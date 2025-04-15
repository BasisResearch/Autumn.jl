(program
  (= GRID_SIZE 50)

  (: NEIGHBOR_RADIUS Number)
  (= NEIGHBOR_RADIUS 9)
  (: MAX_SPEED Number)
  (= MAX_SPEED 1)
  (: SEPARATION_WEIGHT Number)
  (= SEPARATION_WEIGHT 1)
  (: ALIGNMENT_WEIGHT Number)
  (= ALIGNMENT_WEIGHT 3)
  (: COHESION_WEIGHT Number)
  (= COHESION_WEIGHT 1)

  (object Boid 
    (: velocity Position)
    (: color String)
    (Cell 0 0 color))

  (: boids (List Boid))
  (= boids (initnext 
    (list 
      (Boid (Position 1 0) "blue" (Position 5 5))
      (Boid (Position 0 1) "red" (Position 10 10))
      (Boid (Position -1 0) "green" (Position 15 15))
      (Boid (Position 0 -1) "yellow" (Position 8 12))
    ) 
    (map (--> boid (updateBoid boid (prev boids))) (prev boids))))

  (= getNeighbors (fn (boid allBoids)
    (filter (--> other 
      (& 
        (!= boid other)
        (< (sqdist (.. boid origin) (.. other origin)) NEIGHBOR_RADIUS)
      )
    ) allBoids)))

  (= separation (fn (boid neighbors)
    (if (== (length neighbors) 0) 
      then (Position 0 0)
      else (let
        (= sumx (sum (map (--> neighbor
          (- (.. (.. neighbor origin) x) (.. (.. boid origin) x))
        ) neighbors)))
        (= sumy (sum (map (--> neighbor
          (- (.. (.. neighbor origin) y) (.. (.. boid origin) y))
        ) neighbors)))
        (Position 
          (* SEPARATION_WEIGHT sumx)
          (* SEPARATION_WEIGHT sumy)
        )
      )
    )
  ))

  (= alignment (fn (boid neighbors)
    (if (== (length neighbors) 0)
      then (Position 0 0)
      else (let
        (= sumx (sum (map (--> neighbor (.. (.. neighbor velocity) x)) neighbors)))
        (= sumy (sum (map (--> neighbor (.. (.. neighbor velocity) y)) neighbors)))
        (Position 
          (* ALIGNMENT_WEIGHT sumx)
          (* ALIGNMENT_WEIGHT sumy)
        )
      )
    )
  ))

  (= cohesion (fn (boid neighbors)
    (if (== (length neighbors) 0)
      then (Position 0 0)
      else (let
        (= sumx (sum (map (--> neighbor (.. (.. neighbor origin) x)) neighbors)))
        (= sumy (sum (map (--> neighbor (.. (.. neighbor origin) y)) neighbors)))
        (= avgx (/ sumx (length neighbors)))
        (= avgy (/ sumy (length neighbors)))
        (Position 
          (* COHESION_WEIGHT (- avgx (.. (.. boid origin) x)))
          (* COHESION_WEIGHT (- avgy (.. (.. boid origin) y)))
        )
      )
    )
  ))

  (= updateBoid (fn (boid allBoids)
    (let
      (= neighbors (getNeighbors boid allBoids))
      (= sep (separation boid neighbors))
      (= align (alignment boid neighbors))
      (= coh (cohesion boid neighbors))
      (= newVel (Position 
        (+ (+ (.. (.. boid velocity) x) (.. sep x)) (+ (.. align x) (.. coh x)))
        (+ (+ (.. (.. boid velocity) y) (.. sep y)) (+ (.. align y) (.. coh y)))
      ))
      (= speed (sqrt (+ (* (.. newVel x) (.. newVel x)) (* (.. newVel y) (.. newVel y)))))
      (= newVel (if (> speed MAX_SPEED)
        then (Position 
          (* (/ (.. newVel x) speed) MAX_SPEED)
          (* (/ (.. newVel y) speed) MAX_SPEED)
        )
        else newVel
      ))
      (= newPos (Position 
        (% (+ (.. (.. boid origin) x) (.. newVel x)) GRID_SIZE)
        (% (+ (.. (.. boid origin) y) (.. newVel y)) GRID_SIZE)
      ))
      (Boid newVel (.. boid color) newPos)
    )
  ))

  (on clicked 
    (= boids (addObj boids 
      (Boid 
        (Position (uniformChoice (list -1 0 1)) (uniformChoice (list -1 0 1)))
        (uniformChoice (list "red" "blue" "green" "yellow"))
        (Position (.. click x) (.. click y))
      )
    ))
  )

  (on up (= SEPARATION_WEIGHT (min (+ SEPARATION_WEIGHT 2) 10)))
  (on down (= SEPARATION_WEIGHT (max (- SEPARATION_WEIGHT 2) 0)))
  (on left (= ALIGNMENT_WEIGHT (min (+ ALIGNMENT_WEIGHT 2) 10)))
  (on right (= ALIGNMENT_WEIGHT (max (- ALIGNMENT_WEIGHT 2) 0)))
) 