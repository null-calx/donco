#!/usr/bin/env -S sbcl --script

(require :asdf)

; (load "build/bundle.lisp")

(let ((found-dir
	(make-pathname :directory (pathname-directory *load-pathname*))))
  (asdf:load-asd (merge-pathnames "donco.asd" found-dir)))

(asdf:load-system :donco)

(donco:main)
