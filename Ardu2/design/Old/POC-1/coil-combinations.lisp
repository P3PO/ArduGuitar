;;; coil-combination rules and results
;;;

;;; syntax:
;;; expression: (operator elem elem ... elem)
;;; operator: p | s
;;; elem: atom | expression
;;; atom: coil-1 | coil-2 | coil-3 | coil-4
;;; reduction rules
;;; (operator atom) = atom 
;;; (op atom-1 atom-2) = (op atom-2 atom-1)
;;; (op-x atom-1) = (op-y atom-1)
;;; (op-x (op-x elem-1) elem-2) => (op-x elem-1 elem-2)
;;; for x != y: (op-y (op-x elem) elem) cannot reduce
#|
1 2 3
(p 1) = 1 *
(p 2) = 2 *
(p 3) = 3 *
(s 1) = 1 dup
(s 2) = 2 dup
(s 3) = 3 dup
(p 1 2) *
(p 1 3) *
(s 1 2) *
(s 1 3) *
(p 2 3) *
(s 2 3) *
(p 1 (p 2 3)) = (p 1 2 3) *
(p 1 (s 2 3)) *
(s 1 (p 2 3)) *
(s 1 (s 2 3)) = (s 1 2 3) *
(p 2 (p 1 3)) = (p 1 2 3) dup
(p 2 (s 1 3)) *
(s 2 (p 1 3)) *
(s 2 (s 1 3)) = (s 1 2 3) dup
(p 3 (p 1 2)) = (p 1 2 3) dup
(p 3 (s 1 2)) * 
(s 3 (p 1 2)) *

|#