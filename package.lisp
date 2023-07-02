(defpackage :donco-util
  (:use :cl :yason)
  (:export :print-json))

(defpackage :donco-macro-util
  (:use :cl :yason)
  (:export :define-object-class))

(defpackage :donco-reader
  (:use :cl :donco-macro-util)
  (:export :read-db-structure))

(defpackage :donco-json
  (:use :cl :donco-util)
  (:export :write-json))

(defpackage :donco-types
  (:use :cl)
  (:export :sql-type :pg-query-type))

(defpackage :donco-sql
  (:use :cl :donco-types)
  (:export :write-sql))

(defpackage :donco-pg-query
  (:use :cl :yason :donco-types :donco-util)
  (:export :write-pg-query))

(defpackage :donco
  (:use :cl :donco-reader :donco-json :donco-sql :donco-pg-query)
  (:export :main))
