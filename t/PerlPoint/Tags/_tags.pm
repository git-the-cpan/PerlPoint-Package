

# = HISTORY SECTION =====================================================================

# ---------------------------------------------------------------------------------------
# version | date     | author   | changes
# ---------------------------------------------------------------------------------------
# 0.03    |< 14.04.02| JSTENZEL | added simple versions of \I, \B and \C;
# 0.02    |13.10.2001| JSTENZEL | added copy of PerlPoint::Tags::Basic tag \REF;
# 0.01    |20.03.2001| JSTENZEL | new.
# ---------------------------------------------------------------------------------------

# pragmata
use strict;

# declare a helper package to declare tags
package PerlPoint::Tags::_tags;

# declare base "class"
use base qw(PerlPoint::Tags);

# declare global
use vars qw(%tags %sets);

# load modules
use PerlPoint::Constants qw(:parsing :tags);

# declare tags
%tags=(
       FONT => {
                 options    => TAGS_MANDATORY,
                 body       => TAGS_MANDATORY,
                },
       TEST  => {
                 options => TAGS_OPTIONAL,
                },

       TOAST => {
                 options => TAGS_OPTIONAL,
                },

       B     => {body => TAGS_MANDATORY,},
       C     => {body => TAGS_MANDATORY,},
       I     => {body => TAGS_MANDATORY,},

       # resolve a reference (copied from PerlPoint::Tags::Basic 0.02)
       # (this is used to check hook invokation and anchor management)
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

                              $ok=PARSING_FAILED, warn qq(\n\n[Error] Invalid "type" setting.\n)
                                if     exists $options->{type}
                                   and $options->{format}!~/^(linked|plain)$/;

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

                              # check link for being valid
                              unless (my $anchor=$anchors->query($options->{name}))
                                {$ok=PARSING_FAILED, warn qq(\n\n[Error] Unknown link address "$options->{name}."\n);}
                              else
                                {
                                 # link ok, get value (there is only one key/value pair in the received hash)
                                 ($options->{__value__})=(values %$anchor);
                                }

                              # supply status
                              $ok;
                             },
                },
      );

# flag success
1;
