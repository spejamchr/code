start = Time.new
results = []
prod = []
verd = []
(1..9).each do |a|
  ((1..9).to_a-[a]).each do |b|
    ((1..9).to_a-[a,b]).each do |c|
      ((1..9).to_a-[a,b,c]).each do |d|
        ((1..9).to_a-[a,b,c,d]).each do |e|

          prod[0] = [a].join.to_i * [b,c,d,e,].join.to_i
          prod[1] = [a,b].join.to_i * [c,d,e,].join.to_i

          mults = [a,b,c,d,e,]
          (0...prod.count).each do |i|
            product = prod[i].to_s.split('').map{|p|p.to_i}
            verd[i] = ((product & mults).empty?) &&
              (product.count + mults.count == 9) &&
              (product & product == product) &&
              !(product.include?(0))
          end
          (0...prod.count).each do |i|
            if verd[i] == true
              results << prod[i]
            end
          end
        end
      end
    end
  end
end
puts "Took #{Time.new-start} seconds"
puts
puts results.uniq.inject(:+)
puts results.uniq.join(' ')