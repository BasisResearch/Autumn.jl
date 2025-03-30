(program
  (= GRID_SIZE 7)
  
  ; Define game objects
  (object Peg (: empty Bool) (: active Bool) (Cell 0 0 (if empty then "lightgray" else "blue")))
  
  (: pegs (List Peg))
  (= pegs (initnext (list 
           (Peg false false (Position 2 0)) (Peg false false (Position 3 0)) (Peg false false (Position 4 0))
           (Peg false false (Position 2 1)) (Peg false false (Position 3 1)) (Peg false false (Position 4 1))
           (Peg false false (Position 0 2)) (Peg false false (Position 1 2)) (Peg false false (Position 2 2)) (Peg false false (Position 3 2)) (Peg false false (Position 4 2)) (Peg false false (Position 5 2)) (Peg false false (Position 6 2))
           (Peg false false (Position 0 3)) (Peg false false (Position 1 3)) (Peg false false (Position 2 3)) (Peg true false (Position 3 3)) (Peg false false (Position 4 3)) (Peg false false (Position 5 3)) (Peg false false (Position 6 3))
           (Peg false false (Position 0 4)) (Peg false false (Position 1 4)) (Peg false false (Position 2 4)) (Peg false false (Position 3 4)) (Peg false false (Position 4 4)) (Peg false false (Position 5 4)) (Peg false false (Position 6 4))
           (Peg false false (Position 2 5)) (Peg false false (Position 3 5)) (Peg false false (Position 4 5))
           (Peg false false (Position 2 6)) (Peg false false (Position 3 6)) (Peg false false (Position 4 6))
           ) (prev pegs)))
  ; Jump condition
  (= check_jump_possible (--> (p1 p2) (
    let (= delta (deltaPos p1 p2))
    (print delta)
        (in delta (list (Position 2 0) (Position -2 0) (Position 0 2) (Position 0 -2)))
    )
  ))

  ; Activate a peg if it is empty and not active
  (on (clicked (filter (--> obj (== (.. obj empty) false)) (prev pegs))) (let 
      ; Set the clicked peg to active
      (= pegs (updateObj pegs (--> peg (updateObj peg "active" true)) (--> peg (== (.. peg origin) (Position (.. click x) (.. click y))))))
      ; Set other pegs to inactive
      (= pegs (updateObj pegs (--> peg (updateObj peg "active" false)) (--> peg (!= (.. peg origin) (Position (.. click x) (.. click y))))))
      true
      ))
  (on (clicked (filter (--> obj (== (.. obj empty) true)) (prev pegs))) (let
          ; Find the peg that is active
          (= active_peg (head (filter (--> peg (== (.. peg active) true)) (prev pegs))))
          ; Check if the active peg is 2 units away from the clicked peg
          (= jump_possible (check_jump_possible (.. active_peg origin) (Position (.. click x) (.. click y))))
          ; If the jump is possible, remove the peg in between
          (if jump_possible then
            (let
              ; Find the peg in between
              (= mid_pos (Position (/(+ (.. (.. active_peg origin) x) (.. click x)) 2) (/(+ (.. (.. active_peg origin) y) (.. click y)) 2)))
              ; Remove the peg in between
              (= pegs (updateObj pegs (--> peg (updateObj peg "empty" true)) (--> peg (== (.. peg origin) mid_pos))))
              ; Make the clicked peg non-empty
              (= pegs (updateObj pegs (--> peg (updateObj peg "empty" false)) (--> peg (== (.. peg origin) (Position (.. click x) (.. click y))))))
              ; Set the active peg to empty
              (= pegs (updateObj pegs (--> peg (updateObj peg "empty" true)) (--> peg (== peg active_peg))))
              ) else true
          )
          true
  ))
)