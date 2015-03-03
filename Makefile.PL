use ExtUtils::MakeMaker;

if (-d ".git") { # Are we in our development tree? If so, create MANIFEST.
    my ($dir, $manifest);
    open $manifest, ">", "MANIFEST" or die "MANIFEST: $!";
    print $manifest "MANIFEST\n";
    open $dir, '-|', 'git', 'ls-files' or die "Couldn't run git: $!";
    while (<$dir>) { print $manifest $_ unless /^\.|^monotonic_clock/ }
    open $dir, '-|', 'cd monotonic_clock && git ls-files' or die "Couldn't run git in monotonic_clock: $!";
    while (<$dir>) { print $manifest "monotonic_clock/$_" unless /^\./ }
    # This junk is created by autoconf and is hard to compute since it's not in the repo
    print $manifest <<AUTOCONF;
monotonic_clock/Makefile.in
monotonic_clock/aclocal.m4
monotonic_clock/config.h.in
monotonic_clock/config/compile
monotonic_clock/config/config.guess
monotonic_clock/config/config.sub
monotonic_clock/config/depcomp
monotonic_clock/config/install-sh
monotonic_clock/config/ltmain.sh
monotonic_clock/config/missing
monotonic_clock/configure
monotonic_clock/m4/libtool.m4
monotonic_clock/m4/ltoptions.m4
monotonic_clock/m4/ltsugar.m4
monotonic_clock/m4/ltversion.m4
monotonic_clock/m4/lt~obsolete.m4
AUTOCONF
}

WriteMakefile(
    NAME              => 'Time::Monotonic',
    VERSION_FROM      => 'lib/Time/Monotonic.pm',
    AUTHOR            => 'David Caldwell <david@porkrind.org',
    ABSTRACT_FROM     => 'lib/Time/Monotonic.pm',
    LICENSE           => 'perl',
    TEST_REQUIRES     => {
        'Test::More' => 0,
    },
    META_MERGE        => {
        resources => {
            repository => 'https://github.com/caldwell/Time-Monotonic'
        }
    },

    INC               => '-I./monotonic_clock/include',
    MYEXTLIB          => 'monotonic_clock/.libs/libmonotonic_clock.a'
);

sub MY::postamble {
'
$(MYEXTLIB): monotonic_clock/configure Makefile.PL
	cd monotonic_clock && CFLAGS="$(CCFLAGS) -fPIC" ./configure && $(MAKE) all

monotonic_clock/configure: monotonic_clock/configure.ac
	cd monotonic_clock && ./bootstrap.sh

create_distdir: monotonic_clock/configure
'
}
