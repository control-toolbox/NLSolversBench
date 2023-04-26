include("bench_utils.jl")

function OCPProblem{(:exponential, :energy, :state_dim_1, :control_dim_1, :lagrange)}()

    prob = Problem(:exponential, :energy, :state_dim_1, :control_dim_1, :lagrange) 
    ocp = prob.model

    # Flow(ocp, u)
    f = Flow(ocp, (x, p) -> p)

    # shooting function
    t0 = ocp.initial_time
    tf = ocp.final_time
    x0 = 0
    xf_ = 1
    #
    function shoot!(s, p0)
        xf, pf = f(t0, x0, p0, tf)
        s[1] = xf - xf_
    end

    function shoot(p0)
        s = zeros(eltype(p0),1)
        xf, pf = f(t0, x0, p0, tf)
        s[1] = xf - xf_
        return(s)
    end

    # tests
    a = xf_ - x0*exp(-tf)
    b = sinh(tf)
    ξ = a/b

    return(OCPShoot(ξ,shoot,prob.title))
end

function OCPProblem{(:exponential, :consumption, :state_dim_1, :control_dim_1, :lagrange, :control_non_differentiable)}()

    # ---------------------------------------------------------------
    # problem = model + solution
    prob = Problem(:exponential, :consumption, :state_dim_1, :control_dim_1, :lagrange, :control_non_differentiable) 
    ocp = prob.model

    # Flow(ocp, u)
    f0 = Flow(ocp, (x, p) -> 0)
    f1 = Flow(ocp, (x, p) -> 1)

    # shooting function
    t0 = ocp.initial_time
    tf = ocp.final_time
    x0 = -1
    xf_ = 0
    #
    function shoot!(s, p0, t1)
        x1, p1 = f0(t0, x0, p0, t1)
        xf, pf = f1(t1, x1, p1, tf)
        s[1] = xf - xf_
        s[2] = p1 - 1
    end

    function shoot(p0, t1)
        s = zeros(eltype(p0),2)
        x1, p1 = f0(t0, x0, p0, t1)
        xf, pf = f1(t1, x1, p1, tf)
        s[1] = xf - xf_
        s[2] = p1 - 1
        return s
    end

    # tests
    p0 = 1/(x0-(xf_-1)/exp(-tf))
    ξ = [p0, -log(p0)]
    
    nle! = (s, ξ) -> shoot!(s, ξ[1], ξ[2])
    nle(ξ) = shoot(ξ[1],ξ[2])

    return(OCPShoot(ξ,nle,prob.title))

end

function OCPProblem{(:exponential, :time, :state_dim_1, :control_dim_1, :lagrange)}()

    # ---------------------------------------------------------------
    # problem = model + solution
    prob = Problem(:exponential, :time, :state_dim_1, :control_dim_1, :lagrange) 
    ocp = prob.model

    # Flow(ocp, u)
    f⁺ = Flow(ocp, (x, p) -> 1)
    H⁺(x, p) = p * (-x + 1)

    # shooting function
    t0 = ocp.initial_time
    x0 = -1
    xf_ = 0
    #
    function shoot!(s, p0, tf)
        xf, pf = f⁺(t0, x0, p0, tf)
        s[1] = xf - xf_
        s[2] = H⁺(xf, pf) - 1
    end

    function shoot(p0, tf)
        s = zeros(eltype(p0),2)
        xf, pf = f⁺(t0, x0, p0, tf)
        s[1] = xf - xf_
        s[2] = H⁺(xf, pf) - 1
        return s
    end

    # tests
    γ  = 1
    tf = log((-1-γ)/(xf_-γ))
    p0 = exp(t0-tf)/(γ-xf_)
    ξ = [p0, tf]
    
    nle! = (s, ξ) -> shoot!(s, ξ[1], ξ[2])
    nle(ξ) = shoot(ξ[1], ξ[2])

    return(OCPShoot(ξ,nle,prob.title))

end


function OCPProblem{(:integrator, :energy, :free_final_time, :state_dim_1, :control_dim_1, :lagrange)}()

    # ---------------------------------------------------------------
    # problem = model + solution
    prob = Problem(:integrator, :energy, :free_final_time, :state_dim_1, :control_dim_1, :lagrange)
    ocp = prob.model
    

    # Flow(ocp, u)
    f = Flow(ocp, (x, p) -> p)

    # shooting function
    t0 = ocp.initial_time
    x0 = 0
    c(tf, xf) = constraint(ocp, :boundary_constraint)(t0, x0, tf, xf)
    #
    function shoot!(s, p0, tf)
        xf, pf = f(t0, x0, p0, tf)
        s[1] = c(tf, xf)
        s[2] = pf - 2
    end

    function shoot(p0, tf)
        s = zeros(eltype(p0),2)
        xf, pf = f(t0, x0, p0, tf)
        s[1] = c(tf, xf)
        s[2] = pf - 2
        return(s)
    end
 
    # tests
    p0 = 2
    tf = 10
    ξ = [p0, tf]
    nle! = (s, ξ) -> shoot!(s, ξ[1], ξ[2])
    nle(ξ) = shoot(ξ[1],ξ[2])
    return(OCPShoot(ξ,nle,prob.title))

end

function OCPProblem{(:turnpike, :integrator, :state_energy, :state_dim_1, :control_dim_1, :lagrange, :control_constraint, :singular_arc) }()

    # ---------------------------------------------------------------
    # problem = model + solution
    prob = Problem(:turnpike, :integrator, :state_energy, :state_dim_1, :control_dim_1, :lagrange, :control_constraint, :singular_arc) 
    ocp = prob.model


    # Flow(ocp, u)
    fm = Flow(ocp, (x, p) -> -1)
    fp = Flow(ocp, (x, p) -> +1)
    f0 = Flow(ocp, (x, p) ->  0)

    # shooting function
    t0 = ocp.initial_time
    tf = ocp.final_time
    x0=1
    xf=0.5
    #
    function shoot!(s, p0, t1, t2)
        x1, p1 = fm(t0, x0, p0, t1)
        x2, p2 = f0(t1, x1, p1, t2)
        xf_, pf = fp(t2, x2, p2, tf)
        s[1] = xf_ - xf
        s[2] = x1
        s[3] = p1
    end

    function shoot(p0, t1, t2)
        s = zeros(eltype(p0),3)
        x1, p1 = fm(t0, x0, p0, t1)
        x2, p2 = f0(t1, x1, p1, t2)
        xf_, pf = fp(t2, x2, p2, tf)
        s[1] = xf_ - xf
        s[2] = x1
        s[3] = p1
        return(s)
    end


    # tests
    t1 = x0
    t2 = tf - xf
    p0 = t1^2 - 2*x0*t1
    ξ = [p0, t1, t2]
    nle! = (s, ξ) -> shoot!(s, ξ[1], ξ[2], ξ[3])
    nle(ξ) = shoot(ξ[1], ξ[2], ξ[3])

    return(OCPShoot(ξ,nle,prob.title))

end


function OCPProblem{(:integrator, :energy, :state_dim_2, :control_dim_1, :lagrange, :noconstraints)}()

    # problem = model + solution
    prob = Problem(:integrator, :energy, :state_dim_2, :control_dim_1, :lagrange, :noconstraints)
    ocp = prob.model

    # Flow(ocp, u)
    f = Flow(ocp, (x, p) -> p[2])

    # shooting function
    t0 = ocp.initial_time
    tf = ocp.final_time
    x0 = [-1, 0]
    xf_ = [0, 0]
    #
    function shoot!(s, p0)
        xf, pf = f(t0, x0, p0, tf)
        s[1:2] = xf - xf_
    end    

    function shoot(p0)
        s = zeros(eltype(p0),2)
        xf, pf = f(t0, x0, p0, tf)
        s[1:2] = xf - xf_
        return(s)
    end    

    # tests
    a = x0[1]
    b = x0[2]
    C = [-(tf-t0)^3/6 (tf-t0)^2/2
         -(tf-t0)^2/2 (tf-t0)]
    D = [-a-b*(tf-t0), -b]+xf_     
    ξ = C\D


    return(OCPShoot(ξ,shoot,prob.title))
end    


function OCPProblem{(:integrator, :energy, :state_dim_2, :control_dim_1, :lagrange, :control_constraint)}()

    # ---------------------------------------------------------------
    # problem = model + solution
    prob = Problem(:integrator, :energy, :state_dim_2, :control_dim_1, :lagrange, :control_constraint) 
    ocp = prob.model
    sol = prob.solution
    title = prob.title

    # Flow(ocp, u)
    γ  = 5
    fm = Flow(ocp, (x, p) -> -γ)
    fp = Flow(ocp, (x, p) -> +γ)
    fs = Flow(ocp, (x, p) -> p[2])

    # shooting function
    t0 = ocp.initial_time
    tf = ocp.final_time
    x0 = [-1,0]
    xf = [0,0]
    #
    function shoot!(s, p0, t1, t2)
        x1, p1 = fp(t0, x0, p0, t1)
        x2, p2 = fs(t1, x1, p1, t2)
        xf_, pf = fm(t2, x2, p2, tf)
        s[1:2] = xf_ - xf
        s[3] = p1[2] - γ
        s[4] = p2[2] + γ
    end

    function shoot(p0, t1, t2)
        s = zeros(eltype(p0),4)
        x1, p1 = fp(t0, x0, p0, t1)
        x2, p2 = fs(t1, x1, p1, t2)
        xf_, pf = fm(t2, x2, p2, tf)
        s[1:2] = xf_ - xf
        s[3] = p1[2] - γ
        s[4] = p2[2] + γ
        return(s)
    end

    p0 = [12.90994448735837, 6.454972243678883]
    t1 = 0.11270166537924434  
    t2 = 0.8872983346207088
    ξ = [p0..., t1, t2]

    nle(ξ) = shoot(ξ[1:2], ξ[3], ξ[4])
    
    return(OCPShoot(ξ,nle,prob.title))

end





function OCPProblem{(:goddard, :classical, :altitude, :state_dim_3, :control_dim_1, :mayer, :state_constraint, :control_constraint, :singular_arc)}()

    #
    prob = Problem(:goddard, :classical, :altitude, :state_dim_3, :control_dim_1, 
        :mayer, :state_constraint, :control_constraint, :singular_arc)
    ocp = prob.model

    # parameters
    Cd = 310
    Tmax = 3.5
    β = 500
    b = 2
    t0 = 0
    r0 = 1
    v0 = 0
    vmax = 0.1
    m0 = 1
    mf = 0.6

    #
    #remove_constraint!(ocp, :state_constraint_r)
    g(x) = vmax-constraint(ocp, :state_constraint_v)(x) # g(x, u) ≥ 0 (cf. nonnegative multiplier)
    final_mass_cons(xf) = mf-constraint(ocp, :final_constraint)(xf)

    function F0(x)
        r, v, m = x
        D = Cd * v^2 * exp(-β*(r - 1))
        return [ v, -D/m - 1/r^2, 0 ]
    end
    function F1(x)
        r, v, m = x
        return [ 0, Tmax/m, -b*Tmax ]
    end

    # flows
    # bang controls
    u0(x, p) = 0.
    u1(x, p) = 1.

    # singular control of order 1
    H0(x, p) = p' * F0(x)
    H1(x, p) = p' * F1(x)
    H01 = CTBase.Poisson(H0, H1)
    H001 = CTBase.Poisson(H0, H01)
    H101 = CTBase.Poisson(H1, H01)
    us(x, p) = -H001(x, p) / H101(x, p)

    # boundary control
    ub(x, _) = -Ad(F0, g)(x) / Ad(F1, g)(x)
    μb(x, p) = H01(x, p) / Ad(F1, g)(x)

    # associated flows
    f0 = Flow(ocp, u0)
    f1 = Flow(ocp, u1)
    fs = Flow(ocp, us)
    fb = Flow(ocp, ub, (x, _) -> g(x), μb)

    # shooting function
    t0 = ocp.initial_time
    x0 = [ r0, v0, m0 ]
    function shoot!(s, p0, t1, t2, t3, tf) # B+ S C B0 structure

        x1, p1 = f1(t0, x0, p0, t1)
        x2, p2 = fs(t1, x1, p1, t2)
        x3, p3 = fb(t2, x2, p2, t3)
        xf, pf = f0(t3, x3, p3, tf)
        s[1] = final_mass_cons(xf)
        s[2:3] = pf[1:2] - [ 1, 0 ]
        s[4] = H1(x1, p1)
        s[5] = H01(x1, p1)
        s[6] = g(x2)
        s[7] = H0(xf, pf) # free tf

    end

    function shoot(p0, t1, t2, t3, tf) # B+ S C B0 structure
        s = zeros(eltype(p0),7)
        x1, p1 = f1(t0, x0, p0, t1)
        x2, p2 = fs(t1, x1, p1, t2)
        x3, p3 = fb(t2, x2, p2, t3)
        xf, pf = f0(t3, x3, p3, tf)
        s[1] = final_mass_cons(xf)
        s[2:3] = pf[1:2] - [ 1, 0 ]
        s[4] = H1(x1, p1)
        s[5] = H01(x1, p1)
        s[6] = g(x2)
        s[7] = H0(xf, pf) # free tf
        return(s)
    end

    # tests
    t1 = 0.02350968402023801
    t2 = 0.05973738095397227
    t3 = 0.10157134841905507
    tf = 0.20204744057725113
    ξ = [3.9457646591162034, 0.15039559628359686, 0.053712712969520515, 
        t1, 
        t2, 
        t3, 
        tf] # initial guess


    nle! = (s, ξ) -> shoot!(s, ξ[1:3], ξ[4], ξ[5], ξ[6], ξ[7])
    nle(ξ) = shoot(ξ[1:3],ξ[4], ξ[5], ξ[6], ξ[7])


    return(OCPShoot(ξ,nle,prob.title))

end


function OCPProblem{(:integrator, :energy, :distance, :state_dim_2, :control_dim_1, :bolza)}()

    # problem = model + solution
    prob = Problem(:integrator, :energy, :distance, :state_dim_2, :control_dim_1, :bolza)
    ocp = prob.model

    # Flow(ocp, u)
    f = Flow(ocp, (x, p) -> p[2])

    # shooting function
    t0 = ocp.initial_time
    tf = ocp.final_time
    x0 = [0,0]
    #
    function shoot!(s, p0)
        xf, pf = f(t0, x0, p0, tf)
        s[1:2] = pf - [1/2, 0]
    end

    function shoot(p0)
        s = zeros(eltype(p0),2)
        xf, pf = f(t0, x0, p0, tf)
        s[1:2] = pf - [1/2, 0]
        return(s)
    end

    # tests
    ξ = [1/2, tf/2]
    
    return(OCPShoot(ξ,shoot,prob.title))

end



function OCPProblem{(:orbital_transfert, :energy, :state_dim_4, :control_dim_2, :lagrange)}()

    # problem = model + solution
    prob = Problem(:orbital_transfert, :energy, :state_dim_4, :control_dim_2, :lagrange) 
    ocp = prob.model

    # Flow(ocp, u)
    f = Flow(ocp, (x, p) -> [p[3], p[4]])

    # shooting function
    t0 = ocp.initial_time
    tf = ocp.final_time
    x0     = [-42272.67, 0, 0, -5796.72]
    c(x) = constraint(ocp, :boundary_constraint)(t0, x0, tf, x)
    μ      = 5.1658620912*1.0e12
    rf     = 42165
    rf3    = rf^3
    α      = sqrt(μ/rf3);
    Φ(x, p) = x[2]*(p[1]+α*p[4]) - x[1]*(p[2]-α*p[3])

    #
    function shoot!(s, p0)
        xf, pf = f(t0, x0, p0, tf)
        s[1:3] = c(xf)
        s[4] = Φ(xf, pf)
    end

    function shoot(p0)
        s = zeros(eltype(p0),4)
        xf, pf = f(t0, x0, p0, tf)
        s[1:3] = c(xf)
        s[4] = Φ(xf, pf)
        return(s)
    end

    # tests
    ξ = [131.44483634894812, 34.16617425875177, 249.15735272382514, -23.9732920001312]   # pour F_max = 100N
    
    return(OCPShoot(ξ,shoot,prob.title))

end