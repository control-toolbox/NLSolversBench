struct sol_shoot
    x::Vector{<:Real}
    converged::Bool
end

function solve_generic(shoot, ξ, lib, algo, maxit)
    
    isreal = ξ isa Real

    shoot!(s, ξ) = ( s[:] = shoot(ξ); nothing)
    jshoot(ξ) = ForwardDiff.jacobian(shoot, ξ)
    jshoot!(js, ξ) = ( js[:] = jshoot(ξ); nothing )
    
    shoot_p(ξ,p) = shoot(ξ)
    jshoot_p(ξ,p) = jshoot(ξ)

    try
        MLStyle.@match lib begin
            :MINPACK => begin
                            shoot_sol = fsolve(shoot!, jshoot!, ξ, show_trace=false, method=algo, tol=1e-8, iterations=maxit)
                            return(sol_shoot(shoot_sol.x, shoot_sol.converged))
                        end
            :NLsolve => begin
                            shoot_sol = nlsolve(shoot!, jshoot!, ξ, xtol=1e-8, show_trace=false, method=algo, iterations=maxit)
                            return(sol_shoot(shoot_sol.zero, shoot_sol.x_converged))
                        end
            :NonlinearSolve => begin
                            nlf = NonlinearFunction(shoot_p;jac=jshoot_p)
                            shoot_sol = solve(NonlinearProblem(nlf, ξ, 0),algo,abstol=1e-8,maxiters=maxit)
                            return(sol_shoot(Vector{Float64}(vec(shoot_sol)), true))
                        end
            _ => return(sol_shoot(ξ,false))
        end
    catch e
        println(e)
        println("Error while solving with ", lib, " ", algo, " ")
        return(sol_shoot(ξ,false))
    end
end

struct OCPProblem{description}
    function OCPProblem{description}() where {description}
        throw(NonExistingProblem(description))
    end
end

struct OCPShoot
    sol::Union{<:Real,Vector{<:Real}}
    shoot::Function
    title::String
end

function ProblemSh(description...) 
    return OCPProblem{description}()
end


using Random
using Distributions

Random.seed!(248)
function generate_variation(ξ,σ,n)
    d = Uniform(-1,1)
    ξ_var = [([ σ*(abs(el)>0.5 ? el : 0.5)*rand(d) for el in ξ] .+ ξ) for i = 1:n]
    return (ξ_var)
end




function shorten_label(lab::String)
    if lab == "algo_nl(:NonlinearSolve, NewtonRaphson{0, true, Val{:forward}, Nothing, typeof(NonlinearSolve.DEFAULT_PRECS), true, nothing}(nothing, NonlinearSolve.DEFAULT_PRECS))"
        return("algo_nl(:NonlinearSolve, NewtonRaphson)")
    else
        return(lab)
    end
end



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