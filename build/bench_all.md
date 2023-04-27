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
problem_list = [OCPProblem{(:exponential, :energy, :state_dim_1, :control_dim_1, :lagrange)}(); OCPProblem{(:exponential, :time, :state_dim_1, :control_dim_1, :lagrange)}(); OCPProblem{(:integrator, :energy, :free_final_time, :state_dim_1, :control_dim_1, :lagrange)}(); OCPProblem{(:turnpike, :integrator, :state_energy, :state_dim_1, :control_dim_1, :lagrange, :control_constraint, :singular_arc)}(); OCPProblem{(:integrator, :energy, :state_dim_2, :control_dim_1, :lagrange, :noconstraints)}(); OCPProblem{(:integrator, :energy, :distance, :state_dim_2, :control_dim_1, :bolza)}()]
ξ_list = Dict((pb => generate_variation(pb.sol, 3, 10) for pb = problem_list))
function compute_rate(algos, problem_list, ξ_list)
    rate_tol = Dict()
    time_elapsed = Dict()
    df_rate = DataFrame()
    df_rate.name = [problem.title for problem = problem_list]
    for algo = algos
        println("Using algo : ", algo)
        success = [0 for i = 0:2:10]
        time = 0
        temp_rate = zeros(0)
        for pb = problem_list
            println("           with problem : ", pb.title)
            acc = 0
            iter = ProgressBar(1:size((collect(values(ξ_list)))[1], 1))
            for i = iter
                ξ_guess = (ξ_list[pb])[i]
                time += @elapsed(res = solve_generic(pb.shoot, ξ_guess, algo.package, algo.name))
                E_rel = (norm(res.x) - norm(pb.sol)) / norm(pb.sol)
                E_tab = [E_rel ≤ 10.0 ^ -i for i = 10:-2:0]
                success = success + E_tab
                acc = acc + E_tab[2]
            end
            append!(temp_rate, acc / size((collect(values(ξ_list)))[1], 1))
        end
        nb_it = size(problem_list) .* size((collect(values(ξ_list)))[1], 1)
        rate_tol[algo] = success ./ nb_it
        time_elapsed[algo] = time ./ nb_it
        df_rate[:, shorten_label(string(algo))] = temp_rate
    end
    return (rate_tol, time_elapsed, df_rate)
end
(rates_tol, times, df_rate) = compute_rate(algos, problem_list, ξ_list)
println([string(key) for key = collect(keys(rates_tol))])
plot([10.0 ^ -i for i = 10:-2:0], [rates_tol[key] for key = collect(keys(rates_tol))], label = reshape([shorten_label(string(key)) * " in mean time " * string(times[key]) for key = collect(keys(rates_tol))], 1, size(algos, 1)))
plot!(xscale = :log10, yscale = :linear)
plot!(legend = :outerbottom)
savefig("build/bench_all.svg")
```
 ![fig](bench_all.svg) 
 ```julia 
CSV.write("build/df_rate_algo.csv", df_rate)
pretty_table(String, df_rate; tf = tf_markdown, alignment = :c, header = ["name"; [shorten_label(string(algo)) for algo = algos]])
pretty_table(String, df_rate; tf = tf_markdown, alignment = :c, header = ["name"; [shorten_label(string(algo)) for algo = algos]])
```

|                               name                                | algo_nl(:MINPACK, :hybr) | algo_nl(:NLsolve, :newton) | algo_nl(:NLsolve, :trust_region) | algo_nl(:NonlinearSolve, NewtonRaphson) |
|-------------------------------------------------------------------|--------------------------|----------------------------|----------------------------------|-----------------------------------------|
|                  simple exponential - energy min                  |           1.0            |            1.0             |               1.0                |                   1.0                   |
|                   simple exponential - time min                   |           1.0            |            1.0             |               1.0                |                   1.0                   |
|             simple integrator - energy min - free tf              |           0.8            |            1.0             |               0.8                |                   1.0                   |
| simple nonsmooth turnpike - state energy min - affine system in u |           1.0            |            1.0             |               1.0                |                   1.0                   |
|             Double integrator energy - minimise ∫ u²              |           1.0            |            1.0             |               1.0                |                   1.0                   |
|      Double integrator energy/distance - minimise -x₁ + ∫ u²      |           1.0            |            1.0             |               1.0                |                   1.0                   |

