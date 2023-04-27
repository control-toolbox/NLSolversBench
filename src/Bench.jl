using Revise
try
    revise(NLSOLVERSBENCH)
catch
end

using Pkg
using CTProblems
using MINPACK
using NLsolve
using BenchmarkTools
using CTFlows
using MLStyle
using MacroTools

include("bench_utils.jl")



function doBenchMarking(expr, f)

    expr = MacroTools.striplines(expr)
    println("Benchmarking $expr")
    write(f, string(expr)*"\n")
    write(f, "```\n\n")
    write(f, "```bash\n")
    show(f, "text/plain", eval(quote $expr end))
    write(f, "\n```\n\n")

end

function displayTable(expr, f)
    println("Table of $expr")
    write(f, "```\n\n")
    write(f, eval(expr))
    write(f, "\n\n")
end

function bench(file::String)

    file_name = split(file, ('.','/'))[2]
    println("Benching $file_name.jl\n")

    file_name_output = joinpath("build/" * file_name * ".md")
    open(file_name_output, write=true, append=false) do f
        write(f, "# Benchmarks for $file_name.jl\n\n")
        #show(f,"text/plain", Pkg.status(; f))
        write(f, "```julia\n")
    end


    has_displayed = false

    function mapexpr(expr)

        #println("Nouvelle expr           : ", expr)
        #Base.remove_linenums!(expr)
        #println("Suppression line number : ", expr)
        expr = MacroTools.striplines(expr)
        #println("MacroTools line number  : ", expr, "\n")
        println("Expr  : ", expr)
        #dump(expr)

        open(file_name_output, write=true, append=true) do f

            if has_displayed 
                write(f, "```julia\n")
                has_displayed = false
            end
        
            if hasproperty(expr, :head) && expr.head == :macrocall && expr.args[1] == Symbol("@benchmark")

                has_displayed = true
                doBenchMarking(expr, f)
                expr = :()

            else

                MLStyle.@match expr begin
                    :( display($benchname) ) => begin
                        has_displayed = true
                        doBenchMarking(quote $benchname end, f)
                        expr = :()
                    end
                    Expr(:call, fun, args...)   => begin
                        write(f, string(expr)*"\n")
                        if(string(expr.args[1]) == "savefig")
                            write(f,"```\n ![fig](bench_all.svg) \n ```julia \n")
                        end
                        if(string(expr.args[1]) == "pretty_table")
                            displayTable(expr,f)
                        end
                    end
                    _ => begin
                        write(f, string(expr)*"\n")
                    end
                end

            end

        end

        return expr 

    end

    include(mapexpr, file)

end