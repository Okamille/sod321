import matplotlib.pyplot as plt

filename = 'example.dat'

f = open(filename, 'r')

nb_airport = int(f.readline())
start_index = int(f.readline())
end_index = int(f.readline())
Amin = int(f.readline())
nb_region = int(f.readline())

f.readline()

regions = f.readline().split(' ')
regions = [int(region) for region in regions]

f.readline()

R = int(f.readline())

f.readline()

coordinates = []

for index in range(nb_airport):
    a = f.readline().split(' ')
    coordinates.append((int(a[0]), int(a[1])))

plt.figure()

for element in coordinates:
    plt.scatter(*element)
