(import (owl variable))

(define Map
  (map (λ (s) (map
               (λ (c)
                 (case c
                   (#\. '_)
                   (#\# '*)
                   (else (string->symbol (string c)))))
               (string->list s)))
       (force-ll
        (lines (open-input-file "input")))))

(define (findn thing l)
  (let walk ((l l) (acc 0))
    (cond
     ((null? l) #f)
     ((eq? thing (car l)) acc)
     (else
      (walk (cdr l) (+ acc 1))))))

;; thing l -> (x . y)
(define (find-thing thing l)
  (fold
   (λ (y l)
     (if (pair? y)
         y
         (let ((x (findn thing l)))
           (if x
               (cons x y)
               (+ y 1)))))
   0 Map))

(define S (find-thing 'S Map))
(define E (find-thing 'E Map))

(define dirs
  '((1 . 0) (0 . -1) (-1 . 0) (0 . 1)))

(define (+cons a b)
  (values
   (+ (car a) (car b))
   (+ (cdr a) (cdr b))))

(define (search m was x y dp cost)
  (let ((p (lref (lref m y) x)))
    (case p
      ('* (values m #n))
      ('E (values m `((,cost . ,was))))
      (else
       (if (or (not (number? p)) (>= p cost))
           (lets ((m (lset m y (lset (lref m y) x (+ cost 1001)))) ; huh
                  (was (append was `((,x . ,y))))
                  (x1 y1 (+cons (lref dirs (modulo dp 4))       (cons x y)))
                  (x2 y2 (+cons (lref dirs (modulo (+ dp 1) 4)) (cons x y)))
                  (x3 y3 (+cons (lref dirs (modulo (+ dp 3) 4)) (cons x y)))
                  (m l1 (search m was x1 y1 dp (+ cost 1)))
                  (m l2 (search m was x2 y2 (+ dp 1) (+ cost 1001)))
                  (m l3 (search m was x3 y3 (+ dp 3) (+ cost 1001))))
             (let ((l (append l1 l2 l3)))
               (values m (take (reverse l) 1000))))
           (values m #n))))))

(print "this will take a while, go eat lunch or something...")

(define-values (_ vs)
  (search Map #n (car S) (cdr S) 0 0))

(define lowest (caar (sort (λ (a b) (< (car a) (car b))) vs)))

(print "p1: " lowest)

;; 466 too low
;; 1761 too high
(print
 "p2: "
 (len
  (fold
   (λ (a b)
     (if (has? a b)
         a
         (append a (list b))))
   #n
   (fold append #n (filter (λ (v) (= (car v) lowest)) vs)))))
