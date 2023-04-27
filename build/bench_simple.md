# Benchmarks for bench_simple.jl

```julia
include("bench_problems.jl")
pb1 = OCPProblem{(:exponential, :energy, :state_dim_1, :control_dim_1, :lagrange)}()
@benchmark solve_generic(pb1.shoot, pb1.sol, :MINPACK, :hybr)
```

```bash
BenchmarkTools.Trial: 1945 samples with 1 evaluation.
 Range (min … max):  1.672 ms … 144.313 ms  ┊ GC (min … max): 0.00% … 96.62%
 Time  (median):     1.947 ms               ┊ GC (median):    0.00%
 Time  (mean ± σ):   2.561 ms ±   5.059 ms  ┊ GC (mean ± σ):  8.64% ±  4.42%

  ██▇▅▄▆▄▃▄▄▁▂▁                     ▁   ▁▁▁   ▁               ▁
  ██████████████▇██▇█▆▇▇█▅▆█▅▇▃▇▇▇▇███▆█████████▇█▇▇▇▇▇▆▆▇▆▄▅ █
  1.67 ms      Histogram: log(frequency) by time      4.85 ms <

 Memory estimate: 934.69 KiB, allocs estimate: 23153.
```

```julia
@benchmark solve_generic(pb1.shoot, pb1.sol, :MINPACK, :lm)
```

```bash
BenchmarkTools.Trial: 2396 samples with 1 evaluation.
 Range (min … max):  1.672 ms … 95.916 ms  ┊ GC (min … max): 0.00% … 97.47%
 Time  (median):     1.769 ms              ┊ GC (median):    0.00%
 Time  (mean ± σ):   2.080 ms ±  4.163 ms  ┊ GC (mean ± σ):  9.08% ±  4.46%

  ██▇▅▃▂▅▅▅▄▁    ▁                                           ▁
  ████████████▇█▇█▇█▆▇▆▆▆▆▅▇▆▆▅▅▄▄▅▄▆▄▆▄▄▅▁▄▁▄▄▁▄▄▁▄▁▄▁▁▁▄▁▄ █
  1.67 ms      Histogram: log(frequency) by time     4.06 ms <

 Memory estimate: 934.81 KiB, allocs estimate: 23155.
```

```julia
@benchmark solve_generic(pb1.shoot, pb1.sol, :NLsolve, :anderson)
```

```bash
BenchmarkTools.Trial: 7231 samples with 1 evaluation.
 Range (min … max):  549.290 μs … 94.199 ms  ┊ GC (min … max): 0.00% … 99.19%
 Time  (median):     582.586 μs              ┊ GC (median):    0.00%
 Time  (mean ± σ):   686.960 μs ±  2.352 ms  ┊ GC (mean ± σ):  8.98% ±  2.61%

  ▇█▇▆▅▃▂▅▅▃▅▃▃▂▁                                              ▂
  █████████████████████▇▇█▇▇█▇▇▆▇▆▅▅▆▇▆▆▅▅▆▅▅▆▅▆▅▆▆▅▅▅▄▅▅▆▆▁▄▃ █
  549 μs        Histogram: log(frequency) by time      1.28 ms <

 Memory estimate: 313.36 KiB, allocs estimate: 7744.
```

