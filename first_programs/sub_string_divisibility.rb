start = Time.new
results = []
prod = []
count = 0
(1..9).each do |a|
  ((0..9).to_a-[a]).each do |b|
    ((0..9).to_a-[a,b]).each do |c|
      ((0..9).to_a-[a,b,c,1,3,5,7,9]).each do |d|
        set3 = [0,1,2,3,4,5,6,7,8,9].map{|n| (c+d+n)%3 == 0 ? nil : n }.compact
        ((0..9).to_a-[a,b,c,d]-set3).each do |e|
          ((0..9).to_a-[a,b,c,d,e]-[1,2,3,4,6,7,8,9]).each do |f|
            set7=[0,1,2,3,4,5,6,7,8,9].map{|n| "#{e}#{f}#{n}".to_i%7==0 ? nil : n}.compact
            ((0..9).to_a-[a,b,c,d,e,f]-set7).each do |g|
              set11=[0,1,2,3,4,5,6,7,8,9].map{|n| "#{f}#{g}#{n}".to_i%11==0 ? nil : n}.compact
              ((0..9).to_a-[a,b,c,d,e,f,g]-set11).each do |h|
                set13=[0,1,2,3,4,5,6,7,8,9].map{|n| "#{g}#{h}#{n}".to_i%13==0 ? nil : n}.compact
                ((0..9).to_a-[a,b,c,d,e,f,g,h]-set13).each do |i|
                  set17=[0,1,2,3,4,5,6,7,8,9].map{|n| "#{h}#{i}#{n}".to_i%17==0 ? nil : n}.compact
                  ((0..9).to_a-[a,b,c,d,e,f,g,h,i]-set17).each do |j|
                    results << "#{a}#{b}#{c}#{d}#{e}#{f}#{g}#{h}#{i}#{j}".to_i
                    count += 1
                  end
                end
              end
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
puts count
