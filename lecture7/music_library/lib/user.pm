package music_library::user;
use Dancer2 appname => 'music_library';

use Dancer2::Plugin::Database;

use Digest::MD5 qw(md5_hex);
use Data::Dumper;

our $VERSION = '0.1';

hook before => sub{
	if (!session('user') && request->dispatch_path !~ m{^/(login|registration)}){
		forward '/login', {path => request->path};
	}
};

any ['get', 'post'] => '/login' => sub {
	my $err;

	if(request->method() eq "POST"){
		if(params->{login} && params->{password}){
			my $user = database->quick_select('user', 
				{ login => params->{login}, password => passw(params->{password}) });
			set_user_and_redirect($user, params->{path}) if($user);
			$err = 'Ошибка в логине/пароле';
		} else{
			$err = 'Логин/пароль пусты';
		}
	}
	template 'login', {
		'err' => $err,
		'path' => params->{path},
		'login' => params->{login}
	};
};

any ['get', 'post'] => '/registration' => sub {
	my $err;

	if(request->method() eq "POST"){
		$err = 'Логин/пароль пусты' unless($err || params->{login} && params->{password});
		$err = 'Пароль не совпадает' unless($err || params->{password} eq params->{password2});
		$err = 'Пароль должен быть больше 3х символов' unless($err || length(params->{password})>3);
		unless($err){
			my $user = database->quick_select('user', 
				{ login => params->{login}});
			unless($user){
				$user = database->quick_insert('user', 
					{ login => params->{login}, password => passw(params->{password}), name => params->{name} });
				if($user){
					$user = database->quick_select('user', 
						{ login => params->{login}, password => passw(params->{password})});
					$err = 'OK';
					set_user_and_redirect($user, params->{path}) if($user);
				} else{
					$err = 'Не удалось зарегистрировать, попробуйте позже';
				}
				$err = 'Не удалось войти, попробуйте позже';
			}

			$err = 'Такой логин уже существует';
			params->{login} = '';
		}
	}
	template 'registration', {
		'err' => $err,
		'path' => params->{path},
		'login' => params->{login},
		'name' => params->{name},
	};
};

get '/logout' => sub {
	app->destroy_session;
	redirect '/login';
};

# get '/user/:id' => sub {
# 	template 'user_item', {
# 		'user' => database->quick_select('user', 
# 				{ id => params->{id}});
# 	};
# };

get '/user_list' => sub {
	template 'user_list', {
		'users' => database->selectall_arrayref(
						'SELECT id, login FROM user',
						{ Slice => {} }
					)
	};
};

any ['get', 'post'] => '/user_delete' => sub {
	if(request->method() eq "POST"){
		if(session('token') && session('token') eq params->{token}){
			database->quick_delete('user', {'id' => session('user')->{id}});
			app->destroy_session;
		}
		redirect '/login';
	}
	my $token = generate_token();
	session token => generate_token();

	template 'user_delete',{
		'token' => generate_token()
	};
};

sub passw{
	my ($password) = @_;

	return md5_hex('$a1t'.$password);
};

sub set_user_and_redirect{
	my ($user, $path) = @_;

	session user => $user;

	redirect $path if ($path && $path ne '/logout');
	redirect '/';
};

sub generate_token{
	return join('', map{('a'..'z','A'..'Z',0..9)[rand 62]} 0..20);
}

true;
