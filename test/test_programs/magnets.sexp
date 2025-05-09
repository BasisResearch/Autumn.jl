(program
  (= GRID_SIZE 16)
  
  (object Magnet (: color String) (list (Cell 0 0 color) (Cell 0 1 color)))
  
  (: fixedMagnet Magnet)
  (= fixedMagnet (initnext (Magnet "red" (Position 7 7)) (prev fixedMagnet)))
  
  (: mobileMagnet Magnet)
  (= mobileMagnet (initnext (Magnet "blue" (Position 4 7)) (prev mobileMagnet)))
  
  (on left (= mobileMagnet (moveNoCollision (prev "mobileMagnet") -1 0)))
  (on right (= mobileMagnet (moveNoCollision (prev "mobileMagnet") 1 0)))
  (on up (= mobileMagnet (moveNoCollision (prev "mobileMagnet") 0 -1)))
  (on down (= mobileMagnet (moveNoCollision (prev "mobileMagnet") 0 1)))
  (on (adjacentElem (posPole mobileMagnet) (posPole fixedMagnet) 1) (= mobileMagnet (prev "mobileMagnet")))
  (on (adjacentElem (negPole mobileMagnet) (negPole fixedMagnet) 1) (= mobileMagnet (prev "mobileMagnet")))
  (on (in (deltaElem (posPole mobileMagnet) (negPole fixedMagnet)) attractVectors) (
    let
    (= mPos (posPole mobileMagnet))
    (= fNeg (negPole fixedMagnet))
    (= dvec (deltaElem mPos fNeg))
    (= mobileMagnet (move mobileMagnet (unitVectorSinglePos dvec))))
  )
  (on (in (deltaElem (negPole mobileMagnet) (posPole fixedMagnet)) attractVectors) (
    let
    (print "Here2")
    (= mobileMagnet (move mobileMagnet (unitVectorSinglePos (deltaElem (negPole mobileMagnet) (posPole fixedMagnet))))))
  )
    
  (= posPole (--> (magnet) (head (renderValue magnet))))  
  (= negPole (--> (magnet) (tail (renderValue magnet))))  
  
  (= attractVectors (list (Position 0 2) (Position 2 0) (Position -2 0) (Position 0 -2)))
)
