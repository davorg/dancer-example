use strict;
use warnings;

use Example;
use Test::More;
use Plack::Test;
use HTTP::Request::Common;
use Ref::Util qw<is_coderef>;

my $app = Example->to_app;
ok( is_coderef($app), 'Got app' );

my $test = Plack::Test->create($app);

# Test session creation
my $res = $test->request(
    POST '/login' => [
        username => 'testuser',
        password => 'password',
    ]
);
ok( $res->is_redirect, '[POST /login] redirect after successful login' );

# Test session retrieval
$res = $test->request( GET '/' );
ok( $res->is_success, '[GET /] successful' );
like( $res->content, qr/testuser/, 'Session user retrieved' );

# Test session destruction
$res = $test->request( GET '/logout' );
ok( $res->is_redirect, '[GET /logout] redirect after logout' );

$res = $test->request( GET '/' );
ok( $res->is_success, '[GET /] successful' );
unlike( $res->content, qr/testuser/, 'Session user destroyed' );

done_testing();
