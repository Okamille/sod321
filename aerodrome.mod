param filename symbolic;

param N;
param start;
param finish;
param Amin;
param Nregions;

param regions{i in 1..N};
param rmax;

param coordonnes{i in 1..N, k in 1..2};

param x1;
param x2;
param y1;
param y2;

param d{i in 1..N, j in 1..N};

# On définit les variables du problème

var x{i in 1..N, i in 1..N} binary;

for {i in 1..N} {
for {j in 1..N} {
    let x1 = coordonnes[i,1];
    let y1 = coordonnes[i,2];

    let x2 = coordonnes[j,1];
    let y2 = coordonnes[j,2];

    let d[i,j] = sqrt((x1 - x2)**2 + (y1 - y2)**2)
}
}

minimize distance:
sum{i in 1..N, j in 1..N} d[i,j]*x[i,j];

# Contrainte de visite unique

subject to uniquevisit1 {i in 1..N, i != start, i != finish}:
sum{j in 1..N} x[i,j] <= 1;

subject to uniquevisit2 {i in 1..N, i != start, i != finish}:
sum{j in 1..N} x[j,i] <= 1;

# Contrainte de partir de start

subject to startingstart1:
sum{j in 1..N} x[s,j] = 1;

subject to startingstart2:
sum{i in 1..N} x[i,s] = 0;

# Contrainte d'arriver à finish

subject to endingend1:
sum{i in 1..N} x[i, finish] = 1;

subject to endingend2:
sum{j in 1..N} x[finish, j] = 0;

# Quand on arrive à un aérodrome, il faut repartir de cet aérodrome

subject to noteleport {i in 1..N, i != start, i != finish}:
sum{j in 1..N} x[i,j] = sum{j in 1..N} x[j,i];

# Il faut visiter Amin aérodromes

subject to minaerodrome:
sum{i in 1..N, j in 1..N} x[i,j] >= Amin - 1;

