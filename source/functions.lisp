(cl:in-package #:de-mock-racy)


(defun waiting-calls-enque-many* (waiting-calls &rest args)
  (map nil
       (lambda (arg) (apply #'waiting-calls-enque waiting-calls arg))
       args))
