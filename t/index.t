

# = HISTORY SECTION =====================================================================

# ---------------------------------------------------------------------------------------
# version | date     | author   | changes
# ---------------------------------------------------------------------------------------
# 0.01    |26.04.2003| JSTENZEL | new.
# ---------------------------------------------------------------------------------------

# PerlPoint test script


# load modules
use Carp;
use Test::More qw(no_plan);
use PerlPoint::Backend;
use PerlPoint::Parser 0.39;
use PerlPoint::Constants;

# declare test tags
use lib qw(t);
use PerlPoint::Tags;
use PerlPoint::Tags::Basic;

# declare variables
my (@streamData, @results);

# build parser
my ($parser)=new PerlPoint::Parser;

# and call it
$parser->run(
             stream        => \@streamData,
             files         => ['t/index.pp'],
             headlineLinks => 1,
             trace         => TRACE_NOTHING,
             display       => DISPLAY_NOINFO,
            );

# build a backend
my $backend=new PerlPoint::Backend(
                                   name    => 'installation test: index',
                                   trace   => TRACE_NOTHING,
                                   display => DISPLAY_NOINFO,
                                  );

# register a complete set of backend handlers
$backend->register($_, \&handler) foreach (DIRECTIVE_BLOCK .. DIRECTIVE_SIMPLE);

# now run the backend
$backend->run(\@streamData);

# checks
is(shift(@results), $_) foreach (DIRECTIVE_DOCUMENT, DIRECTIVE_START, 'index.pp');

# chapter 1
is(shift(@results), $_) foreach (DIRECTIVE_HEADLINE, DIRECTIVE_START, 1, 'Our first chapter', '');
{
 my $docstreams=shift(@results);
 is(ref($docstreams), 'ARRAY');
 is(join(' ', @$docstreams), '');
}
is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'Our first chapter');
is(shift(@results), $_) foreach (DIRECTIVE_HEADLINE, DIRECTIVE_COMPLETE, 1);

is(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "Let's say I want to ");

is(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'X');
{
 my $pars=shift(@results);
 is(ref($pars), 'HASH');
 is(join(' ', sort keys %$pars), '');
}
is(shift(@results), 1);
is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'index');
is(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'X');
{
 my $pars=shift(@results);
 is(ref($pars), 'HASH');
 is(join(' ', sort keys %$pars), '');
}
is(shift(@results), 1);

is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, " ");
is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'a ');

is(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'X');
{
 my $pars=shift(@results);
 is(ref($pars), 'HASH');
 is(join(' ', sort keys %$pars), '');
}
is(shift(@results), 1);
is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'word');
is(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'X');
{
 my $pars=shift(@results);
 is(ref($pars), 'HASH');
 is(join(' ', sort keys %$pars), '');
}
is(shift(@results), 1);

is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, '.');
is(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);

is(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "It is a very ");

is(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'X');
{
 my $pars=shift(@results);
 is(ref($pars), 'HASH');
 is(join(' ', sort keys %$pars), '');
}
is(shift(@results), 1);
is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'important');
is(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'X');
{
 my $pars=shift(@results);
 is(ref($pars), 'HASH');
 is(join(' ', sort keys %$pars), '');
}
is(shift(@results), 1);

is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'one everyone should know about.');

is(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);

is(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);

is(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'INDEXRELATIONS');
{
 my $pars=shift(@results);
 is(ref($pars), 'HASH');
 is(join(' ', sort grep(!/^__/, keys %$pars)), 'format readdepth reldepth threshold type');
 is(join(' ', map {$pars->{$_}} sort grep(!/^__/, keys %$pars)), 'bullets full startpage 50% linked');
 is_deeply($pars->{__data}, [[3, 50]]);
}
is(shift(@results), 0);

is(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'INDEXRELATIONS');
{
 my $pars=shift(@results);
 is(ref($pars), 'HASH');
 is(join(' ', sort keys %$pars), '__id format readdepth reldepth threshold type');
 is(join(' ', map {$pars->{$_}} sort keys %$pars), '1 bullets full startpage 50% linked');
}
is(shift(@results), 0);

is(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);



# subchapter 1.1
is(shift(@results), $_) foreach (DIRECTIVE_HEADLINE, DIRECTIVE_START, 2, '... with deeper explanations', '');
{
 my $docstreams=shift(@results);
 is(ref($docstreams), 'ARRAY');
 is(join(' ', @$docstreams), '');
}
is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, '... with deeper explanations');
is(shift(@results), $_) foreach (DIRECTIVE_HEADLINE, DIRECTIVE_COMPLETE, 2);

is(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "You know, an index collects keywords of the ");

is(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'X');
{
 my $pars=shift(@results);
 is(ref($pars), 'HASH');
 is(join(' ', sort keys %$pars), '');
}
is(shift(@results), 1);
is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'text');
is(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'X');
{
 my $pars=shift(@results);
 is(ref($pars), 'HASH');
 is(join(' ', sort keys %$pars), '');
}
is(shift(@results), 1);

is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, '.');
is(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);


# chapter 3
is(shift(@results), $_) foreach (DIRECTIVE_HEADLINE, DIRECTIVE_START, 1, 'Our second chapter', '');
{
 my $docstreams=shift(@results);
 is(ref($docstreams), 'ARRAY');
 is(join(' ', @$docstreams), '');
}
is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'Our second chapter');
is(shift(@results), $_) foreach (DIRECTIVE_HEADLINE, DIRECTIVE_COMPLETE, 1);

is(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "There are more ");

is(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'X');
{
 my $pars=shift(@results);
 is(ref($pars), 'HASH');
 is(join(' ', sort keys %$pars), '');
}
is(shift(@results), 1);
is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'word');
is(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'X');
{
 my $pars=shift(@results);
 is(ref($pars), 'HASH');
 is(join(' ', sort keys %$pars), '');
}
is(shift(@results), 1);

is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 's out of course, but they are not');
is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'of interest in this ');

is(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'X');
{
 my $pars=shift(@results);
 is(ref($pars), 'HASH');
 is(join(' ', sort keys %$pars), '');
}
is(shift(@results), 1);
is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'text');
is(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'X');
{
 my $pars=shift(@results);
 is(ref($pars), 'HASH');
 is(join(' ', sort keys %$pars), '');
}
is(shift(@results), 1);

is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, '.');
is(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);

is(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);

is(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'INDEXRELATIONS');
{
 my $pars=shift(@results);
 is(ref($pars), 'HASH');
 is(join(' ', sort grep(!/^__/, keys %$pars)), 'format threshold type');
 is(join(' ', map {$pars->{$_}} sort grep(!/^__/, keys %$pars)), 'enumerated 100% plain');
 is_deeply($pars->{__data}, [[1, 100]]);
}
is(shift(@results), 0);

is(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'INDEXRELATIONS');
{
 my $pars=shift(@results);
 is(ref($pars), 'HASH');
 is(join(' ', sort keys %$pars), '__id format threshold type');
 is(join(' ', map {$pars->{$_}} sort keys %$pars), '3 enumerated 100% plain');
}
is(shift(@results), 0);

is(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);


# chapter 4
is(shift(@results), $_) foreach (DIRECTIVE_HEADLINE, DIRECTIVE_START, 1, 'Conclusion', '');
{
 my $docstreams=shift(@results);
 is(ref($docstreams), 'ARRAY');
 is(join(' ', @$docstreams), '');
}
is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'Conclusion');
is(shift(@results), $_) foreach (DIRECTIVE_HEADLINE, DIRECTIVE_COMPLETE, 1);

is(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, "Importance is (con)");

is(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'X');
{
 my $pars=shift(@results);
 is(ref($pars), 'HASH');
 is(join(' ', sort keys %$pars), '');
}
is(shift(@results), 1);
is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'text');
is(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'X');
{
 my $pars=shift(@results);
 is(ref($pars), 'HASH');
 is(join(' ', sort keys %$pars), '');
}
is(shift(@results), 1);

is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'dependent.');
is(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);

is(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
is(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'INDEXRELATIONS');
{
 my $pars=shift(@results);
 is(ref($pars), 'HASH');
 is(join(' ', sort grep(!/^__/, keys %$pars)), 'format type');
 is(join(' ', map {$pars->{$_}} sort grep(!/^__/, keys %$pars)), 'numbers plain');
 is_deeply($pars->{__data}, [[1, 100], [3, 100]]);
}
is(shift(@results), 0);

is(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'INDEXRELATIONS');
{
 my $pars=shift(@results);
 is(ref($pars), 'HASH');
 is(join(' ', sort keys %$pars), '__id format type');
 is(join(' ', map {$pars->{$_}} sort keys %$pars), '4 numbers plain');
}
is(shift(@results), 0);

is(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);


# index chapter
is(shift(@results), $_) foreach (DIRECTIVE_HEADLINE, DIRECTIVE_START, 1, 'Index', '');
{
 my $docstreams=shift(@results);
 is(ref($docstreams), 'ARRAY');
 is(join(' ', @$docstreams), '');
}
is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'Index');
is(shift(@results), $_) foreach (DIRECTIVE_HEADLINE, DIRECTIVE_COMPLETE, 1);

is(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
is(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_START, 'INDEX');
{
 my $pars=shift(@results);
 is(ref($pars), 'HASH');
 is(join(' ', sort keys %$pars), '');
}
is(shift(@results), 0);
is(shift(@results), $_) foreach (DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'INDEX');
{
 my $pars=shift(@results);
 is(ref($pars), 'HASH');
 is(join(' ', sort keys %$pars), '');
}
is(shift(@results), 0);
is(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);

# document read
is(shift(@results), $_) foreach (DIRECTIVE_DOCUMENT, DIRECTIVE_COMPLETE, 'index.pp');


# SUBROUTINES ###############################################################################

# headline handler: store what you found
sub handler
 {
  # simply store what you received
  push(@results, @_);
 }
