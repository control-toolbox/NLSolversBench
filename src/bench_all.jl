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
problem_list = [
    # OCPProblem{(:exponential, :energy, :x_dim_1, :u_dim_1, :lagrange)}(abstol=1e-12,reltol=1e-12)
    # OCPProblem{(:exponential, :consumption, :x_dim_1, :u_dim_1, :lagrange, :non_diff_wrt_u)}()
    # OCPProblem{(:exponential, :time, :x_dim_1, :u_dim_1, :lagrange)}()
    # OCPProblem{(:integrator, :energy, :free_final_time, :x_dim_1, :u_dim_1, :lagrange)}()
    # OCPProblem{(:turnpike, :integrator, :state_energy, :x_dim_1, :u_dim_1, :lagrange, :u_cons, :singular_arc)}()
    # OCPProblem{(:integrator, :energy, :x_dim_2, :u_dim_1, :lagrange, :noconstraints)}()
    # OCPProblem{(:integrator, :energy, :x_dim_2, :u_dim_1, :lagrange, :u_cons)}() # ERROR: LoadError: Something went wrong. Integrator stepped past tstops but the algorithm was dtchangeable. Please report this error. with newton NLsolve
    # #OCPProblem{(:goddard, :classical, :altitude, :x_dim_3, :u_dim_1, :mayer, :x_cons, :u_cons, :singular_arc)}() # Warning: dt(-8.804759669936376e-18) <= dtmin(1.3877787807814457e-17) at t=0.04188061327788384. Aborting. There is either an error in your model specification or the true solution is unstable. + error
    #OCPProblem{(:integrator, :energy, :distance, :x_dim_2, :u_dim_1, :bolza)}()
    #OCPProblem{(:orbital_transfert, :energy, :x_dim_4, :u_dim_2, :lagrange)}() # Warning: Interrupted. Larger maxiters is needed. If you are using an integrator for non-stiff ODEs or an automatic switching algorithm (the default), you may want to consider using a method for stiff equations. See the solver pages for more details (e.g. https://docs.sciml.ai/DiffEqDocs/stable/solvers/ode_solve/#Stiff-Problems).
    OCPProblem{(:orbital_transfert, :consumption, :x_dim_4, :u_dim_2, :lagrange, :u_cons)}() # Warning: Interrupted. Larger maxiters is needed. If you are using an integrator for non-stiff ODEs or an automatic switching algorithm (the default), you may want to consider using a method for stiff equations. See the solver pages for more details (e.g. https://docs.sciml.ai/DiffEqDocs/stable/solvers/ode_solve/#Stiff-Problems).
    #OCPProblem{(:orbital_transfert, :time, :x_dim_4, :u_dim_2, :mayer, :u_cons)}()
    #OCPProblem{(:integrator, :energy, :x_dim_2, :u_dim_1, :lagrange, :x_cons, :order_2)}()
    #OCPProblem{(:lqr, :x_dim_2, :u_dim_1, :lagrange)}()
    #OCPProblem{(:integrator, :consumption, :x_dim_2, :u_dim_1, :lagrange, :u_cons, :non_diff_wrt_u)}()
]

# generate variations of the true solution for each problem  
ξ_list = Dict(pb => generate_variation(pb.sol,0,10) for pb in problem_list) #generate_variation(pb.sol,0.1,10);generate_variation(pb.sol,0.5,10);generate_variation(pb.sol,2,10)

# function that iterate over the problems, algos and variations to solve the non linear problem
# return rate_tol, time_elapsed and df_rate 
function compute_rate(algos,problem_list,ξ_list)
    rate_tol = Dict()
    time_elapsed = Dict() 
    df_rate = DataFrame()
    
    df_rate.name = [problem.title for problem in problem_list]

    for algo in algos
        println("Using algo : ", algo)
        success = [0 for i = 0:2:10]
        time_spent = 0
        temp_rate = zeros(0)
        for pb in problem_list
            println("           with problem : ", pb.title)
            acc = 0
            iter = ProgressBar(1:size(collect(values(ξ_list))[1],1))
            for i in iter
                ξ_guess = ξ_list[pb][i]
                
                time_spent += @elapsed (res = solve_generic(pb.shoot,ξ_guess,algo.package,algo.name,100))
                
                E_rel = (norm(res.x) - norm(pb.sol))/norm(pb.sol)
                E_tab = [E_rel ≤ 10.0^(-i) for i = 10:-2:0]
                success = success + E_tab
                acc = acc + E_tab[5]
            end
            append!(temp_rate,acc/size(collect(values(ξ_list))[1],1))
        end

        nb_it = (size(problem_list).*size(collect(values(ξ_list))[1],1))
        rate_tol[algo] = round.(success./nb_it;digits=2)
        time_elapsed[algo] = time_spent[1]./nb_it 

        df_rate[:,shorten_label(string(algo))] = temp_rate

    end

    # adding the mean for each algorithm
    push!(df_rate,["mean"; mean.(eachcol(df_rate[:,2:end]))])

    return rate_tol,time_elapsed,df_rate
end

rates_tol,times,df_rate = compute_rate(algos,problem_list,ξ_list)

# plot rate vs relative error 
plot([10.0^(-i) for i = 10:-2:0],[rates_tol[key] for key in collect(keys(rates_tol))], label = reshape([shorten_label(string(key))*" in mean time "*string(times[key][1]) for key in collect(keys(rates_tol))],1,size(algos,1)))
plot!(xscale=:log10, yscale=:linear, title="Percentage of acceptable solution to relative error")
plot!(legend=:outerbottom)
#savefig("build/bench_all.svg")

# save the dataframe as csv (currently not used) 
#CSV.write("build/df_rate_algo.csv", df_rate)

# create a pretty_table for the dataframe (colors does not work in md files)
h1 = Highlighter((df_rate, i, j) -> j in [2,3,4,5] && df_rate[i, j] == minimum(df_rate[:, j]), bold = true, foreground = :red )
h2 = Highlighter((df_rate, i, j) -> j in [2,3,4,5] && df_rate[i, j] == maximum(df_rate[:, j]), bold = true, foreground = :green )
pretty_table(String,df_rate; tf = tf_markdown, alignment = :c, header = ["name"; [shorten_label(string(algo)) for algo = algos]],highlighters=(h1,h2))