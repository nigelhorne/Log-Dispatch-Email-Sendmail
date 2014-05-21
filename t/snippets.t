#!perl -w

use strict;
use warnings;
use File::Spec;
use Test::More;

if(not $ENV{RELEASE_TESTING}) {
	plan(skip_all => 'Author tests not required for installation');
}

eval "use Test::Pod::Snippets";

if($@) {
	plan skip_all => 'Test::Pod::Snippets required for testing POD code snippets';
} else {
	my $tps = Test::Pod::Snippets->new;

	my @modules = qw/ Log::Dispatch::Email::Sendmail /;

	$tps->runtest( module => $_, testgroup => 1 ) for @modules;
}
