

=IMAGE

The \B<\\IMAGE> tag includes an image.


\B<Syntax>

\\IMAGE{options}


\B<Options>

This tag supports various options. Unless explicitly noted, all options are optional.

\I<Basic options>

These options are supported by all translators.

:\B<src>:This is the most important and therefore \B<mandatory> option, setting up
         the pathname of the image file.
         The path can be \I<relative> or \I<absolute>. Relative pathes are relative to the
         document \I<containing the tag>. (This means if documents are nested and the
         nested source contains this tag, relative pathes will still be relative to
         the path of this nested source. This way it is possible to bundle partial
         documents with their images.)
         The image file is checked for existence when the tag is parsed. A missed
         file causes a semantic error.

  // an absolute image path
  \\IMAGE{src="\B</images/>image.gif"}

  // relative image pathes
  \\IMAGE{src="image.gif"}
  \\IMAGE{src="../image.gif"}
  \\IMAGE{src="images/image.gif"}


\I<Additional options>

Several translators may extend the set of supported options.

Note: \I<If you make this document part of your translators documentation please modify
      this section according to your implementation. For example, you may continue this
      section by saying something like "pp2xy also handles ..." In any case, remove
      this note.>



\B<Body>

No body is allowed. A used body will not be recognized as a body of this tag.


\B<Notes>

\B<\\IMAGE> is part of the \I<basic tag set> supported by \I<all> PerlPoint translators.


\B<Example>

This simple example

  Look at this \\IMAGE{src="image.gif"}.

produces something like

  Look at this \IMAGE{src="image.gif"}.


\B<See also>

More basic set tags: \B<\\B>, \B<\\C>, \B<\\I> and \B<\\READY>.

