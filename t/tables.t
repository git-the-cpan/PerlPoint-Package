

# = HISTORY SECTION =====================================================================

# ---------------------------------------------------------------------------------------
# version | date     | author   | changes
# ---------------------------------------------------------------------------------------
# 0.07    |20.03.2001| JSTENZEL | adapted to tag templates;
#         |          | JSTENZEL | adapted to new TABLE tag behaviour;
#         |          | JSTENZEL | added table normalization checks;
#         |23.05.2001| JSTENZEL | adapted to field trimming;
#         |24.05.2001| JSTENZEL | adapted to paragraph reformatting: text paragraphs
#         |          |          | containing only a table become just a table now;
#         |25.05.2001| JSTENZEL | added test of new inlined (streamed) tables;
#         |          | JSTENZEL | added test of unuasual \END_TABLE tag placement
#         |26.05.2001| JSTENZEL | adapeted to new table nesting information;
#         |01.06.2001| JSTENZEL | adapted to modified lexing algorithm which takes
#         |          |          | "words" as long as possible;
# 0.06    |09.12.2000| JSTENZEL | new namespace: "PP" => "PerlPoint";
# 0.05    |11.10.2000| JSTENZEL | adapted to improved table paragraphs;
# 0.04    |10.10.2000| JSTENZEL | added tests for new table paragraphs;
# 0.03    |09.10.2000| JSTENZEL | adapted to fixed table handling;
# 0.02    |05.10.2000| JSTENZEL | parser takes a Safe object now;
# 0.01    |27.05.2000| JSTENZEL | new.
# ---------------------------------------------------------------------------------------

# PerlPoint test script


# pragmata
use strict;

# load modules
use Carp;
use Safe;
use Test;
use PerlPoint::Backend;
use PerlPoint::Parser 0.34;
use PerlPoint::Constants;

# prepare tests
BEGIN {plan tests=>1170;}

# declare variables
my (@streamData, @results);

# build parser
my ($parser)=new PerlPoint::Parser;

# and call it
$parser->run(
             stream       => \@streamData,
             files        => ['t/tables.pp'],
             safe         => new Safe,
             nestedTables => 1,
             trace        => TRACE_NOTHING,
             display      => DISPLAY_NOINFO+DISPLAY_NOWARN,
            );

# build a backend
my $backend=new PerlPoint::Backend(
                                   name    => 'installation test: tables',
                                   trace   => TRACE_NOTHING,
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

# now run the backend
$backend->run(\@streamData);

# perform checks
ok(shift(@results), $_) foreach (DIRECTIVE_DOCUMENT, DIRECTIVE_START, 'tables.pp');

# first table (made by tag)
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE');
 {
  my $pars=shift(@results);
  ok(ref($pars), 'HASH');
  ok(join(' ', sort keys %$pars), '__nestingLevel__ bg border separator');
  ok(join(' ', sort values %$pars), '1 2 blue |');
 }
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_ROW');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'column 1');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'column 2');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'column 3');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_ROW');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_ROW');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'xxxx');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'yyyy');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'zzzzz');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_ROW');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_ROW');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'uuuu');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'vvvv');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'wwwww');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_ROW');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE');
 {
  my $pars=shift(@results);
  ok(ref($pars), 'HASH');
  ok(join(' ', sort keys %$pars), '__nestingLevel__ bg border separator');
  ok(join(' ', sort values %$pars), '1 2 blue |');
 }


# second table (paragraph)
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE');
{my $pars=shift(@results);}

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_ROW');
  
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_HL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'column 1');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_HL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_HL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'column 2');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_HL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_HL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'column 3');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_HL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_ROW');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_ROW');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'xxxx');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'yyyy');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'zzzzz');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_ROW');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_ROW');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'uuuu');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'vvvv');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'wwwww');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_ROW');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE');
{my $pars=shift(@results);}

# first one column table (by tag)
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE');
 {
  my $pars=shift(@results);
  ok(ref($pars), 'HASH');
  ok(join(' ', sort keys %$pars), '__nestingLevel__ bg border separator');
  ok(join(' ', sort values %$pars), '1 2 blue |');
 }

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_ROW');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'column 1');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_ROW');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_ROW');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'xxxx');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_ROW');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_ROW');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'uuuu');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_ROW');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE');
 {
  my $pars=shift(@results);
  ok(ref($pars), 'HASH');
  ok(join(' ', sort keys %$pars), '__nestingLevel__ bg border separator');
  ok(join(' ', sort values %$pars), '1 2 blue |');
 }

# next table (by paragraph)
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE');
{my $pars=shift(@results);}

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_ROW');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_HL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'column 1');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_HL');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_ROW');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_ROW');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'xxxx');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_ROW');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_ROW');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'uuuu');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_ROW');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE');
{my $pars=shift(@results);}

# first normalized table (made by tag)
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE');
 {
  my $pars=shift(@results);
  ok(ref($pars), 'HASH');
  ok(join(' ', sort keys %$pars), '__nestingLevel__ bg border separator');
  ok(join(' ', sort values %$pars), '1 2 blue |');
 }

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_ROW');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'column 1');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'column 2');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'column 3');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_ROW');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_ROW');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'xxxx');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_ROW');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_ROW');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'xxxx');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_ROW');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_ROW');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'uuuu');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'vvvv');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_ROW');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_ROW');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'uuuu');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'vvvv');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_ROW');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE');
 {
  my $pars=shift(@results);
  ok(ref($pars), 'HASH');
  ok(join(' ', sort keys %$pars), '__nestingLevel__ bg border separator');
  ok(join(' ', sort values %$pars), '1 2 blue |');
 }


# 2nd normalized table (declared by paragraph)
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE');
{my $pars=shift(@results);}

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_ROW');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_HL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'column 1');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_HL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_HL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'column 2');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_HL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_HL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'column 3');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_HL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_ROW');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_ROW');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'xxxx');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_ROW');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_ROW');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'xxxx');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_ROW');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_ROW');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'uuuu');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'vvvv');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_ROW');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_ROW');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'uuuu');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'vvvv');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_ROW');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE');
{my $pars=shift(@results);}

# table unusually completed
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE');
 {
  my $pars=shift(@results);
  ok(ref($pars), 'HASH');
  ok(join(' ', sort keys %$pars), '__nestingLevel__ separator');
  ok(join(' ', sort values %$pars), '1 |');
 }
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_ROW');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'column 1');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'column 2');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_ROW');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_ROW');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'xxxx');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'yyyy');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_ROW');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE');
 {
  my $pars=shift(@results);
  ok(ref($pars), 'HASH');
  ok(join(' ', sort keys %$pars), '__nestingLevel__ separator');
  ok(join(' ', sort values %$pars), '1 |');
 }


# inlined table
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'Inlined');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ': ');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE');
 {
  my $pars=shift(@results);
  ok(ref($pars), 'HASH');
  ok(join(' ', sort keys %$pars), '__nestingLevel__ bg border separator');
  ok(join(' ', sort values %$pars), '1 2 blue |');
 }
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_ROW');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'column 1');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'column 2');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'column 3');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_ROW');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_ROW');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'xxxx');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'yyyy');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'zzzzz');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_ROW');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_ROW');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'uuuu');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'vvvv');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'wwwww');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_ROW');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE');
 {
  my $pars=shift(@results);
  ok(ref($pars), 'HASH');
  ok(join(' ', sort keys %$pars), '__nestingLevel__ bg border separator');
  ok(join(' ', sort values %$pars), '1 2 blue |');
 }

ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);


# 1st nested table
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'Nested 1');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ': ');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE');
 {
  my $pars=shift(@results);
  ok(ref($pars), 'HASH');
  ok(join(' ', sort keys %$pars), '__nestingLevel__');
  ok(join(' ', sort values %$pars), '1');
 }

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_ROW');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'column 1');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'column 2');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');

# --- nested table starts ---

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE');
 {
  my $pars=shift(@results);
  ok(ref($pars), 'HASH');
  ok(join(' ', sort keys %$pars), '__nestingLevel__');
  ok(join(' ', sort values %$pars), '2');
 }

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_ROW');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'n1');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'n2');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_ROW');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_ROW');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'n3');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'n4');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_ROW');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE');
 {
  my $pars=shift(@results);
  ok(ref($pars), 'HASH');
  ok(join(' ', sort keys %$pars), '__nestingLevel__');
  ok(join(' ', sort values %$pars), '2');
 }

# --- nested table completed ---

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_ROW');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_ROW');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'xxxx');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'yyyy');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'zzzzz');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_ROW');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_ROW');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'uuuu');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'vvvv');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'wwwww');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_ROW');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE');
 {
  my $pars=shift(@results);
  ok(ref($pars), 'HASH');
  ok(join(' ', sort keys %$pars), '__nestingLevel__');
  ok(join(' ', sort values %$pars), '1');
 }

ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);

# 2nd nested table (tag table inside a paragraph table)
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE');
 {
  my $pars=shift(@results);
  ok(ref($pars), 'HASH');
  ok(join(' ', sort keys %$pars), '__nestingLevel__');
  ok(join(' ', sort values %$pars), '1');
 }

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_ROW');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_HL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'column 1');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_HL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_HL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'column 2');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_HL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_HL');

# --- nested table starts ---

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE');
 {
  my $pars=shift(@results);
  ok(ref($pars), 'HASH');
  ok(join(' ', sort keys %$pars), '__nestingLevel__');
  ok(join(' ', sort values %$pars), '2');
 }

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_ROW');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'n1');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'n2');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_ROW');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_ROW');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'n3');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'n4');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_ROW');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE');
 {
  my $pars=shift(@results);
  ok(ref($pars), 'HASH');
  ok(join(' ', sort keys %$pars), '__nestingLevel__');
  ok(join(' ', sort values %$pars), '2');
 }

# --- nested table completed ---

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_HL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_ROW');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_ROW');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'xxxx');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'yyyy');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'zzzzz');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_ROW');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_ROW');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'uuuu');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'vvvv');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'wwwww');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_ROW');

ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE');
 {
  my $pars=shift(@results);
  ok(ref($pars), 'HASH');
  ok(join(' ', sort keys %$pars), '__nestingLevel__');
  ok(join(' ', sort values %$pars), '1');
 }

ok(shift(@results), $_) foreach (DIRECTIVE_DOCUMENT, DIRECTIVE_COMPLETE, 'tables.pp');

# everything tested?
ok(scalar(@results), 0);

# SUBROUTINES ###############################################################################

# headline handler: store what you found
sub handler
 {
  # simply store what you received
  push(@results, @_);
 }
