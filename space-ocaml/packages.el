;;; packages.el --- space-ocaml layer packages file for Spacemacs.
;;
;; Copyright (c) 2012-2016 Sylvain Benner & Contributors
;;
;; Author: Loic Runarvot <loic@tis-desktop-4>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

;;; Commentary:

;; See the Spacemacs documentation and FAQs for instructions on how to implement
;; a new layer:
;;
;;   SPC h SPC layers RET
;;
;;
;; Briefly, each package to be installed or configured by this layer should be
;; added to `space-ocaml-packages'. Then, for each package PACKAGE:
;;
;; - If PACKAGE is not referenced by any other Spacemacs layer, define a
;;   function `space-ocaml/init-PACKAGE' to load and initialize the package.

;; - Otherwise, PACKAGE is already referenced by another Spacemacs layer, so
;;   define the functions `space-ocaml/pre-init-PACKAGE' and/or
;;   `space-ocaml/post-init-PACKAGE' to customize the package as it is loaded.


;; Based on ocaml layer package

;;; Code:

(defconst space-ocaml-packages
  '(company
    ocp-indent
    merlin
    smartparens
    tuareg))

(defun space-ocaml/post-init-company ()
  (spacemacs|add-company-hook merlin-mode))

(when (configuration-layer/layer-usedp 'syntax-checking)
  (defun space-ocaml/post-init-flycheck ()
    (spacemacs/add-flycheck-hook 'merlin-mode-hook))
  (defun space-ocaml/init-flycheck-ocaml ()
    (use-package flycheck-ocaml
      :if (configuration-layer/package-usedp 'flycheck)
      :defer t
      :init
      (progn
        (with-eval-after-load 'merlin
          (setq merlin-error-after-save nil)
          (flycheck-ocaml-setup))))))

(defun space-ocaml/init-merlin ()
  (use-package merlin
    :defer t
    :init
    (progn
      (add-hook 'tuareg-mode-hook 'merlin-mode)
      (set-default 'merlin-use-auto-complete-mode nil)
      (setq merlin-completion-with-doc t)
      (push 'merlin-company-backend company-backends-merlin-mode)
      (spacemacs/set-leader-keys-for-major-mode 'tuareg-mode
        "eC" 'merlin-error-check
        "en" 'merlin-error-next
        "eN" 'merlin-error-prev
        "gb" 'merlin-pop-stack
        "gg" #'(lambda ()
                 (interactive)
                 (let ((merlin-locate-in-new-window 'never))
                   (merlin-locate)))
        "gG" #'(lambda ()
                 (interactive)
                 (let ((merlin-locate-in-new-window 'always))
                   (merlin-locate)))
        "gl" 'merlin-locate-ident
        "md" 'merlin-destruct
        "me" 'merlin-type-expr
        "mh" 'merlin-document
        "mt" 'merlin-type-enclosing
        "pp" 'merlin-project-check
        "pr" 'merlin-refresh
        "pv" 'merlin-goto-project-file))))

(defun space-ocaml/init-ocp-indent ()
  (use-package ocp-indent
    :defer t
    :init
    (add-hook 'tuareg-mode-hook 'ocp-indent-caml-mode-setup)))

(defun space-ocaml/post-init-smartparens ()
  (with-eval-after-load 'smartparens
    ;; don't auto-close apostrophes (type 'a = foo) and backticks (`Foo)
    (sp-local-pair 'tuareg-mode "'" nil :actions nil)
    (sp-local-pair 'tuareg-mode "`" nil :actions nil)))

(defun space-ocaml/init-tuareg ()
  (use-package tuareg
    :defer t
    :init
    (progn
      (spacemacs//init-ocaml-opam)
      (spacemacs/set-leader-keys-for-major-mode 'tuareg-mode
        "ga" 'tuareg-find-alternate-file
        "cc" 'compile)
      ;; Make OCaml-generated files invisible to filename completion
      (dolist (ext '(".cmo" ".cmx" ".cma" ".cmxa" ".cmi" ".cmxs" ".cmt" ".annot"))
        (add-to-list 'completion-ignored-extensions ext)))))

;;; packages.el ends here
