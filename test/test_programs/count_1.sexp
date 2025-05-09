(program
  (= GRID_SIZE 100)
    
  (object Button (: color String) (Cell 0 0 color))
  (object Blob (list (Cell 0 0 "blue")))
  
  (: blobs (List Blob))
  (= blobs (initnext (list (Blob (Position 50 50))) (prev blobs)))
  
  (: xVel Number)
  (= xVel (initnext 0 (prev xVel)))
  
  (: yVel Number)
  (= yVel (initnext 0 (prev yVel)))
  
  (: xActive Bool)
  (= xActive (initnext true (prev xActive)))
  
  (on ((clicked)) (= xActive (! xActive)))
  
  (on (& (& ((left)) xActive) (> (prev xVel) -1)) (= xVel (- (prev xVel) 1)))
  (on (& (& ((right)) xActive) (< (prev xVel) 1)) (= xVel (+ (prev xVel) 1)))
  
  (on (& (& ((up)) (! xActive)) (> (prev yVel) -1)) (= yVel (- (prev yVel) 1)))
  (on (& (& ((down)) (! xActive)) (> (prev yVel) 1)) (= yVel (+ (prev yVel) 1)))
  
  (on true (= blobs (updateObj blobs (--> obj (move obj (Position (sign (prev xVel)) (sign (prev yVel))))))))
)
