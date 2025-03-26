(program
    (= GRID_SIZE 7)

    (object Button (Cell 0 0 "grey"))
    
    (object PoisonedBlock (: game_over Bool) (Cell 0 0 (if game_over then "black" else "red")))
    (object Block (: selected Bool) (: game_over Bool) (Cell 0 0 (if selected then "yellow" else (if game_over then "black" else "orange"))))
    
    (: poisoned_block PoisonedBlock)
    (= poisoned_block (initnext (PoisonedBlock false(Position 1 1)) (prev "poisoned_block")))

    (: removeButton Button)
    (= removeButton (initnext (Button (Position 0 0)) (prev "removeButton")))
    
    (: blocks (List Block))
    (= blocks (initnext (map (--> pos (Block false false pos)) (list 
                   (Position 1 2) (Position 1 3) (Position 1 4)
        (Position 2 1) (Position 2 2) (Position 2 3) (Position 2 4)
        (Position 3 1) (Position 3 2) (Position 3 3) (Position 3 4)
        (Position 4 1) (Position 4 2) (Position 4 3) (Position 4 4)
        (Position 5 1) (Position 5 2) (Position 5 3) (Position 5 4)

        )) (prev "blocks")))

    ; Set all blocks to black when poisoned block is clicked
    (on (clicked poisoned_block) (= blocks (updateObj blocks (--> b (updateObj b "game_over" true)))))
    (on (clicked poisoned_block) (= poisoned_block (updateObj poisoned_block "game_over" true)))

    ; Set block to selected when clicked if not game over
    (on (& (clicked blocks) (! (.. poisoned_block game_over)))
    (= blocks 
    (updateObj 
    blocks 
    (--> b (updateObj b "selected" true))
    (--> b (== (.. b origin) (Position (.. click x) (.. click y))))
    )))

    ; Remove all selected blocks when clicked
    (on (clicked removeButton) (= blocks (removeObj blocks (--> b (.. b selected)))))
    
)