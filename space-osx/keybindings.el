(when (spacemacs/system-is-mac)

  ;; cmd as meta
  (setq mac-option-key-is-meta nil
        mac-command-key-is-meta t
        mac-command-modifier 'meta
        mac-option-modifier 'none)

  (global-set-key [(meta up)] 'backward-paragraph)
  (global-set-key [(meta down)] 'forward-paragraph))
