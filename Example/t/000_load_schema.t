use strict;
use warnings;
use DBI;
use Test::More;
use YAML::XS qw(LoadFile);

# Load the configuration file
my $config = LoadFile('Example/config.yml');

# Extract connection details from the configuration file
my $dsn = $config->{database}->{dsn};
my $username = $config->{database}->{username};
my $password = $config->{database}->{password};

# Connect to the SQLite database
my $dbh = DBI->connect($dsn, $username, $password, {
    RaiseError => 1,
    PrintError => 0,
    AutoCommit => 1,
});

# Read the schema SQL file
open my $fh, '<', 'Example/db/schema.sql' or die "Could not open schema file: $!";
my $schema_sql = do { local $/; <$fh> };
close $fh;

# Split the schema SQL into individual statements
my @statements = split /;\s*/, $schema_sql;

# Execute each SQL statement one at a time
for my $statement (@statements) {
    next unless $statement =~ /\S/;
    eval {
        $dbh->do($statement);
    };
    if ($@) {
        die "Error executing SQL statement: $@";
    }
}

# Disconnect from the database
$dbh->disconnect;

done_testing();
