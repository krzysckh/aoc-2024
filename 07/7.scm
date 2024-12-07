(import (owl regex))

;; "literally just brute force the combinations"

(define ls (map
            (λ (l) (map string->number ((string->regex "c/:? /") l)))
            (force-ll (lines (open-input-file "input")))))

(define (options l max)
  (if (null? (cdr* l))
      (if (= (car l) max)
          (list (car l))
          '())
      (let* ((o+ (+ (car l) (cadr l)))
             (o* (* (car l) (cadr l)))
             (l+ (if (> o+ max)
                     '()
                     (options (append (list o+) (cddr l)) max)))
             (l* (if (> o* max)
                     '()
                     (options (append (list o*) (cddr l)) max))))
        (append l+ l*))))

(define (options* l max)
  (if (null? (cdr* l))
      (if (= (car l) max)
          (list (car l))
          '())
      (let* ((o+ (+ (car l) (cadr l)))
             (o* (* (car l) (cadr l)))
             (o. (string->number (str (car l) (cadr l))))
             (l+ (if (> o+ max)
                     '()
                     (options* (append (list o+) (cddr l)) max)))
             (l* (if (> o* max)
                     '()
                     (options* (append (list o*) (cddr l)) max)))
             (l. (if (> o. max)
                     '()
                     (options* (append (list o.) (cddr l)) max))))
        (append l+ l* l.))))

(define (fold-res f)
  (fold
   (λ (a b) (+ a (car b)))
   0
   (filter (B not null?) (map (λ (l) (f (cdr l) (car l))) ls))))

(format stdout "p1: ~a~%" (fold-res options))
(format stdout "p2: ~a~%" (fold-res options*))
