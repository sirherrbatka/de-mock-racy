(cl:in-package #:de-mock-racy)


(defmacro mockable-block ((label &rest arguments) &body body)
  `(execute-mockable-block *mock-controller*
                           ',label
                           (list ,@arguments)
                           (lambda () ,@body)))
