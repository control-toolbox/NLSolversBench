struct sol_shoot
    x::Vector{<:Real}
    converged::Bool
end

function solve_generic(shoot!, ξ, lib, algo)

    MLStyle.@match lib begin
        :MINPACK => begin
                        isreal = ξ isa Real
                        shoot_sol = fsolve((s, ξ) -> isreal ? shoot!(s, ξ[1]) : shoot!(s, ξ), Float64.(isreal ? [ξ] : ξ), show_trace=false, method=algo)
                        return(sol_shoot(shoot_sol.x, shoot_sol.converged))
                    end
        :NLsolve => begin
                        isreal = ξ isa Real
                        shoot_sol = nlsolve((s, ξ) -> isreal ? shoot!(s, ξ[1]) : shoot!(s, ξ), Float64.(isreal ? [ξ] : ξ), show_trace=false, method=algo)
                        return(sol_shoot(shoot_sol.zero, shoot_sol.x_converged))
                    end
        _ => return(false)
    end
end

struct OCPProblem{description}
    function OCPProblem{description}() where {description}
        throw(NonExistingProblem(description))
    end
end

struct OCPShoot
    sol::Union{<:Real,Vector{<:Real}}
    shoot!::Function
end

function ProblemSh(description...) 
    return OCPProblem{description}()
end


using Random
using Distributions

function generate_variation(ξ,σ)
    d = Normal()
    ξ_var = [([σ*el*rand(d) for el in ξ] .+ ξ) for i = 1:100]
    return (ξ_var)
end
