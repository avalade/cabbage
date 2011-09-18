(e-max-vendor 'idle-highlight-mode)
(e-max-vendor 'popwin)

(when window-system
  (setq frame-title-format '(buffer-file-name "%f" ("%b")))
  (tooltip-mode -1)
  (mouse-wheel-mode t))

(delete-selection-mode 1)
(transient-mark-mode 1)
(blink-cursor-mode 1)
(scroll-bar-mode -1)
(tool-bar-mode -1)
(show-paren-mode 1)
(idle-highlight-mode 1)

(setq use-dialog-box nil
      visible-bell t
      echo-keystrokes 0.1
      inhibit-startup-message t
      truncate-partial-width-windows nil
      gnuserv-frame (car (frame-list)))

(setq display-buffer-function 'popwin:display-buffer)

(setq-default cursor-type '(bar . 2))
(setq-default indicate-empty-lines t)

;; include path names when two buffers are equally named
(require 'uniquify)
(setq uniquify-buffer-name-style 'forward)

(defalias 'yes-or-no-p 'y-or-n-p)

(defun increase-font-size ()
  (interactive)
  (set-face-attribute 'default
                      nil
                      :height
                      (ceiling (* 1.10
                                  (face-attribute 'default :height))))
  (restore-frame)
  (maximize-frame))

(defun decrease-font-size ()
  (interactive)
  (set-face-attribute 'default
                      nil
                      :height
                      (floor (* 0.9
                                (face-attribute 'default :height))))
  (restore-frame)
  (maximize-frame))

(global-set-key (kbd "<f5>") 'ns-toggle-fullscreen)
(global-set-key (kbd "C-+") 'increase-font-size)
(global-set-key (kbd "C-_") 'decrease-font-size)
