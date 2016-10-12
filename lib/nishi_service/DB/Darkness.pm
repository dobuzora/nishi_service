package nishi_service::DB::Darkness;
use 5.014002;
use Mouse;
extends qw/nishi_service::Utils Aniki::Row/;

use Try::Tiny;

__PACKAGE__->meta->make_immutable();

# class method
sub create_user {
	my ($class, $token, $data) = @_;
	$data->{token} = $token;
	return $class->db->insert_and_fetch_row(users => $data);
}

sub find_token {
    my ($class, $username, $password) = @_;
    my $row = $class->find(users => {
    	username => $username,
    	password => $password
    });
    return $row || undef;
}

sub find_userid {
	my ($class, $username) = @_;
    my $row = $class->find(users => {
    	username => $username
    });
    return $row->id || undef;
}

sub insert_url {
	my ($class, $username, $url) = @_;
	my $user_id = $class->find_userid($username);
	$class->db->insert_and_fetch_row(hang_url => {
		user_id => $user_id,
		url     => $url
	}) or return undef;

	try {
		$class->db->insert_and_fetch_row(website => {
			url => $url
		});
	} catch {
        warn $_;
    };

    return 1;
}

sub find {
	my ($class, $table, $params) = @_;
	my $row = $class->db->select($table => $params)->first;
	return $row;
}

sub has_url {
	my ($class, $url) = @_;
	my $row = find(website => {
		url => $url
	});
	return $row || undef;
}

1;
