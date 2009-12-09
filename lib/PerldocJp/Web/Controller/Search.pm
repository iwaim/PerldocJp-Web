package PerldocJp::Web::Controller::Search;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

has modes => (
    is => 'ro',
    isa => 'HashRef',
    lazy_build => 1,
);

sub _build_modes {
    return { map { ($_ => 1) } qw(all dist author module) };
}

sub search
    :Path('')
{
    my ($self, $c) = @_;

    my $req = $c->req;
    my $page = int($req->param('page'));
    if ($page <= 0) {
        $page = 1;
    }
    my $mode = $req->param('mode');
    if (!exists $self->modes->{ $mode }) {
        $mode = 'all';
    }
    my $query = $req->param('query');
    if (! $query) {
        $query = '';
    }

    my @pods = $c->model('AvailablePod')->search_for( 
        {
            mode  => $mode,
            query => $query,
            page  => $page,
        }
    );
    $c->stash(pods => \@pods);
}

__PACKAGE__->meta->make_immutable();

1;