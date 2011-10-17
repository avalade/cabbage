(defcustom e-max-completion-always-use-autocomplete nil
  "set it to ture if you prefer using auto-complete
as primary completion mechanism"
  :group 'e-max
  :type 'boolean)

(e-max-vendor 'auto-complete)
(e-max-vendor 'smex)

;;;; Smex Completion for M-x
(smex-initialize)

(defun e-max-smex-bind-keys ()
  (when (e-max-bundle-active-p 'ergonomic)
    (global-unset-key (kbd "M-a"))
    (global-set-key (kbd "M-a") 'smex)))
(add-hook 'e-max-initialized-hook 'e-max-smex-bind-keys)

;;;; Global IDO Completion
(ido-everywhere t)

;;;; AutoComplete
(require 'auto-complete-config)
(ac-config-default)

(setq ac-ignore-case nil)

;; enable auto-complete for additional modes
(setq ac-modes
      (append ac-modes '(conf-unix-mode haml-mode)))

(if e-max-completion-always-use-autocomplete
    (progn)
  (setq ac-auto-start nil))

(e-max-global-set-key (kbd "C-SPC") 'auto-complete)
