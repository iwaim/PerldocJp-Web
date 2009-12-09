#!/opt/local/bin/perl
BEGIN {
    if (-d '.git') {
        unshift @INC, 'lib';
    }
}
use App::PerldocJp::UpdateSources;
App::PerldocJp::UpdateSources->new_with_options->run();