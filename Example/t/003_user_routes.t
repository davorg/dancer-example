use strict;
use warnings;

use Example;
use Test::More tests => 4;
use Plack::Test;
use HTTP::Request::Common;
use Ref::Util qw<is_coderef>;

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

my $app = Example->to_app;
ok( is_coderef($app), 'Got app' );

my $test = Plack::Test->create($app);

# Test user registration route
my $res = $test->request( GET '/register' );
ok( $res->is_success, '[GET /register] successful' );

$res = $test->request(
    POST '/register' => [
        username         => 'testuser',
        password         => 'password',
        confirm_password => 'password',
        email            => 'testuser@example.com',
    ]
);
ok( $res->is_redirect, '[POST /register] redirect after successful registration' );

# Test user login route
$res = $test->request( GET '/login' );
ok( $res->is_success, '[GET /login] successful' );

$res = $test->request(
    POST '/login' => [
        username => 'testuser',
        password => 'password',
    ]
);
ok( $res->is_redirect, '[POST /login] redirect after successful login' );
