package Example::Schema::Result::User;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components('InflateColumn::DateTime', 'TimeStamp', 'EncodedColumn');
__PACKAGE__->table('users');
__PACKAGE__->add_columns(
    'id' => {
        data_type => 'integer',
        is_auto_increment => 1,
    },
    'username' => {
        data_type => 'text',
        is_nullable => 0,
    },
    'password' => {
        data_type => 'text',
        is_nullable => 0,
    },
    'email' => {
        data_type => 'text',
        is_nullable => 0,
    },
);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint(['username']);
__PACKAGE__->add_unique_constraint(['email']);

1;
