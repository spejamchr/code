matrix = Matrix[ [1, 2], [3, 4] ]
 # =>  1 2
 #     3 4
matrix.each(:diagonal).to_a # [1,4]