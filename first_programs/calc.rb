kelsie = {}
spencer = {}
spencers_address = {}
kelsies_address = {}

spencer["name"] = "Spencer"
spencer["age"] = 21
spencer["weight"] = 175
spencer["height"] = '5\' 11 1/2"'
spencer["girlfriend"] = kelsie
spencer["address"] = spencers_address
spencer["favorite_color"] = 'Green'

kelsie["name"] = "Kelsie"
kelsie["age"] = 20
kelsie["weight"] = "Don't you dare ask"
kelsie["height"] = "slightly short"
kelsie["boyfriend"] = spencer
kelsie["address"] = kelsies_address
kelsie["favorite_color"] = "purple"

spencers_address["street"] = "1343 Carter Rd"
spencers_address["city"] = "Springtown"
spencers_address["state"] = "TX"
spencers_address["zip"] = 76082
spencers_address["country"] = "USA"

kelsies_address["street"] = "?"
kelsies_address["city"] = "?"
kelsies_address["state"] = "?"
kelsies_address["zip"] = "?"
kelsies_address["country"] = "Uruguay"

puts spencer.to_s
puts Time.new

puts
