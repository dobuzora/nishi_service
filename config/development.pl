+{
    DBI => {
        connect_info => [
            "dbi:Pg:dbname=nishi_service;host=localhost;port=5432;",$ENV{PGUSER}, $ENV{PGPASS}, {
            }
        ]
    },
    
    Auth => +{
        LINENotify => +{
            client_id       => $ENV{LINE_CLIENT_ID},
            client_secret   => $ENV{LINE_CLIENT_SECRET}
        }
    }
};
