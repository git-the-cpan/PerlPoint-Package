

=Tags in general

Tags are \I<directives> embedded into the text stream, commanding how certain
parts of the text should be interpreted. The general syntax is
\B<\<name\>{\<options\>}{\<body\>}>. Whether a part is optional or not depends
on the tag (at least a tag name is required ;-).

A \B<tag name> is made of a backslash and a number of alphanumeric characters
(usually capitals):

  \\TAG

B<Tag options> can be optional (see the specific tags documentation). They follow
the tag name immediately, enclosed by a pair of corresponding curly braces. Each
option is a simple string assignment. The value should be quoted if \C</^\\w+$/> does
not match it. Option settings are separated by whitespace(s).

  \\TAG{par1=value1 par2="www.perl.com" par3="words and blanks"}

The \I<tag body> may be optional. If used, it is anything you want to make the tag
valid for. It immediately follows the optional parameters, enclosed by angle brackets:

  \\TAG<body>
  Tag bodies \\TAG<can
  be multilined>.
  \\TAG{par=value}<body>

Tags can be \I<nested>.

  \\TAG1<\\TAG2<body>>

\I<Every PerlPoint translator defines its own tags>, but usually all of them support
\C<\\I>, \C<\\B>, \C<\\C> and \C<\\IMAGE> as a base set. Additionally, there are a few
reserved tags which are implemented by \I<every> translator. See the next section for
details.

=Special purpose tags

* provide additional source control and

* allow target format specific source parts and

* implement structured formatting;

* can be used whereever tags in general are valid;

* currently are \C<\\INCLUDE>, \C<\\EMBED> and \C<\\END_EMBED>, \C<\\TABLE> and \C<\\END_TABLE>;

==File inclusion

It is possible to include another file by \B<\\INCLUDE{file=\<filename\> type=\<type\>}>.
The nesting level is umlimited, but every file is \I<read only once> (to avoid confusion by
circular nesting).

The mandatory base options are

@|
option | description
file   | names the source to be included (should exist)
type   | determines how the file is handled

All types different from \C<"pp"> or \C<"perl"> make the included file be read but not evaluated.
The read contents is usually passed to the generated output file directly. This is useful
to include target language specific, preformatted parts.

  \\INCLUDE<type=html file=homepage>

A certain translator typically supports the file types of its target language, see the
translator specific documentation for details.


===Including nested PerlPoint sources

If the type of an included file is specified as \C<"PP">, the file contents is
made part of the presentation source.

In this case a special tag option \C<"headlinebase"> can be specified to define a headline
base level used as an offset to all headlines in the included document.

<<EOE
 If "\INCLUDE{type=PP file=file headlinebase=20}" is
 specified and "file" contains a one level headline
 like "=Main topic of special explanations"
 this headline is detected with a level of 21.
EOE

Pass the special keyword \C<CURRENT_LEVEL> to this tag option if you want to
set just the \I<current> headline level as an offset. This results in
"subchapters".

<<EOE
 If "\INCLUDE{type=PP file=file headlinebase=CURRENT_LEVEL}"
 is specified in a chapter of level 4 and "file" contains a
 one level headline like "=Main topic of special explanations"
 this headline is detected with a level of 5.
EOE

A given offset is reset when the included document is parsed completely.

The \C<"headlinebase"> feature makes it easier to share partial documents with others,
or to build complex documents by including seperately maintained parts, or to include
one and the same part at different headline levels.

A PerlPoint file can be included wherever a tag is allowed, but sometimes
it has to be arranged slightly: if you place the inclusion directive at
the beginning of a new paragraph \I<and> your included PerlPoint starts by
a paragraph of another type than text, you should begin the included file
by an empty line to let the parser detect the correct paragraph type. Here
is an example: if the inclusion directive is placed like

  // include PerlPoint
  \\INCLUDE{type=pp file="file.pp"}

and \C<file.pp> immediately starts with a verbatim block like

  <<VERBATIM
      verbatim
  VERBATIM

, \I<the inclusion directive already opens a new paragraph> which is detected to
be \I<text> (because there is no special startup character). Now in the included
file, from the parsers point of view the included PerlPoint is simply a
continuation of this text, because a paragraph ends with an empty line. This
trouble can be avoided by beginning such an included file by an empty line,
so that its first paragraph can be detected correctly.

===Including Perl

The second special case of inclusion is a file type of \C<"Perl">.

  // include PerlPoint
  \\INCLUDE{type=perl file="dynamicPP.pl"}

\B<Inluded Perl is \I<active contents> - see the special chapter about it.>

\I<If> active contents is enabled, included Perl code is evaluated. The code is
expected to produce a PerlPoint string which then replaces the inclusion tag and
is read like static PerlPoint.

If the included code fails, an error message is displayed and the result is
ignored.

==Embedded code

Target format code does not necessarily need to be imported by file - it can be
directly \I<embedded> as well. This means that one can write target language
code within the input stream using \C<\\EMBED>, maybe because you miss a certain
feature in the current translator version:

<<EOE

  \EMBED{lang=HTML}
  This is <i><b>embedded</b> HTML</i>. The parser detects <i>no</i>
  Perl Point tag here, except of <b>END_EMBED</b>.
  \END_EMBED

EOE

The mandatory \I<lang> option specifies which language the embedded code is of.
Usually a translator only supports its own target format to be embedded.
(You will not be surprised that language values of \C<"perl"> and \C<"pp"> are special
cases - see the related subsections.)

Please note that the \C<\\EMBED> tag does not accept a tag body to avoid
ambiguities. Use \C<\\END_EMBED> to flag where the embedded code is completed.
\I<It is the only recognized tag therein.>

Because embedding is not implemented by a paragraph but by a \I<tag>, \\EMBED
can be placed \I<directly> in a text like this:

<<EOE
  These \EMBED{lang=HTML}<i>italics</i>\END_EMBED are formatted
  by HTML code.
EOE

===Embedding PerlPoint into PerlPoint

This is just for fun. Set the \C<"lang"> option to \C<"pp"> to try it:

<<EOE
  Perl Point \EMBED{lang=pp}can \EMBED{lang=pp}be
  \EMBED{lang=pp}nested\END_EMBED\END_EMBED\END_EMBED.
EOE

===Embedding Perl

This feature offers dynamic PerlPoint generation at \I<translation time>.

  \\EMBED{lang=perl}hello\\END_EMBED

\B<Embedded Perl is \I<active contents> - see the special chapter about it.>

\I<If> active contents is enabled, embedded Perl code is evaluated. The code is
expected to produce a PerlPoint string which then replaces the inclusion tag and
is read like static PerlPoint.

If the included code fails, an error message is displayed and the result is
ignored.

Here's another example:

<<EOE

  \EMBED{lang=PERL}

  # build a message
  my $msg="Perl may be embedded as well.";

  # and supply it
  $msg;

  \END_EMBED

EOE

The feature is of course more powerful. You may generate images at translation
time and include them, scan the disk and include a formatted listing, download
data from a webserver and make it part of your presentation, autoformat complex
data, include formatted source code, keep your presentation up to date in any
way and so on.


==Tables by tag

It was mentioned in the \I<paragraph> chapter that tables can be built by table
paragraphs. Well, there is a tag variant of this:

<<EOE

  \TABLE{bg=blue separator="|" border=2}
  \B<column 1>  |  \B<column 2>  | \B<column 3>
     aaaa       |     bbbb       |  cccc
     uuuu       |     vvvv       |  wwww
  \END_TABLE

EOE

\C<\\TABLE> opens the table, while \C<\\END_TABLE> closes it. All enclosed lines
are evaluated as table rows. \I<It is important to use a line per row - a stream syntax
is not implemented yet.>

This tags are sligthly more powerfull than the paragraph syntax: you can set
up several table features like the border width yourself, and you can
format the headlines as you like.

Here is a list of basically supported tag options (by table):

@|
option     | description
separator  | a string separating the table \I<columns> (may contain more than one character)

More options may be supported by your PerlPoint translator software.

