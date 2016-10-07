package nishi_service::DB::Schema;
use 5.014002;

use DBIx::Schema::DSL;
use Aniki::Schema::Relationship::Declare;

database 'PostgreSQL';

create_table 'users' => columns {
	integer 'id', primary_key, unsigned, auto_increment;
	integer 'user_id', not_null, unsigned;
	varchar 'token', not_null;
	datetime 'created_at', not_null;
};

create_table 'hang_url' => columns {
	integer  'id', primary_key, unsigned, auto_increment;
	integer  'user_id', not_null, unsigned;
	varchar  'url', primary_key;
	tinyint  'do_notify', default => 0, not_null;
	datetime 'created_at', not_null;
	datetime 'update_at', not_null;
};

create_table 'website' => columns {
	integer  'id', primary_key, unsigned, auto_increment;
	varchar  'url', primary_key;
	varchar  'html_hash';
	datetime 'created_at', not_null;
};

1;