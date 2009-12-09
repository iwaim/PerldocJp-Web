package PerldocJp::Web::Controller::Author;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

sub load
    :Chained
    :PathPart('author')
    :CaptureArgs(1)
{
    my ($self, $c, $author_id) = @_;

=head1
    if (! $c->model('Author')->find( $author_id ) ) {
        $c->forward('/default');
        return;
    }
=cut

    $c->stash(
        author_id => $author_id
    );
}

sub all_dists_by_author
    :Chained('/author/load')
    :PathPart('')
    :Args(0)
{
    my ($self, $c) = @_;

    my $author_id = $c->stash->{author_id};
    my $dists = $c->model('AvailableDist')->all_dists_by_author(
        {
            author_id => uc $author_id
        }
    );

    $c->stash(
        dists => $dists,
    );
}

__PACKAGE__->meta->make_immutable();

1;