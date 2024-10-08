use strict;
use warnings;

use Example;
use Example::Util::SchemaLoader;
use Test::More;
use Plack::Test;
use HTTP::Request::Common;
use HTTP::Cookies;
use Ref::Util qw<is_coderef>;

Example::Util::SchemaLoader::load_schema();

# Add a test user to the database
my $schema = Example::Schema->connect('dbi:SQLite:dbname=Example/db/example.db');
$schema->resultset('User')->create({
    username => 'testuser',
    password => 'password',
    email    => 'testuser@example.com',
});

my $app = Example->to_app;
ok( is_coderef($app), 'Got app' );

my $url  = 'http://localhost';
my $test = Plack::Test->create($app);
my $jar = HTTP::Cookies->new;

# Test session creation
my $res = $test->request(
    POST "$url/login" => [
        username => 'testuser',
        password => 'password',
    ]
);
ok( $res->is_redirect, '[POST /login] redirect after successful login' );
$jar->extract_cookies($res);

# Test session retrieval
my $req = GET "$url/";
$jar->add_cookie_header($req);
$res = $test->request($req);
ok( $res->is_success, '[GET /] successful' );
like( $res->content, qr/testuser/, 'Session user retrieved' );

# Test session destruction
$res = $test->request( GET '/logout' );
ok( $res->is_redirect, '[GET /logout] redirect after logout' );

$res = $test->request( GET '/' );
ok( $res->is_success, '[GET /] successful' );
unlike( $res->content, qr/testuser/, 'Session user destroyed' );

done_testing();
