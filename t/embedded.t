

# = HISTORY SECTION =====================================================================

# ---------------------------------------------------------------------------------------
# version | date     | author   | changes
# ---------------------------------------------------------------------------------------
# 0.07    |22.07.2001| JSTENZEL | adapted to improved lexer;
# 0.06    |20.03.2001| JSTENZEL | adapted to tag templates;
#         |24.05.2001| JSTENZEL | adapted to paragraph reformatting: text paragraphs
#         |          |          | no longer contain a final whitespace string;
#         |01.06.2001| JSTENZEL | adapeted to modified lexing algorithm which takes
#         |          |          | "words" as long as possible;
# 0.05    |09.12.2000| JSTENZEL | new namespace: "PP" => "PerlPoint";
# 0.04    |05.10.2000| JSTENZEL | adapted to new behaviour: embedded Perl is evaluated!;
#         |07.10.2000| JSTENZEL | Perl Point can now be embedded into Perl Point;
# 0.03    |04.10.2000| JSTENZEL | added filter test;
# 0.02    |05.06.2000| JSTENZEL | adapted to modified stream structure;
# 0.01    |20.05.2000| JSTENZEL | new.
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
BEGIN {plan tests=>232;}

# declare variables
my (@streamData, @results);

# build parser
my ($parser)=new PerlPoint::Parser;

# and call it
$parser->run(
             stream  => \@streamData,
             files   => ['t/embedded.pp'],
             filter  => 'html|perl',
             safe    => new Safe,
             trace   => TRACE_NOTHING, # PARSER+TRACE_LEXER+TRACE_SEMANTIC+TRACE_PARAGRAPHS,
             display => DISPLAY_NOINFO+DISPLAY_NOWARN,
            );

# build a backend
my $backend=new PerlPoint::Backend(
                                   name    => 'installation test: embedded parts',
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
ok(shift(@results), $_) foreach (DIRECTIVE_DOCUMENT, DIRECTIVE_START, 'embedded.pp');
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'Literal text with an ');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'EMBED');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'lang');
 ok(join(' ', sort values %$pars), 'html');
}
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, '<i>embedded</i>');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'EMBED');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'lang');
 ok(join(' ', sort values %$pars), 'html');
}
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'part.');
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'Here we go for more.');
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'EMBED');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'lang');
 ok(join(' ', sort values %$pars), 'HTML');
}
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "\n");
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "\n");
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, '<i>This is embedded <b>HTML</b>.</i>');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "\n");
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "\n");
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'EMBED');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'lang');
 ok(join(' ', sort values %$pars), 'HTML');
}
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);

ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'Here the literal ');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'text continues.');
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);

ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'Perl may be embedded as well.');
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);

ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);

ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'Perl Point ');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'can ');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'be ');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'nested.');
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);

ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'Well.');
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);
ok(shift(@results), $_) foreach (DIRECTIVE_DOCUMENT, DIRECTIVE_COMPLETE, 'embedded.pp');

# 2nd turn ##################################################################################

# cleanup
undef @streamData;
undef @results;

# call parser again, evaluate code without Safe compartment
$parser->run(
             stream  => \@streamData,
             files   => ['t/embedded.pp'],
             filter  => 'html|perl',
             safe    => 1,
             trace   => TRACE_NOTHING, # PARSER+TRACE_LEXER+TRACE_SEMANTIC+TRACE_PARAGRAPHS,
             display => DISPLAY_NOINFO+DISPLAY_NOWARN,
            );

# run the backend again
$backend->run(\@streamData);

# perform checks
ok(shift(@results), $_) foreach (DIRECTIVE_DOCUMENT, DIRECTIVE_START, 'embedded.pp');
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'Literal text with an ');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'EMBED');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'lang');
 ok(join(' ', sort values %$pars), 'html');
}
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, '<i>embedded</i>');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'EMBED');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'lang');
 ok(join(' ', sort values %$pars), 'html');
}
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'part.');
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'Here we go for more.');
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'EMBED');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'lang');
 ok(join(' ', sort values %$pars), 'HTML');
}
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "\n");
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "\n");
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, '<i>This is embedded <b>HTML</b>.</i>');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "\n");
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "\n");
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'EMBED');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'lang');
 ok(join(' ', sort values %$pars), 'HTML');
}
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);

ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'Here the literal ');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'text continues.');
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);

ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'Perl may be embedded as well.');
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);

ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);

ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'Perl Point ');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'can ');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'be ');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'nested.');
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);

ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'Well.');
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);
ok(shift(@results), $_) foreach (DIRECTIVE_DOCUMENT, DIRECTIVE_COMPLETE, 'embedded.pp');

# SUBROUTINES ###############################################################################

# headline handler: store what you found
sub handler
 {
  # simply store what you received
  push(@results, @_);
 }
