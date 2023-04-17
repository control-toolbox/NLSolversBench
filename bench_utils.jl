function solve_generic(shoot!, ξ, lib, algo)

    MLStyle.@match lib begin
        :MINPACK => begin
                        isreal = ξ isa Real
                        shoot_sol = fsolve((s, ξ) -> isreal ? shoot!(s, ξ[1]) : shoot!(s, ξ), Float64.(isreal ? [ξ] : ξ), show_trace=false, method=algo)
                        return(shoot_sol.converged)
                    end
        :NLsolve => begin
                        isreal = ξ isa Real
                        shoot_sol = nlsolve((s, ξ) -> isreal ? shoot!(s, ξ[1]) : shoot!(s, ξ), Float64.(isreal ? [ξ] : ξ), show_trace=false)
                        return(shoot_sol.x_converged)
                    end
        _ => return(false)
    end
end

