+{
    DBI => {
        connect_info => [
        	"dbi:Pg:dbname=nishi_service;host=localhost;port=5432;",'', '', {

        	}
        ]
    },
    
    Auth => +{
	Twitter => +{
	    consumer_key    => 'svqff6gCKMtDaLJXqzDHfKcCy',
	    consumer_secret => 'aWV2YYdoHYYVHqDNVSPeSFlkQi9mKSXKX7AL0cNwlTr3fhPUjg',
	    ssl => 1,
	},
	Github =>  +{
	    client_id       => '41dc8be10a17353bf1d3',
	    client_secret   => 'f6dfc229ed8b9215ee428367cd45b8f64e2dd84a',
	},
	Line_Notify => +{
	    client_id       => 'mijboN1vs24zxpRNndXrvr',
	    client_secret   => 'x2e8NC7OM4ehvQeUUPfjKeqmg7OyDsxDp2JV3nEyrQS',
	}
    }
};
