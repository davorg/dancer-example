package Example::Util::SchemaLoader;

use strict;
use warnings;
use DBI;
use YAML::XS qw(LoadFile);
use Log::Any qw($log);

sub load_schema {
    $log->info("Loading schema...");

    my $config = LoadFile('Example/config.yml');
    my $dbh = DBI->connect(
        $config->{database}->{dsn},
        $config->{database}->{username},
        $config->{database}->{password},
        {
            RaiseError => 1,
            PrintError => 0,
            AutoCommit => 1,
        }
    );

    open my $fh, '<', 'Example/db/schema.sql' or do {
        $log->error("Could not open schema file: $!");
        die "Could not open schema file: $!";
    };
    my $schema_sql = do { local $/; <$fh> };
    close $fh;

    my @statements = split /;\s*/, $schema_sql;

    for my $statement (@statements) {
        next unless $statement =~ /\S/;
        $log->info("Executing SQL statement: $statement");
        eval {
            $dbh->do($statement);
        };
        if ($@) {
            $log->error("Error executing SQL statement: $@");
            die "Error executing SQL statement: $@";
        }
    }

    $dbh->disconnect;
    $log->info("Schema loaded successfully.");
}

1;
