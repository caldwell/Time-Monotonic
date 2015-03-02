use ExtUtils::MakeMaker;

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
$(MYEXTLIB): monotonic_clock/configure
	cd monotonic_clock && CFLAGS="$(CCFLAGS)" ./configure && $(MAKE) all

monotonic_clock/configure: monotonic_clock/configure.ac
	cd monotonic_clock && ./bootstrap.sh
'
}
