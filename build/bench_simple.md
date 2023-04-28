# Benchmarks for bench_simple.jl

```julia
include("bench_problems.jl")
pb1 = OCPProblem{(:exponential, :energy, :state_dim_1, :control_dim_1, :lagrange)}()
@benchmark solve_generic(pb1.shoot, pb1.sol, :MINPACK, :hybr)
```

```bash
BenchmarkTools.Trial: 2808 samples with 1 evaluation.
 Range (min … max):  1.574 ms … 27.907 ms  ┊ GC (min … max): 0.00% … 93.38%
 Time  (median):     1.607 ms              ┊ GC (median):    0.00%
 Time  (mean ± σ):   1.777 ms ±  1.704 ms  ┊ GC (mean ± σ):  6.66% ±  6.49%

  ▅█▇▇▇▆▅▅▄▃▃▁▁                           ▁   ▂▂▃▂▁          ▂
  █████████████▇█▆▆▇▇▆▄▁▄▄▄▁▄▁▁▅▇▇█▆█▆▇▆▇▄███▆██████▇▇▅▆▅▁▁▄ █
  1.57 ms      Histogram: log(frequency) by time     2.07 ms <

 Memory estimate: 942.14 KiB, allocs estimate: 23294.
```

```julia
@benchmark solve_generic(pb1.shoot, pb1.sol, :MINPACK, :lm)
```

```bash
BenchmarkTools.Trial: 2799 samples with 1 evaluation.
 Range (min … max):  1.572 ms … 26.879 ms  ┊ GC (min … max): 0.00% … 92.07%
 Time  (median):     1.612 ms              ┊ GC (median):    0.00%
 Time  (mean ± σ):   1.784 ms ±  1.698 ms  ┊ GC (mean ± σ):  6.63% ±  6.50%

  ▅██▇▇▆▆▅▅▄▃▃▂▁▁  ▁                      ▁   ▂▃▂▁▁          ▁
  ████████████████▆█▆▆▆▅▄▄▃▅▅▄▅▅▇█▅▇▅▅▄▇▆▆█▆█████████▆▆▄▅▄▃▆ █
  1.57 ms      Histogram: log(frequency) by time     2.07 ms <

 Memory estimate: 942.27 KiB, allocs estimate: 23296.
```

```julia
@benchmark solve_generic(pb1.shoot, pb1.sol, :NLsolve, :anderson)
```

```bash
BenchmarkTools.Trial: 8301 samples with 1 evaluation.
 Range (min … max):  527.689 μs …  24.313 ms  ┊ GC (min … max): 0.00% … 96.95%
 Time  (median):     541.753 μs               ┊ GC (median):    0.00%
 Time  (mean ± σ):   598.787 μs ± 932.048 μs  ┊ GC (mean ± σ):  6.12% ±  3.84%

   ▅██▇▇▆▅▄▄▄▃▃▃▂▂▁ ▁▁▁                        ▂▃▄▃▃▂           ▂
  ▇█████████████████████▇▆▅▆▆▆▅▄▆▇███████▇▇█▆▆███████▇▆▇▇▆▇▆▆▅▄ █
  528 μs        Histogram: log(frequency) by time        699 μs <

 Memory estimate: 315.84 KiB, allocs estimate: 7791.
```

