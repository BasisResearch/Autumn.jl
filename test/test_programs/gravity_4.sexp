(program
  (= GRID_SIZE 100)
    
  (object Button (: color String) (Cell 0 0 color))
  (object Blob (list (Cell 0 -1 "black") (Cell 0 0 "black") (Cell 1 -1 "black") (Cell 1 0 "black")))
  
  (: buttons (List Button))
  (= buttons (initnext (list (Button "red" (Position 4 0)) 
              (Button "gold" (Position 8 0))                             
              (Button "darkorange" (Position 12 0))
                        
              (Button "lightgreen" (Position (- GRID_SIZE 1) 4))
                            (Button "green" (Position (- GRID_SIZE 1) 8))
                            (Button "lightseagreen" (Position (- GRID_SIZE 1) 12))
                            
                            (Button "lightblue" (Position 4 (- GRID_SIZE 1)))
                            (Button "blue" (Position 8 (- GRID_SIZE 1)))
                            
  
                        ) (prev buttons)))
  
  (: blobs (List Blob))
  (= blobs (initnext (list) (prev blobs)))
  
  (: gravity String)
  (= gravity (initnext "rr" (prev "gravity")))
                                                                    
  (on (== gravity "ul") (= blobs (updateObj (prev blobs) (--> obj (move obj (Position -1 -2))))))
  (on (== gravity "uu") (= blobs (updateObj (prev blobs) (--> obj (move obj (Position 0 -2))))))
  (on (== gravity "ur") (= blobs (updateObj (prev blobs) (--> obj (move obj (Position 1 -2))))))
  
  (on (== gravity "ru") (= blobs (updateObj (prev blobs) (--> obj (move obj (Position 2 -1))))))
  (on (== gravity "rr") (= blobs (updateObj (prev blobs) (--> obj (move obj (Position 2 0))))))
  (on (== gravity "rd") (= blobs (updateObj (prev blobs) (--> obj (move obj (Position 2 1))))))
  
  (on (== gravity "dl") (= blobs (updateObj (prev blobs) (--> obj (move obj (Position -1 2))))))
  (on (== gravity "dd") (= blobs (updateObj (prev blobs) (--> obj (move obj (Position 0 2))))))
  
  
  (on (clicked (filter (--> obj (== (.. obj color) "red")) (prev buttons))) (= gravity "ul"))
  (on (clicked (filter (--> obj (== (.. obj color) "gold")) (prev buttons))) (= gravity "uu"))
  (on (clicked (filter (--> obj (== (.. obj color) "darkorange")) (prev buttons))) (= gravity "ur"))
  
  (on (clicked (filter (--> obj (== (.. obj color) "lightgreen")) (prev buttons))) (= gravity "ru"))
  (on (clicked (filter (--> obj (== (.. obj color) "green")) (prev buttons))) (= gravity "rr"))
  (on (clicked (filter (--> obj (== (.. obj color) "lightseagreen")) (prev buttons))) (= gravity "rd"))
  
  (on (clicked (filter (--> obj (== (.. obj color) "lightblue")) (prev buttons))) (= gravity "dl"))
  (on (clicked (filter (--> obj (== (.. obj color) "blue")) (prev buttons))) (= gravity "dd"))
  
  (on (& clicked (isFreePos click)) (= blobs (addObj blobs (Blob (Position (.. click x) (.. click y))))))
)
