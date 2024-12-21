(import
 (owl metric))

(define ll (lines (open-input-file "input")))

(define Map
  '((7 8 9)
    (4 5 6)
    (1 2 3)
    (#f 0 A)))

(define Map2
  '((#f ^ A)
    (<  v >)))

(define (findn thing l)
  (let walk ((acc 0))
    (cond
     ((>= acc (len l)) #f)
     ((eq? thing (lref l acc)) acc)
     (else
      (walk (+ acc 1))))))

;; thing l -> (x . y)
(define (find-thing thing m)
  (fold
   (λ (y l)
     (if (pair? y)
         y
         (let ((x (findn thing l)))
           (if x
               (cons x y)
               (+ y 1)))))
   0 m))

(define dirs  '((1 . 0) (0 . -1) (-1 . 0) (0 . 1)))
(define dirs* '(> ^ < v))

(define (+cons a b)
  (values
   (+ (car a) (car b))
   (+ (cdr a) (cdr b))))

(define (+was was dp)
  (append was (list (lref dirs* (modulo dp 4)))))

(define (search m was x y dp target)
  (if (and (>= x 0) (< x (len (car m))) (>= y 0) (< y (len m)))
      (let ((p (lref (lref m y) x)))
        (cond
         ((eq? p #f) #n)
         ((eq? p '*) #n)
         ((eq? p target) `((,x ,y ,was)))
         (else
          (lets ((m (lset m y (lset (lref m y) x '*)))
                 (x1 y1 (+cons (lref dirs (modulo dp 4))       (cons x y)))
                 (x2 y2 (+cons (lref dirs (modulo (+ dp 1) 4)) (cons x y)))
                 (x3 y3 (+cons (lref dirs (modulo (+ dp 2) 4)) (cons x y)))
                 (x4 y4 (+cons (lref dirs (modulo (+ dp 3) 4)) (cons x y)))
                 (l1 (search m (+was was dp) x1 y1 dp target))
                 (l2 (search m (+was was (+ dp 1)) x2 y2 (+ dp 1) target))
                 (l3 (search m (+was was (+ dp 2)) x3 y3 (+ dp 2) target))
                 (l4 (search m (+was was (+ dp 3)) x4 y4 (+ dp 3) target)))
            (append l4 l3 l2 l1)))))
      #n))

(define (lsort-dumb a b)
  (let ((l1 (len (lref a 2)))
        (l2 (len (lref b 2))))
    (< l1 l2)))

;; waht the pod
(define (make-lsort f depth)
  (if (> depth 1)
      lsort-dumb
      (letrec ((ls
                (λ (a b)
                  (let ((ls* (make-lsort f (+ depth 1))))
                    (ls*
                     (append '(0 0) (list (f Map2 (lref a 2) (find-thing 'A Map2) (+ depth 1))))
                     (append '(0 0) (list (f Map2 (lref b 2) (find-thing 'A Map2) (+ depth 1)))))))))
        ls)))

(define (find-comb map* btns start depth)
  (let* ((lsort (make-lsort find-comb depth))
         (sort (if (>= depth 1)
                   (λ (vs) (sort lsort-dumb vs))
                   (λ (vs) (sort lsort vs)))))
    (let loop ((btns btns) (acc #n) (x (car start)) (y (cdr start)))
      (if (null? btns)
          acc
          (let* ((sr (search map* #n x y 0 (car btns)))
                 (vs (map (λ (l) (lset l 2 (append acc (lref l 2)))) sr))
                 (opt (car (sort vs))))
            (loop (cdr btns) (append (lref opt 2) '(A)) (car opt) (cadr opt)))))))

(define (make-complexity-of n)
  (λ (s)
    (let* ((l (list
               (- (string-ref s 0) #\0)
               (- (string-ref s 1) #\0)
               (- (string-ref s 2) #\0)
               (string->symbol (string (string-ref s 3)))))
           (c1 (find-comb Map l (find-thing 'A Map) 0))
           (c2 (let loop ((prev c1) (i 0))
                 (if (= n i)
                     prev
                     (loop (find-comb
                            Map2
                            prev
                            (find-thing 'A Map2)
                            0)
                           (+ i 1)))))
           (c3 (find-comb Map2 c2 (find-thing 'A Map2) 0)))
      (* (len c3) (read s)))))

(define complexity-of1 (make-complexity-of 1))
;; (define complexity-of2 (make-complexity-of 25))

;; 196060 too high
;; 188192 too high
(format stdout "p1: ~a~%" (sum (force-ll (lmap complexity-of1 ll))))

;;; Commentary:
;; i think i've happened to get the correct result by sheer luck
;; if i change (append l4 .. l1) to (append l1 .. l4) the answer changes to a wrong one (??!?)
;; (it should be smart-sorted later in the code)
;;
;; also if i change one of the magic depth numbers in find-comb or make-lsort it also changes answers
;; it's probably to be expected, as it tries to optimize for further locations but hmmm
;; i'm not really sure
;;
;; anyways, merry christmas

;; (format "p2: ~a~%" (sum (force-ll (lmap complexity-of2 ll))))
