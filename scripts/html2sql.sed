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
  s,.*table/tr/td/div/div/div/div=,,
  Ta
  :g
  s/^\([0-9]\{4\}\.\)\([0-9]\{1,2\}\)$/\10\2/
  tg
  p
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
  s,.*table/tr/td/div/div/div/div=\(..\)\.\(..\)\.\(....\),\3-\2-\1,p
  Te
}
