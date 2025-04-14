(program
    (= GRID_SIZE 12)

    (object Guess (: col Number) (Cell 0 0 (if (== col 0) then "grey" else (if (== col 1) then "red" else (if (== col 2) then "green" else (if (== col 3) then "blue" else (if (== col 4) then "yellow" else (if (== col 5) then "purple" else "orange"))))))))
    (object Button (Cell 0 0 "white"))
    (object Hint (: color String) (Cell 0 0 color))

    (: col_list (List Number))
    (= col_list (list 1 2 3 4 5 6))

    ;; modify removeObj in cpp version to get this function working
    ; (= gen_answer (fn (col_list) (let
    ;     (= answer1 (uniformChoice col_list))
    ;     (= col_list (removeObj col_list answer1))
    ;     (= answer2 (uniformChoice col_list))
    ;     (= col_list (removeObj col_list answer2))
    ;     (= answer3 (uniformChoice col_list))
    ;     (= col_list (removeObj col_list answer3))
    ;     (= answer4 (uniformChoice col_list))
    ;     (list answer1 answer2 answer3 answer4)
    ; )))
    (= gen_answer (fn (col_list) (uniformChoice col_list 4)))

    (: correct_answer (List Number))
    (= correct_answer (gen_answer col_list))

    (= is_correct (fn (guess) (== (map (--> o (.. o col)) guess) correct_answer)))

    (: enterButton Button)
    (= enterButton (initnext (Button (Position 0 0)) (prev enterButton)))

    (: curr_guess (List Guess))
    (= curr_guess (list (Guess 0 (Position 3 1)) (Guess 0 (Position 4 1)) (Guess 0 (Position 5 1)) (Guess 0 (Position 6 1))))

    (: prev_guesses (List Guess))
    (= prev_guesses (initnext (list ) (prev prev_guesses)))

    (: hints (List Hint))
    (= hints (initnext (list ) (prev hints)))

    (= create_hint (fn (guess) (let
    (= hintColor (fn (num_correct num_correct_and_position)
    (if (> num_correct 0) then (let 
        (= num_correct (- num_correct 1))
        (if (> num_correct_and_position 0) then (let 
            (= num_correct_and_position (- num_correct_and_position 1))
            "green"
        )
        else "yellow")
    )
    else "grey"
    )))
    (= num_correct (length (filter (--> o (in (.. o col) correct_answer)) guess)))
    (= num_correct_and_position (length (filter (--> o o) (arrayEqual (map (--> o (.. o col)) guess) correct_answer))))
    ; (= num_correct (- num_correct num_correct_and_position))
    (= positions (list (Position 8 1) (Position 9 1) (Position 8 2) (Position 9 2)))
    (= pos1 (uniformChoice positions))
    (= positions (removeObj positions pos1))
    (= pos2 (uniformChoice positions))
    (= positions (removeObj positions pos2))
    (= pos3 (uniformChoice positions))
    (= positions (removeObj positions pos3))
    (= pos4 (uniformChoice positions))
    ; find random position for each hint
    (list (Hint (hintColor num_correct num_correct_and_position) pos1) (Hint (hintColor num_correct num_correct_and_position) pos2) (Hint (hintColor num_correct num_correct_and_position) pos3) (Hint (hintColor num_correct num_correct_and_position) pos4))
    )))

    (on (clicked curr_guess) (= curr_guess 
    (updateObj 
    curr_guess 
    (--> obj (updateObj obj "col" (% (+ (.. obj col) 1) 6)))
    (--> obj (== (.. obj origin) (Position (.. click x) (.. click y))))
    )))

    ;; Preferred way to do this, but `all` not supported
    ; (on (& (clicked enterButton) (all (map (--> o (> (.. o col) 0)) curr_guess))) (let
    (on (clicked enterButton) (let
    (print correct_answer)
    (= prev_guesses (vcat (map (--> cg (addObj (prev prev_guesses) cg)) (prev curr_guess))))
    (= hints (map (--> h (moveDown h)) hints))
    (= hints (map (--> h (moveDown h)) hints))
    (= prev_guesses (map (--> o (moveDown o)) prev_guesses))
    (= prev_guesses (map (--> o (moveDown o)) prev_guesses))
    (= hints (vcat (map (--> cg (addObj (prev hints) cg)) (create_hint (prev curr_guess)))))
    (= curr_guess (list (Guess 0 (Position 3 1)) (Guess 0 (Position 4 1)) (Guess 0 (Position 5 1)) (Guess 0 (Position 6 1))))
    )) 
)
