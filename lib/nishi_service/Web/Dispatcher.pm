package nishi_service::Web::Dispatcher;
use strict;
use warnings;
use utf8;
use JSON::XS;
use nishi_service::Utils qw/darkness/;
use Data::Validate::URI qw/is_uri/;
use Amon2::Web::Dispatcher::RouterBoom;

sub is_login {
    my $session = shift;
    my $username = $session->get('username') // '';
    return 0 unless $username;
    return 1;
}

get '/' => sub {
    my $c = shift;
    if (is_login($c->session)) {
        my $username = $c->session->get('username');
        my $token = $c->session->get('token');
        return $c->render('index.tx', {
           token => $token,
        });
    }

    return $c->redirect('/login');
};

get '/login' => sub { shift->render('login.tx') };

get '/account/login' => sub {
    my $c = shift;
    return $c->redirect('/') if is_login($c->session);
    return $c->render('account.tx');
};

get '/account/register' => sub {
    my $c = shift;
    my $token = $c->session->get('token') // '';
    return $c->redirect('/login') unless $token;

    $c->render('register.tx');
};

post '/auth' => sub {
    my $c = shift;
    my $v = $c->validator;
    $v->check(
        username => [qw/NOT_NULL/],
        password => [[qw/LENGTH 4 16/]]
    );

    if ($v->is_valid) {
        my $username = $v->query->param('username');
        my $password = $v->query->param('password');
        my $token = darkness->find_token($username => $password)->token;
        $c->session->set(username => $username);
        $c->session->set(token => $token);

        return $c->redirect('/');
    }

    return $c->redirect('/account/register');
};

post '/adduser' => sub {
    my $c = shift;
    my $v = $c->validator;
    $v->check(
        username => [qw/NOT_NULL/],
        password => [[qw/LENGTH 4 16/]]
    );

    if ($v->is_valid) {
        my $token = $c->session->get('token') or die "failed to get token from session";
        my $username = $v->query->param('username');
        my $password = $v->query->param('password');

        darkness->create_user($token => {
            username => $username,
            password => $password,
        }) or die "Cannot create user";

        $c->session->set(username => $username);
        $c->session->set(token => $token);

        return $c->redirect('/');
    }

    return $c->redirect('/account/register');
};

post '/addurl' => sub {
    my $c = shift;
    my $username = $c->session->get('username');
    my $content = $c->req->decoded_json;
    foreach my $url (@{$content->{urls}}) {
        warn "Do $url";
        if (is_uri($url)) {
            my $result = darkness->insert_url($username => $url);
            return $c->render_json(+{status => 'failed', reason => "Could not insert url: $url"}) unless $result;
        } else {
            warn "Not url: $url";
        }
    }
    return $c->render_json(+{status => 'success'});
};

get '/logout' => sub {
    my $c = shift;
    $c->session->expire();
    return $c->redirect('/');
};

1;
