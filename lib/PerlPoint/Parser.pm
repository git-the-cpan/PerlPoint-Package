####################################################################
#
#    This file was generated using Parse::Yapp version 1.01.
#
#        Don't edit this file, use source file instead.
#
#             ANY CHANGE MADE HERE WILL BE LOST !
#
####################################################################
package PerlPoint::Parser;
use vars qw ( @ISA );
use strict;

@ISA= qw ( Parse::Yapp::Driver );
#Included Parse/Yapp/Driver.pm file----------------------------------------
{
#
# Module Parse::Yapp::Driver
#
# This module is part of the Parse::Yapp package available on your
# nearest CPAN
#
# Any use of this module in a standalone parser make the included
# text under the same copyright as the Parse::Yapp module itself.
#
# This notice should remain unchanged.
#
# (c) Copyright 1998-1999 Francois Desarmenien, all rights reserved.
# (see the pod text in Parse::Yapp module for use and distribution rights)
#

package Parse::Yapp::Driver;

require 5.004;

use strict;

use vars qw ( $VERSION $COMPATIBLE $FILENAME );

$VERSION = '1.01';
$COMPATIBLE = '0.07';
$FILENAME=__FILE__;

use Carp;

#Known parameters, all starting with YY (leading YY will be discarded)
my(%params)=(YYLEX => 'CODE', 'YYERROR' => 'CODE', YYVERSION => '',
			 YYRULES => 'ARRAY', YYSTATES => 'ARRAY', YYDEBUG => '');
#Mandatory parameters
my(@params)=('LEX','RULES','STATES');

sub new {
    my($class)=shift;
	my($errst,$nberr,$token,$value,$check,$dotpos);
    my($self)={ ERROR => \&_Error,
				ERRST => \$errst,
                NBERR => \$nberr,
				TOKEN => \$token,
				VALUE => \$value,
				DOTPOS => \$dotpos,
				STACK => [],
				DEBUG => 0,
				CHECK => \$check };

	_CheckParams( [], \%params, \@_, $self );

		exists($$self{VERSION})
	and	$$self{VERSION} < $COMPATIBLE
	and	croak "Yapp driver version $VERSION ".
			  "incompatible with version $$self{VERSION}:\n".
			  "Please recompile parser module.";

        ref($class)
    and $class=ref($class);

    bless($self,$class);
}

sub YYParse {
    my($self)=shift;
    my($retval);

	_CheckParams( \@params, \%params, \@_, $self );

	if($$self{DEBUG}) {
		_DBLoad();
		$retval = eval '$self->_DBParse()';#Do not create stab entry on compile
        $@ and die $@;
	}
	else {
		$retval = $self->_Parse();
	}
    $retval
}

sub YYData {
	my($self)=shift;

		exists($$self{USER})
	or	$$self{USER}={};

	$$self{USER};
	
}

sub YYErrok {
	my($self)=shift;

	${$$self{ERRST}}=0;
    undef;
}

sub YYNberr {
	my($self)=shift;

	${$$self{NBERR}};
}

sub YYRecovering {
	my($self)=shift;

	${$$self{ERRST}} != 0;
}

sub YYAbort {
	my($self)=shift;

	${$$self{CHECK}}='ABORT';
    undef;
}

sub YYAccept {
	my($self)=shift;

	${$$self{CHECK}}='ACCEPT';
    undef;
}

sub YYError {
	my($self)=shift;

	${$$self{CHECK}}='ERROR';
    undef;
}

sub YYSemval {
	my($self)=shift;
	my($index)= $_[0] - ${$$self{DOTPOS}} - 1;

		$index < 0
	and	-$index <= @{$$self{STACK}}
	and	return $$self{STACK}[$index][1];

	undef;	#Invalid index
}

sub YYCurtok {
	my($self)=shift;

        @_
    and ${$$self{TOKEN}}=$_[0];
    ${$$self{TOKEN}};
}

sub YYCurval {
	my($self)=shift;

        @_
    and ${$$self{VALUE}}=$_[0];
    ${$$self{VALUE}};
}

sub YYExpect {
    my($self)=shift;

    keys %{$self->{STATES}[$self->{STACK}[-1][0]]{ACTIONS}}
}



#################
# Private stuff #
#################


sub _CheckParams {
	my($mandatory,$checklist,$inarray,$outhash)=@_;
	my($prm,$value);
	my($prmlst)={};

	while(($prm,$value)=splice(@$inarray,0,2)) {
        $prm=uc($prm);
			exists($$checklist{$prm})
		or	croak("Unknow parameter '$prm'");
			ref($value) eq $$checklist{$prm}
		or	croak("Invalid value for parameter '$prm'");
        $prm=unpack('@2A*',$prm);
		$$outhash{$prm}=$value;
	}
	for (@$mandatory) {
			exists($$outhash{$_})
		or	croak("Missing mandatory parameter '".lc($_)."'");
	}
}

sub _Error {
	print "Parse error.\n";
}

sub _DBLoad {
	{
		no strict 'refs';

			exists(${__PACKAGE__.'::'}{_DBParse})#Already loaded ?
		and	return;
	}
	my($fname)=__FILE__;
	my(@drv);
	open(DRV,"<$fname") or die "Report this as a BUG: Cannot open $fname";
	while(<DRV>) {
                	/^\s*sub\s+_Parse\s*{\s*$/ .. /^\s*}\s*#\s*_Parse\s*$/
        	and     do {
                	s/^#DBG>//;
                	push(@drv,$_);
        	}
	}
	close(DRV);

	$drv[0]=~s/_P/_DBP/;
	eval join('',@drv);
}

#Note that for loading debugging version of the driver,
#this file will be parsed from 'sub _Parse' up to '}#_Parse' inclusive.
#So, DO NOT remove comment at end of sub !!!
sub _Parse {
    my($self)=shift;

	my($rules,$states,$lex,$error)
     = @$self{ 'RULES', 'STATES', 'LEX', 'ERROR' };
	my($errstatus,$nberror,$token,$value,$stack,$check,$dotpos)
     = @$self{ 'ERRST', 'NBERR', 'TOKEN', 'VALUE', 'STACK', 'CHECK', 'DOTPOS' };

#DBG>	my($debug)=$$self{DEBUG};
#DBG>	my($dbgerror)=0;

#DBG>	my($ShowCurToken) = sub {
#DBG>		my($tok)='>';
#DBG>		for (split('',$$token)) {
#DBG>			$tok.=		(ord($_) < 32 or ord($_) > 126)
#DBG>					?	sprintf('<%02X>',ord($_))
#DBG>					:	$_;
#DBG>		}
#DBG>		$tok.='<';
#DBG>	};

	$$errstatus=0;
	$$nberror=0;
	($$token,$$value)=(undef,undef);
	@$stack=( [ 0, undef ] );
	$$check='';

    while(1) {
        my($actions,$act,$stateno);

        $stateno=$$stack[-1][0];
        $actions=$$states[$stateno];

#DBG>	print STDERR ('-' x 40),"\n";
#DBG>		$debug & 0x2
#DBG>	and	print STDERR "In state $stateno:\n";
#DBG>		$debug & 0x08
#DBG>	and	print STDERR "Stack:[".
#DBG>					 join(',',map { $$_[0] } @$stack).
#DBG>					 "]\n";


        if  (exists($$actions{ACTIONS})) {

				defined($$token)
            or	do {
				($$token,$$value)=&$lex($self);
#DBG>				$debug & 0x01
#DBG>			and	print STDERR "Need token. Got ".&$ShowCurToken."\n";
			};

            $act=   exists($$actions{ACTIONS}{$$token})
                    ?   $$actions{ACTIONS}{$$token}
                    :   exists($$actions{DEFAULT})
                        ?   $$actions{DEFAULT}
                        :   undef;
        }
        else {
            $act=$$actions{DEFAULT};
#DBG>			$debug & 0x01
#DBG>		and	print STDERR "Don't need token.\n";
        }

            defined($act)
        and do {

                $act > 0
            and do {        #shift

#DBG>				$debug & 0x04
#DBG>			and	print STDERR "Shift and go to state $act.\n";

					$$errstatus
				and	do {
					--$$errstatus;

#DBG>					$debug & 0x10
#DBG>				and	$dbgerror
#DBG>				and	$$errstatus == 0
#DBG>				and	do {
#DBG>					print STDERR "**End of Error recovery.\n";
#DBG>					$dbgerror=0;
#DBG>				};
				};


                push(@$stack,[ $act, $$value ]);

					$$token ne ''	#Don't eat the eof
				and	$$token=$$value=undef;
                next;
            };

            #reduce
            my($lhs,$len,$code,@sempar,$semval);
            ($lhs,$len,$code)=@{$$rules[-$act]};

#DBG>			$debug & 0x04
#DBG>		and	$act
#DBG>		and	print STDERR "Reduce using rule ".-$act." ($lhs,$len): ";

                $act
            or  $self->YYAccept();

            $$dotpos=$len;

                unpack('A1',$lhs) eq '@'    #In line rule
            and do {
                    $lhs =~ /^\@[0-9]+\-([0-9]+)$/
                or  die "In line rule name '$lhs' ill formed: ".
                        "report it as a BUG.\n";
                $$dotpos = $1;
            };

            @sempar =       $$dotpos
                        ?   map { $$_[1] } @$stack[ -$$dotpos .. -1 ]
                        :   ();


            $semval = $code ? &$code( $self, @sempar )
                            : @sempar ? $sempar[0] : undef;

            splice(@$stack,-$len,$len);

                $$check eq 'ACCEPT'
            and do {

#DBG>			$debug & 0x04
#DBG>		and	print STDERR "Accept.\n";

				return($semval);
			};

                $$check eq 'ABORT'
            and	do {

#DBG>			$debug & 0x04
#DBG>		and	print STDERR "Abort.\n";

				return(undef);

			};

#DBG>			$debug & 0x04
#DBG>		and	print STDERR "Back to state $$stack[-1][0], then ";

                $$check eq 'ERROR'
            or  do {
#DBG>				$debug & 0x04
#DBG>			and	print STDERR 
#DBG>				    "go to state $$states[$$stack[-1][0]]{GOTOS}{$lhs}.\n";

#DBG>				$debug & 0x10
#DBG>			and	$dbgerror
#DBG>			and	$$errstatus == 0
#DBG>			and	do {
#DBG>				print STDERR "**End of Error recovery.\n";
#DBG>				$dbgerror=0;
#DBG>			};

			    push(@$stack,
                     [ $$states[$$stack[-1][0]]{GOTOS}{$lhs}, $semval ]);
                next;
            };

#DBG>			$debug & 0x04
#DBG>		and	print STDERR "Forced Error recovery.\n";

            $$check='';
        };

        #Error
            $$errstatus
        or   do {

#DBG>			$debug & 0x10
#DBG>		and	do {
#DBG>			print STDERR "**Entering Error recovery.\n";
#DBG>			++$dbgerror;
#DBG>		};

            ++$$nberror;
            &$error($self);
        };

			$$errstatus == 3	#The next token is not valid: discard it
		and	do {
				$$token eq ''	# End of input: no hope
			and	do {
#DBG>				$debug & 0x10
#DBG>			and	print STDERR "**At eof: aborting.\n";
				return(undef);
			};

#DBG>			$debug & 0x10
#DBG>		and	print STDERR "**Dicard invalid token ".&$ShowCurToken.".\n";

			$$token=$$value=undef;
		};

        $$errstatus=3;

		while(	  @$stack
			  and (		not exists($$states[$$stack[-1][0]]{ACTIONS})
			        or  not exists($$states[$$stack[-1][0]]{ACTIONS}{error})
					or	$$states[$$stack[-1][0]]{ACTIONS}{error} <= 0)) {

#DBG>			$debug & 0x10
#DBG>		and	print STDERR "**Pop state $$stack[-1][0].\n";

			pop(@$stack);
		}

			@$stack
		or	do {

#DBG>			$debug & 0x10
#DBG>		and	print STDERR "**No state left on stack: aborting.\n";

			return(undef);
		};

		#shift the error token

#DBG>			$debug & 0x10
#DBG>		and	print STDERR "**Shift \$error token and go to state ".
#DBG>						 $$states[$$stack[-1][0]]{ACTIONS}{error}.
#DBG>						 ".\n";

		push(@$stack, [ $$states[$$stack[-1][0]]{ACTIONS}{error}, undef ]);

    }

    #never reached
	croak("Error in driver logic. Please, report it as a BUG");

}#_Parse
#DO NOT remove comment

1;

}
#End of include--------------------------------------------------


#line 10 "ppParser.yp"


# = HISTORY SECTION =====================================================================

# ---------------------------------------------------------------------------------------
# version | date     | author   | changes
# ---------------------------------------------------------------------------------------
# 0.28    |14.12.2000| JSTENZEL | made it finally backward compatible to perl 5.005 again;
# 0.27    |07.12.2000| JSTENZEL | moved package namespace from "PP" to "PerlPoint";
# 0.26    |30.11.2000| JSTENZEL | "Perl Point" => "PerlPoint";
#         |02.12.2000| JSTENZEL | bugfix in stackInput() which could remove input lines;
#         |          | JSTENZEL | new hedaline level offset keyword "current_level";
#         |03.12.2000| JSTENZEL | the parser now changes into a sourcefiles directory thus
#         |          |          | getting able to follow relative paths in nested sources;
#         |          | JSTENZEL | bugfix in input stack: must be multi levelled - we need
#         |          |          | one input stack per processed source!;
#         |          | JSTENZEL | cache data now contains headline level informations;
# 0.25    |22.11.2000| JSTENZEL | added notes about Storable updates;
#         |24.11.2000| JSTENZEL | bugfix in caching of embedded parts including empty lines;
#         |          | JSTENZEL | bugfix in modified ordered point intro handling;
#         |27.11.2000| JSTENZEL | bugfix in progress visualization;
#         |          | JSTENZEL | improved progress visualization;
#         |          | JSTENZEL | new experimental tag setting "\ACCEPT_ALL";
# 0.24    |10.11.2000| JSTENZEL | added incremental parsing ("caching");
#         |18.11.2000| JSTENZEL | slightly simplified the code;
#         |          | JSTENZEL | added ordered list continuations;
# 0.23    |28.10.2000| JSTENZEL | bugfix: indentation in embedded code was not accepted;
#         |          | JSTENZEL | using an input stack now for improved embedding;
#         |          | JSTENZEL | tracing active contents now;
# 0.22    |21.10.2000| JSTENZEL | new \INCLUDE headline offset parameter;
#         |25.10.2000| JSTENZEL | bugfixes in trace code;
#         |          | JSTENZEL | modified implementation of included file handling:
#         |          |          | reopening a handle did not work in all cases with perl5.6;
# 0.21    |11.10.2000| JSTENZEL | improved table paragraphs;
#         |14.10.2000| JSTENZEL | added alias/macro feature;
# 0.20    |10.10.2000| JSTENZEL | added table paragraphs;
# 0.19    |08.10.2000| JSTENZEL | added condition paragraphs;
#         |09.10.2000| JSTENZEL | bugfix in table handling: generated stream was wrong;
# 0.18    |05.10.2000| JSTENZEL | embedded Perl code is evaluated now, method run() takes
#         |          |          | a Safe object;
#         |07.10.2000| JSTENZEL | Perl code can now be included as well as embedded;
#         |          | JSTENZEL | variable values are now accessible by embedded and
#         |          |          | included Perl code;
#         |          | JSTENZEL | PerlPoint can now be embedded as well as included;
# 0.17    |04.10.2000| JSTENZEL | bugfix in documentation: colons have not to be guarded
#         |          |          | in definition texts;
#         |          | JSTENZEL | bugfixes in special token handling;
# 0.16    |30.09.2000| JSTENZEL | updated documentation;
#         |          | JSTENZEL | bugfix in special token handling;
#         |03.10.2000| JSTENZEL | definition list items can contain tags now;
#         |04.10.2000| JSTENZEL | added new target language filter feature;
# 0.15    |06.06.2000| JSTENZEL | there were still 5.6 specific operations, using
#         |          |          | IO::File now as an emulation under perl 5.005;
# 0.14    |03.06.2000| JSTENZEL | improved handling of special tag characters to simplify
#         |          |          | PP writing;
#         |          | JSTENZEL | bugfixes: stream contained trailing whitespaces for
#         |          |          | list points and headlines;
#         |          | JSTENZEL | bugfix: empty lines in verbatim blocks were not
#         |          |          | streamed;
#         |          | JSTENZEL | bugfix: stream contained leading newline for verbatim
#         |          |          | blocks;
#         |05.06.2000| JSTENZEL | switched back to 5.005 open() syntax to become compatible;
# 0.13    |01.06.2000| JSTENZEL | made it 5.003 compatible again;
# 0.12    |27.05.2000| JSTENZEL | leading spaces in list point lines are suppressed now;
#         |          | JSTENZEL | bugfix in run(): did not supply correct a return code;
#         |          | JSTENZEL | bugfix: last semantic action must be a true value to
#         |          |          | flag success (to the parser);
# 0.11    |20.05.2000| JSTENZEL | completed embedding feature;
#         |21.05.2000| JSTENZEL | bugfix in semantic error counting;
#         |          | JSTENZEL | added include feature;
#         |27.05.2000| JSTENZEL | added table feature (first version);
# 0.10    |17.04.2000| JSTENZEL | still incomplete embedding code added;
#         |03.05.2000| JSTENZEL | bugfix: verbatim block opener was added to stream
#         |          |          | because of the modified syntax (not completely impl.);
# 0.09    |11.04.2000| JSTENZEL | reorganized verbatim block start: spaces between "&"
#         |          |          | and "<<TERMINATOR" are no longer allowed, but text
#         |          |          | paragraphs with a startup "&" character are allowed now;
#         |          | JSTENZEL | added new paragraph type "definition list point";
#         |14.04.2000| JSTENZEL | streamed lists are embedded into list directives now;
#         |15.04.2000| JSTENZEL | modified syntax of verbatim blocks;
#         |          | JSTENZEL | added variables;
#         |          | JSTENZEL | modified tag syntax into "\TAG[{parlist}][<body>]";
# 0.08    |04.04.2000| JSTENZEL | started to implement the new pp2xy concept;
#         |07.04.2000| JSTENZEL | headlines are terminated by a REAL empty line now;
#         |          | JSTENZEL | old "points" became "unordered list points";
#         |          | JSTENZEL | added new paragraph type "ordered list point";
#         |08.04.2000| JSTENZEL | built in list shifting;
#         |09.04.2000| JSTENZEL | bugfix in text paragraph rule;
#         |10.04.2000| JSTENZEL | blocks are combined now automatically unless there is an
#         |          |          | intermediate control paragraph;
# 0.07    |25.03.2000| JSTENZEL | tag length is now 1 to 8 characters (instead of 1 to 3);
#         |          | JSTENZEL | POD fixes;
#         |          | JSTENZEL | using CPAN id's in HOC now;
# 0.06    |24.02.2000| JSTENZEL | trailing whitespaces in input lines are now removed
#         |          |          | (except of newlines!);
# 0.05    |11.10.1999| JSTENZEL | bugfix: paragraphs generated array references;
#         |          | JSTENZEL | PP::Parser::Constants became PP::Constants;
#         |          | JSTENZEL | adapted POD to pod2text (needs more blank lines);
# 0.04    |09.10.1999| JSTENZEL | moved certain constants into PP::Parser::Constants;
#         |          | JSTENZEL | completed POD;
# 0.03    |08.10.1999| JSTENZEL | started to generate intermediate data;
#         |          | JSTENZEL | simplified array access;
#         |          | JSTENZEL | bugfixes;
#         |09.10.1999| JSTENZEL | added data generation;
#         |          | JSTENZEL | all messages are written in English now;
#         |          | JSTENZEL | tags are declared outside now;
#         |          | JSTENZEL | exported the script part;
#         |          | JSTENZEL | added statistics;
#         |          | JSTENZEL | added trace and display control;
# 0.02    |07.10.1999| JSTENZEL | added C tag;
#         |          | JSTENZEL | added comment traces;
#         |          | JSTENZEL | bugfixes;
#         |          | JSTENZEL | made it pass -w;
#         |          | JSTENZEL | new "verbatim" paragraph;
# 0.01    |28.09.1999| JSTENZEL | new.
# ---------------------------------------------------------------------------------------

# = POD SECTION =========================================================================

=head1 NAME

B<PerlPoint::Parser> - a PerlPoint Parser

=head1 VERSION

This manual describes version B<0.28>.

=head1 SYNOPSIS

  # load the module:
  use PerlPoint::Parser;

  # build the parser and run it
  # to get intermediate data in @stream
  my ($parser)=new PerlPoint::Parser;
  $parser->run(
               stream  => \@stream,
               tags    => \%tags,
               files   => \@files,
              );


=head1 DESCRIPTION

The PerlPoint format, initially designed by Tom Christiansen, is intended
to provide a simple and portable way to generate slides without the need of
a proprietary product. Slides can be prepared in a text editor of your choice,
generated on a any platform where you find perl, and presented by any browser
which can render the chosen output format.

To sum it up,
I<PerlPoint Software takes an ASCII text and transforms it into slides written in a certain document description language.>
This is, by tradition, usually HTML, but you may decide to use another format like
XML, SGML, TeX or whatever you want.

Well, this sounds fine, but how to build a translator which transforms ASCII
into the output format of your choice? Thats what B<PerlPoint::Parser> is made for.
It performs the first translation step by parsing ASCII and transforming it
into an intermediate stream format, which can be processed by a subsequently
called translator backend. By separating parsing and output generation we
get the flexibility to write as many backends as necessary by using the same
parser frontend for all translators.

B<PerlPoint::Parser> supports the complete I<GRAMMAR> with exception of I<certain>
tags. Tags I<are> supported the I<most common way>: the parser recognizes I<any>
tag which is declared by the author of a translator. This way the
parser can be used for various flavours of the PerlPoint language without
having to be modified. So, if there is a need of a certain new flag, it can
quickly be added without any change to B<PerlPoint::Parser>.

The following chapters describe the input format (I<GRAMMAR>) and the
generated stream format (I<STREAM FORMAT>). Finally, the class methods are
described to show you how to build a parser.


=head1 GRAMMAR

This chapter describes how a PerlPoint ASCII slide description has to be
formatted to pass B<PerlPoint::Parser> parsers.

I<Please note> that the input format does I<not> completely determine how
the output will be designed. The final I<format> depends on the backend
which has to be called after the parser to transform its output into a
certain document description language. The final I<appearance> depends on
the I<browsers> behaviour.

Each PerlPoint document is made of I<paragraphs>.

=head2 The paragraphs

All paragraphs start at the beginning of their first line. The first character
or string in this line determines which paragraph is recognized.

A paragraph is completed by an empty line (which may contain whitespaces).
Exceptions are described.

Carriage returns in paragraphs which are completed by an empty line
are transformed into a whitespace

=over 4

=item Comments

start with "//" and reach until the end of the line.


=item Headlines

start with one or more  "=" characters.
The number of "=" characters represents the headline level.

  =First level headline

  ==Second level headline

  ===Multi
    line
   headline
  example


=item Lists

B<Points> or B<unordered lists> start with a "*" character.

  * This is a first point.

  * And, I forgot,
    there is something more to point out.

There are B<ordered lists> as well, and I<they> start with a hash sign ("#"):

  # First, check the number of this.

  # Second, don't forget the first.

The hash signs are intended to be replaced by numbers by a backend.

Because PerlPoint works on base of paragraphs, any paragraph different to
an ordered list point I<closes an ordered list>. If you wish the list to
be continued use a double hash sign in case of the single one in the point
that reopens the list.

  # Here the ordered list begins.

  ? $includeMore

  ## This is point 2 of the list that started before.

  # In subsequent points, the usual single hash sign works as
    expected again.

List continuation works list level specific (see below for level details).
A list cannot be continued in another chapter. Using "##" in the first
point of a new list takes no special effect: the list will begin as usual
(with number 1).

B<Definition lists> are a third list variant. Each item starts with the
described phrase enclosed by a pair of colons, followed by the definition
text:

  :first things: are usually described first,

  :others:       later then.

All lists can be I<nested>. A new level is introduced by
a special paragraph called I<"list indention"> which starts with a ">". A list level
can be terminated by a I<"list indention stop"> paragraph containing of a "<"
character. (These startup characters symbolize "level shifts".)

  * First level.

  * Still there.

>

  * A list point of the 2nd level.

<

  * Back on first level.


Level shifts are accepted between list items I<only>.


=item Texts

are paragraphs like points but begin I<immediatly> without a startup
character:

  This is a simple text.

  In this new text paragraph,
  we demonstrate the multiline feature.


=item Blocks

are intended to contain examples or code I<with> tag recognition.
This means that the parser will discover embedded tags. On the other hand,
it means that one may have to escape ">" characters outside tags. Blocks
begin with an I<indentation> and are completed by the next empty line.

  * Look at these examples:

      A block.

      I<Another> block.
      Escape "\>".

  Examples completed.

Subsequent blocks are joined together automatically: the intermediate empty
lines which would usually complete a block are translated into real empty
lines I<within> the block. This makes it easier to integrate real code
sequences as one block, regardless of the empty lines included. However,
one may explicitly I<wish> to separate subsequent blocks and can do so
by delimiting them by a special control paragraph:

  * Separated subsequent blocks:

      The first block.

      -

      The second block.


=item Verbatim blocks

are similar to blocks in indentation but I<deactivate>
pattern recognition. That means the embedded text is not scanned for tags
and empty lines and may therefore remain as it was in its original place,
possibly a script.

These special blocks need a special syntax. They are realized as here documents.
Start with a here document clause flagging which string will close the "here document":

  <<EOC

    # compare
    $rc=3>2?4:5; # contains ">" which has not to be escaped;

  EOC


=item Tables

are supported as well, they start with an @ sign which is
followed by  the column delimiter:

  @|
   column 1   |   column 2   |  column 3
    aaa       |    bbb       |   ccc
    uuu       |    vvvv      |   www

There is also a more sophisticated way to describe tables, see the tag section below.


=item Conditions

start with a  "?" character. If active contents is enabled, the paragraph text
is evaluated as Perl code. The (boolean) evaluation result then determines if
subsequent PerlPoint is read and parsed. If the result is false, all subsequent
paragraphs until the next condition are I<skipped>.

This feature can be used to maintain various language versions of a presentation
in one source file:

  ? $language eq 'German'

Or you could enable parts of your document by date:

  ? time>$dateOfTalk

Please note that the condition code shares its variables with embedded and included
code.

To make usage easier and to improve readability, condition code is evaluated with
disabled warnings (the language variable in the example above may not even been set).

Translator authors might want to provide predefined variables such as "$language"
in the example.


=item Variable assignment paragraphs

Variables can be used in the text and will be automatically replaced by their string
values (if declared).

  The next paragraph sets a variable.

  $var=var

  This variable is called $var.

All variables are made available to embedded and included Perl code as well as to
conditions and can be accessed there as package variables of "main::". Because a
variable is already replaced by the parser if possible, you have to use the fully
qualified name or to guard the variables "$" prefix character to do so:

  \EMBED{lang=perl}join(' ', $main::var, \$var)\END_EMBED

Variable modifications by embedded or included Perl I<do not> affect the variables
visible to the parser. (This is true for conditions as well.) This means that

  $var=10
  \EMBED{lang=perl}$main::var*=2;\END_EMBED

causes I<$var> to be different on parser and code side - the parser will still use a
value of 10, while embedded code works on with a value of 20.

=item Macro or alias definitions

Sometimes certain text parts are used more than once. It would be a relieve
to have a shortcut instead of having to insert them again and again. The same
is true for tag combinations a user may prefer to use. That's what I<aliases>
(or "macros") are designed for. They allow a presentation author to declare
his own shortcuts and to use them like a tag. The parser will resolve such aliases,
replace them by the defined replacement text and work on with this replacement.

An alias declaration starts with a "+" character followed I<immediately> by the
alias I<name> (without backslash prefix), followed I<immediately> by a colon.
(No additional spaces here.)
I<All text after this colon up to the paragraph closing empty line is stored as the replacement text.>
So, whereever you will
use the new macro, the parser will replace it by this text and I<reparse> the result.
This means that your macro text can contain any valid construction like tags or
other macros.

The replacement text may contain strings embedded into doubled underscores like
"__this__". This is a special syntax to mark that the macro takes parameters
of these names (e.g. "this"). If a tag is used and these parameters are set,
their values will replace the mentioned placeholders. The special placeholder
"__body__" is used to mark the place where the macro body is to place.

Here are a few examples:

  +RED:\FONT{color=red}<__body__>

  +F:\FONT{color=__c__}<__body__>

  +IB:\B<\I<__body__>>

  This \IB<text> is \RED<colored>.

  +TEXT:Macros can be used to abbreviate longer
  texts as well as other tags
  or tag combinations.

  +HTML:\EMBED{lang=html}

  Tags can be \RED<\I<nested>> into macros. And \I<\F{c=blue}<vice versa>>.
  \IB<\RED<This>> is formatted by nested macros.
  \HTML This is <i>embedded HTML</i>\END_EMBED.

  Please note: \TEXT

An I<empty> macro text I<undefines> the macro (if it was already known).

  // undeclare the IB alias
  +IB:

Please note that the current implementation is still called experimental because
there may be still untested cases.

An alias can be used like a tag.

=back

=head2 Tags

Tags are directives embedded into the text stream, commanding how certain parts
of the text should be interpreted.

B<PerlPoint::Parser> parsers can recognize all tags which are build of a backslash
and a number of alphanumeric characters (usually capitals).

  \TAG

I<Tag options> are optional and follow the tag name immediately, enclosed
by a pair of corresponding curly braces. Each option is a simple string
assignment. The value should be quoted if /^\w+$/ does not match it.

  \TAG{par1=value1 par2="www.perl.com" par3="words and blanks"}

The I<tag body> is anything you want to make the tag valid for. It is optional
as well and immediately follows the optional parameters, enclosed by "<" and ">":

  \TAG<body>
  \TAG{par=value}<body>

Tags can be I<nested>.

To provide a maximum of flexibility, tags are declared I<outside> the parser.
This way a translator programmer is free to implement the tags he needs. It is
recommended to always support the basic tags I<\I>, I<\B>, I<\C> and I<\IMAGE>. On the other
hand,a few tags of special meaning are reserved and cannot be declared by
users, because they are handled by the parser itself. These are:

=over 4

=item \INCLUDE

It is possible to include a file into the input stream. Have a look:

 \INCLUDE{type=HTML file=filename}

This imports the file "filename". The file contents is made part of the
generated stream, but not parsed. This is useful to include target language
specific, preformatted parts.

If, however, the file type is specified as "PP", the file contents is
made part of the input stream and parsed. In this case a special tag option
"headlinebase" can be specified to define a headline base level used as
an offset to all headlines in the included document. This makes it easier
to share partial documents with others, or to build complex documents by
including seperately maintained parts, or to include one and the same
part at different headline levels.

 Example: If "\INCLUDE{type=PP file=file headlinebase=20}" is
          specified and "file" contains a one level headline
          like "=Main topic of special explanations"
          this headline is detected with a level of 21.

Pass the special keyword "CURRENT_LEVEL" to this tag option if you want to
set just the I<current> headline level as an offset. This results in
"subchapters".

 Example:

 ===Headline 3

 \INCLUDE{type=PP file=file headlinebase=CURRENT_LEVEL}

A given offset is reset when the included document is parsed completely.

A PerlPoint file can be included wherever a tag is allowed, but sometimes
it has to be arranged slightly: if you place the inclusion directive at
the beginning of a new paragraph I<and> your included PerlPoint starts by
a paragraph of another type than text, you should begin the included file
by an empty line to let the parser detect the correct paragraph type. Here
is an example: if the inclusion directive is placed like

  // include PerlPoint
  \INCLUDE{type=pp file="file.pp"}

and file.pp immediately starts with a verbatim block like

  <<VERBATIM
      verbatim
  VERBATIM

, I<the inclusion directive already opens a new paragraph> which is detected to
be "text" (because there is no special startup character). Now in the included
file, from the parsers point of view the included PerlPoint is simply a
continuation of this text, because a paragraph ends with an empty line. This
trouble can be avoided by beginning such an included file by an empty line,
so that its first paragraph can be detected correctly.

The second special case is a file type of "Perl". If active contents is enabled,
included Perl code is read into memory and evaluated like I<embedded> Perl. The
results are made part of the input stream to be parsed.

It is possible to filter the file types you wish to include (with exception
of "PP"), see below for details. I<In any case>, the mentioned file has to
exist.


=item \EMBED and \END_EMBED

Target format code does not necessarily need to be imported - it can be
directly I<embedded> as well. This means that one can write target language
code within the input stream using I<\EMBED>:

  \EMBED{lang=HTML}
  This is <i><b>embedded</b> HTML</i>. The parser detects <i>no</i>
  PerlPoint tag here, except of <b>END_EMBED</b>.
  \END_EMBED

Because this is handled by I<tags>, not by paragraphs, it can be placed
directly in a text like this:

  These \EMBED{lang=HTML}<i>italics</i>\END_EMBED are formatted
  by HTML code.

Please note that the EMBED tag does not accept a tag body to avoid
ambigities.

Both tag and embedded text are made part of the intermediate stream.
It is the backends task to deal with it. The only exception of this rule
is the embedding of I<Perl> code, which is evaluated by the parser.
The reply of this code is made part of the input stream and parsed as
usual.

It is possible to filter the languages you wish to embed (with exception
of "PP"), see below for details.


=item \TABLE and \END_TABLE

It was mentioned above that tables can be build by table paragraphs.
Well, there is a tag variant of this:

  \TABLE{bg=blue separator="|" border=2}
  \B<column 1>  |  \B<column 2>  | \B<column 3>
     aaaa       |     bbbb       |  cccc
     uuuu       |     vvvv       |  wwww
  \END_TABLE

This is sligthly more powerfull than the paragraph syntax: you can set
up several table features like the border width yourself, and you can
format the headlines as you like.

=back


=head2 What about special formatting?

Earlier versions of B<pp2html> supported special format hints like the HTML
expression "&gt;" for the ">" character, or "&uuml;" for "ü". B<PerlPoint::Parser>
does I<not> support this directly because such hints are specific to the
I<output format> - if someone wants to translate into TeX, it might be curious
for him to use HTML syntax in his ASCII text. Further more, such hints can be
handled I<completely> by a backend which finds them unchanged in the produced
output stream.

The same is true for special headers and trailers. It is a I<backend> task to
add them if necessary. The parser does handle the I<input> only.

  
=head1 STREAM FORMAT

It is suggested to use B<PerlPoint::Backend> to evaluate the intermediate format.
Nevertheless, here is the documentation of this format.

The generated stream is an array of tokens. Most of them are very simple
representing just their contents - words, spaces and so on. Example:

  "These three words."

would be streamed into

  "These" + " " + "three" + " "+ "words."

Note that the final dot I<is part> of the last token. From a document
description view, this should make no difference, its just a string containing
special characters or not.

Well, besides this "main stream", there are I<formatting directives>. They
flag the I<beginning> or I<completion> of a certain format - this means a
whole document, a paragraph or a real formatting like italicising. I<Every>
format is I<embedded> into a start I<and> a completion directive - except
of simple tokens.

In the current implementation, a directive is a reference to an array of mostly
two fields: a directive constant showing which format is related, and a start
or completion hint, which is a constant, too. The used constants are declared in
B<PerlPoint::Constants>. Directives can pass additional informations in additional
fields. By now, the headline directives use this feature to show the headline
level, as well as the tag ones to provide tag type information and the document ones
to keep the name of the original document. Further more, ordered list point I<can>
request a fix number this way.

  # this example shows a tag directive
  ... [DIRECTIVE_TAG, DIRECTIVE_START, "I"]
  + "formatted" + " " + "strings"
  + [DIRECTIVE_TAG, DIRECTIVE_COMPLETE, "I"] ...

To recognize whether a token is a basic or a directive, the ref() function can be
used. However, this handling should be done by B<PerlPoint::Backend> transparently and is
documented here for information purposes only.

Original line numbers are no part of the stream.

This is the complete generator format. It is designed to be simple but powerful.


=head1 METHODS

=head2 new()

The constructor builds and prepares a new parser object.

B<Parameters:>

=over 4

=item The class name.

=back

B<Return value:>
The new object in case of success.

B<Example:>

  my ($parser)=new PerlPoint::Parser;

=cut

# = CODE SECTION ========================================================================

 # startup actions
 BEGIN
  {
   # declare startup helper function
   sub startupGenerateConstants
     {
      # init counter
      my $c=0;

      # and generate constants
      foreach my $constant (@_)
	{eval "use constant $constant => $c"; $c++;}
     }

   # declare internal constants: action timeout types (used as array indices, sort alphabetically!)
   startupGenerateConstants(
                            'LEXER_TOKEN',     # reply symbols token;
                            'LEXER_FATAL',     # bug: unexpected symbol;
                            'LEXER_IGNORE',    # ignore this symbol;
                            'LEXER_EMPTYLINE', # reply the token "Empty_line";
                            'LEXER_SPACE',     # reply the token "Space" and a simple whitespace;
                           );

   # state constants
   startupGenerateConstants(
                            'STATE_DEFAULT',   # default;
                            'STATE_DEFAULT_TAGMODE', # default in tag mode;

                            'STATE_BLOCK',     # block;
                            'STATE_COMMENT',   # comment;
                            'STATE_CONTROL',   # control paragraph (of a single character);
                            'STATE_DPOINT',    # definition list point;
                            'STATE_DPOINT_ITEM', # definition list point item (defined stuff);
                            'STATE_EMBEDDING', # embedded things (HTML, Perl, ...);
                            'STATE_HEADLINE',  # headline;
                            'STATE_OPOINT',    # ordered list point;
                            'STATE_TEXT',      # text;
                            'STATE_UPOINT',    # unordered list point;
                            'STATE_VERBATIM',  # verbatim block;
                            'STATE_TABLE',     # table *paragraph*;
                            'STATE_DEFINITION', # macro definition;
                           );

   # declare internal constants: list shifters
   startupGenerateConstants(
                            'LIST_SHIFT_RIGHT',# shift right;
                            'LIST_SHIFT_LEFT', # shift left;
                           );

   # release memory
   undef &startupGenerateConstants;
  }

 # requires modern perl
 require 5.00503;

 # declare module version
 {
  no strict 'refs';
  ${join('::', __PACKAGE__, 'VERSION')}=0.28;
  ${join('::', __PACKAGE__, 'VERSION')}=${join('::', __PACKAGE__, 'VERSION')}; # to suppress a warning of exclusive usage only;
 }

 # load modules
 use Cwd;
 use Carp;
 use IO::File;
 use PerlPoint::Backend;
 use File::Basename;
 use PerlPoint::Constants 0.09;
 use Digest::SHA1 qw(sha1_base64);
 use Storable qw(:DEFAULT dclone);

 # startup declarations
 my (
     %data,                        # the collected declaration data;
     %lineNrs,                     # the lexers line number hash, input handle specific;
     %specials,                    # special character control (may be active or not);
     %lexerFlags,                  # lexer state flags;
     %statistics,                  # statitics data;
     %variables,                   # user managed variables;
     %flags,                       # various flags;
     %macros,                      # macros / aliases;
     %openedSourcefiles,           # a list of all already opened source files (to avoid circular nesting);

     @specialStack,                # special state stack for temporary activations (to restore original states);
     @stateStack,                  # state stack (mostly intended for non paragraph states like STATE_EMBEDDED);
     @tableSeparatorStack,         # the first element is the column separator string within a table, empty otherwise;
     @inputStack,                  # a stack of additional input lines;
     @inHandles,                   # a stack of input handles (to manage nested sources);
     @olistLevels,                 # a hint storing the last recent ordered list level number of a paragraph (hyrarchically);

     $safeObject,                  # an object of class Safe to evaluate Perl code embedded into PerlPoint;
     $sourceFile,                  # the source file currently read;
     $tagsRef,                     # reference to a hash of valid tag openers (strings without the "<");
     $resultStreamRef,             # reference to an array to put generated stream data in;
     $inHandle,                    # the data input stream (to parse);
     $parserState,                 # the current parser state;
     $readCompletely,              # the input file is read completely;
     $semErr,                      # semantic error counter;
     $tableColumns,                # counter of completed table columns;
     $checksums,		   # paragraph checksums (and associated stream parts);
    );

 # ----- Startup code begins here. -----

 # prepare main input handle (obsolete when all people will use perl 5.6)
 $inHandle=new IO::File;

 # set developer data
 my ($developerName, $developer)=('J. Stenzel', 'perl@jochen-stenzel.de');

 # init flag
 $readCompletely=0;

 # declare paragraphs which are embedded
 my %embeddedParagraphs;
 @embeddedParagraphs{
                     DIRECTIVE_UPOINT,
                     DIRECTIVE_OPOINT,
                    }=();

 # build a reverse engineering backend
 my $reversedInput='';
 my $reverseStream=new PerlPoint::Backend(
                                          name    => 'reverse engineering',
                                          trace   => TRACE_NOTHING,
                                          display => DISPLAY_NOINFO,
                                         );

 # register a complete set of backend handlers (please note that the usage of the "&" prefix
 # before the tag constants is essentiell to make them usabel later - I do not know if this
 # is a bug of perl 5.6 or anything else but it looks really buggy)
 $reverseStream->register(&DIRECTIVE_BLOCK, \&reverseUnexpected);
 $reverseStream->register(&DIRECTIVE_COMMENT, \&reverseUnexpected);
 $reverseStream->register(&DIRECTIVE_DOCUMENT, \&reverseUnexpected);
 $reverseStream->register(&DIRECTIVE_DPOINT, \&reverseUnexpected);
 $reverseStream->register(&DIRECTIVE_HEADLINE, \&reverseUnexpected);
 $reverseStream->register(&DIRECTIVE_LIST_LSHIFT, \&reverseUnexpected);
 $reverseStream->register(&DIRECTIVE_LIST_RSHIFT, \&reverseUnexpected);
 $reverseStream->register(&DIRECTIVE_OPOINT, \&reverseUnexpected);
 $reverseStream->register(&DIRECTIVE_TAG, \&reverseTag);
 $reverseStream->register(&DIRECTIVE_TEXT, \&reverseUnexpected);
 $reverseStream->register(&DIRECTIVE_UPOINT, \&reverseUnexpected);
 $reverseStream->register(&DIRECTIVE_VERBATIM, \&reverseUnexpected);
 $reverseStream->register(&DIRECTIVE_SIMPLE, \&reverseSimple);




sub new {
        my($class)=shift;
        ref($class)
    and $class=ref($class);

    my($self)=$class->SUPER::new( yyversion => '1.01',
                                  yystates =>
[
	{#State 0
		ACTIONS => {
			'EOL' => 3,
			"\@" => 1,
			"#" => 38,
			'Block_cache_hit' => 39,
			'Named_variable' => 7,
			'Colon' => 10,
			'Symbolic_variable' => 42,
			'Upoint_cache_hit' => 45,
			'Embed' => 14,
			'Ils' => 15,
			'Opoint_cache_hit' => 16,
			'Empty_line' => 18,
			"*" => 21,
			'Include' => 23,
			'Table_separator' => 24,
			"+" => 47,
			'Headline_cache_hit' => 49,
			'Heredoc_open' => 50,
			'Table' => 27,
			"=" => 28,
			'Paragraph_cache_hit' => 53,
			'Space' => 55,
			"/" => 56,
			'Word' => 30,
			'Tag_name' => 57,
			"?" => 32,
			'Dpoint_cache_hit' => 33
		},
		GOTOS => {
			'included' => 2,
			'olist' => 4,
			'headline' => 35,
			'verbatim' => 5,
			'dpoint' => 6,
			'opoint' => 37,
			'list_part' => 36,
			'block' => 40,
			'opoint_opener' => 8,
			'upoint' => 9,
			'dlist' => 11,
			'embedded' => 41,
			'basic' => 12,
			'tag' => 43,
			'element' => 13,
			'paragraph' => 44,
			'condition' => 17,
			'document' => 46,
			'text' => 19,
			'list' => 20,
			'table_paragraph' => 22,
			'headline_level' => 25,
			'table_separator' => 48,
			'compound_block' => 51,
			'alias_definition' => 26,
			'comment' => 29,
			'variable_assignment' => 54,
			'table' => 52,
			'literal' => 31,
			'dlist_opener' => 58,
			'ulist' => 34
		}
	},
	{#State 1
		DEFAULT => -118,
		GOTOS => {
			'@20-1' => 59
		}
	},
	{#State 2
		DEFAULT => -94
	},
	{#State 3
		DEFAULT => -78
	},
	{#State 4
		ACTIONS => {
			"#" => 38,
			'Opoint_cache_hit' => 16
		},
		DEFAULT => -25,
		GOTOS => {
			'opoint_opener' => 8,
			'opoint' => 60
		}
	},
	{#State 5
		DEFAULT => -7
	},
	{#State 6
		DEFAULT => -32
	},
	{#State 7
		ACTIONS => {
			"=" => 61
		},
		DEFAULT => -90
	},
	{#State 8
		DEFAULT => -34,
		GOTOS => {
			'@3-1' => 62
		}
	},
	{#State 9
		DEFAULT => -30
	},
	{#State 10
		DEFAULT => -45,
		GOTOS => {
			'@6-1' => 63
		}
	},
	{#State 11
		ACTIONS => {
			'Colon' => 10,
			'Dpoint_cache_hit' => 33
		},
		DEFAULT => -27,
		GOTOS => {
			'dpoint' => 64,
			'dlist_opener' => 58
		}
	},
	{#State 12
		DEFAULT => -77
	},
	{#State 13
		DEFAULT => -83
	},
	{#State 14
		DEFAULT => -121,
		GOTOS => {
			'@22-1' => 65
		}
	},
	{#State 15
		DEFAULT => -52,
		GOTOS => {
			'@8-1' => 66
		}
	},
	{#State 16
		DEFAULT => -36
	},
	{#State 17
		DEFAULT => -10
	},
	{#State 18
		DEFAULT => -13
	},
	{#State 19
		DEFAULT => -5
	},
	{#State 20
		ACTIONS => {
			"#" => 38,
			'Colon' => 10,
			'Opoint_cache_hit' => 16,
			'Upoint_cache_hit' => 45,
			"*" => 21,
			"<" => 70,
			">" => 71,
			'Dpoint_cache_hit' => 33
		},
		DEFAULT => -4,
		GOTOS => {
			'olist' => 4,
			'list_shift' => 68,
			'dpoint' => 6,
			'list_part' => 69,
			'opoint' => 37,
			'list_shifter' => 67,
			'opoint_opener' => 8,
			'upoint' => 9,
			'dlist' => 11,
			'dlist_opener' => 58,
			'ulist' => 34
		}
	},
	{#State 21
		DEFAULT => -39,
		GOTOS => {
			'@4-1' => 72
		}
	},
	{#State 22
		DEFAULT => -11
	},
	{#State 23
		DEFAULT => -124,
		GOTOS => {
			'@24-1' => 73
		}
	},
	{#State 24
		DEFAULT => -117
	},
	{#State 25
		ACTIONS => {
			"=" => 74
		},
		DEFAULT => -15,
		GOTOS => {
			'@1-1' => 75
		}
	},
	{#State 26
		DEFAULT => -12
	},
	{#State 27
		DEFAULT => -114,
		GOTOS => {
			'@18-1' => 76
		}
	},
	{#State 28
		DEFAULT => -18
	},
	{#State 29
		DEFAULT => -9
	},
	{#State 30
		DEFAULT => -88
	},
	{#State 31
		DEFAULT => -55,
		GOTOS => {
			'@9-1' => 77
		}
	},
	{#State 32
		DEFAULT => -20,
		GOTOS => {
			'@2-1' => 78
		}
	},
	{#State 33
		DEFAULT => -44
	},
	{#State 34
		ACTIONS => {
			'Upoint_cache_hit' => 45,
			"*" => 21
		},
		DEFAULT => -26,
		GOTOS => {
			'upoint' => 79
		}
	},
	{#State 35
		DEFAULT => -3
	},
	{#State 36
		DEFAULT => -22
	},
	{#State 37
		DEFAULT => -28
	},
	{#State 38
		ACTIONS => {
			"#" => 80
		},
		DEFAULT => -37
	},
	{#State 39
		DEFAULT => -54
	},
	{#State 40
		DEFAULT => -47
	},
	{#State 41
		DEFAULT => -93
	},
	{#State 42
		DEFAULT => -91
	},
	{#State 43
		DEFAULT => -92
	},
	{#State 44
		DEFAULT => -1
	},
	{#State 45
		DEFAULT => -41
	},
	{#State 46
		ACTIONS => {
			'' => 81,
			'EOL' => 3,
			"\@" => 1,
			"#" => 38,
			'Block_cache_hit' => 39,
			'Named_variable' => 7,
			'Colon' => 10,
			'Symbolic_variable' => 42,
			'Upoint_cache_hit' => 45,
			'Embed' => 14,
			'Ils' => 15,
			'Opoint_cache_hit' => 16,
			'Empty_line' => 18,
			"*" => 21,
			'Include' => 23,
			'Table_separator' => 24,
			"+" => 47,
			'Headline_cache_hit' => 49,
			'Heredoc_open' => 50,
			'Table' => 27,
			"=" => 28,
			'Paragraph_cache_hit' => 53,
			'Space' => 55,
			"/" => 56,
			'Word' => 30,
			'Tag_name' => 57,
			"?" => 32,
			'Dpoint_cache_hit' => 33
		},
		GOTOS => {
			'included' => 2,
			'olist' => 4,
			'headline' => 35,
			'verbatim' => 5,
			'dpoint' => 6,
			'list_part' => 36,
			'opoint' => 37,
			'block' => 40,
			'opoint_opener' => 8,
			'upoint' => 9,
			'dlist' => 11,
			'embedded' => 41,
			'basic' => 12,
			'tag' => 43,
			'element' => 13,
			'paragraph' => 82,
			'condition' => 17,
			'text' => 19,
			'list' => 20,
			'table_paragraph' => 22,
			'headline_level' => 25,
			'table_separator' => 48,
			'compound_block' => 51,
			'alias_definition' => 26,
			'comment' => 29,
			'variable_assignment' => 54,
			'table' => 52,
			'literal' => 31,
			'dlist_opener' => 58,
			'ulist' => 34
		}
	},
	{#State 47
		DEFAULT => -126,
		GOTOS => {
			'@25-1' => 83
		}
	},
	{#State 48
		DEFAULT => -85
	},
	{#State 49
		DEFAULT => -17
	},
	{#State 50
		DEFAULT => -57,
		GOTOS => {
			'@10-1' => 84
		}
	},
	{#State 51
		ACTIONS => {
			'Block_cache_hit' => 39,
			'Ils' => 15,
			"-" => 87
		},
		DEFAULT => -6,
		GOTOS => {
			'block' => 86,
			'block_flagnew' => 85
		}
	},
	{#State 52
		DEFAULT => -84
	},
	{#State 53
		DEFAULT => -14
	},
	{#State 54
		DEFAULT => -8
	},
	{#State 55
		DEFAULT => -89
	},
	{#State 56
		ACTIONS => {
			"/" => 88
		}
	},
	{#State 57
		DEFAULT => -99,
		GOTOS => {
			'@14-1' => 89
		}
	},
	{#State 58
		DEFAULT => -42,
		GOTOS => {
			'@5-1' => 90
		}
	},
	{#State 59
		ACTIONS => {
			'Word' => 91
		},
		GOTOS => {
			'words' => 92
		}
	},
	{#State 60
		DEFAULT => -29
	},
	{#State 61
		ACTIONS => {
			'EOL' => 3,
			'Table_separator' => 24,
			'Include' => 23,
			'Named_variable' => 93,
			'Table' => 27,
			'Symbolic_variable' => 42,
			'Space' => 55,
			'Word' => 30,
			'Tag_name' => 57,
			'Embed' => 14
		},
		GOTOS => {
			'included' => 2,
			'text' => 94,
			'table' => 52,
			'embedded' => 41,
			'basic' => 12,
			'table_separator' => 48,
			'literal' => 31,
			'tag' => 43,
			'element' => 13
		}
	},
	{#State 62
		ACTIONS => {
			'EOL' => 3,
			'Table_separator' => 24,
			'Include' => 23,
			'Named_variable' => 93,
			'Table' => 27,
			'Symbolic_variable' => 42,
			'Space' => 55,
			'Word' => 30,
			'Tag_name' => 57,
			'Embed' => 14
		},
		GOTOS => {
			'included' => 2,
			'text' => 95,
			'table' => 52,
			'embedded' => 41,
			'basic' => 12,
			'table_separator' => 48,
			'literal' => 31,
			'tag' => 43,
			'element' => 13
		}
	},
	{#State 63
		ACTIONS => {
			'Symbolic_variable' => 42,
			'Space' => 55,
			'Include' => 23,
			'Word' => 30,
			'Tag_name' => 57,
			'Named_variable' => 93,
			'Embed' => 14
		},
		GOTOS => {
			'included' => 2,
			'embedded' => 41,
			'tag' => 43,
			'elements' => 97,
			'element' => 96
		}
	},
	{#State 64
		DEFAULT => -33
	},
	{#State 65
		ACTIONS => {
			"{" => 98
		},
		GOTOS => {
			'used_tagpars' => 99
		}
	},
	{#State 66
		ACTIONS => {
			'EOL' => 3,
			'Table_separator' => 24,
			'Include' => 23,
			'Named_variable' => 93,
			'Table' => 27,
			'Symbolic_variable' => 42,
			'Space' => 55,
			'Word' => 30,
			'Tag_name' => 57,
			'Embed' => 14
		},
		GOTOS => {
			'included' => 2,
			'text' => 100,
			'table' => 52,
			'embedded' => 41,
			'basic' => 12,
			'table_separator' => 48,
			'literal' => 31,
			'tag' => 43,
			'element' => 13
		}
	},
	{#State 67
		DEFAULT => -62,
		GOTOS => {
			'@12-1' => 101
		}
	},
	{#State 68
		ACTIONS => {
			'Colon' => 10,
			"*" => 21,
			"#" => 38,
			'Upoint_cache_hit' => 45,
			'Dpoint_cache_hit' => 33,
			'Opoint_cache_hit' => 16
		},
		GOTOS => {
			'olist' => 4,
			'dpoint' => 6,
			'list_part' => 102,
			'opoint' => 37,
			'opoint_opener' => 8,
			'upoint' => 9,
			'dlist' => 11,
			'dlist_opener' => 58,
			'ulist' => 34
		}
	},
	{#State 69
		DEFAULT => -23
	},
	{#State 70
		DEFAULT => -66
	},
	{#State 71
		DEFAULT => -65
	},
	{#State 72
		ACTIONS => {
			'EOL' => 3,
			'Table_separator' => 24,
			'Include' => 23,
			'Named_variable' => 93,
			'Table' => 27,
			'Symbolic_variable' => 42,
			'Space' => 55,
			'Word' => 30,
			'Tag_name' => 57,
			'Embed' => 14
		},
		GOTOS => {
			'included' => 2,
			'text' => 103,
			'table' => 52,
			'embedded' => 41,
			'basic' => 12,
			'table_separator' => 48,
			'literal' => 31,
			'tag' => 43,
			'element' => 13
		}
	},
	{#State 73
		ACTIONS => {
			"{" => 98
		},
		GOTOS => {
			'used_tagpars' => 104
		}
	},
	{#State 74
		DEFAULT => -19
	},
	{#State 75
		ACTIONS => {
			'Table' => 27,
			'Symbolic_variable' => 42,
			'Space' => 55,
			'Table_separator' => 24,
			'Include' => 23,
			'Word' => 30,
			'Tag_name' => 57,
			'Named_variable' => 93,
			'Embed' => 14
		},
		GOTOS => {
			'included' => 2,
			'table' => 52,
			'embedded' => 41,
			'basic' => 106,
			'basics' => 105,
			'table_separator' => 48,
			'tag' => 43,
			'element' => 13
		}
	},
	{#State 76
		ACTIONS => {
			"{" => 98
		},
		GOTOS => {
			'used_tagpars' => 107
		}
	},
	{#State 77
		ACTIONS => {
			'EOL' => 3,
			'Table_separator' => 24,
			'Include' => 23,
			'Named_variable' => 93,
			'Table' => 27,
			'Symbolic_variable' => 42,
			'Space' => 55,
			'Word' => 30,
			'Tag_name' => 57,
			'Embed' => 14
		},
		DEFAULT => -67,
		GOTOS => {
			'included' => 2,
			'literals' => 108,
			'table' => 52,
			'embedded' => 41,
			'basic' => 12,
			'table_separator' => 48,
			'literal' => 110,
			'optional_literals' => 109,
			'tag' => 43,
			'element' => 13
		}
	},
	{#State 78
		ACTIONS => {
			'Table' => 27,
			'Symbolic_variable' => 42,
			'Space' => 55,
			'Table_separator' => 24,
			'Include' => 23,
			'Word' => 30,
			'Tag_name' => 57,
			'Named_variable' => 93,
			'Embed' => 14
		},
		GOTOS => {
			'included' => 2,
			'table' => 52,
			'embedded' => 41,
			'basic' => 106,
			'basics' => 111,
			'table_separator' => 48,
			'tag' => 43,
			'element' => 13
		}
	},
	{#State 79
		DEFAULT => -31
	},
	{#State 80
		DEFAULT => -38
	},
	{#State 81
		DEFAULT => -0
	},
	{#State 82
		DEFAULT => -2
	},
	{#State 83
		ACTIONS => {
			'Word' => 112
		}
	},
	{#State 84
		ACTIONS => {
			'Empty_line' => 113,
			'EOL' => 3,
			'Table_separator' => 24,
			'Include' => 23,
			'Named_variable' => 93,
			'Table' => 27,
			'Symbolic_variable' => 42,
			'Space' => 55,
			'Word' => 30,
			'Tag_name' => 57,
			'Embed' => 14
		},
		GOTOS => {
			'included' => 2,
			'literals_and_empty_lines' => 115,
			'table' => 52,
			'embedded' => 41,
			'literal_or_empty_line' => 114,
			'basic' => 12,
			'table_separator' => 48,
			'literal' => 116,
			'tag' => 43,
			'element' => 13
		}
	},
	{#State 85
		ACTIONS => {
			'Block_cache_hit' => 39,
			'Ils' => 15
		},
		GOTOS => {
			'compound_block' => 117,
			'block' => 40
		}
	},
	{#State 86
		DEFAULT => -48
	},
	{#State 87
		DEFAULT => -50,
		GOTOS => {
			'@7-1' => 118
		}
	},
	{#State 88
		DEFAULT => -60,
		GOTOS => {
			'@11-2' => 119
		}
	},
	{#State 89
		ACTIONS => {
			"{" => 98
		},
		DEFAULT => -102,
		GOTOS => {
			'used_tagpars' => 121,
			'optional_tagpars' => 120
		}
	},
	{#State 90
		ACTIONS => {
			'EOL' => 3,
			'Table_separator' => 24,
			'Include' => 23,
			'Named_variable' => 93,
			'Table' => 27,
			'Symbolic_variable' => 42,
			'Space' => 55,
			'Word' => 30,
			'Tag_name' => 57,
			'Embed' => 14
		},
		GOTOS => {
			'included' => 2,
			'text' => 122,
			'table' => 52,
			'embedded' => 41,
			'basic' => 12,
			'table_separator' => 48,
			'literal' => 31,
			'tag' => 43,
			'element' => 13
		}
	},
	{#State 91
		DEFAULT => -97
	},
	{#State 92
		ACTIONS => {
			'Word' => 123
		},
		DEFAULT => -119,
		GOTOS => {
			'@21-3' => 124
		}
	},
	{#State 93
		DEFAULT => -90
	},
	{#State 94
		DEFAULT => -59
	},
	{#State 95
		DEFAULT => -35
	},
	{#State 96
		DEFAULT => -86
	},
	{#State 97
		ACTIONS => {
			'Colon' => 125,
			'Symbolic_variable' => 42,
			'Space' => 55,
			'Include' => 23,
			'Word' => 30,
			'Tag_name' => 57,
			'Named_variable' => 93,
			'Embed' => 14
		},
		GOTOS => {
			'included' => 2,
			'embedded' => 41,
			'tag' => 43,
			'element' => 126
		}
	},
	{#State 98
		DEFAULT => -104,
		GOTOS => {
			'@16-1' => 127
		}
	},
	{#State 99
		DEFAULT => -122,
		GOTOS => {
			'@23-3' => 128
		}
	},
	{#State 100
		DEFAULT => -53
	},
	{#State 101
		ACTIONS => {
			'Number' => 130
		},
		DEFAULT => -95,
		GOTOS => {
			'optional_number' => 129
		}
	},
	{#State 102
		DEFAULT => -24
	},
	{#State 103
		DEFAULT => -40
	},
	{#State 104
		DEFAULT => -125
	},
	{#State 105
		ACTIONS => {
			'Empty_line' => 132,
			'Table_separator' => 24,
			'Include' => 23,
			'Named_variable' => 93,
			'Table' => 27,
			'Symbolic_variable' => 42,
			'Space' => 55,
			'Word' => 30,
			'Tag_name' => 57,
			'Embed' => 14
		},
		GOTOS => {
			'included' => 2,
			'table' => 52,
			'embedded' => 41,
			'basic' => 131,
			'table_separator' => 48,
			'tag' => 43,
			'element' => 13
		}
	},
	{#State 106
		DEFAULT => -81
	},
	{#State 107
		DEFAULT => -115,
		GOTOS => {
			'@19-3' => 133
		}
	},
	{#State 108
		ACTIONS => {
			'EOL' => 3,
			'Table_separator' => 24,
			'Include' => 23,
			'Named_variable' => 93,
			'Table' => 27,
			'Symbolic_variable' => 42,
			'Space' => 55,
			'Word' => 30,
			'Tag_name' => 57,
			'Embed' => 14
		},
		DEFAULT => -68,
		GOTOS => {
			'included' => 2,
			'table' => 52,
			'embedded' => 41,
			'basic' => 12,
			'table_separator' => 48,
			'literal' => 134,
			'tag' => 43,
			'element' => 13
		}
	},
	{#State 109
		ACTIONS => {
			'Empty_line' => 135
		}
	},
	{#State 110
		DEFAULT => -69
	},
	{#State 111
		ACTIONS => {
			'Empty_line' => 136,
			'Table_separator' => 24,
			'Include' => 23,
			'Named_variable' => 93,
			'Table' => 27,
			'Symbolic_variable' => 42,
			'Space' => 55,
			'Word' => 30,
			'Tag_name' => 57,
			'Embed' => 14
		},
		GOTOS => {
			'included' => 2,
			'table' => 52,
			'embedded' => 41,
			'basic' => 131,
			'table_separator' => 48,
			'tag' => 43,
			'element' => 13
		}
	},
	{#State 112
		ACTIONS => {
			'Colon' => 137
		}
	},
	{#State 113
		DEFAULT => -76
	},
	{#State 114
		DEFAULT => -73
	},
	{#State 115
		ACTIONS => {
			'Empty_line' => 113,
			'EOL' => 3,
			'Table_separator' => 24,
			'Include' => 23,
			'Named_variable' => 93,
			'Heredoc_close' => 139,
			'Table' => 27,
			'Symbolic_variable' => 42,
			'Space' => 55,
			'Word' => 30,
			'Tag_name' => 57,
			'Embed' => 14
		},
		GOTOS => {
			'included' => 2,
			'table' => 52,
			'embedded' => 41,
			'literal_or_empty_line' => 138,
			'basic' => 12,
			'table_separator' => 48,
			'literal' => 116,
			'tag' => 43,
			'element' => 13
		}
	},
	{#State 116
		DEFAULT => -75
	},
	{#State 117
		ACTIONS => {
			'Block_cache_hit' => 39,
			'Ils' => 15,
			"-" => 87
		},
		DEFAULT => -49,
		GOTOS => {
			'block' => 86,
			'block_flagnew' => 85
		}
	},
	{#State 118
		ACTIONS => {
			'Empty_line' => 140
		}
	},
	{#State 119
		ACTIONS => {
			'Table_separator' => 24,
			'Include' => 23,
			'Named_variable' => 93,
			'Table' => 27,
			'Symbolic_variable' => 42,
			'Space' => 55,
			'Word' => 30,
			'Tag_name' => 57,
			'Embed' => 14
		},
		DEFAULT => -79,
		GOTOS => {
			'included' => 2,
			'basics' => 141,
			'table_separator' => 48,
			'optional_basics' => 142,
			'table' => 52,
			'embedded' => 41,
			'basic' => 106,
			'element' => 13,
			'tag' => 43
		}
	},
	{#State 120
		DEFAULT => -100,
		GOTOS => {
			'@15-3' => 143
		}
	},
	{#State 121
		DEFAULT => -103
	},
	{#State 122
		DEFAULT => -43
	},
	{#State 123
		DEFAULT => -98
	},
	{#State 124
		ACTIONS => {
			'EOL' => 3,
			'Table_separator' => 24,
			'Include' => 23,
			'Named_variable' => 93,
			'Table' => 27,
			'Symbolic_variable' => 42,
			'Space' => 55,
			'Word' => 30,
			'Tag_name' => 57,
			'Embed' => 14
		},
		DEFAULT => -67,
		GOTOS => {
			'included' => 2,
			'literals' => 108,
			'table' => 52,
			'embedded' => 41,
			'basic' => 12,
			'table_separator' => 48,
			'literal' => 110,
			'optional_literals' => 144,
			'tag' => 43,
			'element' => 13
		}
	},
	{#State 125
		DEFAULT => -46
	},
	{#State 126
		DEFAULT => -87
	},
	{#State 127
		ACTIONS => {
			'Word' => 146
		},
		GOTOS => {
			'tagpar' => 147,
			'tagpars' => 145
		}
	},
	{#State 128
		ACTIONS => {
			'Empty_line' => 113,
			'EOL' => 3,
			'Table_separator' => 24,
			'Include' => 23,
			'Named_variable' => 93,
			'Table' => 27,
			'Symbolic_variable' => 42,
			'Space' => 55,
			'Word' => 30,
			'Tag_name' => 57,
			'Embed' => 14
		},
		DEFAULT => -71,
		GOTOS => {
			'included' => 2,
			'literals_and_empty_lines' => 148,
			'table' => 52,
			'embedded' => 41,
			'literal_or_empty_line' => 114,
			'basic' => 12,
			'optional_literals_and_empty_lines' => 149,
			'table_separator' => 48,
			'literal' => 116,
			'tag' => 43,
			'element' => 13
		}
	},
	{#State 129
		DEFAULT => -63,
		GOTOS => {
			'@13-3' => 150
		}
	},
	{#State 130
		DEFAULT => -96
	},
	{#State 131
		DEFAULT => -82
	},
	{#State 132
		DEFAULT => -16
	},
	{#State 133
		ACTIONS => {
			'Empty_line' => 113,
			'EOL' => 3,
			'Table_separator' => 24,
			'Include' => 23,
			'Named_variable' => 93,
			'Table' => 27,
			'Symbolic_variable' => 42,
			'Space' => 55,
			'Word' => 30,
			'Tag_name' => 57,
			'Embed' => 14
		},
		DEFAULT => -71,
		GOTOS => {
			'included' => 2,
			'literals_and_empty_lines' => 148,
			'table' => 52,
			'embedded' => 41,
			'literal_or_empty_line' => 114,
			'basic' => 12,
			'optional_literals_and_empty_lines' => 151,
			'table_separator' => 48,
			'literal' => 116,
			'tag' => 43,
			'element' => 13
		}
	},
	{#State 134
		DEFAULT => -70
	},
	{#State 135
		DEFAULT => -56
	},
	{#State 136
		DEFAULT => -21
	},
	{#State 137
		DEFAULT => -127,
		GOTOS => {
			'@26-4' => 152
		}
	},
	{#State 138
		DEFAULT => -74
	},
	{#State 139
		DEFAULT => -58
	},
	{#State 140
		DEFAULT => -51
	},
	{#State 141
		ACTIONS => {
			'Table_separator' => 24,
			'Include' => 23,
			'Named_variable' => 93,
			'Table' => 27,
			'Symbolic_variable' => 42,
			'Space' => 55,
			'Word' => 30,
			'Tag_name' => 57,
			'Embed' => 14
		},
		DEFAULT => -80,
		GOTOS => {
			'included' => 2,
			'table' => 52,
			'embedded' => 41,
			'basic' => 131,
			'table_separator' => 48,
			'tag' => 43,
			'element' => 13
		}
	},
	{#State 142
		ACTIONS => {
			'Empty_line' => 153
		}
	},
	{#State 143
		ACTIONS => {
			"<" => 155
		},
		DEFAULT => -112,
		GOTOS => {
			'optional_tagbody' => 154
		}
	},
	{#State 144
		ACTIONS => {
			'Empty_line' => 156
		}
	},
	{#State 145
		ACTIONS => {
			'Space' => 158,
			"}" => 157
		}
	},
	{#State 146
		DEFAULT => -108,
		GOTOS => {
			'@17-1' => 159
		}
	},
	{#State 147
		DEFAULT => -106
	},
	{#State 148
		ACTIONS => {
			'Empty_line' => 113,
			'EOL' => 3,
			'Table_separator' => 24,
			'Include' => 23,
			'Named_variable' => 93,
			'Table' => 27,
			'Symbolic_variable' => 42,
			'Space' => 55,
			'Word' => 30,
			'Tag_name' => 57,
			'Embed' => 14
		},
		DEFAULT => -72,
		GOTOS => {
			'included' => 2,
			'table' => 52,
			'embedded' => 41,
			'literal_or_empty_line' => 138,
			'basic' => 12,
			'table_separator' => 48,
			'literal' => 116,
			'tag' => 43,
			'element' => 13
		}
	},
	{#State 149
		ACTIONS => {
			'Embedded' => 160
		}
	},
	{#State 150
		ACTIONS => {
			'Empty_line' => 161
		}
	},
	{#State 151
		ACTIONS => {
			'Tabled' => 162
		}
	},
	{#State 152
		ACTIONS => {
			'EOL' => 3,
			'Table_separator' => 24,
			'Include' => 23,
			'Named_variable' => 93,
			'Table' => 27,
			'Symbolic_variable' => 42,
			'Space' => 55,
			'Word' => 30,
			'Tag_name' => 57,
			'Embed' => 14
		},
		GOTOS => {
			'included' => 2,
			'text' => 163,
			'table' => 52,
			'embedded' => 41,
			'basic' => 12,
			'table_separator' => 48,
			'literal' => 31,
			'tag' => 43,
			'element' => 13
		}
	},
	{#State 153
		DEFAULT => -61
	},
	{#State 154
		DEFAULT => -101
	},
	{#State 155
		ACTIONS => {
			'EOL' => 3,
			'Table_separator' => 24,
			'Include' => 23,
			'Named_variable' => 93,
			'Table' => 27,
			'Symbolic_variable' => 42,
			'Space' => 55,
			'Word' => 30,
			'Tag_name' => 57,
			'Embed' => 14
		},
		GOTOS => {
			'included' => 2,
			'literals' => 164,
			'table' => 52,
			'embedded' => 41,
			'basic' => 12,
			'table_separator' => 48,
			'literal' => 110,
			'tag' => 43,
			'element' => 13
		}
	},
	{#State 156
		DEFAULT => -120
	},
	{#State 157
		DEFAULT => -105
	},
	{#State 158
		ACTIONS => {
			'Word' => 146
		},
		GOTOS => {
			'tagpar' => 165
		}
	},
	{#State 159
		ACTIONS => {
			"=" => 166
		}
	},
	{#State 160
		DEFAULT => -123
	},
	{#State 161
		DEFAULT => -64
	},
	{#State 162
		DEFAULT => -116
	},
	{#State 163
		DEFAULT => -128
	},
	{#State 164
		ACTIONS => {
			'EOL' => 3,
			'Table_separator' => 24,
			'Include' => 23,
			'Named_variable' => 93,
			'Table' => 27,
			'Symbolic_variable' => 42,
			">" => 167,
			'Space' => 55,
			'Word' => 30,
			'Tag_name' => 57,
			'Embed' => 14
		},
		GOTOS => {
			'included' => 2,
			'table' => 52,
			'embedded' => 41,
			'basic' => 12,
			'table_separator' => 48,
			'literal' => 134,
			'tag' => 43,
			'element' => 13
		}
	},
	{#State 165
		DEFAULT => -107
	},
	{#State 166
		ACTIONS => {
			"\"" => 168,
			'Word' => 170
		},
		GOTOS => {
			'tagvalue' => 169
		}
	},
	{#State 167
		DEFAULT => -113
	},
	{#State 168
		ACTIONS => {
			'Table' => 27,
			'Symbolic_variable' => 42,
			'Space' => 55,
			'Table_separator' => 24,
			'Include' => 23,
			'Word' => 30,
			'Tag_name' => 57,
			'Named_variable' => 93,
			'Embed' => 14
		},
		GOTOS => {
			'included' => 2,
			'table' => 52,
			'embedded' => 41,
			'basic' => 106,
			'basics' => 171,
			'table_separator' => 48,
			'tag' => 43,
			'element' => 13
		}
	},
	{#State 169
		DEFAULT => -109
	},
	{#State 170
		DEFAULT => -110
	},
	{#State 171
		ACTIONS => {
			'Table' => 27,
			'Symbolic_variable' => 42,
			"\"" => 172,
			'Space' => 55,
			'Table_separator' => 24,
			'Include' => 23,
			'Word' => 30,
			'Tag_name' => 57,
			'Named_variable' => 93,
			'Embed' => 14
		},
		GOTOS => {
			'included' => 2,
			'table' => 52,
			'embedded' => 41,
			'basic' => 131,
			'table_separator' => 48,
			'tag' => 43,
			'element' => 13
		}
	},
	{#State 172
		DEFAULT => -111
	}
],
                                  yyrules  =>
[
	[#Rule 0
		 '$start', 2, undef
	],
	[#Rule 1
		 'document', 1,
sub
#line 886 "ppParser.yp"
{
             # skip empty line "paragraphs"
             unless ($_[1][0] eq '')
              {
               # add data to the output stream
               push(@$resultStreamRef, @{$_[1][0]});

  	       # update checksums (unless done before for parts)
               updateChecksums($_[1][0], 'Paragraph_cache_hit') unless    $_[1][0][0][0]==DIRECTIVE_BLOCK
                                                                       or $_[1][0][0][0]==DIRECTIVE_DLIST
                                                                       or $_[1][0][0][0]==DIRECTIVE_OLIST
                                                                       or $_[1][0][0][0]==DIRECTIVE_ULIST;

               # update statistics, if necessary
               $statistics{$_[1][0][0][0]}++ unless not defined $_[1][0][0][0] or exists $embeddedParagraphs{$_[1][0][0][0]};

               # let the user know that something is going on
               print STDERR "\r", ' ' x length('[Info] '), '... ', $statistics{&DIRECTIVE_HEADLINE}, " chapters read."
                 if     not $flags{display} & &DISPLAY_NOINFO
                    and not $flags{trace}>TRACE_NOTHING
                    and $flags{vis}
                    and -t STDERR
                    and $_[1][0][0][0]==DIRECTIVE_HEADLINE
                    and not $statistics{&DIRECTIVE_HEADLINE} % $flags{vis};

               # this is for the parser to flag success
               1;
              }
            }
	],
	[#Rule 2
		 'document', 2,
sub
#line 916 "ppParser.yp"
{
             # skip empty line "paragraphs"
             unless ($_[2][0] eq '')
              {
               # add data to the output stream, if necessary
               push(@$resultStreamRef, @{$_[2][0]});

               # update checksums, if necessary
               updateChecksums($_[2][0], 'Paragraph_cache_hit') unless    $_[2][0][0][0]==DIRECTIVE_BLOCK
                                                                       or $_[2][0][0][0]==DIRECTIVE_DLIST
                                                                       or $_[2][0][0][0]==DIRECTIVE_OLIST
                                                                       or $_[2][0][0][0]==DIRECTIVE_ULIST;

               # update statistics, if necessary
               $statistics{$_[2][0][0][0]}++ unless exists $embeddedParagraphs{$_[2][0][0][0]};

               # let the user know that something is going on
               print STDERR "\r", ' ' x length('[Info] '), '... ', $statistics{&DIRECTIVE_HEADLINE}, " chapters read."
                 if     not $flags{display} & &DISPLAY_NOINFO
                    and not $flags{trace}>TRACE_NOTHING
                    and $flags{vis}
                    and -t STDERR
                    and $_[2][0][0][0]==DIRECTIVE_HEADLINE
                    and not $statistics{&DIRECTIVE_HEADLINE} % $flags{vis};

               # this is for the parser to flag success
               1;
              }
            }
	],
	[#Rule 3
		 'paragraph', 1, undef
	],
	[#Rule 4
		 'paragraph', 1, undef
	],
	[#Rule 5
		 'paragraph', 1, undef
	],
	[#Rule 6
		 'paragraph', 1, undef
	],
	[#Rule 7
		 'paragraph', 1, undef
	],
	[#Rule 8
		 'paragraph', 1, undef
	],
	[#Rule 9
		 'paragraph', 1, undef
	],
	[#Rule 10
		 'paragraph', 1, undef
	],
	[#Rule 11
		 'paragraph', 1, undef
	],
	[#Rule 12
		 'paragraph', 1, undef
	],
	[#Rule 13
		 'paragraph', 1, undef
	],
	[#Rule 14
		 'paragraph', 1, undef
	],
	[#Rule 15
		 '@1-1', 0,
sub
#line 964 "ppParser.yp"
{
             # switch to headline intro mode
             stateManager(STATE_HEADLINE);

             # update headline level hint
             $flags{headlineLevel}=$_[1][0];

             # trace, if necessary
             warn "[Trace] $sourceFile, line $_[1][1]: Headline (of level $_[1][0]) starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;
            }
	],
	[#Rule 16
		 'headline', 4,
sub
#line 975 "ppParser.yp"
{
             # back to default mode
             stateManager(STATE_DEFAULT);

             # trace, if necessary
             warn "[Trace] $sourceFile, line $_[4][1]: Headline completed.\n" if $flags{trace} & TRACE_PARAGRAPHS;

             # remove trailing whitespace (it represents the final newline)
             pop(@{$_[3][0]}) while $_[3][0][$#{$_[3][0]}]=~/^\s*$/;

	     # update related data
             @olistLevels=();

             # reply data
             [
              [
               # opener directive (including headline level)
               [DIRECTIVE_HEADLINE, DIRECTIVE_START, $_[1][0]],
               # the list of enclosed literals
               @{$_[3][0]},
               # final directive (including headline level again)
               [DIRECTIVE_HEADLINE, DIRECTIVE_COMPLETE, $_[1][0]]
              ],
              $_[4][1]
             ];
            }
	],
	[#Rule 17
		 'headline', 1, undef
	],
	[#Rule 18
		 'headline_level', 1,
sub
#line 1006 "ppParser.yp"
{
                   # start new counter and reply it
                   [$flags{headlineLevelOffset}+1, $_[1][1]];
                  }
	],
	[#Rule 19
		 'headline_level', 2,
sub
#line 1011 "ppParser.yp"
{
                   # update counter and reply it
                   [$_[1][0]+1, $_[1][1]];
                  }
	],
	[#Rule 20
		 '@2-1', 0,
sub
#line 1019 "ppParser.yp"
{
               # switch to condition mode
               stateManager(STATE_HEADLINE);

               # trace, if necessary
               warn "[Trace] $sourceFile, line $_[1][1]: Condition paragraph starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;
              }
	],
	[#Rule 21
		 'condition', 4,
sub
#line 1027 "ppParser.yp"
{
               # back to default mode
               stateManager(STATE_DEFAULT);

               # trace, if necessary
               warn "[Trace] $sourceFile, line $_[4][1]: condition completed.\n" if $flags{trace} & TRACE_PARAGRAPHS;

                # The condition is written in Perl, anything passed really?
                # And does the caller want to evaluate the code?
                if (@{$_[3][0]} and $safeObject)
                  {
                   # trace, if necessary
                   warn "[Trace] Evaluating condition ...\n" if $flags{trace} & TRACE_SEMANTIC;

                   # make it a string and evaluate it
                   my $perl=join('',  @{$_[3][0]});
                   $safeObject->reval('$^W=0');
                   warn "[Trace] $sourceFile, line $_[6][1]: Evaluating condition code:\n\n$perl\n\n\n" if $flags{trace} & TRACE_ACTIVE;
                   my $result=$safeObject->reval($perl);
                   $safeObject->reval('$^W=1');

                   # check result
                   if ($@)
                     {warn "[Error ", ++$semErr, "] $sourceFile, line $_[3][1]: condition code could not be evaluated: $@.\n";}
                   else
                     {
                      # trace, if necessary
                      warn "[Trace] Condition is ", (defined $result and $result) ? 'true, parsing continues' : 'false, parsing is temporarily suspended', ".\n" if $flags{trace} & TRACE_SEMANTIC;

                      # success - configure parser behaviour according to result
                      $flags{skipInput}=1 unless (defined $result and $result);
                     }
                  }
                else
                  {
                   # trace, if necessary
                   warn "[Trace] Condition is not evaluated because of disabled active contents.\n" if $flags{trace} & TRACE_SEMANTIC;
                  }

               # we have to supply something, but it should be nothing (note that this is a *paragraph*, so reply a *string*)
               ['', $_[4][1]];
              }
	],
	[#Rule 22
		 'list', 1, undef
	],
	[#Rule 23
		 'list', 2,
sub
#line 1074 "ppParser.yp"
{
         # update token list and reply it
         push(@{$_[1][0]}, @{$_[2][0]});
         [$_[1][0], $_[2][1]];
        }
	],
	[#Rule 24
		 'list', 3,
sub
#line 1080 "ppParser.yp"
{
         # update statistics, if necessary (shifters are not passed as standalone paragraphs, so ...)
         $statistics{$_[2][0][0][0]}++;

         # update token list and reply it
         push(@{$_[1][0]}, @{$_[2][0]}, @{$_[3][0]});
         [$_[1][0], $_[2][1]];
        }
	],
	[#Rule 25
		 'list_part', 1,
sub
#line 1092 "ppParser.yp"
{
              # embed the points into list directives
              [
               [
                # opener directive
                [DIRECTIVE_OLIST, DIRECTIVE_START],
                # the list of enclosed literals
                @{$_[1][0]},
                # final directive
                [DIRECTIVE_OLIST, DIRECTIVE_COMPLETE]
               ],
               $_[1][1]
              ];
             }
	],
	[#Rule 26
		 'list_part', 1,
sub
#line 1107 "ppParser.yp"
{
              # embed the points into list directives
              [
               [
                # opener directive
                [DIRECTIVE_ULIST, DIRECTIVE_START],
                # the list of enclosed literals
                @{$_[1][0]},
                # final directive
                [DIRECTIVE_ULIST, DIRECTIVE_COMPLETE]
               ],
               $_[1][1]
              ];
             }
	],
	[#Rule 27
		 'list_part', 1,
sub
#line 1122 "ppParser.yp"
{
              # embed the points into list directives
              [
               [
                # opener directive
                [DIRECTIVE_DLIST, DIRECTIVE_START],
                # the list of enclosed literals
                @{$_[1][0]},
                # final directive
                [DIRECTIVE_DLIST, DIRECTIVE_COMPLETE]
               ],
               $_[1][1]
              ];
             }
	],
	[#Rule 28
		 'olist', 1, undef
	],
	[#Rule 29
		 'olist', 2,
sub
#line 1141 "ppParser.yp"
{
          # update token list and reply it
          push(@{$_[1][0]}, @{$_[2][0]});
          [$_[1][0], $_[2][1]];
         }
	],
	[#Rule 30
		 'ulist', 1, undef
	],
	[#Rule 31
		 'ulist', 2,
sub
#line 1151 "ppParser.yp"
{
          # update token list and reply it
          push(@{$_[1][0]}, @{$_[2][0]});
          [$_[1][0], $_[2][1]];
         }
	],
	[#Rule 32
		 'dlist', 1, undef
	],
	[#Rule 33
		 'dlist', 2,
sub
#line 1161 "ppParser.yp"
{
          # update token list and reply it
          push(@{$_[1][0]}, @{$_[2][0]});
          [$_[1][0], $_[2][1]];
         }
	],
	[#Rule 34
		 '@3-1', 0,
sub
#line 1170 "ppParser.yp"
{
           # switch to opoint mode
           stateManager(STATE_OPOINT);

           # trace, if necessary
           warn "[Trace] $sourceFile, line $_[1][1]: Ordered list point starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;
          }
	],
	[#Rule 35
		 'opoint', 3,
sub
#line 1178 "ppParser.yp"
{
           # update statistics (list points are not passed as standalone paragraphs, so ...)
           $statistics{&DIRECTIVE_OPOINT}++;

           # trace, if necessary
           warn "[Trace] $sourceFile, line $_[3][1]: Ordered list point completed.\n" if $flags{trace} & TRACE_PARAGRAPHS;

           # remove leading whitespaces from point text (it separated number wildcard and literal text part)
           splice(@{$_[3][0]}, 1, 1) while not ref($_[3][0][1]) and $_[3][0][1]=~/^\s*$/;

           # reply data (they are already well prepared except that they are marked as text)
           $_[3][0][0][0]=$_[3][0][$#{$_[3][0]}][0]=&DIRECTIVE_OPOINT;

           # update list level hint
           $olistLevels[0]++;

	   # add a level hint, if necessary
	   if ($_[1][0] and $olistLevels[0]>1)
	     {
	      push(@{$_[3][0][0]}, $olistLevels[0]);
	      push(@{$_[3][0][$#{$_[3][0]}]}, $olistLevels[0]);
	     }

	   # update checksums
	   updateChecksums($_[3][0], 'Opoint_cache_hit');

	   # supply result
           $_[3];
          }
	],
	[#Rule 36
		 'opoint', 1, undef
	],
	[#Rule 37
		 'opoint_opener', 1,
sub
#line 1213 "ppParser.yp"
{[0, $_[1][1]];}
	],
	[#Rule 38
		 'opoint_opener', 2,
sub
#line 1215 "ppParser.yp"
{[1, $_[1][1]];}
	],
	[#Rule 39
		 '@4-1', 0,
sub
#line 1220 "ppParser.yp"
{
           # switch to upoint mode
           stateManager(STATE_UPOINT);

           # trace, if necessary
           warn "[Trace] $sourceFile, line $_[1][1]: Unordered list point starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;
          }
	],
	[#Rule 40
		 'upoint', 3,
sub
#line 1228 "ppParser.yp"
{
           # update statistics (list points are not passed as standalone paragraphs, so ...)
           $statistics{&DIRECTIVE_UPOINT}++;

           # trace, if necessary
           warn "[Trace] $sourceFile, line $_[3][1]: Unordered list point completed.\n" if $flags{trace} & TRACE_PARAGRAPHS;

           # remove leading whitespaces from point text (it separated bullet and literal text part)
           splice(@{$_[3][0]}, 1, 1) while not ref($_[3][0][1]) and $_[3][0][1]=~/^\s*$/;

           # remove trailing whitespaces from point text (it represents the final newline character)
           splice(@{$_[3][0]}, -2, 1) while not ref($_[3][0][$#{$_[3][0]}-1]) and $_[3][0][$#{$_[3][0]}-1]=~/^\s*$/;

           # reply data (they are already well prepared except that they are marked as text)
           $_[3][0][0][0]=$_[3][0][$#{$_[3][0]}][0]=&DIRECTIVE_UPOINT;

	   # update checksums
	   updateChecksums($_[3][0], 'Upoint_cache_hit');

	   # supply result
           $_[3];
          }
	],
	[#Rule 41
		 'upoint', 1, undef
	],
	[#Rule 42
		 '@5-1', 0,
sub
#line 1256 "ppParser.yp"
{
          }
	],
	[#Rule 43
		 'dpoint', 3,
sub
#line 1259 "ppParser.yp"
{
           # update statistics (list points are not passed as standalone paragraphs, so ...)
           $statistics{&DIRECTIVE_DPOINT}++;

           # trace, if necessary
           warn "[Trace] $sourceFile, line $_[3][1]: Definition list point completed.\n" if $flags{trace} & TRACE_PARAGRAPHS;

           # remove leading whitespaces from point text (it separated point introduction and literal text part)
           splice(@{$_[3][0]}, 1, 1) while not ref($_[3][0][1]) and $_[3][0][1]=~/^\s*$/;

           # reply data (they are already well prepared except that they are marked as text, and that the definition item stream needs to be added)
           $_[3][0][0]=[DIRECTIVE_DPOINT, DIRECTIVE_START];
           $_[3][0][$#{$_[3][0]}]=[DIRECTIVE_DPOINT, DIRECTIVE_COMPLETE];

           # insert the definition item stream
           splice(@{$_[3][0]}, 1, 0,
                  [DIRECTIVE_DPOINT_ITEM, DIRECTIVE_START],
                  @{$_[1][0]},
                  [DIRECTIVE_DPOINT_ITEM, DIRECTIVE_COMPLETE],
                 );

	   # update checksums
	   updateChecksums($_[3][0], 'Dpoint_cache_hit');

           # supply the result
           $_[3];
          }
	],
	[#Rule 44
		 'dpoint', 1, undef
	],
	[#Rule 45
		 '@6-1', 0,
sub
#line 1292 "ppParser.yp"
{
                 # switch to dlist item mode
                 stateManager(STATE_DPOINT_ITEM);

                 # trace, if necessary
                 warn "[Trace] $sourceFile, line $_[1][1]: Definition list point starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;
                }
	],
	[#Rule 46
		 'dlist_opener', 4,
sub
#line 1300 "ppParser.yp"
{
                 # switch to dlist body mode
                 stateManager(STATE_DPOINT);

                 # simply pass the elements
                 [$_[3][0], $_[4][1]];
                }
	],
	[#Rule 47
		 'compound_block', 1, undef
	],
	[#Rule 48
		 'compound_block', 2,
sub
#line 1313 "ppParser.yp"
{
                   # this is tricky - to combine both blocks, we have to remove the already
                   # embedded stop/start directives and to supply the 
                   [
                    [
                     # original collection WITHOUT the final directive ...
                     @{$_[1][0]}[0..$#{$_[1][0]}-1],
                     # insert an additional newline character (restoring the original empty line)
                     "\n",
                     # ... combined with the new block, except of its INTRO directive
                     @{$_[2][0]}[1..$#{$_[2][0]}],
                    ],
                    $_[2][1]
                   ];
                  }
	],
	[#Rule 49
		 'compound_block', 3,
sub
#line 1329 "ppParser.yp"
{
                   # update statistics (for the first part which is completed by the intermediate flag paragraph)
                   $statistics{&DIRECTIVE_BLOCK}++;

                   # this is simply a list of both blocks
                   [
                    [
                     # original collection
                     @{$_[1][0]},
                     # ... followed by the new block
                     @{$_[3][0]},
                    ],
                    $_[3][1]
                   ];
                  }
	],
	[#Rule 50
		 '@7-1', 0,
sub
#line 1348 "ppParser.yp"
{
                  # switch to control mode
                  stateManager(STATE_CONTROL);

                  # trace, if necessary
                  warn "[Trace] $sourceFile, line $_[1][1]: New block flag starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;
                 }
	],
	[#Rule 51
		 'block_flagnew', 3,
sub
#line 1356 "ppParser.yp"
{
                  # back to default mode
                  stateManager(STATE_DEFAULT);

                  # trace, if necessary
                  warn "[Trace] $sourceFile, line $_[1][1]: New block flag completed.\n" if $flags{trace} & TRACE_PARAGRAPHS;

                  # reply data (these are dummies because block connectors are not made part of the output stream)
                  $_[3];
                 }
	],
	[#Rule 52
		 '@8-1', 0,
sub
#line 1370 "ppParser.yp"
{
          # switch to block mode
          stateManager(STATE_BLOCK);

          # trace, if necessary
          warn "[Trace] $sourceFile, line $_[1][1]: Block starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;
         }
	],
	[#Rule 53
		 'block', 3,
sub
#line 1378 "ppParser.yp"
{
          # trace, if necessary
          warn "[Trace] $sourceFile, line $_[3][1]: Block completed.\n" if $flags{trace} & TRACE_PARAGRAPHS;

          # reply data (they are almost perfect except that they are marked as text,
          # and that the initial spaces have to be inserted)
          $_[3][0][0][0]=$_[3][0][$#{$_[3][0]}][0]=DIRECTIVE_BLOCK;
          splice(@{$_[3][0]}, 1, 0, $_[1][0]);

	  # update checksums
	  updateChecksums($_[3][0], 'Block_cache_hit');

	  # supply result
          $_[3];
         }
	],
	[#Rule 54
		 'block', 1, undef
	],
	[#Rule 55
		 '@9-1', 0,
sub
#line 1398 "ppParser.yp"
{
         # enter text mode - unless we are in a block (or point (which already set this mode itself))
         unless (   $parserState==STATE_BLOCK
                 or $parserState==STATE_UPOINT
                 or $parserState==STATE_OPOINT
                 or $parserState==STATE_DPOINT
                 or $parserState==STATE_DPOINT_ITEM
                 or $parserState==STATE_DEFINITION
                )
          {
           # switch to new mode
           stateManager(STATE_TEXT);

           # trace, if necessary
           warn "[Trace] $sourceFile, line $_[1][1]: Text starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;
          }
        }
	],
	[#Rule 56
		 'text', 4,
sub
#line 1417 "ppParser.yp"
{
         # trace, if necessary
         warn "[Trace] $sourceFile, line $_[4][1]: Text completed.\n" unless    not $flags{trace} & TRACE_PARAGRAPHS
                                                                or $parserState==STATE_BLOCK
                                                                or $parserState==STATE_UPOINT
                                                                or $parserState==STATE_OPOINT
                                                                or $parserState==STATE_DPOINT
                                                                or $parserState==STATE_DPOINT_ITEM;

         # back to default mode
         stateManager(STATE_DEFAULT);

         # remove the final EOL literal, if any
         pop(@{$_[3][0]}) if defined $_[3][0][$#{$_[3][0]}] and $_[3][0][$#{$_[3][0]}] eq 'EOL';

         # reply data
         [
          [
           # opener directive
           [DIRECTIVE_TEXT, DIRECTIVE_START],
           # the list of enclosed literals
           @{$_[1][0]}, @{$_[3][0]},
           # final directive
           [DIRECTIVE_TEXT, DIRECTIVE_COMPLETE],
          ],
          $_[4][1],
         ];
        }
	],
	[#Rule 57
		 '@10-1', 0,
sub
#line 1449 "ppParser.yp"
{
             # switch to verbatim mode
             stateManager(STATE_VERBATIM);

             # trace, if necessary
             warn "[Trace] $sourceFile, line $_[1][1]: Verbatim block starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;

             # check close hint: should be different from "1"
             warn "[Error ", ++$semErr, "] A heredoc close hint should be different from \"1\".\n" if $_[1][0] eq '1';

             # store close hint
             $specials{heredoc}=$_[1][0];
            }
	],
	[#Rule 58
		 'verbatim', 4,
sub
#line 1464 "ppParser.yp"
{
             # trace, if necessary
             warn "[Trace] $sourceFile, line $_[4][1]: Verbatim block completed.\n" if $flags{trace} & TRACE_PARAGRAPHS;

             # back to default mode
             stateManager(STATE_DEFAULT);

             # delete the initial newline (which follows the opener but is no part of the block)
             shift(@{$_[3][0]});

             # reply data
             [
              [
               # opener directive
               [DIRECTIVE_VERBATIM, DIRECTIVE_START],
               # the list of enclosed literals
               @{$_[3][0]},
               # final directive
               [DIRECTIVE_VERBATIM, DIRECTIVE_COMPLETE]
              ],
              $_[4][1]
             ];
            }
	],
	[#Rule 59
		 'variable_assignment', 3,
sub
#line 1491 "ppParser.yp"
{
                        # remove text directives and the final space (made from the final EOL)
                        shift(@{$_[3][0]});
                        pop(@{$_[3][0]}) for (1..2);

                        # make the text contents a string and store it
                        $variables{$_[1][0]}=join('', @{$_[3][0]});

                        # make the new variable setting available to embedded Perl code, if necessary
                        if ($safeObject)
                         {
                          no strict 'refs';
                          ${join('::', $safeObject->root, $_[1][0])}=$variables{$_[1][0]};
                         }

                        # trace, if necessary
                        warn "[Trace] $sourceFile, line $_[3][1]: Variable assignment: \$$_[1][0]=$variables{$_[1][0]}.\n" if $flags{trace} & TRACE_PARAGRAPHS;

                        # flag this paragraph as internal
                        ['', $_[3][1]];
                       }
	],
	[#Rule 60
		 '@11-2', 0,
sub
#line 1516 "ppParser.yp"
{
            # switch to comment mode
            stateManager(STATE_COMMENT);

            # trace, if necessary
            warn "[Trace] $sourceFile, line $_[1][1]: Comment starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;
           }
	],
	[#Rule 61
		 'comment', 5,
sub
#line 1524 "ppParser.yp"
{
            # back to default mode
            stateManager(STATE_DEFAULT);

            # trace, if necessary
            warn "[Trace] $sourceFile, line $_[5][1]: Comment completed.\n" if $flags{trace} & TRACE_PARAGRAPHS;

            # reply data
            [
             [
              # opener directive
              [DIRECTIVE_COMMENT, DIRECTIVE_START],
              # the list of enclosed literals
              @{$_[4][0]},
              # final directive
              [DIRECTIVE_COMMENT, DIRECTIVE_COMPLETE]
             ],
             $_[5][1]
            ];
           }
	],
	[#Rule 62
		 '@12-1', 0,
sub
#line 1548 "ppParser.yp"
{
                # temporarily activate number detection
                push(@specialStack, $specials{number});
                $specials{number}=1;
               }
	],
	[#Rule 63
		 '@13-3', 0,
sub
#line 1554 "ppParser.yp"
{
                # restore previous number detection mode
                $specials{number}=pop(@specialStack);

                # switch to control mode
                stateManager(STATE_CONTROL);

                # trace, if necessary
                warn "[Trace] $sourceFile, line $_[3][1]: List shift ", $_[1][0]==LIST_SHIFT_RIGHT ? 'right' : 'left', " starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;
               }
	],
	[#Rule 64
		 'list_shift', 5,
sub
#line 1565 "ppParser.yp"
{
                # back to default mode
                stateManager(STATE_DEFAULT);

                # trace, if necessary
                warn "[Trace] $sourceFile, line $_[5][1]: List shift ", $_[1][0]==LIST_SHIFT_RIGHT ? 'right' : 'left', " completed.\n" if $flags{trace} & TRACE_PARAGRAPHS;

                # update related data
                if ($_[1][0]==LIST_SHIFT_RIGHT)
		  {unshift(@olistLevels, 0) for (1..(defined $_[3][0] ? $_[3][0] : 1));}
		else
		  {shift(@olistLevels) for (1..(defined $_[3][0] ? $_[3][0] : 1));}

                # reply data
                [
                 [
                  # opener directive
                  [$_[1][0]==LIST_SHIFT_RIGHT ? DIRECTIVE_LIST_RSHIFT : DIRECTIVE_LIST_LSHIFT, DIRECTIVE_START, defined $_[3][0] ? $_[3][0] : 1],
                  # final directive
                  [$_[1][0]==LIST_SHIFT_RIGHT ? DIRECTIVE_LIST_RSHIFT : DIRECTIVE_LIST_LSHIFT, DIRECTIVE_COMPLETE, defined $_[3][0] ? $_[3][0] : 1]
                 ],
                 $_[5][1]
                ];
               }
	],
	[#Rule 65
		 'list_shifter', 1,
sub
#line 1593 "ppParser.yp"
{
                 # reply a flag
                 [LIST_SHIFT_RIGHT, $_[1][1]];
                }
	],
	[#Rule 66
		 'list_shifter', 1,
sub
#line 1598 "ppParser.yp"
{
                 # reply a flag
                 [LIST_SHIFT_LEFT, $_[1][1]];
                }
	],
	[#Rule 67
		 'optional_literals', 0,
sub
#line 1606 "ppParser.yp"
{
                      # start a new, empty list and reply it
                      [[], $lineNrs{$inHandle}];
                     }
	],
	[#Rule 68
		 'optional_literals', 1, undef
	],
	[#Rule 69
		 'literals', 1, undef
	],
	[#Rule 70
		 'literals', 2,
sub
#line 1616 "ppParser.yp"
{
             # update token list and reply it
             push(@{$_[1][0]}, @{$_[2][0]});
             [$_[1][0], $_[2][1]];
            }
	],
	[#Rule 71
		 'optional_literals_and_empty_lines', 0,
sub
#line 1625 "ppParser.yp"
{
                                      # start a new, empty list and reply it
                                      [[], $lineNrs{$inHandle}];
                                     }
	],
	[#Rule 72
		 'optional_literals_and_empty_lines', 1, undef
	],
	[#Rule 73
		 'literals_and_empty_lines', 1, undef
	],
	[#Rule 74
		 'literals_and_empty_lines', 2,
sub
#line 1635 "ppParser.yp"
{
                             # update token list and reply it
                             push(@{$_[1][0]}, @{$_[2][0]});
                             [$_[1][0], $_[2][1]];
                            }
	],
	[#Rule 75
		 'literal_or_empty_line', 1, undef
	],
	[#Rule 76
		 'literal_or_empty_line', 1,
sub
#line 1645 "ppParser.yp"
{
                          # start a new token list and reply it
                          [[$_[1][0]], $_[1][1]];
                         }
	],
	[#Rule 77
		 'literal', 1, undef
	],
	[#Rule 78
		 'literal', 1,
sub
#line 1654 "ppParser.yp"
{
            # start a new token list and reply it
            [[$_[1][0]], $_[1][1]];
           }
	],
	[#Rule 79
		 'optional_basics', 0,
sub
#line 1662 "ppParser.yp"
{
                   # start a new, empty list and reply it
                   [[], $lineNrs{$inHandle}];
                  }
	],
	[#Rule 80
		 'optional_basics', 1, undef
	],
	[#Rule 81
		 'basics', 1, undef
	],
	[#Rule 82
		 'basics', 2,
sub
#line 1672 "ppParser.yp"
{
           # update token list and reply it
           push(@{$_[1][0]}, @{$_[2][0]});
           [$_[1][0], $_[2][1]];
          }
	],
	[#Rule 83
		 'basic', 1, undef
	],
	[#Rule 84
		 'basic', 1, undef
	],
	[#Rule 85
		 'basic', 1, undef
	],
	[#Rule 86
		 'elements', 1, undef
	],
	[#Rule 87
		 'elements', 2,
sub
#line 1690 "ppParser.yp"
{
             # update token list and reply it
             push(@{$_[1][0]}, @{$_[2][0]});
             [$_[1][0], $_[2][1]];
            }
	],
	[#Rule 88
		 'element', 1,
sub
#line 1700 "ppParser.yp"
{
            # start a new token list and reply it
            [[$_[1][0]], $_[1][1]];
           }
	],
	[#Rule 89
		 'element', 1,
sub
#line 1705 "ppParser.yp"
{
            # start a new token list and reply it
            [[$_[1][0]], $_[1][1]];
           }
	],
	[#Rule 90
		 'element', 1,
sub
#line 1710 "ppParser.yp"
{
	    # disable storage of a checksum (variable definitions may change or have changed)
	    $flags{checksummed}=0;

            # start a new token list and reply it
            [[exists $variables{$_[1][0]} ? $variables{$_[1][0]} : join('', '$', $_[1][0])], $_[1][1]];
           }
	],
	[#Rule 91
		 'element', 1,
sub
#line 1718 "ppParser.yp"
{
	    # disable storage of a checksum (variable definitions may change or have changed)
	    $flags{checksummed}=0;

            # start a new token list and reply it
            [[exists $variables{$_[1][0]} ? $variables{$_[1][0]} : join('', '$', "{$_[1][0]}")], $_[1][1]];
           }
	],
	[#Rule 92
		 'element', 1, undef
	],
	[#Rule 93
		 'element', 1, undef
	],
	[#Rule 94
		 'element', 1, undef
	],
	[#Rule 95
		 'optional_number', 0,
sub
#line 1733 "ppParser.yp"
{[undef, $lineNrs{$inHandle}];}
	],
	[#Rule 96
		 'optional_number', 1, undef
	],
	[#Rule 97
		 'words', 1,
sub
#line 1740 "ppParser.yp"
{
          # start a new token list and reply it
          [[$_[1][0]], $_[1][1]];
         }
	],
	[#Rule 98
		 'words', 2,
sub
#line 1745 "ppParser.yp"
{
          # update token list and reply it
          push(@{$_[1][0]}, $_[2][0]);
          [$_[1][0], $_[2][1]];
         }
	],
	[#Rule 99
		 '@14-1', 0,
sub
#line 1755 "ppParser.yp"
{
        # trace, if necessary
        warn "[Trace] $sourceFile, line $_[1][1]: Tag $_[1][0] starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;

        # temporarily activate specials "{", "}", "<" and ">"
        push(@specialStack, @specials{('<', '>', '{', '}')});
        @specials{('{', '}', '<', '>')}=(1) x 4;
       }
	],
	[#Rule 100
		 '@15-3', 0,
sub
#line 1764 "ppParser.yp"
{
        # restore special states of "{" and "}"
        @specials{('{', '}')}=splice(@specialStack, -2, 2);
       }
	],
	[#Rule 101
		 'tag', 5,
sub
#line 1769 "ppParser.yp"
{
        # trace, if necessary
        warn "[Trace] $sourceFile, line $_[5][1]: Tag $_[1][0] completed.\n" if $flags{trace} & TRACE_PARAGRAPHS;

        # restore special states of "<" and ">"
        @specials{('<', '>')}=splice(@specialStack, -2, 2);

        # build parameter hash, if necessary
        my %pars;
        if (@{$_[3][0]})
          {
           # the list already consists of key/value pairs
           %pars=@{$_[3][0]}
          }

        # this might be a macro as well as a tag - so what?
        unless (exists $macros{$_[1][0]})
          {
           # update statistics
           $statistics{&DIRECTIVE_TAG}++;

           # reply tag data
           [
            [
             # opener directive
             [DIRECTIVE_TAG, DIRECTIVE_START, $_[1][0], \%pars],
             # the list of enclosed literals, if any
             @{$_[5][0]} ? @{$_[5][0]} : (),
             # final directive
             [DIRECTIVE_TAG, DIRECTIVE_COMPLETE, $_[1][0], \%pars]
            ],
            $_[5][1]
           ];
          }
        else
          {
	   # disable checksum storage (a macro means "non reproducable contents")
	   $flags{checksummed}=0;

           # this is a macro - resolve it!
           my $macro=$macros{$_[1][0]}->[1];

           # fill in parameters
           foreach my $par (@{$macros{$_[1][0]}->[0]})
             {
              my $value=exists $pars{$par} ? $pars{$par} : '';
              $macro=~s/__${par}__/$value/g;
             }

           # add the body, if necessary
           if ($macro=~/__body__/)
             {

              # reverse engineer the body stream
              $reverseStream->run($_[5][0]);

              # make the body a string to be reparsed
              my $body=join('', @{$_[5][0]} ? $reversedInput : ());

              # reset reverse engineering string buffer
              $reversedInput='';

              # combine macro and body
              $macro=~s/__body__/$body/g;
             }

           # finally, pass the constructed text back to the input stream (by stack)
           stackInput($_[0], split(/(\n)/, $macro));

           # reset the "end of input reached" flag if necessary
           $readCompletely=0 if $readCompletely;

           # reply nothing real
           [[()], $_[5][1]];
          }
       }
	],
	[#Rule 102
		 'optional_tagpars', 0,
sub
#line 1849 "ppParser.yp"
{[[], $lineNrs{$inHandle}];}
	],
	[#Rule 103
		 'optional_tagpars', 1, undef
	],
	[#Rule 104
		 '@16-1', 0,
sub
#line 1855 "ppParser.yp"
{
                 # temporarily activate special "="
                 push(@specialStack, $specials{'='});
                 $specials{'='}=1;
                }
	],
	[#Rule 105
		 'used_tagpars', 4,
sub
#line 1861 "ppParser.yp"
{
                 #restore special state of "="
                 $specials{'='}=pop(@specialStack);

                 # supply the parameters
                 [$_[3][0], $_[4][1]];
                }
	],
	[#Rule 106
		 'tagpars', 1, undef
	],
	[#Rule 107
		 'tagpars', 3,
sub
#line 1873 "ppParser.yp"
{
            # update parameter list
            push(@{$_[1][0]}, @{$_[3][0]});

            # supply updated parameter list
            [$_[1][0], $_[3][1]];
           }
	],
	[#Rule 108
		 '@17-1', 0,
sub
#line 1884 "ppParser.yp"
{
           # temporarily make "=" and quotes the only specials,
           # but take care to reset the remaining settings defined
           push(@specialStack, [(%specials)]);
           @specials{keys %specials}=(0) x scalar(keys %specials);
           @specials{('=', '"')}=(1, 1);
          }
	],
	[#Rule 109
		 'tagpar', 4,
sub
#line 1892 "ppParser.yp"
{
           # restore special settings
           %specials=@{pop(@specialStack)};

           # supply flag and value
           [[$_[1][0], $_[4][0]], $_[4][1]];
          }
	],
	[#Rule 110
		 'tagvalue', 1, undef
	],
	[#Rule 111
		 'tagvalue', 3,
sub
#line 1903 "ppParser.yp"
{
             # build a string and supply it
             [join('', @{$_[2][0]}), $_[3][1]];
            }
	],
	[#Rule 112
		 'optional_tagbody', 0,
sub
#line 1911 "ppParser.yp"
{[[], $lineNrs{$inHandle}];}
	],
	[#Rule 113
		 'optional_tagbody', 3,
sub
#line 1913 "ppParser.yp"
{
                     # reply the literals
                     [$_[2][0], $_[3][1]];
                    }
	],
	[#Rule 114
		 '@18-1', 0,
sub
#line 1921 "ppParser.yp"
{
          # trace, if necessary
          warn "[Trace] $sourceFile, line $_[1][1]: Table starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;

          # check nesting (might be supported in later versions)
          warn "[Error ", ++$semErr, "] $sourceFile, line $_[3][1]: Nested tables are not supported by this parser version.\n" if @tableSeparatorStack;

          # temporarily activate specials "{" and "}"
          push(@specialStack, @specials{('{', '}')});
          @specials{('{', '}')}=(1, 1);

          # empty lines have to be ignored in tables
          push(@specialStack, $lexerFlags{el});
          $lexerFlags{el}=LEXER_IGNORE;
         }
	],
	[#Rule 115
		 '@19-3', 0,
sub
#line 1937 "ppParser.yp"
{
          # restore previous handling of empty lines
          $lexerFlags{el}=pop(@specialStack);

          # restore special state of "{" and "}"
          @specials{('{', '}')}=splice(@specialStack, -2, 2);

          # read parameters
          my %tagpars=@{$_[3][0]};

          # store specified column separator (or default)
          unshift(@tableSeparatorStack, exists $tagpars{separator} ? quotemeta($tagpars{separator}) : '\|');
         }
	],
	[#Rule 116
		 'table', 6,
sub
#line 1951 "ppParser.yp"
{
          # reset column separator memory
          shift(@tableSeparatorStack);

          # build parameter hash, if necessary
          my %pars;
          if (@{$_[3][0]})
            {
             # the list already consists of key/value pairs
             %pars=@{$_[3][0]}
            }

          # If we are here and found anything in the table, a final row was
          # closed and a new one opened at the end of the last table line.
          # Because the table is completed now, the final opener tags can
          # be removed. This is done *here* and by pop() for acceleration.
          pop(@{$_[5][0]}), pop(@{$_[5][0]}) if @{$_[5][0]};

          # reply data in a "tag envelope" (for backends)
          [
           [
            # opener directives
            [DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE', \%pars],
            [DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_ROW'],
            [DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL'],
            # the list of enclosed literals reduced by the final two, if any
            @{$_[5][0]} ? @{$_[5][0]} : (),
            # final directive
            [DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE', \%pars]
           ],
           $_[6][1]
          ];
         }
	],
	[#Rule 117
		 'table_separator', 1,
sub
#line 1988 "ppParser.yp"
{
                    # update counter of completed table columns
                    $tableColumns++;

                    # supply a simple seperator tag
                    [
                     [
                      [DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL'],
                      $_[1][0] eq 'c' ? ()
                                      : (
                                         [DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_ROW'],
                                         [DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_ROW'],
                                        ),
                      [DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL'],
                     ],
                     $_[1][1]
                    ];
                   }
	],
	[#Rule 118
		 '@20-1', 0,
sub
#line 2010 "ppParser.yp"
{
                    # switch to condition mode
                    stateManager(STATE_TABLE);

                    # trace, if necessary
                    warn "[Trace] $sourceFile, line $_[1][1]: Table paragraph starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;
                   }
	],
	[#Rule 119
		 '@21-3', 0,
sub
#line 2018 "ppParser.yp"
{
                    # store specified column separator
                    unshift(@tableSeparatorStack, quotemeta(join('', @{$_[3][0]})));
                   }
	],
	[#Rule 120
		 'table_paragraph', 6,
sub
#line 2023 "ppParser.yp"
{
                    # back to default mode
                    stateManager(STATE_DEFAULT);

                    # trace, if necessary
                    warn "[Trace] $sourceFile, line $_[6][1]: Table paragraph completed.\n" if $flags{trace} & TRACE_PARAGRAPHS;

                    # reset column separator memory
                    shift(@tableSeparatorStack);

                    # build parameter hash, if necessary
                    my %pars=();

                    # If we are here and found anything in the table, a final row was
                    # closed and a new one opened at the end of the last table line.
                    # Because the table is completed now, the final opener tags can
                    # be removed. This is done *here* and by pop() for acceleration.
                    # Additionally, note that in a table *paragraph* the first end
                    # of line is supplied. This is different to a table tag.
                    if (@{$_[5][0]}>4)
                      {
                       # remove initial carriage return in the startup line
                       shift(@{$_[5][0]});

                       # delete final opener directives made by the final carriage return
                       splice(@{$_[5][0]}, -2, 2);

                       # well, the first row shall be formatted as a headline by example,
                       # find the first row and make a modified version
                       {
                        my ($index, @headlinePart)=(0);
                        foreach (@{$_[5][0]})
                          {
                           $index++;
                           push(@headlinePart, (ref($_) eq 'ARRAY' and $_->[0]==DIRECTIVE_TAG and $_->[2] eq 'TABLE_COL') ? [@{$_}[0, 1], 'TABLE_HL'] : $_);
                           last if ref($_) eq 'ARRAY' and $_->[0]==DIRECTIVE_TAG and $_->[1]==DIRECTIVE_COMPLETE and $_->[2] eq 'TABLE_ROW'
                          }
                        splice(@{$_[5][0]}, 0, $index, @headlinePart);
                       }

                       # reply data in a "tag envelope" (for backends)
                       [
                        [
                         # opener directives (note that first row and column are already opened by the initial carriage return stream)
                         [DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE', \%pars],
                         [DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_ROW'],
                         [DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_HL'],
                         # the list of enclosed literals reduced by the final two, if any
                         @{$_[5][0]} ? @{$_[5][0]} : (),
                         # final directive
                         [DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE', \%pars]
                        ],
                        $_[6][1]
                       ];
                      }
                    else
                      {
                       # empty table - reply nothing real
                       [[()], $_[6][1]];
                      }
                   }
	],
	[#Rule 121
		 '@22-1', 0,
sub
#line 2088 "ppParser.yp"
{
             # switch to embedding mode saving the former state
             push(@stateStack, $parserState);
             stateManager(STATE_EMBEDDING);

             # trace, if necessary
             warn "[Trace] $sourceFile, line $_[1][1]: Embedding starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;

	     # Disable storage of a checksum. (Dynamic parts may change or have changed.
             # Static parts are static of course, but the filter settings may vary.)
	     $flags{checksummed}=0;

             # temporarily activate specials "{" and "}"
             push(@specialStack, @specials{('{', '}')});
             @specials{('{', '}')}=(1, 1);
            }
	],
	[#Rule 122
		 '@23-3', 0,
sub
#line 2105 "ppParser.yp"
{
             # restore special state of "{" and "}"
             @specials{('{', '}')}=splice(@specialStack, -2, 2);

             # check parameters: language should be set at least
             my %tagpars=@{$_[3][0]};
             warn "[Error ", ++$semErr, "] $sourceFile, line $_[3][1]: You forgot to specify the language of embedded text.\n" unless exists $tagpars{lang};
            }
	],
	[#Rule 123
		 'embedded', 6,
sub
#line 2114 "ppParser.yp"
{
             # restore parser state
             stateManager(pop(@stateStack));

             # build parameter hash, if necessary
             my %pars;
             if (@{$_[3][0]})
               {
                # the list already consists of key/value pairs
                %pars=@{$_[3][0]}
               }

             # check if we have to stream this code
             unless (not $flags{filter} or lc($pars{lang}) eq 'pp' or (exists $pars{lang} and $pars{lang}=~/^$flags{filter}$/i))
               {
                # caller wants to skip the embedded code: we have to supply something, but it should be nothing
                [[()], $_[6][1]];
               }
             elsif (lc($pars{lang}) eq 'pp')
               {
                # embedded PerlPoint - pass it back to the parser (by stack)
                stackInput($_[0], split(/(\n)/, join('',  @{$_[5][0]})));

                # reset the "end of input reached" flag if necessary
                $readCompletely=0 if $readCompletely;

                # we have to supply something, but it should be nothing
                [[()], $_[6][1]];
               }
             elsif (lc($pars{lang}) eq 'perl')
               {
                # This is embedded Perl code, anything passed really?
                # And does the caller want to evaluate the code?
                if (@{$_[5][0]} and $safeObject)
                  {
                   # make the code a string and evaluate it
                   my $perl=join('',  @{$_[5][0]});
                   warn "[Trace] $sourceFile, line $_[6][1]: Evaluating this code:\n\n$perl\n\n\n" if $flags{trace} & TRACE_ACTIVE;
                   my $result=$safeObject->reval($perl);

                   # check result
                   if ($@)
                     {warn "[Error ", ++$semErr, "] $sourceFile, line $_[5][1]: embedded Perl code could not be evaluated: $@.\n";}
                   else
                     {
                      # success - make the result part of the input stream
                      stackInput($_[0], split(/(\n)/, $result));

                      # reset the "end of input reached" flag if necessary
                      $readCompletely=0 if $readCompletely;
                     }
                  }

                # we have to supply something, but it should be nothing
                [[()], $_[6][1]];
               }
             else
               {
                # reply data in a "tag envelope" (for backends)
                [
                 [
                  # opener directive
                  [DIRECTIVE_TAG, DIRECTIVE_START, 'EMBED', \%pars],
                  # the list of enclosed literals, if any
                  @{$_[5][0]} ? @{$_[5][0]} : (),
                  # final directive
                  [DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'EMBED', \%pars]
                 ],
                 $_[6][1]
                ];
               }
            }
	],
	[#Rule 124
		 '@24-1', 0,
sub
#line 2190 "ppParser.yp"
{
             # trace, if necessary
             warn "[Trace] $sourceFile, line $_[1][1]: Inclusion starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;

	     # Disable storage of a checksum. (Files may change or have changed. Later on,
             # we could try to keep a files modification date unless it is a nested PerlPoint
             # source or a dynamic Perl part. For now, it seems to be sufficient that each file
             # is cached itself.)
	     $flags{checksummed}=0;

             # temporarily activate specials "{" and "}"
             push(@specialStack, @specials{('{', '}')});
             @specials{('{', '}')}=(1, 1);
            }
	],
	[#Rule 125
		 'included', 3,
sub
#line 2205 "ppParser.yp"
{
             # restore special state of "{" and "}"
             @specials{('{', '}')}=splice(@specialStack, -2, 2);

             # check parameters: type and filename should be set at least
             my $errors;
             my %tagpars=@{$_[3][0]};
             $errors++, warn "[Error ", ++$semErr, "] $sourceFile, line $_[3][1]: You forgot to specify the type of your included file.\n" unless exists $tagpars{type};
             $errors++, warn "[Error ", ++$semErr, "] $sourceFile, line $_[3][1]: You forgot to specify the name of your included file.\n" unless exists $tagpars{file};
             $errors++, warn "[Error ", ++$semErr, "] $sourceFile, line $_[3][1]: Source file $tagpars{file} was already opened before.\n" if     exists $tagpars{file}
                                                                                                                                 and exists $openedSourcefiles{$tagpars{file}}
                                                                                                                                 and exists $tagpars{type}
                                                                                                                                 and $tagpars{type}=~/^pp$/;

             # PerlPoint headline offsets have to be positive numbers or certain strings
             $errors++, warn "[Error ", ++$semErr, "] $sourceFile, line $_[3][1]: Invalid headline level offset $tagpars{headlinebase}, positive number or keyword CURRENT_LEVEL expected.\n" if $tagpars{type}=~/^pp$/i and exists $tagpars{headlinebase} and $tagpars{headlinebase}!~/^\d+$/ and $tagpars{headlinebase}!~/^current_level$/i;
             $tagpars{headlinebase}=$flags{headlineLevel} if exists $tagpars{headlinebase} and $tagpars{headlinebase}=~/^current_level$/i;

             # all right?
             unless (defined $errors)
               {
                # check the filename
                if (-r $tagpars{file})
                  {
                   # check specified file type
                   if ($tagpars{type}=~/^pp$/i)
                     {
                      # we include a PerlPoint document, switch input handle (we intermediately have to close the original handle because of perl5.6.0 bugs)
                      unshift(@inHandles, [tell($inHandle), $_[0]->YYData->{INPUT}, basename($sourceFile), $lineNrs{$inHandle}, @flags{qw(headlineLevelOffset headlineLevel)}, cwd()]);
                      close($inHandle);
                      open($inHandle, $tagpars{file});
                      $_[0]->YYData->{INPUT}='';
                      $sourceFile=$tagpars{file};
                      $lineNrs{$inHandle}=0;

                      # change directory with file
                      chdir(dirname($tagpars{file}));

                      # open a new input stack
                      unshift(@inputStack, []);

                      # headline level offset declared?
                      $flags{headlineLevelOffset}=exists $tagpars{headlinebase} ? $tagpars{headlinebase} : 0;

                      # store the filename in the list of opened sources, to avoid circular reopening
                      # (it would be more perfect to store the complete path, is there a module for this?)
                      $openedSourcefiles{$tagpars{file}}=1;

                      # we have to supply something, but it should be nothing
                      [[()], $_[3][1]];
                     }
                   elsif ($flags{filter} and $tagpars{type}!~/^$flags{filter}$/i)
                     {
                      # this file does not need to be included, nevertheless
                      # we have to supply something - but it should be nothing
                      [[()], $_[3][1]];
                     }
                   elsif ($tagpars{type}=~/^perl$/i)
                     {
                      # Does the caller want to evaluate code?
                      if ($safeObject)
                        {
                         # evaluate the source code (for an unknown reason, we have to precede the constant by "&" here to work)
                         warn "[Info] Evaluating included Perl code.\n" unless $flags{display} & &DISPLAY_NOINFO;
                         my $result=$safeObject->rdo($tagpars{file});

                         # check result
                         if ($@)
                           {warn "[Error ", ++$semErr, "] $sourceFile, line $_[3][1]: included Perl code could not be evaluated: $@.\n";}
                         else
                           {
                            # success - make the result part of the input stream (by stack)
                            stackInput($_[0], split(/(\n)/, $result));

                            # reset the "end of input reached" flag if necessary
                            $readCompletely=0 if $readCompletely;
                           }
                        }

                      # we have to supply something, but it should be nothing
                      [[()], $_[3][1]];
                     }
                   else
                     {
                      # we include anything else: provide the contents as it is,
                      # declared as an "embedded" part
#                      open(my $included, $tagpars{file});
                      my $included=new IO::File;
                      open($included, $tagpars{file});
                      my @included=<$included>;
                      close($included);

                      [
                       [
                        # opener directive
                        [DIRECTIVE_TAG, DIRECTIVE_START, 'EMBED', {lang=>$tagpars{type}}],
                        # the list of enclosed "literals", if any
                        @included,
                        # final directive
                        [DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'EMBED', {lang=>$tagpars{type}}]
                       ],
                       $_[3][1]
                      ];
                     }
                  }
                else
                  {
                   # simply inform user
                   $errors++, warn "[Error ", ++$semErr, "] $sourceFile, line $_[3][1]: File $tagpars{file} does not exist or cannot be read (current directory: ", cwd(), ").\n";

                   # we have to supply something, but it should be nothing
                   [[()], $_[3][1]];
                  }
               }
             else
               {        
                # we have to supply something, but it should be nothing
                [[()], $_[3][1]];
               }
            }
	],
	[#Rule 126
		 '@25-1', 0,
sub
#line 2330 "ppParser.yp"
{
                     # switch to definition mode
                     stateManager(STATE_DEFINITION);

                     # trace, if necessary
                     warn "[Trace] $sourceFile, line $_[1][1]: Macro definition starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;
                    }
	],
	[#Rule 127
		 '@26-4', 0,
sub
#line 2338 "ppParser.yp"
{
                     # disable all specials to get the body as a plain text
                     @specials{keys %specials}=(0) x scalar(keys %specials);
                    }
	],
	[#Rule 128
		 'alias_definition', 6,
sub
#line 2343 "ppParser.yp"
{
                     # "text" already switched back to default mode (and disabled specials [{}:])

                     # trace, if necessary
                     warn "[Trace] $sourceFile, line $_[4][1]: Macro definition completed.\n" if $flags{trace} & TRACE_PARAGRAPHS;

                     # build macro text
                     shift(@{$_[6][0]}); splice(@{$_[6][0]}, -2, 2);
                     my $macro=join('', @{$_[6][0]});

                     # anything specified?
                     if ($macro=~/^\s*$/)
                       {
                        # nothing defined, should this line cancel a previous definition?
                        if (exists $macros{$_[3][0]})
                          {
                           # cancel macro
                           delete $macros{$_[3][0]};

                           # trace, if necessary
                           warn "[Trace] $sourceFile, line $_[4][1]: Macro \"$_[3][0]\" is cancelled.\n" if $flags{trace} & TRACE_SEMANTIC;
                          }
                        else
                          {
                           # trace, if necessary
                           warn "[Trace] $sourceFile, line $_[4][1]: Empty macro \"$_[3][0]\" is ignored.\n" if $flags{trace} & TRACE_SEMANTIC;
                          }
                       }
                     else
                       {
                        # ok, this is a new definition - get all used parameters
                        my %pars; 
                        @pars{($macro=~/__([^_\\]+)__/g)}=();

                        # tag body wildcard is no parameter
                        delete $pars{body};

                        # make guarded underscores just underscores
                        $macro=~s/\\_//g;

                        # store name, parameters and macro
                        $macros{$_[3][0]}=[[keys %pars], $macro];
                       }

                     # we have to supply something, but it should be nothing
                     # (this is a paragraph, so reply a plain string)
                     ['', $_[8][1]];
                    }
	]
],
                                  @_);
    bless($self,$class);
}

#line 2395 "ppParser.yp"



# ------------------------------------------
# Internal function: input stack management.
# ------------------------------------------
sub stackInput
 {
  # get parameters
  my ($parser, @lines)=@_;

  # declare variable
  my (@waiting);

  # the current input line becomes the last line to read in this set
  # (this way, we arrange it that additional text is exactly placed where its generator tag or macro stood,
  # without Ils confusion)
  push(@lines, (defined $parser->YYData->{INPUT} and $parser->YYData->{INPUT}) ? $parser->YYData->{INPUT} : ());

  # lines are expected to be generated by split(/(\n)/, ...) - recombine them
  # to place the newlines where they belong to (take care in loop counting - array size changes while looping!
  # - predeclare loop limit with original array size)
  my $lineNr=@lines;
  for (my $i=0; $i<$lineNr; $i+=2)
    {push(@waiting, join('', splice(@lines, 0, 2)));}

  # get next line to read
  my $newInputLine=shift(@waiting);

  # update (innermost) input stack
  unshift(@{$inputStack[0]}, @waiting);

  # make the new top line the current input
  $parser->YYData->{INPUT}=$newInputLine;
 }


# -----------------------------
# Internal function: the lexer.
# -----------------------------
sub lexer
 {
  # get parameters
  my ($parser)=@_;

  # scan for unlexed EOL´s which should be ignored
  while ($parser->YYData->{INPUT} and $parser->YYData->{INPUT}=~/^\n/ and $lexerFlags{eol}==LEXER_IGNORE)
    {
     # trace, if necessary
     warn "[Trace] Lexer: Ignored EOL in line $lineNrs{$inHandle}.\n" if $flags{trace} & TRACE_LEXER;
     
     # remove the ignored newline
     $parser->YYData->{INPUT}=~s/^\n//;
    }

  # get next symbol
  unless ($parser->YYData->{INPUT})
    {
      {
       # will the next line be get from the input stack instead of a real file?
       my $lineFromStack=scalar(@{$inputStack[0]});

       # get next input line
       unless (
                  (@{$inputStack[0]} and ($parser->YYData->{INPUT}=shift(@{$inputStack[0]}) or 1))
               or (defined($inHandle) and $parser->YYData->{INPUT}=<$inHandle>)
              )
         {
          # was this a nested source?
          unless (@inHandles)
            {
             # this was the base document: should we insert a final additional token?
             $readCompletely=1,
             (($flags{trace} & TRACE_LEXER) and warn("[Trace] Lexer: Final Empty_line in line $lineNrs{$inHandle}.\n")),
             return('Empty_line', ['', $lineNrs{$inHandle}]) unless $readCompletely;

             # well done
             return('', [undef, -1]);
            }
          else
            {
             # we finished a nested source: close it and restore
             # things to continue reading the enclosing file
             my ($helper1, $helper2, $helper3);
             ($helper1, $parser->YYData->{INPUT}, $sourceFile, $helper2, @flags{qw(headlineLevelOffset headlineLevel)}, $helper3)=@{shift(@inHandles)};
             $lineNrs{$inHandle}=$helper2-1; # -1 to compensate the subsequent increment
             # back to envelopes directory
             chdir($helper3);
             # reopen envelope file
             close($inHandle);
             $inHandle=new IO::File;
             open($inHandle, $sourceFile);
             seek($inHandle, $helper1, 0);

             # switch back to envelopes input stack
             shift(@inputStack);
            }
         }
     
       # update line counter
       $lineNrs{$inHandle}++;

       # ignore this line if wished
       $parser->YYData->{INPUT}='', redo if $flags{skipInput} and $parser->YYData->{INPUT}!~/^\?/;

       # if we are here, skip mode is leaved
       $flags{skipInput}=0;
     
       # add a line update hint
       push(@$resultStreamRef, [DIRECTIVE_NEW_LINE, DIRECTIVE_START, {file=>$sourceFile, line=>$lineNrs{$inHandle}}]) if $flags{linehints};

       # remove TRAILING whitespaces, but keep newlines (if any)
       {
        my $newline=($parser->YYData->{INPUT}=~/\n$/m);
        $parser->YYData->{INPUT}=~s/\s*$//;
        $parser->YYData->{INPUT}=join('', $parser->YYData->{INPUT}, "\n") if $newline;
       }

       # scan for empty lines as necessary
       if ($parser->YYData->{INPUT}=~/^$/)
         {
	  # update the checksum flags
	  $flags{checksum}=1 if $flags{cache} & CACHE_ON;

          # trace, if necessary
          warn "[Trace] Lexer: Empty_line in line $lineNrs{$inHandle}", $lexerFlags{el}==LEXER_IGNORE ? ' is ignored' : '', ".\n" if $flags{trace} & TRACE_LEXER;

          # update input line
          $parser->YYData->{INPUT}='';

          # sometimes empty lines have no special meaning
          $lexerFlags{el}==LEXER_IGNORE and redo;

          # but sometimes they are very special
          return('Empty_line', ["\n", $lineNrs{$inHandle}]);
         }
       else
	 {
	  # disable caching for embedded code containing empty lines
	  $flags{checksummed}=0 if $specials{embedded};

          # this may be the first line of a new paragraph to be checksummed
          if (
	          ($flags{cache} & CACHE_ON)
	      and $flags{checksum}
              and not $lineFromStack
	      and (not $specials{heredoc} or $specials{heredoc} eq '1')
              and not @tableSeparatorStack
              and not $specials{embedded}
	     )
	    {
	     # handle $/ locally
	     local($/);

             # update statistics
             $statistics{cache}[0]++;

	     # well, switch to paragraph mode (depending on the paragraph type)!
             if ($parser->YYData->{INPUT}=~/^<<(\w+)/)
	       {$/="\n$1";}
             elsif ($parser->YYData->{INPUT}=~/^(?<!\\)\\TABLE/i)
	       {$/="\n\\END_TABLE";}
	     else
	       {$/='';}

	     # store current position
             my $lexerPosition=tell($inHandle);

	     # read *current* paragraph completely (take care - we may have read it completely yet!)
	     seek($inHandle, $lexerPosition-length($parser->YYData->{INPUT}), 0) unless $parser->YYData->{INPUT}=~/^<<(\w+)/ or $parser->YYData->{INPUT}=~/^(?<!\\)\\TABLE/i;
	     my $paragraph=<$inHandle>;
	     $paragraph=join('', $parser->YYData->{INPUT}, $paragraph) if $parser->YYData->{INPUT}=~/^<<(\w+)/ or $parser->YYData->{INPUT}=~/^(?<!\\)\\TABLE/i;

	     # count the lines in the paragraph read
	     my $plines=0;
	     $plines++ while $paragraph=~/(\n)/g;
	     $plines-- unless $parser->YYData->{INPUT}=~/^<<(\w+)/ or $parser->YYData->{INPUT}=~/^(?<!\\)\\TABLE/i;

	     # remove trailing whitespaces (to avoid checksumming them)
	     $paragraph=~s/\n+$//;

	     # anything interesting found?
	     if (defined $paragraph)
	       {
		# build checksum (of paragraph *and* headline level offset)
		my $checksum=sha1_base64(join('+', exists $flags{headlineLevelOffset} ? $flags{headlineLevelOffset} : 0, $paragraph));
		
		# warn "---> Searching checksum for this paragraph:\n-----\n$paragraph\n- by $checksum --\n";
		# check paragraph to be known
		if (exists $checksums->{$sourceFile} and exists $checksums->{$sourceFile}{$checksum})
		  {
		   # Do *not* reset the checksum flag for new checksums - we already read the
                   # empty lines, and a new paragraph may follow! *But* deactivate the current
                   # checksum to avoid multiple storage - we already stored it, right?
		   $flags{checksummed}=0;

		   # reset input buffer - it is all handled (take care to remove a final newline
                   # if the paragraph was closed by a string - this would normally be read in a
                   # per line processing, but it remained in the file in paragraph mode)
                   $/="\n";
		   scalar(<$inHandle>) if $parser->YYData->{INPUT}=~/^<<(\w+)/ or $parser->YYData->{INPUT}=~/^(?<!\\)\\TABLE/i;
		   $parser->YYData->{INPUT}='';

		   # warn "===========> PARAGRAPH CACHE HIT!! ($lineNrs{$inHandle}/$sourceFile/$checksum) <=================\n$paragraph-----\n";
		   # use Data::Dumper; warn Dumper($checksums->{$sourceFile}{$checksum});

                   # update statistics
                   $statistics{cache}[1]++;
		   
		   # update line counter
                   # warn "----> Old line: $lineNrs{$inHandle}\n";
		   $lineNrs{$inHandle}+=$plines;
                   # warn "----> New line: $lineNrs{$inHandle}\n";

		   # The next steps depend - follow the provided hint. We may have to reinvoke
		   # the parser to restore a state.                   
# perl 5.6 #       unless (exists $checksums->{$sourceFile}{$checksum}[2])
                   unless (defined $checksums->{$sourceFile}{$checksum}[2])
		     {
		      # direct case - add the already known part directly to the stream
		      push(@$resultStreamRef, @{$checksums->{$sourceFile}{$checksum}[0]});

		      # Well done this paragraph - go on!
		      redo;
		     }
		   else
		     {
		      # more complex case - reinvoke the parser to update its states
		      return($checksums->{$sourceFile}{$checksum}[2], [dclone($checksums->{$sourceFile}{$checksum}[0]), $lineNrs{$inHandle}]);
		     }
		  }

                # flag that we are going to build an associated stream
		$flags{checksummed}=[$checksum, scalar(@$resultStreamRef), $plines];
		# warn "---> Started checksumming for\n-----\n$paragraph\n---(", $plines+1, " line(s))\n";
	       }

	     # reset file pointer
	     seek($inHandle, $lexerPosition, 0);
	    }

	  # update the checksum flag: we are *within* a paragraph, do not checksum
          # until we reach the next empty line
	  $flags{checksum}=0;
	 }

       # scan for herdoc close hints
       if ($specials{heredoc} and $specials{heredoc} ne '1' and $parser->YYData->{INPUT}=~/^($specials{heredoc})$/)
         {
          # trace, if necessary
          warn "[Trace] Lexer: Heredoc close hint $1 in line $lineNrs{$inHandle}.\n" if $flags{trace} & TRACE_LEXER;

          # update input line
          $parser->YYData->{INPUT}='';

          # reset heredoc setting
          $specials{heredoc}=1;

          # reply token
          return('Heredoc_close', [$1, $lineNrs{$inHandle}]);
         }

       # scan for indented lines, if necessary
       if ($parser->YYData->{INPUT}=~/^(\s+)/)
         {
          if ($lexerFlags{ils}==LEXER_TOKEN)
            {
             # trace, if necessary
             warn "[Trace] Lexer: Ils in line $lineNrs{$inHandle}.\n" if $flags{trace} & TRACE_LEXER;

             # update input buffer and reply the token (contents is necessary as well)
             my $ils=$1;
             $parser->YYData->{INPUT}=~s/^$1//; 
             return('Ils', [$ils, $lineNrs{$inHandle}]);
            }
          elsif ($lexerFlags{ils}==LEXER_IGNORE)
            {
             warn "[Trace] Lexer: Ils in line $lineNrs{$inHandle} is ignored.\n" if $flags{trace} & TRACE_LEXER;
             $parser->YYData->{INPUT}=~s/^(\s+)//;
            }
         }

       # scan for a new paragraph opened by a tag, if necessary
       if ($parserState==STATE_DEFAULT and $parser->YYData->{INPUT}=~/^\\/)
         {
          # remain in default state, but switch to its tag mode
          stateManager(STATE_DEFAULT_TAGMODE);
         }
      }
     }

  # reply a token
  for ($parser->YYData->{INPUT})
    {
     # declare scopies
     my ($found, $sfound);

     # trace, if necessary
     warn "[Trace] Lexing \"$_\".\n" if $flags{trace} & TRACE_LEXER;

     # check for table separators, if necessary (these are the most common strings)
     if (@tableSeparatorStack)
       {
        # check for a column separator
        s/^$tableSeparatorStack[0]//,
        (($flags{trace} & TRACE_LEXER) and warn("[Trace] Lexer: table column separator in line $lineNrs{$inHandle}.\n")),
        return('Table_separator', ['c', $lineNrs{$inHandle}]) if /^($tableSeparatorStack[0])/;

        # check for row separator
        s/^\n//,
        (($flags{trace} & TRACE_LEXER) and warn("[Trace] Lexer: table row separator in line $lineNrs{$inHandle}.\n")),
        return('Table_separator', ['r', $lineNrs{$inHandle}]) if /^(\n)/ and $tableColumns;
       }

     # reply next token: EOL?
     if (/^(\n)/)
       {
        if ($lexerFlags{eol}==LEXER_TOKEN)
          {
           $found=$1;
           warn("[Trace] Lexer: EOL in line $lineNrs{$inHandle}.\n") if $flags{trace} & TRACE_LEXER;
           s/^$1//;
           return('EOL', [$found, $lineNrs{$inHandle}]);
          }
        elsif ($lexerFlags{eol}==LEXER_EMPTYLINE)
          {
           # flag "empty line" as wished
           warn("[Trace] Lexer: EOL -> Empty_line in line $lineNrs{$inHandle}.\n") if $flags{trace} & TRACE_LEXER;
           s/^$1//;
           return('Empty_line', ['', $lineNrs{$inHandle}]);
          }
        elsif ($lexerFlags{eol}==LEXER_SPACE)
          {
           # flag "space" as wished and reply a simple whitespace
           warn("[Trace] Lexer: EOL -> Space in line $lineNrs{$inHandle}.\n") if $flags{trace} & TRACE_LEXER;
           s/^$1//;
           return('Space', [' ', $lineNrs{$inHandle}]);
          }
        else
          {die "[BUG] Unhandled EOL directive $lexerFlags{eol}.";}
       }

     # reply next token: scan for spaces
     $found=$1, s/^$1//,
     (($flags{trace} & TRACE_LEXER) and warn("[Trace] Lexer: Space in line $lineNrs{$inHandle}.\n")),
     return('Space', [$found, $lineNrs{$inHandle}]) if /^(\s+)/;

     # reply next token: scan for here doc openers
     $found=$1, s/^<<$1//,
     (($flags{trace} & TRACE_LEXER) and warn("[Trace] Lexer: Heredoc opener $found in line $lineNrs{$inHandle}.\n")),
     return('Heredoc_open', [$found, $lineNrs{$inHandle}]) if /^<<(\w+)/ and $specials{heredoc} eq '1';

     # reply next token: scan for SPECIAL tagnames: \TABLE
     $found=$1, s/^\\$1//,
     (($flags{trace} & TRACE_LEXER) and warn("[Trace] Lexer: Table starts in line $lineNrs{$inHandle}.\n")),
     return('Table', [$found, $lineNrs{$inHandle}]) if $specials{tag} and /^(?<!\\)\\(TABLE)/i;
     
     # reply next token: scan for SPECIAL tagnames: \END_TABLE
     $found=$1, s/^\\$1//,
     (($flags{trace} & TRACE_LEXER) and warn("[Trace] Lexer: Table completed in line $lineNrs{$inHandle}.\n")),
     return('Tabled', [$found, $lineNrs{$inHandle}])  if $specials{tag} and /^(?<!\\)\\(END_TABLE)/i;
     
     # reply next token: scan for SPECIAL tagnames: \EMBED
     $found=$1, s/^\\$1//,
     (($flags{trace} & TRACE_LEXER) and warn("[Trace] Lexer: Embedding starts in line $lineNrs{$inHandle}.\n")),
     return('Embed', [$found, $lineNrs{$inHandle}]) if $specials{tag} and /^(?<!\\)\\(EMBED)/i;
     
     # reply next token: scan for SPECIAL tagnames: \END_EMBED
     $found=$1, s/^\\$1//,
     (($flags{trace} & TRACE_LEXER) and warn("[Trace] Lexer: Embedding completed in line $lineNrs{$inHandle}.\n")),
     return('Embedded', [$found, $lineNrs{$inHandle}]) if $specials{embedded} and /^(?<!\\)\\(END_EMBED)/i;
     
     # reply next token: scan for SPECIAL tagnames: \INCLUDE
     $found=$1, s/^\\$1//,
     (($flags{trace} & TRACE_LEXER) and warn("[Trace] Lexer: Including starts in line $lineNrs{$inHandle}.\n")),
     return('Include', [$found, $lineNrs{$inHandle}]) if $specials{tag} and /^(?<!\\)\\(INCLUDE)/i;
     
     # reply next token: scan for tagnames
     $found=$1, s/^\\$1//,
     (($flags{trace} & TRACE_LEXER) and warn("[Trace] Lexer: Tag opener $found in line $lineNrs{$inHandle}.\n")),
     return('Tag_name', [$found, $lineNrs{$inHandle}]) if $specials{tag} and /^(?<!\\)\\(\w+)/ and (exists $tagsRef->{'\ACCEPT_ALL'} or exists $tagsRef->{$1} or exists $macros{$1});
     
     # reply next token: scan for special characters
     $found=$1, s/^\Q$1//,
     (($flags{trace} & TRACE_LEXER) and warn("[Trace] Lexer: Special $found in line $lineNrs{$inHandle}.\n")),
     return($found, [$found, $lineNrs{$inHandle}]) if /^(?<!\\)(\S)/ and exists $specials{$1} and $specials{$1};

     # reply next token: scan for definition list items
     $found=$1, s/^$1//,
     (($flags{trace} & TRACE_LEXER) and warn("[Trace] Lexer: Colon in line $lineNrs{$inHandle}.\n")),
     return('Colon', [$found, $lineNrs{$inHandle}]) if $specials{colon} and /^(?<!\\)(:)/;

     # reply next token: search for named variables
     $found=$1, s/^\$$1//,
     (($flags{trace} & TRACE_LEXER) and warn("[Trace] Lexer: Named variable \"$found\" in line $lineNrs{$inHandle}.\n")),
     return('Named_variable', [$found, $lineNrs{$inHandle}]) if /^(?<!\\)\$(\w+)/;

     # reply next token: search for symbolic variables
     $found=$1, s/^\${$1}//,
     (($flags{trace} & TRACE_LEXER) and warn("[Trace] Lexer: Symbolic variable \"$found\" in line $lineNrs{$inHandle}.\n")),
     return('Symbolic_variable', [$found, $lineNrs{$inHandle}]) if /^(?<!\\)\${(\w+)}/;

     # remove guarding \\, if necessary
     s/^\\// unless $specials{heredoc} or $parserState==STATE_EMBEDDING or $parserState==STATE_DEFINITION;

     # reply next token: scan for numbers, if necessary
     $found=$1, s/^$1//,
     (($flags{trace} & TRACE_LEXER) and warn("[Trace] Lexer: Number $found in line $lineNrs{$inHandle}.\n")),
     return('Number', [$found, $lineNrs{$inHandle}]) if $specials{number} and /^(\d+)/;

     # reply next token: scan for words
     $found=$1, s/^\Q$1//,
     (($flags{trace} & TRACE_LEXER) and warn("[Trace] Lexer: Word \"$found\" in line $lineNrs{$inHandle}.\n")),
     return('Word', [$found, $lineNrs{$inHandle}]) if /^(\w+)/;

     # reply next token: single character (declared as "word" as well)
     $found=$1, s/^\Q$1//,
     (($flags{trace} & TRACE_LEXER) and warn("[Trace] Lexer: Word \"$found\" in line $lineNrs{$inHandle}.\n")),
     return('Word', [$found, $lineNrs{$inHandle}]) if /^(\S)/;

     # everything should be handled - this code should never be executed!
     die "[BUG] $sourceFile, line $lineNrs{$inHandle}: No symbol found in \"$_\"!\n";
    }
 }

# ----------------------------------------------------------------------------------------------
# Internal function: error message display.
# ----------------------------------------------------------------------------------------------
sub _Error
 {
  warn "[Error] $sourceFile, line ${$_[0]->YYCurval}[1]", (exists $statistics{cache} and $statistics{cache}[1]) ? ' (or below because of cache hits)' : (), ": symbol \"", $_[0]->YYCurtok, '" is "', ${$_[0]->YYCurval}[0], "\", expected:\n", join("\nor ", sort $_[0]->YYExpect), ".\n";
 }

# ----------------------------------------------------------------------------------------------
# Internal function: state manager.
# ----------------------------------------------------------------------------------------------
sub stateManager
 {
  # get parameter
  my ($newState)=@_;

  # check parameter
  confess "[BUG] Invalid new state $newState passed.\n" unless    $newState==STATE_DEFAULT
                                                               or $newState==STATE_DEFAULT_TAGMODE
                                                               or $newState==STATE_TEXT
                                                               or $newState==STATE_UPOINT
                                                               or $newState==STATE_OPOINT
                                                               or $newState==STATE_DPOINT
                                                               or $newState==STATE_DPOINT_ITEM
                                                               or $newState==STATE_BLOCK
                                                               or $newState==STATE_VERBATIM
                                                               or $newState==STATE_EMBEDDING
                                                               or $newState==STATE_HEADLINE
                                                               or $newState==STATE_TABLE
                                                               or $newState==STATE_DEFINITION
                                                               or $newState==STATE_CONTROL
                                                               or $newState==STATE_COMMENT;

  # store the new state
  $parserState=$newState;

  # enter new state: default
  $newState==STATE_DEFAULT and do
    {
     # prepare lexer
     @lexerFlags{qw(ils eol el)}=(LEXER_TOKEN, LEXER_EMPTYLINE, LEXER_IGNORE);

     # activate special characters as necessary
     @specials{('/', '*', '#', '=', '<', '>', '{', '}' , '-', '?', '@', '+', 'heredoc', 'colon', 'tag', 'embedded', 'number')}=(1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0);

     # trace, if necessary
     warn "[Trace] Entered default state.\n" if $flags{trace} & TRACE_SEMANTIC;

     # well done
     return;
    };

  # enter new state: default in tag mode (same as default, but a paragraph starting with a tag delays switching to other
  # modes, so we have to explicitly disable the paragraph opener specials)
  $newState==STATE_DEFAULT_TAGMODE and do
    {
     # prepare lexer
     @lexerFlags{qw(ils eol el)}=(LEXER_TOKEN, LEXER_EMPTYLINE, LEXER_IGNORE);

     # activate special characters as necessary
     @specials{('/', '*', '#', '=', '<', '>', '{', '}' , '-', '?', '@', '+', 'heredoc', 'colon', 'tag', 'embedded', 'number')}=(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0);

     # trace, if necessary
     warn "[Trace] Entered default state in tag mode.\n" if $flags{trace} & TRACE_SEMANTIC;

     # well done
     return;
    };

  # enter new state: headline body
  $newState==STATE_HEADLINE and do
    {
     # prepare lexer
     @lexerFlags{qw(ils eol el)}=(LEXER_IGNORE, LEXER_SPACE, LEXER_TOKEN);

     # activate special characters as necessary
     @specials{('/', '*', '#', '=', '<', '>', '{', '}' , '-', '?', '@', '+', 'heredoc', 'colon', 'tag', 'embedded', 'number')}=(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0);

     # trace, if necessary
     warn "[Trace] Entered headline body state.\n" if $flags{trace} & TRACE_SEMANTIC;

     # well done
     return;
    };

  # enter new state: comment
  $newState==STATE_COMMENT and do
    {
     # prepare lexer
     @lexerFlags{qw(ils eol el)}=(LEXER_IGNORE, LEXER_EMPTYLINE, LEXER_IGNORE);

     # activate special characters as necessary
     @specials{('/', '*', '#', '=', '<', '>', '{', '}' , '-', '?', '@', '+', 'heredoc', 'colon', 'tag', 'embedded', 'number')}=(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

     # trace, if necessary
     warn "[Trace] Entered comment state.\n" if $flags{trace} & TRACE_SEMANTIC;

     # well done
     return;
    };

  # enter new state: text
  $newState==STATE_TEXT and do
    {
     # prepare lexer
     @lexerFlags{qw(ils eol el)}=(LEXER_IGNORE, LEXER_SPACE, LEXER_TOKEN);

     # activate special characters as necessary
     @specials{('/', '*', '#', '=', '<', '>', '{', '}' , '-', '?', '@', '+', 'heredoc', 'colon', 'tag', 'embedded', 'number')}=(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0);

     # trace, if necessary
     warn "[Trace] Entered text state.\n" if $flags{trace} & TRACE_SEMANTIC;

     # well done
     return;
    };

  # enter new state: text
  $newState==STATE_TABLE and do
    {
     # prepare lexer
     @lexerFlags{qw(ils eol el)}=(LEXER_SPACE, LEXER_TOKEN, LEXER_TOKEN);

     # activate special characters as necessary
     @specials{('/', '*', '#', '=', '<', '>', '{', '}' , '-', '?', '@', '+', 'heredoc', 'colon', 'tag', 'embedded', 'number')}=(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0);

     # trace, if necessary
     warn "[Trace] Entered table paragraph state.\n" if $flags{trace} & TRACE_SEMANTIC;

     # well done
     return;
    };

  # enter new state: text
  $newState==STATE_DEFINITION and do
    {
     # prepare lexer
     @lexerFlags{qw(ils eol el)}=(LEXER_IGNORE, LEXER_SPACE, LEXER_TOKEN);

     # activate special characters as necessary
     @specials{('/', '*', '#', '=', '<', '>', '{', '}' , '-', '?', '@', '+', 'heredoc', 'colon', 'tag', 'embedded', 'number')}=(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0);

     # trace, if necessary
     warn "[Trace] Entered macro definition state.\n" if $flags{trace} & TRACE_SEMANTIC;

     # well done
     return;
    };

  # enter new state: unordered list point - defined item
  ($newState==STATE_DPOINT_ITEM) and do
    {
     # prepare lexer
     @lexerFlags{qw(ils eol el)}=(LEXER_IGNORE, LEXER_SPACE, LEXER_TOKEN);

     # activate special characters as necessary
     @specials{('/', '*', '#', '=', '<', '>', '{', '}' , '-', '?', '@', '+', 'heredoc', 'colon', 'tag', 'embedded', 'number')}=(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0);

     # trace, if necessary
     warn "[Trace] Entered definition item state.\n" if $flags{trace} & TRACE_SEMANTIC;

     # well done
     return;
    };

  # enter new state: unordered list point
  ($newState==STATE_UPOINT or $newState==STATE_OPOINT or $newState==STATE_DPOINT) and do
    {
     # prepare lexer
     @lexerFlags{qw(ils eol el)}=(LEXER_IGNORE, LEXER_SPACE, LEXER_TOKEN);

     # activate special characters as necessary
     @specials{('/', '*', '#', '=', '<', '>', '{', '}' , '-', '?', '@', '+', 'heredoc', 'colon', 'tag', 'embedded', 'number')}=(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0);

     # trace, if necessary
     warn "[Trace] Entered point state.\n" if $flags{trace} & TRACE_SEMANTIC;

     # well done
     return;
    };

  # enter new state: block
  $newState==STATE_BLOCK and do
    {
     # prepare lexer
     @lexerFlags{qw(ils eol el)}=(LEXER_SPACE, LEXER_TOKEN, LEXER_TOKEN);

     # activate special characters as necessary
     @specials{('/', '*', '#', '=', '<', '>', '{', '}' , '-', '?', '@', '+', 'heredoc', 'colon', 'tag', 'embedded', 'number')}=(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0);

     # trace, if necessary
     warn "[Trace] Entered block state.\n" if $flags{trace} & TRACE_SEMANTIC;

     # well done
     return;
    };

  # enter new state: verbatim block
  $newState==STATE_VERBATIM and do
    {
     # prepare lexer
     @lexerFlags{qw(ils eol el)}=(LEXER_SPACE, LEXER_TOKEN, LEXER_TOKEN);

     # activate special characters as necessary
     @specials{('/', '*', '#', '=', '<', '>', '{', '}' , '-', '?', '@', '+', 'heredoc', 'colon', 'tag', 'embedded', 'number')}=(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0);

     # trace, if necessary
     warn "[Trace] Entered verbatim state.\n" if $flags{trace} & TRACE_SEMANTIC;

     # well done
     return;
    };

  # enter new state: embedding
  $newState==STATE_EMBEDDING and do
    {
     # prepare lexer
     @lexerFlags{qw(ils eol el)}=(LEXER_SPACE, LEXER_TOKEN, LEXER_TOKEN);

     # activate special characters as necessary
     @specials{('/', '*', '#', '=', '<', '>', '{', '}' , '-', '?', '@', '+', 'heredoc', 'colon', 'tag', 'embedded', 'number')}=(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0);

     # trace, if necessary
     warn "[Trace] Entered embedding state.\n" if $flags{trace} & TRACE_SEMANTIC;

     # well done
     return;
    };

  # enter new state: unordered list point
  $newState==STATE_CONTROL and do
    {
     # prepare lexer
     @lexerFlags{qw(ils eol el)}=(LEXER_IGNORE, LEXER_IGNORE, LEXER_TOKEN);

     # activate special characters as necessary
     @specials{('/', '*', '#', '=', '<', '>', '{', '}' , '-', '?', '@', '+', 'heredoc', 'colon', 'tag', 'embedded', 'number')}=(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

     # trace, if necessary
     warn "[Trace] Entered control state.\n" if $flags{trace} & TRACE_SEMANTIC;

     # well done
     return;
    };

  # check yourself
  confess "[BUG] Unhandled state $newState.\n";
 }


=pod

=head2 run()
This function starts the parser for a number of passed files.

B<Parameters:>
All parameters except of the I<object> parameter are named (pass them by hash).

=over 4

=item cache

This optional parameter controls source file paragraph caching.

By default, a source file is parsed completely everytime you pass it to the
parser. This is no problem with tiny sources but can delay your work if you
are dealing with large sources which have to be translated periodically into
presentations while they are written. Typically most of the paragraphs remain
unchanged from version to version, but nevertheless everything is usually
reparsed which means a waste of time. Well, to improve this a paragraph
cache can be activated by setting this option to B<CACHE_ON>.

The parser caches each I<initial source file> individually. That means that
if three files are passed to the parser with activated caching, three cache
files will be written. They are placed in the source file directory, named
.<source file>.ppcache. Please note that the paragraphs of I<included> sources
are cached in the cache file of the I<main> document because they may have to
be evaluated differently depending on inclusion context.

What acceleration can be expected? Well, this I<strongly>
depends on your source structure. Efficiency will grow with longer paragraphs,
reused paragraphs and paragraph number. It will be reduced by heavy usage
of active contents, macros and embedding because every paragraph that refers
to parts defined externally is not strongly determined by itself and therefore
it cannot be cached. Here is a list of all reasons which cause a paragraph to
be excluded from caching:

=over 4

=item Usage of variables

Every occurence of anything looking like a replacable variable (C<$var> or C<${var}>).
Even if this variable has no assigned value at caching time, this could have been
changed when the paragraph will be reread later.

=item Usage of macros

A macro means "unreproducable contents" because its definition is (potentially)
subject to changes.

=item Embedded parts

Obviously dynamic parts may change from one version to another, but even static
parts could have to be interpreted differently because a user can set up new
I<filter>s.

=item Included files

An \INCLUDE tag immediately disables caching for the paragraph it resides in
because the loaded file may change its contents. This is not really a
restriction because the included paragraphs themselves I<are> cached if possible.

=back

Even with all these restrictions about 50% of a real life document of more than
150 paragraphs (with a large number of used macros) could be cached. This saved
20% of the runtime in subsequent parser calls (with the I<pp2html> translator
by Lorenz Domke).

New cache entries are always I<added> which means that old entries are never
replaced and a cache file tends to grow. If you ever wish to clean up a
cache file completely pass B<CACHE_CLEANUP> to this option.

To deactivate caching explicitly pass B<CACHE_OFF>.
I<An existing cache will not be destroyed.>

Settings can be combined by I<addition>.

  # clean up the cache, then refill it
  cache => CACHE_CLEANUP+CACHE_ON,

  # clean up the cache and deactivate it
  cache => CACHE_CLEANUP+CACHE_OFF,

The B<CACHE_OFF> value is overwritten by any other setting.

It is suggested to make this setting available to translator users to let
them decide when a cache should be used.

I<Please note> that there is a problem with line numbers if paragraphs are
restored from cache because of the behaviour of perls paragraph mode. In this
mode, the <> operator reads in any number of newlines between paragraphs but
supplies only one of them. That is why I do not get the real number of lines
in a paragraph and therefore cannot store them. To work around this, two
strategies can be used. First, do not use more than exactly one newline
between paragraphs. (This strategy is not for real life users, of course,
but in this case restored numbers would be correct.) Second, remember that
source line numbers are only interesting in error messages. If the parser
detects an error, it therefore says: error "there or later" when a cache hit
already occured. If the real number is wished the parser could be reinvoked
then with deactivated cache and will report it.

I<Second note:> cache files are not locked while using them. If you need
this feature please let me know.

=item display

This parameter is optional. It controls the display of runtime messages
like informations or warnings. By default, all messages are displayed. You
can suppress these informations partially or completely by passing one or
more of the "DISPLAY_..." variables declared in B<PerlPoint::Constants>.
Constants should be combined by addition.

=item files

a reference to an array of files to be scanned.

=item filter

a regular expression describing the target language. This setting, if used,
prevents all embedded or included source code of other languages than the set
one from inclusion into the generated stream. This accelerates both parsing
and backend handling. The pattern is evaluated case insensitively.

 Example: pass "html|perl" to allow HTML and Perl.

To illustrate this, imagine a translator to PostScript. If it reads a Perl
Point file which includes native HTML, this translator cannot handle such code.
The backend would have to skip the HTML statements. With a "PostScript" filter,
the HTML code will not appear in the stream.

This enables PerlPoint texts prepared for various target languages. If an
author really needs plain target language code to be embedded into PerlPoint,
he could provide versions for various languages. Translators using a filter
will then receive exactly the code of their target language, if provided.

Please note that you cannot filter out PerlPoint code or files.

By default, no filter is set.

=item linehints

If set to a true value, the parser will embed line hints into the stream
whenever a new source line begins.

A line hint has the form

  [DIRECTIVE_NEW_LINE, DIRECTIVE_START, {file=>filename, line=>number}]

and is suggested to be handled by a backend callback.

Please note that currently source line numbers are not guaranteed to be
correct if stream parts are restored from I<cache> (see there for details).

The default value is 0.

=item object

the parser object made by I<new()>;

=item safe

an object of the B<Safe> class which comes with perl. It is used to evaluate
embedded Perl code in a safe environment. By letting the caller of I<run()>
provide this object, a translator author can make the level of safety fully
configurable by users. Usually, the following should work

  use Safe;
  ...
  $parser->run(safe=>new Safe, ...);

Active Perl contents is I<suppressed> if this setting is omitted or if anything
else than a B<Safe> object is passed. (There are currently three types of active
contents: embedded or included Perl and condition paragraphs.)

=item stream

A reference to an array where the generated output stream should be stored in.

Application programmers may want to tie this array if the target ASCII
texts are expected to be large (long ASCII texts can result in large stream
data which may occupy a lot of memory). Because of the fact that the parser
stores stream data I<by paragraph>, memory consumption can be reduced
significantly by tying the stream array.

It is recommended to pass an empty array. Stored data will not be overwritten,
the parser I<appends> its data instead (by push()).

=item tags

A reference to a hash which keys are the tags that should be recognized.
For example, pass "I", "B" and "C" to implement the well known POD tags.

Take care to pass capitalized tag keys only. Non capitalized keys cannot
be recognized by convention.

If a tag is discovered, the parser will produce an open and a close directive
in the output stream containing the tags name as stored in the hash. Look at
this example:

  # you pass
  tags => {I=>1, B=>1, C=>1},

  # the tags are recognized in a text like
  "... \I<bla \B<blu> \C<> blo>..."

  # for which the parser will produce something like
  ... [DIRECTIVE_TAG, DIRECTIVE_START, 'I']
  + "bla" + " "
  + [DIRECTIVE_TAG, DIRECTIVE_START, 'B']
  + "blu"
  + [DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'B']
  + " "
  + [DIRECTIVE_TAG, DIRECTIVE_START, 'C']
  + [DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'C']
  + " " + "blo"
  + [DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'I']

It is suggested to handle tags by backend callbacks.

The parser takes no attention to the hash I<values>.

Note that any tag that is not declared in this hash I<cannot> be discovered by
the parser and will not be passed to the stream - they are recognized as simple
strings (I<without> the leading backslash).

As a new experimental feature, this default behaviour can be modified. If a tag
name "\ACCEPT_ALL" is passed,
I<anything that looks like a tag will be recognized as a tag>. (Take care to
guard all backslashes which shall not start a tag or macro!) This feature is
built in to simplify processing by different backends which may implement different
tag sets.

=item trace

This parameter is optional. It is intended to activate trace code while the method
runs. You may pass any of the "TRACE_..." constants declared in B<PerlPoint::Constants>,
combined by addition as in the following example:

  # show the traces of both
  # lexical and syntactical analysis
  trace => TRACE_LEXER+TRACE_PARSER,

If you omit this parameter or pass TRACE_NOTHING, no traces will be displayed.

=item vispro

activates "process visualization" which simply means that a user will see
progress messages while the parser reads the documents. The I<numerical>
value of this setting determines how often the progress message shall be
updated by a I<paragraph interval>:

  # inform every five paragraphs
  vispro => 5,

Process visualization is automatically suppressed unless STDERR is
connected to a terminal, if this option is omitted, I<display> was set
to C<DISPLAY_NOINFO> or parser I<trace>s are activated.

=back

B<Return value:>
A "true" value in case of success, "false" otherwise. A call is performed
successfully if there was neither a syntactical nor a semantic error in the
parsed files.

B<Example:>

  $parser->run(
               stream  => \@streamData,
               tags    => \%tagHash,
               files   => \@ARGV,
               filter  => 'HTML',
               cache   => CACHE_ON,
               trace   => TRACE_PARAGRAPHS,
              );

=cut
sub run 
 {
  # get parameters
  my ($me, @pars)=@_;

  # build parameter hash
  confess "[BUG] The number of parameters should be even.\n" if @pars%2;
  my %pars=@pars;

  # and check parameters
  confess "[BUG] Missing object parameter.\n" unless $me;
  confess "[BUG] Object parameter is no ", __PACKAGE__, " object.\n" unless ref $me and ref $me eq __PACKAGE__;
  confess "[BUG] Missing stream array reference parameter.\n" unless $pars{stream};
  confess "[BUG] Stream array reference parameter is no array reference.\n" unless ref $pars{stream} and ref $pars{stream} eq 'ARRAY';
  confess "[BUG] Missing tag hash reference parameter.\n" unless $pars{tags};
  confess "[BUG] Tag hash reference parameter is no hash reference.\n" unless ref $pars{tags} and ref $pars{tags} eq 'HASH';
  confess "[BUG] Missing file list reference parameter.\n" unless $pars{files};
  confess "[BUG] File list reference parameter is no array reference.\n" unless ref $pars{files} and ref $pars{files} eq 'ARRAY';
  confess "[BUG] You should pass at least one file to parse.\n" unless @{$pars{files}};
  if (exists $pars{filter})
    {
     eval "'lang'=~/$pars{filter}/";
     confess "[BUG] Invalid filter expression \"$pars{filter}\": $@.\n" if $@;
    }

  # variables
  my ($rc)=(1);

  # init internal data
  (
   $tagsRef,                 #  1
   $resultStreamRef,         #  2
   $safeObject,              #  3
   $flags{trace},            #  4
   $flags{display},          #  5
   $flags{filter},           #  6
   $flags{linehints},        #  7
   $flags{cache},            #  8
   $flags{cached},           #  9
   $flags{vis},              # 10
  )=(
     $pars{tags},                                                             #  1
     $pars{stream},                                                           #  2
     (exists $pars{safe} and ref($pars{safe}) eq 'Safe') ? $pars{safe} : 0,   #  3
     exists $pars{trace} ? $pars{trace} : TRACE_NOTHING,                      #  4
     exists $pars{display} ? $pars{display} : DISPLAY_ALL,                    #  5
     exists $pars{filter} ? $pars{filter} : '',                               #  6
     (exists $pars{linehints} and $pars{linehints}),                          #  7
     exists $pars{cache} ? $pars{cache} : CACHE_OFF,                          #  8
     0,                                                                       #  9
     exists $pars{vispro} ? $pars{vispro} : 0,                                # 10
    );

  # init more
  @flags{qw(skipInput headlineLevelOffset headlineLevel)}=(0) x 3;

  # welcome user
  unless ($flags{display} & DISPLAY_NOINFO)
   {  
    print STDERR "[Info] The PerlPoint parser ";
    {
     no strict 'refs';
     print STDERR ${join('::', __PACKAGE__, 'VERSION')};
    }
    warn " starts.\n";
    warn "       Active contents is ", $safeObject ? 'evaluated' : 'ignored', ".\n";

    # report cache mode
    warn "       Paragraph cache is ", ($flags{cache} & CACHE_ON) ? '' : 'de', "activated.\n";
   }

  # save current directory
  my $startupDirectory=cwd();

  # scan all input files
  foreach my $file (@{$pars{files}})
    {
     # inform user
     warn "[Info] Processing $file ...\n" unless $flags{display} & DISPLAY_NOINFO;

     # init input stack
     @inputStack=([]);

     # update file hint
     $sourceFile=$file;

     # open file and make the new handle the parsers input
     open($inHandle, $file) or confess("[Fatal] Could not open input file $file.\n");

     # store the filename in the list of opened sources, to avoid circular reopening
     # (it would be more perfect to store the complete path, is there a module for this?)
     $openedSourcefiles{$file}=1;

     # change into the source directory
     chdir(dirname($file));

     # (cleanup and) read old checksums as necessary
     my $cachefile=sprintf(".%s.ppcache", basename($file));
     if (($flags{cache} & CACHE_CLEANUP) and -e $cachefile)
       {
	warn "       Resetting paragraph cache for $file.\n" unless $flags{display} & DISPLAY_NOINFO;
	unlink($cachefile);
       }
     $checksums=retrieve($cachefile) if ($flags{cache} & CACHE_ON) and -e $cachefile;
     #use Data::Dumper; warn Dumper($checksums);

     # store a document start directive (done here to save memory)
     push(@$resultStreamRef, [DIRECTIVE_DOCUMENT, DIRECTIVE_START, basename($file)]);

     # enter first (and most common) lexer state
     stateManager(STATE_DEFAULT);

     # flag that the next paragraph can be checksummed, if so
     $flags{checksum}=1 if $flags{cache} & CACHE_ON;

     # parse input
     $rc=($rc and $me->YYParse(yylex=>\&lexer, yyerror=>\&_Error, yydebug => ($flags{trace} & TRACE_PARSER) ? 0x1F : 0x00));

     # store a document completion directive (done here to save memory)
     push(@$resultStreamRef, [DIRECTIVE_DOCUMENT, DIRECTIVE_COMPLETE, basename($file)]);

     # reset the input handle and flags
     $readCompletely=0;

     # store checksums, if necessary
     store($checksums, $cachefile) if     ($flags{cache} & CACHE_ON)
                                      and $flags{cached}
                                      and defined $checksums and %$checksums;

     # close the input file
     close($inHandle);
     $inHandle=new IO::File;

     # back to startup directory
     chdir($startupDirectory);
    }

  # success?
  if ($rc and not $semErr)
    {
     # display a summary
     warn <<EOM unless $flags{display} & DISPLAY_NOINFO;

[Info] Input ok.

       Statistics:
       -----------
       ${\(statisticsHelper(DIRECTIVE_HEADLINE, 'headline'))},
       ${\(statisticsHelper(DIRECTIVE_TEXT, 'text'))},
       ${\(statisticsHelper(DIRECTIVE_UPOINT, 'unordered list point'))},
       ${\(statisticsHelper(DIRECTIVE_OPOINT, 'ordered list point'))},
       ${\(statisticsHelper(DIRECTIVE_DPOINT, 'definition list point'))},
       ${\(statisticsHelper(DIRECTIVE_BLOCK, 'block'))},
       ${\(statisticsHelper(DIRECTIVE_VERBATIM, 'verbatim block'))},
       ${\(statisticsHelper(DIRECTIVE_TAG, 'tag'))}
       ${\(statisticsHelper(DIRECTIVE_LIST_RSHIFT, 'right list shifter'))},
       ${\(statisticsHelper(DIRECTIVE_LIST_LSHIFT, 'left list shifter'))},
       and ${\(statisticsHelper(DIRECTIVE_COMMENT, 'comment'))} were detected in ${\(join('', scalar(@{$pars{files}}), ' file', @{$pars{files}}==1?'':'s'))}.

EOM

     # add cache informations, if necessary
     warn  ' ' x length('[Info] '), int(100*$statistics{cache}[1]/$statistics{cache}[0]+0.5), "% of all checked paragraphs were restored from cache.\n\n" if $flags{cache} & CACHE_ON and not $flags{display} & DISPLAY_NOINFO;
    }
  else
    {
     # display a summary
     warn "[Info] Input contains $semErr semantic error", $semErr>1?'s':'', ".\n" if $semErr;
    }

  # inform user
  warn "[Info] Parsing completed.\n" unless $flags{display} & DISPLAY_NOINFO;

  # reply success state
  $rc and not $semErr;
 }

# ------------------------------------------------------
# A tiny helper function intended for internal use only.
# ------------------------------------------------------
sub statisticsHelper
 {
  # get and check parameters
  my ($type, $string)=@_;
  confess "[BUG] Missing type parameter.\n" unless defined $type;
  confess "[BUG] Missing string parameter.\n" unless $string;

  # declare variables
  my ($nr)=(exists $statistics{$type} and $statistics{$type}) ? $statistics{$type} : 0;

  # reply resulting string
  join('', "$nr $string", $nr==1 ? '' : 's');
 }

sub updateChecksums
 {
  # get and check parameters
  my ($streamPart, $parserReinvokationHint)=@_;
  confess "[BUG] Missing stream part parameter.\n" unless defined $streamPart;
  confess "[BUG] Stream part parameter is no reference.\n" unless ref($streamPart);

  # certain paragraph types are not cached intentionally
  return if    not ($flags{cache} & CACHE_ON)
            or exists {
                       DIRECTIVE_COMMENT() => 1,
                      }->{$streamPart->[0][0]};

  if (exists $flags{checksummed} and $flags{checksummed})
    {
     $checksums->{$sourceFile}{$flags{checksummed}[0]}=[dclone($streamPart), $flags{checksummed}[2], $parserReinvokationHint ? $parserReinvokationHint : ()];
     # use Data::Dumper;
     # warn Dumper($streamPart);
     $flags{checksummed}=undef;

     # note that something new was cached
     $flags{cached}=1;
    }
 }

# reverse engineering handler: unexpected item
sub reverseUnexpected
 {
  # get parameters
  my ($opcode, $mode)=@_;

  # display a message
  warn "[Warn] Unexpected stream item $opcode / $mode in reverse engineering component.\n";
 }


# reverse simple token
sub reverseSimple
 {
  # get parameters
  my ($opcode, $mode, @contents)=@_;

  # just reply what you got
  $reversedInput.=join('', @contents);
 }


# reverse a tag
sub reverseTag
 {
  # get parameters
  my ($opcode, $mode, $tag, $settings)=@_;

  # act mode dependend (wrote "\\" not '\' for emacs parantheses match)
  $reversedInput.=join('', "\\", $tag, %$settings ? join('', '{', join(' ', (map {"$_=\"$settings->{$_}\""} keys %$settings)), '}') : '', '<') if $mode==DIRECTIVE_START;
  $reversedInput.='>' if $mode==DIRECTIVE_COMPLETE;
 }


1;


# = POD TRAILER SECTION =================================================================

=pod

=head1 EXAMPLE

The following code shows a minimal but complete parser.

  # pragmata
  use strict;

  # load modules
  use PerlPoint::Parser;

  # declare variables
  my (@streamData, %tagHash);

  # declare list of tag openers
  @tagHash{qw(B C I IMG E)}=();

  # build parser
  my ($parser)=new PerlPoint::Parser;
  # and call it
  $parser->run(
               stream  => \@streamData,
               tags    => \%tagHash,
               files   => \@ARGV,
              );

=head1 NOTES

=head2 Format

The PerlPoint format was initially designed by I<Tom Christiansen>,
who wrote an HTML slide generator for it, too.

I<Lorenz Domke> added a number of additional useful and interesting
features to the original implementation. At a certain point, we
decided to redesign the tool to make it a base for slide generation
not only into HTML but into various document description languages.

The PerlPoint format implemented by this parser version is slightly
different from the original design. Presentations written for Perl
Point 1.0 will I<not> pass the parser but can simply be converted
into the new format. We designed the new format as a team of
I<Lorenz Domke>, I<Stephen Riehm> and me.

=head2 Storable updates

From version 0.24 on the Storable module is a prerequisite of the
parser package because Storable is used to store and retrieve cache
data in files. If you update your Storable installation it I<might>
happen that its internal format changes and therefore stored cache
data becomes unreadable. Simply remove the cache files (see I<FILES>)
and rerun the parser to rebuild the cache, or call the parsers C<run()>
method with C<cache> set to C<CACHE_CLEAN> for the same effect.

=head1 FILES

If I<cache>s are used, the parser writes cache files where the initial
sources are stored. They are named .<source file>.ppcache.

=head1 SEE ALSO

=over 4

=item PerlPoint::Constants

Constants used by parser functions and in the I<STREAM FORMAT>.

=item PerlPoint::Backend

A frame class to write backends basing on the I<STREAM OUTPUT>.

=item pp2html

The inital PerlPoint tool designed and provided by Tom Christiansen. A new translator
by I<Lorenz Domke> using B<PerlPoint::Package>.

=back

=head1 AUTHOR

Copyright (c) Jochen Stenzel (perl@jochen-stenzel.de), 1999-2000. All rights reserved.

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

=cut

1;
