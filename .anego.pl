require nishi_service;
my $config = nishi_service->config;

+{
    "connect_info" => $config->{DBI}{connect_info},
    "schema_class" => 'nishi_service::DB::Schema'
};