;;;; converter.lisp --- JSON generator from Common Lisp codes 
;;;
;;; This code has been placed in the Public Domain.  All warranties
;;; are disclaimed.
;;;
;;; This file is composed of a collection of JSON file generator.
;;; Kai can be used with a variety of backends.
;;; Here we use JSON and provide a common platform for a variety of
;;; backends.

(in-package :cl-user)
(defpackage #:kai.interface
  (:use :cl)
  (:import-from :kai.converter
                :check-file-exist
                :data-to-json
                :style-to-json
                :make-kai-cache)
  (:import-from :kai.plotly.generate
                :download-plotlyjs
                :save-html
                :save-js)
  (:import-from :kai.plotly.launch
                :open-browser)
  (:export :*state*
           :*style*
           :reset!
           :scatter
           :style
           :show))
(in-package #:kai.interface)



;;;; Input style converter
;;;
;;; When getting input data, we accept variable length args.
;;; We cannot realize to accept one or two args with some options by
;;; standard style, so we papare such a function to convert args.

(defun convert-data (&rest data)
  (let ((x (car data))
        (y (cadr data)))
    (if (or (consp x)        ; check first data
            (vectorp x))
        (if (or (consp y)    ; check second data  
                (vectorp y))
            data
            `((quote ,(loop for i below (length x) collect i))
              (quote ,x)
              ,@(cdr data)))
        (error "Invalid input"))))


;;;; State
;;;
;;; To make it able to plot multiple graph, we have a state as list.

(defparameter *state* '())

(defparameter *style* "{}")

(defun reset! ()
  (setf *state* '())
  (setf *style* "{}"))


;;;; Scatter and Line
;;;
;;; This covers scatter and line plotting and their options.

;; 2D scatter
(defun scatter (&rest data)
  (push (eval `(-scatter ,@(apply #'convert-data data)))
        *state*))

(defun -scatter (data0
                 data1
                 &key
                   (mode "markers")
                   (name "")
                   (text '())
                   (error-x '())
                   (error-y '())
                   (fill "")
                   (fillcolor "")
                   (line '())
                   (marker '()))
  (data-to-json :data0 data0
                   :data1 data1
                   :type "scatter"
                   :mode mode
                   :name name
                   :text text
                   :error-x error-x
                   :error-y error-y
                   :fill fill
                   :fillcolor fillcolor
                   :line line
                   :marker marker))

;; Bar plot
(defun bar (&rest data)
  (push (eval `(-bar ,@(apply #'convert-data data)))
        *state*))

(defun -bar (data0
                 data1
                 &key
                   (name "")
                   (text '())
                   (error-x '())
                   (error-y '())
                   (fill "")
                   (fillcolor "")
                   (marker '()))
  (data-to-json :data0 data0
                   :data1 data1
                   :type "bar"
                   :mode ""
                   :name name
                   :text text
                   :error-x error-x
                   :error-y error-y
                   :fill fill
                   :fillcolor fillcolor
                   :line '()
                   :marker marker))


;;;; Layout
;;;
;;; To attach title or axis options to the graph.

(defun style (&key
                 (title "Scatter Plot"))
  (setf *style* (style-to-json :title title)))


;;;; Plot
;;;
;;; Launch viewer and draw traces and styles.

(defun show ()
  (make-kai-cache)
  (if (not (check-file-exist "kai.html"))
      (save-html))
  (if (not (check-file-exist "plotly-latest.min.js"))
      (download-plotlyjs))
  (save-js *state* *style*)
  (open-browser)
  (reset!))
