(cl:in-package #:de-mock-racy)


(defmacro mockable-block ((label &rest arguments) &body body)
  "Defines block that can be later mocked."
  `(execute-mockable-block *mock-controller*
                           ',label
                           (list ,@arguments)
                           (lambda () ,@body)))


(defmacro filter (label arguments &body body)
  "Expands into a lambda form suitable as :filter argument for the make-instance 'basic-waiting-call. Each form in body is supposed to return non-nil in order for filter to accept form."
  (alexandria:with-gensyms (!waiting-call !mock-controller !label !arguments)
    `(lambda (,!waiting-call ,!mock-controller ,!label ,!arguments)
       (declare (ignore ,!waiting-call ,!mock-controller))
       (and (eq ,!label ',label)
            (= ,(length arguments) (length ,!arguments))
            (destructuring-bind ,arguments ,!arguments
              (declare (ignorable ,@arguments))
              (and ,@body))))))


(defmacro implementation (arguments &body body)
  "Expands into a lambda form suitable as :implementation argument for the make-instance 'basic-waiting-call."
  (alexandria:with-gensyms (!waiting-call !mock-controller !label !arguments !thunk)
    `(lambda (,!waiting-call ,!mock-controller ,!label ,!arguments ,!thunk)
       (declare (ignore ,!waiting-call ,!mock-controller ,!label ,!thunk))
       (destructuring-bind ,arguments ,!arguments
         (declare (ignorable ,@arguments))
         ,@body))))


(defmacro define-mock-method (label mock-controller-class arguments &body body)
  "Defines execute-mockable-block method for a given mock-controller class and label."
  (alexandria:with-gensyms (!thunk !mock-controller !arguments !label)
    `(defmethod execute-mockable-block ((,!mock-controller ,mock-controller-class)
                                        (,!label (eql ',label))
                                        ,!arguments
                                        ,!thunk)
       (destructuring-bind ,arguments ,!arguments
         (declare (ignorable ,@arguments))
         ,@body))))
