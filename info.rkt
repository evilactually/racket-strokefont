#lang info
(define collection "strokefont")
(define deps '("base" "control"))
(define build-deps '("scribble-lib" "racket-doc" "rackunit-lib" "pict-lib" "draw-lib" "testing-util-lib" "rackunit-lib"))
(define scribblings '(("scribblings/strokefont.scrbl" ())))
(define pkg-desc "Simple to use Hershey stroke font")
(define version "0.1")
(define pkg-authors '(vlad.shcherbakov))
(define license '(Apache-2.0 OR MIT))
