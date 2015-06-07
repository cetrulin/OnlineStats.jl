module VarianceTest

using OnlineStats
using DataFrames
using FactCheck


facts("Variance") do
    context("Variance") do
        n1, n2 = rand(1:1_000_000, 2)
        n = n1 + n2
        x1 = rand(n1)
        x2 = rand(n2)
        x = [x1; x2]

        o = Variance(x1)
        @fact OnlineStats.name(o) => "OVar"
        @fact o.μ => roughly(mean(x1))
        @fact o.biasedvar => roughly(var(x1) * ((n1 -1) / n1), 1e-5)
        @fact o.n => n1

        update!(o, x2)
        @fact o.μ => roughly(mean(x))
        @fact o.biasedvar => roughly(var(x) * ((n -1) / n), 1e-5)
        @fact o.n => n

        o1 = Variance(x1)
        o2 = Variance(x2)
        o3 = merge(o1, o2)
        merge!(o1, o2)
        @fact o1.n => o3.n
        @fact o1.μ => roughly(o3.μ)
        @fact o1.biasedvar => roughly(o3.biasedvar)

        @fact mean(x) => roughly(mean(o1))
        @fact var(x) => roughly(var(o1), 1e-5)


        o = Variance()
        @fact o.μ => 0.0
        @fact o.biasedvar => 0.0
        @fact o.n => 0
        @fact nobs(o) => 0
        @fact mean(o) => 0.0
        @fact var(o) => 0.0
        @fact statenames(o) => [:μ, :σ², :nobs]
        @fact state(o) => Any[mean(o), var(o), nobs(o)]
        update!(o, x1)
        @fact mean(o) => roughly(mean(x1))
        @fact var(o)  => roughly(var(x1))
        @fact o.n => n1
        o1 = copy(o)
        @fact mean(o1) => roughly(mean(x1))
        @fact var(o1) => roughly(var(x1))
        @fact o.n => n1
        @fact nobs(o) => n1

        x = rand()
        o = Variance(x)
        @fact mean(o) => x
        @fact var(o) => 0.
        @fact nobs(o) => 1
        @fact std(o) => 0.

        @fact OnlineStats.if0then1(0.) => 1.
        @fact OnlineStats.if0then1(x) => x
        update!(o, rand(100))
        @fact OnlineStats.standardize(o, x) => (x - mean(o)) / std(o)
        @fact OnlineStats.unstandardize(o, x) => x * std(o) + mean(o)
        OnlineStats.standardize!(o, 0.)
        @fact nobs(o) => 102

        empty!(o)
        @fact mean(o) => 0.
        @fact var(o) => 0.

        o2 = Variance(rand(100))
        o = [o; o2]
        print(typeof(o))
#         OnlineStats.standardize!(o, rand(2))

        x = rand(100)
        o = Variance()
        updatebatch!(o, x)
        @fact mean(o) => mean(x)
        @fact var(o) => roughly(var(x))
    end

    context("Variances") do
        n = rand(1:1_000_000)
        p = rand(2:100)
        x1 = rand(n, p)
        o = Variances(x1)
        @fact statenames(o) => [:μ, :σ², :nobs]
        @fact state(o) => Any[mean(o), var(o), nobs(o)]
        @fact var(o) => roughly(vec(var(x1, 1)), 1e-5)
        @fact mean(o) => roughly(vec(mean(x1, 1)))
        @fact std(o) => roughly(vec(std(x1, 1)), 1e-5)

        x = rand(10)
        o = Variances(x)
        @fact mean(o) => x
        @fact var(o) => zeros(10)
        @fact std(o) => zeros(10)
        @fact OnlineStats.center(o, x) => zeros(10)
        @fact OnlineStats.uncenter(o, -x) => zeros(10)
        @fact OnlineStats.center!(o, x) => zeros(10)
        @fact nobs(o) => 2
        update!(o, rand(100, 10))
        @fact OnlineStats.standardize(o, x) => roughly( (x - mean(o)) ./ std(o))
        @fact OnlineStats.unstandardize(o, x) => roughly( x .* std(o) + mean(o))
        OnlineStats.standardize!(o, x)
        @fact nobs(o) => 103

        empty!(o)
        @fact mean(o) => zeros(10)
        @fact var(o) => zeros(10)
        @fact nobs(o) => 0

        x1 = rand(100, 4)
        x2 = rand(100, 4)
        x = [x1, x2]
        o1 = Variances(x1)
        o2 = Variances(x2)
        o3 = merge(o1, o2)
        merge!(o1, o2)
        @fact mean(o1) => mean(o3)
        @fact var(o1) => var(o3)

        @fact nobs(o1) => 200
        @fact mean(o1) => roughly(vec(mean([x1, x2], 1)))
        @fact std(o1) => roughly(vec(std([x1, x2], 1)), .01)

        x = rand(100, 5)
        o = Variances(5)
        updatebatch!(o, x)
        @fact mean(o) => vec(mean(x, 1))
        @fact var(o) => roughly(vec(var(x, 1)))
    end

end # facts
end # module
