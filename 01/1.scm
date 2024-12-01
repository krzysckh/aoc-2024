(define ns (map (λ (x) (map string->number ((string->regex "c/ +/") x)))
                (force-ll (lines (open-input-file "input")))))
(define ls (sort < (map car ns)))
(define rs (sort < (map cadr ns)))

(print "p1: " (sum (map abs (zip - ls rs))))
(print "p2: " (sum (map (λ (x) (* (length (filter (C = x) rs)) x)) ls)))
