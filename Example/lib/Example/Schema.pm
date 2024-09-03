package Example::Schema;

use base qw/DBIx::Class::Schema/;

__PACKAGE__->load_namespaces;

sub connect_db {
    my $self = shift;
    my $config = shift;

    return $self->connect(
        $config->{database}->{dsn},
        $config->{database}->{username},
        $config->{database}->{password},
        { RaiseError => 1, PrintError => 0, AutoCommit => 1 }
    );
}

sub get_schema {
    my ($class, $config) = @_;
    return $class->connect_db($config);
}

1;
