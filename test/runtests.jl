include("interpret.jl")

# Test all the functions in test_programs folder
function test_program_file(filename)
    println("Testing program: $filename")
    program_path = joinpath(@__DIR__, "test_programs", filename)
    
    # Read the program file
    program_str = read(program_path, String)
    
    # Parse the program
    program = Autumn.parseautumn(program_str)

    n = 10
    
    # Create random user events for n timesteps
    user_events = []
    for _ in 1:n
        # Randomly decide which actions to take
        click_pos = rand(0:15), rand(0:15)
        event = rand([
            (click = Autumn.AutumnStandardLibrary.Click(click_pos...),),
            (left = true,),
            (right = true,),
            (up = true,),
            (down = true,),
            empty_env()
        ])
        push!(user_events, event)
    end
    
    # Run the program for 3 timesteps
    try
        env = interpret_over_time(program, n, user_events)
        return true
    catch e
        println("Error running program $filename: ")
        showerror(stdout, e)
        println()
        return false
    end
end

@testset "test_programs" begin
    # Get all .sexp files in the test_programs directory
    test_dir = joinpath(@__DIR__, "test_programs")
    program_files = filter(f -> endswith(f, ".sexp"), readdir(test_dir))
    
    for file in program_files
        @test test_program_file(file)
    end
end
