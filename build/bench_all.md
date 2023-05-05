# Benchmarks for bench_all.jl

```julia
using Pkg
using CTProblems
using MINPACK
using NLsolve
using BenchmarkTools
using CTFlows
using MLStyle
using MacroTools
using LinearAlgebra
using Plots
using CTBase
using ProgressBars
using NonlinearSolve
using Sundials
using DataFrames
using CSV
using PrettyTables
using ForwardDiff
include("bench_problems.jl")
include("bench_algo.jl")
algos = [algo_nl(:MINPACK, :hybr), algo_nl(:NLsolve, :newton), algo_nl(:NLsolve, :trust_region), algo_nl(:NonlinearSolve, NewtonRaphson())]
problem_list = [OCPProblem{(:orbital_transfert, :consumption, :x_dim_4, :u_dim_2, :lagrange, :u_cons)}()]
ξ_list = Dict((pb => generate_variation(pb.sol, 0.5, 10) for pb = problem_list))
(rates_tol, times, df_rate) = compute_rate(algos, problem_list, ξ_list)
plot([10.0 ^ -i for i = 10:-2:0], [rates_tol[key] for key = collect(keys(rates_tol))], label = reshape([shorten_label(string(key)) * " in mean time " * string((times[key])[1]) for key = collect(keys(rates_tol))], 1, size(algos, 1)))
plot!(xscale = :log10, yscale = :linear, title = "Percentage of acceptable solution to relative error")
plot!(legend = :outerbottom)
savefig("build/bench_all.svg")
```
 ![fig](bench_all.svg) 
 ```julia 
CSV.write("build/df_rate_algo.csv", df_rate)
h1 = Highlighter(((df_rate, i, j)->begin
                j in [2, 3, 4, 5] && df_rate[i, j] == minimum(df_rate[:, j])
            end), bold = true, foreground = :red)
h2 = Highlighter(((df_rate, i, j)->begin
                j in [2, 3, 4, 5] && df_rate[i, j] == maximum(df_rate[:, j])
            end), bold = true, foreground = :green)
pretty_table(String, df_rate; tf = tf_markdown, alignment = :c, header = ["name"; [shorten_label(string(algo)) for algo = algos]], highlighters = (h1, h2))
```

|                           name                           | algo_nl(:MINPACK, :hybr) | algo_nl(:NLsolve, :newton) | algo_nl(:NLsolve, :trust_region) | algo_nl(:NonlinearSolve, NewtonRaphson) |
|----------------------------------------------------------|--------------------------|----------------------------|----------------------------------|-----------------------------------------|
| Orbital transfert - consumption minimisation - ∫ ‖u‖ dt  |           0.7            |            0.3             |               0.4                |                   0.3                   |
|                           mean                           |           0.7            |            0.3             |               0.4                |                   0.3                   |


