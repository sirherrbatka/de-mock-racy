(cl:in-package #:de-mock-racy)


(defclass basic-waiting-call ()
  ((%implementation-closure :initarg :implementation
                            :reader implementation-closure)
   (%filter-closure :initarg :filter
                    :reader filter-closure)
   (%usage-count :initarg :usage-count
                 :accessor usage-count))
  (:default-initargs :filter-closure (constantly t)
                     :usage-count 1))


(defclass basic-waiting-calls ()
  ((%content :initarg :content
             :reader content)
   (%waiting-call-class :initarg :waiting-call-class
                        :reader waiting-call-class))
  (:default-initargs
   :waiting-call-class 'basic-waiting-call
   :content (make-array 0 :adjustable t :fill-pointer 0)))


(defclass basic-mock-controller ()
  ((%waiting-calls :initarg :waiting-calls
                   :reader waiting-calls))
  (:default-initargs :waiting-calls (make-instance 'basic-waiting-calls)))
