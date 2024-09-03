use strict;
use warnings;

use Example;
use Test::More tests => 4;
use Plack::Test;
use HTTP::Request::Common;
use Ref::Util qw<is_coderef>;

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
