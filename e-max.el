(load (concat e-max-repository "lib/bundles"))
(load (concat e-max-repository "lib/defun"))

(cond
 ((string-match "nt" system-configuration)
  (load "private/platforms/windows"))
 ((string-match "apple" system-configuration)
  (load "lib/platforms/mac")))

(dolist (bundle e-max-bundles)
  (load (concat e-max-repository "bundles/" (symbol-name bundle) "/bundle")))
