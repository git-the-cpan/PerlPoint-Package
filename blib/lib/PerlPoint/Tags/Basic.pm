

# = HISTORY SECTION =====================================================================

# ---------------------------------------------------------------------------------------
# version | date     | author   | changes
# ---------------------------------------------------------------------------------------
# 0.02    |02.10.2001| JSTENZEL | added LOCALTOC;
#         |11.10.2001| JSTENZEL | added SEQ;
#         |12.10.2001| JSTENZEL | added REF;
#         |13.10.2001| JSTENZEL | added HIDE;
#         |24.10.2001| JSTENZEL | added FORMAT and STOP;
#         |31.10.2001| JSTENZEL | added FORMAT doc;
#         |03.12.2001| JSTENZEL | now all messages mention the inflicted tag name and
#         |          |          | a source line number where possible;
# 0.01    |19.03.2001| JSTENZEL | new.
# ---------------------------------------------------------------------------------------

# = POD SECTION =========================================================================

=head1 NAME

B<PerlPoint::Tags::Basic> - declares basic PerlPoint tags

=head1 VERSION

This manual describes version B<0.02>.

=head1 SYNOPSIS

  # declare basic tags
  use PerlPoint::Tags::Basic;

=head1 DESCRIPTION

This module declares several basic PerlPoint tags. Tag declarations
are used by the parser to determine if a used tag is valid, if it needs
options, if it needs a body and so on. Please see
\B<PerlPoint::Tags> for a detailed description of tag declaration.

Every PerlPoint translator willing to handle the tags of this module
can declare this by using the module in the scope where it built the
parser object.

  # declare basic tags
  use PerlPoint::Tags::Basic;

  # load parser module
  use PerlPoint::Parser;

  ...

  # build parser
  my $parser=new PerlPoint::Parser(...);

  ...

It is also possible to select certain declarations.

  # declare basic tags
  use PerlPoint::Tags::Basic qw(I C);


A set name is provided as well to declare all the flags at once.

  # declare basic tags
  use PerlPoint::Tags::Basic qw(:basic);


=head1 TAGS

=head2 B

marks text as I<bold>. No options, but a mandatory tag body.

=head2 C

marks text as I<code>. No options, but a mandatory tag body.


=head2 FORMAT

is a container tag to configure result formatting. Configuration
settings are received via tag options and are intended to remain
valid until another modification. For example, one may set the
default text color of examples to green. This would remain valid
until the next text color setting.

Please note that this tag is very general. Accepted options and
their meaning are defined by the \I<converters>. Nevertheless,
certain settings are commonly used by convention.


=head2 HIDE

hides everything in its body. Makes most sense when used with
a tag condition.

=head2 I

marks text as I<italic>. No options, but a mandatory tag body.

=head2 IMAGE

includes an I<image>. No tag body, but a mandatory option C<"src"> to pass
the image file, and an optional option C<"alt"> to store text alternatively
to be displayed. The option set is open - there can be more options
but they will not be checked by the parser.

The image source file name will be supplied I<absolutely> in the stream.


=head2 LOCALTOC

inserts a list of subchapters, which means a list of the plain subchapter
titles. This is especially useful at the beginning of a greater document
section, or on an introduction page where you want to preview what the
audience can expect in the following talk section.

Using a tag relieves the documents author from writing and maintaining
this list manually.

There is no tag body, but the result can be configured by I<options>.

=over 4

=item depth

Subchapters may have subchapters as well. By default, the whole tree is
displayed, but this can be limited by this option. Pass the I<number>
of sublevels that shall be included. The lowest possible value is C<1>.
Invalid option values will cause syntax errors.

Consider you are in a level 1 headline with these subchapters:

  ==Details 1
  ==Details 2
  ===Details 2 explained
  ===Details 2 furtherly explained
  ==Conclusion

Depth C<1> will result in listing "Details 1", "Details 2" and "Conclusion".
Depth C<2> or greater will add the explanation subchapters of level 3.

Note that the option expects an I<offset> value. The list depth is
independend of the I<absolute> levels of subchapters. This way,
your settings will remain valid even if absolute levels change (which
might happen when the document is included, for example).

=item format

This setting configures what kind of list will be generated. The following
values are specified:

=over 4

=item bullets

produces an unordered list,

=item enumerated

produces an I<ordered> list,

=item numbers

produces a list where each chapter is preceeded by its chapter number,
according to the documents hierarchy (C<1.1.5>, C<2.3.> etc.).

=back

If this option is omitted, the setting defaults to C<bullets>.


=item type

B<linked> makes each listed subchapter title a link to the related
chapter. Note that this feature depends on the target formats link
support, so results may vary.

By default, titles are displayed as I<plain text> - B<plain> can be
used to specify this explicitly.


=back

B<Examples:>


  \LOCALTOC

C<>

  \LOCALTOC{depth=2}

C<>

  \LOCALTOC{format=enumerated type=linked}



=head2 READY

declares the document to be read completely. No options, no body. Works
instantly. Not even the current paragraph will become part of the result.
I<This tag is still experimental, and its behaviour may change in future versions.>
It is suggested to use it in a single text paragraph, usually embedded
into conditions.

  ? ready

C<>

  \READY

C<>

  ? 1


=head2 REF

This is a very general and highly configurable reference.
It can be used both to make linked and unlinked references,
it can fallback to alternative references if necessary,
and it can finally be that optional that the specified
reference does not even has to exist.

There are various options. Please note that several options
are filled by the parser. They are not internded to be
propagated to document authors.

To make best use of \REF it is recommended to register
all anchors at parsing time (with the parsers anchor
object passed to all tag hooks).


=over 4

=item name

specifies the name of the target anchor.
A missing link is an error unless C<occasion>
is set to a true value or an C<alt>ternative
address can be found.

Links are verified using the parsers anchor
object which is passed to all tag hooks.

=item type

configures which way the result should be produced:

I<linked>: The result is made a link to the referenced object.

I<plain>:  This is the default formatting and means that the
result is supplied as plain text.

=item alt

If the anchor specified by C<name> cannot be found,
the tag will try all entries of a comma separated list
specified by this options value. (For readability,
commata may be surrounded by whitespaces.) Trials
follow the listed link order, the first valid address
found will be used.

Links are verified using the parsers anchor
object which is passed to all tag hooks.

=item occasion

If the tag cannot find a valid address (either
by C<name> or by trying <alt>), usually an
error occurs. By setting this option to a true
value a missing link will be ignored. The result
is equal to a I<non specified> C<\REF> tag.

=item __body__

A flag saying there was a body specified or not.
This information can help converters to start a translation
before having read the tag body tokens (producing
links, a tag without body means that we have to
use the value of the referenced object (see C<__value__>)
our text, otherwise, the body text must be used).

=item __value__

The value of the (finally) referenced object. This
only works if the referenced anchor was registered
to the parsers C<PerlPoint::Anchors> object which
is passed to all tag hooks.


=back


=head2 SEQ

Inserts the next value of a certain numerical sequence.
Optionally, the generated number can be made an I<anchor>
to reference it at another place.

There is no tag body, but there are several I<options>.
Please note that the parser passes informations by
internal options as well.


=over 4

=item type

This specifies the sequence the number shall
belong to. If the specified string is not already
registered as a sequence, a new sequence is opened.
The first number in a new sequence is C<1>. If
the sequence is already known, the next number in
it will be supplied.

=item name

If passed, this option sets an anchor name which
is registered to the parsers C<PerlPoint::Anchors>
object (which is passed to all tag hooks). This makes
it easy to reference the generated number at another
place (by \REF or another referencing tag). The value
of such a link is the sequence number.

By default, no anchor is generated.

=item __nr__

This is the generated sequence number, inserted by the parser.
No user option.

=back

=head2 STOP

Enforces an syntactical error which stops document processing immediately.
Most useful when used with tag conditions.


=head1 TAG SETS

There is only one set "basic" including all the tags.

=cut


# check perl version
require 5.00503;

# = PACKAGE SECTION (internal helper package) ==========================================

# declare package
package PerlPoint::Tags::Basic;

# declare package version (as a STRING!!)
$VERSION="0.02";

# declare base "class"
use base qw(PerlPoint::Tags);


# = PRAGMA SECTION =======================================================================

# set pragmata
use strict;
use vars qw(%tags %sets);

# = LIBRARY SECTION ======================================================================

# load modules
use File::Basename;
use Cwd qw(cwd abs_path);
use PerlPoint::Constants 0.14 qw(:parsing :tags);


# = CODE SECTION =========================================================================

# private variables
my (%seq);

# tag declarations
%tags=(
       # base fomatting tags: no options, mandatory body
       B     => {body => TAGS_MANDATORY,},
       C     => {body => TAGS_MANDATORY,},
       I     => {body => TAGS_MANDATORY,},


       # container of formatting switches
       FORMAT => {
                  # all switches are passed by options
                  options => TAGS_MANDATORY,

                  # no body needed
                  body    => TAGS_DISABLED,
                 },


       # resolve a reference
       HIDE  => {
                 # conditions are options (currently), so ...
                 options => TAGS_OPTIONAL,

                 # there must be something to hide
                 body    => TAGS_MANDATORY,

                 # hook!
                 hook    => sub
                             {
                              # if this hook is invoked, it means we *shall* hide
                              # all content, so instruct the parser appropriately
                              PARSING_ERASE;
                             },
                },

       # image: no body, but several mandatory options
       IMAGE => {
                 # mandatory options
                 options => TAGS_MANDATORY,

                 # no body required
                 body    => TAGS_DISABLED,

                 # hook!
                 hook    => sub
                             {
                              # declare and init variable
                              my $ok=PARSING_OK;

                              # take parameters
                              my ($tagLine, $options)=@_;

                              # check them
                              $ok=PARSING_FAILED, warn qq(\n\n[Error] Missing "src" option in IMAGE tag, line $tagLine.\n) unless exists $options->{src};
                              $ok=PARSING_ERROR,  warn qq(\n\n[Error] Image file "$options->{src}" does not exist or is no file in IMAGE tag, line $tagLine.\n) if $ok==PARSING_OK and not (-e $options->{src} and not -d _);

                              # add current path to options, if necessary (deprecated)
                              $options->{__loaderpath__}=cwd() if $ok==PARSING_OK;

                              # absolutify the image source path (should work on UNIX and DOS, but other systems?)
                              my ($base, $path, $type)=fileparse($options->{src});
                              $options->{src}=join('/', abs_path($path), basename($options->{src})) if $ok==PARSING_OK;

                              # supply status
                              $ok;
                             },
                },

       # subchapter list
       LOCALTOC => {
                    # no body, optional options
                    body    => TAGS_DISABLED,
                    options => TAGS_OPTIONAL,

                    # hook in to check option values
                    hook    => sub
                                {
                                 # declare and init variable
                                 my $ok=PARSING_OK;

                                 # take parameters
                                 my ($tagLine, $options)=@_;

                                 # check them
                                 $ok=PARSING_FAILED, warn qq(\n\n[Error] LOCALTOC tag option "depth" requires a number greater 0, line $tagLine.\n)
                                  if     exists $options->{depth}
                                     and $options->{depth}!~/^\d+$/
                                     and $options->{depth};

                                 $ok=PARSING_FAILED, warn qq(\n\n[Error] Invalid "format" setting "$options->{format}" in LOCALTOC tag, line $tagLine.\n)
                                  if     exists $options->{format}
                                     and $options->{format}!~/^(bullets|enumerated|numbers)$/;

                                 $ok=PARSING_FAILED, warn qq(\n\n[Error] Invalid "type" setting "$options->{type}" in LOCALTOC tag, line $tagLine.\n)
                                  if     exists $options->{type}
                                     and $options->{type}!~/^(linked|plain)$/;

                                 # set defaults, if necessary
                                 if ($ok==PARSING_OK)
                                   {
                                    $options->{depth}=0          unless exists $options->{depth};
                                    $options->{format}='bullets' unless exists $options->{format};
                                    $options->{type}='plain'     unless exists $options->{type};
                                   }

                                 # supply status
                                 $ok;
                                },
                   },


       # declare document to be complete
       READY => {
                 # no options required
                 options => TAGS_DISABLED,

                 # no body required
                 body    => TAGS_DISABLED,

                 # hook!
                 hook    => sub
                             {
                              # flag that parsing is completed
                              PARSING_COMPLETED;
                             },
                },


       # resolve a reference
       REF   => {
                 # at least one option is required
                 options => TAGS_MANDATORY,

                 # there can be a body
                 body    => TAGS_OPTIONAL,

                 # hook!
                 hook    => sub
                             {
                              # declare and init variable
                              my $ok=PARSING_OK;

                              # take parameters
                              my ($tagLine, $options, $body, $anchors)=@_;

                              # check them (a name must be specified at least)
                              $ok=PARSING_FAILED, warn qq(\n\n[Error] Missing "name" option in REF tag, line $tagLine.\n) unless exists $options->{name};

                              $ok=PARSING_FAILED, warn qq(\n\n[Error] Invalid "type" setting "$options->{type}" in REF tag, line $tagLine.\n)
                                if     exists $options->{type}
                                   and $options->{type}!~/^(linked|plain)$/;

                              # set defaults, if necessary
                              $options->{type}='plain' unless exists $options->{type};

                              # plain references make no sense with a body
                              $ok=PARSING_IGNORE, warn qq(\n\n[Warn] REF tag ignored in line $tagLine: body makes "plain" formatting useless.\n)
                                if $options->{type} eq 'plain' and @$body;

                              # store a body hint
                              $options->{__body__}=@$body ? 1 : 0;

                              # format address to simplify anchor search
                              $options->{name}=~s/\s*\|\s*/\|/g if exists $options->{name};

                              # supply status
                              $ok;
                             },

                 # afterburner
                 finish =>  sub
                             {
                              # declare and init variable
                              my $ok=PARSING_OK;

                              # take parameters
                              my ($options, $anchors)=@_;

                              # try to find an alternative, if possible
                              if (exists $options->{alt} and not $anchors->query($options->{name}))
                                {
                                 foreach my $alternative (split(/\s*,\s*/, $options->{alt}))
                                   {
                                    if ($anchors->query($alternative))
                                      {
                                       warn qq(\n\n[Info] Unknown link address "$options->{name}" is replaced by alternative "$alternative" in REF tag.\n);
                                       $options->{name}=$alternative;
                                       last;
                                      }
                                   }
                                }

                              # check link for being valid - finally
                              unless ($anchors->query($options->{name}))
                                {
                                 # allowed case?
                                 if (exists $options->{occasion} and $options->{occasion})
                                   {
                                    $ok=PARSING_IGNORE;
                                    warn qq(\n\n[Info] Unknown link address "$options->{name}": REF tag ignored.\n);
                                   }
                                 else
                                   {
                                    $ok=PARSING_FAILED;
                                    warn qq(\n\n[Error] Unknown link address "$options->{name}" in REF tag.\n);
                                   }
                                }
                              else
                                {
                                 # link ok, get value
                                 $options->{__value__}=$anchors->query($options->{name})->{$options->{name}};
                                }

                              # supply status
                              $ok;
                             },
                },


       # add a new sequence entry
       SEQ   => {
                 # at least one option is required
                 options => TAGS_MANDATORY,

                 # no body required
                 body    => TAGS_DISABLED,

                 # hook!
                 hook    => sub
                             {
                              # declare and init variable
                              my $ok=PARSING_OK;

                              # take parameters
                              my ($tagLine, $options, $body, $anchors)=@_;

                              # check them (a sequence type must be specified, a name is optional)
                              $ok=PARSING_FAILED, warn qq(\n\n[Error] Missing "type" option in SEQ tag, line $tagLine.\n) unless exists $options->{type};

                              # still all right?
                              if ($ok==PARSING_OK)
                                {
                                 # get a new entry, store it by option
                                 $options->{__nr__}=++$seq{$options->{type}};

                                 # if a name was set, store it together with the value
                                 $anchors->add($options->{name}, $seq{$options->{type}}) if $options->{name};
                                }

                              # supply status
                              $ok;
                             },
                },


       # stop document processing by raising an syntactical error
       STOP  => {
                 # conditions are options (currently), so ...
                 options => TAGS_OPTIONAL,

                 # no body needed
                 body    => TAGS_DISABLED,

                 # hook!
                 hook    => sub
                             {
                              # enforce fatal error
                              PARSING_FAILED;
                             },
                },
      );


%sets=(
       basic => [qw(B C I FORMAT HIDE IMAGE LOCALTOC READY REF SEQ STOP)],
      );


1;


# = POD TRAILER SECTION =================================================================

=pod

=head1 SEE ALSO

=over 4

=item B<PerlPoint::Tags>

The tag declaration base "class".

=back


=head1 SUPPORT

A PerlPoint mailing list is set up to discuss usage, ideas,
bugs, suggestions and translator development. To subscribe,
please send an empty message to perlpoint-subscribe@perl.org.

If you prefer, you can contact me via perl@jochen-stenzel.de
as well.

=head1 AUTHOR

Copyright (c) Jochen Stenzel (perl@jochen-stenzel.de), 1999-2001.
All rights reserved.

This module is free software, you can redistribute it and/or modify it
under the terms of the Artistic License distributed with Perl version
5.003 or (at your option) any later version. Please refer to the
Artistic License that came with your Perl distribution for more
details.

The Artistic License should have been included in your distribution of
Perl. It resides in the file named "Artistic" at the top-level of the
Perl source tree (where Perl was downloaded/unpacked - ask your
system administrator if you dont know where this is).  Alternatively,
the current version of the Artistic License distributed with Perl can
be viewed on-line on the World-Wide Web (WWW) from the following URL:
http://www.perl.com/perl/misc/Artistic.html


=head1 DISCLAIMER

This software is distributed in the hope that it will be useful, but
is provided "AS IS" WITHOUT WARRANTY OF ANY KIND, either expressed or
implied, INCLUDING, without limitation, the implied warranties of
MERCHANTABILITY and FITNESS FOR A PARTICULAR PURPOSE.

The ENTIRE RISK as to the quality and performance of the software
IS WITH YOU (the holder of the software).  Should the software prove
defective, YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR
CORRECTION.

IN NO EVENT WILL ANY COPYRIGHT HOLDER OR ANY OTHER PARTY WHO MAY CREATE,
MODIFY, OR DISTRIBUTE THE SOFTWARE BE LIABLE OR RESPONSIBLE TO YOU OR TO
ANY OTHER ENTITY FOR ANY KIND OF DAMAGES (no matter how awful - not even
if they arise from known or unknown flaws in the software).

Please refer to the Artistic License that came with your Perl
distribution for more details.

