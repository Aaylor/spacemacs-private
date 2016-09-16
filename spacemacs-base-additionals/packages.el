;;; packages.el --- spacemacs-base-additionals layer packages file for Spacemacs.
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
;; added to `spacemacs-base-additionals-packages'. Then, for each package PACKAGE:
;;
;; - If PACKAGE is not referenced by any other Spacemacs layer, define a
;;   function `spacemacs-base-additionals/init-PACKAGE' to load and initialize the package.

;; - Otherwise, PACKAGE is already referenced by another Spacemacs layer, so
;;   define the functions `spacemacs-base-additionals/pre-init-PACKAGE' and/or
;;   `spacemacs-base-additionals/post-init-PACKAGE' to customize the package as it is loaded.

;;; Code:

(defconst spacemacs-base-additionals-packages
  '(neotree
    rainbow-delimiters
    smartparens
    smooth-scrolling
    spaceline))

(defun spacemacs-base-additionals/init-neotree ()
  (use-package neotree
    :defer t
    :commands neo-global--window-exists-p
    :init
    (progn
      (setq neo-window-width 32
            neo-create-file-auto-open t
            neo-banner-message nil
            neo-show-updir-line nil
            neo-mode-line-type 'neotree
            neo-smart-open t
            neo-dont-be-alone t
            neo-persist-show nil
            neo-show-hidden-files t
            neo-auto-indent-point t
            neo-modern-sidebar t
            neo-vc-integration nil)

      (defun spacemacs/neotree-expand-or-open ()
        "Collapse a neotree node."
        (interactive)
        (let ((node (neo-buffer--get-filename-current-line)))
          (when node
            (if (file-directory-p node)
                (progn
                  (neo-buffer--set-expand node t)
                  (neo-buffer--refresh t)
                  (when neo-auto-indent-point
                    (next-line)
                    (neo-point-auto-indent)))
              (call-interactively 'neotree-enter)))))

      (defun spacemacs/neotree-collapse ()
        "Collapse a neotree node."
        (interactive)
        (let ((node (neo-buffer--get-filename-current-line)))
          (when node
            (when (file-directory-p node)
              (neo-buffer--set-expand node nil)
              (neo-buffer--refresh t))
            (when neo-auto-indent-point
              (neo-point-auto-indent)))))

      (defun spacemacs/neotree-collapse-or-up ()
        "Collapse an expanded directory node or go to the parent node."
        (interactive)
        (let ((node (neo-buffer--get-filename-current-line)))
          (when node
            (if (file-directory-p node)
                (if (neo-buffer--expanded-node-p node)
                    (spacemacs/neotree-collapse)
                  (neotree-select-up-node))
              (neotree-select-up-node)))))

      (defun neotree-find-project-root ()
        (interactive)
        (if (neo-global--window-exists-p)
            (neotree-hide)
          (let ((origin-buffer-file-name (buffer-file-name)))
            (neotree-find (projectile-project-root))
            (neotree-find origin-buffer-file-name))))

      (defun spacemacs//neotree-key-bindings ()
        "Set the key bindings for a neotree buffer."
        (evilified-state-evilify-map neotree-mode-map
          :mode neotree-mode
          :bindings
          (kbd "TAB")  'neotree-stretch-toggle
          (kbd "RET") 'neotree-enter
          (kbd "|") 'neotree-enter-vertical-split
          (kbd "-") 'neotree-enter-horizontal-split
          (kbd "?") 'evil-search-backward
          (kbd "c") 'neotree-create-node
          (kbd "d") 'neotree-delete-node
          (kbd "gr") 'neotree-refresh
          (kbd "h") 'spacemacs/neotree-collapse-or-up
          (kbd "H") 'neotree-select-previous-sibling-node
          (kbd "J") 'neotree-select-down-node
          (kbd "K") 'neotree-select-up-node
          (kbd "l") 'spacemacs/neotree-expand-or-open
          (kbd "L") 'neotree-select-next-sibling-node
          (kbd "q") 'neotree-hide
          (kbd "r") 'neotree-rename-node
          (kbd "R") 'neotree-change-root
          (kbd "s") 'neotree-hidden-file-toggle))

      (spacemacs/set-leader-keys
        "ft" 'neotree-toggle
        "pt" 'neotree-find-project-root))

    :config
    (spacemacs//neotree-key-bindings)))

(defun spacemacs-base-additionals/init-rainbow-delimiters ()
  (use-package rainbow-delimiters
    :defer t
    :init
    (progn
      (spacemacs/set-leader-keys "tCd" 'rainbow-delimiters-mode)
      (when (member dotspacemacs-highlight-delimiters '(any all))
        (spacemacs/add-to-hooks 'rainbow-delimiters-mode '(prog-mode-hook))))))

(defun spacemacs-base-additionals/init-smartparens ()
  (use-package smartparens
    :defer t
    :commands (sp-split-sexp sp-newline)
    :init
    (progn
      (spacemacs/add-to-hooks (if dotspacemacs-smartparens-strict-mode
                                  'smartparens-strict-mode
                                'smartparens-mode)
                              '(prog-mode-hook))

      ;; enable smartparens-mode in `eval-expression'
      (defun conditionally-enable-smartparens-mode ()
        "Enable `smartparens-mode' in the minibuffer, during `eval-expression'."
        (if (eq this-command 'eval-expression)
            (smartparens-mode)))

      (add-hook 'minibuffer-setup-hook 'conditionally-enable-smartparens-mode)

      (spacemacs|add-toggle smartparens
        :status smartparens-mode
        :on (smartparens-mode)
        :off (smartparens-mode -1)
        :documentation "Enable smartparens."
        :evil-leader "tp")

      (spacemacs|add-toggle smartparens-globally
        :status smartparens-mode
        :on (smartparens-global-mode)
        :off (smartparens-global-mode -1)
        :documentation "Enable smartparens globally."
        :evil-leader "t C-p")

      (setq sp-show-pair-delay 0.2
            ;; fix paren highlighting in normal mode
            sp-show-pair-from-inside t
            sp-cancel-autoskip-on-backward-movement nil)

      (spacemacs/set-leader-keys
        "J"  'sp-split-sexp
        "jj" 'sp-newline))
    :config
    (progn
      (require 'smartparens-config)
      (spacemacs|diminish smartparens-mode " ⓟ" " p")

      (show-smartparens-global-mode +1)

      (defun spacemacs/smartparens-pair-newline (id action context)
        (save-excursion
          (newline)
          (indent-according-to-mode)))

      (defun spacemacs/smartparens-pair-newline-and-indent (id action context)
        (spacemacs/smartparens-pair-newline id action context)
        (indent-according-to-mode))

      ;; don't create a pair with single quote in minibuffer
      (sp-local-pair 'minibuffer-inactive-mode "'" nil :actions nil)

      (sp-pair "{" nil :post-handlers
               '(:add (spacemacs/smartparens-pair-newline-and-indent "RET")))
      (sp-pair "[" nil :post-handlers
               '(:add (spacemacs/smartparens-pair-newline-and-indent "RET"))))))

(defun spacemacs-base-additionals/init-smooth-scrolling ()
  (use-package smooth-scrolling
    :init
    (progn
      (setq smooth-scroll-margin 5)
      (spacemacs|add-toggle smooth-scrolling
        :status smooth-scrolling-mode
        :on (progn
              (smooth-scrolling-mode)
              (enable-smooth-scroll-for-function previous-line)
              (enable-smooth-scroll-for-function next-line)
              (enable-smooth-scroll-for-function isearch-repeat))
        :off (progn
               (smooth-scrolling-mode -1)
               (disable-smooth-scroll-for-function previous-line)
               (disable-smooth-scroll-for-function next-line)
               (disable-smooth-scroll-for-function isearch-repeat))
        :documentation "Smooth scrolling."
        :evil-leader "tv")
      (when dotspacemacs-smooth-scrolling
        (spacemacs/toggle-smooth-scrolling-on))
      ;; add hooks here only for emacs built-in packages that are not owned
      ;; by a layer.
      (defun spacemacs//unset-scroll-margin ()
        "Set scroll-margin to zero."
        (setq-local scroll-margin 0))
      (spacemacs/add-to-hooks 'spacemacs//unset-scroll-margin
                              '(messages-buffer-mode-hook)))))

(defun spacemacs-base-additionals/init-spaceline ()
  (use-package spaceline-config
    :init
    (progn
      (spacemacs|do-after-display-system-init
       (setq-default powerline-default-separator
                     (if (display-graphic-p) 'wave 'utf-8)))
      (defun spacemacs//set-powerline-for-startup-buffers ()
        "Set the powerline for buffers created when Emacs starts."
        (dolist (buffer '("*Messages*" "*spacemacs*" "*Compile-Log*"))
          (when (and (get-buffer buffer)
                     (configuration-layer/package-usedp 'spaceline))
            (spacemacs//restore-powerline buffer))))
      (add-hook 'emacs-startup-hook
                'spacemacs//set-powerline-for-startup-buffers))
    :config
    (progn
      (defun spacemacs/customize-powerline-faces ()
        "Alter powerline face to make them work with more themes."
        (set-face-attribute 'powerline-inactive2 nil
                            :inherit 'font-lock-comment-face))
      (spacemacs/customize-powerline-faces)

      (dolist (spec '((minor-modes "tmm")
                      (major-mode "tmM")
                      (version-control "tmv")
                      (new-version "tmV")
                      (point-position "tmp")
                      (org-clock "tmc")))
        (let* ((segment (car spec))
               (status-var (intern (format "spaceline-%S-p" segment))))
          (eval `(spacemacs|add-toggle ,(intern (format "mode-line-%S" segment))
                   :status ,status-var
                   :on (setq ,status-var t)
                   :off (setq ,status-var nil)
                   :documentation ,(format "Show %s in the mode-line."
                                           (replace-regexp-in-string
                                            "-" " " (format "%S" segment)))
                   :evil-leader ,(cadr spec)))))
      (setq spaceline-org-clock-p nil)

      (defun spacemacs//evil-state-face ()
        (if (bound-and-true-p evil-state)
            (let ((state (if (eq 'operator evil-state) evil-previous-state evil-state)))
              (intern (format "spacemacs-%S-face" state)))
          'face-of-god))
      (setq spaceline-highlight-face-func 'spacemacs//evil-state-face)

      (let ((unicodep (dotspacemacs|symbol-value
                       dotspacemacs-mode-line-unicode-symbols)))
        (setq spaceline-window-numbers-unicode unicodep)
        (setq spaceline-workspace-numbers-unicode unicodep))

      (defpowerline spacemacs-powerline-new-version
        (propertize
         spacemacs-version-check-lighter
         'mouse-face 'mode-line-highlight
         'help-echo (format "New version %s | Click with mouse-1 to update"
                            spacemacs-new-version)
         'local-map (let ((map (make-sparse-keymap)))
                      (define-key map
                        [mode-line down-mouse-1]
                        (lambda (event)
                          (interactive "@e")
                          (if (yes-or-no-p
                               (format (concat "Do you want to update to the newest "
                                               "version %s ?") spacemacs-new-version))
                              (progn
                                (spacemacs/switch-to-version spacemacs-new-version))
                            (message "Update aborted."))))
                      map)))

      (spaceline-define-segment new-version
        (when spacemacs-new-version
          (spacemacs-powerline-new-version
           (spacemacs/get-new-version-lighter-face
            spacemacs-version spacemacs-new-version))))

      (spaceline-spacemacs-theme '(new-version :when active))
      (spaceline-helm-mode t)
      (when (configuration-layer/package-usedp 'info+)
        (spaceline-info-mode t))

      (defun spacemacs//restore-powerline (buffer)
        "Restore the powerline in buffer"
        (with-current-buffer buffer
          (setq-local mode-line-format (default-value 'mode-line-format))
          (powerline-set-selected-window)
          (powerline-reset)))

      (defun spacemacs//prepare-diminish ()
        (when spaceline-minor-modes-p
          (let ((unicodep (dotspacemacs|symbol-value
                           dotspacemacs-mode-line-unicode-symbols)))
            (setq spaceline-minor-modes-separator
                  (if unicodep (if (display-graphic-p) "" " ") "|"))
            (dolist (mm spacemacs--diminished-minor-modes)
              (let ((mode (car mm)))
                (when (and (boundp mode) (symbol-value mode))
                  (let* ((unicode (cadr mm))
                         (ascii (caddr mm))
                         (dim (if unicodep
                                  unicode
                                (if ascii ascii unicode))))
                    (diminish mode dim))))))))
      (add-hook 'spaceline-pre-hook 'spacemacs//prepare-diminish))))
