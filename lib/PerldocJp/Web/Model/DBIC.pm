# Note: This is NOT Catalyst::Model::DBIC::Schema!

package PerldocJp::Web::Model::DBIC;
use Moose;
use PerldocJp::Schema;
use namespace::autoclean;

extends 'Catalyst::Model';

has connect_info => (
    is => 'ro',
    isa => 'ArrayRef',
    required => 1,
);

around COMPONENT => sub {
    my ($next, $class, @args) = @_;
    my $self = $next->($class, @args);
    return $self;
};

sub ACCEPT_CONTEXT {
    my $self = shift;

    if (PerldocJp::Schema->storage) {
        # return cached connection
        return "PerldocJp::Schema";
    } else {
        return PerldocJp::Schema->connection( @{ $self->connect_info } );
    }
}

__PACKAGE__->meta->make_immutable();

1;
