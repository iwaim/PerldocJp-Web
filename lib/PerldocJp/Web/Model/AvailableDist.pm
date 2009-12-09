package PerldocJp::Web::Model::AvailableDist;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Model';

has backend => (
    is => 'rw',
    isa => 'Object',
);

sub build_backend {
    my ($self, $c) = @_;
    Class::MOP::load_class("PerldocJp::API::AvailableDist");
    my $backend = PerldocJp::API::AvailableDist->new( schema => $c->model('DBIC') );
    $self->backend($backend);
    return $backend;
}

sub ACCEPT_CONTEXT {
    my ($self, $c) = @_;
    return $self->backend || $self->build_backend($c);
}

__PACKAGE__->meta->make_immutable();

1;