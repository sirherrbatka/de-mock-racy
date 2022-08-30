(cl:in-package #:de-mock-racy)


(defclass basic-waiting-call ()
  ((%implementation-closure :initarg :implementation
                            :reader implementation-closure)
   (%filter-closure :initarg :filter
                    :reader filter-closure)
   (%usage-count :initarg :usage-count
                 :accessor usage-count)
   (%usage-counter :initform 0
                   :accessor usage-counter))
  (:default-initargs :usage-count 1))


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


(define-condition no-mock-implementation-error (error)
  ((%label :initarg :label
           :reader no-mock-implementation-error-label)
   (%arguments :initarg :arguments
               :reader no-mock-implementation-error-arguments))
  (:report (lambda (object stream)
             (format stream "No mock implementation for block with label ~S and arguments ~{~a ~}could be found."
                     (no-mock-implementation-error-label object)
                     (no-mock-implementation-error-arguments object)))))
