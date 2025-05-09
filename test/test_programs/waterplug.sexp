(program
    (= GRID_SIZE 16)
    
    (object Button (: color String) (Cell 0 0 color))
    (object Vessel (Cell 0 0 "purple"))
    (object Plug (Cell 0 0 "orange"))
    (object Water (Cell 0 0 "blue"))
    
    (: vesselButton Button)
    (= vesselButton (Button "purple" (Position 2 0)))
    (: plugButton Button)
    (= plugButton (Button "orange" (Position 5 0)))
    (: waterButton Button)
    (= waterButton (Button "blue" (Position 8 0)))
    (: removeButton Button)
    (= removeButton (Button "gray" (Position 11 0)))
    (: clearButton Button)
    (= clearButton (Button "red" (Position 14 0)))
    
    (: vessels (List Vessel))
    (= vessels (initnext (list (Vessel (Position 6 15)) (Vessel (Position 6 14)) (Vessel (Position 6 13)) (Vessel (Position 5 12)) (Vessel (Position 4 11)) (Vessel (Position 3 10)) (Vessel (Position 9 15)) (Vessel (Position 9 14)) (Vessel (Position 9 13)) (Vessel (Position 10 12)) (Vessel (Position 11 11)) (Vessel (Position 12 10))) (prev "vessels")))
    (: plugs (List Plug))
    (= plugs (initnext (list (Plug (Position 7 15)) (Plug (Position 8 15)) (Plug (Position 7 14)) (Plug (Position 8 14)) (Plug (Position 7 13)) (Plug (Position 8 13))) (prev "plugs")))

    (: waterList (List Water))
    (= waterList (initnext (list) (prev "waterList")))
    
    (: currentParticle String)
    (= currentParticle (initnext "vessel" (prev "currentParticle")))
    
    (on true (= waterList (updateObj (prev "waterList") nextLiquid)))

    (on (and ((clicked)) (and (isFreePos click) (== currentParticle "vessel"))) (= vessels (addObj vessels (Vessel (Position (.. click x) (.. click y))))))

    (on (and ((clicked)) (and (isFreePos click) (== currentParticle "plug"))) (= plugs (addObj plugs (Plug (Position (.. click x) (.. click y))))))

    (on (and ((clicked)) (and (isFreePos click) (== currentParticle "water"))) (= waterList (addObj waterList (Water (Position (.. click x) (.. click y))))))

    (on (clicked vesselButton) (= currentParticle "vessel"))
    (on (clicked plugButton) (= currentParticle "plug"))
    (on (clicked waterButton) (= currentParticle "water"))

    (on (clicked removeButton) (= plugs (removeObj plugs (--> obj true))))

    (on (clicked clearButton) (
      let (= vessels (removeObj vessels (--> obj true)))
          (= plugs (removeObj plugs (--> obj true)))
          (= waterList (removeObj waterList (--> obj true)))))
)
