# Benchmarks for bench_simple.jl

```julia
prob = Problem(:exponential, :energy, :state_dim_1, :control_dim_1, :lagrange)
ocp = prob.model
sol = prob.solution
f = Flow(ocp, ((x, p)->begin
                p
            end))
t0 = ocp.initial_time
tf = ocp.final_time
x0 = 0
xf_ = 1
function shoot!(s, p0)
    (xf, pf) = f(t0, x0, p0, tf)
    s[1] = xf - xf_
end
a = xf_ - x0 * exp(-tf)
b = sinh(tf)
ξ = a / b + 1
fparams(ξ) = begin
        (t0, x0, ξ, tf, f)
    end
@benchmark solve_generic(shoot!, ξ, :MINPACK, :hybr)
```

```bash
BenchmarkTools.Trial: 664 samples with 1 evaluation.
 Range (min … max):  5.531 ms … 58.119 ms  ┊ GC (min … max): 0.00% … 85.28%
 Time  (median):     6.377 ms              ┊ GC (median):    0.00%
 Time  (mean ± σ):   7.522 ms ±  5.016 ms  ┊ GC (mean ± σ):  6.72% ±  9.22%

  █▅▆▃▂▁ ▁                                                    
  ██████▇███▅▇▆▅▄▄▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▄ ▇
  5.53 ms      Histogram: log(frequency) by time     44.1 ms <

 Memory estimate: 3.12 MiB, allocs estimate: 78946.
```

```julia
@benchmark solve_generic(shoot!, ξ, :MINPACK, :lm)
```

```bash
BenchmarkTools.Trial: 1053 samples with 1 evaluation.
 Range (min … max):  3.916 ms … 44.129 ms  ┊ GC (min … max): 0.00% … 86.36%
 Time  (median):     4.082 ms              ┊ GC (median):    0.00%
 Time  (mean ± σ):   4.774 ms ±  3.772 ms  ┊ GC (mean ± σ):  7.50% ±  8.56%

  █▇▂ ▁  ▄▇▁                                                  
  ███▅███████▇▅▄▄▆▇▅▅▅▅▅▄▄▁▁▄▁▁▁▁▄▁▄▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▄ █
  3.92 ms      Histogram: log(frequency) by time     10.9 ms <

 Memory estimate: 2.20 MiB, allocs estimate: 55677.
```

```julia
@benchmark solve_generic(shoot!, ξ, :NLsolve, :None)
```

```bash
BenchmarkTools.Trial: 980 samples with 1 evaluation.
 Range (min … max):  3.941 ms … 57.081 ms  ┊ GC (min … max): 0.00% … 87.89%
 Time  (median):     4.461 ms              ┊ GC (median):    0.00%
 Time  (mean ± σ):   5.095 ms ±  3.963 ms  ┊ GC (mean ± σ):  7.16% ±  8.46%

  ▇█▅▂▃▃▃▂▂▄▆▄▂▃▁   ▁                                         
  █████████████████▆███▆▇▇▇▇▇▆▄▆▆▆▆▆▆▅▄▄▄▄▄▄▄▅▁▄▄▁▁▄▁▁▁▁▁▁▄▄ █
  3.94 ms      Histogram: log(frequency) by time     9.65 ms <

 Memory estimate: 2.22 MiB, allocs estimate: 56337.
```

