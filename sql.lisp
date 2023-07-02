(in-package :donco-sql)

;; (alexandria:define-constant)
(eval-when  (:compile-toplevel)
  (defconstant +initial-constraint+
    "create extension if not exists \"uuid-ossp\";"))

(defun parse-column (column)
  (format nil "~A ~A~@[ unique~*~]~@[ not null~*~]~@[ default ~A~]~@[ primary key~*~]"
	  (slot-value column 'donco-reader::name)
	  (sql-type (slot-value column 'donco-reader::type))
	  (slot-value column 'donco-reader::unique)
	  (slot-value column 'donco-reader::required)
	  (slot-value column 'donco-reader::default)
	  (slot-value column 'donco-reader::pkey)))

(defun parse-column-list (column-list)
  (loop for column in column-list
	collect (parse-column column)))

(defun create-fkey-constraint-name (cur-table-name prev-table-name)
  (format nil "fkey_~A_~A" cur-table-name prev-table-name))

(defun parse-fkey (cur-table-name cur-column-name prev-table-name prev-column-name)
  (format nil "constraint ~A foreign key (~A) references ~A (~A)"
	  (create-fkey-constraint-name cur-table-name prev-table-name)
	  cur-column-name
	  prev-table-name
	  prev-column-name))

(defun parse-column-constraints (column-list table-name)
  (loop for column in column-list
	for fkey = (slot-value column 'donco-reader::fkey)
	when fkey
	  collect (parse-fkey table-name
			      (slot-value column 'donco-reader::name)
			      (slot-value fkey 'donco-reader::table)
			      (slot-value fkey 'donco-reader::column))))

(defun parse-table (table)
  (format nil "create table ~A (~%~{  ~A~^,~%~}~{,~%  ~A~}~%);"
	  (slot-value table 'donco-reader::name)
	  (parse-column-list (slot-value table 'donco-reader::columns))
	  (parse-column-constraints (slot-value table 'donco-reader::columns)
				    (slot-value table 'donco-reader::name))))

(defun write-sql (table-name-list tables out-stream)
  (format out-stream "~A~%~%~{~A~%~^~%~}"
	  +initial-constraint+
	  (loop for table-name in table-name-list
		collect (parse-table (gethash table-name tables)))))
