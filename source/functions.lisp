(cl:in-package #:de-mock-racy)


(defun waiting-calls-enque-many* (waiting-calls &rest args)
  (map nil
       (lambda (arg) (apply #'waiting-calls-enque waiting-calls arg))
       args))


(defun call-thunk ()
  (funcall *thunk*))


(defun execute-mockable-block (mock-controller label arguments thunk)
  (let ((*thunk* thunk))
    (execute-mockable-block* mock-controller label arguments thunk)))
