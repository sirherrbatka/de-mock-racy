(cl:in-package #:de-mock-racy)


(defmethod execute-mockable-block ((mock-controller (eql nil))
                                   label
                                   arguments
                                   thunk)
  (funcall thunk))


(defmethod execute-mockable-block :around ((mock-controller basic-mock-controller)
                                           label
                                           arguments
                                           thunk)
  (let* ((waiting-calls (waiting-calls mock-controller))
         (waiting-call (waiting-calls-search-matching waiting-calls mock-controller
                                                      label arguments)))
    (if (null waiting-call)
        (call-next-method)
        (waiting-call-invoke waiting-call mock-controller label arguments thunk))))


(defmethod waiting-call-accept-p ((waiting-call basic-waiting-call)
                                  mock-controller
                                  label
                                  arguments)
  (funcall (filter-closure waiting-call) mock-controller label arguments))


(defmethod waiting-calls-search-matching ((waiting-calls basic-waiting-calls)
                                          mock-controller
                                          label
                                          arguments)
  (find-if (lambda (waiting-call)
             (and (not (waiting-call-used-up-p waiting-call))
                  (waiting-call-accept-p waiting-call mock-controller label arguments)))
           (content waiting-calls)))


(defmethod waiting-call-invoke ((waiting-call basic-waiting-call)
                                mock-controller
                                label
                                arguments
                                thunk)
  (assert (not (waiting-call-used-up-p waiting-call)))
  (decf (usage-count waiting-call))
  (funcall (implementation-closure waiting-call) mock-controller label arguments thunk))


(defmethod waiting-calls-enque ((waiting-calls basic-waiting-calls)
                                &rest arguments)
  (let* ((waiting-call-class (waiting-call-class waiting-calls))
         (waiting-call (apply #'make-instance waiting-call-class arguments))
         (content (content waiting-calls)))
    (vector-push-extend waiting-call content)
    waiting-calls))


(defmethod waiting-call-used-up-p ((waiting-call basic-waiting-call))
  (<= (usage-count waiting-call) 0))


(defmethod waiting-calls-every-used-up-p ((waiting-calls basic-waiting-calls))
  (every #'waiting-call-used-up-p (content waiting-calls)))
