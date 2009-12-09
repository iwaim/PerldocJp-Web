package PerldocJp::Web::Controller::Dist;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

sub load
    :Chained('/author/load')
    :PathPart('')
    :CaptureArgs(1)
{
    my ($self, $c, $dist_name) = @_;

    if( $dist_name !~ s/-([^-]+)$//) {
        $c->forward('/default');
        $c->finalize;
        return;
    }
    my $version = $1;

    my $dist = $c->model('AvailableDist')->find_for_version(
        {
            dist => $dist_name,
            version => $version,
        },
    );

    if (! $dist) {
        $c->forward('/default');
        $c->finalize;
        return;
    }

    $c->stash(
        dist_name => $dist_name,
        dist => $dist,
        version => $version,
    );
}

sub index
    :Chained('/dist/load')
    :PathPart('')
    :Args(0)
{
    my ($self, $c) = @_;

    my $dist_name = $c->stash->{dist_name};
    my $version   = $c->stash->{version};
    return unless $dist_name && $version;

    my @pods = $c->model('AvailablePod')->find_for_dist(
        {
            dist => $dist_name,
            version => $version,
        }
    );

    $c->stash( pods => \@pods );
}

sub pod
    :Chained('/dist/load')
    :PathPart('')
    :Args(1)
{
    my ($self, $c, $module) = @_;
    my $dist_name = $c->stash->{dist_name};
    my $version   = $c->stash->{version};
    my $pod = $c->model('AvailablePod')->find_for_module(
        {
            dist => $dist_name,
            version => $version,
            module => $module,
        }
    );
    if (! $pod) {
        $c->forward('/default');
        $c->finalize;
        return;
    }

    # Ideally, we should be caching this rendered result
    $c->stash( pod => $c->view('Pod')->render($pod->pod) );
    
}

__PACKAGE__->meta->make_immutable();

1;