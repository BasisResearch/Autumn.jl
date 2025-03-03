(program (= GRID_SIZE 24)
  
  (object Robot (: color String) (: active Bool) (: dir String) (: moving Bool) (Cell 0 0 color))
  (object Wall (Cell 0 0 "grey"))
  (object Border (map (--> (pos) (Cell (.. pos x) (.. pos y) "grey")) 
                  (vcat (list 
                  (rect (Position 0 0) (Position GRID_SIZE 1)) 
                  (rect (Position 0 0) (Position 1 GRID_SIZE))
                  (rect (Position (- GRID_SIZE 1) 0) (Position GRID_SIZE GRID_SIZE)) 
                  (rect (Position 0 (- GRID_SIZE 1)) (Position GRID_SIZE GRID_SIZE))
                  ))
                  ))
  
  (object InnerWall (: orientation String) (: length Number) (map (--> (pos) (Cell (.. pos x) (.. pos y) "darkgrey")) 
                    (if (== orientation "horizontal")
                        then (rect (Position 0 0) (Position length 1))
                        else (rect (Position 0 0) (Position 1 length)))))
           
  (: robot1 Robot) 
  (= robot1 (Robot "red" true "none" false (Position 5 5))) ; robot1 is active at first
  
  (: robot2 Robot) 
  (= robot2 (Robot "blue" false "none" false (Position 18 7)))
  
  (: robot3 Robot) 
  (= robot3 (Robot "green" false "none" false (Position 8 17)))
  
  (: robot4 Robot) 
  (= robot4 (Robot "yellow" false "none" false (Position 15 15)))

  ; Border walls
  (: borders Border) 
  (= borders (initnext 
          (Border (Position 0 0))
          (prev borders)))
  
  ; Inner walls - Ricochet Robots style
  (: innerWall1 InnerWall)
  (= innerWall1 (InnerWall "horizontal" 4 (Position 4 6)))
  
  (: innerWall2 InnerWall)
  (= innerWall2 (InnerWall "vertical" 5 (Position 10 3)))
  
  (: innerWall3 InnerWall)
  (= innerWall3 (InnerWall "horizontal" 6 (Position 12 8)))
  
  (: innerWall4 InnerWall)
  (= innerWall4 (InnerWall "vertical" 3 (Position 17 12)))
  
  (: innerWall5 InnerWall)
  (= innerWall5 (InnerWall "horizontal" 5 (Position 3 15)))
  
  (: innerWall6 InnerWall)
  (= innerWall6 (InnerWall "vertical" 4 (Position 7 18)))
  
  (: innerWall7 InnerWall)
  (= innerWall7 (InnerWall "horizontal" 3 (Position 15 20)))
  
  (: innerWall8 InnerWall)
  (= innerWall8 (InnerWall "vertical" 6 (Position 20 9)))
  
  ; Center walls forming a 2x2 square in the middle
  (: centerWall (List Wall))
  (= centerWall1 (list (Wall (Position 11 11)) (Wall (Position 12 11)) (Wall (Position 11 12)) (Wall (Position 12 12)) ))
  
  ; Quadrant divider walls
  (: quadWall1 InnerWall)
  (= quadWall1 (InnerWall "horizontal" 5 (Position 2 9)))
  
  (: quadWall2 InnerWall)
  (= quadWall2 (InnerWall "vertical" 4 (Position 15 5)))
  
  (: quadWall3 InnerWall)
  (= quadWall3 (InnerWall "horizontal" 4 (Position 18 16)))
  
  (: quadWall4 InnerWall)
  (= quadWall4 (InnerWall "vertical" 3 (Position 5 19)))
  
  ; Robot selection handlers
  (on (clicked robot1) 
      (let 
      (= robot1 (updateObj robot1 "active" true)) 
      (= robot2 (updateObj robot2 "active" false)) 
      (= robot3 (updateObj robot3 "active" false)) 
      (= robot4 (updateObj robot4 "active" false))
      true
      ))
  
  (on (clicked robot2) 
      (let 
      (= robot1 (updateObj robot1 "active" false)) 
      (= robot2 (updateObj robot2 "active" true)) 
      (= robot3 (updateObj robot3 "active" false)) 
      (= robot4 (updateObj robot4 "active" false))
      true
      ))
  
  (on (clicked robot3) 
      (let 
      (= robot1 (updateObj robot1 "active" false)) 
      (= robot2 (updateObj robot2 "active" false)) 
      (= robot3 (updateObj robot3 "active" true)) 
      (= robot4 (updateObj robot4 "active" false))
      true
      ))
  
  (on (clicked robot4) 
      (let 
      (= robot1 (updateObj robot1 "active" false)) 
      (= robot2 (updateObj robot2 "active" false)) 
      (= robot3 (updateObj robot3 "active" false)) 
      (= robot4 (updateObj robot4 "active" true))
      true
      ))
  
  ; Direction setting with arrow keys - only allow when robot is not moving
  (on (& (left) (& (.. robot1 active) (! (.. robot1 moving)))) (= robot1 (updateObj robot1 "dir" "left")))
  (on (& (left) (& (.. robot2 active) (! (.. robot2 moving)))) (= robot2 (updateObj robot2 "dir" "left")))
  (on (& (left) (& (.. robot3 active) (! (.. robot3 moving)))) (= robot3 (updateObj robot3 "dir" "left")))
  (on (& (left) (& (.. robot4 active) (! (.. robot4 moving)))) (= robot4 (updateObj robot4 "dir" "left")))
  
  (on (& (right) (& (.. robot1 active) (! (.. robot1 moving)))) (= robot1 (updateObj robot1 "dir" "right")))
  (on (& (right) (& (.. robot2 active) (! (.. robot2 moving)))) (= robot2 (updateObj robot2 "dir" "right")))
  (on (& (right) (& (.. robot3 active) (! (.. robot3 moving)))) (= robot3 (updateObj robot3 "dir" "right")))
  (on (& (right) (& (.. robot4 active) (! (.. robot4 moving)))) (= robot4 (updateObj robot4 "dir" "right")))
  
  (on (& (up) (& (.. robot1 active) (! (.. robot1 moving)))) (= robot1 (updateObj robot1 "dir" "up")))
  (on (& (up) (& (.. robot2 active) (! (.. robot2 moving)))) (= robot2 (updateObj robot2 "dir" "up")))
  (on (& (up) (& (.. robot3 active) (! (.. robot3 moving)))) (= robot3 (updateObj robot3 "dir" "up")))
  (on (& (up) (& (.. robot4 active) (! (.. robot4 moving)))) (= robot4 (updateObj robot4 "dir" "up")))
  
  (on (& (down) (& (.. robot1 active) (! (.. robot1 moving)))) (= robot1 (updateObj robot1 "dir" "down")))
  (on (& (down) (& (.. robot2 active) (! (.. robot2 moving)))) (= robot2 (updateObj robot2 "dir" "down")))
  (on (& (down) (& (.. robot3 active) (! (.. robot3 moving)))) (= robot3 (updateObj robot3 "dir" "down")))
  (on (& (down) (& (.. robot4 active) (! (.. robot4 moving)))) (= robot4 (updateObj robot4 "dir" "down")))
  
  ; Enhanced movement handlers for continuous movement until collision
  (on (== (.. robot1 dir) "left") 
      (let
        (= robot1 (updateObj robot1 "moving" true))
        (= moved (moveLeftNoCollision robot1))
        (= stopped (== moved robot1))
        (if stopped
          then (= robot1 (updateObj (updateObj robot1 "dir" "none") "moving" false))
          else (= robot1 moved))
        true))
  
  (on (== (.. robot1 dir) "right") 
      (let
        (= robot1 (updateObj robot1 "moving" true))
        (= moved (moveRightNoCollision robot1))
        (= stopped (== moved robot1))
        (if stopped
          then (= robot1 (updateObj (updateObj robot1 "dir" "none") "moving" false))
          else (= robot1 moved))
        true))
  
  (on (== (.. robot1 dir) "up") 
      (let
        (= robot1 (updateObj robot1 "moving" true))
        (= moved (moveUpNoCollision robot1))
        (= stopped (== moved robot1))
        (if stopped
          then (= robot1 (updateObj (updateObj robot1 "dir" "none") "moving" false))
          else (= robot1 moved))
        true))
  
  (on (== (.. robot1 dir) "down") 
      (let
        (= robot1 (updateObj robot1 "moving" true))
        (= moved (moveDownNoCollision robot1))
        (= stopped (== moved robot1))
        (if stopped
          then (= robot1 (updateObj (updateObj robot1 "dir" "none") "moving" false))
          else (= robot1 moved))
        true))
  
  ; Movement handlers for robot2
  (on (== (.. robot2 dir) "left") 
      (let
        (= robot2 (updateObj robot2 "moving" true))
        (= moved (moveLeftNoCollision robot2))
        (= stopped (== moved robot2))
        (if stopped
          then (= robot2 (updateObj (updateObj robot2 "dir" "none") "moving" false))
          else (= robot2 moved))
        true))
  
  (on (== (.. robot2 dir) "right") 
      (let
        (= robot2 (updateObj robot2 "moving" true))
        (= moved (moveRightNoCollision robot2))
        (= stopped (== moved robot2))
        (if stopped
          then (= robot2 (updateObj (updateObj robot2 "dir" "none") "moving" false))
          else (= robot2 moved))
        true))
  
  (on (== (.. robot2 dir) "up") 
      (let
        (= robot2 (updateObj robot2 "moving" true))
        (= moved (moveUpNoCollision robot2))
        (= stopped (== moved robot2))
        (if stopped
          then (= robot2 (updateObj (updateObj robot2 "dir" "none") "moving" false))
          else (= robot2 moved))
        true))
  
  (on (== (.. robot2 dir) "down") 
      (let
        (= robot2 (updateObj robot2 "moving" true))
        (= moved (moveDownNoCollision robot2))
        (= stopped (== moved robot2))
        (if stopped
          then (= robot2 (updateObj (updateObj robot2 "dir" "none") "moving" false))
          else (= robot2 moved))
        true))
  
  ; Movement handlers for robot3
  (on (== (.. robot3 dir) "left") 
      (let
        (= robot3 (updateObj robot3 "moving" true))
        (= moved (moveLeftNoCollision robot3))
        (= stopped (== moved robot3))
        (if stopped
          then (= robot3 (updateObj (updateObj robot3 "dir" "none") "moving" false))
          else (= robot3 moved))
        true))
  
  (on (== (.. robot3 dir) "right") 
      (let
        (= robot3 (updateObj robot3 "moving" true))
        (= moved (moveRightNoCollision robot3))
        (= stopped (== moved robot3))
        (if stopped
          then (= robot3 (updateObj (updateObj robot3 "dir" "none") "moving" false))
          else (= robot3 moved))
        true))
  
  (on (== (.. robot3 dir) "up") 
      (let
        (= robot3 (updateObj robot3 "moving" true))
        (= moved (moveUpNoCollision robot3))
        (= stopped (== moved robot3))
        (if stopped
          then (= robot3 (updateObj (updateObj robot3 "dir" "none") "moving" false))
          else (= robot3 moved))
        true))
  
  (on (== (.. robot3 dir) "down") 
      (let
        (= robot3 (updateObj robot3 "moving" true))
        (= moved (moveDownNoCollision robot3))
        (= stopped (== moved robot3))
        (if stopped
          then (= robot3 (updateObj (updateObj robot3 "dir" "none") "moving" false))
          else (= robot3 moved))
        true))
  
  ; Movement handlers for robot4
  (on (== (.. robot4 dir) "left") 
      (let
        (= robot4 (updateObj robot4 "moving" true))
        (= moved (moveLeftNoCollision robot4))
        (= stopped (== moved robot4))
        (if stopped
          then (= robot4 (updateObj (updateObj robot4 "dir" "none") "moving" false))
          else (= robot4 moved))
        true))
  
  (on (== (.. robot4 dir) "right") 
      (let
        (= robot4 (updateObj robot4 "moving" true))
        (= moved (moveRightNoCollision robot4))
        (= stopped (== moved robot4))
        (if stopped
          then (= robot4 (updateObj (updateObj robot4 "dir" "none") "moving" false))
          else (= robot4 moved))
        true))
  
  (on (== (.. robot4 dir) "up") 
      (let
        (= robot4 (updateObj robot4 "moving" true))
        (= moved (moveUpNoCollision robot4))
        (= stopped (== moved robot4))
        (if stopped
          then (= robot4 (updateObj (updateObj robot4 "dir" "none") "moving" false))
          else (= robot4 moved))
        true))
  
  (on (== (.. robot4 dir) "down") 
      (let
        (= robot4 (updateObj robot4 "moving" true))
        (= moved (moveDownNoCollision robot4))
        (= stopped (== moved robot4))
        (if stopped
          then (= robot4 (updateObj (updateObj robot4 "dir" "none") "moving" false))
          else (= robot4 moved))
        true))
)