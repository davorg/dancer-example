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

# Test rendering of index template
my $res = $test->request( GET '/' );
ok( $res->is_success, '[GET /] successful' );
like( $res->content, qr/Welcome to the Example Application/, 'Index template rendered' );

# Test rendering of login template
$res = $test->request( GET '/login' );
ok( $res->is_success, '[GET /login] successful' );
like( $res->content, qr/Login/, 'Login template rendered' );

# Test rendering of register template
$res = $test->request( GET '/register' );
ok( $res->is_success, '[GET /register] successful' );
like( $res->content, qr/Register/, 'Register template rendered' );

done_testing();
