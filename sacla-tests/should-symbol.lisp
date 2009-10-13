;; Copyright (C) 2002-2004, Yuji Minejima <ggb01164@nifty.ne.jp>
;; ALL RIGHTS RESERVED.
;;
;; $Id: should-symbol.lisp,v 1.7 2004/02/20 07:23:42 yuji Exp $
;; 
;; Redistribution and use in source and binary forms, with or without
;; modification, are permitted provided that the following conditions
;; are met:
;; 
;;  * Redistributions of source code must retain the above copyright
;;    notice, this list of conditions and the following disclaimer.
;;  * Redistributions in binary form must reproduce the above copyright
;;    notice, this list of conditions and the following disclaimer in
;;    the documentation and/or other materials provided with the
;;    distribution.
;; 
;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
;; "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
;; LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
;; A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
;; OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
;; SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
;; LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
;; DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
;; THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
;; (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
;; OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

(HANDLER-CASE (PROGN (MAKE-SYMBOL 'NOT-A-STRING))
  (TYPE-ERROR NIL T)
  (ERROR NIL NIL)
  (:NO-ERROR (&REST REST) (DECLARE (IGNORE REST)) NIL))
(HANDLER-CASE (PROGN (MAKE-SYMBOL #\a))
  (TYPE-ERROR NIL T)
  (ERROR NIL NIL)
  (:NO-ERROR (&REST REST) (DECLARE (IGNORE REST)) NIL))
(HANDLER-CASE (PROGN (MAKE-SYMBOL '(NAME)))
  (TYPE-ERROR NIL T)
  (ERROR NIL NIL)
  (:NO-ERROR (&REST REST) (DECLARE (IGNORE REST)) NIL))

(HANDLER-CASE (PROGN (COPY-SYMBOL "NOT A SYMBOL"))
  (TYPE-ERROR NIL T)
  (ERROR NIL NIL)
  (:NO-ERROR (&REST REST) (DECLARE (IGNORE REST)) NIL))
(HANDLER-CASE (PROGN (COPY-SYMBOL #\a))
  (TYPE-ERROR NIL T)
  (ERROR NIL NIL)
  (:NO-ERROR (&REST REST) (DECLARE (IGNORE REST)) NIL))
(HANDLER-CASE (PROGN (COPY-SYMBOL '(NAME)))
  (TYPE-ERROR NIL T)
  (ERROR NIL NIL)
  (:NO-ERROR (&REST REST) (DECLARE (IGNORE REST)) NIL))


(HANDLER-CASE (PROGN (GENSYM 'EAT-THIS))
  (TYPE-ERROR NIL T)
  (ERROR NIL NIL)
  (:NO-ERROR (&REST REST) (DECLARE (IGNORE REST)) NIL))
(HANDLER-CASE (PROGN (GENSYM -1))
  (TYPE-ERROR NIL T)
  (ERROR NIL NIL)
  (:NO-ERROR (&REST REST) (DECLARE (IGNORE REST)) NIL))
(HANDLER-CASE (PROGN (GENSYM #\a))
  (TYPE-ERROR NIL T)
  (ERROR NIL NIL)
  (:NO-ERROR (&REST REST) (DECLARE (IGNORE REST)) NIL))


(HANDLER-CASE (PROGN (GENTEMP 'NOT-A-STRING))
  (TYPE-ERROR NIL T)
  (ERROR NIL NIL)
  (:NO-ERROR (&REST REST) (DECLARE (IGNORE REST)) NIL))
(HANDLER-CASE (PROGN (GENTEMP #\a))
  (TYPE-ERROR NIL T)
  (ERROR NIL NIL)
  (:NO-ERROR (&REST REST) (DECLARE (IGNORE REST)) NIL))
(HANDLER-CASE (PROGN (GENTEMP "TEMP" '(NIL)))
  (TYPE-ERROR NIL T)
  (ERROR NIL NIL)
  (:NO-ERROR (&REST REST) (DECLARE (IGNORE REST)) NIL))


(HANDLER-CASE (PROGN (SYMBOL-FUNCTION "not-a-function"))
  (TYPE-ERROR NIL T)
  (ERROR NIL NIL)
  (:NO-ERROR (&REST REST) (DECLARE (IGNORE REST)) NIL))
(HANDLER-CASE (PROGN (SYMBOL-FUNCTION #\a))
  (TYPE-ERROR NIL T)
  (ERROR NIL NIL)
  (:NO-ERROR (&REST REST) (DECLARE (IGNORE REST)) NIL))
(HANDLER-CASE (PROGN (SYMBOL-FUNCTION '(NIL)))
  (TYPE-ERROR NIL T)
  (ERROR NIL NIL)
  (:NO-ERROR (&REST REST) (DECLARE (IGNORE REST)) NIL))
(HANDLER-CASE
    (PROGN (FMAKUNBOUND 'SYMBOL-FOR-TEST) (SYMBOL-FUNCTION 'SYMBOL-FOR-TEST))
  (UNDEFINED-FUNCTION NIL T)
  (ERROR NIL NIL)
  (:NO-ERROR (&REST REST) (DECLARE (IGNORE REST)) NIL))

(HANDLER-CASE (PROGN (SYMBOL-NAME "not-a-symbol"))
  (TYPE-ERROR NIL T)
  (ERROR NIL NIL)
  (:NO-ERROR (&REST REST) (DECLARE (IGNORE REST)) NIL))
(HANDLER-CASE (PROGN (SYMBOL-NAME #\a))
  (TYPE-ERROR NIL T)
  (ERROR NIL NIL)
  (:NO-ERROR (&REST REST) (DECLARE (IGNORE REST)) NIL))
(HANDLER-CASE (PROGN (SYMBOL-NAME '(NIL)))
  (TYPE-ERROR NIL T)
  (ERROR NIL NIL)
  (:NO-ERROR (&REST REST) (DECLARE (IGNORE REST)) NIL))

(HANDLER-CASE (PROGN (SYMBOL-PACKAGE "not-a-symbol"))
  (TYPE-ERROR NIL T)
  (ERROR NIL NIL)
  (:NO-ERROR (&REST REST) (DECLARE (IGNORE REST)) NIL))
(HANDLER-CASE (PROGN (SYMBOL-PACKAGE #\a))
  (TYPE-ERROR NIL T)
  (ERROR NIL NIL)
  (:NO-ERROR (&REST REST) (DECLARE (IGNORE REST)) NIL))
(HANDLER-CASE (PROGN (SYMBOL-PACKAGE '(NIL)))
  (TYPE-ERROR NIL T)
  (ERROR NIL NIL)
  (:NO-ERROR (&REST REST) (DECLARE (IGNORE REST)) NIL))

(HANDLER-CASE (PROGN (SYMBOL-PLIST "not-a-symbol"))
  (TYPE-ERROR NIL T)
  (ERROR NIL NIL)
  (:NO-ERROR (&REST REST) (DECLARE (IGNORE REST)) NIL))
(HANDLER-CASE (PROGN (SYMBOL-PLIST #\a))
  (TYPE-ERROR NIL T)
  (ERROR NIL NIL)
  (:NO-ERROR (&REST REST) (DECLARE (IGNORE REST)) NIL))
(HANDLER-CASE (PROGN (SYMBOL-PLIST '(NIL)))
  (TYPE-ERROR NIL T)
  (ERROR NIL NIL)
  (:NO-ERROR (&REST REST) (DECLARE (IGNORE REST)) NIL))

(HANDLER-CASE (PROGN (SYMBOL-VALUE "not-a-symbol"))
  (TYPE-ERROR NIL T)
  (ERROR NIL NIL)
  (:NO-ERROR (&REST REST) (DECLARE (IGNORE REST)) NIL))
(HANDLER-CASE (PROGN (SYMBOL-VALUE #\a))
  (TYPE-ERROR NIL T)
  (ERROR NIL NIL)
  (:NO-ERROR (&REST REST) (DECLARE (IGNORE REST)) NIL))
(HANDLER-CASE (PROGN (SYMBOL-VALUE '(NIL)))
  (TYPE-ERROR NIL T)
  (ERROR NIL NIL)
  (:NO-ERROR (&REST REST) (DECLARE (IGNORE REST)) NIL))

(HANDLER-CASE (PROGN (PROGN (MAKUNBOUND 'A) (SYMBOL-VALUE 'A)))
  (UNBOUND-VARIABLE NIL T)
  (ERROR NIL NIL)
  (:NO-ERROR (&REST REST) (DECLARE (IGNORE REST)) NIL))



(HANDLER-CASE (PROGN (GET "not-a-symbol" 'A))
  (TYPE-ERROR NIL T)
  (ERROR NIL NIL)
  (:NO-ERROR (&REST REST) (DECLARE (IGNORE REST)) NIL))
(HANDLER-CASE (PROGN (GET #\a 'A))
  (TYPE-ERROR NIL T)
  (ERROR NIL NIL)
  (:NO-ERROR (&REST REST) (DECLARE (IGNORE REST)) NIL))
(HANDLER-CASE (PROGN (GET '(NIL) 'A))
  (TYPE-ERROR NIL T)
  (ERROR NIL NIL)
  (:NO-ERROR (&REST REST) (DECLARE (IGNORE REST)) NIL))



(HANDLER-CASE (PROGN (REMPROP "not-a-symbol" 'A))
  (TYPE-ERROR NIL T)
  (ERROR NIL NIL)
  (:NO-ERROR (&REST REST) (DECLARE (IGNORE REST)) NIL))
(HANDLER-CASE (PROGN (REMPROP #\a 'A))
  (TYPE-ERROR NIL T)
  (ERROR NIL NIL)
  (:NO-ERROR (&REST REST) (DECLARE (IGNORE REST)) NIL))
(HANDLER-CASE (PROGN (REMPROP '(NIL) 'A))
  (TYPE-ERROR NIL T)
  (ERROR NIL NIL)
  (:NO-ERROR (&REST REST) (DECLARE (IGNORE REST)) NIL))

(HANDLER-CASE (PROGN (BOUNDP "not-a-symbol"))
  (TYPE-ERROR NIL T)
  (ERROR NIL NIL)
  (:NO-ERROR (&REST REST) (DECLARE (IGNORE REST)) NIL))
(HANDLER-CASE (PROGN (BOUNDP #\a))
  (TYPE-ERROR NIL T)
  (ERROR NIL NIL)
  (:NO-ERROR (&REST REST) (DECLARE (IGNORE REST)) NIL))
(HANDLER-CASE (PROGN (BOUNDP '(NIL)))
  (TYPE-ERROR NIL T)
  (ERROR NIL NIL)
  (:NO-ERROR (&REST REST) (DECLARE (IGNORE REST)) NIL))

(HANDLER-CASE (PROGN (MAKUNBOUND "not-a-symbol"))
  (TYPE-ERROR NIL T)
  (ERROR NIL NIL)
  (:NO-ERROR (&REST REST) (DECLARE (IGNORE REST)) NIL))
(HANDLER-CASE (PROGN (MAKUNBOUND #\a))
  (TYPE-ERROR NIL T)
  (ERROR NIL NIL)
  (:NO-ERROR (&REST REST) (DECLARE (IGNORE REST)) NIL))
(HANDLER-CASE (PROGN (MAKUNBOUND '(NIL)))
  (TYPE-ERROR NIL T)
  (ERROR NIL NIL)
  (:NO-ERROR (&REST REST) (DECLARE (IGNORE REST)) NIL))

(HANDLER-CASE (PROGN (SET "not-a-symbol" 1))
  (TYPE-ERROR NIL T)
  (ERROR NIL NIL)
  (:NO-ERROR (&REST REST) (DECLARE (IGNORE REST)) NIL))
(HANDLER-CASE (PROGN (SET #\a 0))
  (TYPE-ERROR NIL T)
  (ERROR NIL NIL)
  (:NO-ERROR (&REST REST) (DECLARE (IGNORE REST)) NIL))
(HANDLER-CASE (PROGN (SET '(NIL) 2))
  (TYPE-ERROR NIL T)
  (ERROR NIL NIL)
  (:NO-ERROR (&REST REST) (DECLARE (IGNORE REST)) NIL))
