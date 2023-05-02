# Benchmarks for bench_simple.jl

```julia
include("bench_problems.jl")
pb1 = OCPProblem{(:exponential, :energy, :x_dim_1, :u_dim_1, :lagrange)}()
@benchmark solve_generic(pb1.shoot, pb1.sol, :MINPACK, :hybr)
```

```bash
BenchmarkTools.Trial: 2153 samples with 1 evaluation.
 Range (min … max):  1.708 ms … 86.056 ms  ┊ GC (min … max): 0.00% … 97.07%
 Time  (median):     1.902 ms              ┊ GC (median):    0.00%
 Time  (mean ± σ):   2.314 ms ±  3.878 ms  ┊ GC (mean ± σ):  8.70% ±  5.09%

  ▆██▇▅▄▃▄▄▅▆▅▄▃▂▁▁▁▁                                        ▁
  ███████████████████▇█████▇▇▇█▆█▇▇▆▆▇▆▇▇█▇▆█▇█▇▇▆▅▅▅▆▅▄▅▅▁▅ █
  1.71 ms      Histogram: log(frequency) by time      4.2 ms <

 Memory estimate: 942.14 KiB, allocs estimate: 23294.
```

```julia
@benchmark solve_generic(pb1.shoot, pb1.sol, :MINPACK, :lm)
```

```bash
BenchmarkTools.Trial: 2131 samples with 1 evaluation.
 Range (min … max):  1.702 ms … 103.476 ms  ┊ GC (min … max): 0.00% … 97.50%
 Time  (median):     1.946 ms               ┊ GC (median):    0.00%
 Time  (mean ± σ):   2.337 ms ±   3.974 ms  ┊ GC (mean ± σ):  8.79% ±  5.12%

   ██▃                                                         
  ▇████▆▆▅▅▇▇▅▅▄▄▄▃▃▃▃▃▃▃▃▃▃▂▃▃▂▂▂▃▂▃▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▁▂▁▁▂ ▃
  1.7 ms          Histogram: frequency by time        4.28 ms <

 Memory estimate: 942.27 KiB, allocs estimate: 23296.
```

```julia
@benchmark solve_generic(pb1.shoot, pb1.sol, :NLsolve, :anderson)
```

```bash
BenchmarkTools.Trial: 6542 samples with 1 evaluation.
 Range (min … max):  565.219 μs … 71.341 ms  ┊ GC (min … max): 0.00% … 98.74%
 Time  (median):     643.291 μs              ┊ GC (median):    0.00%
 Time  (mean ± σ):   758.339 μs ±  2.082 ms  ┊ GC (mean ± σ):  8.27% ±  2.99%

  ▅██▇▇▆▅▅▅▅▆▆▅▅▄▃▃▃▃▂▂▁▁▁▁▁ ▁                                 ▂
  ███████████████████████████████▇▇▇▇▆▆▅▇▇▅▇▆▇▇▆▇▇▆▇▆▇▅▅▆▅▄▄▅▇ █
  565 μs        Histogram: log(frequency) by time      1.35 ms <

 Memory estimate: 315.84 KiB, allocs estimate: 7791.
```

