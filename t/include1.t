

# = HISTORY SECTION =====================================================================

# ---------------------------------------------------------------------------------------
# version | date     | author   | changes
# ---------------------------------------------------------------------------------------
# 0.08    |22.07.2001| JSTENZEL | adapted to improved lexer;
# 0.07    |20.03.2001| JSTENZEL | adapted to tag templates;
#         |24.05.2001| JSTENZEL | adapted to paragraph reformatting: text paragraphs
#         |          |          | no longer contain a final whitespace string;
#         |28.05.2001| JSTENZEL | renamed to include1.t;
#         |01.06.2001| JSTENZEL | adapeted to modified lexing algorithm which takes
#         |          |          | "words" as long as possible;
# 0.06    |10.02.2001| JSTENZEL | added tests of "example" inclusion;
# 0.05    |09.12.2000| JSTENZEL | new namespace: "PP" => "PerlPoint";
# 0.04    |21.10.2000| JSTENZEL | added level offset example;
# 0.03    |05.10.2000| JSTENZEL | parser takes a Safe object now;
#         |07.10.2000| JSTENZEL | added inclusion of Perl code;
# 0.02    |04.10.2000| JSTENZEL | added filter test;
# 0.01    |21.05.2000| JSTENZEL | new.
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
BEGIN {plan tests=>219;}

# declare variables
my (@streamData, @results);

# build parser
my ($parser)=new PerlPoint::Parser;

# and call it
$parser->run(
             stream  => \@streamData,
             files   => ['t/include.pp'],
             filter  => 'pp|perl|anything',
             safe    => new Safe,
             trace   => TRACE_NOTHING,
             display => DISPLAY_NOINFO+DISPLAY_NOWARN,
            );

# build a backend
my $backend=new PerlPoint::Backend(
                                   name    => 'installation test: include files',
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
ok(shift(@results), $_) foreach (DIRECTIVE_DOCUMENT, DIRECTIVE_START, 'include.pp');
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'We include ');
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'This text was included.');
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);

ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);

ok(shift(@results), $_) foreach (DIRECTIVE_HEADLINE, DIRECTIVE_START, 11);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'First level headline moved to level 11');
ok(shift(@results), $_) foreach (DIRECTIVE_HEADLINE, DIRECTIVE_COMPLETE, 11);

ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'This is the 2nd included');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'PP file in this test.');
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);

ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'This was the source');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ':');
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);

ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_VERBATIM, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "  \n");
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "  =First level headline moved to level 11\n");
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "  \n");
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "  This is the 2nd included\n");
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "  PP file in this test.\n");
ok(shift(@results), $_) foreach (DIRECTIVE_VERBATIM, DIRECTIVE_COMPLETE);
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);

ok(shift(@results), $_) foreach (DIRECTIVE_BLOCK, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'something.');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "\n");
ok(shift(@results), $_) foreach (DIRECTIVE_BLOCK, DIRECTIVE_COMPLETE);
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'Continued frame source.');
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);

ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'Now we include another file type ');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, '- by declaration: ');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'EMBED');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'lang');
 ok(join(' ', sort values %$pars), 'anything');
}
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "\n");
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "This text was included.\n");
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "\n");
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "\\INCLUDE{type=pp file=\"include2.pp\" headlinebase=10}\n");
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "\n");
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "This was the source:\n");
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "\n");
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, qq(\\INCLUDE{type=example file="include2.pp" indent=2}\n));
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "\n");
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'EMBED');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'lang');
 ok(join(' ', sort values %$pars), 'anything');
}
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, '.');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'This can be done multiply, look: ');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'EMBED');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'lang');
 ok(join(' ', sort values %$pars), 'anything');
}
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "\n");
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "This text was included.\n");
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "\n");
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "\\INCLUDE{type=pp file=\"include2.pp\" headlinebase=10}\n");
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "\n");
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "This was the source:\n");
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "\n");
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, qq(\\INCLUDE{type=example file="include2.pp" indent=2}\n));
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "\n");
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'EMBED');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'lang');
 ok(join(' ', sort values %$pars), 'anything');
}
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, '.');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);

ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, q(Now, let's include ));
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'Perl code.');
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);

ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'Ready this test.');
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);

ok(shift(@results), $_) foreach (DIRECTIVE_DOCUMENT, DIRECTIVE_COMPLETE, 'include.pp');


# SUBROUTINES ###############################################################################

# headline handler: store what you found
sub handler
 {
  # simply store what you received
  push(@results, @_);
 }
