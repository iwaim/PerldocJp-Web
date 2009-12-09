#!/usr/bin/env perl
BEGIN {
    if (-d '.git') {
        unshift @INC, 'lib';
    }
}
use App::PerldocJp::UpdateCPAN;
App::PerldocJp::UpdateCPAN->new_with_options->run();