;;;; launch.lisp --- File opener
;;;
;;; This code has been placed in the Public Domain.  All warranties
;;; are disclaimed.
;;;
;;; This file handles opening js files with system commands.

(in-package :cl-user)

(defpackage :kai.plotly.launch
  (:use :cl)
  (:import-from :kai.util
                :check-file-exist)
  (:export :open-browser))
(in-package :kai.plotly.launch)



;;;; Open browser
;;;
;;; When launching js file in the browser, we use system command
;;; to open browser.
(defun open-browser ()
  (let ((path-to-html (check-file-exist "plotly" "kai.html")))
    (uiop:run-program #+(or win32 mswindows windows)
                      (format nil "explorer file:///~A" path-to-html)
                      #+(or macos darwin)
                      (format nil "open ~A" path-to-html)
                      #-(or win32 mswindows macos darwin windows)
                      (format nil "xdg-open ~A" path-to-html))))
