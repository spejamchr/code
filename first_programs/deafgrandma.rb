puts 'HELLO THERE SWEETIE! GRANNY ALWAYS LIKES YOUR VISITS!'
response = gets.chomp
while true
  if response == 'BYE'
    puts 'YOU WOULDN\'T LEAVE YOUR POOR GRANDMA, WOULD YOU?'
    response = gets.chomp
    if response == 'BYE'
      puts 'NO NO PLEASE DON\'T GO!'
      response = gets.chomp
      if response == 'BYE'
        puts 'WELL AT LEAST COME BACK SOON, THEN!'
        break
      end
    end
  else
    if response == response.upcase
      date = (rand(20) + 1930 )
      puts 'NO, NOT SINCE ' + date.to_s + '!'
    else
      puts 'HUH?! SPEAK UP, SONNY!'
    end
    response = gets.chomp
  end
end

