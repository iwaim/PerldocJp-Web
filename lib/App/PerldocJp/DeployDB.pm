package App::PerldocJp::DeployDB;
use Moose;
use PerldocJp::Schema;
use namespace::autoclean;

with 'MooseX::Getopt';
with 'MooseX::SimpleConfig';
with 'PerldocJp::Trait::WithDBIC';

has connect_info => (
    is => 'ro',
    isa => 'ArrayRef',
    required => 1,
);

has drop_table => (
    is => 'ro',
    isa => 'Bool',
    default => 0
);

sub run {
    my $self = shift;

    my $schema = PerldocJp::Schema->connection( @{ $self->connect_info } );

    my $guard = $schema->txn_scope_guard();
    $schema->deploy(
        {
            add_drop_table => $self->drop_table,
            quote_field_names => 0,
        }
    );
    $guard->commit;
}

__PACKAGE__->meta->make_immutable();

1;