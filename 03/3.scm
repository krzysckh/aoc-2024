(import
 (prefix (owl parse) get-))

(define (chars->num chars)
  (fold (λ (n c) (+ (* n 10) (- c #\0))) 0 chars))

(define get-digit
  (get-byte-if
   (λ (x)
     (and
      (<= #\0 x)
      (<= x #\9)))))

(define get-mul
  (get-parses
   ((_ (get-word "mul(" 'mul))
    (a (get-greedy-plus get-digit))
    (_ (get-byte-if (C = #\,)))
    (b (get-greedy-plus get-digit))
    (_ (get-byte-if (C = #\)))))
   (cons 'value (* (chars->num a) (chars->num b)))))

(define get-do
  (get-parses
   ((_ (get-word "do()" 'do)))
   (list 'do)))

(define get-dont
  (get-parses
   ((_ (get-word "don't()" 'dont)))
   (list 'dont)))

(define parser
  (get-parses
   ((vals (get-greedy-plus
           (get-one-of
            get-mul
            get-dont
            get-do
            get-byte))))
   vals))

(define elems
  (get-parse
   parser
   (str-iter (list->string (file->list "input")))
   'err))

(define fs (filter pair? elems))

(print "p1: " (fold (λ (a b) (+ a (cdr b)))
                    0
                    (filter (λ (x) (eq? 'value (car x))) fs)))

(print "p2: " (let loop ((l fs) (sum 0) (state 'do))
                (cond
                 ((null? l) sum)
                 ((eq? (caar l) 'value)
                  (if (eq? state 'do)
                      (loop (cdr l) (+ sum (cdar l)) state)
                      (loop (cdr l) sum state)))
                 ((eq? (caar l) 'do)
                  (loop (cdr l) sum 'do))
                 ((eq? (caar l) 'dont)
                  (loop (cdr l) sum 'dont)))))
