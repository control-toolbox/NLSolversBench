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

include("bench_problems.jl")
include("bench_algo.jl")

algos = [
    algo_nl(:MINPACK,:hybr),
    algo_nl(:MINPACK,:lm),
    algo_nl(:NLsolve,:newton),
    algo_nl(:NLsolve,:trust_region),
    algo_nl(:NLsolve,:anderson)
]
problem_list = [
    OCPProblem{(:exponential, :energy, :state_dim_1, :control_dim_1, :lagrange)}()
    OCPProblem{(:integrator, :energy, :state_dim_2, :control_dim_1, :lagrange)}()
    OCPProblem{(:turnpike, :integrator, :state_energy, :state_dim_1, :control_dim_1, :lagrange, :control_constraint, :singular_arc)}()
    #OCPProblem{(:goddard, :classical, :altitude, :state_dim_3, :control_dim_1, :mayer, :state_constraint, :control_constraint, :singular_arc)}()
]


ξ_list = Dict(pb => generate_variation(pb.sol,1) for pb in problem_list)


function compute_rate()
    rate = Dict() 
    for algo in algos
        success = [0 for i = 0:2:10]
        for pb in problem_list
            for ξ_guess in ξ_list[pb]
                res = solve_generic(pb.shoot!,ξ_guess,algo.package,algo.name)
                E_rel = (norm(res.x) - norm(pb.sol))/norm(pb.sol)
                success = success + [E_rel ≤ 10.0^(-i) for i = 10:-2:0]
            end
        end
        rate[algo] = success./(size(problem_list).*size(collect(values(ξ_list))[1],1))
    end
    return rate
end

rates = compute_rate()
println([string(key) for key in collect(keys(rates))])
plot([10.0^(-i) for i = 10:-2:0],[rates[key] for key in collect(keys(rates))], label = reshape([string(key) for key in collect(keys(rates))],1,size(algos,1)))
plot!(xscale=:log10, yscale=:linear)