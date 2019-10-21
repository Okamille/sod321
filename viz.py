import matplotlib.pyplot as plt
import json

instance = 'aerodrome_40_1'
resolution = 'exponential'

data_file = 'instances/%s.txt' % instance
result_file = 'results/%s/%s.json' % (resolution, instance)

f = open(data_file)
N = int(f.readline())
start = int(f.readline())
end = int(f.readline())
Amin = f.readline()
Nregions = f.readline()

X, Y = [], []

f.readline()

regions = f.readline().split(' ')[:-1]
regions = [int(region) + 1 for region in regions]
regions[start - 1] = 0
regions[end - 1] = 0

f.readline()
Rmax = f.readline()
f.readline()

for i in range(N):
    line = f.readline()
    line = line.split(' ')
    X.append(int(line[0]))
    Y.append(int(line[1]))
f.close()

plt.scatter(x=X, y=Y, c=regions)

visited = []

with open(result_file) as f:
    data = json.load(f)
    visited = data['path']

for i in range(1,len(visited)):
    node1 = visited[i-1] - 1
    node2 = visited[i] - 1
    plt.plot([X[node1], X[node2]], [Y[node1], Y[node2]], c='b')