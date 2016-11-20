package MusicLibrary::User;
use Dancer2 appname => 'MusicLibrary';

use Dancer2::Plugin::Database;

use strict;
use warnings;
use utf8;

use Digest::MD5 qw(md5_hex);
use Scalar::Util qw(reftype);
use Data::Dumper;
use Data::UUID;

our $VERSION = '0.1';

hook before => sub{
	if (!session('user') && request->dispatch_path !~ m{^/(login|registration)$}){
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
	my ($validated, $err);

	if(request->method() eq "POST"){
		my $h_errors = {
			'Логин/пароль пусты' => sub{
				params->{login} && params->{password}
			},
			'Пароль не совпадает' => sub{
				params->{password} eq params->{password2}
			},
			'Пароль должен быть больше 3х символов' => sub{
				length(params->{password})>3
			},
		};

		( $validated, $err ) = _validate_form($h_errors, 
			qw(login password name path));
		unless($err){
			my $user = database->quick_select('user', 
				{ login => $validated->{login}});
			unless($user){
				my $result = database->quick_insert('user', 
					{ login => $validated->{login}, password => passw($validated->{password}), name => $validated->{name} });
				if($result){
					$user = database->quick_select('user', 
						{ login => $validated->{login}, password => passw($validated->{password})});
					set_user_and_redirect($user, $validated->{path}) if($user);
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
			redirect '/login';
		}
	}

	my $token;
	if(session('token')){
		$token = session('token');
	} else{
		$token = generate_token();
		session token => $token;
	}

	template 'user_delete',{
		'token' => $token
	};
};

get '/user/:id' => sub{
	forward '/', {id => params->{id}, path => request->path};
};

# get '/user/:id' => sub {
# 	template 'user_item', {
# 		'user' => database->quick_select('user', 
# 				{ id => params->{id}});
# 	};
# };

sub passw{
	my ($password) = @_;

	return md5_hex(config->{password_salt}.$password);
};

sub set_user_and_redirect{
	my ($user, $path) = @_;

	session user => $user;

	redirect $path if ($path && $path ne '/logout');
	redirect '/';
};

sub generate_token{
	# return join('', map{('a'..'z','A'..'Z',0..9)[rand 62]} 0..20);
	return Data::UUID->new->create_str();
}

sub _validate_form{
	my ($h_errors, @names) = @_;

	for (keys %$h_errors) {
		if($_ && reftype($h_errors->{$_}) eq 'CODE'){
			return ( undef, $_ ) unless ($h_errors->{$_}->());
		}
	}

	my %validate;
	$validate{$_} = params->{$_} for (@names);
	return ( \%validate, undef );
}

true;
