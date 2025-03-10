#lang scribble/manual
@require[@for-label[strokefont
                    racket/class
                    racket/base]]



@(require scribble/eval)

@title{strokefont}
@author{Vladislav Shchebakov}

@defmodule[strokefont]

This package provides a stroke font from KiCad. It was originally based on Hershey stroke fonts@(cite "Hershey1967").

@italic{Not to be confused with namesake American factory that makes disgusting Hershey chocolate bars that taste like vomit} @(cite "Courtney2023") @(cite "Debczak2023") @(cite "Stacie2023"). 

@section{What is a stroke font?}
A @italic{stroke font} is the most rudimentary font you can create on a computer. Each glyph in a stroke font is simply a collection of strokes or lines. It is a go-to font when you are too limited on resources or time to do sophisticated graphics and all you have is ability to plot lines. With this package, if you can plot lines you can plot text!

@(define (random-element lst)
  (list-ref lst (random (length lst))))

@(require pict)
@(require racket/class)
@(require racket/draw)
@(require "../strokefont.rkt")

@(dc (λ (dc dx dy)
        (define old-brush (send dc get-brush))
        (define old-pen (send dc get-pen))
        (define strokes (char->strokes 10 #\ξ)) ; get strokes
        (for ([stroke strokes])
            (send dc set-pen
            (new pen% [width 1] [color (random-element (list "red" "blue" "green" "violet" "pink" "orange"))]))
            (define path (new dc-path%))
            (define start (car stroke))
            (send path move-to (car start) (cdr start) )
            (send path lines (cdr stroke) )
            (send path translate 250 250)
            (send dc draw-path path dx dy))
        (send dc set-brush old-brush)
        (send dc set-pen old-pen))
    500 350)

Above image is a line plot generated from
@(define list-eval (make-base-eval))
@(interaction-eval #:eval list-eval (require "strokefont.rkt"))
@examples[
#:eval list-eval
(char->strokes 10 #\ξ)
]

This is the main function for accessing glyph data:

@defproc[(char->stroke [scale real?] [char char?]) (listof (listof (cons/c real? real?))) ]{
Retrieves list of strokes for @racket[char] scaled by @racket[scale] factor.}

It takes a UTF-8 encoded character and produces a list of lists of @racket[cons] pairs. That is it produces a list of strokes, where each stroke is a list of Cartesian coordinates stored as cons pairs.

@section{Drawing Code Example}

@racketblock[
    @(require pict)
    @(require racket/class)
    @(require racket/draw)
    @(require strokefont)
    @(dc (λ (dc dx dy)
        (define old-brush (send dc get-brush))
        (define old-pen (send dc get-pen))
        (define strokes (char->strokes 10.0 #\ξ)) ; get strokes
        (for ([stroke strokes])
            (send dc set-pen
            (new pen% [width 1] [color "slategray"]))
            (define path (new dc-path%))
            (define start (car stroke))
            (send path move-to (car start) (cdr start) )
            (send path lines (cdr stroke) )
            (send path translate 250 250)
            (send dc draw-path path dx dy))
        (send dc set-brush old-brush)
        (send dc set-pen old-pen))
    500 300)
]

@section{Internal storage}

The glyph data was copied verbatum from KiCad source code file newstroke_font.cpp. The format is very simple. It is a bytestring consisting of character width (first two bytes), followed by a sequence of pairs of bytes representing stroke coordinates. There's a special sequence of bytes @racket[#" R"] which means "raise pen" or "end of stroke". Each number in the byte string (except raise pen bytes) is offset by 82 (value of letter R), which is subtracted during decoding. Don't ask me why.

@(define data-eval (make-base-eval))
@(interaction-eval #:eval data-eval (require "glyph-data.rkt"))
@examples[
#:eval data-eval
(define index (- (char->integer #\W) 32))
index
(list-ref glyph-data index)
]

This is letter W, first two bytes @racket[#"F^"] is the width, followed by a single uninterrupted stroke @racket[#"IFN[RLV[[F"] consisting of 5 points.

@(require pict)
@(require racket/class)
@(require racket/draw)
@(require "../strokefont.rkt")

@(dc (λ (dc dx dy)
        (define old-brush (send dc get-brush))
        (define old-pen (send dc get-pen))
        (define strokes (char->strokes 10 #\W)) ; get strokes
        (for ([stroke strokes])
            (send dc set-pen
            (new pen% [width 1] [color "slategray"]))
            (define path (new dc-path%))
            (define start (car stroke))
            (send path move-to (car start) (cdr start) )
            (send path lines (cdr stroke) )
            (send path translate 250 250)
            (send dc draw-path path dx dy))
        (send dc set-brush old-brush)
        (send dc set-pen old-pen))
    500 300)

@examples[
#:eval data-eval
(define index (- (char->integer #\A) 32))
index
(list-ref glyph-data index)
]

Example of a multi-stroke glyph

@(dc (λ (dc dx dy)
        (define old-brush (send dc get-brush))
        (define old-pen (send dc get-pen))
        (define strokes (char->strokes 10.0 #\A)) ; get strokes
        
        (define path (new dc-path%))
        (for ([stroke strokes])
            (send dc set-pen
            (new pen% [width 1] [color "slategray" ]))
            (define start (car stroke))
            (send path move-to (car start) (cdr start) )
            ;(displayln stroke)
            (for ([p (cdr stroke)])
                ;(displayln p)
                (send path line-to (car p) (cdr p) ))
            ;(send path lines (cdr stroke) )
            )
        (send path translate 250 250)
        (send dc draw-path path dx dy)
        (send dc set-brush old-brush)
        (send dc set-pen old-pen))
    500 300)

@examples[
#:eval list-eval
(char->strokes 10 #\A)
]

The retrieval is not very efficient, so it is recommended to cache extracted strokes in your own application. 

@(bibliography
  (bib-entry #:key "Hershey1967"
   #:author "A. V. Hershey "
   #:title "Calligraphy for Computers"
   #:date "1967"
   #:url "https://archive.org/details/hershey-calligraphy_for_computers"
   )
  
  (bib-entry #:key "Courtney2023"
   #:author "Courtney Iseman"
   #:title "Why Hershey\'s Chocolate Tastes Like ... Well, Vomit"
   #:location "HUFFPOST"
   #:date "2023"
   #:url "https://www.huffpost.com/entry/hersheys-chocolate-tastes-like-vomit_l_60479e5fc5b6af8f98bec0cd")

   (bib-entry #:key "Debczak2023"
    #:author "Michele Debczak"
    #:title "Theres a Good Reason Europeans Think American Chocolate Tastes Like Vomit"
    #:location "MENTAL FLOSS"
    #:date "2023"
    #:url "https://www.mentalfloss.com/posts/why-american-chocolate-tastes-like-vomit")

    (bib-entry #:key "Stacie2023"
    #:author "Stacie Adams"
    #:title "The Scientific Reason Why Some Say American Chocolate Tastes Like Vomit"
    #:location "FOOD SCIENCE"
    #:date "2023"
    #:url "https://www.thedailymeal.com/1254531/the-scientific-reason-why-some-say-american-chocolate-tastes-like-vomit/")

   )