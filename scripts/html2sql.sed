#!/bin/sed

/h2=/ {
  :f
  n
  s,^.*table/tr/td/div/h2=,,p
  Tf
}

/div=Geschäftsnummer/ {
  :a
  n
  s,.*table/tr/td/div/div/div/div=,,p
  Ta
}
/div=Geschäftsart/ {
  :b
  n
  s,.*table/tr/td/div/div/div/div=,,p
  Tb
}
/div=Status/ {
  :d
  n
  s,.*table/tr/td/div/div/div/div=,,p
  Td
}
/div=Eingangsdatum/ {
  :e
  n
  s,.*table/tr/td/div/div/div/div=,,p
  Te
}
