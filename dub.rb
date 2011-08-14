#!/usr/bin/ruby

#
# Like du, but sorts your output by size. Compare:
#
#
#
# > du -h -d 1 
# 1.4M	./.git
# 1.4M	./img
# 100K	./js
# 2.9M	.
#
# > dub
# 2.9M .
# 1.4M ./img
# 1.4M ./.git
# 100.0K ./js

duout = `du -h -d 1`

comps = []

duout.each do |l|
  l =~ /\s*(\d+(\.\d+)?)(\w)\s+(.*)$/
  size = $1
  unit = $3
  path = $4
  comps << [size.to_f, unit, path]
end

unit_to_mult = {
  'K' => 1,
  'M' => 2**10,
  'G' => 2**20
}

comps.sort! do |a, b|
  (b[0] * unit_to_mult[b[1]]) <=> (a[0] * unit_to_mult[a[1]])
end

comps.each do |(size,unit,path)|
  puts "#{size}#{unit} #{path}"
end
