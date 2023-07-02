(in-package :donco-macro-util)

(defun as-keyword (symbol)
  (intern (string symbol) :keyword))

(defun normalize (fields)
  (loop for field in fields
	for (name poster) = (if (listp field) field (list field))
	collect (list name (or poster name))))

(defun fields->slots (fields)
  (loop for (name) in fields
	collect (list name :initarg (as-keyword name))))

(defun fields->names (fields)
  (loop for (name) in fields
	collect name))

(defun stringify (symbol-or-string)
  (cond ((keywordp symbol-or-string) symbol-or-string)
	((stringp symbol-or-string) symbol-or-string)
	(t (string-downcase (string symbol-or-string)))))

(defmacro define-object-class (name &body fields)
  (let ((obj-var (gensym "OBJ-"))
	(stream-var (gensym "STREAM-"))
	(fields (normalize fields)))
    `(progn
       (defclass ,name ()
	 ,(fields->slots fields))
       (defmethod encode ((,obj-var ,name) &optional (,stream-var *standard-output*))
	 (with-output (,stream-var)
	   (with-object ()
	     (with-slots ,(fields->names fields) ,obj-var
	       ,@(loop for (name poster) in fields
		       when (not (eq poster :hidden))
			 collect
		         `(if ,name
			      (encode-object-element ,(stringify poster) ,name)))))))
       (defmethod slot-unbound (class (instance ,name) slot-name)
	 (declare (ignore class))
	 (setf (slot-value instance slot-name) nil)))))

