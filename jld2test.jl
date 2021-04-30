module PSSFSS


module GSMs
export GSM

mutable struct GSM{T1 <: AbstractMatrix, T2 <: AbstractMatrix}
    s11::T1
    s12::T2
    s21::T2
    s22::T1
end

end # module GSMs
##############################################
module Outputs
using ..GSMs: GSM
using JLD2
using StaticArrays
export runit

const SV2 = SVector{2,Float64}

SteerType = Union{NamedTuple{(:ψ₁, :ψ₂), Tuple{Float64, Float64}}, 
                  NamedTuple{(:θ, :ϕ), Tuple{Float64, Float64}}}

struct Result
    gsm::GSM
    steering::SteerType
    β⃗₀₀::SV2
    FGHz::Float64
    ϵᵣin::ComplexF64
    μᵣin::ComplexF64
    β₁in::SV2
    β₂in::SV2
    ϵᵣout::ComplexF64
    μᵣout::ComplexF64
    β₁out::SV2
    β₂out::SV2
end

function append_result_data(fname, gname, result)
    jldopen(fname, "a") do fid
        group = JLD2.Group(fid, gname)
        group["result"] = result
    end
    return    
end

function read_result_file(fname::AbstractString)::Vector{Result}
    dat = load(fname) # a Dict
    ks = collect(keys(dat))
    sort!(ks, by = x -> parse(Int,split(x, '/')[1]))
    Result[dat[k] for k in ks]
end

function runit(n1=1)
    infile = "pssfss.res"
    outfile = "test.res"
    isfile(outfile) && rm(outfile)
    results = read_result_file(infile)
    for k = n1:length(results)
        println(k)
        gname = string(k)
        append_result_data(outfile, gname, results[k])
    end
end

end # module Outputs
##############################################

end # module PSSFSS
    