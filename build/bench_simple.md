# Benchmarks for bench_simple.jl

```julia
include("bench_problems.jl")
pb1 = OCPProblem{(:exponential, :energy, :state_dim_1, :control_dim_1, :lagrange)}()
@benchmark solve_generic(pb1.shoot, pb1.sol, :MINPACK, :hybr)
```

```bash
BenchmarkTools.Trial: 2620 samples with 1 evaluation.
 Range (min … max):  1.667 ms … 39.357 ms  ┊ GC (min … max): 0.00% … 94.37%
 Time  (median):     1.714 ms              ┊ GC (median):    0.00%
 Time  (mean ± σ):   1.905 ms ±  2.303 ms  ┊ GC (mean ± σ):  7.39% ±  5.83%

  ▂▆▇██▇▇▆▆▅▄▃▁▁                                 ▃▂▁▂        ▁
  ███████████████▆▆▇▆▆▅▆▅▄▅▄▄▅▇▇▇▇▇▇▇▇▅▆▅▆▄▄▇▇▇█▇██████▆▄▄▄▃ █
  1.67 ms      Histogram: log(frequency) by time     2.15 ms <

 Memory estimate: 934.69 KiB, allocs estimate: 23153.
```

```julia
@benchmark solve_generic(pb1.shoot, pb1.sol, :MINPACK, :lm)
```

```bash
BenchmarkTools.Trial: 2610 samples with 1 evaluation.
 Range (min … max):  1.674 ms … 39.523 ms  ┊ GC (min … max): 0.00% … 94.72%
 Time  (median):     1.716 ms              ┊ GC (median):    0.00%
 Time  (mean ± σ):   1.912 ms ±  2.313 ms  ┊ GC (mean ± σ):  7.40% ±  5.84%

  ▄▇▇██▆▆▅▄▃▂                            ▁▃▃▂▁▁              ▂
  ████████████▇▇▇▆▆▄▆▆▄▁▆▇██▇▇▆▆▆▇▇▆▄▅▇▇▇██████▇▅▁▅▄▁▁▁▁▄▁▁▄ █
  1.67 ms      Histogram: log(frequency) by time     2.25 ms <

 Memory estimate: 934.81 KiB, allocs estimate: 23155.
```

```julia
@benchmark solve_generic(pb1.shoot, pb1.sol, :NLsolve, :anderson)
```

```bash
BenchmarkTools.Trial: 7855 samples with 1 evaluation.
 Range (min … max):  553.645 μs … 38.457 ms  ┊ GC (min … max): 0.00% … 97.76%
 Time  (median):     567.808 μs              ┊ GC (median):    0.00%
 Time  (mean ± σ):   633.100 μs ±  1.313 ms  ┊ GC (mean ± σ):  7.36% ±  3.49%

  ▁▆███▇▆▅▄▄▄▃▃▂▂▁▁▁▁        ▁▁▁              ▂▃▃▃▂▁           ▂
  ████████████████████▇▇▆▆▅▄▇████▇▆▇▆▆▇▆▇▅▆▆▇▇███████▇▇▆▆▆▆▄▂▅ █
  554 μs        Histogram: log(frequency) by time       728 μs <

 Memory estimate: 313.36 KiB, allocs estimate: 7744.
```

