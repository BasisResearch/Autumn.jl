(program
    (= GRID_SIZE 16)

    (object Particle (Cell 0 0 "blue"))

    (: click_count Number)
    (= click_count 0)

    (: particles (List Particle))
    (= particles (initnext (list) 
        (updateObj (prev particles) 
            (--> obj (Particle (uniformChoice (adjPositions (.. obj origin))))))))

    (= create_particles (fn (n)
        (if (== n 0)
            then (list (Particle (Position (.. click x) (.. click y))))
            else (concat (list (create_particles (- n 1)) (create_particles (- n 1)))))))

    (on clicked (= click_count (+ (prev click_count) 1)))
    (on clicked (= particles (concat (list (prev particles) (create_particles (prev click_count) (Position (.. click x) (.. click y)))))))
)

