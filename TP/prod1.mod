param n; #number of production cycles
param d{t in 1..n}; #demand
param f{t in 1..n}; #fixed production cost
param h{t in 1..n}; #storage cost
param p{t in 1..n}; #variable production cost

param M;

var x{1..n} >= 0;
var y{1..n} binary;
var s{0..n} >= 0;

# Objective

minimize cost :sum {t in 1..n} (y[t]*f[t] + x[t]*p[t] + h[t]*s[t]);
subject to production_cycle {t in 1..n}:
    s[t] = s[t-1] + x[t] - d[t];
subject to fixed_prod {t in 1..n}:
    x[t] <= y[t]*M;
subject to init:
    s[0] = 0;