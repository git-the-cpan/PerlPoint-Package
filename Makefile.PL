
# Makefile.PL -- Makefile template for PerlPoint::Parser
#
# This file is part of the "PerlPoint::Package" module package.
# PerlPoint::Package is free software, you can redistribute it
# and/or modify it under the terms of the Artistic License.

# load module
use ExtUtils::MakeMaker;

# the package requires modern perl
require 5.00503;

my $version='0.39';

# write makefile
$ok=WriteMakefile(
                  NAME         => 'PerlPoint::Package',
                  ABSTRACT     => 'A framework to write PerlPoint converters.',
                  VERSION      => $version,
                  PREREQ_PM    => {
		                   Digest::SHA1      => 1,
                                   File::Spec        => 0.8,
                                   File::Temp        => 0.12,
                                   IO::File          => 1,
                                   Storable          => 1,
                                   Test::Harness     => 1.25,
                                   Test::More        => 0.11,
                                  },
                  dist         => {
                                   COMPRESS     => 'gzip -9',
                                   SUFFIX       => 'tgz',
                                  },
                  EXE_FILES    => ['demo/pp2sdf'],
                 );

# provide additional informations
warn <<EOM if $ok;

Welcome to the PerlPoint package $version!

The installation is well prepared now,
and you might run "make test" and
"make install".

Note: There are demo applications provided
in directory "demo". They can be started after
successfull installation of this package.

You can use the Changelog or TODO file as a
first PerlPoint input to run the demo scripts.
(With exception of pp2sdf, they do not
implement the full language but demonstrate
how converters can be built.)

pp2sdf will be installed together with the
package modules. It serves as a reference
implementation of a converter.

EOM
