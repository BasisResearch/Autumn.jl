(program
  (= GRID_SIZE 60)

  (: NEIGHBOR_RADIUS Number)
  (= NEIGHBOR_RADIUS 25)
  (: MIN_DISTANCE Number)
  (= MIN_DISTANCE 1)
  (: MAX_SPEED Number)
  (= MAX_SPEED 4)
  (: SEPARATION_WEIGHT Number)
  (= SEPARATION_WEIGHT 1)
  (: ALIGNMENT_WEIGHT Number)
  (= ALIGNMENT_WEIGHT 3)
  (: COHESION_WEIGHT Number)
  (= COHESION_WEIGHT 0)
  (: MAX_BOID_COUNT Number)
  (= MAX_BOID_COUNT 30)

  (object Boid 
    (: velocity Position)
    (Cell 0 0 "mediumpurple"))

  (: boids (List Boid))
  (= boids (initnext 
    (list 
      (Boid (Position 1 0) (Position 5 5))
      (Boid (Position 0 1) (Position 10 10))
      (Boid (Position -1 0) (Position 15 15))
      (Boid (Position 0 -1) (Position 8 12))
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
          (let
            (= dx (- (.. (.. neighbor origin) x) (.. (.. boid origin) x)))
            (= dy (- (.. (.. neighbor origin) y) (.. (.. boid origin) y)))
            (= dist (sqrt (+ (* dx dx) (* dy dy))))
            (if (< dist MIN_DISTANCE)
              then (* SEPARATION_WEIGHT (/ dx (* dist dist)))
              else (* SEPARATION_WEIGHT (/ dx (* (* dist dist) dist)))
            )
          )
        ) neighbors)))
        (= sumy (sum (map (--> neighbor
          (let
            (= dx (- (.. (.. neighbor origin) x) (.. (.. boid origin) x)))
            (= dy (- (.. (.. neighbor origin) y) (.. (.. boid origin) y)))
            (= dist (sqrt (+ (* dx dx) (* dy dy))))
            (if (< dist MIN_DISTANCE)
              then (* SEPARATION_WEIGHT (/ dy (* dist dist)))
              else (* SEPARATION_WEIGHT (/ dy (* (* dist dist) dist)))
            )
          )
        ) neighbors)))
        (Position 
          (- sumx)
          (- sumy)
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
      (= newX (+ (.. (.. boid origin) x) (.. newVel x)))
      (= newY (+ (.. (.. boid origin) y) (.. newVel y)))
      (= wrappedX (if (< newX 0) 
        then (+ GRID_SIZE (% newX GRID_SIZE))
        else (if (>= newX GRID_SIZE)
          then (% newX GRID_SIZE)
          else newX)))
      (= wrappedY (if (< newY 0) 
        then (+ GRID_SIZE (% newY GRID_SIZE))
        else (if (>= newY GRID_SIZE)
          then (% newY GRID_SIZE)
          else newY)))
      (= newPos (Position wrappedX wrappedY))
      (Boid newVel newPos)
    )
  ))

  (on (& ((clicked)) (< (length boids) MAX_BOID_COUNT))
    (= boids (addObj boids 
      (Boid 
        (Position (uniformChoice (list -1 0 1)) (uniformChoice (list -1 0 1)))
        (Position (.. click x) (.. click y))
      )
    ))
  )

  (on up (= SEPARATION_WEIGHT (min (+ SEPARATION_WEIGHT 1) 10)))
  (on down (= SEPARATION_WEIGHT (max (- SEPARATION_WEIGHT 1) 0)))
  (on left (= ALIGNMENT_WEIGHT (min (+ ALIGNMENT_WEIGHT 1) 10)))
  (on right (= ALIGNMENT_WEIGHT (max (- ALIGNMENT_WEIGHT 1) 0)))
) 