from scipy.optimize import broyden1
import matplotlib.pyplot as plt
import numpy as np
from mpl_toolkits.mplot3d import Axes3D


x1 = 1 / 4 - 17**0.5 / 4
x2 = 1 / 4 + 17**0.5 / 4

y1, y2 = x1**2, x2**2

x0, y0 = 0, 0

d1 = (x1**2 + y1**2)**0.5
d2 = (x2**2 + y2**2)**0.5
d12 = ((x1 - x2)**2 + (y1 - y2)**2)**0.5

def _d1(a, b, c):
    disc = (b**2 - 4 * a * c)**0.5
    top = (2 * (disc + b)**2 * (disc * b + 2 * a**2 - 2 * a * c + b**2))**0.5
    return top / (4 * a**2)

def _d2(a, b, c):
    disc = (b**2 - 4 * a * c)**0.5
    top = (-2 * (disc - b)**2 * (disc * b - 2 * a**2 + 2 * a * c - b**2))**0.5
    return top / (4 * a**2)

def _d12(a, b, c):
    return (-4 * a**3 * c + a**2 * b**2 - 4 * a * b**2 * c + b**4)**0.5 / a**2

a = 1
b = -1 / 2
c = -1

print(_d1(a, b, c))
print(d1)

print(_d2(a, b, c))
print(d2)

print(_d12(a, b, c))
print(d12)

def solve_for_abc(arr):
    a, b, c = arr
    d1_ = d1 - _d1(a, b, c)
    d2_ = d2 - _d2(a, b, c)
    d12_ = d12 - _d12(a, b, c)
    return (d12_, d1_, d2_)

abc = broyden1(solve_for_abc, [1, -1, -1])
# print(abc)

# print(solve_for_abc(abc))


def equ(a, b, c):
    def quad(x):
        return a * x**2 + b * x + c
    return quad

qua = equ(1, 0, 0)

x1 = -1
x0 = 0

y1, y0 = qua(x1), qua(x0)
d1 = (x1**2 + y1**2)**0.5
ratios = []
chords = []
d1s = []
d2s = []

n = 100
maxi = 0.1
step = maxi / n

ratios = np.zeros([n, n])
chords = np.zeros([n, n])
d1s = np.zeros([n, n])
d2s = np.zeros([n, n])
x1s = np.zeros([n, n])
x2s = np.zeros([n, n])
y1s = np.zeros([n, n])
y2s = np.zeros([n, n])

for i in range(n):
    x1 = -(i + 1) * step
    y1 = qua(x1)
    d1 = (x1**2 + y1**2)**0.5
    for j in range (n):
        x2 = (j + 1) * step
        y2 = qua(x2)
        ratios[i, j] = (x2 / -x1)
        chords[i, j] = (((x1 - x2)**2 + (y1 - y2)**2)**0.5)
        d1s[i, j] = (d1)
        d2s[i, j] = ((x2**2 + y2**2)**0.5)
        x1s[i, j] = -x1
        x2s[i, j] = x2
        y1s[i, j] = y1
        y2s[i, j] = y2

d2sd1s = d2s / d1s

fig = plt.figure()
ax = fig.add_subplot(1, 1, 1, projection='3d')

nums = 1-(ratios.max()-ratios)/(ratios.max()-ratios.min())
ax.plot_surface(x1s,
                x2s,
                ratios,
                linewidth=0,
                facecolors=plt.cm.jet(nums),
                rstride=5,
                cstride=5,
                alpha=0.3)

plt.show()
