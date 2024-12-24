(define in ((string->regex "c/\n\n/") (list->string (file->list "input"))))

(define z? (B (string->regex "m/^z/") symbol->string))
(define y? (B (string->regex "m/^y/") symbol->string))
(define x? (B (string->regex "m/^x/") symbol->string))

(define base-env
  (fold
   (λ (a b)
     (let ((l ((string->regex "c/: /") b)))
       (put a (string->symbol (car l)) (string->number (cadr l)))))
   empty
   ((string->regex "c/\n/") (car in))))

(define ops
  (map
   (λ (s)
     (let ((l ((string->regex "c/ /") s)))
       (list
        (string->symbol (lref l 0))
        (string->symbol (lref l 1))
        (string->symbol (lref l 2))
        (string->symbol (lref l 4)))))
   ((string->regex "c/\n/") (cadr in))))

(define (try-op env a op b)
  (let* ((a (get env a #f))
         (b (get env b #f))
         (f (case op
              ('OR  bior)
              ('XOR bxor)
              ('AND band)
              (else => (λ (s) (error "oops " s))))))
    (if (and a b)
        (f a b)
        #f)))

(define (sum-bits l)
  (fold (λ (a b) (bior (<< a 1) b)) 0 l))

(define (bits-of pred env)
  (map
   cdr
   (sort
    (λ (a b) (string-ci>? (symbol->string (car a)) (symbol->string (car b))))
    (filter (B pred car) (ff->list env)))))

(define (solve env ops cont fail)
  (let loop ((env env) (ops ops) (nlast 0) (nhist 0))
    (when (> nhist (len ops))
      (fail "unsolvable"))
    (if (null? ops)
        (cont (bits-of z? env))
        (let* ((o (car ops))
               (v (try-op env (car o) (cadr o) (caddr o))))
          (if v
              (loop (put env (lref o 3) v) (cdr ops) 0 0)
              (loop env (append (cdr ops) (list o))
                    (len ops)
                    (if (= nlast (len ops)) (+ nhist 1) 0)))))))

(define sumb (call/cc (λ (c) (solve base-env ops c (λ (s) (error "fail: " s))))))

(format stdout "p1: ~a~%" (sum-bits sumb))

;; nope not today

;; (define n-bits
;;   (/ (len (ff->list base-env)) 2))

;; (define sum-wanted
;;   (+ (sum-bits (bits-of x? base-env))
;;      (sum-bits (bits-of y? base-env))))

;; (define wanted-bits
;;   (reverse
;;    (let loop ((rest sum-wanted))
;;      (if (= rest 0)
;;          #n
;;          (append (list (band rest 1)) (loop (>> rest 1)))))))

;; (define (get-bad-bits bad)
;;   (filter
;;    (λ (n)
;;      (let ((a (lref bad n))
;;            (b (lref wanted-bits n)))
;;        (not (= a b))))
;;    (iota 0 1 (len wanted-bits))))

;; (define (get-bad-bit-names bad-bits)
;;   (map
;;    (λ (n) (string->symbol (str "z" (if (< n 10) "0" "") n)))
;;    bad-bits))

;; (define (cossa sym l)
;;   (cond
;;    ((null? l) #f)
;;    ((equal? (last (car l) 'oops) sym) (car l))
;;    (else
;;     (cossa sym (cdr l)))))

;; (define (uniq l)
;;   (fold (λ (a b) (if (has? a b) a (append a (list b)))) #n l))

;; (define (find-shit-nodes from)
;;   (if (or (x? from) (y? from))
;;       #n
;;       (let ((v (cossa from ops)))
;;         (append
;;          (list v)
;;          (find-shit-nodes (car v))
;;          (find-shit-nodes (caddr v))))))

;; (define shit-nodes
;;   (uniq (fold append #n (map find-shit-nodes (get-bad-bit-names (get-bad-bits sumb))))))

;; (define (swap ops a b)
;;   (let ((ops (filter (λ (x)
;;                        (and
;;                         (not (eq? (lref x 3) (lref a 3)))
;;                         (not (eq? (lref x 3) (lref b 3)))))
;;                        ops)))
;;     (append ops (list (lset a 3 (lref b 3)) (lset b 3 (lref a 3))))))

;; (define bad (get-bad-bit-names (get-bad-bits (call/cc (λ (c) (solve base-env ops2 c K))))))
;; (print "bad bits: " bad)

;; (map print (reverse (find-shit-nodes (car bad))))

;; (define (n-wrong ops)
;;   (let ((res (call/cc (λ (fail) (solve base-env ops get-bad-bits fail)))))
;;     (if (string? res)
;;         (<< 1 32)
;;         (len res))))
