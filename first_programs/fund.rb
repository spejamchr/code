space1 = 0
spaceT = 50
speed = 0.05
linesA = 0
linesT = 39


def move_right spaceT, speed, linesT, linesA, message
  start = Time.now
  space1 = 0
  space2 = spaceT
  linesB = linesT-linesA
  while space2 > 0
    s1 = ' ' * space1
    s2 = ' ' * space2
    lA = "\n" * linesA
    lB = "\n" * linesB
    if Time.now - start >= speed
      start = Time.now
      puts "#{ lA }#{ s1 }#{message}#{ s2 }#{ lB }"
      space1 += 1
      space2 -=1
    end
  end
end

def move_left spaceT, speed, linesT, linesA, message
  start = Time.now
  space1 = spaceT
  space2 = 0
  linesB = linesT-linesA
  while space1 > 0
    s1 = ' ' * space1
    s2 = ' ' * space2
    lA = "\n" * linesA
    lB = "\n" * linesB
    if Time.now - start >= speed
      start = Time.now
      puts "#{ lA }#{ s1 }#{message}#{ s2 }#{ lB }"
      space1 -= 1
      space2 +=1
    end
  end
end


while linesA < linesT
  move_right(spaceT,speed,linesT,linesA,"SPENCER")
  linesA += 1
  move_left(spaceT,speed,linesT,linesA,"SPENCER")
  linesA += 1
end