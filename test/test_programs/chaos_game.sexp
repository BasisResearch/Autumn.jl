(program
    (= GRID_SIZE 60)

    (object Particle (Cell 0 0 "red"))

    (: particles_initial (List Particle))
    (= particles_initial (list (Particle (Position (/ GRID_SIZE 2) 0)) (Particle (Position 0 (- GRID_SIZE 1))) (Particle (Position (- GRID_SIZE 1) (- GRID_SIZE 1)))))
    (: particles (List Particle))
    (= particles (initnext (list (Particle (uniformChoice (rect (Position 0 0) (Position (- GRID_SIZE 1) (- GRID_SIZE 1))))))
        (prev particles)
    ))

    (on clicked (let
        ; Get the last particle from the initial list
        (= lastParticle (tail particles))
        (= lastPos (.. lastParticle origin))
        ; Randomly choose one of the initial particles
        (= randomParticle (uniformChoice particles_initial))
        (= randomPos (.. randomParticle origin))
        ; Get the midpoint between the last particle and the clicked position
        (= midpoint (Position (/ (+ (.. lastPos x) (.. randomPos x)) 2) (/ (+ (.. lastPos y) (.. randomPos y)) 2)))
        ; Add the midpoint to the particles
        (= particles (addObj particles (Particle midpoint)))
    ))
)