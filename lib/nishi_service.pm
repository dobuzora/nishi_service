package nishi_service;
use strict;
use warnings;
use utf8;
our $VERSION='0.01';
use 5.008001;
use nishi_service::DB::Schema;
use nishi_service::DB;
use FormValidator::Lite;
use parent qw/Amon2/;

# Enable project local mode.
__PACKAGE__->make_local_context();

sub db {
    my $c = shift;
    if (!exists $c->{db}) {
        my $conf = $c->config->{DBI} or die "Missing configuration about DBI";
        $c->{db} = nishi_service::DB->connect(
            connect_info => $conf->{connect_info},
            # I suggest to enable following lines if you are using mysql.
            # on_connect_do => [
            #     'SET SESSION sql_mode=STRICT_TRANS_TABLES;',
            # ],
        );
    }
    $c->{db};
}


sub validator {
    my $c = shift;
    my $q =  $c->{args}
        ? +{ %{$c->{args}}, $c->req->parameters->flatten}
        : $c->req;

    my $validator = FormValidator::Lite->new($q);

    return $validator;
}

1;
__END__

=head1 NAME

nishi_service - nishi_service

=head1 DESCRIPTION

This is a main context class for nishi_service

=head1 AUTHOR

nishi_service authors.

