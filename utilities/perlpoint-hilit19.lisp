

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
   ("^\\$[_A-Za-z0-9]+=" nil define)

   ;; variable usage
   ("\\$[_A-Za-z0-9]+" nil define)
   ("\\$\\{[_A-Za-z0-9]+\\}" nil define)

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


