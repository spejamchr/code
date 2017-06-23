def recursive_shuffle beginning_list, shuffled_list
  if beginning_list.count <= 0                          #If the beginning is empty, just "puts" the shuffled.
    return shuffled_list
  end
  waiting_to_be_shuffled = []
  rand(beginning_list.count).times do                  #Take a random number of items from the beginning
    (waiting_to_be_shuffled.push (beginning_list.pop)) #and put them in the waiting list.
  end                                                  
  shuffled_list.push (beginning_list.pop) #Take the last remaining item in beginning, put it in shuffled.
  beginning_list.each do |leftovers|            #Take the leftover items in beginning, and put them  with 
    waiting_to_be_shuffled.push (leftovers)     #others that are waiting to be shuffled. It's backwards now.
  end
  recursive_shuffle waiting_to_be_shuffled.reverse, shuffled_list  #reverse the backwards list, and shuffle it.
end
  
class Array
  def to_shuffle                                      # This 'wraps' recursive_shuffle.
    recursive_shuffle self, []
  end
end

p [1,2,3,4,5,6,7,8,9,10,11,12,13].to_shuffle