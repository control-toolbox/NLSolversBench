# NLSolversBench
Benchmark of Julia solvers for nonlinear equations for the control-toolbox

To run the basic benchmark run [```bench_run.jl```](bench_run.jl).

The results files are in the [```build```](build) folder.
For each benchmark file there is markdown file with the results.

For [```bench_all.jl```](src/bench_all.jl) the generated files are : 
- [```bench_all.md```](build/bench_all.md) : the relevant code and result for the benchmark of non-linear method solvers (includes the graph and the table).
- [```bench_all.svg```](build/bench_all.svg) : a graph showing the percentage of acceptable solution to relative error
- [```df_rate_algo.csv```](build/df_rate_algo.csv) : a table generated directly by [```bench_all.jl```](src/bench_all.jl) with the solving success for a specific relative error vs a solver and an optimal control problem

For a more extensive look about solvers please see [```existing_solvers.md```](existing_solvers.md). 
By looking at the table, a better solver than ```minpack hybr``` could be the solver of ```NLsolve.jl``` with the ```trust region``` algorithm.