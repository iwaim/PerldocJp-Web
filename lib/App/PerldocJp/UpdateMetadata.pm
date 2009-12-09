# XXX This is currently a hackish piece of shit.
package App::PerldocJp::UpdateMetadata;
use Moose;
use File::Find::Rule;
use MooseX::Types::Path::Class;
use PerldocJp::Schema;
use namespace::autoclean;

with 'MooseX::Getopt';
with 'MooseX::SimpleConfig';
with 'PerldocJp::Trait::WithDBIC';

has connect_info => (
    is => 'ro',
    isa => 'ArrayRef',
    required => 1,
);

has pod_dir => (
    is => 'ro',
    isa => 'Path::Class::Dir',
    coerce => 1,
    required => 1,
);

has '+schema' => (
    traits => ['NoGetopt'],
);

around _build_schema => sub {
    my ($next, $self, @args) = @_;
    return PerldocJp::Schema->connection( @{ $self->connect_info } );
};

sub run {
    my $self = shift;
    $self->update_translated_pod_list;
}

sub update_translated_pod_list {
    my $self = shift;
    my $pod_dir = $self->pod_dir;

    if (! -d $pod_dir) {
        die "POD source directory $pod_dir does not exist!";
    }

    my $parser = App::PerldocJp::UpdateMetadata::PodParser->new();
    my $find_pods = File::Find::Rule->file()->name('*.pod');

    my $guard = $self->txn_guard();
    my $pod_rs = $self->resultset('AvailablePod');
    my $package_rs = $self->resultset('PackageDetails');

    my %dists;
    while ( my $dist = $pod_dir->next ) {
        next unless $dist->is_dir;
        next unless ($dist->dir_list(-1,1)) =~ /^(.+)-([\d\._]+)$/;

        my ($dist_name, $version) = ($1, $2);

        my @pods = $find_pods->in( $dist );

        foreach my $pod (@pods) {
            $parser->reset();
            local $parser->{pod} = $pod;
            eval {
                $parser->parse_from_file($pod);
            };
            if ($@) {
                warn "Failed to parse $pod";
                next;
            }

            if (! $parser->name) {
                warn "failed to retrieve for $pod";
            } else {
                # if the module in question is not on CPAN, we probably
                # shouldn't be indexiing it?
                my $module = $package_rs->search( { dist => $dist_name }, { rows => 1} )->single;
                if (! $module) {
                    warn "$dist_name does not exist on our list...";
                    next;
                }

                # register to available distributions later
                $dists{ join('|', $module->dist, $version) } ||= [ $module->author_id, $module->dist_version ];

                # register available module
                # id is dist|module|version
                $pod_rs->update_or_create(
                    {
                        id => join('|', $module->dist, $parser->name, $version),
                        author_id => $module->author_id,
                        dist => $module->dist,
                        module => $parser->name,
                        pod => $pod,
                        dist_version => $version,
                    }
                );
            }
        }
    }

    my $dist_rs = $self->resultset('AvailableDist');
    while (my ($id, $data) = each %dists) {
        my ($dist, $version) = split(qr/\|/, $id);
        $dist_rs->update_or_create(
            {
                id   => $id,
                name => $dist,
                version => $version,
                author_id => $data->[0],
                latest_version => $data->[1],
            }
        )
    }

    $guard->commit;
}

__PACKAGE__->meta->make_immutable();

package 
    App::PerldocJp::UpdateMetadata::PodParser;
use utf8;
use Moose;
use Moose::Util::TypeConstraints;
use Encode;
use namespace::autoclean;

extends 'Pod::Parser';

has encoding => (
    is => 'rw',
    isa => 'Str',
    default => 'euc-jp',
    clearer => 'clear_encoding'
);

subtype ClassNameString
    => as 'Str'
    => where {
        /^\D/ &&
        /^[a-zA-Z_:]+$/
    }
;

has name => (
    is => 'rw',
    isa => 'ClassNameString',
    clearer => 'clear_name'
);

sub reset {
    my $self = shift;
    $self->encoding('euc-jp');
    $self->clear_name;
}

sub command {
    my ($self, $command, $para) = @_;

    # if we have multiple lines, just use the first one
    if ($para =~ /\n/) {
        ($para) = split /\n/, $para;
    }
    $para = decode($self->encoding, $para);
    if ($para eq 'NAME' || $para eq '名前') {
        $self->{in_name} = 1;
    } elsif ($command eq 'encoding') {
        $self->encoding( $para );
    }
}

sub textblock {
    my ($self, $para) = @_;
    $para = decode($self->encoding, $para);
    if ($self->{in_name}) {
        # if we have multiple lines, just use the first one
        if ($para =~ /\n/) {
            ($para) = split /\n/, $para;
        }

        $para =~ s/\s+$//;
        $para =~ s/\s*-+\s*.*$//sm;
        $self->name( $para );
        delete $self->{in_name};
    }
}

sub verbatim { }

1;
