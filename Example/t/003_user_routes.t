use strict;
use warnings;

use Example;
use Example::Util::SchemaLoader;
use Test::More;
use Plack::Test;
use HTTP::Request::Common;
use Ref::Util qw<is_coderef>;

Example::Util::SchemaLoader::load_schema();

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

# Test edge cases and error handling in user registration route
$res = $test->request(
    POST '/register' => [
        username         => 'testuser2',
        password         => 'password',
        confirm_password => 'differentpassword',
        email            => 'testuser2@example.com',
    ]
);
ok( $res->is_success, '[POST /register] successful with password mismatch' );
like( $res->content, qr/Passwords do not match/, 'Password mismatch error message' );

$res = $test->request(
    POST '/register' => [
        username         => 'testuser',
        password         => 'password',
        confirm_password => 'password',
        email            => 'testuser@example.com',
    ]
);
ok( $res->is_success, '[POST /register] successful with duplicate username' );
like( $res->content, qr/Failed to register user/, 'Duplicate username error message' );

# Test edge cases and error handling in user login route
$res = $test->request(
    POST '/login' => [
        username => 'nonexistentuser',
        password => 'password',
    ]
);
ok( $res->is_success, '[POST /login] successful with nonexistent user' );
like( $res->content, qr/Invalid username or password/, 'Nonexistent user error message' );

$res = $test->request(
    POST '/login' => [
        username => 'testuser',
        password => 'wrongpassword',
    ]
);
ok( $res->is_success, '[POST /login] successful with wrong password' );
like( $res->content, qr/Invalid username or password/, 'Wrong password error message' );

# Test logout route
$res = $test->request( GET '/logout' );
ok( $res->is_redirect, '[GET /logout] redirect after logout' );

done_testing();
