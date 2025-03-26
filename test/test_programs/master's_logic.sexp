(program
    (= GRID_SIZE 12)

    (object Guess (: col Number) (Cell 0 0 (if (== col 0) then "grey" else (if (== col 1) then "red" else (if (== col 2) then "green" else (if (== col 3) then "blue" else (if (== col 4) then "yellow" else (if (== col 5) then "purple" else "orange"))))))))
    (object Button (Cell 0 0 "white"))
    (object Hint (: color String) (Cell 0 0 color))

    (: col_list (List Number))
    (= col_list (list 1 2 3 4 5 6))

    ; (= gen_answer (fn (col_list) (let
    ;     (= answer1 (uniformChoice col_list))
    ;     (= col_list (removeObj col_list (--> n (== n answer1))))
    ;     (= answer2 (uniformChoice col_list))
    ;     (= col_list (removeObj col_list (--> n (== n answer2))))
    ;     (= answer3 (uniformChoice col_list))
    ;     (= col_list (removeObj col_list (--> n (== n answer3))))
    ;     (= answer4 (uniformChoice col_list))
    ;     (= col_list (removeObj col_list (--> n (== n answer4))))
    ;     (list answer1 answer2 answer3 answer4)
    ; )))
    (= gen_answer (fn (col_list) (uniformChoice col_list 4)))

    (: correct_answer (List Number))
    (= correct_answer (gen_answer col_list))

    (= is_correct (fn (guess) (== (map (--> o (.. o col)) guess) correct_answer)))

    (: enterButton Button)
    (= enterButton (initnext (Button (Position 0 0)) (prev enterButton)))

    (: curr_guess (List Guess))
    (= curr_guess (list (Guess 0 (Position 4 1)) (Guess 0 (Position 5 1)) (Guess 0 (Position 6 1)) (Guess 0 (Position 7 1))))

    (: prev_guesses (List Guess))
    (= prev_guesses (initnext (list ) (prev prev_guesses)))

    (: hints (List Hint))
    (= hints (initnext (list ) (prev hints)))

    (= create_hint (fn (guess) (let
    (= num_correct (length (filter (--> o (in (.. o col) correct_answer)) guess)))
    ; (= num_correct_and_position (length (filter (--> o (== o (.. guess col))) (map (--> o (.. o col)) correct_answer))))
    ; (print num_correct_and_position)
    (list (Hint "black" (Position 0 0)) (Hint "black" (Position 1 0)) (Hint "black" (Position 0 1)) (Hint "black" (Position 1 1)))
    )))

    (on (clicked curr_guess) (= curr_guess 
    (updateObj 
    curr_guess 
    (--> obj (updateObj obj "col" (% (+ (.. obj col) 1) 6)))
    (--> obj (== (.. obj origin) (Position (.. click x) (.. click y))))
    )))

    (on (& (clicked enterButton) (all (map (--> o (> (.. o col) 0)) curr_guess))) (let
    (= prev_guesses (vcat (map (--> cg (addObj (prev prev_guesses) cg)) (prev curr_guess))))
    (= prev_guesses (map (--> o (moveDown o)) prev_guesses))
    (= prev_guesses (map (--> o (moveDown o)) prev_guesses))
    (if (is_correct curr_guess) then ( let
    (print "correct")
    ) else ( let
    (print "not correct")
    ))
    (= hints (vcat (map (--> cg (addObj (prev hints) cg)) (create_hint curr_guess))))
    (= curr_guess (list (Guess 0 (Position 4 1)) (Guess 0 (Position 5 1)) (Guess 0 (Position 6 1)) (Guess 0 (Position 7 1))))
    ))
)
