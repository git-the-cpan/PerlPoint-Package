
# Makefile.PL -- Makefile template for PerlPoint::Parser
#
# This file is part of the "PerlPoint::Package" module package.
# PerlPoint::Package is free software, you can redistribute it
# and/or modify it under the same terms as Perl itself.

# load module
use ExtUtils::MakeMaker;

# the package requires modern perl
require 5.00503;

# write makefile
$ok=WriteMakefile(
                  NAME         => 'PerlPoint',
                  VERSION      => '0.31',
                  PREREQ_PM    => {
		                   Digest::SHA1 => 1,
                                   IO::File     => 1,
                                   Storable     => 1,
                                  },
                  dist         => {
                                   COMPRESS     => 'gzip -9',
                                   SUFFIX       => 'tgz',
                                  },
                  EXE_FILES    => ['demo/pp2sdf'],
                 );

# provide additional informations
warn <<EOM if $ok;

Welcome to the PerlPoint package!

The installation is well prepared now,
and you might run "make test" and
"make install".

Note: There are demo applications provided
in directory "demo". They can be started after
successfull installation of this package.

You can use the Changelog or TODO file as a
first PerlPoint input to run the demo scripts.
(With exception of pp2sdf, they do not
implement the full language but show how
translators can be built.)

pp2sdf will be installed together with the
package modules.

EOM
