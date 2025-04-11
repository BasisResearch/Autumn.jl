(program
    (= GRID_SIZE 17)

    (object Tree (: color String) (: height Number) 
            (map 
             (--> pos (Cell (.. pos x) (.. pos y) color)) 
             (rect (Position 0 0) (Position 0 height)) 
            )
    )



    

)