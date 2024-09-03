use strict;
use warnings;
use DBI;
use Test::More;

# Connect to the SQLite database
my $dbh = DBI->connect("dbi:SQLite:dbname=Example/db/example.db", "", "", {
    RaiseError => 1,
    PrintError => 0,
    AutoCommit => 1,
});

# Read the schema SQL file
open my $fh, '<', 'Example/db/schema.sql' or die "Could not open schema file: $!";
my $schema_sql = do { local $/; <$fh> };
close $fh;

# Execute the schema SQL
$dbh->do($schema_sql);

# Disconnect from the database
$dbh->disconnect;

done_testing();
