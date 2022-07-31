(cl:in-package #:de-mock-racy)


(defgeneric execute-mockable-block (mock-controller label arguments thunk))
(defgeneric waiting-calls (mock-controller))
(defgeneric implementation-closure (waiting-call))
(defgeneric waiting-call-used-up-p (waiting-call))
(defgeneric waiting-calls-search-matching (waiting-calls mock-controller label arguments))
(defgeneric waiting-call-accept-p (waiting-call mock-controller label arguments))
(defgeneric waiting-call-invoke (waiting-call mock-controller label arguments thunk))
(defgeneric waiting-calls-enque (waiting-calls &rest arguments))
(defgeneric waiting-calls-every-used-up-p (waiting-calls))

(defgeneric waiting-call-class (basic-waiting-calls))
(defgeneric filter-closure (waiting-call))
(defgeneric usage-count (waiting-call))
(defgeneric (setf usage-count) (new-value waiting-call))
(defgeneric content (waiting-calls))
