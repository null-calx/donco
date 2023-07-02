(in-package :donco)

(defun main (&optional (input-pathname "base.sexp"))
  (destructuring-bind (tables table-name-list)
      (with-open-file (in input-pathname
			  :direction :input)
	(read-db-structure in))
    (with-open-file (out "db-structure.json"
			 :direction :output
			 :if-exists :supersede
			 :if-does-not-exist :create)
      (write-json table-name-list tables out))
    (with-open-file (out "db-structure.sql"
			 :direction :output
			 :if-exists :supersede
			 :if-does-not-exist :create)
      (write-sql table-name-list tables out))
    (with-open-file (out "db-query.json"
			 :direction :output
			 :if-exists :supersede
			 :if-does-not-exist :create)
      (write-pg-query table-name-list tables out))))
