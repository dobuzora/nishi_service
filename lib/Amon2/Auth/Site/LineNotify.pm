package Amon2::Auth::Site::LINENotify;

use strict;
use warnings;
use utf8;

use Mouse;
use Furl;
use URI;
use JSON::XS;
use Amon2::Auth;

sub moniker { 'line_notify' }

has furl => (
    is => 'ro',
    isa => 'Furl',
    lazy => 1,
    default => sub {
        Furl->new(agent => "Amon2::Auth/$Amon2::Auth::VERSION");
    }
);

has authorize_url => (
    is => 'ro',
    isa => 'Str',
    default => 'https://notify-bot.line.me/oauth/authorize'
);

has access_token_url => (
    is => 'ro',
    isa => 'Str',
    default => 'https://notify-bot.line.me/oauth/token'
);

has client_id => (
    is => 'ro',
    isa => 'Str',
    required => 1
);

has client_secret => (
    is => 'ro',
    isa => 'Str',
    required => 1
);

has scope => (
    is      => 'ro',
    isa     => 'Str',
    default => 'notify'
);

has response_type => (
    is      => 'ro',
    isa     => 'Str',
    default => 'code'
);

has grant_type => (
    is      => 'ro',
    isa     => 'Str',
    default => 'authorization_code'
);

sub auth_uri {
    my ($self, $c, $callback_uri) = @_;

    my $redirect_uri = URI->new($self->authorize_url);
    my %params = (
        redirect_uri => $callback_uri,
        state => $c->session->xsrf_token
    );
    $params{$_} = $self->$_ for qw/response_type scope client_id/;
    $redirect_uri->query_form(%params);

    return $redirect_uri->as_string;
}

sub callback {
    my ($self, $c, $callback) = @_;

    my $code = $c->req->param('code') or die "Could not get a 'code' parameter";
    my $redirect_uri = $c->req->uri->clone;
    $redirect_uri->query_form(+{});
    my %params = (
        code => $code,
        redirect_uri => $redirect_uri->as_string
    );
    $params{$_} = $self->$_ for qw/grant_type client_id client_secret/;

    my $res = $self->furl->post(
        $self->access_token_url,
        ['Content-Type' => 'application/x-www-form-urlencoded'],
        \%params
    );
    die "Could not authenticate: ".$res->status_line unless $res->is_success;
    my $decoded_content = decode_json($res->decoded_content);
    my $access_token = $decoded_content->{access_token} or die "Cannot get a access_token";

    return $callback->{on_finished}->($access_token);
}

__PACKAGE__->meta->make_immutable();

1;
