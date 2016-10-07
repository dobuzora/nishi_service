package nishi_service::Utils;

use strict;
use warnings;
use utf8;
use Exporter 'import';

# Tools
use Clone qw/clone/;
use Time::Moment;

use nishi_service;

our @EXPORT_OK = qw/config/;

# class methods
sub db     { nishi_service->context->db }
sub config { clone(nishi_service->context->config) }

# time
sub now { Time::Moment->now }


1;
