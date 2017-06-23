import math
import sympy as sp
import numpy as np
import matplotlib.pyplot as plt
from sympy.integrals import laplace_transform as lap

t, s = sp.symbols('t s')
ft = sp.sin(t)
fs = lap(ft, t, s)[0]


class Diff():
    def __init__(self, func, x):
        self.func = func
        self.x = x
        self.bank = {}

    def add(self, n):
        if n not in self.bank:
            print('Adding bank for n:', n)
            self.bank[n] = sp.diff(self.func, self.x, n)
            print('Bank added for n:', n)

    def dif(self, x, n):
        return self.bank[n].evalf(subs={self.x: x})

    def val(self, x, n):
        f = self.dif(n/x, n)
        a = (-1)**n/math.factorial(n)
        b = (n/x)**(n+1)
        return a * b * f

    def plot(self, xs, n):
        print('\nStarting with n:', n)
        self.add(n)
        ys = [self.val(x, n) for x in xs]
        plt.plot(xs, ys)
        print('Finished with n:', n)

d = Diff(fs, s)

b = 0.01
e = 0.5 * np.pi
xs = np.linspace(b, e, 200)

d.plot(xs, int(math.exp(0)))
d.plot(xs, int(math.exp(1)))
d.plot(xs, int(math.exp(2)))
d.plot(xs, int(math.exp(3)))
d.plot(xs, int(math.exp(5)))

y = [ft.evalf(subs={t: x}) for x in xs]
plt.plot(xs, y, 'k:')

plt.show()
