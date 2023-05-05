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
    #algo_nl(:NLsolve,:newton),
    algo_nl(:NLsolve,:trust_region),
    #algo_nl(:NLsolve,:anderson), # may be unstable if too far from the solution and don't finish/ raise error
    #algo_nl(:NonlinearSolve,NewtonRaphson()), # may be unstable and raise exception
    #algo_nl(:NonlinearSolve,TrustRegion()), # does not work, surely because it's in wip
    #algo_nl(:NonlinearSolve,KINSOL()) # may be unstable if too far from the solution and don't finish
]

### Hard problems
problem_list_hard = [
    OCPProblem{(:orbital_transfert, :energy, :x_dim_4, :u_dim_2, :lagrange)}() # Warning: Interrupted. Larger maxiters is needed. If you are using an integrator for non-stiff ODEs or an automatic switching algorithm (the default), you may want to consider using a method for stiff equations. See the solver pages for more details (e.g. https://docs.sciml.ai/DiffEqDocs/stable/solvers/ode_solve/#Stiff-Problems).
    OCPProblem{(:orbital_transfert, :consumption, :x_dim_4, :u_dim_2, :lagrange, :u_cons)}() # Warning: Interrupted. Larger maxiters is needed. If you are using an integrator for non-stiff ODEs or an automatic switching algorithm (the default), you may want to consider using a method for stiff equations. See the solver pages for more details (e.g. https://docs.sciml.ai/DiffEqDocs/stable/solvers/ode_solve/#Stiff-Problems).
    OCPProblem{(:orbital_transfert, :time, :x_dim_4, :u_dim_2, :mayer, :u_cons)}()
    #OCPProblem{(:goddard, :classical, :altitude, :x_dim_3, :u_dim_1, :mayer, :x_cons, :u_cons, :singular_arc)}() # Warning: dt(-8.804759669936376e-18) <= dtmin(1.3877787807814457e-17) at t=0.04188061327788384. Aborting. There is either an error in your model specification or the true solution is unstable. + error
]

# generate variations of the true solution for hard problems  
ξ_list_hard = Dict(pb => generate_variation(pb.sol,0.05,10) for pb in problem_list_hard)

rates_tol_hard,times_hard,df_rate_hard = compute_rate(algos,problem_list_hard,ξ_list_hard)

# plot rate vs relative error 
plot([10.0^(-i) for i = 10:-2:0],[rates_tol_hard[key] for key in collect(keys(rates_tol_hard))], label = reshape([shorten_label(string(key))*" in mean time "*string(times_hard[key][1]) for key in collect(keys(rates_tol_hard))],1,size(algos,1)))
plot!(xscale=:log10, yscale=:linear, title="Percentage of acceptable solution to relative error")
plot!(legend=:outerbottom)
savefig("build/bench_hard.svg")

# save the dataframe as csv (currently not used) 
CSV.write("build/df_rate_algo_hard.csv", df_rate_hard)

# create a pretty_table for the dataframe (colors does not work in md files)
h1 = Highlighter((df_rate_hard, i, j) -> j in [2,3,4,5] && df_rate_hard[i, j] == minimum(df_rate_hard[:, j]), bold = true, foreground = :red )
h2 = Highlighter((df_rate_hard, i, j) -> j in [2,3,4,5] && df_rate_hard[i, j] == maximum(df_rate_hard[:, j]), bold = true, foreground = :green )
pretty_table(String,df_rate_hard; tf = tf_markdown, alignment = :c, header = ["name"; [shorten_label(string(algo)) for algo = algos]],highlighters=(h1,h2))