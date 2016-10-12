package nishi_service::Utils;

use strict;
use warnings;
use utf8;
use Exporter 'import';

# Tools
use Clone qw/clone/;
use Time::Moment;
use Scalar::Util qw/blessed/;
use nishi_service;

our @EXPORT_OK = qw/now config to_sql_datetime from_sql_datetime darkness/;

# class methods
sub db     { nishi_service->context->db }
sub config { clone(nishi_service->context->config) }
sub darkness { 'nishi_service::DB::Darkness' }

# time
sub now { Time::Moment->now }

# from papix's code
sub from_sql_datetime {
    my $datetime = shift;
    $datetime =~ tr/ /T/;
    return Time::Moment->from_string("${datetime}Z");
}

sub to_sql_datetime {
    my $datetime = shift;
    return $datetime->at_utc->strftime('%F %T%6f') if blessed $datetime and $datetime->isa('Time::Moment');
    return $datetime;
}


1;
