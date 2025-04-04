(program
  (= GRID_SIZE 16)
  
  (object Agent (Cell 0 0 "blue"))
  (object Box (Cell 0 0 "gray"))
  (object Goal (Cell 0 0 "red"))
  
  (: agent Agent)
  (= agent (initnext (Agent (Position 7 4)) (prev agent)))
    
  (: boxes (List Box))
  (= boxes (initnext (list (Box (Position 14 2)) (Box (Position 9 14)) (Box (Position 1 2)) (Box (Position 0 4)) (Box (Position 4 4)) (Box (Position 9 9)) (Box (Position 10 9)) (Box (Position 0 11))) (prev boxes)))
  
  (: goal Goal)
  (= goal (initnext (Goal (Position 0 0)) (prev goal)))
  
  (on left (let (= boxes (moveBoxes (prev boxes) (prev agent) (prev goal) -1 0)) 
                (= agent (moveAgent (prev agent) (prev boxes) (prev goal) -1 0)))) 
  
  (on right (let (= boxes (moveBoxes (prev boxes) (prev agent) (prev goal) 1 0)) 
                  (= agent (moveAgent (prev agent) (prev boxes) (prev goal) 1 0)))) 
  
  (on up (let (= boxes (moveBoxes (prev boxes) (prev agent) (prev goal) 0 -1)) 
              (= agent (moveAgent (prev agent) (prev boxes) (prev goal) 0 -1)))) 
  
  (on down (let (= boxes (moveBoxes (prev boxes) (prev agent) (prev goal) 0 1)) 
                (= agent (moveAgent (prev agent) (prev boxes) (prev goal) 0 1)))) 
  
  (on (& ((clicked)) (isFreePos click)) (= boxes (addObj boxes (Box (Position (.. click x) (.. click y))))))
  
  (= moveBoxes (fn (boxes agent goal x y) 
                  (updateObj boxes 
                    (--> obj (if (intersects (move obj Position (x y)) goal) then (removeObj obj) else (moveNoCollision obj Position (x y)))) 
                    (--> obj (== (displacement (.. obj origin) (.. agent origin)) (Position (- 0 x) (- 0 y)))))))
  
  (= moveAgent (fn (agent boxes goal x y) 
                  (if (intersects (list (move agent x y)) (moveBoxes boxes agent goal x y))
                    then agent 
                    else (move agent x y))))
)
