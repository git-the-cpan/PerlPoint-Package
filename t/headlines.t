

# = HISTORY SECTION =====================================================================

# ---------------------------------------------------------------------------------------
# version | date     | author   | changes
# ---------------------------------------------------------------------------------------
# 0.04    |20.03.2001| JSTENZEL | adapted to tag templates;
# 0.03    |09.12.2000| JSTENZEL | new namespace: "PP" => "PerlPoint";
# 0.02    |05.10.2000| JSTENZEL | parser takes a Safe object now;
# 0.01    |08.04.2000| JSTENZEL | new.
# ---------------------------------------------------------------------------------------

# PerlPoint test script


# pragmata
use strict;

# load modules
use Carp;
use Safe;
use Test;
use PerlPoint::Backend;
use PerlPoint::Parser 0.08;
use PerlPoint::Constants;

# prepare tests
BEGIN {plan tests=>72;}

# declare variables
my (@streamData, @results);

# build parser
my ($parser)=new PerlPoint::Parser;

# and call it
$parser->run(
             stream  => \@streamData,
             files   => ['t/headlines.pp'],
             safe    => new Safe,
             trace   => TRACE_NOTHING,
             display => DISPLAY_NOINFO+DISPLAY_NOWARN,
            );

# build a backend
my $backend=new PerlPoint::Backend(
                                   name    =>'installation test: headlines',
                                   trace   =>TRACE_NOTHING,
                                   display => DISPLAY_NOINFO,
                                  );

# register a complete set of backend handlers
$backend->register($_, \&handler) foreach (
                                           DIRECTIVE_BLOCK,
                                           DIRECTIVE_COMMENT,
                                           DIRECTIVE_DOCUMENT,
                                           DIRECTIVE_DPOINT,
                                           DIRECTIVE_HEADLINE,
                                           DIRECTIVE_LIST_LSHIFT,
                                           DIRECTIVE_LIST_RSHIFT,
                                           DIRECTIVE_OPOINT,
                                           DIRECTIVE_TAG,
                                           DIRECTIVE_TEXT,
                                           DIRECTIVE_UPOINT,
                                           DIRECTIVE_VERBATIM,
                                           DIRECTIVE_SIMPLE,
                                          );

# now run the backends
$backend->run(\@streamData);

# perform checks
shift(@results) until $results[0] eq DIRECTIVE_HEADLINE or not @results;

# level recognition
ok(shift(@results), $_) foreach (DIRECTIVE_HEADLINE, DIRECTIVE_START, 1);
shift(@results) until $results[0] eq DIRECTIVE_HEADLINE or not @results;
ok(shift(@results), $_) foreach (DIRECTIVE_HEADLINE, DIRECTIVE_COMPLETE, 1);

ok(shift(@results), $_) foreach (DIRECTIVE_HEADLINE, DIRECTIVE_START, 2);
shift(@results) until $results[0] eq DIRECTIVE_HEADLINE or not @results;
ok(shift(@results), $_) foreach (DIRECTIVE_HEADLINE, DIRECTIVE_COMPLETE, 2);

ok(shift(@results), $_) foreach (DIRECTIVE_HEADLINE, DIRECTIVE_START, 3);
shift(@results) until $results[0] eq DIRECTIVE_HEADLINE or not @results;
ok(shift(@results), $_) foreach (DIRECTIVE_HEADLINE, DIRECTIVE_COMPLETE, 3);

ok(shift(@results), $_) foreach (DIRECTIVE_HEADLINE, DIRECTIVE_START, 30);
shift(@results) until $results[0] eq DIRECTIVE_HEADLINE or not @results;
ok(shift(@results), $_) foreach (DIRECTIVE_HEADLINE, DIRECTIVE_COMPLETE, 30);

# line combination and paragraph termination
ok(shift(@results), $_) foreach (DIRECTIVE_HEADLINE, DIRECTIVE_START, 1);
shift(@results) until $results[0] eq DIRECTIVE_HEADLINE or not @results;
ok(shift(@results), $_) foreach (DIRECTIVE_HEADLINE, DIRECTIVE_COMPLETE, 1);

ok(shift(@results), $_) foreach (DIRECTIVE_HEADLINE, DIRECTIVE_START, 2);
shift(@results) until $results[0] eq DIRECTIVE_HEADLINE or not @results;
ok(shift(@results), $_) foreach (DIRECTIVE_HEADLINE, DIRECTIVE_COMPLETE, 2);

ok(shift(@results), $_) foreach (DIRECTIVE_HEADLINE, DIRECTIVE_START, 3);
shift(@results) until $results[0] eq DIRECTIVE_HEADLINE or not @results;
ok(shift(@results), $_) foreach (DIRECTIVE_HEADLINE, DIRECTIVE_COMPLETE, 3);

ok(shift(@results), $_) foreach (DIRECTIVE_HEADLINE, DIRECTIVE_START, 4);
shift(@results) until $results[0] eq DIRECTIVE_HEADLINE or not @results;
ok(shift(@results), $_) foreach (DIRECTIVE_HEADLINE, DIRECTIVE_COMPLETE, 4);

# trailing whitespace handling
ok(shift(@results), $_) foreach (DIRECTIVE_HEADLINE, DIRECTIVE_START, 1);
shift(@results) until $results[0] eq DIRECTIVE_HEADLINE or not @results;
ok(shift(@results), $_) foreach (DIRECTIVE_HEADLINE, DIRECTIVE_COMPLETE, 1);

ok(shift(@results), $_) foreach (DIRECTIVE_HEADLINE, DIRECTIVE_START, 2);
shift(@results) until $results[0] eq DIRECTIVE_HEADLINE or not @results;
ok(shift(@results), $_) foreach (DIRECTIVE_HEADLINE, DIRECTIVE_COMPLETE, 2);

ok(shift(@results), $_) foreach (DIRECTIVE_HEADLINE, DIRECTIVE_START, 3);
shift(@results) until $results[0] eq DIRECTIVE_HEADLINE or not @results;
ok(shift(@results), $_) foreach (DIRECTIVE_HEADLINE, DIRECTIVE_COMPLETE, 3);

ok(shift(@results), $_) foreach (DIRECTIVE_HEADLINE, DIRECTIVE_START, 4);
shift(@results) until $results[0] eq DIRECTIVE_HEADLINE or not @results;
ok(shift(@results), $_) foreach (DIRECTIVE_HEADLINE, DIRECTIVE_COMPLETE, 4);



# SUBROUTINES ###############################################################################

# headline handler: store what you found
sub handler
 {
  # simply store what you received
  push(@results, @_);
 }
