(asdf:defsystem #:de-mock-racy
  :name "de-mock-racy"
  :version "0.0.0"
  :author "Marek Kochanowicz"
  :depends-on ()
  :serial T
  :pathname "source"
  :components ((:file "package")
               (:file "generics")
               (:file "variables")
               (:file "types")
               (:file "macros")
               (:file "methods")))
