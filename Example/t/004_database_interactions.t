use strict;
use warnings;

use Test::More tests => 3;
use Example::Schema;
use DBIx::Class::Schema::Loader qw/ make_schema_at /;

# Subroutine to load the schema directly within the test file
sub load_schema {
    use DBI;
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

# Call the new subroutine before running the tests
load_schema();

# Load the schema
my $schema = Example::Schema->connect('dbi:SQLite:dbname=Example/db/example.db');

# Test user creation in the database
subtest 'User creation' => sub {
    my $user = $schema->resultset('User')->create({
        username => 'testuser',
        password => 'testpassword',
        email    => 'testuser@example.com',
    });

    ok($user, 'User created');
    is($user->username, 'testuser', 'Username is correct');
    is($user->email, 'testuser@example.com', 'Email is correct');
};

# Test user retrieval from the database
subtest 'User retrieval' => sub {
    my $user = $schema->resultset('User')->find({ username => 'testuser' });

    ok($user, 'User retrieved');
    is($user->username, 'testuser', 'Username is correct');
    is($user->email, 'testuser@example.com', 'Email is correct');
};
