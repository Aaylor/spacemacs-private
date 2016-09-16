;;; packages.el --- coding-guides layer packages file for Spacemacs.
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
;; added to `coding-guides-packages'. Then, for each package PACKAGE:
;;
;; - If PACKAGE is not referenced by any other Spacemacs layer, define a
;;   function `coding-guides/init-PACKAGE' to load and initialize the package.

;; - Otherwise, PACKAGE is already referenced by another Spacemacs layer, so
;;   define the functions `coding-guides/pre-init-PACKAGE' and/or
;;   `coding-guides/post-init-PACKAGE' to customize the package as it is loaded.

;;; Code:

(defconst coding-guides-packages
  '(column-enforce-mode
    highlight-chars
    highlight-indent-guides))

(defun coding-guides/init-column-enforce-mode ()
  (add-hook 'prog-mode-hook 'column-enforce-mode))

(defun coding-guides/init-coding-guides ()
  (hc-toggle-highlight-hard-spaces)
  (hc-toggle-highlight-tabs)
  (hc-toggle-highlight-trailing-whitespace))

(defun coding-guides/init-highlight-ident-guides ())

;;; packages.el ends here
