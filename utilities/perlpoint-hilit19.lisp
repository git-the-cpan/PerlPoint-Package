
;; = HISTORY SECTION =====================================================================

;; ---------------------------------------------------------------------------------------
;; version | date     | author   | changes
;; ---------------------------------------------------------------------------------------
;; 0.02    |09.06.2001| JSTENZEL | variables can contain umlauts now, adapted;
;; 0.01    | 2000     | JSTENZEL | new.
;; ---------------------------------------------------------------------------------------

;; = CODE SECTION ========================================================================


;; This piece of code is an example how Emacs'
;; hilit19 module could be extended for a
;; perlpoint-mode. This is no part of Emacs.
;;
;; Copyright (C) 2001 Jochen Stenzel (perl@jochen-stenzel.de).
(
 hilit-set-mode-patterns 'perlpoint-mode

 '(
   ;; comment
   ("^//.*$" nil comment)

   ;; variable definition
   ("^\\$[_A-Za-z0-9‰ˆ¸ƒ÷‹ﬂ]+=" nil define)

   ;; variable usage
   ("\\$[_A-Za-z0-9‰ˆ¸ƒ÷‹ﬂ]+" nil define)
   ("\\$\\{[_A-Za-z0-9‰ˆ¸ƒ÷‹ﬂ]+\\}" nil define)

   ;; headline
   ("^=+.+$" nil label)

   ;; list points
   ("^*" nil error)
   ("^##?" nil error)
   ("^:.+:" nil error)

   ;; alias definition
   ("^\\++.+$" nil defun)

   ;; tags (closing angle bracket definition is too common, but as a first trial ...)
   ("\\\\[_A-Z0-9]+\\(\\{.+\\}\\)?<?" nil keyword)
   (">" nil keyword)
  )
)


