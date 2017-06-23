# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""
class Factorial:
    """
    Finds factorial.

    Simple usage:
        Factorial(30).result #=> 26525285981219105863630848000000

    More permanent usage:
        a = Factorial(30)
        a.result #=> 26525285981219105863630848000000
        a.length #=> 33
        a.number #=> 30
    """
    table = {0: 1}
    limit = 500

    def __init__(self, number):
        self.number = number
        self.result = self.factorial(number)
        self.length = len(str(self.result))

    def factorial(self, n):
        """Used to find the factorial of the given number. Expects an integer
        and returns an integer"""
        if n == 0:
            return 1
        elif n in self.table:
            return self.table[n]
        elif n > self.limit and n - self.limit > max(self.table):
            self.table[n - self.limit] = self.factorial(n - self.limit)
        return n * self.factorial_non_save(n - 1)

    def factorial_non_save(self, n):
        if n == 0:
            return 1
        elif n in self.table:
            return self.table[n]
        else:
            return n * self.factorial_non_save(n-1)


    def sef_number(self,n):
        self.number = n

print(Factorial(100000).length)
