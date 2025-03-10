(program 
(= GRID_SIZE 24)
  
  ; Define enhanced objects
  (object Switch (: powered Bool) (list 
                                  (Cell 0 0 (if powered then "red" else "white"))
                                  (Cell 0 1 (if powered then "red" else "white"))
                                  (Cell 1 0 (if powered then "red" else "white"))
                                  (Cell 1 1 (if powered then "red" else "white"))))
  
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

  (= isPowered (--> obj (.. obj powered)))
  
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
  (= switches (initnext (list (Switch false (Position 4 12)) (Switch false (Position 19 12))) (prev switches)))

  (: wires (List Wire))
  (= wires (initnext (list 
    (Wire false (Position 6 11)) (Wire false (Position 7 10)) (Wire false (Position 8 9)) (Wire false (Position 9 8))
    (Wire false (Position 10 7)) (Wire false (Position 11 6)) (Wire false (Position 11 5))
    (Wire false (Position 18 11)) (Wire false (Position 17 10)) (Wire false (Position 16 9)) (Wire false (Position 15 8))
    (Wire false (Position 14 7)) (Wire false (Position 13 6)) (Wire false (Position 6 12)) (Wire false (Position 7 12))
    (Wire false (Position 8 11)) (Wire false (Position 9 10)) (Wire false (Position 10 9)) (Wire false (Position 11 9))
    (Wire false (Position 18 12)) (Wire false (Position 17 12)) (Wire false (Position 16 11)) (Wire false (Position 15 10))
    (Wire false (Position 14 9)) (Wire false (Position 6 13)) (Wire false (Position 7 14)) (Wire false (Position 8 15))
    (Wire false (Position 9 16)) (Wire false (Position 10 16)) (Wire false (Position 11 16)) (Wire false (Position 6 13))
    (Wire false (Position 6 14)) (Wire false (Position 6 15)) (Wire false (Position 6 16)) (Wire false (Position 6 17))
    (Wire false (Position 6 18)) (Wire false (Position 6 19)) (Wire false (Position 6 20)) (Wire false (Position 7 20))
    (Wire false (Position 8 20)) (Wire false (Position 9 20)) (Wire false (Position 10 20)) (Wire false (Position 11 20))
    (Wire false (Position 18 13)) (Wire false (Position 18 14)) (Wire false (Position 18 15)) (Wire false (Position 18 16))
    (Wire false (Position 18 17)) (Wire false (Position 18 18)) (Wire false (Position 18 19)) (Wire false (Position 18 20))
    (Wire false (Position 17 20)) (Wire false (Position 16 20)) (Wire false (Position 15 20)) (Wire false (Position 14 20))
    ) (prev wires)))

  (: andOutputs (List AndOutput))
  (= andOutputs (initnext (list (AndOutput false (Position 12 4))) (prev andOutputs)))

  (: orOutputs (List OrOutput))
  (= orOutputs (initnext (list (OrOutput false (Position 12 8))) (prev orOutputs)))

  (: notOutputs (List NotOutput))
  (= notOutputs (initnext (list (NotOutput false (Position 12 16))) (prev notOutputs)))

  (: xorOutputs (List XorOutput))
  (= xorOutputs (initnext (list (XorOutput false (Position 12 20))) (prev xorOutputs)))

  ; Current placement mode
  (: placementMode String)
  (= placementMode (initnext "play" (prev "placementMode")))

  ; Logic functions
  (= evaluateAND (--> (a b) (& a b))) 
  (= evaluateOR (--> (a b) (| a b))) 
  (= evaluateNOT (--> (a) (! a))) 
  (= evaluateXOR (--> (a b) (| (& a (! b)) (& (! a) b))))

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
  (on (& (clicked switches) (== placementMode "play"))
    (let
      (= clickedSwitch (head (filter (--> obj (clicked obj)) (prev switches))))
      (= switches (removeObj switches clickedSwitch))
      (= clickedSwitch (updateObj clickedSwitch "powered" (! (.. clickedSwitch powered))))
      (= switches (addObj switches clickedSwitch))
      true
    ))

  ; Update wire states based on if adjacent objects or diagonal objects are powered
  (on true
    (= wires (updateObj wires (--> wire 
      (let
        (= adjObjs (concat 
          (adjacentObjs wire 1)  ; Check adjacent connections
          (adjacentObjsDiag wire) ; Check diagonal connections
        ))
        (print adjObjs)
        (= poweredAdjObjs (filter (--> obj (isPowered obj)) adjObjs))
        (updateObj wire "powered" (> (length poweredAdjObjs) 0))
      )
    )))
  )

  ; Update gate outputs based on connected wires
  (on true
    (= andOutputs (updateObj andOutputs (--> output
      (let
        (= adjWires (concat
          (filter (--> obj (adjacentTwoObjs obj output 1)) wires)  ; Check adjacent connections
          (filter (--> obj (adjacentTwoObjsDiag obj output)) wires) ; Check diagonal connections
        ))
        (= poweredWires (filter (--> wire (isPowered wire)) adjWires))
        (updateObj output "powered" (== (length poweredWires) 2))
      )
    )))

    (= orOutputs (updateObj orOutputs (--> output
      (let
        (= adjWires (concat
          (filter (--> obj (adjacentTwoObjs obj output 1)) wires)  ; Check adjacent connections
          (filter (--> obj (adjacentTwoObjsDiag obj output)) wires) ; Check diagonal connections
        ))
        (= poweredWires (filter (--> wire (isPowered wire)) adjWires))
        (updateObj output "powered" (> (length poweredWires) 0))
      )
    )))

    (= notOutputs (updateObj notOutputs (--> output
      (let
        (= adjWires (concat
          (filter (--> obj (adjacentTwoObjs obj output 1)) wires)  ; Check adjacent connections
          (filter (--> obj (adjacentTwoObjsDiag obj output)) wires) ; Check diagonal connections
        ))
        (= poweredWires (filter (--> wire (isPowered wire)) adjWires))
        (updateObj output "powered" (== (length poweredWires) 0))
      )
    )))

    (= xorOutputs (updateObj xorOutputs (--> output
      (let
        (= adjWires (concat
          (filter (--> obj (adjacentTwoObjs obj output 1)) wires)  ; Check adjacent connections
          (filter (--> obj (adjacentTwoObjsDiag obj output)) wires) ; Check diagonal connections
        ))
        (= poweredWires (filter (--> wire (isPowered wire)) adjWires))
        (updateObj output "powered" (== (length poweredWires) 1))
      )
    )))
  )
)