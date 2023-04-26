struct sol_shoot
    x::Vector{<:Real}
    converged::Bool
end

function solve_generic(shoot, ξ, lib, algo)
    
    shoot!(s, ξ) = ( s[:] = shoot(ξ); nothing)
    shoot_p(ξ,p) = shoot(ξ)

    try
        MLStyle.@match lib begin
            :MINPACK => begin
                            isreal = ξ isa Real
                            shoot_sol = fsolve((s, ξ) -> isreal ? shoot!(s, ξ[1]) : shoot!(s, ξ), Float64.(isreal ? [ξ] : ξ), show_trace=false, method=algo, tol=1e-8)
                            return(sol_shoot(shoot_sol.x, shoot_sol.converged))
                        end
            :NLsolve => begin
                            isreal = ξ isa Real
                            shoot_sol = nlsolve((s, ξ) -> isreal ? shoot!(s, ξ[1]) : shoot!(s, ξ), Float64.(isreal ? [ξ] : ξ), autodiff = :forward, xtol=1e-8, show_trace=false, method=algo)
                            return(sol_shoot(shoot_sol.zero, shoot_sol.x_converged))
                        end
            :NonlinearSolve => begin
                            isreal = ξ isa Real
                            shoot_sol = solve(NonlinearProblem(shoot_p, isreal ? ξ[1] : ξ, 0),algo,abstol=1e-8)
                            return(sol_shoot(Vector{Float64}(vec(shoot_sol)), true))
                        end
            _ => return(false)
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

Random.seed!(123)
function generate_variation(ξ,σ,n)
    d = Uniform(-1,1)#Normal()
    ξ_var = [([σ*el*rand(d) for el in ξ] .+ ξ) for i = 1:n]
    return (ξ_var)
end




function shorten_label(lab::String)
    if lab == "algo_nl(:NonlinearSolve, NewtonRaphson{0, true, Val{:forward}, Nothing, typeof(NonlinearSolve.DEFAULT_PRECS), true, nothing}(nothing, NonlinearSolve.DEFAULT_PRECS))"
        return("algo_nl(:NonlinearSolve, NewtonRaphson)")
    else
        return(lab)
    end
end
