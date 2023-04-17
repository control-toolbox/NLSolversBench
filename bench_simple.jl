
#prob = Problems()

prob = Problem(:exponential, :energy, :state_dim_1, :control_dim_1, :lagrange) 
ocp = prob.model
sol = prob.solution
#title = prob.title

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

# tests
a = xf_ - x0*exp(-tf)
b = sinh(tf)
ξ = a/b + 1
fparams(ξ) = (t0, x0, ξ, tf, f)



@benchmark solve_generic(shoot!, ξ, :MINPACK, :hybr)

@benchmark solve_generic(shoot!, ξ, :MINPACK, :lm)

@benchmark solve_generic(shoot!, ξ, :NLsolve, :None)