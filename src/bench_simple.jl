include("bench_problems.jl")

pb1 = OCPProblem{(:exponential, :energy, :state_dim_1, :control_dim_1, :lagrange)}()

@benchmark solve_generic(pb1.shoot!, pb1.sol, :MINPACK, :hybr)

@benchmark solve_generic(pb1.shoot!, pb1.sol, :MINPACK, :lm)

@benchmark solve_generic(pb1.shoot!, pb1.sol, :NLsolve, :anderson)