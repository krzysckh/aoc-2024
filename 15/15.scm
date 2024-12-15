(define (move->list m)
  (case m
    (#\> '(1  . 0))
    (#\< '(-1 . 0))
    (#\^ '(0  . -1))
    (#\v '(0  . 1))))

(define (hasv? l v)
  (any (C equal? v) l))

;;--- get input

(define in ((string->regex "c/\n\n/") (list->string (file->list "input"))))
(define moves (map move->list (string->list (fold string-append "" ((string->regex "c/\n/") (cadr in))))))

(define Map
  (map
   (λ (s) (map
           (λ (c) (case c
                    (#\. '_)
                    (else => (λ (_) (string->symbol (string c))))))
           (string->list s)))
   ((string->regex "c/\n/") (car in))))

(define (findn thing l)
  (let walk ((l l) (acc 0))
    (cond
     ((null? l) #f)
     ((eq? thing (car l)) acc)
     (else
      (walk (cdr l) (+ acc 1))))))

;;--- solve part 2

(define-values (px py)
  (let loop ((m Map) (y 0))
    (let ((x (findn '@ (car m))))
      (if x
          (values (* 2 x) y)
          (loop (cdr m) (+ y 1))))))

(define Map2
  (map
   (λ (l)
     (let ((blocks
            (let loop ((l l))
              (let ((b (findn 'L l)))
                (if b
                    (append (list b) (loop (lset (lset l b '_) (+ b 1) '_)))
                    '()))))
           (walls
            (let loop ((l l))
              (let ((b (findn (string->symbol "#") l)))
                (if b
                    (append (list b) (loop (lset l b '_)))
                    '())))))
       (list blocks walls)))
   (map
    (λ (l) (fold (λ (a b)
                   (case b
                     ('@ (append a '(_ _)))
                     ('O (append a '(L R)))
                     (else => (λ (b) (append a `(,b ,b))))))
                 #n
                 l))
    Map)))

;; ((y x1 x2) ...)
(define blocks
  (fold
   (λ (a b)
     (let ((l (car (lref Map2 b))))
       (append a (zip cons (make-list (len l) b) (fold (λ (a b) (append a `((,b ,(+ 1 b))))) #n l)))))
   #n
   (iota 0 1 (len Map2))))

;; ((y . x) ...)
(define walls
  (fold
   (λ (a b)
     (let ((l (cadr (lref Map2 b))))
       (append a (zip cons (make-list (len l) b) l))))
   #n
   (iota 0 1 (len Map2))))

(define (block-of x y blocks)
  (let ((b (car (filter (λ (b) (has? (cdr b) x)) (filter (λ (v) (equal? (car v) y)) blocks)))))
    (values (car b) (cadr b) (caddr b))))

(define (in-block? x y blocks)
  (any
   (λ (b) (has? (cdr* b) x))
   (filter (λ (v) (equal? (car v) y)) blocks)))

(define (in-wall? x y)
  (hasv? walls (cons y x)))

(define (maybe-move px py m blocks)
  (lets ((x y (values (+ px (car m)) (+ py (cdr m)))))
    (cond
     ((in-wall? x y) (values #f px py blocks)) ;; nope
     ((in-block? x y blocks)
      (lets ((y x1 x2 (block-of x y blocks))
             (_blocks blocks)
             (blocks-without (filter (λ (b) (not (equal? b (list y x1 x2)))) blocks))
             (ok1? _1 _2 blocks (maybe-move x1 y m blocks-without))
             (ok2? _1 _2 blocks (maybe-move x2 y m blocks))) ; test if both blocks can be pushed
        (if (and ok1? ok2?)
            (values #t x y (append blocks (list (list (+ y (cdr m)) (+ x1 (car m)) (+ x2 (car m))))))
            (values #f px py _blocks))))
     (else
      (values #t x y blocks)))))

;; final block positions
(define fin
  (let loop ((x px) (y py) (moves moves) (blocks blocks))
    (if (null? moves)
        blocks
        (lets ((ok? x y blocks (maybe-move x y (car moves) blocks)))
          (loop x y (cdr moves) blocks)))))

(format stdout "p2: ~a~%" (fold (λ (a b) (+ a (* (car b) 100) (cadr b))) 0 fin))
