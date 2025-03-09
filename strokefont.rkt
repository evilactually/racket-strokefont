#lang racket 

(provide char->strokes)

(require 
    "glyph-data.rkt"
    ;racket/flonum
    ffi/vector
    control
    opengl)

(define font-offset -8)

; split up list into pairs
(define (list-split-pairs lst)
    (foldr (lambda (a result)
        (define head (car result)) ; head is last pair
        (if (>= (length head) 2) ; if reached 2
            (let ([new-head (cons a `())]) ; start new head
                (cons new-head (cons head (cdr result)))) ; add new head and put old head back
            (if (not (null? a))
                (let ([new-head (cons a head)]) ; else grow old head
                    (cons new-head (cdr result)))
                result)))
                
        (list null)
        lst))

(define R (bytes-ref #"R" 0))

; Returns list of strokes
(define (char->strokes scale char)
    (define index (- (char->integer char) 32)) ; convert to list index
    (define glyph-byte-pairs (list-split-pairs (bytes->list  (list-ref glyph-data index))))
    (define glyph-start-end-x (car glyph-byte-pairs)) ; first pair of bytes is glyph's width
    (define glyph-start-x (* (- (car glyph-start-end-x) R) scale))
    (define glyph-end-x (* (- (car (cdr glyph-start-end-x)) R) scale))
    (define glyph-width (- glyph-end-x glyph-start-x))
    (define glyph-stroke-data (cdr glyph-byte-pairs))
    (define (decode-xy xy)
        (match xy
            [(list x y) (cons (- (* (- x R) scale) glyph-start-x) (* (+ (- y R) font-offset) scale))]
            [_ #f])
        )

    ; unpack strokes into sub-lists
    (define strokes
        (foldr (lambda (a result)
            (define stroke (car result)) ; stroke is current stroke
            (match stroke
                [(cons (list 32 82) xs) ; end of stroke
                    (let ([new-stroke (cons a null)]) ; start new stroke
                        (cons new-stroke (cons xs (cdr result))))]
                [_ ; else grow old stroke
                    (let ([updated-stroke (cons a stroke)]) 
                        (cons updated-stroke (cdr result)))] ; return unchanged if null
                    ))
            (list null)
            glyph-stroke-data))
    ; decode coordinates
    (map 
        (lambda (xs)
            (map decode-xy xs))
        strokes))
