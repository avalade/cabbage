(setq e-max-repository (expand-file-name "E-MAX-DIR/"))

(setq e-max-bundles '(
                      accessibility
                      css
                      ergonomic
                      git
                      html
                      lisp
                      project
                      python
                      ))

(load (concat e-max-repository "e-max"))
