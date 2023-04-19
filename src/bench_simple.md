# Benchmarks for src/bench_simple.jl

```julia
include("bench_problems.jl")
pb1 = OCPProblem{(:exponential, :energy, :state_dim_1, :control_dim_1, :lagrange)}()
@benchmark solve_generic(pb1.shoot!, pb1.sol, :MINPACK, :hybr)
```

```bash
BenchmarkTools.Trial: 2745 samples with 1 evaluation.
 Range (min … max):  1.627 ms … 27.702 ms  ┊ GC (min … max): 0.00% … 92.14%
 Time  (median):     1.680 ms              ┊ GC (median):    0.00%
 Time  (mean ± σ):   1.817 ms ±  1.763 ms  ┊ GC (mean ± σ):  6.61% ±  6.37%

    ▃█▆▄▅▇▆▆▅▁▁                                               
  ▃▇████████████▆▆▄▄▃▃▃▃▃▃▃▂▂▃▂▂▂▁▂▂▂▂▁▁▂▂▂▁▂▂▂▂▂▂▃▂▂▃▃▂▂▂▁▂ ▄
  1.63 ms        Histogram: frequency by time           2 ms <

 Memory estimate: 941.95 KiB, allocs estimate: 23291.
```

```julia
@benchmark solve_generic(pb1.shoot!, pb1.sol, :MINPACK, :lm)
```

```bash
BenchmarkTools.Trial: 2746 samples with 1 evaluation.
 Range (min … max):  1.623 ms … 29.104 ms  ┊ GC (min … max): 0.00% … 93.17%
 Time  (median):     1.681 ms              ┊ GC (median):    0.00%
 Time  (mean ± σ):   1.817 ms ±  1.772 ms  ┊ GC (mean ± σ):  6.64% ±  6.37%

     ▅█▆▅▇▇▆▅▃▄                                               
  ▂▄███████████▇▇▆▅▄▄▃▄▃▃▂▃▃▂▂▂▂▂▁▂▂▂▂▂▁▁▂▂▁▂▁▂▃▂▃▂▂▂▂▂▂▃▂▂▂ ▄
  1.62 ms        Histogram: frequency by time           2 ms <

 Memory estimate: 942.08 KiB, allocs estimate: 23293.
```

```julia
@benchmark solve_generic(pb1.shoot!, pb1.sol, :NLsolve, :anderson)
```

```bash
BenchmarkTools.Trial: 8126 samples with 1 evaluation.
 Range (min … max):  540.830 μs … 27.802 ms  ┊ GC (min … max): 0.00% … 96.68%
 Time  (median):     559.039 μs              ┊ GC (median):    0.00%
 Time  (mean ± σ):   611.660 μs ±  1.010 ms  ┊ GC (mean ± σ):  6.56% ±  3.88%

    ▂█▆▁                                                        
  ▁▂████▆▅▃▄▄▄▄▃▃▃▂▂▂▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁ ▂
  541 μs          Histogram: frequency by time          748 μs <

 Memory estimate: 315.78 KiB, allocs estimate: 7790.
```

