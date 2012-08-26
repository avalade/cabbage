(defvar e-max--globaly-bound-keys-alist '())

(defun e-max-bundle-active-p (bundle-name)
  (member bundle-name e-max-bundles))

(defun e-max-flymake-active-p ()
  e-max-use-flymake)

(defun e-max-global-set-key (binding func)
  (add-to-list 'e-max--globaly-bound-keys-alist (cons binding func))
  (global-set-key binding func))

(defun e-max-clear-local-bindings ()
  (interactive)
  (dolist (binding e-max--globaly-bound-keys-alist)
    (local-unset-key (car binding))))

(add-hook 'after-change-major-mode-hook 'e-max-clear-local-bindings)
(add-hook 'org-mode-hook 'e-max-clear-local-bindings)
(add-hook 'org-agenda-mode-hook 'e-max-clear-local-bindings)
(add-hook 'comint-mode-hook 'e-max-clear-local-bindings)
(add-hook 'inf-ruby-mode-hook 'e-max-clear-local-bindings)
(add-hook 'erlang-mode-hook 'e-max-clear-local-bindings)
(add-hook 'diff-mode 'e-max-clear-local-bindings)
(add-hook 'magit-mode 'e-max-clear-local-bindings)
(add-hook 'html-mode-hook 'e-max-clear-local-bindings)

(defun e-max-lisp-buffer-p ()
  (memql major-mode '(emacs-lisp-mode lisp-mode lisp-interaction-mode)))

(defun e-max-flymake-init ()
  "registered as hook in bundles ; configures flymake"
  (e-max-vendor 'flymake-point)

  (local-set-key (kbd "C-§") 'flymake-goto-next-error))

(defun e-max-insert-pairs-p ()
  e-max-insert-pairs)

;; API: project
(defvar e-max-project-root-indicators
  '("Rakefile" ".git" "Gemfile")
  "list of file-/directory-names which indicate a root of a project")

(defun e-max-project-parent-directory (a-directory)
  "Returns the directory of which a-directory is a child"
  (file-name-directory (directory-file-name a-directory)))

(defun e-max-project-root-directory-p (a-directory)
  "Returns t if a-directory is the root"
  (equal a-directory (e-max-project-parent-directory a-directory)))

(defun e-max-project-root (&optional directory)
  "Finds the root directory of the project by walking the directory tree until it finds a project root indicator."
  (let* ((directory (file-name-as-directory (or directory default-directory)))
         (present-files (directory-files directory)))
    (cond ((e-max-project-root-directory-p directory) nil)
          ((> (length (intersection present-files e-max-project-root-indicators :test 'string=)) 0) directory)
          (t (e-max-project-root (file-name-directory (directory-file-name directory)))))))

;; API: integrated testing
(defvar e-max-testing--last-project-root nil
  "cache for the project-root of the last executed spec-file")

(defvar e-max-testing--last-spec-file nil
  "cache for the last executed spec-file")

(defvar e-max-testing--last-execute-function nil
  "cache for the last test executing function")

(defvar e-max-testing-execute-function nil
  "set this variable to the testing function, which executes tests.
a value of nil means, this buffer does not contain an executable test")
(make-variable-buffer-local 'e-max-testing-execute-function)

(defun e-max-testing-execute-test ()
  (interactive)
  (when buffer-file-name (save-buffer))
  (cond (e-max-testing-execute-function
         (progn
           (setq e-max-testing--last-project-root (e-max-project-root))
           (setq e-max-testing--last-test-file buffer-file-name)
           (setq e-max-testing--last-execute-function e-max-testing-execute-function)
           (funcall e-max-testing-execute-function buffer-file-name)))
        ((and e-max-testing--last-project-root
              e-max-testing--last-test-file
              e-max-testing--last-execute-function)
         (let ((default-directory e-max-testing--last-project-root))
           (funcall e-max-testing--last-execute-function e-max-testing--last-test-file)))
        (t
         (message "Don't know what to do. Open an executable test and run again."))))


(defun e-max-bundle (bundle)
  "Load the given BUNDLE (which can be either a symbol or a string."

  (interactive (list (make-symbol
                      (ido-completing-read
                       "Bundle: "
                       (e-max-bundles--list-available)))))

  (load (concat e-max-bundle-dir
                (if (symbolp bundle)
                    (symbol-name bundle) bundle)
                "/bundle"))
  (add-to-list 'e-max-bundles bundle))


(defun e-max-list-bundles ()
  "Show available and enabled list of bundles"
  (interactive)

  (let* ((bundles (e-max-bundles--list-available))
         (active (mapcar (lambda (e) (symbol-name e)) e-max-bundles))
         (inactive (delq nil (mapcar (lambda (e)
                                       (if (not (member e active))
                                           e))
                                     bundles))))

    (message (concat
              "e-max-bundles: \n"
              (concat "INACTIVE: " (mapconcat 'identity inactive ", "))
              "\n"
              (concat "ACTIVE: " (mapconcat 'identity active ", "))))))

(defun e-max-bundles--list-available ()
  (directory-files (concat e-max-repository "bundles") nil "^[^.]"))
