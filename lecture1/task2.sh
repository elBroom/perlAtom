perl -naF';' -e 'if($F[4] > 1024*1024){print $F[8]; $i++;};END{print "\n$. ".($i+0)}'