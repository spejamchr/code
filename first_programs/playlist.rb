Dir.chdir '/Users/spencer/Desktop/playlist'
song_names = Dir['/Users/spencer/Desktop/music mp3/**/*.mp3']

def shuffle list                                      # This 'wraps' recursive_shuffle.
  recursive_shuffle list, []
end

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
  recursive_shuffle waiting_to_be_shuffled.reverse, shuffled_list  #Reverse the backwards list, and
end                                                                #continue shuffling it.

shuffled_songs = shuffle song_names

filename = "MY PLAYLIST.m3u"
File.open filename, 'w' do |f|
  shuffled_songs.each do |song|
    f.write(song + "\n")
  end
end
