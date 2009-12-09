#!/opt/local/bin/perl
BEGIN {
    if (-d '.git') {
        unshift @INC, 'lib';
    }
}
use App::PerldocJp::UpdateMetadata;
App::PerldocJp::UpdateMetadata->new_with_options->run();