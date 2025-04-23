(program
  (= GRID_SIZE 13)
  (= background "darkgray") ; optional background color
  (= UPDATE_RATE 10) ; Only update every 5 frames

  ;; -------------------------
  ;; Object Definitions
  ;; -------------------------
  (object Car (: speed Number) (Cell 0 0 "blue"))
  (object Track (: solid Bool) (Cell 0 0 (if solid then "white" else "black")))
  (object Obstacle (Cell 0 0 "red"))
  (object FinishLine (: color String) (Cell 0 0 color))
  (object Score (: color String) (Cell 0 0 color))
  ;; -------------------------
  ;; Global State
  ;; -------------------------
  (: frameCount Number)
  (= frameCount (initnext 0 (if (>= (prev frameCount) UPDATE_RATE) 
                               then 0
                               else (+ (prev frameCount) 1))))

  (: playedNumber Number)
  (= playedNumber (initnext 0 (prev playedNumber)))

  (: playerCar Car)
  (= playerCar
    (initnext
      (Car 1 (Position 5 10)) ; Start near the bottom
      (let
        ;; Only move when frameCount is 0 (every UPDATE_RATE frames)
        (= shouldUpdate (== (prev frameCount) 0))
        (if shouldUpdate
          then (moveNoCollision (prev "playerCar") (Position 0 -1))
          else (prev "playerCar"))
      )
    )
  )

  (: scores (List Score))
  (= scores (initnext (list ) (prev scores)))

  ;; Define the track as a list of track cells (white lines or black empty road)
  (: tracks (List Track))
  (= tracks
    (initnext
      (list
        ;; A few lines marking track boundaries or lanes
        (Track true (Position 0 0)) (Track true (Position 0 1)) 
        (Track true (Position 11 0)) (Track true (Position 11 1))
      )
      (prev tracks)
    )
  )

  (: obstacles (List Obstacle))
  (= obstacles
    (initnext
      (list 
        (Obstacle (Position 5 2))
        (Obstacle (Position 3 7))
        (Obstacle (Position 7 5))
      )
      ;; Only move obstacles when frameCount is 0 (every UPDATE_RATE frames)
      (if (== (prev frameCount) 0)
        then (updateObj (prev obstacles) (--> o (move o (Position 0 1))))
        else (prev obstacles))
    )
  )

  ;; The finish line near the top
  (: finish FinishLine)
  (= finish (initnext (FinishLine "gold" (Position 5 0)) (prev finish)))

  ;; Keep track of race status
  (: raceOver Bool)
  (= raceOver (initnext false (prev raceOver)))

  ;; -------------------------
  ;; Movement Functions
  ;; -------------------------
  (= moveNoCollision (fn (car deltaPos)
    (let
      (= newPos (Position 
                  (+ (.. (.. car origin) x) (.. deltaPos x))
                  (+ (.. (.. car origin) y) (.. deltaPos y))))
      (if (or 
            (! (isWithinBounds newPos)) 
            (intersectsPos newPos tracks))
        then car
        else (move car deltaPos))
    )
  ))

  (= intersectsPos (fn (pos objects)
    (any (--> obj (== (.. obj origin) pos)) objects)
  ))

  ;; -------------------------
  ;; Controls: left/right arrows to switch lanes
  ;; -------------------------
  (on left
    (let
      (= oldCar (prev "playerCar"))
      (= playerCar (moveNoCollision oldCar (Position -1 0)))
    )
  )
  (on right
    (let
      (= oldCar (prev "playerCar"))
      (= playerCar (moveNoCollision oldCar (Position 1 0)))
    )
  )

  ;; Optionally use up/down to accelerate or decelerate
  (on up
    (let
      (= oldCar (prev "playerCar"))
      (= newSpeed (min (+ (.. oldCar speed) 1) 3)) ; max speed 3
      (= playerCar (updateObj oldCar "speed" newSpeed))
    )
  )
  (on down
    (let
      (= oldCar (prev "playerCar"))
      (= newSpeed (max (- (.. oldCar speed) 1) 1)) ; min speed 1
      (= playerCar (updateObj oldCar "speed" newSpeed))
    )
  )

  ;; -------------------------
  ;; Collisions
  ;; -------------------------
  ;; Car hits obstacle => race over
  (on (intersects (prev "playerCar") (prev obstacles))
    (let
      (= raceOver true)
      (= finish (updateObj (prev finish) "color" "red"))
      (print "CRASH! Game Over.")
      ;; reset the game after a delay
      (if (== (prev frameCount) 0)
        then (let
          (= playerCar (Car 1 (Position 5 10)))
          (= obstacles (list 
            (Obstacle (Position 5 2))
            (Obstacle (Position 3 7))
            (Obstacle (Position 7 5))))
          (= finish (FinishLine "gold" (Position 5 0)))
          (= raceOver false)
          (= playedNumber (+ (prev playedNumber) 1))
          (= scores (addObj (prev scores) (Score "red" (Position (- GRID_SIZE 1) (- GRID_SIZE (prev playedNumber))))))
          )
        else true
      )

    )
  )

  ;; Car crosses finish line
  (on (intersects (prev "playerCar") (prev finish))
    (let
      (= raceOver true)
      (= finish (updateObj (prev finish) "color" "green"))
      (print "You reached the finish line! You win!")
      ;; reset the game after a delay
      (if (== (prev frameCount) 0)
        then (let
          (= playerCar (Car 1 (Position 5 10)))
          (= obstacles (list 
            (Obstacle (Position 5 2))
            (Obstacle (Position 3 7))
            (Obstacle (Position 7 5))))
          (= finish (FinishLine "gold" (Position 5 0)))
          (= raceOver false)
          (= playedNumber (+ (prev playedNumber) 1))
          (= scores (addObj (prev scores) (Score "green" (Position (- GRID_SIZE 1) (- GRID_SIZE (prev playedNumber))))))
        )
        else true
      )
    )
  )
)