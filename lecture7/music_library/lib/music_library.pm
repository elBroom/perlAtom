package music_library;
use Dancer2;

use Dancer2::Plugin::Database;
use Dancer2::Plugin::Ajax;
use Digest::MD5 qw(md5_hex);
use Data::Dumper;

use user;

our $VERSION = '0.1';

prefix undef;

get '/:id?' => sub {
	my $user_id = params->{id} || session('user')->{id};
	template 'album_list', {
		'albums' => database->selectall_arrayref(
						'SELECT * FROM album WHERE user_id=?',
						{ Slice => {} },
						$user_id
					),
		'user' => database->quick_select('user', {'id' => $user_id}),
		'current_user' => session('user'),
	};
};

prefix '/album';

any ['get', 'post'] => '/update/:id?' => sub {
	my ($err, $album, $title, $year, $band_name);

	if(params->{id}){
		$album = database->quick_select('album', { id => params->{id} ,user_id => session('user')->{id} });
		redirect '/' unless($album);
	}
	if(request->method() eq "POST"){
		$err = 'Поле Название не заполнено' unless($err || params->{title});
		$err = 'Поле Год не заполнено' unless($err || params->{year});
		$err = 'Поле Группа не заполнено' unless($err || params->{band_name});
		unless($err){
			my $result;
			if(params->{id}){ #new
				$result = database->quick_update('album', { id => params->{id} },
				{ title => params->{title}, year => params->{year}, band_name => params->{band_name} });
			} else{ #old
				$result = database->quick_insert('album', 
				{ title => params->{title}, year => params->{year}, band_name => params->{band_name}, user_id => session('user')->{id} });
			}
			redirect '/' if($result);
		}
		$title = params->{title};
		$year = params->{year};
		$band_name = params->{band_name};
	} else{
		if($album && !params->{title} && !params->{year} && !params->{band_name}){
			$title = $album->{title};
			$year = $album->{year};
			$band_name = $album->{band_name};
		}
	}
	template 'album_update',{
		'id' => params->{id},
		'err' => $err,
		'title' => $title,
		'year' => $year,
		'band_name' => $band_name,
	};
};

any ['get', 'post'] => '/parse' => sub {
	if(request->method() eq "POST" && params->{text}){
		my $i=0;
		foreach my $row (split("\n",params->{text})) {
			if($i % 2){
				my @cells = map {s/^\s+|\s+$//g; $_} split('\|', $row);
				my $band_name = $cells[1];
				my $year = $cells[2];
				my $album_title = $cells[3];
				my $track_name = $cells[4];
				my $format = $cells[5];
				eval {
					database->begin_work;
					my $album = database->quick_select('album', {
						'year' => $year, 'title' => $album_title, 'band_name' => $band_name, 'user_id' => session('user')->{id}
					});
					my $album_id;
					unless($album){
						$album = database->quick_insert('album', {
							'year' => $year, 'title' => $album_title, 'band_name' => $band_name, 'user_id' => session('user')->{id}
						});
						$album_id = database->last_insert_id(undef, undef, 'album', 'id');
					} else{
						$album_id = $album->{id};
					}
					my $track = database->quick_select('track', {
						'name' => $track_name, 'format' => $format, 'album_id' => $album_id
					});
					unless($track){
						$track = database->quick_insert('track', {
							'name' => $track_name, 'format' => $format, 'album_id' => $album_id
						});
					}
					database->commit;
				};
				if ($@) {
					warn "Error add track $@";
					database->rollback;
				}
			}
			$i++;
		}
		redirect '/';
	}
	template 'album_parse';
};


prefix '/track';

get '/list/:id' => sub {
	my $album = database->quick_select('album', {'id' => params->{id}});
	if($album){
		template 'track_list', {
			'tracks' => database->selectall_arrayref(
							'SELECT * FROM track WHERE album_id=?',
							{ Slice => {} },
							params->{id}
						),
			'album' => $album,
			'current_user' => session('user'),
		};
	} else{
		status 'not_found';
		template 'special_404', { path => request->path };
	}
	
};

any ['get', 'post'] => '/update/:id?' => sub {
	my ($err, $track, $name, $format, $album_id, $image, $http_image);

	if(params->{id}){
		$track = database->selectrow_hashref(
								'SELECT t.* FROM track t 
								 JOIN album a ON a.id = t.album_id
								 WHERE t.id=? AND a.user_id=?', {},
								params->{id}, session('user')->{id});
		redirect '/' unless($track);
	}
	if(request->method() eq "POST"){
		$err = 'Поле Название не заполнено' unless($err || params->{name});
		$err = 'Поле Год не заполнено' unless($err || params->{format});
		$err = 'Альбом не выбран' unless($err || params->{album_id});
		$err = 'Адрес изображения не является http(s) ссылкой' unless($err || params->{http_image} =~ m{^$|^https?:\/\/.*(png|jpg|svg|gif|tiff)$});

		# print Dumper(params->{image});
		# if(!$err && params->{image}){
		# 	$image = params->{album_id}.'_'.generate_file_name;
		# 	my $dir = path(config->{appdir}, 'uploads');
		# 	mkdir $dir if not -e $dir;
		# 	my $path = path($dir, $image);
		# 	request->upload('image')->link_to($path);
		# 	print Dumper($path);
		# } elsif($track){
		# 	$image = $track->{image};
		# }

		unless($err){
			my $result;
			if(params->{id}){ #new
				$result = database->quick_update('track', { id => params->{id} },
				{ name => params->{name}, format => params->{format}, album_id => params->{album_id}, http_image => params->{http_image}, image => params->{image} });
			} else{ #old
				$result = database->quick_insert('track', 
				{ name => params->{name}, format => params->{format}, album_id => params->{album_id}, http_image => params->{http_image}, image => params->{image} });
			}
			redirect '/track/list/'.params->{album_id} if($result);
		}
		$name = params->{name};
		$format = params->{format};
		$album_id = params->{album_id};
		$http_image = params->{http_image};
	} else{
		if($track && !params->{name} && !params->{format} && !params->{album_id}){
			$name = $track->{name};
			$format = $track->{format};
			$album_id = $track->{album_id};
			$http_image = $track->{http_image};
			$image = $track->{image};
		}
	}
	template 'track_update',{
		'id' => params->{id},
		'err' => $err,
		'name' => $name,
		'format' => $format,
		'album_id' => $album_id,
		'http_image' => $http_image,
		'image' => $image,
		'albums' => database->selectall_arrayref(
						'SELECT id, title FROM album WHERE user_id=?',
						{ Slice => {} },
						session('user')->{id}
					),
	};
};

ajax '/delete/:id' => sub {
	my $track = database->selectrow_hashref(
							'SELECT t.* FROM track t 
							 JOIN album a ON a.id = t.album_id
							 WHERE t.id=? AND a.user_id=?', {},
							params->{id}, session('user')->{id});
	if($track){
		database->quick_delete('track', {'id' => params->{id}});
		return to_json { id => params->{id} };
	} else{
		return to_json { error => 'permission denied' };
	}
};

sub generate_file_name{
	return md5_hex(localtime(time));
}

true;
