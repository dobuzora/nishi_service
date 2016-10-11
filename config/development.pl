+{
    DBI => {
        connect_info => [
        	"dbi:Pg:dbname=nishi_service;host=localhost;port=5432;",'', '', {
        	}
        ]
    },
    
    Auth => +{
	Line_Notify => +{
	    client_id       => '',
	    client_secret   => '',
	}
    }
};
