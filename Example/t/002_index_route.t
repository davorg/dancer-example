use strict;
use warnings;

use Example;
use Test::More tests => 2;
use Plack::Test;
use HTTP::Request::Common;
use Ref::Util qw<is_coderef>;

my $app = Example->to_app;
ok( is_coderef($app), 'Got app' );

my $test = Plack::Test->create($app);
my $res  = $test->request( GET '/' );

ok( $res->is_success, '[GET /] successful' );
