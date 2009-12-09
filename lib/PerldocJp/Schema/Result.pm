package PerldocJp::Schema::Result;
use strict;
use base qw(DBIx::Class);

__PACKAGE__->mk_classdata('engine' => 'InnoDB');
__PACKAGE__->mk_classdata('charset' => 'UTF8');

our $UUID_GENERATOR ;

sub uuid {
    my $self = shift;

    if (! $UUID_GENERATOR ) {
        $UUID_GENERATOR = Data::UUID->new();
    }
    return $UUID_GENERATOR->create_str()
}

sub sqlt_deploy_hook {
    my ($self, $sqlt_table) = @_;

    # XXX if mysql?
    $sqlt_table->extra->{mysql_table_type} = $self->engine;
    $sqlt_table->extra->{mysql_charset}    = $self->charset;
    return ();
};

1;
