(import
 (prefix (owl sys) sys/))

(define (main p1 banana-map)
  (format stdout "p1: ~a~%" p1)
  (format stdout "p2: ~a~%" (ff-fold (λ (o k v) (if (> v o) v o)) 0 banana-map))
  (halt 0))

;; me when i cheat :3
(when (sys/file? "state.fasl")
  (let* ((l (fasl-load "state.fasl" 'bad)))
    (main (car l) (cadr l))))

(define in
  (force-ll (lmap string->number (lines (open-input-file "input")))))

(define (prune x)
  (modulo x (<< 1 24)))

(define (rand* rs)
  (let* ((rs (prune (bxor (* rs 64) rs)))
         (rs (prune (bxor (floor (/ rs 32)) rs))))
    (prune (bxor (* rs 2048) rs))))

(define (p1)
  (let loop ((sum 0))
    (lets ((who msg (next-mail)))
      (tuple-case msg
        ((add! x)
         (print "add " x)
         (loop (+ sum x)))
        ((get)
         (mail who sum)
         (loop sum))))))

(thread 'p1 (p1))

;; ff's test for equality with eq?, so a key has to be an interned symbol
(define (fuck x)
  (string->symbol (str* x)))

(define banana-map
  (let loop ((in in) (ff empty))
    (if (null? in)
        ff
        (loop
         (cdr in)
         (let walk ((rs (car in)) (n 0) (ff ff) (log `((,(modulo (car in) 10) . #f))) (skip empty))
           (if (= n 2000)
               (begin
                 (mail 'p1 (tuple 'add! rs))
                 ff)
               (let* ((rs (rand* rs))
                      (b (modulo rs 10))
                      (v (- b (car (last log 'oops))))
                      (log (if (= (len log) 4)
                               (append (cdr log) `((,b . ,v)))
                               (append log       `((,b . ,v)))))
                      (k (fuck (map cdr log)))
                      (ff (if (and (= (len log) 4) (get skip k #t))
                              (put ff k (+ (get ff k 0) b))
                              ff)))
                 (walk rs (+ n 1) ff log (put skip k #f)))))))))

(let ((l (list (interact 'p1 (tuple 'get)) banana-map)))
  (fasl-save l "state.fasl")
  (main (car l) (cadr l)))
