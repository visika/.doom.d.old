;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Mariano Mollo"
      user-mail-address "marianomollo@protonmail.ch")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; "JetBrains Mono" 13 "DejaVu Sans Mono"
(setq doom-font (font-spec :family "Fira Code" :size 13))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
;; (setq doom-theme 'doom-one-light)
(setq doom-theme 'doom-one)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type nil)


;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c g k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c g d') to jump to their definition and see how
;; they are implemented.
(setq org-roam-graph-executable "/usr/bin/neato")
(setq org-roam-graph-extra-config '(("overlap" . "false")))
(use-package org-roam
	      :custom-face
	      (org-roam-link ((t (:inherit org-link :foreground "dark orange"))))
        :config
        (require 'org-roam-protocol)
        (setq org-roam-capture-templates
              '(("d" "default" plain (function org-roam--capture-get-point)
                 "%?"
                 :file-name "${slug}"
                 :head "#+SETUPFILE:./hugo_setup.org
#+HUGO_SECTION: appunti
#+HUGO_SLUG: ${slug}
#+TITLE: ${title}\n"
                 :unnarrowed t)
                ("p" "private" plain (function org-roam-capture--get-point)
                 "%?"
                 :file-name "private-${slug}"
                 :head "#+TITLE: ${title}\n"
                 :unnarrowed t)))
        (setq org-roam-ref-capture-templates
              '(("r" "ref" plain (function org-roam-capture--get-point)
                 "%?"
                 :file-name "websites/${slug}"
                 :head "#+SETUPFILE:./hugo_setup.org
#+ROAM_KEY: ${ref}
#+HUGO_SLUG: ${slug}
#+TITLE: ${title}
- source :: ${ref}"
                 :unnarrowed t))))

;; configure org-roam-protocol

(server-start)
(use-package org-protocol)
(require 'org-protocol)

(require 'org-roam-protocol)

(after! (org org-roam)
(defun my/org-roam--backlinks-list-with-content (file)
  (with-temp-buffer
    (if-let* ((backlinks (org-roam--get-backlinks file))
              (grouped-backlinks (--group-by (nth 0 it) backlinks)))
        (progn
          (insert (format "\n\n* %d Backlinks\n"
                          (length backlinks)))
          (dolist (group grouped-backlinks)
            (let ((file-from (car group))
                  (bls (cdr group)))
              (insert (format "** [[file:%s][%s]]\n"
                              file-from
                              (org-roam--get-title-or-slug file-from)))
              (dolist (backlink bls)
                (pcase-let ((`(,file-from _ ,props) backlink))
                  (insert (s-trim (s-replace "\n" " " (plist-get props :content))))
                  (insert "\n\n")))))))
    (buffer-string)))

  (defun my/org-export-preprocessor (backend)
    (let ((links (my/org-roam--backlinks-list-with-content (buffer-file-name))))
      (unless (string= links "")
        (save-excursion
          (goto-char (point-max))
          (insert (concat "\n* Backlinks\n") links)))))

  (add-hook 'org-export-before-processing-hook 'my/org-export-preprocessor))
(require 'org-ref)
;; see org-ref for use of these variables
(setq reftex-default-bibliography '("~/Documenti/bibliography/references.bib")
      org-ref-default-bibliography '("~/Documenti/bibliography/references.bib")
      org-ref-pdf-directory "~/Documenti/bibliography/bibtex-pdfs/")

(setq bibtex-completion-bibliography "~/Documenti/bibliography/references.bib"
      bibtex-completion-library-path "~/Documenti/bibliography/bibtex-pdfs"
      bibtex-completion-notes-path "~/Documenti/bibliography/helm-bibtex-notes")

;; open pdf with system pdf viewer (works on mac)
(setq bibtex-completion-pdf-open-function
  (lambda (fpath)
    (start-process "open" "*open*" "open" fpath)))

;; alternative
;; (setq bibtex-completion-pdf-open-function 'org-open-file)

(setq org-latex-pdf-process (list "latexmk -shell-escape -bibtex -f -pdf %f"))

(setq org-latex-prefer-user-labels t)

;; setup org-journal
(use-package org-journal
  :custom
  (org-journal-dir "~/org/")
  (org-journal-file-format "%Y-%m-%d.org")
  (org-journal-date-prefix "#+TITLE: ")
  (org-journal-time-prefix "* ")
  (org-journal-carryover-items ""))
  ;; (org-journal-date-format "%Y-%m-%d"))

;; (defun org-journal-date-format-func (time)
;;   "Custom function to insert journal date header,
;;   and some custom text on a newly created journal file."
;;   (concat
;;    (when (= (buffer-size) 0)
;;      (concat
;;       (format-time-string
;;        (pcase org-journal-file-type
;;          (`daily "#+ROAM_ALIAS: \"%x\" \"%d %B %Y\" \"%Y-%m-%d\"")
;;          (`weekly "#+TITLE: Weekly Journal No. %V, %Y")
;;          (`monthly "#+TITLE: %B Journal, %Y")
;;          (`yearly "#+TITLE: %Y Journal")
;;          )
;;        time)
;;       "\n"))
;;    org-journal-date-prefix
;;    (format-time-string "%A, %d %B %Y" time)))

;; (setq org-journal-date-format #'org-journal-date-format-func)

(defalias 'rekt 'rectangle-mark-mode)

;; (after! (discord-emacs)
;;   (discord-emacs-run "384815451978334208"))
(require 'elcord)
(elcord-mode)

;; enable auto-export on saving for selected files
(after! (org ox-hugo)
  (defun jethro/conditional-hugo-enable ()
    (save-excursion
      (if (cdr (assoc "SETUPFILE" (org-roam--extract-global-props '("SETUPFILE"))))
          (org-hugo-auto-export-mode +1)
        (org-hugo-auto-export-mode -1))))
  (add-hook 'org-mode-hook #'jethro/conditional-hugo-enable))

(after! (org org-ref ox-hugo)
  (use-package org-ref-ox-hugo
    :config
    (add-to-list 'org-ref-formatted-citation-formats
                 '("md"
                   ("article" . "${author}, *${title}*, ${journal}, *${volume}(${number})*, ${pages} (${year}). ${doi}")
                   ("inproceedings" . "${author}, *${title}*, In ${editor}, ${booktitle} (pp. ${pages}) (${year}). ${address}: ${publisher}.")
                   ("book" . "${author}, *${title}* (${year}), ${address}: ${publisher}.")
                   ("phdthesis" . "${author}, *${title}* (Doctoral dissertation) (${year}). ${school}, ${address}.")
                   ("inbook" . "${author}, *${title}*, In ${editor} (Eds.), ${booktitle} (pp. ${pages}) (${year}). ${address}: ${publisher}.")
                   ("incollection" . "${author}, *${title}*, In ${editor} (Eds.), ${booktitle} (pp. ${pages}) (${year}). ${address}: ${publisher}.")
                   ("proceedings" . "${editor} (Eds.), _${booktitle}_ (${year}). ${address}: ${publisher}.")
                   ("unpublished" . "${author}, *${title}* (${year}). Unpublished manuscript.")
                   ("misc" . "${author} (${year}). *${title}*. Retrieved from [${howpublished}](${howpublished}). ${note}.")
                   (nil . "${author}, *${title}* (${year}).")))))
