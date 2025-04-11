(program
  (= GRID_SIZE 10)
  (: COLORS (List String))
  (= COLORS (list "red" "blue" "green" "yellow" "purple"))

  (object Ball (: color String) (Cell 0 0 color))

  (: balls (List Ball))
  (= balls (initnext (list (Ball "red" (Position 0 0)) (Ball "blue" (Position 4 5)) (Ball "green" (Position 7 8))) (prev balls)))
  
  (: activePos Position)
  (= activePos (initnext (Position 0 0) (prev activePos)))

  (on (clicked balls) (= activePos (Position (.. click x) (.. click y))))
  
  (on (& ((clicked)) (isFreePos click)) 
      (= balls (addObj balls (Ball (uniformChoice COLORS) (head (randomPositions GRID_SIZE 1))))))

  (on (& ((clicked)) (isFreePos click)) (let
    (= ball (head (filter (--> b (== (.. b origin) activePos)) balls)))
    (= ball (move ball (unitVector ball (Position (.. click x) (.. click y)))))))

)
