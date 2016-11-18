package Local::Habr;

use v5.10;
use strict;
use warnings;
no warnings 'experimental';

use Data::Dumper;

use Local::Source::Loader;
use Local::Source::MySQL;
use Local::Source::Memcached;
use Local::FormatFabric;

=encoding utf8

=head1 NAME

Local::Habr - habrahabr.ru crawler

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

use Class::XSAccessor {
	accessors => [qw/
		_command _format _refresh _params _site _loader _memcached _db
	/],
};

sub new{
	my ($class, %params) = @_;
	my $self = bless {}, $class;

	$self->_command($params{'command'});
	$self->_refresh($params{'refresh'});
	$self->_params($params{'params'});
	$self->_site($params{'site'} or 'habrahabr');
	$self->_format(Local::FormatFabric->new($params{'format'}));

	$self->_loader(Local::Source::Loader->new('site'=>$self->_site));
	$self->_db(Local::Source::MySQL->new('site'=>$self->_site));
	$self->_memcached(Local::Source::Memcached->new('site'=>$self->_site));

	return $self;
}

sub get{
	my ($self) = @_;
	return $self->_format->get($self->_get_data);
}

sub _get_data{
	my ($self) = @_;

	given($self->_command){
		when('user'){
			if($self->_params->{'name'}){
				return $self->_get_user($self->_params->{'name'});
			} elsif($self->_params->{'post'}){
				return $self->_get_user_post($self->_params->{'post'});
			} else{
				die 'Not valid arguments';
			}
		}
		when('commenters'){
			if($self->_params->{'post'}){
				return $self->_get_commenters($self->_params->{'post'})->{'comments'};
			} else{
				die 'Not valid arguments';
			}
		}
		when('post'){
			if($self->_params->{'id'}){
				return $self->_get_posts($self->_params->{'id'});
			} else{
				die 'Not valid arguments';
			}
		}
		when('desert_posts'){
			if($self->_params->{'n'}){
				return $self->_get_desert_posts($self->_params->{'n'});
			} else{
				die 'Not valid arguments';
			}
		}
		when('self_commentors'){
			return $self->_get_self_commentors;
		}
		default{
			die 'Not valid arguments';
		}
	}
	return '';
}

sub _get_user{
	my ($self, $name) = @_;
	my $result;

	my $loader = sub{
		$result = $self->_loader->get_user($name);
		die "User not found $name" unless($result);
		return $result;
	};

	my $mysql = sub{
		$result = $self->_db->get_user($name) unless($self->_refresh);
		unless($result){
			$result = $loader->();
			$self->_db->set_user($result);
		}
		return $result;
	};

	my $memcached = sub{
		$result = $self->_memcached->get_user($name) unless($self->_refresh);
		unless($result){
			$result = $mysql->();
			$self->_memcached->set_user($result);
		}
		return $result;
	};
	
	return $memcached->();
}

sub _get_posts{
	my ($self, $ids) = @_;
	my @result;
	for (grep { $_>0 } map { $_+0 } split /,/, $ids){
		my $post = $self->_get_post($_);
		delete $post->{'id'};
		delete $post->{'comments'};
		push(@result, $post);
	}
	return \@result;
}

sub _get_post{
	my ($self, $id) = @_;
	my $result;

	my $loader = $self->_get_loader_post($id);

	my $mysql = sub{
		$result = $self->_db->get_post($id) unless($self->_refresh);
		unless($result){
			$result = $loader->();
			$self->_db->set_post($result);
		}
		return $result;
	};
	
	return $mysql->();
}

sub _get_commenters{
	my ($self, $id) = @_;
	my $result;

	my $loader = $self->_get_loader_post($id);

	my $mysql = sub{
		my $commenters = $self->_db->get_commenters($id) unless($self->_refresh);
		unless(@{$commenters}){
			$result = $loader->();
			$self->_db->set_post($result);
		} else{
			$result->{'comments'} = $commenters;
		}
		return $result;
	};
	
	return $mysql->();
}

sub _get_user_post{
	my ($self, $post) = @_;
	my $author = $self->_get_post($post)->{'author'};
	return $self->_get_user($author);
}

sub _get_self_commentors{
	my ($self) = @_;

	my $mysql = sub{
		return $self->_db->get_self_commentors;
	};

	my $memcached = sub{
		my $result = $self->_memcached->get_self_commentors() unless($self->_refresh);
		unless($result){
			$result = $mysql->();
			$self->_memcached->set_self_commentors($result);
		}
		return $result;
	};
	
	return $memcached->();
}

sub _get_desert_posts{
	my ($self, $n) = @_;

	my $mysql = sub{
		return $self->_db->get_desert_posts($n);
	};

	my $memcached = sub{
		my $result = $self->_memcached->get_desert_posts($n) unless($self->_refresh);
		unless($result){
			$result = $mysql->();
			$self->_memcached->set_desert_posts({$n => $result});
		}
		return $result;
	};
	
	return $memcached->();
}

sub _get_loader_post{
	my ($self, $id) = @_;
	my $result;

	my $loader = sub{
		$result = $self->_loader->get_post($id);
		die "Post not found $id" unless($result);

		my @commenters;
		for my $name (@{$result->{'comments'}}) {
			my $user = $self->_get_user($name);
			if($user){
				push(@commenters, $user);
				$self->_db->set_commenter($result, $user);
			}
		}
		$result->{'comments'} = \@commenters;
		$self->_memcached->del_self_commentors();
		$self->_memcached->del_desert_posts();
		return $result;
	};

	return $loader;
}

1;
