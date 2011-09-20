;; Configuration

(defcustom e-max-plone-enable-po-mode
  t
  "Use po-mode for translation files"
  :type 'boolean
  :group 'e-max)

(defcustom e-max-plone-changelog-name
  nil
  "Name to use in changelogs."
  :type 'string
  :group 'e-max)


;;;; -------------------------------------
;;;; Bundle

;; dependencies
(e-max-vendor 'textmate)
(load (concat e-max-bundle-dir "plone/lookup"))

;; add additional files / directories to execlude from textmate-goto-file
(when (not (string-match "eggs" *textmate-gf-exclude*))
  (setq *textmate-gf-exclude*
        (replace-regexp-in-string ".pyc"
                                  ".pyc|eggs|parts|coverage"
                                  *textmate-gf-exclude*))

  (setq *textmate-project-roots*
        (append *textmate-project-roots* '("setup.py" "bootstrap.py"))))


;; helpers

(defun e-max-plone--find-buildout-root (path)
  "Search PATH for a buildout root.

If a buildout root is found return the path, othwise return
nil."
  ;; find the most top one, not the first one
  (let* ((dir default-directory)
         (previous dir))
    (while (not (equalp dir nil))
      (setq dir (e-max--find-parent-with-file dir "bootstrap.py"))
      (if (not (equalp dir nil))
          (progn
            (setq previous dir)
            ;; get parent dir
            (setq dir (file-name-directory (directory-file-name dir))))))
    previous))


(defun e-max-plone-make-changelog-entry ()
  (interactive)

  (let ((name (or e-max-plone-changelog-name
                  (user-login-name))))

    (beginning-of-buffer)
    (forward-paragraph 2)

    (newline)
    (insert "* ")
    (newline)
    (insert (concat "  [" name "]"))
    (newline)
    (previous-line 2)
    (end-of-line)))

(defun e-max-plone-find-changelog-make-entry ()
  (interactive)
  (let* ((egg-root (e-max--find-parent-with-file default-directory "setup.py"))
         (history-file (concat egg-root "docs/HISTORY.txt"))
         (changelog-file (concat egg-root "CHANGELOG.txt")))

    (if (file-exists-p history-file)
        (progn
          (find-file history-file)
          (e-max-plone-make-changelog-entry))
      (if (file-exists-p changelog-file)
          (progn
            (find-file changelog-file)
            (e-max-plone-make-changelog-entry))))))


(defun e-max-plone-find-file-in-package (&optional buildout-root)
  "Prompts for another package to open, which is in the same src directory,
then prompts for a file. Expects to be within a package
 (e.g. .../src/some.package/some/package/anyfile.py)."
  (interactive)

  (let* ((root (replace-regexp-in-string
                "\/?$" "/"
                (or buildout-root
                    (e-max--find-parent-with-file default-directory "src"))))
         (srcpath (concat root "src/"))
         (path nil))

    (if (file-accessible-directory-p srcpath)
        (setq path (concat srcpath
                           (ido-completing-read
                            "Package: "
                            (directory-files srcpath nil "^[^.]"))))

      (setq path root))

    (setq path (replace-regexp-in-string "\/?$" "" path))
    (find-file
     (concat path "/"
             (textmate-completing-read
              "Find file: "
              (mapcar
               (lambda (e)
                 (replace-regexp-in-string (concat path "/") "" (concat "/" e)))
               (textmate-project-files path)))))))


(defun e-max-plone-ido-find-buildout (&optional projects-root)
  "Open a file within a buildout checkout."
  (interactive)

  (let* ((projectsdir (replace-regexp-in-string
                       "\/?$" "/"
                       (or projects-root e-max-project-location)))
         (project-name (ido-completing-read
                        "Project: "
                        (directory-files projectsdir nil "^[^.]")))
         (project-path (concat projectsdir project-name))

         (buildout-name (ido-completing-read
                         (concat project-name " buildout: ")
                         (directory-files project-path nil "^[^.]")))
         (buildout-path (concat project-path "/" buildout-name "/")))

    (e-max-persp (concat buildout-name "@" project-name))
    (e-max-plone-find-file-in-package buildout-path)))

;; hooks & customization

(when e-max-plone-enable-po-mode
  (e-max-vendor 'po-mode)

  (add-to-list 'auto-mode-alist '("\\.po\\(t\\)?$" . po-mode)))

(add-to-list 'auto-mode-alist '("\\.\\(z\\)?pt$" . nxml-mode))
(add-to-list 'auto-mode-alist '("\\.zcml$" . nxml-mode))


(defun e-max-plone--python-bindings ()
  (define-key python-mode-map (kbd "C-M-<return>") 'e-max-plone-goto-defition)
  (define-key python-mode-map (kbd "C-M-S-<return>") 'e-max-plone-lookup-import))

(add-hook 'python-mode-hook 'e-max-plone--python-bindings)


;; global bindings

(e-max-global-set-key (kbd "C-c f c") 'e-max-plone-find-changelog-make-entry)
(e-max-global-set-key (kbd "M-T") 'e-max-plone-find-file-in-package)
(e-max-global-set-key (kbd "C-p b") 'e-max-plone-ido-find-buildout)
