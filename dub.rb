#!/usr/bin/ruby

color_highlighting = false
  
ARGV.each do |arg|
  if arg == '-c'
    color_highlighting = true
  end
end

duout = `du -h -d 1`

comps = []

duout.split(/\n/).each do |l|
  l =~ /\s*(\d+(\.\d+)?)(\w)\s+(.*)$/
  size = $1
  unit = $3
  path = $4
  comps << [size.to_f, unit, path]
end

unit_to_mult = {
  'B' => 1,
  'K' => 2**10,
  'M' => 2**20,
  'G' => 2**30
}

comps.sort! do |a, b|
  (b[0] * unit_to_mult[b[1]]) <=> (a[0] * unit_to_mult[a[1]])
end

BLACK = "\033[30m"
RED = "\033[31m"
RED_BLINK = "\033[5;31m"
GREEN = "\033[32m"
YELLOW = "\033[33m"
BLUE = "\033[34m"
MAGENTA = "\033[35m"
CYAN = "\033[36m"
WHITE = "\033[37m"
RESET_COLOR = "\033[0m"

if color_highlighting
  comps.each do |(size,unit,path)|
    case unit
    when 'G'
      output_color = RED 
    when 'M'
      output_color = YELLOW
    when 'K'
      output_color = CYAN 
    when 'B'
      output_color = GREEN 
    else 
      output_color = BLACK 
    end

    printf( "%s%10.1f%s %s%s\n",output_color, size, unit, path,RESET_COLOR)
  end
else
  comps.each do |(size,unit,path)|
    printf( "%10.1f%s %s\n",size, unit, path)
  end
end
