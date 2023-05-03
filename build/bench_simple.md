# Benchmarks for bench_simple.jl

```julia
include("bench_problems.jl")
pb1 = OCPProblem{(:exponential, :energy, :x_dim_1, :u_dim_1, :lagrange)}()
@benchmark solve_generic(pb1.shoot, pb1.sol, :MINPACK, :hybr, 100)
```

```bash
BenchmarkTools.Trial: 2293 samples with 1 evaluation.
 Range (min … max):  1.783 ms … 106.992 ms  ┊ GC (min … max):  0.00% … 97.66%
 Time  (median):     1.875 ms               ┊ GC (median):     0.00%
 Time  (mean ± σ):   2.175 ms ±   4.880 ms  ┊ GC (mean ± σ):  10.43% ±  4.56%

   ▁██▅▄▂▂▃▂▂▂                                                 
  ▃███████████▇▇▅▅▅▄▃▃▃▂▃▂▂▁▂▂▂▁▂▂▂▃▅▆▆▇▆▆▅▅▄▄▄▄▄▅▄▃▃▃▃▃▂▂▂▁▂ ▄
  1.78 ms         Histogram: frequency by time        2.31 ms <

 Memory estimate: 934.62 KiB, allocs estimate: 23149.
```

```julia
@benchmark solve_generic(pb1.shoot, pb1.sol, :MINPACK, :lm, 100)
```

```bash
BenchmarkTools.Trial: 2320 samples with 1 evaluation.
 Range (min … max):  1.779 ms … 104.984 ms  ┊ GC (min … max):  0.00% … 97.64%
 Time  (median):     1.860 ms               ┊ GC (median):     0.00%
 Time  (mean ± σ):   2.149 ms ±   4.774 ms  ┊ GC (mean ± σ):  10.27% ±  4.53%

   ▂▆▇▇█▇█▆▅▄▄▂▁                             ▁                 
  ▅██████████████▆▅▅▃▃▃▃▃▃▃▂▂▂▂▂▂▂▂▁▁▂▂▂▃▄▆▆▇█▇▆▆▅▄▄▃▄▅▅▄▄▄▄▃ ▄
  1.78 ms         Histogram: frequency by time        2.23 ms <

 Memory estimate: 934.75 KiB, allocs estimate: 23151.
```

```julia
@benchmark solve_generic(pb1.shoot, pb1.sol, :NLsolve, :anderson, 100)
```

```bash
BenchmarkTools.Trial: 6953 samples with 1 evaluation.
 Range (min … max):  589.454 μs … 108.349 ms  ┊ GC (min … max):  0.00% … 99.24%
 Time  (median):     618.212 μs               ┊ GC (median):     0.00%
 Time  (mean ± σ):   714.497 μs ±   2.762 ms  ┊ GC (mean ± σ):  10.35% ±  2.66%

    ▄█▅▃▂▁                                                       
  ▂▆████████▇█▇▅▅▄▃▃▃▂▂▂▂▂▁▁▁▁▁▁▁▁▁▁▁▁▁▃▄▆▅▅▄▄▃▃▂▂▃▂▃▃▃▃▂▂▁▂▁▁▁ ▃
  589 μs           Histogram: frequency by time          754 μs <

 Memory estimate: 313.34 KiB, allocs estimate: 7743.
```

