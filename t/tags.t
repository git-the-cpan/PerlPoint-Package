

# = HISTORY SECTION =====================================================================

# ---------------------------------------------------------------------------------------
# version | date     | author   | changes
# ---------------------------------------------------------------------------------------
# 0.06    |09.12.2000| JSTENZEL | new namespace: "PP" => "PerlPoint";
# 0.05    |05.10.2000| JSTENZEL | parser takes a Safe object now;
# 0.04    |03.10.2000| JSTENZEL | adapted to new definition list grammar: definition item
#         |          |          | is now made of base elements like tags;
# 0.03    |16.08.2000| JSTENZEL | added a demonstration of string parameters;
# 0.02    |27.05.2000| JSTENZEL | adapted to modified list streaming (leading spaces);
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
use PerlPoint::Parser 0.09;
use PerlPoint::Constants;

# prepare tests
BEGIN {plan tests=>736;}

# declare variables
my (@streamData, @results);

# build parser
my ($parser)=new PerlPoint::Parser;

# and call it
$parser->run(
             stream  => \@streamData,
             tags    => {FONT=>1, TEST=>1, TOAST=>1,},
             files   => ['t/tags.pp'],
             safe    => new Safe,
             trace   => TRACE_NOTHING,
             display => DISPLAY_NOINFO,
            );

# build a backend
my $backend=new PerlPoint::Backend(
                                   name    => 'installation test: tags',
                                   trace   => TRACE_NOTHING,
                                   display => DISPLAY_NOINFO,
                                  );

# register a complete set of backend handlers
$backend->register($_, \&handler) foreach (DIRECTIVE_BLOCK .. DIRECTIVE_SIMPLE);

# now run the backend
$backend->run(\@streamData);

# checks
ok(shift(@results), $_) foreach (DIRECTIVE_DOCUMENT, DIRECTIVE_START, 'tags.pp');
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'Simple');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ':');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TEST');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), '');
}
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TEST');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), '');
}
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, '.');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'Guarded');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ':');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "\\");
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'TEST');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, '.');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'Sequence');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ':');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TEST');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), '');
}
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TEST');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), '');
}
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TOAST');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), '');
}
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TOAST');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), '');
}
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, '.');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'With');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'body');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ':');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TOAST');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), '');
}
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'toast');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TOAST');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), '');
}
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, '.');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'Sequence');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ':');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TEST');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), '');
}
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'test');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TEST');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), '');
}
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TOAST');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), '');
}
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'toast');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TOAST');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), '');
}
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, '.');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'Nested');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ':');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TEST');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), '');
}
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'tested');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TOAST');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), '');
}
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'toast');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TOAST');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), '');
}
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TEST');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), '');
}
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, '.');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'With');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'parameters');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ':');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TEST');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'par1 par2');
 ok($pars->{par1}, 'p1');
 ok($pars->{par2}, 'p2');
}
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TEST');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'par1 par2');
 ok($pars->{par1}, 'p1');
 ok($pars->{par2}, 'p2');
}
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'Sequence');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ':');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TEST');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 't');
 ok($pars->{t}, 'test');
}
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TEST');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 't');
 ok($pars->{t}, 'test');
}
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TOAST');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 't');
 ok($pars->{t}, 'toast');
}
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TOAST');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 't');
 ok($pars->{t}, 'toast');
}
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, '.');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'Complete');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ':');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TEST');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 't');
 ok($pars->{t}, 'test');
}
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'test');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TEST');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 't');
 ok($pars->{t}, 'test');
}
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'Sequence');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ':');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TEST');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 't');
 ok($pars->{t}, 'test');
}
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'test');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TEST');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 't');
 ok($pars->{t}, 'test');
}
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TOAST');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 't');
 ok($pars->{t}, 'toast');
}
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'toast');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TOAST');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 't');
 ok($pars->{t}, 'toast');
}
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, '.');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'Nested');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ':');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TEST');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 't');
 ok($pars->{t}, 'test');
}
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'tested');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TOAST');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 't');
 ok($pars->{t}, 'toast');
}
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'toast');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TOAST');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 't');
 ok($pars->{t}, 'toast');
}
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TEST');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 't');
 ok($pars->{t}, 'test');
}
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, '.');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);
ok(shift(@results), $_) foreach (DIRECTIVE_HEADLINE, DIRECTIVE_START, DIRECTIVE_COMPLETE);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'Tag');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'in');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'a');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TEST');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), '');
}
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'headline');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TEST');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), '');
}
# ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_HEADLINE, DIRECTIVE_COMPLETE, DIRECTIVE_COMPLETE);
ok(shift(@results), $_) foreach (DIRECTIVE_ULIST, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_UPOINT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TEST');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), '');
}
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'Tags');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TEST');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), '');
}
ok(shift(@results), $_) foreach (DIRECTIVE_UPOINT, DIRECTIVE_COMPLETE);
ok(shift(@results), $_) foreach (DIRECTIVE_ULIST, DIRECTIVE_COMPLETE);
ok(shift(@results), $_) foreach (DIRECTIVE_OLIST, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_OPOINT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TOAST');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), '');
}
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'in');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TOAST');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), '');
}
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_OPOINT, DIRECTIVE_COMPLETE);
ok(shift(@results), $_) foreach (DIRECTIVE_OLIST, DIRECTIVE_COMPLETE);
ok(shift(@results), $_) foreach (DIRECTIVE_DLIST, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_DPOINT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_DPOINT_ITEM, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'FONT');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'color');
 ok($pars->{color}, 'blue')
}
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'item');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'FONT');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'color');
 ok($pars->{color}, 'blue')
}
ok(shift(@results), $_) foreach (DIRECTIVE_DPOINT_ITEM, DIRECTIVE_COMPLETE);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'list');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TEST');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), '');
}
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'po');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TOAST');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), '');
}
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'i');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TOAST');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), '');
}
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'nts');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TEST');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), '');
}
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, '.');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_DPOINT, DIRECTIVE_COMPLETE);
ok(shift(@results), $_) foreach (DIRECTIVE_DLIST, DIRECTIVE_COMPLETE);
ok(shift(@results), $_) foreach (DIRECTIVE_BLOCK, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, '   ');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'And');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'in');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "\n");
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, '   ');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'a');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TEST');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), '');
}
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'block');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TEST');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), '');
}
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, '.');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "\n");
ok(shift(@results), $_) foreach (DIRECTIVE_BLOCK, DIRECTIVE_COMPLETE);
ok(shift(@results), $_) foreach (DIRECTIVE_VERBATIM, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "\n");
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, '  ');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'Tags');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'are');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'currently');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "\\");
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'TEST');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, '<');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'not');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, '>');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "\n");
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, '  ');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'processed');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'in');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "\\");
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'TOAST');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, '<');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'Verbatim');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'blocks');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, '>');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, '.');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "\n");
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "\n");
ok(shift(@results), $_) foreach (DIRECTIVE_VERBATIM, DIRECTIVE_COMPLETE);

ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'String');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'parameter');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ':');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'TEST');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'addr t');
 ok($pars->{addr}, 'http://www.perl.com');
 ok($pars->{t}, 'test');
}
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'test');
ok(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TEST');
{
 my $pars=shift(@results);
 ok(ref($pars), 'HASH');
 ok(join(' ', sort keys %$pars), 'addr t');
 ok($pars->{addr}, 'http://www.perl.com');
}
ok(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);

ok(shift(@results), $_) foreach (DIRECTIVE_DOCUMENT, DIRECTIVE_COMPLETE, 'tags.pp');


# SUBROUTINES ###############################################################################

# headline handler: store what you found
sub handler
 {
  # simply store what you received
  push(@results, @_);
 }
