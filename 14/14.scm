;; this is just a scheme excercise for me
;; for full part 1/part 2 see perl solution and README

(import
 (prefix (owl parse) get-))

(define in (force-ll (lines (open-input-file "input"))))

(define get-digit
  (get-byte-if
   (λ (x)
     (or
      (= x #\-)
      (and
       (<= #\0 x)
       (<= x #\9))))))

(define (chars->num chars)
  (lets ((chars v (if (= (car chars) #\-)
                      (values (cdr chars) -1)
                      (values chars 1))))
    (* v (fold (λ (n c) (+ (* n 10) (- c #\0))) 0 chars))))

(define parser
  (get-parses
   ((_ (get-word "p=" '_))
    (px (get-greedy-plus get-digit))
    (_ (get-byte-if (C = #\,)))
    (py (get-greedy-plus get-digit))
    (_ (get-word " v=" '_))
    (gx (get-greedy-plus get-digit))
    (_ (get-byte-if (C = #\,)))
    (gy (get-greedy-plus get-digit)))
   (list (chars->num px) (chars->num py) (chars->num gx) (chars->num gy))))

(define (parse s)
  (get-parse
   parser
   (str-iter s)
   'shit))

(define robots (map parse in))

(define mx 101)
(define my 103)

(define (positions-on n)
  (map (λ (r)
         (cons
          (modulo (+ (car r) (* (caddr r) n)) mx)
          (modulo (+ (cadr r) (* (cadddr r) n)) my)))
       robots))

(define qvs
  (fold
   (λ (a pos)
     (cond
      ((= (car pos) (/ (- mx 1) 2)) a)
      ((= (cdr pos) (/ (- my 1) 2)) a)
      ((< (car pos) (/ mx 2))
       (if (< (cdr pos) (/ my 2))
           (lset a 1 (+ (lref a 1) 1))
           (lset a 2 (+ (lref a 2) 1))))
      (else
       (if (< (cdr pos) (/ my 2))
           (lset a 0 (+ (lref a 0) 1))
           (lset a 3 (+ (lref a 3) 1))))))
   '(0 0 0 0)
   (positions-on 100)))

(print "p1: " (fold * 1 qvs))
