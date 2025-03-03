(
    program
    (= GRID_SIZE 16)

    (object Card (: num Number) (: color String) (: shade String) (list (Cell -1 -2 "white") (Cell -1 -1 "white") (Cell -1 0 "white") (Cell -1 1 "white") (Cell -1 2 "white")
                                                    (Cell 0 -2 "white")  (Cell 0 -1 (if (>= num 1) then (* shade color) else "black")) (Cell 0 0 (if (>= num 2) then (* shade color) else "black")) (Cell 0 1 (if (== num 3) then (* shade color) else "black")) (Cell 0 2 "white")
                                                    (Cell 1 -2 "white") (Cell 1 -1 "white") (Cell 1 0 "white") (Cell 1 1 "white") (Cell 1 2 "white")))

    (: cards (List Card))
    (= cards (initnext (list
        (Card 1 "blue" "light" (Position 2 2)) (Card 2 "blue" "dark" (Position 6 2)) (Card 3 "blue" "" (Position 9 2)) 
    ) (prev cards)))
)