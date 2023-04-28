# Benchmarks for bench_simple.jl

```julia
include("bench_problems.jl")
pb1 = OCPProblem{(:exponential, :energy, :state_dim_1, :control_dim_1, :lagrange)}()
@benchmark solve_generic(pb1.shoot, pb1.sol, :MINPACK, :hybr)
```

```bash
BenchmarkTools.Trial: 2523 samples with 1 evaluation.
 Range (min … max):  1.659 ms … 74.591 ms  ┊ GC (min … max): 0.00% … 96.94%
 Time  (median):     1.729 ms              ┊ GC (median):    0.00%
 Time  (mean ± σ):   1.977 ms ±  3.709 ms  ┊ GC (mean ± σ):  9.82% ±  5.10%

   ▂▇██▆▅▃▅▃▃▂▂                                               
  ▄████████████▆▆▅▄▃▃▃▂▂▂▂▂▂▂▁▂▂▂▁▂▂▂▂▃▄▅▆▅▄▄▃▃▃▃▂▂▃▄▅▅▄▃▃▃▃ ▄
  1.66 ms        Histogram: frequency by time        2.12 ms <

 Memory estimate: 935.06 KiB, allocs estimate: 23162.
```

```julia
@benchmark solve_generic(pb1.shoot, pb1.sol, :MINPACK, :lm)
```

```bash
BenchmarkTools.Trial: 2499 samples with 1 evaluation.
 Range (min … max):  1.668 ms … 72.553 ms  ┊ GC (min … max): 0.00% … 96.85%
 Time  (median):     1.736 ms              ┊ GC (median):    0.00%
 Time  (mean ± σ):   1.996 ms ±  3.716 ms  ┊ GC (mean ± σ):  9.79% ±  5.12%

   ▄█▅▆▅▅▂▂▁                                                  
  ▅█████████▇▆▅▄▃▃▃▃▂▂▂▂▁▁▂▂▂▂▂▃▃▄▄▄▄▃▃▃▂▂▃▄▄▄▄▃▃▃▂▂▂▂▁▂▁▁▂▂ ▃
  1.67 ms        Histogram: frequency by time        2.24 ms <

 Memory estimate: 935.19 KiB, allocs estimate: 23164.
```

```julia
@benchmark solve_generic(pb1.shoot, pb1.sol, :NLsolve, :anderson)
```

```bash
BenchmarkTools.Trial: 7501 samples with 1 evaluation.
 Range (min … max):  557.427 μs … 70.149 ms  ┊ GC (min … max): 0.00% … 98.93%
 Time  (median):     579.052 μs              ┊ GC (median):    0.00%
 Time  (mean ± σ):   662.915 μs ±  2.110 ms  ┊ GC (mean ± σ):  9.70% ±  3.02%

    ▅█▆▃▁                                                       
  ▃▇██████▇█▇▇▅▅▅▄▄▃▃▃▂▃▂▂▂▂▂▂▂▂▂▂▁▂▂▃▃▄▄▃▃▃▃▃▂▂▂▂▃▃▄▄▄▃▃▂▂▂▂▂ ▃
  557 μs          Histogram: frequency by time          719 μs <

 Memory estimate: 313.48 KiB, allocs estimate: 7747.
```

