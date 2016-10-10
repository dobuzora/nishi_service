+{
    DBI => {
        connect_info => [
        	"dbi:Pg:dbname=nishi_service;host=localhost;port=5432;",'', '', {

        	}
        ]
    },
    
    Auth => +{
	Twitter => +{
	    consumer_key    => '',
	    consumer_secret => '',
	    ssl => 1,
	},
	Github =>  +{
	    client_id       => '',
	    client_secret   => '',
	},
	Line_Notify => +{
	    client_id       => '',
	    client_secret   => '',
	}
    }
};
