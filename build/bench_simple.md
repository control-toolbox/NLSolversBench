# Benchmarks for bench_simple.jl

```julia
include("bench_problems.jl")
pb1 = OCPProblem{(:exponential, :energy, :x_dim_1, :u_dim_1, :lagrange)}()
@benchmark solve_generic(pb1.shoot, pb1.sol, :MINPACK, :hybr, 100)
```

```bash
BenchmarkTools.Trial: 2576 samples with 1 evaluation.
 Range (min … max):  1.680 ms … 34.739 ms  ┊ GC (min … max): 0.00% … 93.73%
 Time  (median):     1.735 ms              ┊ GC (median):    0.00%
 Time  (mean ± σ):   1.937 ms ±  2.027 ms  ┊ GC (mean ± σ):  6.43% ±  5.83%

  ▅██▇▆▅▃▁▁▁        ▁  ▂▁▄▄▃                                 ▁
  █████████████▇█████████████▇▄▆▆▆▁▅▄▄▁▄▄▄▄▁▄▄▁▄▁▄▄▁▄▄▁▄▁▄▁▄ █
  1.68 ms      Histogram: log(frequency) by time     2.69 ms <

 Memory estimate: 941.70 KiB, allocs estimate: 23281.
```

```julia
@benchmark solve_generic(pb1.shoot, pb1.sol, :MINPACK, :lm, 100)
```

```bash
BenchmarkTools.Trial: 2579 samples with 1 evaluation.
 Range (min … max):  1.676 ms … 38.337 ms  ┊ GC (min … max): 0.00% … 93.80%
 Time  (median):     1.731 ms              ┊ GC (median):    0.00%
 Time  (mean ± σ):   1.935 ms ±  2.020 ms  ┊ GC (mean ± σ):  6.40% ±  5.82%

  ▆█▇▆▄▂▁        ▁▃▄▃                                        ▁
  ████████████████████▇▅▃▅▃▅▆▁▃▁▄▁▃▁▅▁▃▅▁▁▁▁▃▅▁▃▃▁▄▁▃▁▁▁▃▁▁▃ █
  1.68 ms      Histogram: log(frequency) by time     3.07 ms <

 Memory estimate: 941.83 KiB, allocs estimate: 23283.
```

```julia
@benchmark solve_generic(pb1.shoot, pb1.sol, :NLsolve, :anderson, 100)
```

```bash
BenchmarkTools.Trial: 7234 samples with 1 evaluation.
 Range (min … max):  555.376 μs … 60.217 ms  ┊ GC (min … max): 0.00% … 96.95%
 Time  (median):     575.373 μs              ┊ GC (median):    0.00%
 Time  (mean ± σ):   686.417 μs ±  1.350 ms  ┊ GC (mean ± σ):  7.02% ±  3.63%

  █▆▄▃▂▂▂▄▄▂▁                                                  ▁
  █████████████▇▇▆▆▆▆▅▆▆▆▅▅▅▅▅▅▄▅▄▅▄▄▄▄▄▃▅▄▅▄▄▂▅▅▅▆▅▄▅▅▅▄▅▅▅▄▅ █
  555 μs        Histogram: log(frequency) by time      1.61 ms <

 Memory estimate: 315.70 KiB, allocs estimate: 7787.
```

