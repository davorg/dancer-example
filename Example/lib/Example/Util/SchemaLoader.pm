package Example::Util::SchemaLoader;

use strict;
use warnings;
use DBI;
use YAML::XS qw(LoadFile);

sub load_schema {
    my $config = LoadFile('Example/config.yml');
    my $dbh = DBI->connect(
        $config->{database}->{dsn},
        $config->{database}->{username},
        $config->{database}->{password},
        {
            RaiseError => 1,
            PrintError => 0,
            AutoCommit => 1,
        }
    );

    open my $fh, '<', 'Example/db/schema.sql' or die "Could not open schema file: $!";
    my $schema_sql = do { local $/; <$fh> };
    close $fh;

    $dbh->do($schema_sql);
    $dbh->disconnect;
}

1;
