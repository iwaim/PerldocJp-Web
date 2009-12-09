package PerldocJp::Schema::Result::AvailablePod;
use strict;
use base qw(PerldocJp::Schema::Result);

__PACKAGE__->load_components( qw(Core) );
__PACKAGE__->table('perldocjp_available_pod');
__PACKAGE__->add_columns(
    id => { # the ID is the path 
        data_type => 'TEXT',
        is_nullable => 0,
    },
    author_id => {
        data_type => 'CHAR',
        is_nullable => 0,
        size => 32,
    },
    dist => {
        data_type => 'TEXT',
        is_nullable => 0,
    },
    module => {
        data_type => 'TEXT',
        is_nullable => 0,
    },
    pod => {
        data_type => 'TEXT',
        is_nullable => 0,
    },
    dist_version => {
        data_type => 'CHAR',
        size => 32,
        is_nullable => 0,
    },
);
__PACKAGE__->set_primary_key('id');

sub sqlt_deploy_hook {
    my ($self, $sqlt_table) = @_;

    my ($pk) = grep { $_->type eq 'PRIMARY KEY' } $sqlt_table->get_constraints();
    $pk->fields([ 'id(255)' ]);

    $sqlt_table->add_index(
        name => $self->table . '_author_id_idx',
        fields => [ 'author_id' ]
    );
    $sqlt_table->add_index(
        name => $self->table . '_get_for_dist_idx',
        fields => [ 'module(255)', 'dist_version' ]
    );
        

    $self->next::method($sqlt_table);
}

1;