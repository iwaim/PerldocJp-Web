package PerldocJp::API::AvailablePod;
use Moose;
use namespace::autoclean;

with 'PerldocJp::Trait::WithDBIC';

sub find_for_dist {
    my ($self, $args) = @_;

    my $dist = $args->{dist}
        or confess "no dist specified for find_for_dist";
    my $version = $args->{version}
        or confess "no version specified for find_for_dist";

    return $self->resultset('AvailablePod')->search( 
        {
            dist => $dist,
            dist_version => $version,
        },
        {
            order_by => 'module ASC',
        }
    );
}

sub find_for_module {
    my ($self, $args) = @_;

    my $dist = $args->{dist}
        or confess "no dist specified for find_for_module";
    my $version = $args->{version}
        or confess "no version specified for find_for_module";
    my $module = $args->{module}
        or confess "no module specified for find_for_module";

    return $self->resultset('AvailablePod')->search( 
        {
            dist => $dist,
            dist_version => $version,
            module => $module
        },
        {
            rows => 1,
        }
    )->single;
}

sub search_for {
    my ($self, $args) = @_;

    # currently ignoring "mode"

    my $query = $args->{query};
    my $page = $args->{page} || 1;
    my @ret;
    if ($query) {
        @ret = $self->resultset('AvailablePod')->search(
            {
                -or => [
                    dist => { REGEXP => $query },
                    module => { REGEXP => $query },
                ]
            },
            {
                page => $page,
                rows => 15,
                order_by => 'dist_version DESC, module ASC', # should change depending on mode
            }
        );
    }
    return wantarray ? @ret : \@ret;
}

__PACKAGE__->meta->make_immutable();

1;
