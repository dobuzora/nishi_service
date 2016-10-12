package nishi_service::Web::Request;
use strict;
use warnings;
use utf8;
use parent qw/Amon2::Web::Request/;
use Try::Tiny;
use JSON;

sub decoded_json { decode_json($_[0]->content); }

1;