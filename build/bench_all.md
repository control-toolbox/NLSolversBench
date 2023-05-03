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
include("bench_problems.jl")
include("bench_algo.jl")
algos = [algo_nl(:MINPACK, :hybr), algo_nl(:NLsolve, :newton), algo_nl(:NLsolve, :trust_region), algo_nl(:NonlinearSolve, NewtonRaphson())]
problem_list = [OCPProblem{(:exponential, :energy, :x_dim_1, :u_dim_1, :lagrange)}(); OCPProblem{(:exponential, :consumption, :x_dim_1, :u_dim_1, :lagrange, :non_diff_wrt_u)}(); OCPProblem{(:exponential, :time, :x_dim_1, :u_dim_1, :lagrange)}(); OCPProblem{(:integrator, :energy, :free_final_time, :x_dim_1, :u_dim_1, :lagrange)}(); OCPProblem{(:turnpike, :integrator, :state_energy, :x_dim_1, :u_dim_1, :lagrange, :u_cons, :singular_arc)}(); OCPProblem{(:integrator, :energy, :x_dim_2, :u_dim_1, :lagrange, :noconstraints)}(); OCPProblem{(:integrator, :energy, :distance, :x_dim_2, :u_dim_1, :bolza)}(); OCPProblem{(:integrator, :energy, :x_dim_2, :u_dim_1, :lagrange, :x_cons, :order_2)}()]
ξ_list = Dict((pb => [generate_variation(pb.sol, 0.5, 10); generate_variation(pb.sol, 2, 10); generate_variation(pb.sol, 10, 10)] for pb = problem_list))
(rates_tol, times, df_rate) = compute_rate(algos, problem_list, ξ_list)
plot([10.0 ^ -i for i = 10:-2:0], [rates_tol[key] for key = collect(keys(rates_tol))], label = reshape([shorten_label(string(key)) * " in mean time " * string(times[key]) for key = collect(keys(rates_tol))], 1, size(algos, 1)))
plot!(xscale = :log10, yscale = :linear, title = "Percentage of acceptable solution to relative error")
plot!(legend = :outerbottom)
$(Expr(:toplevel, :(savefig("build/bench_all.svg"))))
CSV.write("build/df_rate_algo.csv", df_rate)
h1 = Highlighter(((df_rate, i, j)->begin
                j in [2, 3, 4, 5] && df_rate[i, j] == minimum(df_rate[:, j])
            end), bold = true, foreground = :red)
h2 = Highlighter(((df_rate, i, j)->begin
                j in [2, 3, 4, 5] && df_rate[i, j] == maximum(df_rate[:, j])
            end), bold = true, foreground = :green)
pretty_table(String, df_rate; tf = tf_markdown, alignment = :c, header = ["name"; [shorten_label(string(algo)) for algo = algos]], highlighters = (h1, h2))
```

|                                  name                                  | algo_nl(:MINPACK, :hybr) | algo_nl(:NLsolve, :newton) | algo_nl(:NLsolve, :trust_region) | algo_nl(:NonlinearSolve, NewtonRaphson) |
|------------------------------------------------------------------------|--------------------------|----------------------------|----------------------------------|-----------------------------------------|
|                    simple exponential - energy min                     |         0.966667         |            1.0             |               1.0                |                   1.0                   |
|                     simple exponential - conso min                     |           0.9            |          0.966667          |               1.0                |                0.966667                 |
|                     simple exponential - time min                      |           1.0            |          0.933333          |               1.0                |                0.933333                 |
|                simple integrator - energy min - free tf                |         0.933333         |            1.0             |               1.0                |                   1.0                   |
|   simple nonsmooth turnpike - state energy min - affine system in u    |           1.0            |            1.0             |               1.0                |                   1.0                   |
|                Double integrator energy - minimise ∫ u²                |           1.0            |            1.0             |               1.0                |                   1.0                   |
|        Double integrator energy/distance - minimise -x₁ + ∫ u²         |           1.0            |            1.0             |               1.0                |                   1.0                   |
| Double integrator energy - mininimise ∫ u² under the constraint x₁ ≤ l |           0.7            |          0.966667          |             0.666667             |                0.933333                 |


