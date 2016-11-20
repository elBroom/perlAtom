package MusicLibrary;
use Dancer2;

use Dancer2::Plugin::Database;
use Dancer2::Plugin::Ajax;

use Digest::MD5 qw(md5_hex);
use Data::Dumper;

use strict;
use warnings;
use utf8;
use Encode qw(decode_utf8);

use User;

our $VERSION = '0.1';

prefix undef;

get '/' => sub {
	my $user_id = params->{id} || session('user')->{id};
	my $user = database->quick_select('user', {'id' => $user_id});
	if($user){
		template 'album_list', {
			'albums' => database->selectall_arrayref(
							'SELECT * FROM album WHERE user_id=? ORDER BY `title`',
							{ Slice => {} },
							$user_id
						),
			'user' => $user,
			'current_user' => session('user'),
		};
	} else{
		render_404(params->{path} || request->path);
	}
};

get '/uploads/:name' => sub {
	my $types = join '|', values config->{images}->{types};
	if (params->{name} =~ /^[\d\w_]+\.($types)$/s){
		my $dir = get_dir_images();
		my $path = path($dir, params->{name});

		if (-e $path) {
			return send_file($path, system_path => 1);
		}
	}
	render_404(request->path);
};

prefix '/album';

any ['get', 'post'] => '/update/:id?' => sub {
	my ($err, $validated, $album, $title, $year, $band_name);

	if(params->{id}){
		$album = database->quick_select('album', { id => params->{id} ,user_id => session('user')->{id} });
		render_404(request->path) unless($album);
	}
	if(request->method() eq "POST"){
		my $h_names = {
			id => 'Id', 
			title => 'Название', 
			year => 'Год', 
			band_name => 'Группа',
		};
		( $validated, $err ) = _validate_album($h_names);

		unless($err){
			my $result;
			if($validated->{id}){ #old
				$result = database->quick_update('album', { id => $validated->{id} },
				{ title => $validated->{title}, year => $validated->{year}, band_name => $validated->{band_name} });
			} else{ #new
				$result = database->quick_insert('album', 
				{ title => $validated->{title}, year => $validated->{year}, band_name => $validated->{band_name}, user_id => session('user')->{id} });
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
					1;
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
							'SELECT * FROM track WHERE album_id=? ORDER BY  `name`',
							{ Slice => {} },
							params->{id}
						),
			'album' => $album,
			'current_user' => session('user'),
			'images_dir' => '/'.config->{images}->{dir}.'/',
		};
	} else{
		render_404(request->path);
	}
	
};

any ['get', 'post'] => '/update/:album_id/:id?' => sub {
	my ($err, $validated, $album_title, $track, $name, $format, $album_id, $image, $http_image);

	if(params->{id}){
		$track = database->selectrow_hashref(
				'SELECT t.*, a.title FROM track t 
				 JOIN album a ON a.id = t.album_id
				 WHERE t.album_id =? AND t.id=? AND a.user_id=?', {},
				params->{album_id}, params->{id}, session('user')->{id});
		render_404(request->path) unless($track);
		$album_title = $track->{title};
	} else{
		my $album = database->quick_select('album', { id => params->{album_id} ,user_id => session('user')->{id} });
		render_404(request->path) unless($album);
		$album_title = $album->{title};
	}

	if(request->method() eq "POST"){
		$image = $track->{image} if($track);

		my $h_names = {
			id => 'Id', 
			name => 'Название', 
			format => 'Формат', 
			image => 'Изображение',
			http_image => 'Адрес изображения',
			_album_id => 'Альбом',
		};
		( $validated, $err ) = _validate_track($h_names);

		unless($err){
			if($validated->{image}){
				my $dir = get_dir_images();
				my $old_image = $image;
				$image = $validated->{_album_id}.'_'.generate_file_name().'.'.get_image_suffix(request->upload('image')->type);
				my $path = path($dir, $image);
				
				request->upload('image')->link_to($path);
				if($old_image){
					$path = path($dir, $old_image);
					unlink($path) if -e $path;
				}
			}

			my $result;
			if($validated->{id}){ #old
				$result = database->quick_update('track', { id => $validated->{id} },
				{ name => $validated->{name}, format => $validated->{format}, album_id => $validated->{_album_id}, http_image => $validated->{http_image}, image => $image });
			} else{ #new
				$result = database->quick_insert('track', 
				{ name => $validated->{name}, format => $validated->{format}, album_id => $validated->{_album_id}, http_image => $validated->{http_image}, image => $image });
			}
			redirect '/track/list/'.$validated->{_album_id} if($result);
		}
		$name = params->{name};
		$format = params->{format};
		$album_id = params->{_album_id};
		$http_image = params->{http_image};
	} else{
		if($track && !params->{name} && !params->{format}){
			$name = $track->{name};
			$format = $track->{format};
			$album_id = $track->{album_id};
			$http_image = $track->{http_image};
			$image = $track->{image};
		}
	}
	template 'track_update',{
		'id' => params->{id},
		'album_title' => $album_title,
		'err' => $err,
		'name' => $name,
		'format' => $format,
		'album_id' => $album_id,
		'http_image' => $http_image,
		'image' => $image,
		'images_dir' => '/'.config->{images}->{dir}.'/',
	};
};

ajax '/delete/:id' => sub {
	my $track = database->selectrow_hashref(
							'SELECT t.* FROM track t 
							 JOIN album a ON a.id = t.album_id
							 WHERE t.id=? AND a.user_id=?', {},
							params->{id}, session('user')->{id});
	if($track){
		database->quick_delete('track', {'id' => $track->{id}});
		if($track->{image}){
			my $dir = get_dir_images();
			my $path = path($dir, $track->{image});
			unlink($path) if -e $path;
		}
		return to_json { id => $track->{id} };
	} else{
		return to_json { error => 'permission denied' };
	}
};

sub check_type{
	my ($type) = @_;

	return defined(config->{images}->{types}->{$type});
}

sub get_image_suffix{
	my ($type) = @_;

	return config->{images}->{types}->{$type};
}

sub generate_file_name{
	return md5_hex(localtime(time));
}

sub get_dir_images{
	my $dir = path(config->{appdir}, config->{images}->{dir});

	if(not -e $dir){
		mkdir $dir or die "Directory $dir cannot be created: ".decode_utf8($!);
	}
	return $dir;
}

sub render_404{
	my ($path) = @_;

	status 404;
	return "No such page: $path";
}

sub _validate_album{
	my ($h_names) = @_;
	my %validated;

	for my $name (keys %$h_names) {
		my $value = params->{$name};
		if ($name eq 'title' or $name eq 'year' or $name eq 'band_name'){
			unless($value){
				return (undef, "Поле $h_names->{$name} не заполнено");
			}
		}
		if($name eq 'year'){
			unless($value =~ /[\d]{4}/s){
				return (undef, "Поле $h_names->{$name} должен быть четырех разрядным числом");
			}
		}
		$validated{$name} = $value;
	}

	return( \%validated, undef );
}

sub _validate_track{
	my ($h_names) = @_;
	my %validated;

	for my $name (keys %$h_names) {
		my $value = params->{$name};
		if ($name eq 'name' or $name eq 'format'){
			unless($value){
				return (undef, "Поле $h_names->{$name} не заполнено");
			}
		}
		if($name eq 'http_image'){
			unless($value =~ m{^$|^https?:\/\/[^&?]+\.(png|jpg|jpeg|svg|svgz|gif|tif|tiff|bmp|ico|wbmp|webp)$}s){
				return (undef, "$h_names->{$name} не является корректной http(s) ссылкой");
			}
		}
		if($name eq 'image'){
			if($value && !check_type(request->upload($name)->type)){
				return (undef, "Тип файла не соответствует изображению");
			}
		}
		$validated{$name} = $value;
	}

	return( \%validated, undef );
}

true;
