(in-package :donco-util)

(defun print-json (object &optional (stream *standard-output*))
  (let ((*symbol-encoder* #'string)
	(stream (make-json-output-stream stream :indent nil)))
    (encode object stream)
    (format stream "~%")
    (force-output stream)))
