# Benchmarks for bench_simple.jl

```julia
include("bench_problems.jl")
pb1 = OCPProblem{(:exponential, :energy, :x_dim_1, :u_dim_1, :lagrange)}()
@benchmark solve_generic(pb1.shoot, pb1.sol, :MINPACK, :hybr)
```

```bash
BenchmarkTools.Trial: 2622 samples with 1 evaluation.
 Range (min … max):  1.556 ms … 35.777 ms  ┊ GC (min … max): 0.00% … 94.58%
 Time  (median):     1.647 ms              ┊ GC (median):    0.00%
 Time  (mean ± σ):   1.901 ms ±  1.985 ms  ┊ GC (mean ± σ):  6.60% ±  6.04%

  ▆██▇▆▄▃▂▂▂▃▃▂▁▂▁   ▁ ▁                                     ▁
  █████████████████▇████▆▇▇▇▆██▇▇▆▆▇▇▇█▆▇▆▆▅▇▅▆▇▄▆▄▆▄▄▅▄▄▁▄▆ █
  1.56 ms      Histogram: log(frequency) by time     3.31 ms <

 Memory estimate: 942.14 KiB, allocs estimate: 23294.
```

```julia
@benchmark solve_generic(pb1.shoot, pb1.sol, :MINPACK, :lm)
```

```bash
BenchmarkTools.Trial: 2351 samples with 1 evaluation.
 Range (min … max):  1.559 ms … 51.634 ms  ┊ GC (min … max): 0.00% … 94.54%
 Time  (median):     1.716 ms              ┊ GC (median):    0.00%
 Time  (mean ± σ):   2.117 ms ±  2.303 ms  ┊ GC (mean ± σ):  6.55% ±  6.05%

  ▇█▇▆▅▄▃▃▃▂▂▂▁▂▁▂▁  ▁                                       ▁
  █████████████████████▇███▇██▇▇▆▇█▅▆▇▇▆▆▆▆▆▇▆▆▅▆▅▆▄▅▄▆▁▄▅▄▄ █
  1.56 ms      Histogram: log(frequency) by time     4.71 ms <

 Memory estimate: 942.27 KiB, allocs estimate: 23296.
```

```julia
@benchmark solve_generic(pb1.shoot, pb1.sol, :NLsolve, :anderson)
```

```bash
BenchmarkTools.Trial: 7835 samples with 1 evaluation.
 Range (min … max):  518.908 μs … 32.204 ms  ┊ GC (min … max): 0.00% … 97.64%
 Time  (median):     549.309 μs              ┊ GC (median):    0.00%
 Time  (mean ± σ):   633.500 μs ±  1.106 ms  ┊ GC (mean ± σ):  6.47% ±  3.65%

  ██▇▆▆▅▄▄▄▄▄▃▂▂▃▂▁▁▁▁▁▁                                       ▂
  ████████████████████████▇███▇▇▇▇▇█▇▇▆▇▆▆▆▆▆▆▆▅▆▆▇▆▆▅▆▆▅▅▅▅▅▄ █
  519 μs        Histogram: log(frequency) by time      1.11 ms <

 Memory estimate: 315.84 KiB, allocs estimate: 7791.
```

