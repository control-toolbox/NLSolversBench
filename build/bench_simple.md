# Benchmarks for bench_simple.jl

```julia
include("bench_problems.jl")
pb1 = OCPProblem{(:exponential, :energy, :x_dim_1, :u_dim_1, :lagrange)}()
@benchmark solve_generic(pb1.shoot, pb1.sol, :MINPACK, :hybr, 100)
```

```bash
BenchmarkTools.Trial: 1972 samples with 1 evaluation.
 Range (min … max):  1.673 ms … 93.865 ms  ┊ GC (min … max): 0.00% … 94.70%
 Time  (median):     1.924 ms              ┊ GC (median):    0.00%
 Time  (mean ± σ):   2.525 ms ±  4.088 ms  ┊ GC (mean ± σ):  7.83% ±  4.85%

  █▇▅▄▅▅▄▂▂▂▁▁▁▁▁▁▁ ▁▁                                        
  ██████████████████████▇██▇▆▅▆▆▇▅▇▄▆▄▆▆▆▆▇▆█▇█▆▆▆▅▇▅▆▅▅▆▆▄▅ █
  1.67 ms      Histogram: log(frequency) by time     5.47 ms <

 Memory estimate: 934.62 KiB, allocs estimate: 23149.
```

```julia
@benchmark solve_generic(pb1.shoot, pb1.sol, :MINPACK, :lm, 100)
```

```bash
BenchmarkTools.Trial: 2573 samples with 1 evaluation.
 Range (min … max):  1.663 ms … 73.794 ms  ┊ GC (min … max): 0.00% … 97.04%
 Time  (median):     1.719 ms              ┊ GC (median):    0.00%
 Time  (mean ± σ):   1.939 ms ±  3.340 ms  ┊ GC (mean ± σ):  8.92% ±  5.04%

   ▁▆▇▇██▆▅▄▃                                                 
  ▃███████████▇▅▅▄▄▃▃▃▂▂▂▂▂▂▂▂▁▁▂▂▂▂▂▃▄▅▄▃▄▃▃▃▃▂▂▂▃▄▅▅▄▃▃▃▂▂ ▄
  1.66 ms        Histogram: frequency by time        2.07 ms <

 Memory estimate: 934.75 KiB, allocs estimate: 23151.
```

```julia
@benchmark solve_generic(pb1.shoot, pb1.sol, :NLsolve, :anderson, 100)
```

```bash
BenchmarkTools.Trial: 7747 samples with 1 evaluation.
 Range (min … max):  551.474 μs … 62.904 ms  ┊ GC (min … max): 0.00% … 98.90%
 Time  (median):     570.940 μs              ┊ GC (median):    0.00%
 Time  (mean ± σ):   642.054 μs ±  1.852 ms  ┊ GC (mean ± σ):  8.66% ±  2.97%

    ▄█▇▆▇▄▃▂▁                                                   
  ▁▄██████████▇▆▄▄▃▃▃▂▂▂▂▂▂▁▁▁▁▁▁▁▁▁▁▁▂▃▃▃▃▂▂▂▁▂▁▁▂▂▂▄▃▃▂▂▁▁▁▁ ▃
  551 μs          Histogram: frequency by time          689 μs <

 Memory estimate: 313.34 KiB, allocs estimate: 7743.
```

