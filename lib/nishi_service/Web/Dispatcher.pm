package nishi_service::Web::Dispatcher;
use strict;
use warnings;
use utf8;
use Amon2::Web::Dispatcher::RouterBoom;
#use nishi_service::Auth::Line_Notify;
use Data::Dumper;

any '/' => sub {
    my ($c) = @_;
    $c->session->set("xsrf" => Amon2::Util::random_string(32));
    my $counter = $c->session->get('counter') || 0;
    $counter++;
    $c->session->set('counter' => $counter);
    return $c->render('index.tx', {
	counter => $counter,
    });
};


post '/reset_counter' => sub {
    my $c = shift;
    $c->session->remove('counter');
    return $c->redirect('/');
};

post '/account/logout' => sub {
    my ($c) = @_;
    $c->session->expire();
    return $c->redirect('/');
};

1;
