(program
  (= GRID_SIZE 30)
    
  (object Button (: color String) (Cell 0 0 color))
  (object Blob (: color String) (list (Cell 0 -1 color) (Cell 0 0 color) (Cell 1 -1 color) (Cell 1 0 color)))
  
  (: leftButton Button)
  (= leftButton (initnext (Button "red" (Position 0 14)) (prev leftButton)))
  
  (: rightButton Button)
  (= rightButton (initnext (Button "darkorange" (Position 29 14)) (prev rightButton)))
    
  (: upButton Button)
  (= upButton (initnext (Button "gold" (Position 14 0)) (prev upButton)))
  
  (: downButton Button)
  (= downButton (initnext (Button "green" (Position 14 29)) (prev downButton)))
  
  (: blobs (List Blob))
  (= blobs (initnext (list) (prev blobs)))
  
  (: gravity String)
  (= gravity (initnext "down" (prev "gravity")))
  
  (: blobColor Number)
  (= blobColor (initnext 0 (prev blobColor)))
  
  (on (== gravity "left") (= blobs (updateObj (prev blobs) (--> obj (moveLeft obj)))))
  (on (== gravity "right") (= blobs (updateObj (prev blobs) (--> obj (moveRight obj)))))
  (on (== gravity "up") (= blobs (updateObj (prev blobs) (--> obj (moveUp obj)))))
  (on (== gravity "down") (= blobs (updateObj (prev blobs) (--> obj (moveDown obj)))))
  
  (on (& ((clicked)) (isFreePos click)) (= blobColor (% (+ (prev blobColor) 1) 3)))
  (on (& (& ((clicked)) (isFreePos click)) (== blobColor 0)) (= blobs (addObj blobs (Blob "blue" (Position (.. click x) (.. click y))))))
  (on (& (& ((clicked)) (isFreePos click)) (== blobColor 1)) (= blobs (addObj blobs (Blob "mediumpurple" (Position (.. click x) (.. click y))))))
  (on (& (& ((clicked)) (isFreePos click)) (== blobColor 2)) (= blobs (addObj blobs (Blob "magenta" (Position (.. click x) (.. click y))))))
  
  (on (clicked leftButton) (= gravity "left"))
  
  (on (clicked rightButton) (= gravity "right"))
  
  (on (clicked upButton) (= gravity "up"))
  
  (on (clicked downButton) (= gravity "down"))
)
