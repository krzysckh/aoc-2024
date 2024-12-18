(define (l->n l)
  (string->number (cadr ((string->regex "c/: /") l))))

(define ls (force-ll (lines (open-input-file "input"))))
(define code (map string->number ((string->regex "c/,/") (cadr ((string->regex "c/: /") (lref ls 4))))))

(define (n->combo n A B C)
  (case n
    ((0 1 2 3) n)
    (4 A)
    (5 B)
    (6 C)
    (else
     (error "elo" "pozdro"))))

(define (vm code A B C fin)
  (let loop ((ip 0) (A A) (B B) (C C) (out #n))
    (when (>= ip (len code))
      (fin out))
    (let ((v (lref code ip))
          (o (lref code (+ ip 1))))
      (case v
        (0 (loop (+ ip 2) (truncate (/ A (expt 2 (n->combo o A B C)))) B C out))
        (1 (loop (+ ip 2) A (bxor B o) C out))
        (2 (loop (+ ip 2) A (modulo (n->combo o A B C) 8) C out))
        (3 (if (= A 0)
               (loop (+ ip 2) A B C out)
               (loop o A B C out)))
        (4 (loop (+ ip 2) A (bxor B C) C out))
        (5 (loop (+ ip 2) A B C (append out (list (modulo (n->combo o A B C) 8)))))
        (6 (loop (+ ip 2) A (truncate (/ A (expt 2 (n->combo o A B C)))) C out))
        (7 (loop (+ ip 2) A B (truncate (/ A (expt 2 (n->combo o A B C)))) out))
        (else
         (error "erm" "what the pod"))))))

(define-values (A B C)
  (values (l->n (car ls)) (l->n (cadr ls)) (l->n (caddr ls))))

(let ((vs (call/cc (λ (c) (vm code A B C c)))))
  (format stdout
          "p1: ~a~%"
          (fold
           (λ (a b) (string-append a "," (str b)))
           (str (car vs))
           (cdr vs))))

(define (ncdr l n)
  (if (= n 0)
      l
      (ncdr (cdr l) (- n 1))))

;; uhhh
(format
 stdout
 "p2: ~a~%"
 (call/cc
  (λ (fin)
    (let loop ((i 0) (A 0))
      (if (= i 16)
          (fin A)
          (call/cc
           (λ (c)
             (for-each
              (λ (x)
                (let* ((A (+ (* A 8) x))
                       (res (call/cc (λ (f) (vm code A B C f)))))
                  (when (equal? res (ncdr code (- (len code) 0 i 1)))
                    (if-lets ((r (loop (+ i 1) A)))
                      (c A))))) ; fucked up
              (iota 0 1 8))
             #f)))))))
