#!/usr/bin/ruby

def run
  wccmd = `find . -ipath #{ARGV[0]} -exec wc -l {} \\;`

  comps = []

  total = 0
  wccmd.split(/\n/).each do |l|
    l =~ /\s*(\d+(\.\d+)?)\s+(.*)$/
    size = $1
    path = $3
    comps << [size.to_i, path]
    total += size.to_i
  end

  comps.sort! do |a, b|
    b[0] <=> a[0]
  end

  comps.each do |(size,path)|
    printf( "%d %s\n", size, path)
  end

  puts "Total: #{total}"
end

run
