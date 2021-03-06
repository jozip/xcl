;; clos.lisp -- CLOS benchmarking code
;;
;; Author: Eric Marsden <emarsden@laas.fr>
;; Time-stamp: <2003-12-30 emarsden>
;;
;;
;; This file does some benchmarking of CLOS functionality. It creates
;; a class hierarchy of the form
;;
;;                         class-0-0
;;                      /     |        \
;;                    /       |          \
;;                  /         |            \
;;          class-0-1      class-1-1     . class-2-1
;;             |         /    |     .  .   /    |
;;             |     /      . |  .       /      |
;;             |  /     .     |        /        |
;;          class-0-2      class-1-2       class-2-2
;;
;;
;; where the shape of the hierarchy is controlled by the parameters
;; +HIERARCHY-DEPTH+ and +HIERARCHY-WIDTH+. Note that classes to the
;; left of the diagram have more superclasses than those to the right.
;; It then defines methods specializing on each class (simple methods,
;; after methods and AND-type method combination), and
;; INITIALIZE-INSTANCE methods. The code measures the speed of
;;
;;    - creation of the class hierarchy (time taken to compile and
;;      execute the DEFCLASS forms)
;;
;;    - instance creation
;;
;;    - method definition (time taken to compile and execute the
;;      DEFMETHOD forms)
;;
;;    - execution of "simple" method invocations, both with and
;;      without :after methods
;;
;;    - execution of "complex" method invocations (using AND-type
;;      method combination)
;;
;;
;; This code is probably not representative of real usage of CLOS, but
;; should give an idea of the speed of a particular CLOS
;; implementation.
;;
;; Note: warnings about undefined accessors and types are normal when
;; compiling this code.


(in-package "CL-USER")


(eval-when (:compile-toplevel :load-toplevel :execute)
  (defconstant +hierarchy-depth+ 10)
  (defconstant +hierarchy-width+ 5))


;; the level-0 hierarchy
(defclass class-0-0 () ())

(defvar *instances* (make-array #.+hierarchy-width+ :element-type 'class-0-0))


(defgeneric simple-method (a b))

(defmethod simple-method ((self class-0-0) other) other)

(defgeneric complex-method (a b &rest rest)
  (:method-combination and))

(defmethod complex-method and ((self class-0-0) other &rest rest)
   (declare (ignore rest))
   other)

(defmacro make-class-name (depth width)
  (with-standard-io-syntax
    `(intern (format nil "CLASS-~d-~d" ,depth ,width))))

(defmacro make-attribute-name (depth width)
  (with-standard-io-syntax
    `(intern (format nil "ATTRIBUTE-~d-~d" ,depth ,width))))

(defmacro make-initarg-name (depth width)
  (with-standard-io-syntax
    `(intern (format nil "INITARG-~d-~d" ,depth ,width) :keyword)))

(defmacro make-accessor-name (depth width)
  (with-standard-io-syntax
    `(intern (format nil "GET-ATTRIBUTE-~d-~d" ,depth ,width))))

(defmacro class-definition (depth width)
  `(defclass ,(make-class-name depth width)
    ,(loop :for w :from width :below #.+hierarchy-width+
           :collect (make-class-name (1- depth) w))
    (( ,(make-attribute-name depth width)
      :initarg ,(make-initarg-name depth width)
      :initform (* ,depth ,width)
      :accessor ,(make-accessor-name depth width)))))

(defmacro init-instance-definition (depth width)
  `(defmethod initialize-instance :after ((self ,(make-class-name depth width)) &rest initargs)
    (declare (ignore initargs))
    (incf (,(make-accessor-name depth width) self))))

(defmacro simple-method-definition (depth width)
  `(defmethod simple-method ((self ,(make-class-name depth width))
                      (n number))
     (* n (call-next-method) (,(make-accessor-name depth width) self))))

(defmacro complex-method-definition (depth width)
  `(defmethod complex-method and ((self ,(make-class-name depth width))
                                  (n number) &rest rest)
     (declare (ignore n rest))
     (,(make-accessor-name depth width) self)))

(defmacro after-method-definition (depth width)
  `(defmethod simple-method :after ((self ,(make-class-name depth width))
                             (n number))
     (declare (ignore n))
     (setf (,(make-accessor-name depth width) self) ,(* depth width width))))

(defun defclass-forms ()
  (let (forms)
    (loop :for width :to #.+hierarchy-width+ :do
         (push `(defclass ,(make-class-name 1 width) (class-0-0) ()) forms))
    (loop :for dpth :from 2 :to +hierarchy-depth+ :do
          (loop :for wdth :to #.+hierarchy-width+ :do
                (push `(class-definition ,dpth ,wdth) forms)
                (push `(init-instance-definition ,dpth ,wdth) forms)))
    (nreverse forms)))

(defun defmethod-forms ()
  (let (forms)
    (loop :for dpth :from 2 to #.+hierarchy-depth+ :do
          (loop :for wdth :to #.+hierarchy-width+ :do
                (push `(simple-method-definition ,dpth ,wdth) forms)
                (push `(complex-method-definition ,dpth ,wdth) forms)))
    (nreverse forms)))

(defun after-method-forms ()
  (let (forms)
    (loop :for depth :from 2 :to #.+hierarchy-depth+ :do
          (loop :for width :to #.+hierarchy-width+ :do
                (push `(after-method-definition ,depth ,width) forms)))
    (nreverse forms)))

(defun run-defclass ()
  (funcall (compile nil `(lambda () ,@(defclass-forms)))))

(defun run-defmethod ()
  (funcall (compile nil `(lambda () ,@(defmethod-forms)))))

(defun add-after-methods ()
  (funcall (compile nil `(lambda () ,@(after-method-forms)))))

(defun make-instances ()
  (dotimes (i 5000)
    (dotimes (w #.+hierarchy-width+)
      (setf (aref *instances* w)
            (make-instance (make-class-name #.+hierarchy-depth+ w)
                           (make-initarg-name #.+hierarchy-depth+ w) 42))
      `(incf (slot-value (aref *instances* w) ',(make-attribute-name #.+hierarchy-depth+ w))))))

;; the code in the function MAKE-INSTANCES is very difficult to
;; optimize, because the arguments to MAKE-INSTANCE are not constant.
;; This test attempts to simulate the common case where some of the
;; parameters to MAKE-INSTANCE are constants.
(defclass a-simple-base-class ()
  ((attribute-one :accessor attribute-one
                  :initarg :attribute-one
                  :type string)))

(defclass a-derived-class (a-simple-base-class)
  ((attribute-two :accessor attribute-two
                  :initform 42
                  :type integer)))

(defun make-instances/simple ()
  (dotimes (i 5000)
    (make-instance 'a-derived-class
                   :attribute-one "The first attribute"))
  (dotimes (i 5000)
    (make-instance 'a-derived-class
                   :attribute-one "The non-defaulting attribute")))


(defun methodcall/simple (num)
  (dotimes (i 5000)
    (simple-method (aref *instances* num) i)))

(defun methodcalls/simple ()
  (dotimes (w #.+hierarchy-width+)
    (methodcall/simple w)))

(defun methodcalls/simple+after ()
  (add-after-methods)
  (dotimes (w #.+hierarchy-width+)
    (methodcall/simple w)))

(defun methodcall/complex (num)
  (dotimes (i 5000)
    (complex-method (aref *instances* num) i)))

(defun methodcalls/complex ()
  (dotimes (w #.+hierarchy-width+)
    (methodcall/complex w)))



;;; CLOS implementation of the Fibonnaci function, with EQL specialization

(defgeneric eql-fib (x))

(defmethod eql-fib ((x (eql 0)))
   1)

(defmethod eql-fib ((x (eql 1)))
   1)

; a method for all other cases
(defmethod eql-fib (x)
   (+ (eql-fib (- x 1))
      (eql-fib (- x 2))))


(defun run-eql-fib ()
  (eql-fib 30))

(defun stamp (stream)
  (multiple-value-bind (sec min hour date month year)
      (decode-universal-time (get-universal-time))
    (declare (ignore sec))
    (let (pm)
      (format stream "~A ~D ~D ~D:~2,'0D ~A~%"
              (ecase month
                ( 1 "Jan")
                ( 2 "Feb")
                ( 3 "Mar")
                ( 4 "Apr")
                ( 5 "May")
                ( 6 "Jun")
                ( 7 "Jul")
                ( 8 "Aug")
                ( 9 "Sep")
                (10 "Oct")
                (11 "Nov")
                (12 "Dec"))
              date
              year
              (progn
                (cond ((zerop hour)
                       (setq hour 12))
                      ((eql hour 12)
                       (setq pm t))
                      ((> hour 12)
                       (setq hour (- hour 12))
                       (setq pm t)))
                hour)
              min
              (if pm "PM" "AM")))))

(defun run-tests ()
  (with-open-stream (log (open (merge-pathnames "bench-clos.log"
                                                (user-homedir-pathname))
                               :direction :output
                               :if-exists :append
                               :if-does-not-exist :create))
    (with-open-stream (out (make-broadcast-stream *standard-output* log))
      (let ((*compile-verbose* nil)
            (*compile-print* nil)
            #+xcl
            (sys:*mumble* nil))
        (stamp out)
        (format out "~&~A ~A~%" (lisp-implementation-type) (lisp-implementation-version))
        #+xcl
        (let ((*standard-output* out))
          (describe-compiler-policy))
        (dolist (test '(run-defclass
                        run-defmethod
                        make-instances
                        make-instances/simple
                        methodcalls/simple
                        methodcalls/simple+after
                        methodcalls/complex
;;                         run-eql-fib
                        ))
          (let ((start (get-internal-run-time))
                end)
            (funcall test)
            (setq end (get-internal-run-time))
            (format out "~&  ~S~32T~7,3F seconds~%"
                    test
                    (/ (float (- end start))
                       internal-time-units-per-second))))
        (terpri out)))))

;; EOF
