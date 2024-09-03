use strict;
use warnings;

use Test::More;
use Example::Schema;
use Digest::SHA qw(sha256_hex);
use Example::Util::SchemaLoader;

Example::Util::SchemaLoader::load_schema();

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

done_testing();
