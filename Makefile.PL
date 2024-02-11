use strict;
use warnings;
use ExtUtils::MakeMaker 6.64;	# 6.64 for TEST_REQUIRES

my @needfull;	# https://github.com/nigelhorne/Log-Dispatch-Email-Sendmail/issues/82

# Install Pre-requisites
BEGIN {
	# if($ENV{'AUTOMATED_TESTING'}) {
		# # TODO: I suppose it would be better to return "UNKNOWN" on
		# #	platforms without Devel::CheckBin
		# #	Note this is also disabled in GitHub Actions
		# print STDERR "NA: Automatic testing disabled until I can work out how to tell smokers to install Devel::CheckBin\n";
		# exit(0);
	# }

	# require Devel::CheckBin;
	# Devel::CheckBin->import();
	my @modules = (
		'Devel::CheckBin'
	);
	foreach my $module(@modules) {
		eval "use $module";
		if($@) {
			# Install module dependancies
			if($module =~ /(.+)\s/) {
				# Specific version not satisfied
				push @needfull, $1;
			} else {
				push @needfull, $module;
			}
		}
	}
	if(scalar(@needfull)) {
		my $list = join(' ', @needfull);
		print "Installing $list\n";
		$ENV{'PERL_MM_USE_DEFAULT'} = 1;
		# system("cpan -i $list");
		system('perl -MCPAN -e \'CPAN::Shell->install("' . join('", "', @needfull) . '")\'');
	}
}

foreach my $module(@needfull) {
	my $version;
	if($module =~ /(.+)\s(.+)$/) {
		$module = $1;
		$version = $2;
	}
	if($module =~ /.+\/(.+)/) {
		$module = $1;
	}
	$module =~ s/\-/::/g;
	$module =~ s/\.tar\.gz$//;
	eval "require $module";
	if($@) {
		die $@;
	}
	$module->import();
	# if($version && ($module::VERSION < $version)) {
		# die "$module: need $version got ", $module::VERSION;
	# }
}

# Allow me (and CI tools) to test on systems without sendmail
unless(defined($ENV{'AUTHOR_TESTING'})) {
	# check_bin('/usr/sbin/sendmail');
	can_run('/usr/sbin/sendmail');
	# unless((-f '/usr/sbin/sendmail') && (-x '/usr/sbin/sendmail')) {
		# print STDERR "NA: sendmail not installed\n";
		# exit(0);
	# }
}

WriteMakefile(
    NAME                => 'Log::Dispatch::Email::Sendmail',
    AUTHOR              => q{Nigel Horne <njh@bandsman.co.uk>},
    VERSION_FROM        => 'lib/Log/Dispatch/Email/Sendmail.pm',
    ABSTRACT_FROM        => 'lib/Log/Dispatch/Email/Sendmail.pm',
    ((defined($ExtUtils::MakeMaker::VERSION) &&
     ($ExtUtils::MakeMaker::VERSION >= 6.3002))
      ? ('LICENSE'=> 'GPL')
      : ()),
    PL_FILES            => {},
    BUILD_REQUIRES => {
    	'Devel::CheckBin' => 0,
    }, PREREQ_PM => {
	'Log::Dispatch' => 0,
	'Sys::Hostname' => 0,
    }, TEST_REQUIRES => {
	'Test::Most' => 0,
	'Test::Needs' => 0,
	'Test::NoWarnings' => 0,
	'Test::Requires' => 0
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Log-Dispatch-Email-Sendmail-*' },
    META_MERGE => {	# https://perldoc.perl.org/CPAN::Meta::Spec
    	'meta-spec' => { version => 2 },
    	resources => {
    		repository => {
			type => 'git',
			url => 'git://github.com/nigelhorne/Log-Dispatch-Email-Sendmail.git',
			web => 'https://github.com/nigelhorne/Log-Dispatch-Email-Sendmail',
			repisitory => 'https://github.com/nigelhorne/Log-Dispatch-Email-Sendmail',
    		}, bugtracker => {
			# web => 'https://rt.cpan.org/Public/Dist/Display.html?Name=Log-Dispatch-Email-Sendmail',
			web => 'https://github.com/nigelhorne/Log-Dispatch-Email-Sendmail/issues',
			url => 'https://github.com/nigelhorne/Log-Dispatch-Email-Sendmail/issues',
			mailto => 'bug-Log-Dispatch-Email-Sendmail@rt.cpan.org'
		}
	},
    },
    MIN_PERL_VERSION	=> '5.6.2'	# Probably would work, but never tested on earlier versions than this
);
