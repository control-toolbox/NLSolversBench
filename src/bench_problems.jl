include("bench_utils.jl")

function OCPProblem{(:exponential, :energy, :x_dim_1, :u_dim_1, :lagrange)}(;abstol::Float64=1e-12,reltol::Float64=1e-12)

    prob = Problem(:exponential, :energy, :x_dim_1, :u_dim_1, :lagrange)
    ocp = prob.model

    # Flow(ocp, u)
    f = Flow(ocp, (x, p) -> p, abstol=abstol, reltol=reltol)

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
    ξ = [a/b]

    nle(ξ) = shoot(ξ[1])

    return(OCPShoot(ξ,nle,prob.title))
end

function OCPProblem{(:exponential, :consumption, :x_dim_1, :u_dim_1, :lagrange, :non_diff_wrt_u)}(;abstol::Float64=1e-12,reltol::Float64=1e-12)

    # ---------------------------------------------------------------
    # problem = model + solution
    prob = Problem(:exponential, :consumption, :x_dim_1, :u_dim_1, :lagrange, :non_diff_wrt_u)
    ocp = prob.model

    # Flow(ocp, u)
    f0 = Flow(ocp, (x, p) -> 0, abstol=abstol, reltol=reltol)
    f1 = Flow(ocp, (x, p) -> 1, abstol=abstol, reltol=reltol)

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

function OCPProblem{(:exponential, :time, :x_dim_1, :u_dim_1, :lagrange)}(;abstol::Float64=1e-12,reltol::Float64=1e-12)

    # ---------------------------------------------------------------
    # problem = model + solution
    prob = Problem(:exponential, :time, :x_dim_1, :u_dim_1, :lagrange)
    ocp = prob.model

    # Flow(ocp, u)
    f⁺ = Flow(ocp, (x, p) -> 1, abstol=abstol, reltol=reltol)
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


function OCPProblem{(:integrator, :energy, :free_final_time, :x_dim_1, :u_dim_1, :lagrange)}(;abstol::Float64=1e-12,reltol::Float64=1e-12)

    # ---------------------------------------------------------------
    # problem = model + solution
    prob = Problem(:integrator, :energy, :free_final_time, :x_dim_1, :u_dim_1, :lagrange)
    ocp = prob.model
    

    # Flow(ocp, u)
    f = Flow(ocp, (x, p) -> p, abstol=abstol, reltol=reltol)

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

function OCPProblem{(:turnpike, :integrator, :state_energy, :x_dim_1, :u_dim_1, :lagrange, :u_cons, :singular_arc)}(;abstol::Float64=1e-12,reltol::Float64=1e-12)

    # ---------------------------------------------------------------
    # problem = model + solution
    prob = Problem(:turnpike, :integrator, :state_energy, :x_dim_1, :u_dim_1, :lagrange, :u_cons, :singular_arc)
    ocp = prob.model


    # Flow(ocp, u)
    fm = Flow(ocp, (x, p) -> -1, abstol=abstol, reltol=reltol)
    fp = Flow(ocp, (x, p) -> +1, abstol=abstol, reltol=reltol)
    f0 = Flow(ocp, (x, p) ->  0, abstol=abstol, reltol=reltol)

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


function OCPProblem{(:integrator, :energy, :x_dim_2, :u_dim_1, :lagrange, :noconstraints)}(;abstol::Float64=1e-12,reltol::Float64=1e-12)

    # problem = model + solution
    prob = Problem(:integrator, :energy, :x_dim_2, :u_dim_1, :lagrange, :noconstraints)
    ocp = prob.model

    # Flow(ocp, u)
    f = Flow(ocp, (x, p) -> p[2], abstol=abstol, reltol=reltol)

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


function OCPProblem{(:integrator, :energy, :x_dim_2, :u_dim_1, :lagrange, :u_cons)}(;abstol::Float64=1e-12,reltol::Float64=1e-12)

    # ---------------------------------------------------------------
    # problem = model + solution
    prob = Problem(:integrator, :energy, :x_dim_2, :u_dim_1, :lagrange, :u_cons)
    ocp = prob.model
    sol = prob.solution
    title = "Double integrator energy - mininimise ∫ u² under the constraint norm(u) ≤ γ"

    # Flow(ocp, u)
    γ  = 5
    fm = Flow(ocp, (x, p) -> -γ, abstol=abstol, reltol=reltol)
    fp = Flow(ocp, (x, p) -> +γ, abstol=abstol, reltol=reltol)
    fs = Flow(ocp, (x, p) -> p[2], abstol=abstol, reltol=reltol)

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
    
    return(OCPShoot(ξ,nle,title))

end





function OCPProblem{(:goddard, :classical, :altitude, :x_dim_3, :u_dim_1, :mayer, :x_cons, :u_cons, :singular_arc)}(;abstol::Float64=1e-12,reltol::Float64=1e-12)

    #
    prob = Problem(:goddard, :classical, :altitude, :x_dim_3, :u_dim_1, :mayer, :x_cons, :u_cons, :singular_arc)
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
    remove_constraint!(ocp, :x_cons_r)
    g(x) = vmax-constraint(ocp, :x_cons_v)(x) # g(x, u) ≥ 0 (cf. nonnegative multiplier)
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
    f0 = Flow(ocp, u0, abstol=abstol, reltol=reltol)
    f1 = Flow(ocp, u1, abstol=abstol, reltol=reltol)
    fs = Flow(ocp, us, abstol=abstol, reltol=reltol)
    fb = Flow(ocp, ub, (x, _) -> g(x), μb, abstol=abstol, reltol=reltol)

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


function OCPProblem{(:integrator, :energy, :distance, :x_dim_2, :u_dim_1, :bolza)}(;abstol::Float64=1e-12,reltol::Float64=1e-12)

    # problem = model + solution
    prob = Problem(:integrator, :energy, :distance, :x_dim_2, :u_dim_1, :bolza)
    ocp = prob.model

    # Flow(ocp, u)
    f = Flow(ocp, (x, p) -> p[2], abstol=abstol, reltol=reltol)

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



function OCPProblem{(:orbital_transfert, :energy, :x_dim_4, :u_dim_2, :lagrange)}(;abstol::Float64=1e-12,reltol::Float64=1e-12)

    # problem = model + solution
    prob = Problem(:orbital_transfert, :energy, :x_dim_4, :u_dim_2, :lagrange) 
    ocp = prob.model

    # Flow(ocp, u)
    f = Flow(ocp, (x, p) -> [p[3], p[4]], abstol=abstol, reltol=reltol)

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


function OCPProblem{(:orbital_transfert, :consumption, :x_dim_4, :u_dim_2, :lagrange, :u_cons)}(;abstol::Float64=1e-12,reltol::Float64=1e-12)

    # problem = model + solution
    prob = Problem(:orbital_transfert, :consumption, :x_dim_4, :u_dim_2, :lagrange, :u_cons)
    ocp = prob.model
    sol = prob.solution
    title = prob.title

    # Flow(ocp, u)
    m0     = 2000
    F_max  = 100
    γ_max  = F_max*3600.0^2/(m0*10^3)
    μ      = 5.1658620912*1e12
    rf     = 42165
    rf3    = rf^3
    α      = sqrt(μ/rf3)
    #
    u(p) = [p[3], p[4]]/sqrt(p[3]^2 + p[4]^2)
    #
    f0 = Flow(ocp, (_, _) -> [0, 0], abstol=abstol, reltol=reltol)
    f1 = Flow(ocp, (_, p) -> u(p), abstol=abstol, reltol=reltol)

    # shooting function
    t0 = ocp.initial_time
    tf = ocp.final_time
    x0 = [-42272.67, 0, 0, -5796.72]
    c(xf) = constraint(ocp, :boundary_constraint)(t0, x0, tf, xf)
    Φ(x, p) = x[2]*(p[1]+α*p[4]) - x[1]*(p[2]-α*p[3])
    sw(p) = γ_max*(p[3]^2 + p[4]^2) - 1

    #
    function shoot(p0, t1, t2, t3, t4)
        #
        s = zeros(eltype(p0),8)
        x1, p1 = f1(t0, x0, p0, t1)
        x2, p2 = f0(t1, x1, p1, t2)
        x3, p3 = f1(t2, x2, p2, t3)
        x4, p4 = f0(t3, x3, p3, t4)
        xf, pf = f1(t4, x4, p4, tf)
        #
        s[1:3] = c(xf)
        s[4] = Φ(xf, pf)
        s[5] = sw(p1)
        s[6] = sw(p2)
        s[7] = sw(p3)
        s[8] = sw(p4)
        return(s)
        #
    end

    # tests
    p0 = [0.02698412111231433, 0.006910835140705538, 0.050397371862031096, -0.0032972040120747836]
    ti = [0.4556797711668658, 3.6289692721936913, 11.683607683450061, 12.505465498856514]
    ξ  = [p0; ti]

    

    nle(ξ) = shoot(ξ[1:4], ξ[5:8]...)

    return(OCPShoot(ξ,nle,prob.title))
end


function OCPProblem{(:orbital_transfert, :time, :x_dim_4, :u_dim_2, :mayer, :u_cons)}(;abstol::Float64=1e-12,reltol::Float64=1e-12)

    # problem = model + solution
    prob = Problem(:orbital_transfert, :time, :x_dim_4, :u_dim_2, :mayer, :u_cons)
    ocp = prob.model
    sol = prob.solution
    title = prob.title

    # Flow(ocp, u)
    m0     = 2000.0
    F_max  = 100.0
    γ_max  = F_max*3600.0^2/(m0*10^3)
    μ      = 5.1658620912*1.0e12
    rf     = 42165
    rf3    = rf^3
    α      = sqrt(μ/rf3)
    #
    H(x, p, u) =  p[1]*x[3] + p[2]*x[4] + 
                    p[3]*(-μ*x[1]/(sqrt(x[1]^2+x[2]^2))^3 + u[1]) + 
                    p[4]*(-μ*x[2]/(sqrt(x[1]^2+x[2]^2))^3 + u[2])
    u(p) = [p[3], p[4]]*γ_max/sqrt(p[3]^2 + p[4]^2)
    f = Flow(ocp, (_, p) -> u(p), abstol=abstol, reltol=reltol)

    # shooting function
    t0 = ocp.initial_time
    x0 = [-42272.67, 0, 0, -5796.72]
    c(tf, xf) = constraint(ocp, :boundary_constraint)(t0, x0, tf, xf)
    Φ(x, p) = x[2]*(p[1]+α*p[4]) - x[1]*(p[2]-α*p[3])

    #
    function shoot(p0, tf)
        s = zeros(eltype(p0),5)
        xf, pf = f(t0, x0, p0, tf)
        s[1:3] = c(tf, xf)
        s[4] = Φ(xf, pf)
        s[5] = H(xf, pf, u(pf)) - 1
        return(s)
    end

    # tests
    ξ = [0.00010323118914991345, 4.892642780583378e-5, 0.00035679672938385165, -0.0001553613885740003, 13.403181957151876]   # pour F_max = 100N
    
    nle(ξ) = shoot(ξ[1:4], ξ[5])
    return(OCPShoot(ξ,nle,prob.title))

end


function OCPProblem{(:integrator, :energy, :x_dim_2, :u_dim_1, :lagrange, :x_cons, :order_2)}(;abstol::Float64=1e-12,reltol::Float64=1e-12)

    # ---------------------------------------------------------------
    # problem = model + solution
    prob = Problem(:integrator, :energy, :x_dim_2, :u_dim_1, :lagrange, :x_cons, :order_2) 
    ocp = prob.model
    sol = prob.solution
    title = prob.title

    # Flow(ocp, u)
    #
    fs = Flow(ocp, (x, p) -> p[2], abstol=abstol, reltol=reltol)
    # constraint
    l = 1/9
    uc(x, p) = 0
    g(x) = constraint(ocp, :x_cons)(x) - l
    μc(x, p) = 0
    fc = Flow(ocp, uc, (x, _) -> g(x), μc)

    # shooting function
    t0 = ocp.initial_time
    tf = ocp.final_time
    x0 = [0, 1]
    xf_ = [0, -1]
    #
    function shoot(p0, t1, t2, ν1, ν2)
        s = zeros(eltype(p0),6)
        x1, p1 = fs(t0, x0, p0, t1)
        x2, p2 = fc(t1, x1, p1+ν1*[1, 0], t2)
        xf, pf = fs(t2, x2, p2+ν2*[1, 0], tf)
        s[1:2] = xf_ - xf
        s[3] = g(x1)
        s[4] = x1[2]
        s[5] = p1[2]
        s[6] = p2[2]
        return(s)
    end

    # tests
    t1 = 1/3
    t2 = 2/3
    p0 = [-18, -6]
    ν1 = 18
    ν2 = 18
    ξ  = [p0..., t1, t2, ν1, ν2]

    nle(ξ) = shoot(ξ[1:2], ξ[3], ξ[4], ξ[5], ξ[6])

    return(OCPShoot(ξ,nle,prob.title))


end


function OCPProblem{(:lqr, :x_dim_2, :u_dim_1, :lagrange)}(;abstol::Float64=1e-12,reltol::Float64=1e-12)
    # problem = model + solution
    prob = Problem(:lqr, :x_dim_2, :u_dim_1, :lagrange)
    ocp = prob.model

    # Flow(ocp, u)
    B = [0; 1]
    f = Flow(ocp, (x, p) -> B'*p, abstol=abstol, reltol=reltol)

    # shooting function
    t0 = ocp.initial_time
    tf = ocp.final_time
    x0 = [0, 1]
    #
    function shoot(p0)
        s = zeros(eltype(p0),2)
        xf, pf = f(t0, x0, p0, tf)
        s[1:2] = pf
        return(s)
    end

    # solution
    ξ = [-0.41112814502591294, -1.3479980933014002]

    return(OCPShoot(ξ,shoot,prob.title))

end

function OCPProblem{(:integrator, :consumption, :x_dim_2, :u_dim_1, :lagrange, :u_cons, :non_diff_wrt_u)}(;abstol::Float64=1e-12,reltol::Float64=1e-12)
    # ---------------------------------------------------------------
    # problem = model + solution
    prob = Problem(:integrator, :consumption, :x_dim_2, :u_dim_1, :lagrange, :u_cons, :non_diff_wrt_u)
    ocp = prob.model
    sol = prob.solution
    title = "Double integrator consumption - mininimise ∫ norm(u) under the constraint norm(u) ≤ γ"

    # Flow(ocp, u)
    γ  = 5
    fm = Flow(ocp, (x, p) -> -γ, abstol=abstol, reltol=reltol)
    fp = Flow(ocp, (x, p) -> +γ, abstol=abstol, reltol=reltol)
    f0 = Flow(ocp, (x, p) -> 0, abstol=abstol, reltol=reltol)

    # shooting function
    t0 = ocp.initial_time
    tf = ocp.final_time
    x0 = [-1, 0]
    xf = [0, 0]
    #
    function shoot(p0, t1, t2)
        s = zeros(eltype(p0),4)
        x1, p1 = fp(t0, x0, p0, t1)
        x2, p2 = f0(t1, x1, p1, t2)
        xf_, pf = fm(t2, x2, p2, tf)
        s[1:2] = xf_ - xf
        s[3] = p1[2] - 1
        s[4] = p2[2] + 1
        return(s)
    end

    # tests
    t1 = 0.2763932022500211#0.25*tf
    t2 = 0.723606797749979#0.75*tf
    p0 = [4.472135954999579, 2.23606797749979]#[11/tf, 6]
    ξ = [p0..., t1, t2]

    

    nle(ξ) = shoot(ξ[1:2], ξ[3], ξ[4])
    
    return(OCPShoot(ξ,nle,title))

end