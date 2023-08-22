(in-package :donco-reader)

(define-object-class fkey
  table		; table-name the fkey links to
  imports	; list of column-names the fkey imports

  (column :hidden))

(define-object-class column
  name		; column-name as used by the database
  type		; column-datatype
  text		; ui text to display in place of column name
  unit		; unit to display with text if any

  (pkey "primaryKey")
		; bool to mark primary key
  (fkey "foreignKey")
		; foreign keys
  		; primary and foreign keys have uuid as type

  (default :hidden)
  		; default value to use while creating database entry
  (unique :hidden)
  (required "isRequired")
  (internal "isInternal")
  (read-perm "readPermission"))

(define-object-class table
  name		; table-name as used by the database
  text		; ui text to display in place of table name
  url		; url text to display in place of table name

  poster	; define the the string to display for the any row
  pkey		; column-name of the primaryKey

  prev		; tables referenced by fkey in current table
  next		; tables having fkey referencing current table

  columns	; list of columns

  (plain :hidden)
  hidden	; hide table from users
  (write-perm "writePermission"))

(defparameter *tables* (make-hash-table :test #'equal))
(defparameter *table-name-list* nil)

(defun create-column-name (table-instance column-name)
  (format nil "~A_~A" (slot-value table-instance 'name) column-name))

(defun import-columns (table-name imports)
  (let* ((table (gethash table-name *tables*))
	 (plain (slot-value table 'plain))
	 (column-names (if plain
			   imports
			   (loop for import in imports
				 collect (create-column-name table import)))))
    (loop for column-name in column-names
	  collect (find column-name (slot-value table 'columns)
			:key #'(lambda (column) (slot-value column 'name))
			:test #'equal))))

(defun read-fkey (table-instance table-name &rest imports)
  (let ((other-table (gethash table-name *tables*)))
    (assert other-table
	    (table-name other-table)
	    "Table '~A' not found." table-name)
    (push (slot-value other-table 'name)
	  (slot-value table-instance 'prev))
    (push (slot-value table-instance 'name)
	  (slot-value other-table 'next))
    (let ((fkey (make-instance 'fkey
			       :table table-name
			       :imports (import-columns table-name imports))))
      (setf (slot-value fkey 'column) (slot-value other-table 'pkey))
      fkey)))

(defun read-column (table-instance column-name &key type (text column-name) unit pkey fkey default unique required internal read-perm &allow-other-keys)
  (let ((column (make-instance 'column
			       :name (if (slot-value table-instance 'plain)
					 column-name
					 (create-column-name table-instance column-name))
			       :type type
			       :text text
			       :unit unit
			       :pkey pkey
			       :fkey (if fkey (apply #'read-fkey table-instance fkey))
			       :default default
			       :unique unique
			       :required required
			       :internal internal
			       :read-perm read-perm)))
    (when fkey
      (setf (slot-value column 'type) :uuid))
    (when pkey
      (assert (not (slot-value table-instance 'pkey)))
      (setf (slot-value table-instance 'pkey) (slot-value column 'name))
      (setf (slot-value column 'type) :uuid)
      (setf (slot-value column 'internal) t)
      (setf (slot-value column 'default) "uuid_generate_v4 ()"))
    column))

(defun read-table (name props &rest column-list)
  (let ((table (make-instance 'table
			      :name name
			      :text (getf props :text name)
			      :url (getf props :url name)
			      :poster (getf props :poster)
			      :plain (getf props :plain)
			      :hidden (getf props :hidden)
			      :write-perm (getf props :write-perm))))
    (push name *table-name-list*)
    (setf (gethash name *tables*) table)
    (setf (slot-value table 'columns)
	  (loop for column in column-list
		collect (apply #'read-column table column)))
    table))

(defun read-db-structure (in-stream)
  (let ((*tables* (make-hash-table :test #'equal))
	(*table-name-list* nil))
    (loop for table = (read in-stream nil)	  
	  while table
	  do (apply #'read-table (cdr table)))
    (list *tables* (nreverse *table-name-list*))))
