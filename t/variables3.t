
# = HISTORY SECTION =====================================================================

# ---------------------------------------------------------------------------------------
# version | date     | author   | changes
# ---------------------------------------------------------------------------------------
# 0.01    |07.03.2003| JSTENZEL | new.
# ---------------------------------------------------------------------------------------

# PerlPoint test script


# pragmata
use strict;

# load modules
use Carp;
use Test::More qw(no_plan);
use PerlPoint::Backend;
use PerlPoint::Constants;
use PerlPoint::Parser 0.39;

# declare variables
my (@streamData, @results);

# build parser
my ($parser)=new PerlPoint::Parser;

# and call it
$parser->run(
             stream          => \@streamData,
             files           => ['t/variables3.pp'],
             trace           => TRACE_NOTHING,
             display         => DISPLAY_NOINFO+DISPLAY_NOWARN,
            );

# build a backend
my $backend=new PerlPoint::Backend(
                                   name    => 'installation test: guarded variables',
                                   trace   => TRACE_NOTHING,
                                   display => DISPLAY_NOINFO,
                                  );

# register a complete set of backend handlers
$backend->register($_, \&handler) foreach (DIRECTIVE_BLOCK .. DIRECTIVE_SIMPLE);

# now run the backend
$backend->run(\@streamData);


# checks
is(shift(@results), $_) foreach (DIRECTIVE_DOCUMENT, DIRECTIVE_START, 'variables3.pp');

is(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'This text guards variables');
is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ': ');
is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, '$var, ');
is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, '$var2.');
is(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);

is(shift(@results), $_) foreach (DIRECTIVE_BLOCK, DIRECTIVE_START);
is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, '  ');
is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'This example guards variables');
is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "\n");
is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, '  ');
is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'as well: ');
is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, '$var, ');
is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, '$var2.');
is(shift(@results), $_) foreach (DIRECTIVE_BLOCK, DIRECTIVE_COMPLETE);

is(shift(@results), $_) foreach (DIRECTIVE_VERBATIM, DIRECTIVE_START);
is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "\n");
is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, " In a here doc, guarded vars\n");
is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, " remain guarded: \\\$var, \\\$var2.\n");
is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "\n");
is(shift(@results), $_) foreach (DIRECTIVE_VERBATIM, DIRECTIVE_COMPLETE);

is(shift(@results), $_) foreach (DIRECTIVE_DOCUMENT, DIRECTIVE_COMPLETE, 'variables3.pp');


# SUBROUTINES ###############################################################################

# headline handler: store what you found
sub handler
 {
  # simply store what you received
  push(@results, @_);
 }

