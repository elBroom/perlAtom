package Local::HabrFacade;

use v5.10;
use strict;
use warnings;
no warnings 'experimental';

use Data::Dumper;

use Local::Habr::Commenter;
use Local::Habr::Post;
use Local::Habr::User;

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
		_command _format _params _commenter _user _post
	/],
};

sub new{
	my ($class, %params) = @_;
	my $self = bless {}, $class;

	$self->_command($params{'command'});
	$self->_format(Local::FormatFabric->new($params{'format'}));
	$self->_params($params{'params'});

	my $site = $params{'site'} || 'habrahabr';
	
	$self->_commenter(Local::Habr::Commenter->new(refresh=>$params{'refresh'}, site=>$site));
	$self->_user(Local::Habr::User->new(refresh=>$params{'refresh'}, site=>$site));
	$self->_post(Local::Habr::Post->new(refresh=>$params{'refresh'}, site=>$site));
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
				return $self->_user->get_user($self->_params->{'name'});
			} elsif($self->_params->{'post'}){
				my $post = $self->_post->get_post($self->_params->{'post'});
				return $self->_user->get_user($post->{'author'});
			} else{
				die 'Not valid arguments';
			}
		}
		when('post'){
			if($self->_params->{'id'}){
				return $self->_post->get_posts($self->_params->{'id'});
			} else{
				die 'Not valid arguments';
			}
		}
		when('commenters'){
			if($self->_params->{'post'}){
				return $self->_commenter->get_commenters($self->_params->{'post'});
			} else{
				die 'Not valid arguments';
			}
		}
		when('desert_posts'){
			if($self->_params->{'n'}){
				return $self->_commenter->get_desert_posts($self->_params->{'n'});
			} else{
				die 'Not valid arguments';
			}
		}
		when('self_commentors'){
			return $self->_commenter->get_self_commentors;
		}
		default{
			die 'Not valid arguments';
		}
	}
	return '';
}

1;
