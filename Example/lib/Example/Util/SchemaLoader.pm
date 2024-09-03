package Example::Util::SchemaLoader;

use strict;
use warnings;
use DBI;

sub load_schema {
    my $dbh = DBI->connect("dbi:SQLite:dbname=Example/db/example.db", "", "", {
        RaiseError => 1,
        PrintError => 0,
        AutoCommit => 1,
    });

    open my $fh, '<', 'Example/db/schema.sql' or die "Could not open schema file: $!";
    my $schema_sql = do { local $/; <$fh> };
    close $fh;

    $dbh->do($schema_sql);
    $dbh->disconnect;
}

1;
