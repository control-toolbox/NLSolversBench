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


# non linear solvers to bench
algos = [
    algo_nl(:MINPACK,:hybr),
    #algo_nl(:MINPACK,:lm), # to suited for non least square problems
    algo_nl(:NLsolve,:newton),
    algo_nl(:NLsolve,:trust_region),
    #algo_nl(:NLsolve,:anderson), # may be unstable if too far from the solution and don't finish/ raise error
    algo_nl(:NonlinearSolve,NewtonRaphson()), # may be unstable and raise exception
    #algo_nl(:NonlinearSolve,TrustRegion()), # does not work, surely because it's in wip
    #algo_nl(:NonlinearSolve,KINSOL()) # may be unstable if too far from the solution and don't finish
]

# list of the problems to bench the solvers on
problem_list_easy = [
    OCPProblem{(:exponential, :energy, :x_dim_1, :u_dim_1, :lagrange)}(abstol=1e-12,reltol=1e-12)
    OCPProblem{(:exponential, :consumption, :x_dim_1, :u_dim_1, :lagrange, :non_diff_wrt_u)}()
    OCPProblem{(:exponential, :time, :x_dim_1, :u_dim_1, :lagrange)}()
    OCPProblem{(:integrator, :energy, :free_final_time, :x_dim_1, :u_dim_1, :lagrange)}()
    OCPProblem{(:turnpike, :integrator, :state_energy, :x_dim_1, :u_dim_1, :lagrange, :u_cons, :singular_arc)}()
    OCPProblem{(:integrator, :energy, :x_dim_2, :u_dim_1, :lagrange, :noconstraints)}()
    OCPProblem{(:integrator, :energy, :x_dim_2, :u_dim_1, :lagrange, :u_cons)}() # ERROR: LoadError: Something went wrong. Integrator stepped past tstops but the algorithm was dtchangeable. Please report this error. with newton NLsolve
    OCPProblem{(:integrator, :energy, :distance, :x_dim_2, :u_dim_1, :bolza)}()
    OCPProblem{(:integrator, :energy, :x_dim_2, :u_dim_1, :lagrange, :x_cons, :order_2)}()
    OCPProblem{(:lqr, :x_dim_2, :u_dim_1, :lagrange)}()
    OCPProblem{(:integrator, :consumption, :x_dim_2, :u_dim_1, :lagrange, :u_cons, :non_diff_wrt_u)}()
]

# generate variations of the true solution for easy problems  
ξ_list_easy = Dict(pb => [generate_variation(pb.sol,0.1,10);generate_variation(pb.sol,0.5,10);generate_variation(pb.sol,2,10)] for pb in problem_list_easy)

rates_tol_easy,times_easy,df_rate_easy = compute_rate(algos,problem_list_easy,ξ_list_easy)

# plot rate vs relative error 
plot([10.0^(-i) for i = 10:-2:0],[rates_tol_easy[key] for key in collect(keys(rates_tol_easy))], label = reshape([shorten_label(string(key))*" in mean time "*string(times_easy[key][1]) for key in collect(keys(rates_tol_easy))],1,size(algos,1)))
plot!(xscale=:log10, yscale=:linear, title="Percentage of acceptable solution to relative error")
plot!(legend=:outerbottom)
savefig("build/bench_easy.svg")

# save the dataframe as csv (currently not used) 
CSV.write("build/df_rate_algo_easy.csv", df_rate_easy)

# create a pretty_table for the dataframe (colors does not work in md files)
h1 = Highlighter((df_rate_easy, i, j) -> j in [2,3,4,5] && df_rate_easy[i, j] == minimum(df_rate_easy[:, j]), bold = true, foreground = :red )
h2 = Highlighter((df_rate_easy, i, j) -> j in [2,3,4,5] && df_rate_easy[i, j] == maximum(df_rate_easy[:, j]), bold = true, foreground = :green )
pretty_table(String,df_rate_easy; tf = tf_markdown, alignment = :c, header = ["name"; [shorten_label(string(algo)) for algo = algos]],highlighters=(h1,h2))