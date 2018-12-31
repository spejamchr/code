import numpy as np

class Grid():
    columns = 160
    rows = 24

    def __init__(self):
        self.grid = np.zeros([self.rows, self.columns])

    def display(self):
        for row in self.grid:
            print(''.join(row))

    def infect(self):
        np.random.choice(self.rows)
        self.grid[np.random.choice(self.rows), np.random.choice(self.columns)] = 1

g = Grid()
g.display()
g.infect()
g.display()
