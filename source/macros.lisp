(cl:in-package #:de-mock-racy)


(defmacro mockable-block ((label &rest arguments) &body body)
  `(execute-mockable-block *mock-controller*
                           ',label
                           (list ,@arguments)
                           (lambda () ,@body)))


(defmacro filter (label arguments &body body)
  (alexandria:with-gensyms (!waiting-call !mock-controller !label !arguments)
    `(lambda (,!waiting-call ,!mock-controller ,!label ,!arguments)
       (declare (ignore ,!waiting-call ,!mock-controller))
       (destructuring-bind (,@arguments) ,!arguments
         (declare (ignorable ,@arguments))
         (and (eq ,!label ',label)
              ,@body)))))
