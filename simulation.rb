require 'bigdecimal'
require 'matrix'

MTTF = BigDecimal.new(300000)
MTTR = BigDecimal.new(60)
DT = BigDecimal.new(1)
C = BigDecimal.new("0.9")

LAMBDA = 1 / MTTF
MI = 1 / MTTR

A =  Matrix[
  [1 - LAMBDA * DT,       MI * DT,                   MI * DT,                   MI * DT],
  [LAMBDA * C * DT,       1 - LAMBDA * DT - MI * DT, 0,                         0],
  [0,                     LAMBDA * C * DT,           1 - LAMBDA * DT - MI * DT, 0],
  [(1 - C) * LAMBDA * DT, (1 - C) * LAMBDA * DT,     LAMBDA * DT,               1 - MI * DT]
]

@probabilities = Matrix.column_vector([1, 0, 0, 0])

def iteration_step
  p availability

  @probabilities = A * @probabilities
end

def availability
  probabilities_vector = @probabilities.column_vectors[0]
  p1 = probabilities_vector[0]
  p2 = probabilities_vector[1]
  p3 = probabilities_vector[2]

  p1 + p2 + p3
end
