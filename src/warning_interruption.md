```julia
True solution : [131.445, 34.1662, 249.157, -23.9733]
Using algo : algo_nl(:MINPACK, :hybr)
           with problem : Orbital transfert - energy minimisation - min ∫ ‖u‖² dt
            and i0 = [153.1617553856573, 22.044935869926043, 187.5491804773901, -24.565258684692363]
Using algo : algo_nl(:NLsolve, :newton)
           with problem : Orbital transfert - energy minimisation - min ∫ ‖u‖² dt
            and i0 = [188.51091594019846, 45.235476944447335, 172.45440239822253, -20.14623725383765]
Using algo : algo_nl(:NonlinearSolve, NewtonRaphson{0, true, Val{:forward}, Nothing, typeof(NonlinearSolve.DEFAULT_PRECS), true, nothing}(nothing, NonlinearSolve.DEFAULT_PRECS))
           with problem : Orbital transfert - energy minimisation - min ∫ ‖u‖² dt
            and i0 = [188.51091594019846, 45.235476944447335, 172.45440239822253, -20.14623725383765]

┌ Warning: Interrupted. Larger maxiters is needed. If you are using an integrator for non-stiff ODEs or an automatic switching algorithm (the default), you may want to consider using a method for stiff equations. See the solver pages for more details (e.g. https://docs.sciml.ai/DiffEqDocs/stable/solvers/ode_solve/#Stiff-Problems).
└ @ SciMLBase ~/.julia/packages/SciMLBase/VdcHg/src/integrator_interface.jl:575


True solution : [0.00010323118914991345, 4.892642780583378e-5, 0.00035679672938385165, -0.0001553613885740003, 13.403181957151876]
Using algo : algo_nl(:NonlinearSolve, NewtonRaphson{0, true, Val{:forward}, Nothing, typeof(NonlinearSolve.DEFAULT_PRECS), true, nothing}(nothing, NonlinearSolve.DEFAULT_PRECS))
           with problem : Orbital transfert - time minimisation
            and i0 = [0.00011699736126926748, 6.120481175842646e-5, 0.000452739334008642, -0.00018957919135312144, 16.89810581209801]
=> ERROR: LoadError: LAPACKException(1)
