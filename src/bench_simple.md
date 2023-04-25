# Benchmarks for src/bench_simple.jl

```julia
include("bench_problems.jl")
pb1 = OCPProblem{(:exponential, :energy, :state_dim_1, :control_dim_1, :lagrange)}()
@benchmark solve_generic(pb1.shoot, pb1.sol, :MINPACK, :hybr)
```

```bash
BenchmarkTools.Trial: 2653 samples with 1 evaluation.
 Range (min … max):  1.622 ms … 70.250 ms  ┊ GC (min … max): 0.00% … 97.06%
 Time  (median):     1.672 ms              ┊ GC (median):    0.00%
 Time  (mean ± σ):   1.881 ms ±  3.485 ms  ┊ GC (mean ± σ):  9.47% ±  4.98%

    ▃█▇▆▅▄▃▂▄                                                 
  ▃▆███████████▇▅▄▄▄▃▃▂▂▂▂▂▂▂▂▂▁▂▂▂▁▂▂▁▁▁▂▂▄▄▄▃▃▃▃▃▂▃▃▃▂▂▂▂▂ ▃
  1.62 ms        Histogram: frequency by time        1.99 ms <

 Memory estimate: 935.06 KiB, allocs estimate: 23162.
```

```julia
@benchmark solve_generic(pb1.shoot, pb1.sol, :MINPACK, :lm)
```

```bash
BenchmarkTools.Trial: 2646 samples with 1 evaluation.
 Range (min … max):  1.622 ms … 69.462 ms  ┊ GC (min … max): 0.00% … 96.92%
 Time  (median):     1.678 ms              ┊ GC (median):    0.00%
 Time  (mean ± σ):   1.886 ms ±  3.471 ms  ┊ GC (mean ± σ):  9.42% ±  4.98%

    ▃▄█▆▇▆▄▅▅▄▂                                               
  ▅▇███████████▆▇▅▅▄▄▃▃▃▃▃▂▂▂▂▂▂▂▂▂▂▁▂▂▂▂▃▃▄▄▄▄▄▃▃▃▃▃▃▂▂▂▂▂▂ ▄
  1.62 ms        Histogram: frequency by time        1.99 ms <

 Memory estimate: 935.19 KiB, allocs estimate: 23164.
```

```julia
@benchmark solve_generic(pb1.shoot, pb1.sol, :NLsolve, :anderson)
```

```bash
BenchmarkTools.Trial: 7931 samples with 1 evaluation.
 Range (min … max):  538.481 μs … 67.890 ms  ┊ GC (min … max): 0.00% … 98.97%
 Time  (median):     557.061 μs              ┊ GC (median):    0.00%
 Time  (mean ± σ):   626.848 μs ±  1.984 ms  ┊ GC (mean ± σ):  9.38% ±  2.94%

    ▃▇█▇█▇▄▁▂▂▁                                                 
  ▂▆███████████▇▆▅▄▃▃▂▂▂▂▂▂▂▁▂▁▁▁▁▁▁▁▁▁▁▂▂▃▃▃▃▂▃▂▂▂▂▂▁▁▁▁▁▁▁▁▁ ▃
  538 μs          Histogram: frequency by time          668 μs <

 Memory estimate: 313.48 KiB, allocs estimate: 7747.
```

