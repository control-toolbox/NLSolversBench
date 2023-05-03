# Benchmarks for bench_simple.jl

```julia
include("bench_problems.jl")
pb1 = OCPProblem{(:exponential, :energy, :x_dim_1, :u_dim_1, :lagrange)}()
@benchmark solve_generic(pb1.shoot, pb1.sol, :MINPACK, :hybr, 100)
```

```bash
BenchmarkTools.Trial: 2326 samples with 1 evaluation.
 Range (min … max):  1.656 ms … 143.876 ms  ┊ GC (min … max):  0.00% … 98.01%
 Time  (median):     1.752 ms               ┊ GC (median):     0.00%
 Time  (mean ± σ):   2.144 ms ±   4.500 ms  ┊ GC (mean ± σ):  10.70% ±  5.29%

  ▇█▇▄▂▂▅▃▄▁▁                                                  
  ████████████▇▇█▆▆▄▆▅▇▆▆▄▄▇▅▆▅▄▅▄▄▃▆▄▅▅▄▃▃▄▄▄▄▃▅▄▅▄▅▅▃▃▃▄▃▃▄ █
  1.66 ms      Histogram: log(frequency) by time      4.31 ms <

 Memory estimate: 934.62 KiB, allocs estimate: 23149.
```

```julia
@benchmark solve_generic(pb1.shoot, pb1.sol, :MINPACK, :lm, 100)
```

```bash
BenchmarkTools.Trial: 1559 samples with 1 evaluation.
 Range (min … max):  1.657 ms … 110.672 ms  ┊ GC (min … max): 0.00% … 96.78%
 Time  (median):     2.428 ms               ┊ GC (median):    0.00%
 Time  (mean ± σ):   3.193 ms ±   4.504 ms  ┊ GC (mean ± σ):  6.68% ±  4.87%

  ▅█▆▄▁▁                                                       
  ██████▆▆▄▅▅▄▄▃▃▃▃▄▂▃▃▃▃▃▃▃▃▄▃▃▅▅▄▅▄▅▅▆▇▅▆▆▄▄▃▃▃▃▃▂▂▁▂▂▂▂▂▂▂ ▃
  1.66 ms         Histogram: frequency by time         5.9 ms <

 Memory estimate: 934.75 KiB, allocs estimate: 23151.
```

```julia
@benchmark solve_generic(pb1.shoot, pb1.sol, :NLsolve, :anderson, 100)
```

```bash
BenchmarkTools.Trial: 4896 samples with 1 evaluation.
 Range (min … max):  549.698 μs … 122.910 ms  ┊ GC (min … max): 0.00% … 99.08%
 Time  (median):     697.308 μs               ┊ GC (median):    0.00%
 Time  (mean ± σ):     1.009 ms ±   2.596 ms  ┊ GC (mean ± σ):  7.03% ±  2.82%

  █▅▃▁▁                                                          
  ██████▅▅▄▄▃▃▃▃▃▃▃▃▃▂▃▂▂▂▂▃▃▃▂▃▃▃▃▃▃▄▃▄▄▄▅▄▄▄▄▃▃▃▂▂▂▂▂▂▂▂▂▂▂▁▂ ▃
  550 μs           Histogram: frequency by time         1.98 ms <

 Memory estimate: 313.34 KiB, allocs estimate: 7743.
```

