package nishi_service::DB;
use 5.014002;
use Mouse;
extends qw/Aniki/;

__PACKAGE__->setup(
    schema => 'nishi_service::DB::Schema',
    filter => 'nishi_service::DB::Filter',
    row    => 'nishi_service::DB::Row',
);

__PACKAGE__->meta->make_immutable();

sub connect {
	my $class = shift;
	$class->new(@_);
}

1;