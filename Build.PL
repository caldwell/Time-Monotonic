use 5.008;
use strict;
use warnings FATAL => 'all';
use Module::Build;
use Config;

if (-d ".git") { # Are we in our development tree? If so, create MANIFEST.
    my ($dir, $manifest);
    open $manifest, ">", "MANIFEST" or die "MANIFEST: $!";
    print $manifest "MANIFEST\n";
    open $dir, 'git ls-files|' or die "Couldn't run git: $!";
    while (<$dir>) { print $manifest $_ unless /^\.|^monotonic_clock/ }
    open $dir, '-|', 'cd monotonic_clock && git ls-files' or die "Couldn't run git in monotonic_clock: $!";
    while (<$dir>) { print $manifest "monotonic_clock/$_" unless /^\./ }
}

# This hacks around the fact that we are using c_source to store files, when Module::Build expects directories.
my $custom = Module::Build->subclass(
    class => 'My::Builder',
    code  => <<'CUSTOM_CODE');
sub compile_c {
  my ($self, $file, %args) = @_;
  # Adding to c_source adds to include_dirs, too. Since we're adding files, remove them.
  @{$self->include_dirs} = grep { !/\.c$/ } @{$self->include_dirs};
  $self->SUPER::compile_c($file, %args);
}
CUSTOM_CODE

my $builder = $custom->new(
    module_name         => 'Time::Monotonic',
    license             => 'perl',
    dist_author         => 'David Caldwell <david@porkrind.org>',
    dist_version_from   => 'lib/Time/Monotonic.pm',
    release_status      => 'stable',
    configure_requires => {
        'Module::Build' => 0.3604,
    },
    build_requires => {
        'Test::More' => 0,
    },
    meta_merge => {
      resources => {
        repository  => 'https://github.com/caldwell/Time-Monotonic',
      },
    },
    extra_compiler_flags => '-DHAVE_GETTIMEOFDAY', # We're going to assume everyone is at least that modern
    include_dirs => 'monotonic_clock/include',
    c_source     => ['monotonic_clock/src/monotonic_common.c'],
);

# Add the appropriate platform-specific backend.
#
# This isn't as good as the configure script that comes with
# monotonic_clock, since it actually tests for the feature instead of
# assuming that non-darwin unixes support POSIX clock_gettime. On the other
# hand, this handles windows.
push(@{$builder->c_source},
     $^O                 eq 'darwin'  ? 'monotonic_clock/src/monotonic_mach.c' :
     $builder->os_type() eq 'Windows' ? 'monotonic_clock/src/monotonic_win32.c' :
     $builder->os_type() eq 'Unix'    ? 'monotonic_clock/src/monotonic_clock.c' :
                                        'monotonic_clock/src/monotonic_generic.c');

$builder->create_build_script();
