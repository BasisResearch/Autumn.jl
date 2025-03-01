(program (= GRID_SIZE 24)
  
  (object Robot (: color String) (: active Bool) (: dir String) (Cell 0 0 color))
  (object Wall (Cell 0 0 "grey"))
  (object Border (map (--> (pos) (Cell (.. pos x) (.. pos y) "grey")) 
                  (vcat (list 
                  (rect (Position 0 0) (Position GRID_SIZE 1)) 
                  (rect (Position 0 0) (Position 1 GRID_SIZE))
                  (rect (Position (- GRID_SIZE 1) 0) (Position GRID_SIZE GRID_SIZE)) 
                  (rect (Position 0 (- GRID_SIZE 1)) (Position GRID_SIZE GRID_SIZE))
                  ))
                  ))
           
  
  (: robot1 Robot) 
  (= robot1 (Robot "red" true "none" (Position 5 5))) ; robot1 is active at first
  
  (: robot2 Robot) 
  (= robot2 (Robot "blue" false "none" (Position 1 5)))
  
  (: robot3 Robot) 
  (= robot3 (Robot "green" false "none" (Position 5 7)))
  
  (: robot4 Robot) 
  (= robot4 (Robot "yellow" false "none" (Position 5 15)))
  
  (: walls Border) 
  (= walls (initnext 
          (Border (Position 0 0))
          (prev walls)))
  
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
  
  (on (& (left) (.. robot1 active)) (= robot1 (updateObj robot1 "dir" "left")))
  (on (& (left) (.. robot2 active)) (= robot2 (updateObj robot2 "dir" "left")))
  (on (& (left) (.. robot3 active)) (= robot3 (updateObj robot3 "dir" "left")))
  (on (& (left) (.. robot4 active)) (= robot4 (updateObj robot4 "dir" "left")))

  (on (& (right) (.. robot1 active)) (= robot1 (updateObj robot1 "dir" "right")))
  (on (& (right) (.. robot2 active)) (= robot2 (updateObj robot2 "dir" "right")))
  (on (& (right) (.. robot3 active)) (= robot3 (updateObj robot3 "dir" "right")))
  (on (& (right) (.. robot4 active)) (= robot4 (updateObj robot4 "dir" "right")))

  (on (& (up) (.. robot1 active)) (= robot1 (updateObj robot1 "dir" "up")))
  (on (& (up) (.. robot2 active)) (= robot2 (updateObj robot2 "dir" "up")))
  (on (& (up) (.. robot3 active)) (= robot3 (updateObj robot3 "dir" "up")))
  (on (& (up) (.. robot4 active)) (= robot4 (updateObj robot4 "dir" "up")))

  (on (& (down) (.. robot1 active)) (= robot1 (updateObj robot1 "dir" "down")))
  (on (& (down) (.. robot2 active)) (= robot2 (updateObj robot2 "dir" "down")))
  (on (& (down) (.. robot3 active)) (= robot3 (updateObj robot3 "dir" "down")))
  (on (& (down) (.. robot4 active)) (= robot4 (updateObj robot4 "dir" "down")))

  ; Movement handlers for robot1
  (on (== (.. robot1 dir) "left") (= robot1 (moveLeftNoCollision robot1)))
  (on (== (.. robot1 dir) "right") (= robot1 (moveRightNoCollision robot1)))
  (on (== (.. robot1 dir) "up") (= robot1 (moveUpNoCollision robot1)))
  (on (== (.. robot1 dir) "down") (= robot1 (moveDownNoCollision robot1)))
  
  ; Movement handlers for robot2
  (on (== (.. robot2 dir) "left") (= robot2 (moveLeftNoCollision robot2)))
  (on (== (.. robot2 dir) "right") (= robot2 (moveRightNoCollision robot2)))
  (on (== (.. robot2 dir) "up") (= robot2 (moveUpNoCollision robot2)))
  (on (== (.. robot2 dir) "down") (= robot2 (moveDownNoCollision robot2)))
  
  ; Movement handlers for robot3
  (on (== (.. robot3 dir) "left") (= robot3 (moveLeftNoCollision robot3)))
  (on (== (.. robot3 dir) "right") (= robot3 (moveRightNoCollision robot3)))
  (on (== (.. robot3 dir) "up") (= robot3 (moveUpNoCollision robot3)))
  (on (== (.. robot3 dir) "down") (= robot3 (moveDownNoCollision robot3)))
  
  ; Movement handlers for robot4
  (on (== (.. robot4 dir) "left") (= robot4 (moveLeftNoCollision robot4)))
  (on (== (.. robot4 dir) "right") (= robot4 (moveRightNoCollision robot4)))
  (on (== (.. robot4 dir) "up") (= robot4 (moveUpNoCollision robot4)))
  (on (== (.. robot4 dir) "down") (= robot4 (moveDownNoCollision robot4)))
)