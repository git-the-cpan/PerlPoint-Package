

# = HISTORY SECTION =====================================================================

# ---------------------------------------------------------------------------------------
# version | date     | author   | changes
# ---------------------------------------------------------------------------------------
# 0.07    |20.03.2001| JSTENZEL | adapted to tag templates;
#         |01.06.2001| JSTENZEL | adapted to modified lexing algorithm which takes
#         |          |          | "words" as long as possible;
# 0.06    |30.01.2001| JSTENZEL | ordered lists now provide the entry level number;
# 0.05    |09.12.2000| JSTENZEL | new namespace: "PP" => "PerlPoint";
# 0.04    |18.11.2000| JSTENZEL | new ordered list continuation;
# 0.03    |05.10.2000| JSTENZEL | parser takes a Safe object now;
#         |07.10.2000| JSTENZEL | new multilevel shifts;
# 0.02    |03.10.2000| JSTENZEL | adapted to new definition list syntax;
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
BEGIN {plan tests=>157;}

# declare variables
my (@streamData, @results);

# build parser
my ($parser)=new PerlPoint::Parser;

# and call it
$parser->run(
             stream  => \@streamData,
             files   => ['t/lists.pp'],
             safe    => new Safe,
             trace   => TRACE_NOTHING,
             display => DISPLAY_NOINFO+DISPLAY_NOWARN,
            );

# build a backend
my $backend=new PerlPoint::Backend(
                                   name    =>'installation test: lists',
                                   trace   =>TRACE_NOTHING,
                                   display => DISPLAY_NOINFO,
                                  );

# register a complete set of backend handlers
$backend->register($_, \&handler) foreach (DIRECTIVE_BLOCK .. DIRECTIVE_SIMPLE);

# now run the backend
$backend->run(\@streamData);

# perform checks
shift(@results) until $results[0] eq DIRECTIVE_ULIST or not @results;

# 1st level
ok(shift(@results), $_) foreach (DIRECTIVE_ULIST, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_UPOINT, DIRECTIVE_START);
shift(@results) until $results[0] eq DIRECTIVE_UPOINT or not @results;
ok(shift(@results), $_) foreach (DIRECTIVE_UPOINT, DIRECTIVE_COMPLETE);

ok(shift(@results), $_) foreach (DIRECTIVE_UPOINT, DIRECTIVE_START);
shift(@results) until $results[0] eq DIRECTIVE_UPOINT or not @results;
ok(shift(@results), $_) foreach (DIRECTIVE_UPOINT, DIRECTIVE_COMPLETE);
ok(shift(@results), $_) foreach (DIRECTIVE_ULIST, DIRECTIVE_COMPLETE);

ok(shift(@results), $_) foreach (DIRECTIVE_OLIST, DIRECTIVE_START, 1);
ok(shift(@results), $_) foreach (DIRECTIVE_OPOINT, DIRECTIVE_START);
shift(@results) until $results[0] eq DIRECTIVE_OPOINT or not @results;
ok(shift(@results), $_) foreach (DIRECTIVE_OPOINT, DIRECTIVE_COMPLETE);

ok(shift(@results), $_) foreach (DIRECTIVE_OPOINT, DIRECTIVE_START);
shift(@results) until $results[0] eq DIRECTIVE_OPOINT or not @results;
ok(shift(@results), $_) foreach (DIRECTIVE_OPOINT, DIRECTIVE_COMPLETE);
ok(shift(@results), $_) foreach (DIRECTIVE_OLIST, DIRECTIVE_COMPLETE, 1);

# shift right
ok(shift(@results), $_) foreach (DIRECTIVE_LIST_RSHIFT, DIRECTIVE_START, 1);
ok(shift(@results), $_) foreach (DIRECTIVE_LIST_RSHIFT, DIRECTIVE_COMPLETE, 1);

# 2nd level
ok(shift(@results), $_) foreach (DIRECTIVE_OLIST, DIRECTIVE_START, 1);
ok(shift(@results), $_) foreach (DIRECTIVE_OPOINT, DIRECTIVE_START);
shift(@results) until $results[0] eq DIRECTIVE_OPOINT or not @results;
ok(shift(@results), $_) foreach (DIRECTIVE_OPOINT, DIRECTIVE_COMPLETE);
ok(shift(@results), $_) foreach (DIRECTIVE_OLIST, DIRECTIVE_COMPLETE, 1);

ok(shift(@results), $_) foreach (DIRECTIVE_ULIST, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_UPOINT, DIRECTIVE_START);
shift(@results) until $results[0] eq DIRECTIVE_UPOINT or not @results;
ok(shift(@results), $_) foreach (DIRECTIVE_UPOINT, DIRECTIVE_COMPLETE);
ok(shift(@results), $_) foreach (DIRECTIVE_ULIST, DIRECTIVE_COMPLETE);

ok(shift(@results), $_) foreach (DIRECTIVE_OLIST, DIRECTIVE_START, 2);
ok(shift(@results), $_) foreach (DIRECTIVE_OPOINT, DIRECTIVE_START, 2);
shift(@results) until $results[0] eq DIRECTIVE_OPOINT or not @results;
ok(shift(@results), $_) foreach (DIRECTIVE_OPOINT, DIRECTIVE_COMPLETE, 2);
ok(shift(@results), $_) foreach (DIRECTIVE_OLIST, DIRECTIVE_COMPLETE, 2);

# shift right 2 levels
ok(shift(@results), $_) foreach (DIRECTIVE_LIST_RSHIFT, DIRECTIVE_START, 2);
ok(shift(@results), $_) foreach (DIRECTIVE_LIST_RSHIFT, DIRECTIVE_COMPLETE, 2);

# 4th level
ok(shift(@results), $_) foreach (DIRECTIVE_ULIST, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_UPOINT, DIRECTIVE_START);
shift(@results) until $results[0] eq DIRECTIVE_UPOINT or not @results;
ok(shift(@results), $_) foreach (DIRECTIVE_UPOINT, DIRECTIVE_COMPLETE);
ok(shift(@results), $_) foreach (DIRECTIVE_ULIST, DIRECTIVE_COMPLETE);

ok(shift(@results), $_) foreach (DIRECTIVE_OLIST, DIRECTIVE_START, 1);
ok(shift(@results), $_) foreach (DIRECTIVE_OPOINT, DIRECTIVE_START);
shift(@results) until $results[0] eq DIRECTIVE_OPOINT or not @results;
ok(shift(@results), $_) foreach (DIRECTIVE_OPOINT, DIRECTIVE_COMPLETE);
ok(shift(@results), $_) foreach (DIRECTIVE_OLIST, DIRECTIVE_COMPLETE, 1);

# shift left 2 levels
ok(shift(@results), $_) foreach (DIRECTIVE_LIST_LSHIFT, DIRECTIVE_START, 2);
ok(shift(@results), $_) foreach (DIRECTIVE_LIST_LSHIFT, DIRECTIVE_COMPLETE, 2);

# 2nd level
ok(shift(@results), $_) foreach (DIRECTIVE_ULIST, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_UPOINT, DIRECTIVE_START);
shift(@results) until $results[0] eq DIRECTIVE_UPOINT or not @results;
ok(shift(@results), $_) foreach (DIRECTIVE_UPOINT, DIRECTIVE_COMPLETE);
ok(shift(@results), $_) foreach (DIRECTIVE_ULIST, DIRECTIVE_COMPLETE);

# shift left
ok(shift(@results), $_) foreach (DIRECTIVE_LIST_LSHIFT, DIRECTIVE_START, 1);
ok(shift(@results), $_) foreach (DIRECTIVE_LIST_LSHIFT, DIRECTIVE_COMPLETE, 1);

# 1st level
ok(shift(@results), $_) foreach (DIRECTIVE_OLIST, DIRECTIVE_START, 1);
ok(shift(@results), $_) foreach (DIRECTIVE_OPOINT, DIRECTIVE_START);
shift(@results) until $results[0] eq DIRECTIVE_OPOINT or not @results;
ok(shift(@results), $_) foreach (DIRECTIVE_OPOINT, DIRECTIVE_COMPLETE);

ok(shift(@results), $_) foreach (DIRECTIVE_OPOINT, DIRECTIVE_START);
shift(@results) until $results[0] eq DIRECTIVE_OPOINT or not @results;
ok(shift(@results), $_) foreach (DIRECTIVE_OPOINT, DIRECTIVE_COMPLETE);
ok(shift(@results), $_) foreach (DIRECTIVE_OLIST, DIRECTIVE_COMPLETE, 1);

ok(shift(@results), $_) foreach (DIRECTIVE_ULIST, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_UPOINT, DIRECTIVE_START);
shift(@results) until $results[0] eq DIRECTIVE_UPOINT or not @results;
ok(shift(@results), $_) foreach (DIRECTIVE_UPOINT, DIRECTIVE_COMPLETE);
ok(shift(@results), $_) foreach (DIRECTIVE_ULIST, DIRECTIVE_COMPLETE);


ok(shift(@results), $_) foreach (DIRECTIVE_DLIST, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_DPOINT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_DPOINT_ITEM, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'definition');
ok(shift(@results), $_) foreach (DIRECTIVE_DPOINT_ITEM, DIRECTIVE_COMPLETE);
shift(@results) until $results[0] eq DIRECTIVE_DPOINT or not @results;
ok(shift(@results), $_) foreach (DIRECTIVE_DPOINT, DIRECTIVE_COMPLETE);

ok(shift(@results), $_) foreach (DIRECTIVE_DPOINT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_DPOINT_ITEM, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'definition with spaces ');
ok(shift(@results), $_) foreach (DIRECTIVE_DPOINT_ITEM, DIRECTIVE_COMPLETE);
shift(@results) until $results[0] eq DIRECTIVE_DPOINT or not @results;
ok(shift(@results), $_) foreach (DIRECTIVE_DPOINT, DIRECTIVE_COMPLETE);
ok(shift(@results), $_) foreach (DIRECTIVE_DLIST, DIRECTIVE_COMPLETE);



# SUBROUTINES ###############################################################################

# headline handler: store what you found
sub handler
 {
  # simply store what you received
  push(@results, @_);
 }
