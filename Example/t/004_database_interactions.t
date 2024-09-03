use strict;
use warnings;

use Test::More tests => 3;
use Example::Schema;
use DBIx::Class::Schema::Loader qw/ make_schema_at /;

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
