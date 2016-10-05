+{
    DBI => {
        connect_info => [
        	"dbi:Pg:dbname=nishi_service;host=localhost;port=5432;",'root', '$ENV{MYSQL_PASSWORD}', {

        	}
        ]
    }
};
