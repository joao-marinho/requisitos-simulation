require 'bigdecimal'
require 'matrix'
require 'benchmark'
require 'optparse'

options = {}
OptionParser.new do |opts|

  opts.on("-c VALUE") do |c|
    options[:c] = c
  end
end.parse!

BigDecimal.limit(1000)

MAX_ITERATIONS = 50000000
MTTF = BigDecimal.new(300000)
MTTR = BigDecimal.new(60)
DT = BigDecimal.new(1)
C = BigDecimal.new(options[:c] || "0.5")

LAMBDA = 1 / MTTF
MI = 1 / MTTR

A =  Matrix[
  [1 - LAMBDA * DT,       MI * DT,                   MI * DT,                   MI * DT],
  [LAMBDA * C * DT,       1 - LAMBDA * DT - MI * DT, 0,                         0],
  [0,                     LAMBDA * C * DT,           1 - LAMBDA * DT - MI * DT, 0],
  [(1 - C) * LAMBDA * DT, (1 - C) * LAMBDA * DT,     LAMBDA * DT,               1 - MI * DT]
]

@data = []
@probabilities = Matrix.column_vector([1, 0, 0, 0])

p "MTTF #{MTTF.to_s}"
p "MTTR #{MTTR.to_s}"
p "DT #{DT.to_s}"
p "C #{C.to_s}"

def iteration_step
  @probabilities = A * @probabilities
  @data.push(availability)
end

def availability
  probabilities_vector = @probabilities.column_vectors[0]
  p1 = probabilities_vector[0]
  p2 = probabilities_vector[1]
  p3 = probabilities_vector[2]

  p1 + p2 + p3
end

def reached_max_iterations?
  @data.length > MAX_ITERATIONS
end

def the_last_data_values_are_equal?
  return false if @data.length < 100
  last_element = @data.last
  @data.last(100).all? do |value|
    value == last_element
  end
end

def should_continue?
  !reached_max_iterations? and !the_last_data_values_are_equal?
end

@data.push(availability)
while should_continue?
  p(@data.last) if (@data.length % 10000) == 0
  iteration_step
end
