package PerldocJp::Web;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;
use Catalyst qw/
	-Debug
    ConfigLoader
    Static::Simple
/;

extends 'Catalyst';

our $VERSION = '0.01';
$VERSION = eval $VERSION;

__PACKAGE__->config(
	name => 'PerldocJp::Web',
	disable_component_resolution_regex_fallback => 1, 
);

__PACKAGE__->setup();


=head1 NAME

PerldocJp::Web - Japanese Perldoc Site

=head1 SYNOPSIS

    script/perldocjp_web_server.pl

    # do the following first:
    #
    # (1) Deploy the database (currently only MySQL is supported)
    #     ./script/perldocjp_deploydb.pl \
    #           --connect_info=dbi:mysql:dname=perldocjp \
    #           --connect_info=username \
    #           --connect_info=password
    #
    # (2) Get the documents available from perldocjp project
    #     (this will decode the document to UTF-8 as necessary)
    #     ./script/perldocjp_update_sources.pl \
    #           --destination=/path/to/perldocjp
    #
    # (3) Get the current CPAN metadata information
    #     ./script/perldocjp_update_cpan.pl \
    #           --connect_info=dbi:mysql:dname=perldocjp \
    #           --connect_info=username \
    #           --connect_info=password
    #
    # (4) Apply the source information from perldocjp and combine with
    #     the CPAN metadata
    #     ./script/perldocjp_update_metadata.pl \
    #           --pod_dir=/path/to/perldocjp/docs/modules/
    #           --connect_info=dbi:mysql:dname=perldocjp \
    #           --connect_info=username \
    #           --connect_info=password
    #
    # you're all set. run the web server as usual


=head1 AUTHOR

Daisuke Maki C< <<daisuke@endeworks.jp>> >

=cut

1;