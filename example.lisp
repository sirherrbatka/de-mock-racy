(cl:in-package #:cl-user)


(defun example-implementation (a b)
  (format t "Called implementation with arguments ~a, ~a.~%" a b))


(defun example-function (&optional (a 1) (b 2))
  (format t "Called main function, now calling the mockable-block...~%")
  (de-mock-racy:mockable-block #1=(example-implementation a b)
    #1#))

(example-function)

#|
Called main function, now calling the mockable-block...
Called implementation with arguments 1, 2.
|#

(let* ((waiting-calls (make-instance 'de-mock-racy:basic-waiting-calls))
       (de-mock-racy:*mock-controller* (make-instance 'de-mock-racy:basic-mock-controller
                                                      :waiting-calls waiting-calls)))
  (de-mock-racy:waiting-calls-enque waiting-calls
                                    :filter (de-mock-racy:filter example-implementation (a b)
                                              (= a 1)
                                              (= b 2))
                                    :implementation (de-mock-racy:implementation (a b)
                                                      (format t "Called mock implementation with arguments ~a, ~a~%" a b)))
  (example-function)
  (when (de-mock-racy:waiting-calls-every-used-up-p waiting-calls)
    (format t "All of the waiting-calls used up.~%")))

#|
Called main function, now calling the mockable-block...
Called mock implementation with arguments 1, 2
All of the waiting-calls used up.
|#

(let* ((waiting-calls (make-instance 'de-mock-racy:basic-waiting-calls))
       (de-mock-racy:*mock-controller* (make-instance 'de-mock-racy:basic-mock-controller
                                                      :waiting-calls waiting-calls)))
  (de-mock-racy:waiting-calls-enque waiting-calls
                                    :filter (de-mock-racy:filter example-implementation (a b)
                                              (= a 1)
                                              (= b 2))
                                    :implementation (de-mock-racy:implementation (a b)
                                                      (format t "Called mock implementation with arguments ~a, ~a~%" a b)))
  (example-function)
  (example-function)
  )

;; The above will emit eror because by default each waiting call can be invoked only once. This can be corrected...

(let* ((waiting-calls (make-instance 'de-mock-racy:basic-waiting-calls))
       (de-mock-racy:*mock-controller* (make-instance 'de-mock-racy:basic-mock-controller
                                                      :waiting-calls waiting-calls)))
  (de-mock-racy:waiting-calls-enque waiting-calls
                                    :usage-count 2
                                    :filter (de-mock-racy:filter example-implementation (a b)
                                              (= a 1)
                                              (= b 2))
                                    :implementation (de-mock-racy:implementation (a b)
                                                      (format t "Called mock implementation with arguments ~a, ~a~%" a b)))
  (example-function)
  (example-function)
  (when (de-mock-racy:waiting-calls-every-used-up-p waiting-calls)
    (format t "All of the waiting-calls used up.~%")))

#|
Called main function, now calling the mockable-block...
Called mock implementation with arguments 1, 2
Called main function, now calling the mockable-block...
Called mock implementation with arguments 1, 2
All of the waiting-calls used up.
|#

;; It is also possible to pass nil as :usage-count to allow unlitmited number of calls.

(let* ((waiting-calls (make-instance 'de-mock-racy:basic-waiting-calls))
       (de-mock-racy:*mock-controller* (make-instance 'de-mock-racy:basic-mock-controller
                                                      :waiting-calls waiting-calls)))
  (de-mock-racy:waiting-calls-enque waiting-calls
                                    :usage-count nil
                                    :filter (de-mock-racy:filter example-implementation (a b)
                                              (= a 1)
                                              (= b 2))
                                    :implementation (de-mock-racy:implementation (a b)
                                                      (format t "Called mock implementation with arguments ~a, ~a~%" a b)))
  (example-function)
  (example-function)
  (unless (de-mock-racy:waiting-calls-every-used-up-p waiting-calls)
    (format t "This will always print because usage-count is nil.~%")))

#|
Called mock implementation with arguments 1, 2
Called main function, now calling the mockable-block...
Called mock implementation with arguments 1, 2
This will always print because usage-count is nil.
|#

;; you can enque multiple waiting-calls.

(let* ((waiting-calls (make-instance 'de-mock-racy:basic-waiting-calls))
       (de-mock-racy:*mock-controller* (make-instance 'de-mock-racy:basic-mock-controller
                                                      :waiting-calls waiting-calls)))
  (de-mock-racy:waiting-calls-enque waiting-calls
                                    :filter (de-mock-racy:filter example-implementation (a b)
                                              (= a 1) (= b 2))
                                    :implementation (de-mock-racy:implementation (a b)
                                                      (format t "Called mock implementation 1 with arguments ~a, ~a~%" a b)))
  (de-mock-racy:waiting-calls-enque waiting-calls
                                    :filter (de-mock-racy:filter example-implementation (a b)
                                              (= a 1) (= b 2))
                                    :implementation (de-mock-racy:implementation (a b)
                                                      (format t "Called mock implementation 2 with arguments ~a, ~a~%" a b)))
  (example-function)
  (example-function)
  (unless (de-mock-racy:waiting-calls-every-used-up-p waiting-calls)
    (format t "All of the waiting-calls used up.~%")))

#|
Called main function, now calling the mockable-block...
Called mock implementation 1 with arguments 1, 2
Called main function, now calling the mockable-block...
Called mock implementation 2 with arguments 1, 2
|#

;; let's subclass basic-mock-controller to implement shared mock implementation

(defclass application-specific-mock-controller (de-mock-racy:basic-mock-controller)
  ())

(de-mock-racy:define-mock-method example-implementation application-specific-mock-controller (a b)
  (format t "This is handy if you need to mock a shared default behavior. It can be still shadowed by waiting-call.~%")
  (format t "Oh, btw: arguments a: ~a, b: ~a.~%" a b))

(let* ((waiting-calls (make-instance 'de-mock-racy:basic-waiting-calls))
       (de-mock-racy:*mock-controller* (make-instance 'application-specific-mock-controller
                                                      :waiting-calls waiting-calls)))
  (de-mock-racy:waiting-calls-enque waiting-calls
                                    :usage-count 1
                                    :filter (de-mock-racy:filter example-implementation (a b)
                                              (= a 1)
                                              (= b 2))
                                    :implementation (de-mock-racy:implementation (a b)
                                                      (format t "Called mock implementation with arguments ~a, ~a~%" a b)))
  (example-function 3 4) ; misses filter
  (example-function) ; hits filter
  (example-function) ; would hit filter, but call is already used up
  (when (de-mock-racy:waiting-calls-every-used-up-p waiting-calls)
    (format t "All used up again.")))

#|
Called main function, now calling the mockable-block...
This is a handy if you need to mock a shared default behavior. It can be still shadowed by waiting-call.
Oh, btw: arguments a: 3, b: 4.
Called main function, now calling the mockable-block...
Called mock implementation with arguments 1, 2
Called main function, now calling the mockable-block...
This is a handy if you need to mock a shared default behavior. It can be still shadowed by waiting-call.
Oh, btw: arguments a: 1, b: 2.
All used up again.
|#
