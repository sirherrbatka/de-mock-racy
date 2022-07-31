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
       (and (eq ,!label ',label)
            (= ,(length arguments) (length ,!arguments))
            (destructuring-bind ,arguments ,!arguments
              (declare (ignorable ,@arguments))
              (and ,@body))))))


(defmacro implementation (arguments &body body)
  (alexandria:with-gensyms (!waiting-call !mock-controller !label !arguments !thunk)
    `(lambda (,!waiting-call ,!mock-controller ,!label ,!arguments ,!thunk)
       (declare (ignore ,!waiting-call ,!mock-controller ,!label ,!arguments ,!thunk))
       (destructuring-bind ,arguments ,!arguments
         (declare (ignorable ,@arguments))
         ,@body))))


(defmacro define-mock-method (label mock-controller-class arguments &body body)
  (alexandria:with-gensyms (!thunk !mock-controller !arguments !label)
    `(defmethod execute-mockable-block ((,!mock-controller ,mock-controller-class)
                                        (,!label (eq ',label))
                                        ,!arguments
                                        ,!thunk)
       (destructuring-bind ,arguments ,!arguments
         (declare (ignorable ,@arguments))
         ,@body))))
