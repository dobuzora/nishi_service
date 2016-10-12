package nishi_service::DB::Filter;
use 5.014002;
use Data::Dumper;
use Aniki::Filter::Declare;
use nishi_service::Utils qw/now to_sql_datetime from_sql_datetime/;

trigger insert => sub {
    my ($row, $next) = @_;
    $row->{created_at} ||= now;
    $row->{updated_at} ||= now;
    warn Dumper $row;
    return $next->($row);
};

inflate qr/_at$/ => sub { from_sql_datetime($_[0]) };
deflate qr/_at$/ => sub { to_sql_datetime($_[0]) };

1;