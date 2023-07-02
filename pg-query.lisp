(in-package :donco-pg-query)

(defparameter *i* 0)

(defun parse-poster (poster)
  poster)

(defun column-name-list (table)
  (loop for column in (slot-value table 'donco-reader::columns)
	unless (slot-value column 'donco-reader::internal)
	  collect (slot-value column 'donco-reader::name)))

(defun type-list (table)
  (loop for column in (slot-value table 'donco-reader::columns)
	unless (slot-value column 'donco-reader::internal)
	  collect (pg-query-type (slot-value column 'donco-reader::type) (incf *i*))))

(defun paired-list (column-name-list table)
  (loop for name in column-name-list
	for type in (type-list table)
	collect (list name type)))

(defun join (cur-table cur-column)
  (let* ((fkey (slot-value cur-column 'donco-reader::fkey))
	 (cur-table-name (slot-value cur-table 'donco-reader::name))
	 (cur-column-name (slot-value cur-column 'donco-reader::name))
	 (prev-table-name (slot-value fkey 'donco-reader::table))
	 (prev-column-name (slot-value fkey 'donco-reader::column)))
    (format nil "join ~A on ~A.~A = ~A.~A"
	    prev-table-name
	    prev-table-name
	    prev-column-name
	    cur-table-name
	    cur-column-name)))

(defun joins (table)
  (loop for column in (slot-value table 'donco-reader::columns)
	when (slot-value column 'donco-reader::fkey)
	  collect (join table column)))

(defun parse-table (table)
  (let ((hashmap (make-hash-table)))
    (let* ((table-name (slot-value table 'donco-reader::name))
	   (pkey (slot-value table 'donco-reader::pkey))
	   (poster (parse-poster (slot-value table 'donco-reader::poster)))
	   (column-name-list (column-name-list table)))
      (setf (gethash "selectList" hashmap)
	    (format nil "select ~A as poster, ~A as href from ~A;"
		    poster
		    pkey
		    table-name))
      (setf (gethash "count" hashmap)
	    (format nil "select count(~A) as count from ~A;"
		    pkey
		    table-name))
      (let ((*i* 0))
	(setf (gethash "selectItem" hashmap)
	      (format nil "select * from ~A where ~A = ~A~{ ~A~};"
		      table-name
		      pkey
		      (pg-query-type :uuid (incf *i*))
		      (joins table))))
      (let ((*i* 0))
	(setf (gethash "insert" hashmap)
	      (format nil "insert into ~A (~{~A~^, ~}) values (~{~A~^, ~});"
		      table-name
		      column-name-list
		      (type-list table))))
      (let ((*i* 0))
	(setf (gethash "update" hashmap)
	      (format nil "update ~A set ~{~{~A = ~A~}~^, ~} where ~A = ~A;"
		      table-name
		      (paired-list column-name-list table)
		      pkey
		      (pg-query-type :uuid (incf *i*)))))
      (let ((*i* 0))
	(setf (gethash "delete" hashmap)
	      (format nil "delete from ~A where ~A = ~A;"
		      table-name
		      pkey
		      (pg-query-type :uuid (incf *i*)))))
      hashmap)))

(defun write-pg-query (table-name-list tables out-stream)
  (let ((hashmap (make-hash-table)))
    (loop for table-name in table-name-list
	  do (setf (gethash table-name hashmap)
		   (parse-table (gethash table-name tables))))
    (print-json hashmap out-stream)))
