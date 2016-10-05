use strict;
use warnings;
use Test::More;


use nishi_service;
use nishi_service::Web;
use nishi_service::Web::View;
use nishi_service::Web::ViewFunctions;

use nishi_service::DB::Schema;
use nishi_service::Web::Dispatcher;


pass "All modules can load.";

done_testing;
