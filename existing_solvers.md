# Non linear solvers

## Solvers

- [MINPACK](https://github.com/sglyon/MINPACK.jl)
- [NLSolve](https://github.com/JuliaNLSolvers/NLsolve.jl)
- [NonLinearSolve](https://github.com/SciML/NonlinearSolve.jl)
	
## [MINPACK](https://github.com/sglyon/MINPACK.jl)

```julia
fsolve(f!::Function, x0::Vector{Float64}, m::Int=length(x0); tol::Float64=1e-8, show_trace::Bool=false, tracing::Bool=false, method::Symbol=:hybr, iterations::Int=typemax(Int), io::IO=STDOUT, kwargs...) 

fsolve(f!::Function, g!::Function, x0::Vector{Float64}, m::Int=length(x0); tol::Float64=1e-8, show_trace::Bool=false, tracing::Bool=false, method::Symbol=:hybr, iterations::Int=typemax(Int), io::IO=STDOUT, kwargs...)
``` 

methods : 

- [hybr](https://github.com/devernay/cminpack/blob/d1f5f5a273862ca1bbcf58394e4ac060d9e22c76/hybrd1.c) & [hybrd](https://github.com/devernay/cminpack/blob/d1f5f5a273862ca1bbcf58394e4ac060d9e22c76/hybrd.c) : Powell's algorithm (with jacobian calculated by a forward-difference if not provided)
- [lm](https://github.com/devernay/cminpack/blob/d1f5f5a273862ca1bbcf58394e4ac060d9e22c76/lmdif1.c) & [lmdif](https://github.com/devernay/cminpack/blob/d1f5f5a273862ca1bbcf58394e4ac060d9e22c76/lmdif.c) : Levenberg-Marquadt algorithm (with jacobian calculated by a forward-difference if not provided)


## [NLSolve](https://github.com/JuliaNLSolvers/NLsolve.jl)

```julia
function nlsolve(f, initial_x::AbstractArray; method::Symbol = :trust_region, autodiff = :central, inplace = !applicable(f, initial_x), kwargs...)

function nlsolve(f,j,initial_x::AbstractArray;inplace = !applicable(f, initial_x),kwargs...)
```

methods : 

- newton : Newton with linesearch
- trust_region : trust region
- fixedpoint : fixed-point iteration
- anderson : fixed-point with Anderson acceleration


## [NonLinearSolve](https://github.com/SciML/NonlinearSolve.jl)

```julia
solve(prob::NonlinearProblem,alg;kwargs)
```

methods : 
- NewtonRaphson
- TrustRegion
- SimpleNewtonRaphson
- Broyden
- Klement
- SimpleTrustRegion
- SimpleDFSane


## SCIML NLS
It seems that sciml Non Linear Solvers wraps NLSolve and [other solvers](https://docs.sciml.ai/NonlinearSolve/stable/solvers/NonlinearSystemSolvers/).
