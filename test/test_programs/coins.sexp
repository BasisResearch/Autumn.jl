(program
  (= GRID_SIZE 16)
  
  (object Agent (Cell 0 0 "red"))
  (object Coin (Cell 0 0 "gold"))
  (object Bullet (Cell 0 0 "mediumpurple"))

  (: agent Agent)
  (= agent (initnext (Agent (Position 7 9)) (prev agent)))

  (: coins (List Coin))
  (= coins (initnext (map (--> pos (Coin pos)) (filter (--> p (& (== (% (.. p y) 2) 0) (== (% (.. p x) 2) 0))) (rect (Position 3 2) (Position 13 5)))) (prev coins)))

  (: bullets (List Bullet))
  (= bullets (initnext (list) (prev bullets)))
  
  (: numBullets Int)
  (= numBullets (initnext 0 (prev numBullets)))
  
  (on left (= agent (moveLeft agent)))
  (on right (= agent (moveRight agent)))
  (on up (= agent (moveUp agent)))
  (on down (= agent (moveDown agent)))

  (on true (= bullets (updateObj bullets (--> obj (moveUp (obj))))))
  
  (on (& ((clicked)) (> (prev numBullets) 0)) 
      (let (= numBullets (- (prev numBullets) 1)) 
            (= bullets (addObj bullets (Bullet (.. (prev agent) origin))))))  

  (on (intersects (prev agent) (prev coins)) 
      (let (= numBullets (+ (prev numBullets) 1)) 
            (= coins (removeObj coins (--> obj (intersects (obj) (prev agent)))))))
)
