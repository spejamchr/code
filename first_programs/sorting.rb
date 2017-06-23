#puts 'Enter names, please, and I will put them in alphabetical order.'
#names = []
#entry = ' '
#while entry != ''
#  entry = gets.chomp
#  names.push entry
#  end
#goodlist = []
#names.each do |name|
#  goodlist.push name.capitalize
#  end
#puts goodlist.to_s
#puts 'Here are the names in alphabetical order:'

def sort some_array
  recursive_sort some_array, []
end

def recursive_sort unsorted_array, sorted_array
  if unsorted_array.length <= 0
    return sorted_array
  end
  still_unsorted = []
  smallest = unsorted_array.pop
  unsorted_array.each do |tested_object|
    if smallest > tested_object
      still_unsorted.push smallest
      smallest = tested_object
    else
      still_unsorted.push tested_object
    end
  end
  sorted_array.push smallest
  recursive_sort still_unsorted, sorted_array
end

puts sort ["Susan", "Spencer", "Spencer", "Ryan",
           "David", "Brian", "Clarissa", "Heather", 
           "James", "Manny", "Quincy", "Zachary"]