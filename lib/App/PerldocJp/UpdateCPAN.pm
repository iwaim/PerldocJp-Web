# Download CPAN module information and update our "master" data

package App::PerldocJp::UpdateCPAN;
use utf8;
use Moose;
use Encode;
use File::Basename qw(basename);
use File::Find::Rule;
use PerldocJp::Schema;
use MooseX::Types::Path::Class;
use namespace::autoclean;

with 'MooseX::Getopt';
with 'MooseX::SimpleConfig';
with 'PerldocJp::Trait::WithDBIC';

has connect_info => (
    is => 'ro',
    isa => 'ArrayRef',
    required => 1,
);

has package_details => (
    is => 'ro',
    isa => 'Str',
    required => 1,
    lazy_build => 1,
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
    my $schema = $self->schema;
    my $package_details = $self->package_details;
    open(my $fh, '<', $package_details)
        or confess "Could not open $package_details: $!";

    my $guard = $schema->txn_scope_guard();

    my $find_pods = File::Find::Rule->file()->name('*.pod');

    my $rs = $schema->resultset('PackageDetails');
    my $start = 0;
    while ( <$fh> ) {
        if (/^$/) {
            $start++;
            next;
        }
        next unless $start;

        chomp;
        my ($module, $version, $path) = split /\s+/;

        if ($version eq 'undef') {
            $version = undef;
        }
            
        # Check if we have a module of the same name in our translated
        # POD directory
        my $dist = basename($path);
        $dist =~ s/-([\d\._]+)\.tar\.gz$//;
        my $dist_version = $1;

        my $author_id = (split(/\//, $path))[-2];
        
        $rs->update_or_create(
            {
                module  => $module,
                dist    => $dist,
                version => $version,
                dist_version => $dist_version,
                path    => $path,
                author_id => $author_id,
            },
            { key => 'is_unique_module' },
        );
    }

    $guard->commit;
}

sub _build_package_details {
    my $self = shift;

    require CPAN;
    require File::Spec;
    require File::Temp;
    require LWP::UserAgent;
    # fetch the latest 02packages.details.txt file
    CPAN::HandleConfig->load unless $CPAN::Config_loaded++;

    my $ua       = LWP::UserAgent->new();
    my $temp_dir = File::Temp::tempdir( CLEANUP => 1, TEMPDIR => 1 );
    my $local    = File::Spec->catfile($temp_dir, '02packages.details.txt');
    foreach my $host (@{ $CPAN::Config->{urllist} }) {
        $host =~ s/\/$//;
        my $remote = "$host/modules/02packages.details.txt";
        warn $remote;
        my $res    = $ua->mirror( $remote, $local );
        if ($res->is_success) {
            $self->{__tempdir} = $temp_dir;
            return $local;
        }
    }

    confess "Could not download 02packages.details.txt from any server";
}

1;
