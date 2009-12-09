package PerldocJp::API::AvailableDist;
use Moose;
use namespace::autoclean;

with 'PerldocJp::Trait::WithDBIC';

sub all_dists_by_author {
    my ($self, $args) = @_;

    my $author_id = $args->{author_id} or
        confess "no author_id provide for all_dists_by_author";
    my @all = $self->resultset('AvailableDist')->search(
        {
            author_id => $author_id,
        }
    );
    return wantarray ? @all : \@all;
}

sub find_for_version {
    my ($self, $args) = @_;

    my $dist_name = $args->{dist} or confess "no dist provided for find_for_version";
    my $version = $args->{version} or confess "no version provided for find_for_version";
    my $dist = $self->resultset('AvailableDist')->search(
        {
            name => $dist_name,
            version => $version
        },
        {
            rows => 1,
        }
    )->single;

    return $dist;
}

__PACKAGE__->meta->make_immutable();

1;

