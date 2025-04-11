(program
  (= GRID_SIZE 3)
  (object Twiddle (: color String) (Cell 0 0 color))
  
  (: possiblePos (List Position))
  (= possiblePos (rect (Position 0 0) (Position GRID_SIZE GRID_SIZE)))

  (= twiddlePos (fn () (let 
    (= pos (head (uniformChoice possiblePos 1)))
    (= possiblePos (removeObj possiblePos pos))
    pos))
   )
  (: twiddle1 Twiddle)
  (= twiddle1 (initnext (Twiddle "red" ((twiddlePos))) (prev twiddle1)))

  (: twiddle2 Twiddle)
  (= twiddle2 (initnext (Twiddle "green" ((twiddlePos))) (prev twiddle2)))

  (: twiddle3 Twiddle)
  (= twiddle3 (initnext (Twiddle "blue" ((twiddlePos))) (prev twiddle3)))

  (: twiddle4 Twiddle)
  (= twiddle4 (initnext (Twiddle "yellow" ((twiddlePos))) (prev twiddle4)))

  (: twiddle5 Twiddle)
  (= twiddle5 (initnext (Twiddle "purple" ((twiddlePos))) (prev twiddle5)))

  (: twiddle6 Twiddle)
  (= twiddle6 (initnext (Twiddle "orange" ((twiddlePos))) (prev twiddle6)))

  (: twiddle7 Twiddle)
  (= twiddle7 (initnext (Twiddle "pink" ((twiddlePos))) (prev twiddle7)))

  (: twiddle8 Twiddle)
  (= twiddle8 (initnext (Twiddle "brown" ((twiddlePos))) (prev twiddle8)))

  (: twiddle9 Twiddle)
  (= twiddle9 (initnext (Twiddle "gray" ((twiddlePos))) (prev twiddle9)))

  (= rot_clockwise (fn (twiddle1_ twiddle2_ twiddle3_ twiddle4_)
        (let    
            (= twiddle1_ (moveRight twiddle1_))
            (= twiddle2_ (moveDown twiddle2_))
            (= twiddle3_ (moveLeft twiddle3_))
            (= twiddle4_ (moveUp twiddle4_))
            (list twiddle1_ twiddle2_ twiddle3_ twiddle4_)
   )))

  (= rot_counterclockwise (fn (twiddle1_ twiddle2_ twiddle3_ twiddle4_)
        (let    
            (= twiddle1_ (moveLeft twiddle1_))
            (= twiddle2_ (moveUp twiddle2_))
            (= twiddle3_ (moveRight twiddle3_))
            (= twiddle4_ (moveDown twiddle4_))
            (list twiddle1_ twiddle2_ twiddle3_ twiddle4_)
   )))

  (: currentset Number)
  (= currentset (initnext 0 (prev currentset)))

  (on clicked
    (= currentset (
        if (in (Position (.. click x) (.. click y)) (list (Position 0 0) (Position 0 1) (Position 1 1)))
        then 0
        else (if (in (Position (.. click x) (.. click y)) (list (Position 1 0) (Position 2 0)))
        then 1
        else (if (in (Position (.. click x) (.. click y)) (list (Position 0 2) (Position 1 2)))
        then 2
        else 3
        ))
    )))


)