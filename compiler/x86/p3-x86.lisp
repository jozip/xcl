;;; p3-x86.lisp
;;;
;;; Copyright (C) 2006-2009 Peter Graves <peter@armedbear.org>
;;;
;;; This program is free software; you can redistribute it and/or
;;; modify it under the terms of the GNU General Public License
;;; as published by the Free Software Foundation; either version 2
;;; of the License, or (at your option) any later version.
;;;
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with this program; if not, write to the Free Software
;;; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

(in-package "COMPILER")

(defun finalize-ir2 ()
  (let* ((compiland *current-compiland*)
         (code *code*)
         (len (length code))
         ;; make initial size big enough to avoid having to resize the output vector
         (initial-size (max (logand (+ len (ash len -1) 16) (lognot 15)) 64))
         (new-code (make-array initial-size :fill-pointer 0))
         (index -1) ; first local is at -4(%ebp)
         )
    (declare (type simple-vector code))
    (dotimes (i (length code))
      (let ((instruction (svref code i)))
        (declare (type ir2-instruction instruction))
        (let ((operator (operator instruction)))
          (case operator
            (:exit
             (unless (compiland-omit-frame-pointer compiland)
               ;;                    (vector-push-extend '(:leave) new-code)
               (vector-push-extend (make-ir2-instruction :leave nil nil) new-code)
               )
             (dolist (reg (reverse (compiland-registers-to-be-saved compiland)))
               ;;                    (vector-push-extend `(:pop ,reg) new-code)
               (vector-push-extend (make-ir2-instruction :pop reg nil) new-code)
               )
             ;;                  (vector-push-extend '(:ret) new-code)
             (vector-push-extend (make-ir2-instruction :ret nil nil) new-code)
             )
            (:align-stack
             (aver nil)
             ;;                  (unless (compiland-leaf-p compiland)
             ;;                    (let ((*code* nil)
             ;;                          (*main* nil)
             ;;                          (*elsewhere* nil)
             ;;                          (*current-segment* :main))
             ;;                      (let ((OK (make-label)))
             ;;                        (inst :test 15 :esp)
             ;;                        (emit-jmp-short :z OK)
             ;;                        (inst :sub 8 :rsp)
             ;;                        (inst :test 15 :rsp)
             ;;                        (emit-jmp-short :z OK)
             ;;                        (inst :int3)
             ;;                        (label OK))
             ;;                      (dotimes (i (length *main*))
             ;;                        (vector-push-extend (aref *main* i) new-code))))
             )
            (:allocate-local
             ;; FIXME move this case to FINALIZE-VARS
             (let ((var (operand1 instruction)))
               ;;                    (aver (var-p var))
               (declare (type var var))
               (aver (null (var-index var)))
               (aver (null (var-register var)))
               (setf (var-index var) index)
               (decf index)
               ;; FIXME coalesce all these pushes at the end of FINALIZE-VARS
               ;;                    (vector-push-extend '(:push :eax) new-code)
               (vector-push-extend (make-ir2-instruction :push :eax nil) new-code)
               ))
            (:enter-frame
             (unless (compiland-omit-frame-pointer compiland)
               ;;                    (vector-push-extend '(:push :ebp) new-code)
               (vector-push-extend (make-ir2-instruction :push :ebp nil) new-code)
               ;;                    (vector-push-extend '(:mov :esp :ebp) new-code)
               (vector-push-extend (make-ir2-instruction :mov :esp :ebp) new-code)
               ))
            (:initialize-thread-var
             (when (compiland-thread-var compiland)
               ;;                    (vector-push-extend '(:call "RT_current_thread") new-code)
               (vector-push-extend (make-ir2-instruction :call "RT_current_thread" nil) new-code)
               ;;                    (vector-push-extend `(:mov :eax ,(compiland-thread-var compiland)) new-code)
               (vector-push-extend (make-ir2-instruction :mov :eax (compiland-thread-var compiland)) new-code)
               ))
            (:save-registers
             (dolist (reg (compiland-registers-to-be-saved compiland))
               ;;                    (vector-push-extend `(:push ,reg) new-code)
               (vector-push-extend (make-ir2-instruction :push reg nil) new-code)
               ))
            (t
             (vector-push-extend instruction new-code))))))
    (setq *code* (coerce new-code 'simple-vector))))

(defparameter *combine-binary-data* t)

(defun add-instruction (instruction code)
  (when (and *combine-binary-data*
             (memq (instruction-kind instruction) '(:bytes :byte))
             (plusp (length code)))
    (let ((last-instruction (aref code (1- (length code)))))
      (when (eq (instruction-kind last-instruction) :bytes)
        (let* ((new-size (+ (instruction-size instruction)
                            (instruction-size last-instruction)))
               (data (instruction-data instruction))
               (new-data (nconc (instruction-data last-instruction)
                                (if (listp data) data (list data)))))
          (set-instruction-size last-instruction new-size)
          (set-instruction-data last-instruction new-data)
          (return-from add-instruction)))))
  (vector-push-extend instruction code))

(defun assemble-ir2 ()
;;   (generate-function-prolog)
  (let* (;;(compiland *current-compiland*)
         (code *code*)
         (len (length code))
         ;; make initial size big enough to avoid having to resize the output vector
         (initial-size (max (logand (+ len (ash len -1) 16) (lognot 15)) 64))
         (new-code (make-array initial-size :fill-pointer 0))
         (leaf-p t)
         (var-ref-count 0))
    (declare (type simple-vector code))
    (dotimes (i (length code))
      (let ((instruction (svref code i)))
        (declare (type ir2-instruction instruction))
        (let ((operator (operator instruction))
              (operand1 (operand1 instruction))
              (operand2 (operand2 instruction)))
          (case operator
            (:mov
             (cond ((var-p operand1)
                    ;; var ref
                    (incf var-ref-count)
                    (cond ((var-index operand1)
                           (setf (operand1 instruction)
                                 (list (index-displacement (var-index operand1)) :ebp)))
                          ((var-register operand1)
                           (setf (operand1 instruction) (var-register operand1)))
                          (t
                           (mumble "p3 :mov no var-index for var ~S~%" (var-name operand1))
                           (unsupported))))
                   ((var-p operand2)
                    ;; setq
                    (incf var-ref-count)
                    (cond ((var-index operand2)
                           (setf (operand2 instruction)
                                 (list (index-displacement (var-index operand2)) :ebp)))
                          ((var-register operand2)
                           (setf (operand2 instruction) (var-register operand2)))
                          (t
                           (mumble "p3 :mov no var-index for var ~S~%" (var-name operand2))
                           (unsupported))))
                   (t
                    ;; nothing to do
                    ))
             (add-instruction (assemble-ir2-instruction instruction) new-code))
            (:push
             (cond ((var-p operand1)
                    (cond ((var-index operand1)
                           (setf (operand1 instruction)
                                 (list (index-displacement (var-index operand1)) :ebp))
                           (add-instruction (assemble-ir2-instruction instruction) new-code))
                          ((var-register operand1)
                           (setf (operand1 instruction) (var-register operand1))
                           (add-instruction (assemble-ir2-instruction instruction) new-code))
                          (t
                           (mumble "p3 :push no var-index for var ~S~%" (var-name operand1))
                           (unsupported))))
                   ((and (consp operand1)
                         (length-eql operand1 2)
                         (eq (%car operand1) :constant))
                    (add-instruction (make-instruction :bytes 1 '(#x68)) new-code)
                    (add-instruction (make-instruction :constant 4 (%cadr operand1)) new-code))
                   (t
                    ;; nothing to do
                    (add-instruction (assemble-ir2-instruction instruction) new-code))))
            (:push-immediate
             (cond ((and (consp operand1)
                         (eq (%car operand1) :constant))
                    (aver (length-eql operand1 2))
                    (add-instruction (make-instruction :bytes 1 '(#x68)) new-code)
                    (add-instruction
                     (make-instruction :constant 4 (%cadr operand1))
                     new-code))
                   (t
                    (mumble "push-immediate unsupported case~%")
                    (unsupported))))
            (:exit
             (aver nil)
             ;;                  (let ((instructions nil))
             ;;                    (unless (compiland-omit-frame-pointer compiland)
             ;;                      (push '(:leave) instructions))
             ;;                    (dolist (reg (reverse (compiland-registers-to-be-saved compiland)))
             ;;                      (push `(:pop ,reg) instructions))
             ;;                    (push '(:ret) instructions)
             ;;                    (setq instructions (nreverse instructions))
             ;;                    (let ((bytes (assemble instructions)))
             ;;                      (setq instruction
             ;;                            (make-instruction :exit (length bytes) (coerce bytes 'list)))
             ;;                      ;;                        (setf (svref code i) instruction)
             ;;                      ))
             ;;                  (add-instruction instruction new-code)
             )
            (:call
             (setq leaf-p nil)
             ;;                  (setq instruction (make-instruction :call 5 operand1))
             ;;                  (add-instruction instruction new-code)
             (add-instruction (make-instruction :call 5 operand1) new-code)
             )
            (:move-immediate
             (cond ((and (consp operand1)
                         (eq (%car operand1) :function))
                    (aver (length-eql operand1 2))
                    (let ((symbol (%cadr operand1))
                          (register operand2))
                      ;; mov imm32, reg
                      (add-instruction
                       (make-instruction :bytes 1 (list (+ #xb8 (register-number register))))
                       new-code)
                      (add-instruction
                       (make-instruction :function 4 symbol)
                       new-code)))
                   ((and (consp operand1)
                         (eq (%car operand1) :constant))
                    (aver (length-eql operand1 2))
                    (let ((form (%cadr operand1))
                          (register operand2))
                      (cond ((memq register '(:eax :ebx :ecx :edx :esi :edi))
                             (add-instruction
                              (make-instruction :bytes 1 (list (+ #xb8 (register-number register))))
                              new-code))
                            (t
                             (mumble "p3 :move-immediate :constant unsupported case register = ~S~%"
                                     register)
                             (unsupported)))
                      (add-instruction
                       (make-instruction :constant 4 form)
                       new-code)))
                   (t
                    (mumble "p3 :move-immediate unsupported case~%")
                    (unsupported))))
            (:compare-immediate
             (let (form register)
               (cond ((memq operand1 '(nil t))
                      (setq form     operand1
                            register operand2))
                     ((and (consp operand1)
                           (eq (%car operand1) :constant))
                      (aver (length-eql operand1 2))
                      (setq form     (%cadr operand1)
                            register operand2))
                     (t
                      (mumble "p3 :compare-immediate unsupported case~%")
                      (unsupported)))
               (aver (memq register '(:eax :ebx :ecx :edx :esi :edi)))
               (if (eq register :eax)
                   (add-instruction (make-instruction :bytes 1 '(#x3d)) new-code)
                   (add-instruction (make-instruction :bytes 2
                                                         (list #x81 (+ #xf8 (register-number register))))
                                       new-code))
               (add-instruction (make-instruction :constant 4 form) new-code)))
            (:byte
             (add-instruction (make-instruction :bytes 1 (list operand1)) new-code))
            (:bytes
             (let* ((bytes (operand1 instruction))
                    (length (length bytes)))
               (add-instruction (make-instruction :bytes length bytes) new-code)))
            (:recurse
             (add-instruction (make-instruction :recurse 5 nil) new-code))
            (t
             (add-instruction (assemble-ir2-instruction instruction) new-code))))))
    (when (> (length new-code) initial-size)
      (mumble "p3 initial-size = ~D (length new-code) = ~D~%"
              initial-size
              (length new-code)))
    (setq *code* (coerce new-code 'simple-vector))))

(defun convert-binary-data ()
  (let ((code *code*))
    (declare (type simple-vector code))
    (dotimes (i (length code))
      (let ((instruction (aref code i)))
        (when (eq (instruction-kind instruction) :bytes)
          (setf (aref code i)
                (coerce (the list (instruction-data instruction)) '(simple-array (unsigned-byte 8) 1))))))))

(defun p3 ()
  (finalize-ir2)
  (assemble-ir2)
  (convert-binary-data))
