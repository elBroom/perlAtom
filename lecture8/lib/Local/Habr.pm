package Local::Habr;

use v5.10;
use strict;
use warnings;
no warnings 'experimental';

use Data::Dumper;

use Local::Post;
use Local::User;

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
		_command _format _params
	/],
};

sub new{
	my ($class, %params) = @_;
	my $self = bless {}, $class;

	$self->_command($params{'command'});
	$self->_format(Local::FormatFabric->new($params{'format'}));
	$self->_params($params{'params'});

	my $site = $params{'site'} || 'habrahabr';
	my $post = Local::Post->new;
	$post->site($site);
	$post->refresh($params{'refresh'});
	my $user = Local::User->new;
	$user->site($site);
	$user->refresh($params{'refresh'});
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
				return Local::User->new->get_user($self->_params->{'name'});
			} elsif($self->_params->{'post'}){
				return Local::User->new->get_user_post($self->_params->{'post'});
			} else{
				die 'Not valid arguments';
			}
		}
		when('commenters'){
			if($self->_params->{'post'}){
				return Local::User->new->get_commenters($self->_params->{'post'})->{'comments'};
			} else{
				die 'Not valid arguments';
			}
		}
		when('post'){
			if($self->_params->{'id'}){
				return Local::Post->new->get_posts($self->_params->{'id'});
			} else{
				die 'Not valid arguments';
			}
		}
		when('desert_posts'){
			if($self->_params->{'n'}){
				return Local::Post->new->get_desert_posts($self->_params->{'n'});
			} else{
				die 'Not valid arguments';
			}
		}
		when('self_commentors'){
			return Local::User->new->get_self_commentors;
		}
		default{
			die 'Not valid arguments';
		}
	}
	return '';
}

1;
