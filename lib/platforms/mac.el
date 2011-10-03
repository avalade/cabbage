;; config

(defvar exec-path-from-shell "/bin/bash"
  "E-max uses the $PATH environment variable of this shell as exec-path.")

(defcustom e-max-mac-use-shell-path nil
  "Set this to ture, if you want Emacs to use the PATH of your bin/bash"
  :group 'e-max
  :type 'boolean)

;; start the server to use emacsclient from the console
(server-start)

(setenv "PATH" (concat (getenv "PATH") ":/usr/local/bin"))
(setq exec-path (cons "/usr/local/bin" exec-path))

;; use emacs keybindings.
(setq mac-pass-command-to-system nil
      ns-pop-up-frames nil
      ns-alternate-modifier (quote none)
      ns-command-modifier (quote meta))

;; We want to use utf-8 when possible
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

;; custom place to save customizations
(set-frame-font "-apple-consolas-medium-r-normal--13-130-72-72-m-130-iso10646-1")

(setq mac-emulate-three-button-mouse nil)

(defun mac-use-shell-path ()
  (interactive)
  (let ((path-from-shell
         (replace-regexp-in-string
          "[[:space:]\n]*$" ""
          (shell-command-to-string (concat exec-path-from-shell " -l -c 'echo $PATH'")))))
    (setenv "PATH" path-from-shell)
    (setq exec-path (split-string path-from-shell path-separator))))

(when e-max-mac-use-shell-path
  (mac-use-shell-path))

;; make emacs use the clipboard
(setq x-select-enable-clipboard t)
