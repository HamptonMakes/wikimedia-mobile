;;; haml-mode.el --- Major mode for editing Haml files

;; Copyright (c) 2007, 2008 Nathan Weizenbaum

;; Author: Nathan Weizenbaum
;; URL: http://github.com/nex3/haml/tree/master
;; Version: 1.0
;; Keywords: markup, language

;;; Commentary:

;; Because Haml's indentation schema is similar
;; to that of YAML and Python, many indentation-related
;; functions are similar to those in yaml-mode and python-mode.

;; To install, save this on your load path and add the following to
;; your .emacs file:
;;
;; (require 'haml-mode)

;;; Code:

(eval-when-compile (require 'cl))
(require 'ruby-mode)

;; User definable variables

(defgroup haml nil
  "Support for the Haml template language."
  :group 'languages
  :prefix "haml-")

(defcustom haml-mode-hook nil
  "Hook run when entering Haml mode."
  :type 'hook
  :group 'haml)

(defcustom haml-indent-offset 2
  "Amount of offset per level of indentation."
  :type 'integer
  :group 'haml)

(defcustom haml-backspace-backdents-nesting t
  "Non-nil to have `haml-electric-backspace' re-indent all code
nested beneath the backspaced line be re-indented along with the
line itself."
  :type 'boolean
  :group 'haml)

(defface haml-tab-face
  '((((class color)) (:background "hotpink"))
    (t (:reverse-video t)))
  "Face to use for highlighting tabs in Haml files."
  :group 'faces
  :group 'haml)

(defvar haml-indent-function 'haml-indent-p
  "This function should look at the current line and return t
if the next line could be nested within this line.

The function can also return a positive integer to indicate
a specific level to which the current line could be indented.")

(defvar haml-block-openers
  `("^ *\\([%\\.#][a-z0-9_:\\-]*\\)+\\({.*}\\)?\\(\\[.*\\]\\)?[><]*[ \t]*$"
    "^ *[&!]?[-=~].*do[ \t]*\\(|.*|[ \t]*\\)?$"
    ,(concat "^ *[&!]?[-=~][ \t]*\\("
             (regexp-opt '("if" "unless" "while" "until" "else"
                           "begin" "elsif" "rescue" "ensure" "when"))
             "\\)")
    "^ */\\(\\[.*\\]\\)?[ \t]*$"
    "^ *-#"
    "^ *:")
  "A list of regexps that match lines of Haml that could have
text nested beneath them.")

;; Font lock

(defun haml-nested-regexp (re)
  (concat "^\\( *\\)" re "\\(\n\\(?:\\(?:\\1 .*\\| *\\)\n\\)*\\(?:\\1 .*\\| *\\)?\\)?"))

(defconst haml-font-lock-keywords
  `((,(haml-nested-regexp "\\(?:-#\\|/\\).*")  0 font-lock-comment-face)
    (,(haml-nested-regexp ":\\w+") 0 font-lock-string-face)
    (haml-highlight-interpolation  1 font-lock-variable-name-face prepend)
    (haml-highlight-ruby-tag       1 font-lock-preprocessor-face)
    (haml-highlight-ruby-script    1 font-lock-preprocessor-face)
    ("^ *\\(\t\\)"                 1 'haml-tab-face)
    ("^!!!.*"                      0 font-lock-constant-face)
    ("| *$"                        0 font-lock-string-face)))

(defconst haml-filter-re "^ *:\\w+")
(defconst haml-comment-re "^ *\\(?:-\\#\\|/\\)")

(defun haml-fontify-region-as-ruby (beg end)
  "Use Ruby's font-lock variables to fontify the region between BEG and END."
  (save-excursion
    (save-match-data
      (let ((font-lock-keywords ruby-font-lock-keywords)
            (font-lock-syntactic-keywords ruby-font-lock-syntactic-keywords)
            font-lock-keywords-only
            font-lock-extend-region-functions
            font-lock-keywords-case-fold-search)
        ;; font-lock-fontify-region apparently isn't inclusive,
        ;; so we have to move the beginning back one char
        (font-lock-fontify-region (- beg 1) end)))))

(defun haml-highlight-ruby-script (limit)
  "Highlight a Ruby script expression (-, =, or ~)."
  (when (re-search-forward "^ *\\(-\\|[&!]?[=~]\\) \\(.*\\)$" limit t)
    (haml-fontify-region-as-ruby (match-beginning 2) (match-end 2))))

(defun haml-highlight-ruby-tag (limit)
  "Highlight Ruby code within a Haml tag.

This highlights the tag attributes and object refs of the tag,
as well as the script expression (-, =, or ~) following the tag.

For example, this will highlight all of the following:
  %p{:foo => 'bar'}
  %p[@bar]
  %p= 'baz'
  %p{:foo => 'bar'}[@bar]= 'baz'"
  (when (re-search-forward "^ *[%.#]" limit t)
    (let ((eol (save-excursion (end-of-line) (point))))
      (forward-char -1)

      ;; Highlight tag, classes, and ids
      (while (looking-at "[.#%][a-z0-9_:\\-]*")
        (put-text-property (match-beginning 0) (match-end 0) 'face
                           (case (char-after)
                             (?% font-lock-function-name-face)
                             (?# font-lock-keyword-face)
                             (?. font-lock-type-face)))
        (goto-char (match-end 0)))

      ;; Highlight obj refs
      (when (eq (char-after) ?\[)
        (let ((beg (point)))
          (haml-limited-forward-sexp eol)
          (haml-fontify-region-as-ruby beg (point))))

      ;; Highlight attr hashes
      (when (eq (char-after) ?\{)
        (let ((beg (point)))
          (haml-limited-forward-sexp eol)

          ;; Check for multiline
          (while (and (eolp) (eq (char-before) ?,) (not (eobp)))
            (forward-line)
            (let ((eol (save-excursion (end-of-line) (point))))
              ;; If no sexps are closed,
              ;; we're still continuing a  multiline hash
              (if (>= (car (parse-partial-sexp (point) eol)) 0)
                  (end-of-line)
                ;; If sexps have been closed,
                ;; set the point at the end of the total sexp
                (goto-char beg)
                (haml-limited-forward-sexp eol))))

          (haml-fontify-region-as-ruby (+ 1 beg) (point))))

      ;; Move past end chars
      (when (looking-at "[<>&!]+") (goto-char (match-end 0)))
      ;; Highlight script
      (if (looking-at "\\([=~]\\) \\(.*\\)$")
          (haml-fontify-region-as-ruby (match-beginning 2) (match-end 2))
        ;; Give font-lock something to highlight
        (forward-char -1)
        (looking-at "\\(\\)"))
      t)))

(defun haml-highlight-interpolation (limit)
  "Highlight Ruby interpolation (#{foo})."
  (when (re-search-forward "\\(#{\\)" limit t)
    (save-match-data
      (forward-char -1)
      (let ((beg (point)))
        (haml-limited-forward-sexp limit)
        (haml-fontify-region-as-ruby (+ 1 beg) (point)))

      (when (eq (char-before) ?})
        (put-text-property (- (point) 1) (point)
                           'face font-lock-variable-name-face))
      t)))

(defun haml-limited-forward-sexp (limit &optional arg)
  "Move forward using `forward-sexp' or to limit,
whichever comes first."
  (let (forward-sexp-function)
    (condition-case err
        (save-restriction
          (narrow-to-region (point) limit)
          (forward-sexp arg))
      (scan-error
       (unless (equal (nth 1 err) "Unbalanced parentheses")
         (signal 'scan-error (cdr err)))
       (goto-char limit)))))

(defun* haml-extend-region-filters-comments ()
  "Extend the font-lock region to encompass filters and comments."
  (let ((old-beg font-lock-beg)
        (old-end font-lock-end))
    (save-excursion
      (goto-char font-lock-beg)
      (beginning-of-line)
      (unless (or (looking-at haml-filter-re)
                  (looking-at haml-comment-re))
        (return-from haml-extend-region-filters-comments))
      (setq font-lock-beg (point))
      (haml-forward-sexp)
      (beginning-of-line)
      (setq font-lock-end (max font-lock-end (point))))
    (or (/= old-beg font-lock-beg)
        (/= old-end font-lock-end))))

(defun* haml-extend-region-multiline-hashes ()
  "Extend the font-lock region to encompass multiline attribute hashes."
  (let ((old-beg font-lock-beg)
        (old-end font-lock-end))
    (save-excursion
      (goto-char font-lock-beg)
      (let ((attr-props (haml-parse-multiline-attr-hash))
            multiline-end)
        (when attr-props
          (setq font-lock-beg (cdr (assq 'point attr-props)))

          (end-of-line)
          ;; Move through multiline attrs
          (when (eq (char-before) ?,)
            (save-excursion
              (while (progn (end-of-line) (eq (char-before) ?,) (not (eobp)))
                (forward-line))

              (forward-line -1)
              (end-of-line)
              (setq multiline-end (point))))

          (goto-char (+ (cdr (assq 'point attr-props))
                        (cdr (assq 'hash-indent attr-props))
                        -1))
          (haml-limited-forward-sexp
           (or multiline-end
               (save-excursion (end-of-line) (point))))
          (setq font-lock-end (max font-lock-end (point))))))
    (or (/= old-beg font-lock-beg)
        (/= old-end font-lock-end))))


;; Mode setup

(defvar haml-mode-syntax-table
  (let ((table (make-syntax-table)))
    (modify-syntax-entry ?: "." table)
    (modify-syntax-entry ?_ "w" table)
    table)
  "Syntax table in use in haml-mode buffers.")

(defvar haml-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map [backspace] 'haml-electric-backspace)
    (define-key map "\C-?" 'haml-electric-backspace)
    (define-key map "\C-c\C-f" 'haml-forward-sexp)
    (define-key map "\C-c\C-b" 'haml-backward-sexp)
    (define-key map "\C-c\C-u" 'haml-up-list)
    (define-key map "\C-c\C-d" 'haml-down-list)
    (define-key map "\C-c\C-k" 'haml-kill-line-and-indent)
    (define-key map "\C-c\C-r" 'haml-output-region)
    (define-key map "\C-c\C-l" 'haml-output-buffer)
    map))

;;;###autoload
(define-derived-mode haml-mode fundamental-mode "Haml"
  "Major mode for editing Haml files.

\\{haml-mode-map}"
  (set-syntax-table haml-mode-syntax-table)
  (add-to-list 'font-lock-extend-region-functions 'haml-extend-region-filters-comments)
  (add-to-list 'font-lock-extend-region-functions 'haml-extend-region-multiline-hashes)
  (set (make-local-variable 'font-lock-multiline) t)
  (set (make-local-variable 'indent-line-function) 'haml-indent-line)
  (set (make-local-variable 'indent-region-function) 'haml-indent-region)
  (set (make-local-variable 'parse-sexp-lookup-properties) t)
  (setq comment-start "-#")
  (setq indent-tabs-mode nil)
  (setq font-lock-defaults '((haml-font-lock-keywords) t t)))

;; Useful functions

(defun haml-comment-block ()
  "Comment the current block of Haml code."
  (interactive)
  (save-excursion
    (let ((indent (current-indentation)))
      (back-to-indentation)
      (insert "-#")
      (newline)
      (indent-to indent)
      (beginning-of-line)
      (haml-mark-sexp)
      (haml-reindent-region-by haml-indent-offset))))

(defun haml-uncomment-block ()
  "Uncomment the current block of Haml code."
  (interactive)
  (save-excursion
    (beginning-of-line)
    (while (not (looking-at haml-comment-re))
      (haml-up-list)
      (beginning-of-line))
    (haml-mark-sexp)
    (kill-line 1)
    (haml-reindent-region-by (- haml-indent-offset))))

(defun haml-replace-region (start end)
  "Replaces the current block of Haml code with the HTML equivalent."
  (interactive "r")
  (save-excursion
    (goto-char end)
    (setq end (point-marker))
    (goto-char start)
    (let ((ci (current-indentation)))
      (while (re-search-forward "^ +" end t)
        (replace-match (make-string (- (current-indentation) ci) ? ))))
    (shell-command-on-region start end "haml" "haml-output" t)))

(defun haml-output-region (start end)
  "Displays the HTML output for the current block of Haml code."
  (interactive "r")
  (kill-new (buffer-substring start end)) 
  (with-temp-buffer
    (yank)
    (haml-indent-region (point-min) (point-max))
    (shell-command-on-region (point-min) (point-max) "haml" "haml-output")))

(defun haml-output-buffer ()
  "Displays the HTML output for entire buffer."
  (interactive)
  (haml-output-region (point-min) (point-max)))

;; Navigation

(defun haml-forward-through-whitespace (&optional backward)
  "Move the point forward at least one line, until it reaches
either the end of the buffer or a line with no whitespace.

If `backward' is non-nil, move the point backward instead."
  (let ((arg (if backward -1 1))
        (endp (if backward 'bobp 'eobp)))
    (loop do (forward-line arg)
          while (and (not (funcall endp))
                     (looking-at "^[ \t]*$")))))

(defun haml-at-indent-p ()
  "Returns whether or not the point is at the first
non-whitespace character in a line or whitespace preceding that
character."
  (let ((opoint (point)))
    (save-excursion
      (back-to-indentation)
      (>= (point) opoint))))

(defun haml-forward-sexp (&optional arg)
  "Move forward across one nested expression.
With `arg', do it that many times.  Negative arg -N means move
backward across N balanced expressions.

A sexp in Haml is defined as a line of Haml code as well as any
lines nested beneath it."
  (interactive "p")
  (or arg (setq arg 1))
  (if (and (< arg 0) (not (haml-at-indent-p)))
      (back-to-indentation)
    (while (/= arg 0)
      (let ((indent (current-indentation)))
        (loop do (haml-forward-through-whitespace (< arg 0))
              while (and (not (eobp))
                         (not (bobp))
                         (> (current-indentation) indent)))
        (back-to-indentation)
        (setq arg (+ arg (if (> arg 0) -1 1)))))))

(defun haml-backward-sexp (&optional arg)
  "Move backward across one nested expression.
With ARG, do it that many times.  Negative arg -N means move
forward across N balanced expressions.

A sexp in Haml is defined as a line of Haml code as well as any
lines nested beneath it."
  (interactive "p")
  (haml-forward-sexp (if arg (- arg) -1)))

(defun haml-up-list (&optional arg)
  "Move out of one level of nesting.
With ARG, do this that many times."
  (interactive "p")
  (or arg (setq arg 1))
  (while (> arg 0)
    (let ((indent (current-indentation)))
      (loop do (haml-forward-through-whitespace t)
            while (and (not (bobp))
                       (>= (current-indentation) indent)))
      (setq arg (- arg 1))))
  (back-to-indentation))

(defun haml-down-list (&optional arg)
  "Move down one level of nesting.
With ARG, do this that many times."
  (interactive "p")
  (or arg (setq arg 1))
  (while (> arg 0)
    (let ((indent (current-indentation)))
      (haml-forward-through-whitespace)
      (when (<= (current-indentation) indent)
        (haml-forward-through-whitespace t)
        (back-to-indentation)
        (error "Nothing is nested beneath this line"))
      (setq arg (- arg 1))))
  (back-to-indentation))

(defun haml-mark-sexp ()
  "Marks the next Haml block."
  (let ((forward-sexp-function 'haml-forward-sexp))
    (mark-sexp)))

(defun haml-mark-sexp-but-not-next-line ()
  "Marks the next Haml block, but puts the mark at the end of the
last line of the sexp rather than the first non-whitespace
character of the next line."
  (haml-mark-sexp)
  (set-mark
   (save-excursion
     (goto-char (mark))
     (forward-line -1)
     (end-of-line)
     (point))))

;; Indentation and electric keys

(defun* haml-indent-p ()
  "Returns t if the current line can have lines nested beneath it."
  (let ((attr-props (haml-parse-multiline-attr-hash)))
    (when attr-props
      (end-of-line)
      (return-from haml-indent-p
        (if (eq (char-before) ?,) (cdr (assq 'hash-indent attr-props))
          (beginning-of-line)
          (list (+ (cdr (assq 'indent attr-props)) haml-indent-offset) nil)))))
  (loop for opener in haml-block-openers
        if (looking-at opener) return t
        finally return nil))

(defun* haml-parse-multiline-attr-hash ()
  "Parses a multiline attribute hash, and returns
an alist with the following keys:

INDENT is the indentation of the line beginning the hash.

HASH-INDENT is the indentation of the first character
within the attribute hash.

POINT is the character position at the beginning of the line
beginning the hash."
  (save-excursion
    (while t
      (beginning-of-line)
      (if (looking-at "^ *\\(?:[.#%][a-z0-9_:\\-]+\\)+{")
          (progn
            (goto-char (- (match-end 0) 1))
            (haml-limited-forward-sexp (save-excursion (end-of-line) (point)))
            (return-from haml-parse-multiline-attr-hash
              (if (eq (char-before) ?,)
                  `((indent . ,(current-indentation))
                    (hash-indent . ,(- (match-end 0) (match-beginning 0)))
                    (point . ,(match-beginning 0)))
                nil)))
        (forward-line -1)
        (end-of-line)
        (when (not (eq (char-before) ?,))
          (return-from haml-parse-multiline-attr-hash nil))))))

(defun haml-compute-indentation ()
  "Calculate the maximum sensible indentation for the current line."
  (save-excursion
    (beginning-of-line)
    (if (bobp) (list 0 nil)
      (haml-forward-through-whitespace t)
      (let ((indent (funcall haml-indent-function)))
        (cond
         ((consp indent) indent)
         ((integerp indent) (list indent t))
         (indent (list (+ (current-indentation) haml-indent-offset) nil))
         (t (list (current-indentation) nil)))))))

(defun haml-indent-region (start end)
  "Indent each nonblank line in the region.
This is done by indenting the first line based on
`haml-compute-indentation' and preserving the relative
indentation of the rest of the region.

If this command is used multiple times in a row, it will cycle
between possible indentations."
  (save-excursion
    (goto-char end)
    (setq end (point-marker))
    (goto-char start)
    (let (this-line-column current-column
          (next-line-column
           (if (and (equal last-command this-command) (/= (current-indentation) 0))
               (* (/ (- (current-indentation) 1) haml-indent-offset) haml-indent-offset)
             (car (haml-compute-indentation)))))
      (while (< (point) end)
        (setq this-line-column next-line-column
              current-column (current-indentation))
        ;; Delete whitespace chars at beginning of line
        (delete-horizontal-space)
        (unless (eolp)
          (setq next-line-column (save-excursion
                                   (loop do (forward-line 1)
                                         while (and (not (eobp)) (looking-at "^[ \t]*$")))
                                   (+ this-line-column
                                      (- (current-indentation) current-column))))
          ;; Don't indent an empty line
          (unless (eolp) (indent-to this-line-column)))
        (forward-line 1)))
    (move-marker end nil)))

(defun haml-indent-line ()
  "Indent the current line.
The first time this command is used, the line will be indented to the
maximum sensible indentation.  Each immediately subsequent usage will
back-dent the line by `haml-indent-offset' spaces.  On reaching column
0, it will cycle back to the maximum sensible indentation."
  (interactive "*")
  (let ((ci (current-indentation))
        (cc (current-column)))
    (destructuring-bind (need strict) (haml-compute-indentation)
      (save-excursion
        (beginning-of-line)
        (delete-horizontal-space)
        (if (and (not strict) (equal last-command this-command) (/= ci 0))
            (indent-to (* (/ (- ci 1) haml-indent-offset) haml-indent-offset))
          (indent-to need))))
    (when (< (current-column) (current-indentation))
      (forward-to-indentation 0))))

(defun haml-reindent-region-by (n)
  "Add N spaces to the beginning of each line in the region.
If N is negative, will remove the spaces instead.  Assumes all
lines in the region have indentation >= that of the first line."
  (let ((ci (current-indentation)))
    (save-excursion
      (replace-regexp (concat "^" (make-string ci ? ))
                      (make-string (max 0 (+ ci n)) ? )
                      nil (point) (mark)))))

(defun haml-electric-backspace (arg)
  "Delete characters or back-dent the current line.
If invoked following only whitespace on a line, will back-dent
the line and all nested lines to the immediately previous
multiple of `haml-indent-offset' spaces.

Set `haml-backspace-backdents-nesting' to nil to just back-dent
the current line."
  (interactive "*p")
  (if (or (/= (current-indentation) (current-column))
          (bolp)
          (looking-at "^[ \t]+$"))
      (backward-delete-char arg)
    (save-excursion
      (let ((ci (current-column)))
        (beginning-of-line)
        (if haml-backspace-backdents-nesting
            (haml-mark-sexp-but-not-next-line)
          (set-mark (save-excursion (end-of-line) (point))))
        (haml-reindent-region-by (* (- arg) haml-indent-offset))
        (back-to-indentation)
        (pop-mark)))))

(defun haml-kill-line-and-indent ()
  "Kill the current line, and re-indent all lines nested beneath it."
  (interactive)
  (beginning-of-line)
  (haml-mark-sexp-but-not-next-line)
  (kill-line 1)
  (haml-reindent-region-by (* -1 haml-indent-offset)))

(defun haml-indent-string ()
  "Return the indentation string for `haml-indent-offset'."
  (mapconcat 'identity (make-list haml-indent-offset " ") ""))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.haml$" . haml-mode))

;; Setup/Activation
(provide 'haml-mode)
;;; haml-mode.el ends here
