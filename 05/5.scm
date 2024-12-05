(define l (split (C string=? "") (force-ll (lines (open-input-file "input")))))

(define rules (map (λ (v) (map string->number ((string->regex "c/\\|/") v))) (car l)))
(define vs (map (λ (v) (map string->number ((string->regex "c/,/") v))) (cadr l)))

(define (ins-before l v v-before)
  (let loop ((l l) (acc #n))
    (cond
     ((null? l) acc)
     ((eq? (car l) v-before) (append acc `(,v) l))
     (else
      (loop (cdr l) (append acc `(,(car l))))))))

(define (rules-of lst full-lst)
  (filter
   (λ (v) (and (= (car v) (car lst))
               (has? full-lst (cadr v))))
   rules))

(define (rule-ok? r rest)
  (or (eq? #f rest) (has? rest (cadr r))))

(define (list-ok? l)
  (let loop ((rest l))
    (if (null? rest)
        #t
        (let ((cur-rules (rules-of rest l)))
          (if (all (C rule-ok? rest) cur-rules)
              (loop (cdr rest))
              #f)))))

(define (middle-of l)
  (lref l (floor (/ (len l) 2))))

(define ls (zip cons (map list-ok? vs) vs))
(define bad (map cdr (filter (B not car) ls)))

(define (fix l)
  (let walk ((l l) (r rules))
    (cond
     ((null? r) l)
     ((rule-ok? (car r) (memq (caar r) l)) (walk l (cdr r)))
     ((and (has? l (cadar r)) (has? l (caar r)))
      (let ((R (cons (caar r) (cadar r))))
        (walk
         (ins-before
          (filter (λ (x) (not (= (car R) x))) l)
          (car R)
          (cdr R))
         (cdr r))))
     (else
      (walk l (cdr r))))))

;; apply fixes until (fix x) = x
(define (fix-until l)
  (let loop ((l l))
    (let ((fixed (fix l)))
      (if (equal? l fixed)
          fixed
          (loop fixed)))))

(format stdout "p1: ~a~%" (sum (map (B middle-of cdr) (filter car ls))))
(format stdout "p2: ~a~%" (sum (map middle-of (map fix-until bad))))
