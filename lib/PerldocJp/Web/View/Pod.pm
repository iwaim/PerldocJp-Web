package PerldocJp::Web::View::Pod;
use Moose;
use Pod::Xhtml;
use namespace::autoclean;

extends 'Catalyst::View';

has parser => (
    is => 'ro',
    isa => 'Pod::Xhtml',
    lazy_build => 1,
);

sub _build_parser {
    return Pod::Xhtml->new(MakeIndex => 0, MakeMeta => 0);
}

override process => sub {
    my ($self, $c) = @_;

    $c->res->content_type('text/html');
    $c->res->body( $self->render( $c->stash->{template} ) );
};

sub render {
    my ($self, $pod_file) = @_;

    my $parser = $self->parser;

    my $html;
    open(my $source, '<', $pod_file) or
        confess "Could not open $pod_file: $!";
    open(my $output, '>', \$html) or
        confess "Could not open in-memory IO buffer: $!";
    $parser->parse_from_file( $source, $output );

    # XXX This sucks.
    $html =~ s/\A.+(?=<div class="pod">)//sm;
    $html =~ s/<\/body>.+$//sm;

    return $html;
}

__PACKAGE__->meta->make_immutable();

1;
