#!/opt/local/bin/perl
BEGIN {
    if (-d '.git') {
        unshift @INC, 'lib';
    }
}
use App::PerldocJp::DeployDB;
App::PerldocJp::DeployDB->new_with_options->run();