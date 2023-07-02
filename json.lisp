(in-package :donco-json)

(defun write-json (table-name-list tables out-stream)
  (let ((hashmap (make-hash-table)))
    (setf (gethash "tables" hashmap) tables)
    (setf (gethash "tableNameList" hashmap) table-name-list)
    (print-json hashmap out-stream)))
