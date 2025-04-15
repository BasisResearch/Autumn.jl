(program
  (= GRID_SIZE 3)
  (object Twiddle (: color String) (Cell 0 0 color))
  
  (: possiblePos (List Position))
  (= possiblePos (rect (Position 0 0) (Position GRID_SIZE GRID_SIZE)))

  (= twiddlePos (fn () (let 
    (= pos (head (uniformChoice possiblePos 1)))
    (print pos)
    (= possiblePos (removeObj possiblePos pos))
    pos))
   )
  (: twiddles (List Twiddle))
  (= twiddles (initnext (list (Twiddle "red" ((twiddlePos)))
  (Twiddle "green" ((twiddlePos)))
  (Twiddle "blue" ((twiddlePos)))
  (Twiddle "yellow" ((twiddlePos)))
  (Twiddle "cyan" ((twiddlePos)))
  (Twiddle "orange" ((twiddlePos)))
  (Twiddle "magenta" ((twiddlePos)))
  (Twiddle "brown" ((twiddlePos)))
  (Twiddle "gray" ((twiddlePos)))
  ) (prev twiddles)))

  (: currentset Number)
  (= currentset (initnext 0 (prev currentset)))

  (on clicked
    (= currentset (
        if (in (Position (.. click x) (.. click y)) (list (Position 0 0) (Position 0 1) (Position 1 1)))
        then 1
        else (if (in (Position (.. click x) (.. click y)) (list (Position 1 0) (Position 2 0)))
        then 2
        else (if (in (Position (.. click x) (.. click y)) (list (Position 0 2) (Position 1 2)))
        then 3
        else 4
        ))
    )))

    (on (== currentset 1) (let
        (= t1 (head (filter (--> o (== (.. o origin) (Position 0 0))) twiddles)))
        (= t2 (head (filter (--> o (== (.. o origin) (Position 1 0))) twiddles)))
        (= t3 (head (filter (--> o (== (.. o origin) (Position 1 1))) twiddles)))
        (= t4 (head (filter (--> o (== (.. o origin) (Position 0 1))) twiddles)))
        (print t1)
        (print t2)
        (print t3)
        (print t4)
        (updateObj twiddles (--> t (moveRight t)) (--> t (== (.. t color) (.. t1 color))))
        (updateObj twiddles (--> t (moveDown t)) (--> t (== (.. t color) (.. t2 color))))
        (updateObj twiddles (--> t (moveLeft t)) (--> t (== (.. t color) (.. t3 color))))
        (updateObj twiddles (--> t (moveUp t)) (--> t (== (.. t color) (.. t4 color))))
        (= currentset 0)
    ))

    (on (== currentset 2) (let
        (= t1 (head (filter (--> o (== (.. o origin) (Position 1 0))) twiddles)))
        (= t2 (head (filter (--> o (== (.. o origin) (Position 2 0))) twiddles)))
        (= t3 (head (filter (--> o (== (.. o origin) (Position 2 1))) twiddles)))
        (= t4 (head (filter (--> o (== (.. o origin) (Position 1 1))) twiddles)))
        (updateObj twiddles (--> t (moveRight t)) (--> t (== (.. t color) (.. t1 color))))
        (updateObj twiddles (--> t (moveDown t)) (--> t (== (.. t color) (.. t2 color))))
        (updateObj twiddles (--> t (moveLeft t)) (--> t (== (.. t color) (.. t3 color))))
        (updateObj twiddles (--> t (moveUp t)) (--> t (== (.. t color) (.. t4 color))))
        (= currentset 0)
    ))

    (on (== currentset 3) (let
        (= t1 (head (filter (--> o (== (.. o origin) (Position 0 1))) twiddles)))
        (= t2 (head (filter (--> o (== (.. o origin) (Position 1 1))) twiddles)))
        (= t3 (head (filter (--> o (== (.. o origin) (Position 1 2))) twiddles)))
        (= t4 (head (filter (--> o (== (.. o origin) (Position 0 2))) twiddles)))
        (updateObj twiddles (--> t (moveRight t)) (--> t (== (.. t color) (.. t1 color))))
        (updateObj twiddles (--> t (moveDown t)) (--> t (== (.. t color) (.. t2 color))))
        (updateObj twiddles (--> t (moveLeft t)) (--> t (== (.. t color) (.. t3 color))))
        (updateObj twiddles (--> t (moveUp t)) (--> t (== (.. t color) (.. t4 color))))
        (= currentset 0)
    ))

    (on (== currentset 4) (let
        (= t1 (head (filter (--> o (== (.. o origin) (Position 1 1))) twiddles)))
        (= t2 (head (filter (--> o (== (.. o origin) (Position 2 1))) twiddles)))
        (= t3 (head (filter (--> o (== (.. o origin) (Position 2 2))) twiddles)))
        (= t4 (head (filter (--> o (== (.. o origin) (Position 1 2))) twiddles)))
        (updateObj twiddles (--> t (moveRight t)) (--> t (== (.. t color) (.. t1 color))))
        (updateObj twiddles (--> t (moveDown t)) (--> t (== (.. t color) (.. t2 color))))
        (updateObj twiddles (--> t (moveLeft t)) (--> t (== (.. t color) (.. t3 color))))
        (updateObj twiddles (--> t (moveUp t)) (--> t (== (.. t color) (.. t4 color))))
        (= currentset 0)
    ))
)