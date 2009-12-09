package PerldocJp::Schema::Result::AvailableDist;
use strict;
use base qw(PerldocJp::Schema::Result);

__PACKAGE__->load_components( qw(Core) );
__PACKAGE__->table('perldocjp_available_dist');
__PACKAGE__->add_columns(
    id => {
        data_type => 'TEXT',
        is_nullable => 0,
    },
    name => {
        data_type => 'TEXT',
        is_nullable => 0,
    },
    path => { # the ID is the path 
        data_type => 'TEXT',
        is_nullable => 0,
    },
    author_id => {
        data_type => 'CHAR',
        is_nullable => 0,
        size => 32,
    },
    version => {
        data_type => 'CHAR',
        size => 32,
        is_nullable => 0,
    },
    latest_version => {
        data_type => 'CHAR',
        size => 32,
        is_nullable => 0,
    },
);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint(is_unique_dist => [ 'name', 'version' ]);

sub sqlt_deploy_hook {
    my ($self, $sqlt_table) = @_;

    foreach my $constraint ($sqlt_table->get_constraints()) {
        if ($constraint->type eq 'PRIMARY KEY') {
            $constraint->fields([ 'id(255)' ]);
        } elsif ($constraint->name eq 'is_unique_dist') {
            $constraint->fields([ 'name(255)', 'version' ]);
        }
    }

    $self->next::method($sqlt_table);
}

1;

