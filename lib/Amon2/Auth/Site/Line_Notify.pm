package Amon2::Auth::Site::Line_Notify;

use strict;
use warnings;
use utf8;

use Mouse;
use LWP::UserAgent;
use URI;
use JSON;
use Amon2::Auth::Util qw(parse_content);
use Amon2::Auth;
use Data::Dumper;


sub moniker { 'line_notify' } 

has client_id => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);


has client_secret => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);


has user_info => (
    is => 'rw',
    isa => 'Bool',
    default => 1,
); 


has ua => (
    is => 'ro',
    isa => 'LWP::UserAgent',
    lazy => 1,
    default => sub {
	my $ua = LWP::UserAgent->new(agent => "Amon2::Auth/$Amon2::Auth::VERSION");
    },
);

has authorize_url => (
    is => 'ro',
    isa => 'Str',
    default => 'https://notify-bot.line.me/oauth/authorize',
);

has access_token_url => (
    is => 'ro',
    isa => 'Str',
    default => 'https://notify-bot.line.me/oauth/token',
);

has redirect_url => (
    is => 'ro',
    isa => 'Str',
);


sub auth_uri {
    my ($self, $c, $callback_uri) = @_;

    my $redirect_uri = URI->new($self->authorize_url);
    my %params;
    if (defined $callback_uri) {
        $params{redirect_uri} = $callback_uri;
    } elsif (defined $self->redirect_url) {
        $params{redirect_uri} = $self->redirect_url;
    }
    #$params{redirect_uri} = 'http://127.0.0.1:5000/callback';
    #$params{redirect_uri} = 'http://127.0.0.1:5000/auth/line_notify/callback';
    $params{response_type} = 'code';
    $params{client_id} = $self->client_id;
    $params{scope} = 'notify';
    #$params{response_mode} = 'form_post';
    #$params{state} = $c->get_csrf_defender_token();
    $params{state} = $c->session->xsrf_token();
    print STDERR Dumper %params;
    $redirect_uri->query_form(%params);
    print STDERR "\n"."****************************************";
    return $redirect_uri->as_string;
}

sub callback {
    my ($self, $c, $callback) = @_;

    my $code = $c->req->param('code') or die "Cannot get a 'code' parameter";
    my %params = (code => $code);
    warn $code;
    #warn $self->redirect_url;
    $params{grant_type} = 'authorization_code';
    $params{client_id} = $self->client_id;
    $params{client_secret} = $self->client_secret;
    $params{redirect_uri} = $self->redirect_url if defined $self->redirect_url;
    $params{redirect_uri} =  'http://127.0.0.1:5000/auth/line_notify/callback';
    print STDERR Dumper %params;
    #$req->header('Content-Type' => 'application/x-www-form-urlencoded');
    print STDERR "\n",%params;

    my $res = $self->ua->post($self->access_token_url, \%params);
    print STDERR "\n",$res;
    $res->is_success or die "Cannot authenticate";
    my $dat = parse_content($res->decoded_content);
    if (my $err = $dat->{error}) {
	return $callback->{on_error}->($err);
    }
    my $access_token = $dat->{access_token} or die "Cannot get a access_token";
    print STDERR "###########################################";
    return $callback->{on_finished}->( $access_token );
}




1;
