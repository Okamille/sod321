param N; #number of airports
param Nstart; #start of race
param Nfinish; #end of race

param G; #number of airports to go to
param regions; #number of regions
param r{i in 1..N} #region of airport i

param R; #max radius that an airplane can fly

# Coordinates of airports
param X{i in 1..N}
param Y{i in 1..N}