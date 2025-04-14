(program
    (= GRID_SIZE 16)

    ;; Define a Particle object that can move randomly
    (object Particle (Cell 0 0 "blue"))

    ;; Track the number of clicks
    (: click_count Number)
    (= click_count 0)

    ;; List to store all particles
    (: particles (List Particle))

    (: create_particles (fn (n)
        (if (== n 0)
            then (list (Particle (Position (.. click x) (.. click y))))
            else (concat (create_particles (- n 1)) (create_particles (- n 1))))))

    ;; Update particles to move randomly
    (= particles (initnext (list) 
        (updateObj (prev particles) 
            (--> obj (Particle (uniformChoice (adjPositions (.. obj origin))))))))

    ;; On click, create 2^n new particles where n is the current click count
    (on clicked (= click_count (+ (prev click_count) 1)))
    (on clicked (= particles (concat (prev particles) (create_particles (prev click_count) (Position (.. click x) (.. click y))))))
)

