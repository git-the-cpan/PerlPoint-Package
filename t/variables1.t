

# = HISTORY SECTION =====================================================================

# ---------------------------------------------------------------------------------------
# version | date     | author   | changes
# ---------------------------------------------------------------------------------------
# 0.08    |22.07.2001| JSTENZEL | adapted to improved lexer;
# 0.07    |20.03.2001| JSTENZEL | adapted to tag templates;
#         |23.03.2001| JSTENZEL | adapted to by line lexing of verbatim blocks;
#         |12.04.2001| JSTENZEL | added tests of predeclared variables;
#         |25.05.2001| JSTENZEL | adapted to paragraph reformatting: text paragraphs
#         |          |          | no longer contain a final whitespace string;
#         |28.05.2001| JSTENZEL | added _PARSER_VERSION test;
#         |01.06.2001| JSTENZEL | adapted to modified lexing algorithm which takes
#         |          |          | "words" as long as possible;
# 0.06    |20.01.2001| JSTENZEL | variable settings are now propagated into the stream;
# 0.05    |09.12.2000| JSTENZEL | new namespace: "PP" => "PerlPoint";
# 0.04    |07.10.2000| JSTENZEL | variables are accessible by (embedded) Perl now;
# 0.03    |05.10.2000| JSTENZEL | parser takes a Safe object now;
# 0.02    |05.06.2000| JSTENZEL | adapted to modified stream structure;
# 0.01    |15.04.2000| JSTENZEL | new.
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
use PerlPoint::Constants 0.11;

# prepare tests
BEGIN {plan tests=>295;}

# declare variables
my (@streamData, @results);

# build parser
my ($parser)=new PerlPoint::Parser;

# and call it
$parser->run(
             stream          => \@streamData,
             files           => ['t/variables.pp'],
             safe            => new Safe,
             var2stream      => 1,
             predeclaredVars => {vAr1=>'several', VaR2=>'variables',},
             trace           => TRACE_NOTHING,
             display         => DISPLAY_NOINFO+DISPLAY_NOWARN,
            );

# build a backend
my $backend=new PerlPoint::Backend(
                                   name    =>'installation test: variables',
                                   trace   =>TRACE_NOTHING,
                                   display => DISPLAY_NOINFO,
                                  );

# register a complete set of backend handlers
$backend->register($_, \&handler) foreach (DIRECTIVE_BLOCK .. DIRECTIVE_SIMPLE);

# now run the backend
$backend->run(\@streamData);

# checks
ok(shift(@results), $_) foreach (DIRECTIVE_VARSET, DIRECTIVE_START);
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'value var');
 ok($pars->{var}, '_PARSER_VERSION');
 ok($pars->{value}, $PerlPoint::Parser::VERSION);
}
ok(shift(@results), $_) foreach (DIRECTIVE_VARSET, DIRECTIVE_START);
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'value var');
 ok($pars->{var}, '_STARTDIR');
 # we skip the value check because this directory setting depends on the installation and may therefore vary
}
ok(shift(@results), $_) foreach (DIRECTIVE_VARSET, DIRECTIVE_START);
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'value var');
 ok($pars->{var}, 'VAR1');
 ok($pars->{value}, 'several');
}
ok(shift(@results), $_) foreach (DIRECTIVE_VARSET, DIRECTIVE_START);
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'value var');
 ok($pars->{var}, 'VAR2');
 ok($pars->{value}, 'variables');
}
ok(shift(@results), $_) foreach (DIRECTIVE_VARSET, DIRECTIVE_START);
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'value var');
 ok($pars->{var}, '_SOURCE_LEVEL');
 ok($pars->{value}, 1);
}
ok(shift(@results), $_) foreach (DIRECTIVE_DOCUMENT, DIRECTIVE_START, 'variables.pp');
ok(shift(@results), $_) foreach (DIRECTIVE_VARSET, DIRECTIVE_START);
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'value var');
 ok($pars->{var}, 'word');
 ok($pars->{value}, 'word');
}
ok(shift(@results), $_) foreach (DIRECTIVE_VARSET, DIRECTIVE_START);
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'value var');
 ok($pars->{var}, 'words');
 ok($pars->{value}, 'words words words');
}
ok(shift(@results), $_) foreach (DIRECTIVE_VARSET, DIRECTIVE_START);
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'value var');
 ok($pars->{var}, 'number');
 ok($pars->{value}, '17');
}
ok(shift(@results), $_) foreach (DIRECTIVE_VARSET, DIRECTIVE_START);
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'value var');
 ok($pars->{var}, 'string1');
 ok($pars->{value}, '"double quotes"');
}
ok(shift(@results), $_) foreach (DIRECTIVE_VARSET, DIRECTIVE_START);
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'value var');
 ok($pars->{var}, 'string2');
 ok($pars->{value}, "'single quotes'");
}
ok(shift(@results), $_) foreach (DIRECTIVE_VARSET, DIRECTIVE_START);
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'value var');
 ok($pars->{var}, 'multiline');
 ok($pars->{value}, 'one line next line 3rd line');
}
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, '${noAssignment}');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, '=no assignment');
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'Text');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ': word.');
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'words words words');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'at the beginning.');
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, q(And these are number (17), double ("double quotes") and single quoted ('single quotes') strings.));
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'This was assigned in a multiline');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ': one line next line 3rd line.');
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'Text');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ': word.');
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'words words words');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'at the beginning.');
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, q(And these are number (17), double ("double quotes") and single quoted ('single quotes') strings.));
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'This was assigned in a multiline');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ': one line next line 3rd line.');
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);
ok(shift(@results), $_) foreach (DIRECTIVE_BLOCK, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, '  ');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'Variables in');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "\n");
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, '  ');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'a code block:');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "\n");
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, '  ');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'word');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ', word.');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "\n");
ok(shift(@results), $_) foreach (DIRECTIVE_BLOCK, DIRECTIVE_COMPLETE);
ok(shift(@results), $_) foreach (DIRECTIVE_VERBATIM, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "\n");
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "  Variables in\n");
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "  a verbatim block:\n");
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "  \$word, \${word}.\n");
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "\n");
ok(shift(@results), $_) foreach (DIRECTIVE_VERBATIM, DIRECTIVE_COMPLETE);
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, '$nondeclared');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, '${variables}');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, '.');
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);
ok(shift(@results), $_) foreach (DIRECTIVE_VARSET, DIRECTIVE_START);
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'value var');
 ok($pars->{var}, 'value');
 ok($pars->{value}, '1st');
}
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'value is 1st.');
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);
ok(shift(@results), $_) foreach (DIRECTIVE_VARSET, DIRECTIVE_START);
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'value var');
 ok($pars->{var}, 'value');
 ok($pars->{value}, '2nd');
}
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'value is 2nd.');
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);
ok(shift(@results), $_) foreach (DIRECTIVE_VARSET, DIRECTIVE_START);
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'value var');
 ok($pars->{var}, 'value');
 ok($pars->{value}, '3rd');
}
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'value is 3rd.');
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);
ok(shift(@results), $_) foreach (DIRECTIVE_VARSET, DIRECTIVE_START);
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'value var');
 ok($pars->{var}, 'nested1');
 ok($pars->{value}, 'word 3rd');
}
ok(shift(@results), $_) foreach (DIRECTIVE_VARSET, DIRECTIVE_START);
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'value var');
 ok($pars->{var}, 'nested2');
 ok($pars->{value}, '17 word 3rd 17');
}
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, '17 word 3rd 17');
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);

ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'Predeclared were several variables.');
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);

ok(shift(@results), $_) foreach (DIRECTIVE_DOCUMENT, DIRECTIVE_COMPLETE, 'variables.pp');

# SUBROUTINES ###############################################################################

# headline handler: store what you found
sub handler
 {
  # simply store what you received
  push(@results, @_);
 }
