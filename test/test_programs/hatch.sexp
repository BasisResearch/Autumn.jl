(program
  (= GRID_SIZE 16)

  (object Eggshell (: broken Bool) (Cell 0 0 "tan"))
  (object Feather (: hidden Bool) (: color String) (Cell 0 0 color))

  (= makeEgg (fn () (list                                    
          (Eggshell false (Position 7 15)) 
          (Eggshell false (Position 8 15))
          (Eggshell false (Position 9 15))  
          (Eggshell false (Position 6 14)) 
          (Eggshell false (Position 7 14)) 
          (Eggshell false (Position 8 14)) 
          (Eggshell false (Position 9 14))
          (Eggshell false (Position 10 14)) 
          (Eggshell false (Position 5 13)) 
          (Eggshell false (Position 6 13))
          (Eggshell false (Position 7 13)) 
          (Eggshell false (Position 8 13)) 
          (Eggshell false (Position 9 13)) 
          (Eggshell false (Position 10 13))
          (Eggshell false (Position 11 13)) 
          (Eggshell false (Position 5 12)) 
          (Eggshell false (Position 6 12)) 
          (Eggshell false (Position 7 12))
          (Eggshell false (Position 8 12)) 
          (Eggshell false (Position 9 12)) 
          (Eggshell false (Position 10 12)) 
          (Eggshell false (Position 11 12))
          (Eggshell false (Position 5 11)) 
          (Eggshell false (Position 6 11)) 
          (Eggshell false (Position 7 11)) 
          (Eggshell false (Position 8 11))
          (Eggshell false (Position 9 11)) 
          (Eggshell false (Position 10 11)) 
          (Eggshell false (Position 11 11)) 
          (Eggshell false (Position 6 10)) 
          (Eggshell false (Position 7 10)) 
          (Eggshell false (Position 8 10)) 
          (Eggshell false (Position 9 10))
          (Eggshell false (Position 10 10))
          (Eggshell false (Position 7 9)) 
          (Eggshell false (Position 8 9)) 
          (Eggshell false (Position 9 9)))))

  (= makeChick (fn () (list (Feather true "orange" (Position 7 15))
            (Feather true  "orange" (Position 8 15))
            (Feather true  "yellow" (Position 6 14))
            (Feather true  "yellow" (Position 7 14))
            (Feather true  "yellow" (Position 8 14))
            (Feather true  "yellow" (Position 9 14))
            (Feather true  "yellow" (Position 6 13))
            (Feather true  "yellow" (Position 7 13))
            (Feather true  "yellow" (Position 8 13))
            (Feather true  "yellow" (Position 9 13))
            (Feather true  "yellow" (Position 6 12))
            (Feather true  "yellow" (Position 7 12))
            (Feather true  "yellow" (Position 8 12))
            (Feather true  "yellow" (Position 9 12))
            (Feather true  "yellow" (Position 9 11))
            (Feather true  "yellow" (Position 10 11))
            (Feather true  "orange" (Position 11 11))
            (Feather true  "yellow" (Position 9 10))
            )))


  (: feathers (List Feather))
  (= feathers (initnext ((makeChick)) (prev feathers)))



  (: eggshells (List Eggshell))
  (= eggshells (initnext ((makeEgg)) (nextEggshells (prev eggshells) (prev feathers))))


  (on (clicked eggshells) (= eggshells (updateObj (prev eggshells) 
                                                  (--> eggshell 
                                                        (if (clicked eggshell) 
                                                        then (updateObj eggshell "broken" true) 
                                                        else eggshell)))))
                        
  (= nextEggshells (--> (eggshells feathers) 
                        (let (= brokenEggshell (filter (--> (es) (.. es broken)) eggshells))
                             (= brokenEggshell (filter (--> (es) (! (intersects es feathers))) brokenEggshell))
                             (= unbrokenEggshell (filter (--> (es) (! (.. es broken) )) eggshells))
                             (= nextBrokenEggShell (map nextLiquid brokenEggshell))
                             (concat (list nextBrokenEggShell unbrokenEggshell)))))

)
