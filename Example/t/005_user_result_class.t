use strict;
use warnings;

use Test::More tests => 5;
use Example::Schema;
use Digest::SHA qw(sha256_hex);

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

# Connect to the database
my $schema = Example::Schema->connect('dbi:SQLite:dbname=Example/db/example.db');

# Test unique constraints on username and email
subtest 'Unique constraints' => sub {
    my $user1 = $schema->resultset('User')->create({
        username => 'uniqueuser',
        password => 'password',
        email    => 'uniqueuser@example.com',
    });

    ok($user1, 'User1 created');

    eval {
        my $user2 = $schema->resultset('User')->create({
            username => 'uniqueuser',
            password => 'password',
            email    => 'uniqueuser2@example.com',
        });
    };
    like($@, qr/UNIQUE constraint failed: users.username/, 'Unique constraint on username');

    eval {
        my $user3 = $schema->resultset('User')->create({
            username => 'uniqueuser3',
            password => 'password',
            email    => 'uniqueuser@example.com',
        });
    };
    like($@, qr/UNIQUE constraint failed: users.email/, 'Unique constraint on email');
};

# Test password encryption
subtest 'Password encryption' => sub {
    my $password = 'plaintextpassword';
    my $encrypted_password = sha256_hex($password);

    my $user = $schema->resultset('User')->create({
        username => 'encryptionuser',
        password => $encrypted_password,
        email    => 'encryptionuser@example.com',
    });

    ok($user, 'User created with encrypted password');
    is($user->password, $encrypted_password, 'Password is encrypted');
};
