(program 
(= GRID_SIZE 24)
  
  ; Define enhanced objects
  (object Switch (: state_ Bool) (list 
                                  (Cell 0 0 (if state_ then "red" else "white"))
                                  (Cell 0 1 (if state_ then "red" else "white"))
                                  (Cell 1 0 (if state_ then "red" else "white"))
                                  (Cell 1 1 (if state_ then "red" else "white"))))
  
  (object AndOutput (: powered Bool) (list 
                                  (Cell 0 0 (if powered then "orange" else "darkblue"))
                                  (Cell 0 1 (if powered then "orange" else "darkblue"))
                                  (Cell 1 0 (if powered then "orange" else "darkblue"))
                                  (Cell 1 1 (if powered then "orange" else "darkblue"))))
  
  (object OrOutput (: powered Bool) (list 
                                  (Cell 0 0 (if powered then "orange" else "darkgreen"))
                                  (Cell 0 1 (if powered then "orange" else "darkgreen"))
                                  (Cell 1 0 (if powered then "orange" else "darkgreen"))
                                  (Cell 1 1 (if powered then "orange" else "darkgreen"))))

  (object NotOutput (: powered Bool) (list 
                                  (Cell 0 0 (if powered then "orange" else "darkred"))
                                  (Cell 0 1 (if powered then "orange" else "darkred"))
                                  (Cell 1 0 (if powered then "orange" else "darkred"))
                                  (Cell 1 1 (if powered then "orange" else "darkred"))))

  (object XorOutput (: powered Bool) (list 
                                  (Cell 0 0 (if powered then "orange" else "purple"))
                                  (Cell 0 1 (if powered then "orange" else "purple"))
                                  (Cell 1 0 (if powered then "orange" else "purple"))
                                  (Cell 1 1 (if powered then "orange" else "purple"))))
  
  ; Wire object - just a single cell
  (object Wire (: powered Bool) (Cell 0 0 (if powered then "yellow" else "grey")))

  ; Button
  (object Button (: color String) (Cell 0 0 color))

  ; Add buttons for wires, switches, outputs and reset
  (: wireButton Button)
  (= wireButton (initnext (Button "grey" (Position 1 0)) (prev wireButton)))

  (: switchButton Button)
  (= switchButton (initnext (Button "white" (Position 4 0)) (prev switchButton)))

  (: andOutputButton Button)
  (= andOutputButton (initnext (Button "darkblue" (Position 7 0)) (prev andOutputButton)))

  (: orOutputButton Button)   
  (= orOutputButton (initnext (Button "darkgreen" (Position 10 0)) (prev orOutputButton)))

  (: notOutputButton Button)
  (= notOutputButton (initnext (Button "darkred" (Position 13 0)) (prev notOutputButton)))

  (: xorOutputButton Button)
  (= xorOutputButton (initnext (Button "purple" (Position 16 0)) (prev xorOutputButton)))

  (: resetButton Button)
  (= resetButton (initnext (Button "red" (Position 19 0)) (prev resetButton)))

  (: playButton Button)
  (= playButton (initnext (Button "yellow" (Position 22 0)) (prev playButton)))

  ; Lists to store placed objects
  (: switches (List Switch))
  (= switches (initnext (list) (prev switches)))

  (: wires (List Wire))
  (= wires (initnext (list) (prev wires)))

  (: andOutputs (List AndOutput))
  (= andOutputs (initnext (list) (prev andOutputs)))

  (: orOutputs (List OrOutput))
  (= orOutputs (initnext (list) (prev orOutputs)))

  (: notOutputs (List NotOutput))
  (= notOutputs (initnext (list) (prev notOutputs)))

  (: xorOutputs (List XorOutput))
  (= xorOutputs (initnext (list) (prev xorOutputs)))

  ; Current placement mode
  (: placementMode String)
  (= placementMode (initnext "play" (prev placementMode)))

  ; Logic functions
  (= evaluateAND (--> (a b) (& a b))) 
  (= evaluateOR (--> (a b) (| a b))) 
  (= evaluateNOT (--> (a) (! a))) 
  (= evaluateXOR (--> (a b) (| (& a (! b)) (& (! a) b))))

  ; Generic function to check if two objects are connected through a path of objects
  (= isConnected (--> (obj1 obj2 connectorObjs)
    (| (in obj1 (concat (list (adjacentObjsDiag obj2 1) (adjacentObjs obj2 1))))
       (& (any (--> c (in c (concat (list (adjacentObjsDiag obj1 1) (adjacentObjs obj1 1))))) connectorObjs)
          (any (--> c (in c (concat (list (adjacentObjsDiag obj2 1) (adjacentObjs obj2 1))))) connectorObjs)))))

  ; Click handlers for buttons
  (on (clicked wireButton) (= placementMode "wire"))
  (on (clicked switchButton) (= placementMode "switch"))
  (on (clicked andOutputButton) (= placementMode "and"))
  (on (clicked orOutputButton) (= placementMode "or"))
  (on (clicked notOutputButton) (= placementMode "not"))
  (on (clicked xorOutputButton) (= placementMode "xor"))
  (on (clicked playButton) (= placementMode "play"))
  (on (clicked resetButton) 
    (let
      (= switches (removeObj switches (--> obj true)))
      (= wires (removeObj wires (--> obj true)))
      (= andOutputs (removeObj andOutputs (--> obj true)))
      (= orOutputs (removeObj orOutputs (--> obj true)))
      (= notOutputs (removeObj notOutputs (--> obj true)))
      (= xorOutputs (removeObj xorOutputs (--> obj true)))
      true
    ))

  ; Click handlers for object placement
  (on (& (& ((clicked)) (isFreePos click)) (== placementMode "wire")) 
    (= wires (addObj wires (Wire false (Position (.. click x) (.. click y))))))

  (on (& (& ((clicked)) (isFreePos click)) (== placementMode "switch")) 
    (= switches (addObj switches (Switch false (Position (.. click x) (.. click y))))))

  (on (& (& ((clicked)) (isFreePos click)) (== placementMode "and")) 
    (= andOutputs (addObj andOutputs (AndOutput false (Position (.. click x) (.. click y))))))

  (on (& (& ((clicked)) (isFreePos click)) (== placementMode "or")) 
    (= orOutputs (addObj orOutputs (OrOutput false (Position (.. click x) (.. click y))))))

  (on (& (& ((clicked)) (isFreePos click)) (== placementMode "not")) 
    (= notOutputs (addObj notOutputs (NotOutput false (Position (.. click x) (.. click y))))))

  (on (& (& ((clicked)) (isFreePos click)) (== placementMode "xor")) 
    (= xorOutputs (addObj xorOutputs (XorOutput false (Position (.. click x) (.. click y))))))

  ; Click handler for toggling switches
  (on (& (clicked (filter (--> obj (in obj switches)) (prev switches))) (== placementMode "play"))
    (let
      (= clickedSwitch (head (filter (--> obj (clicked obj)) (prev switches))))
      (= switches (updateObj switches (--> obj (if (== obj clickedSwitch) then (updateObj obj "state_" (! (.. obj state_))) else obj))))
      true
    ))

  ; Update wire states based on connected switches
  (on true
    (= wires (updateObj wires (--> wire
      (let
        (= connectedSwitches (filter (--> switch (isConnected switch wire switches)) switches))
        (= powered (any (--> switch (.. switch state_)) connectedSwitches))
        (updateObj wire "powered" powered)
      )))))

  ; Update gate outputs based on connected wires and switches
  (on true
    (let
      (= andOutputs (updateObj andOutputs (--> gate
        (let
          (= connectedWires (filter (--> wire (isConnected wire gate wires)) wires))
          (= connectedSwitches (filter (--> switch (isConnected switch gate switches)) switches))
          (= powered (evaluateAND 
            (any (--> wire (.. wire powered)) connectedWires)
            (any (--> switch (.. switch state_)) connectedSwitches)))
          (updateObj gate "powered" powered)
        ))))

      (= orOutputs (updateObj orOutputs (--> gate
        (let
          (= connectedWires (filter (--> wire (isConnected wire gate wires)) wires))
          (= connectedSwitches (filter (--> switch (isConnected switch gate switches)) switches))
          (= powered (evaluateOR 
            (any (--> wire (.. wire powered)) connectedWires)
            (any (--> switch (.. switch state_)) connectedSwitches)))
          (updateObj gate "powered" powered)
        ))))

      (= notOutputs (updateObj notOutputs (--> gate
        (let
          (= connectedWires (filter (--> wire (isConnected wire gate wires)) wires))
          (= connectedSwitches (filter (--> switch (isConnected switch gate switches)) switches))
          (= powered (evaluateNOT 
            (any (--> wire (.. wire powered)) connectedWires)
            (any (--> switch (.. switch state_)) connectedSwitches)))
          (updateObj gate "powered" powered)
        ))))

      (= xorOutputs (updateObj xorOutputs (--> gate
        (let
          (= connectedWires (filter (--> wire (isConnected wire gate wires)) wires))
          (= connectedSwitches (filter (--> switch (isConnected switch gate switches)) switches))
          (= powered (evaluateXOR 
            (any (--> wire (.. wire powered)) connectedWires)
            (any (--> switch (.. switch state_)) connectedSwitches)))
          (updateObj gate "powered" powered)
        ))))
      true
    ))

  
)