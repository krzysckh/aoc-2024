(import
 (prefix (owl parse) get-))

(define (xcdr v n)
  (if (= n 0)
      v
      (xcdr (cdr* v) (- n 1))))

(define (car** v)
  (let ((v (car* v)))
    (if (null? v)
        v
        (list v))))

(define (get-diag l)
  (let* ((rows (map (λ (v) (xcdr (lref l v) v)) (iota 0 1 (len l)))))
    (let loop ((rows rows) (acc #n))
      (if (null? (car* rows))
          acc
          (loop (map cdr* rows) (append acc (list (fold append #n (map car** rows)))))))))

(define vs         (map string->list (force-ll (lines (open-input-file "input")))))
(define vs-rev     (map reverse vs))
(define vs-rot     (map (λ (n) (map (C lref n) vs)) (iota 0 1 (len vs))))
(define vs-rot-rev (map reverse vs-rot))

(define Map (map (λ (l) (map (λ (x) (string->symbol (string x))) l)) vs))

(define diags*
  (append
   (get-diag vs)
   (get-diag vs-rev)
   (cdr (get-diag (reverse vs)))
   (cdr (get-diag (reverse vs-rev)))))

(define diags (append diags* (map reverse diags*)))

(define parser
  (get-parses
   ((vals (get-greedy-star
           (get-one-of
            (get-word "XMAS" 'xmas)
            get-byte))))
   vals))

(define (n-xmas s)
  (length (filter symbol? (get-parse parser (str-iter (list->string s)) #n))))

(define (boxes l)
  (let loop ((l l))
    (if (< (len (car* l)) 3)
        #n
        (append `((,(take (lref l 0) 3)
                   ,(take (lref l 1) 3)
                   ,(take (lref l 2) 3))) (loop (map cdr* l))))))

(define (middle-a? l) (eq? 'A (cadadr l)))
(define (mas? l)
  (and
   (or (and (eq? 'M (caar l))
            (eq? 'S (caddr (caddr l))))
       (and (eq? 'S (caar l))
            (eq? 'M (caddr (caddr l)))))
   (or (and (eq? 'M (caddar l))
            (eq? 'S (caaddr l)))
       (and (eq? 'S (caddar l))
            (eq? 'M (caaddr l))))))


(define ls (filter middle-a? (let loop ((m Map))
                               (if (< (len m) 3)
                                   #n
                                   (append (boxes (take m 3)) (loop (cdr m)))))))

(format stdout "p1: ~a~%" (fold + 0 (map n-xmas (append vs vs-rev vs-rot vs-rot-rev diags))))
(format stdout "p2: ~a~%" (len (filter mas? ls)))
