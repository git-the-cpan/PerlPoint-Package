

# = HISTORY SECTION =====================================================================

# ---------------------------------------------------------------------------------------
# version | date     | author   | changes
# ---------------------------------------------------------------------------------------
# 0.01    |28.05.2001| JSTENZEL | new.
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
BEGIN {plan tests=>191;}

# declare variables
my (@streamData, @results);

# build parser
my ($parser)=new PerlPoint::Parser;

# and call it
$parser->run(
             stream     => \@streamData,
             files      => ['t/include3.pp'],
             filter     => 'pp',
             safe       => new Safe,
             var2stream => 1,
             trace      => TRACE_NOTHING,
             display    => DISPLAY_NOINFO+DISPLAY_NOWARN,
            );

# build a backend
my $backend=new PerlPoint::Backend(
                                   name    => 'installation test: include files preserving variables',
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
                                           DIRECTIVE_VARRESET,
                                           DIRECTIVE_TAG,
                                           DIRECTIVE_TEXT,
                                           DIRECTIVE_UPOINT,
                                           DIRECTIVE_VARSET,
                                           DIRECTIVE_VERBATIM,
                                           DIRECTIVE_SIMPLE,
                                          );

# now run the backend
$backend->run(\@streamData);

# perform checks, starting by skipping predeclared variables (checked by another test)
shift(@results) until $results[0] eq DIRECTIVE_DOCUMENT and $results[1] eq DIRECTIVE_START;

# source stream begins
ok(shift(@results), $_) foreach (DIRECTIVE_DOCUMENT, DIRECTIVE_START, 'include3.pp');

# variables are set
ok(shift(@results), $_) foreach (DIRECTIVE_VARSET, DIRECTIVE_START);
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'value var');
 ok($pars->{var}, 'toBeRestored1');
 ok($pars->{value}, 'value1');
}
ok(shift(@results), $_) foreach (DIRECTIVE_VARSET, DIRECTIVE_START);
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'value var');
 ok($pars->{var}, 'toBeRestored2');
 ok($pars->{value}, 'value2');
}
ok(shift(@results), $_) foreach (DIRECTIVE_VARSET, DIRECTIVE_START);
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'value var');
 ok($pars->{var}, 'canBeOverwritten');
 ok($pars->{value}, 'value3');
}

# original values
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'Original values');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, q(: "value1", "value2", "value3".));
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);

# internal variable is set
ok(shift(@results), $_) foreach (DIRECTIVE_VARSET, DIRECTIVE_START);
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'value var');
 ok($pars->{var}, '_SOURCE_LEVEL');
 ok($pars->{value}, 2);
}

# including a source makes an empty paragraph here ... could be improved!
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);

# variables are set
ok(shift(@results), $_) foreach (DIRECTIVE_VARSET, DIRECTIVE_START);
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'value var');
 ok($pars->{var}, 'toBeRestored1');
 ok($pars->{value}, 'newValue1');
}
ok(shift(@results), $_) foreach (DIRECTIVE_VARSET, DIRECTIVE_START);
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'value var');
 ok($pars->{var}, 'toBeRestored2');
 ok($pars->{value}, 'newValue2');
}
ok(shift(@results), $_) foreach (DIRECTIVE_VARSET, DIRECTIVE_START);
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'value var');
 ok($pars->{var}, 'canBeOverwritten');
 ok($pars->{value}, 'newValue3');
}

# in the nested source
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'Values inside nested source');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, q(: "newValue1", "newValue2", "newValue3".));
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);

# internal variable is set
ok(shift(@results), $_) foreach (DIRECTIVE_VARSET, DIRECTIVE_START);
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'value var');
 ok($pars->{var}, '_SOURCE_LEVEL');
 ok($pars->{value}, 1);
}

# all variables are reset ...
ok(shift(@results), $_) foreach (DIRECTIVE_VARRESET, DIRECTIVE_START);

# ... and set again to restore original values
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
 ok($pars->{var}, '_SOURCE_LEVEL');
 ok($pars->{value}, 1);
}
ok(shift(@results), $_) foreach (DIRECTIVE_VARSET, DIRECTIVE_START);
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'value var');
 ok($pars->{var}, '_STARTDIR');
 # skip the value test here
}
ok(shift(@results), $_) foreach (DIRECTIVE_VARSET, DIRECTIVE_START);
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'value var');
 ok($pars->{var}, 'canBeOverwritten');
 ok($pars->{value}, 'value3');
}
ok(shift(@results), $_) foreach (DIRECTIVE_VARSET, DIRECTIVE_START);
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'value var');
 ok($pars->{var}, 'toBeRestored1');
 ok($pars->{value}, 'value1');
}
ok(shift(@results), $_) foreach (DIRECTIVE_VARSET, DIRECTIVE_START);
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'value var');
 ok($pars->{var}, 'toBeRestored2');
 ok($pars->{value}, 'value2');
}

# restored values
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'After 1st inclusion');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, q(: "value1", "value2", "value3".));
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);

# internal variable is set
ok(shift(@results), $_) foreach (DIRECTIVE_VARSET, DIRECTIVE_START);
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'value var');
 ok($pars->{var}, '_SOURCE_LEVEL');
 ok($pars->{value}, 2);
}

# including a source makes an empty paragraph here ... could be improved!
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);

# variables are set
ok(shift(@results), $_) foreach (DIRECTIVE_VARSET, DIRECTIVE_START);
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'value var');
 ok($pars->{var}, 'toBeRestored1');
 ok($pars->{value}, 'newValue1');
}
ok(shift(@results), $_) foreach (DIRECTIVE_VARSET, DIRECTIVE_START);
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'value var');
 ok($pars->{var}, 'toBeRestored2');
 ok($pars->{value}, 'newValue2');
}
ok(shift(@results), $_) foreach (DIRECTIVE_VARSET, DIRECTIVE_START);
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'value var');
 ok($pars->{var}, 'canBeOverwritten');
 ok($pars->{value}, 'newValue3');
}

# in the nested source
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'Values inside nested source');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, q(: "newValue1", "newValue2", "newValue3".));
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);

# internal variable is set
ok(shift(@results), $_) foreach (DIRECTIVE_VARSET, DIRECTIVE_START);
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'value var');
 ok($pars->{var}, '_SOURCE_LEVEL');
 ok($pars->{value}, 1);
}

# variables are restored
ok(shift(@results), $_) foreach (DIRECTIVE_VARSET, DIRECTIVE_START);
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'value var');
 ok($pars->{var}, 'toBeRestored1');
 ok($pars->{value}, 'value1');
}
ok(shift(@results), $_) foreach (DIRECTIVE_VARSET, DIRECTIVE_START);
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'value var');
 ok($pars->{var}, 'toBeRestored2');
 ok($pars->{value}, 'value2');
}

# restored values
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'After 2nd inclusion');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, q(: "value1", "value2", "newValue3".));
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);

ok(shift(@results), $_) foreach (DIRECTIVE_DOCUMENT, DIRECTIVE_COMPLETE, 'include3.pp');


# SUBROUTINES ###############################################################################

# headline handler: store what you found
sub handler
 {
  # simply store what you received
  push(@results, @_);
 }
