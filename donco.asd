(defsystem "donco"
  :depends-on (:yason)
  :serial t
  :components ((:file "package")
	       (:file "util")
	       (:file "macro-util")
	       (:file "reader")
	       (:file "json")
	       (:file "types")
	       (:file "sql")
	       (:file "pg-query")
	       (:file "main")))
