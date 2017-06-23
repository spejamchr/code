require 'prime'

def is_prime? num
  if num <= 1
    return nil
  elsif num == 2
    return true
  end
  factor = 3
  while factor <= num/2
    if num % factor == 0
      return false
    else
      factor += 2
    end
  end
  return true
end

def factor_method num, master, time, limit
  if Time.now - time > limit
    puts "Request timed out at #{limit} seconds"
    return nil
  end
  if Prime.prime?(num)
    master.push(num)
  elsif num % 2 == 0
    factor1 = 2
    factor2 = num/2
    factor_method factor1, master, time, limit
    factor_method factor2, master, time, limit
  else
    factor1 = 3
    while num % factor1 != 0
      factor1 += 2
    end
    factor2 = num/factor1
    factor_method factor1, master, time, limit
    factor_method factor2, master, time, limit
  end
  return master
end

def factor number, limit
  array = []
  factor_method(number, array, Time.now, limit)
end



puts factor(600851475143, 3.036).to_s


