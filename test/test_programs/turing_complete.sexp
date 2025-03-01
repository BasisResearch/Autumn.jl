(program 
(= GRID_SIZE 24)
  
  ; Define base objects
  (object Wire (: state_ Bool) (: powered Bool) (if powered then (Cell 0 0 "yellow") else (Cell 0 0 "darkgrey")))
  (object LogicGate (: type String) (: inputs (List Bool)) (: powered Bool) 
           (if powered then (Cell 0 0 "green") else (Cell 0 0 "blue")))
  (object Switch (: state_ Bool) (if state_ then (Cell 0 0 "red") else (Cell 0 0 "darkgrey")))
  (object LED (: powered Bool) (if powered then (Cell 0 0 "orange") else (Cell 0 0 "darkblue")))
  
  ; Function to evaluate logic gates 
  (= evaluateAND (--> (a b) (& a b))) 
  (= evaluateOR (--> (a b) (| a b))) 
  (= evaluateNOT (--> (a) (! a))) 
  (= evaluateXOR (--> (a b) (| (& a (! b)) (& (! a) b))))
  
  ; Create input switches
  (: switch1 Switch) 
  (= switch1 (initnext (Switch false (Position 3 5)) (prev switch1)))
                          
  (: switch2 Switch) 
  (= switch2 (initnext (Switch false (Position 3 10)) (prev switch2)))
  
  ; Create wires
  (: wire1 Wire) 
  (= wire1 (initnext (Wire false false (Position 4 5))
                    (Wire false (.. switch1 state_) (Position 4 5))))
                    
  (: wire2 Wire) 
  (= wire2 (initnext (Wire false false (Position 4 10))
                    (Wire false (.. switch2 state_) (Position 4 10))))
  
  (: wire3 Wire) 
  (= wire3 (initnext (Wire false false (Position 5 5))
                    (Wire false (.. switch1 state_) (Position 5 5))))
                    
  (: wire4 Wire) 
  (= wire4 (initnext (Wire false false (Position 5 10))
                    (Wire false (.. switch2 state_) (Position 5 10))))
  
  (: wire5 Wire) 
  (= wire5 (initnext (Wire false false (Position 9 5))
                    (Wire false (.. andGate powered) (Position 9 5))))
                    
  (: wire6 Wire) 
  (= wire6 (initnext (Wire false false (Position 9 10))
                    (Wire false (.. orGate powered) (Position 9 10))))
                    
  (: wire7 Wire) 
  (= wire7 (initnext (Wire false false (Position 9 15))
                    (Wire false (.. notGate powered) (Position 9 15))))
                    
  (: wire8 Wire) 
  (= wire8 (initnext (Wire false false (Position 9 20))
                    (Wire false (.. xorGate powered) (Position 9 20))))
  
  ; Create logic gates
  (: andGate LogicGate) 
  (= andGate (initnext 
              (LogicGate "AND" (list false false) false (Position 7 5))
              (LogicGate "AND" 
                        (list (.. switch1 state_) (.. switch2 state_))
                        (evaluateAND (.. switch1 state_) (.. switch2 state_))
                        (Position 7 5))))
                        
  (: orGate LogicGate) 
  (= orGate (initnext 
            (LogicGate "OR" (list false false) false (Position 7 10))
            (LogicGate "OR" 
                      (list (.. switch1 state_) (.. switch2 state_))
                      (evaluateOR (.. switch1 state_) (.. switch2 state_))
                      (Position 7 10))))
                      
  (: notGate LogicGate) 
  (= notGate (initnext 
              (LogicGate "NOT" (list false) false (Position 7 15))
              (LogicGate "NOT" 
                        (list (.. switch1 state_))
                        (evaluateNOT (.. switch1 state_))
                        (Position 7 15))))
                        
  (: xorGate LogicGate) 
  (= xorGate (initnext 
              (LogicGate "XOR" (list false false) false (Position 7 20))
              (LogicGate "XOR" 
                        (list (.. switch1 state_) (.. switch2 state_))
                        (evaluateXOR (.. switch1 state_) (.. switch2 state_))
                        (Position 7 20))))
  
  ; Create output LEDs
  (: andLED LED) 
  (= andLED (initnext
            (LED false (Position 11 5))
            (LED (.. andGate powered) (Position 11 5))))
            
  (: orLED LED) 
  (= orLED (initnext
           (LED false (Position 11 10))
           (LED (.. orGate powered) (Position 11 10))))
           
  (: notLED LED) 
  (= notLED (initnext
            (LED false (Position 11 15))
            (LED (.. notGate powered) (Position 11 15))))
            
  (: xorLED LED) 
  (= xorLED (initnext
            (LED false (Position 11 20))
            (LED (.. xorGate powered) (Position 11 20))))

  (on (clicked switch1) (= switch1 (updateObj switch1 "state_" (! (.. (prev switch1) state_)))))

  (on (clicked switch2) (= switch2 (updateObj switch2 "state_" (! (.. (prev switch2) state_)))))
  
)