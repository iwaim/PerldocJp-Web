#!/usr/bin/env perl
use inc::Module::Install;

name 'PerldocJp-Web';
all_from 'lib/PerldocJp/Web.pm';

requires 'Catalyst::Runtime' => '5.80015';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Action::RenderView';
requires 'Catalyst::View::TT';
requires 'DBIx::Class';
requires 'File::Find::Rule';
requires 'Guard'; # XXX Replace with Scope::Guard if the dep is a problem
requires 'Moose';
requires 'MooseX::Types::Path::Class';
requires 'Pod::Xhtml';
requires 'namespace::autoclean';
requires 'YAML::XS';

test_requires 'Test::More' => '0.88';
catalyst;

readme_from 'lib/PerldocJp/Web.pm';
install_script glob('script/*.pl');
auto_install;
WriteAll;
