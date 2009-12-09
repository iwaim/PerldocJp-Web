package PerldocJp::Trait::WithDBIC;
use Moose::Role;
use namespace::autoclean;

has schema => (
    is => 'ro',
    isa => 'Str',
    required => 1,
    lazy_build => 1,
);

sub _build_schema { }
sub txn_guard { shift->schema->txn_scope_guard }
sub resultset { shift->schema->resultset(@_) }

1;
