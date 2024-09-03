use strict;
use warnings;

use Test::More tests => 3;
use YAML::XS qw(LoadFile);

# Test loading of config.yml
my $config = LoadFile('Example/config.yml');
ok($config, 'Loaded config.yml');
is($config->{appname}, 'Example', 'App name is correct');

# Test loading of environment-specific configuration files
my $dev_config = LoadFile('Example/environments/development.yml');
ok($dev_config, 'Loaded development.yml');
is($dev_config->{logger}, 'console', 'Logger is correct for development environment');

my $prod_config = LoadFile('Example/environments/production.yml');
ok($prod_config, 'Loaded production.yml');
is($prod_config->{log}, 'warning', 'Log level is correct for production environment');
