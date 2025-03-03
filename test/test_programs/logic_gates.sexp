(program 
(= GRID_SIZE 24)
  
  ; Define enhanced objects
  (object Switch (: state_ Bool) (list 
                                  (Cell 0 0 (if state_ then "red" else "darkgrey"))
                                  (Cell 0 1 (if state_ then "red" else "darkgrey"))
                                  (Cell 1 0 (if state_ then "red" else "darkgrey"))
                                  (Cell 1 1 (if state_ then "red" else "darkgrey"))))
  
  (object Output (: powered Bool) (list 
                                  (Cell 0 0 (if powered then "orange" else "darkblue"))
                                  (Cell 0 1 (if powered then "orange" else "darkblue"))
                                  (Cell 1 0 (if powered then "orange" else "darkblue"))
                                  (Cell 1 1 (if powered then "orange" else "darkblue"))))
  
  ; Wire object - just a single cell
  (object Wire (: powered Bool) (Cell 0 0 (if powered then "yellow" else "grey")))
  
  ; Logic functions
  (= evaluateAND (--> (a b) (& a b))) 
  (= evaluateOR (--> (a b) (| a b))) 
  (= evaluateNOT (--> (a) (! a))) 
  (= evaluateXOR (--> (a b) (| (& a (! b)) (& (! a) b))))
  
  ; Create input switches with better positioning
  (: switch1 Switch) 
  (= switch1 (initnext (Switch false (Position 4 12)) (prev switch1)))
                          
  (: switch2 Switch) 
  (= switch2 (initnext (Switch false (Position 19 12)) (prev switch2)))
 
  ; === AND Gate (Row 1) ===
  ; AND gate output
  (: andOutput Output) 
  (= andOutput (initnext
               (Output false (Position 12 4))
               (Output (evaluateAND (.. switch1 state_) (.. switch2 state_)) (Position 12 4))))
  
  ; Wires from switch1 to AND
  (: andWire1 (List Wire))
  (= andWire1 (initnext 
              (map (--> pos (Wire false pos)) 
                   (list (Position 6 11) (Position 7 10) (Position 8 9) 
                         (Position 9 8) (Position 10 7) (Position 11 6) 
                         (Position 11 5)))
              (map (--> w (updateObj w "powered" (.. switch1 state_))) (prev andWire1))))
  
  ; Wires from switch2 to AND
  (: andWire2 (List Wire))
  (= andWire2 (initnext 
              (map (--> pos (Wire false pos)) 
                   (list (Position 18 11) (Position 17 10) (Position 16 9) 
                         (Position 15 8) (Position 14 7) (Position 13 6) 
                        ))
              (map (--> w (updateObj w "powered" (.. switch2 state_))) (prev andWire2))))
            
  ; === OR Gate (Row 2) ===
  ; OR gate output
  (: orOutput Output) 
  (= orOutput (initnext
              (Output false (Position 12 8))
              (Output (evaluateOR (.. switch1 state_) (.. switch2 state_)) (Position 12 8))))
  
  ; Wires from switch1 to OR
  (: orWire1 (List Wire))
  (= orWire1 (initnext 
             (map (--> pos (Wire false pos)) 
                  (list (Position 6 12) (Position 7 12) (Position 8 11) 
                        (Position 9 10) (Position 10 9) (Position 11 9)))
             (map (--> w (updateObj w "powered" (.. switch1 state_))) (prev orWire1))))
  
  ; Wires from switch2 to OR
  (: orWire2 (List Wire))
  (= orWire2 (initnext 
             (map (--> pos (Wire false pos)) 
                  (list (Position 18 12) (Position 17 12) (Position 16 11) 
                        (Position 15 10) (Position 14 9) ))
             (map (--> w (updateObj w "powered" (.. switch2 state_))) (prev orWire2))))
          
  ; === NOT Gate (Row 3) ===
  ; NOT gate output
  (: notOutput Output) 
  (= notOutput (initnext
               (Output false (Position 12 16))
               (Output (evaluateNOT (.. switch1 state_)) (Position 12 16))))
  
  ; Wires from switch1 to NOT
  (: notWire (List Wire))
  (= notWire (initnext 
             (map (--> pos (Wire false pos)) 
                  (list (Position 6 13) (Position 7 14) (Position 8 15) 
                        (Position 9 16) (Position 10 16) (Position 11 16)))
             (map (--> w (updateObj w "powered" (.. switch1 state_))) (prev notWire))))
            
  ; === XOR Gate (Row 4) ===
  ; XOR gate output
  (: xorOutput Output) 
  (= xorOutput (initnext
               (Output false (Position 12 20))
               (Output (evaluateXOR (.. switch1 state_) (.. switch2 state_)) (Position 12 20))))
  
  ; Wires from switch1 to XOR
  (: xorWire1 (List Wire))
  (= xorWire1 (initnext 
              (map (--> pos (Wire false pos)) 
                   (list (Position 6 13) (Position 6 14) (Position 6 15) 
                         (Position 6 16) (Position 6 17) (Position 6 18) 
                         (Position 6 19) (Position 6 20) (Position 7 20) 
                         (Position 8 20) (Position 9 20) (Position 10 20) (Position 11 20)))
              (map (--> w (updateObj w "powered" (.. switch1 state_))) (prev xorWire1))))
  
  ; Wires from switch2 to XOR
  (: xorWire2 (List Wire))
  (= xorWire2 (initnext 
              (map (--> pos (Wire false pos)) 
                   (list (Position 18 13) (Position 18 14) (Position 18 15) 
                         (Position 18 16) (Position 18 17) (Position 18 18) 
                         (Position 18 19) (Position 18 20) (Position 17 20) 
                         (Position 16 20) (Position 15 20) (Position 14 20) ))
              (map (--> w (updateObj w "powered" (.. switch2 state_))) (prev xorWire2))))
  
  ; Click handlers for all switches
  (on (clicked switch1) (= switch1 (updateObj switch1 "state_" (! (.. (prev switch1) state_)))))
  (on (clicked switch2) (= switch2 (updateObj switch2 "state_" (! (.. (prev switch2) state_)))))
)