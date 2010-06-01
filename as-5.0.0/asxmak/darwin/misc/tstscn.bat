rm -f ../../../asxtst/asmt2blo.lst
../exe/as430 -glaxff ../../../asxtst/asmt2blo.asm
../exe/asxscn ../../../asxtst/asmt2blo.lst

rm ../../../asxtst/asmt2blo.lst
../exe/as740 -glaxff ../../../asxtst/asmt2blo.asm
../exe/asxscn ../../../asxtst/asmt2blo.lst

rm -f ../../../asxtst/asmt2bhi.lst
../exe/as1802 -glaxff ../../../asxtst/asmt2bhi.asm
../exe/asxscn ../../../asxtst/asmt2bhi.lst

rm -f ../../../asxtst/asmt2bhi.lst
../exe/as2650 -glaxff ../../../asxtst/asmt2bhi.asm
../exe/asxscn ../../../asxtst/asmt2bhi.lst

rm -f ../../../asxtst/asmt2blo.lst
../exe/as6500 -glaxff ../../../asxtst/asmt2blo.asm
../exe/asxscn ../../../asxtst/asmt2blo.lst

rm -f ../../../asxtst/asmt2bhi.lst
../exe/as6800 -glaxff ../../../asxtst/asmt2bhi.asm
../exe/asxscn ../../../asxtst/asmt2bhi.lst

rm -f ../../../asxtst/asmt2bhi.lst
../exe/as6801 -glaxff ../../../asxtst/asmt2bhi.asm
../exe/asxscn ../../../asxtst/asmt2bhi.lst

rm -f ../../../asxtst/asmt2bhi.lst
../exe/as6804 -glaxff ../../../asxtst/asmt2bhi.asm
../exe/asxscn ../../../asxtst/asmt2bhi.lst

rm -f ../../../asxtst/asmt2bhi.lst
../exe/as6805 -glaxff ../../../asxtst/asmt2bhi.asm
../exe/asxscn ../../../asxtst/asmt2bhi.lst

rm -f ../../../asxtst/asmt2bhi.lst
../exe/as6808 -glaxff ../../../asxtst/asmt2bhi.asm
../exe/asxscn ../../../asxtst/asmt2bhi.lst

rm -f ../../../asxtst/asmt2bhi.lst
../exe/as6809 -glaxff ../../../asxtst/asmt2bhi.asm
../exe/asxscn ../../../asxtst/asmt2bhi.lst

rm -f ../../../asxtst/asmt2bhi.lst
../exe/as6811 -glaxff ../../../asxtst/asmt2bhi.asm
../exe/asxscn ../../../asxtst/asmt2bhi.lst

rm -f ../../../asxtst/asmt2bhi.lst
../exe/as6812 -glaxff ../../../asxtst/asmt2bhi.asm
../exe/asxscn ../../../asxtst/asmt2bhi.lst

rm -f ../../../asxtst/asmt2bhi.lst
../exe/as6816 -glaxff ../../../asxtst/asmt2bhi.asm
../exe/asxscn ../../../asxtst/asmt2bhi.lst

rm -f ../../../asxtst/asmt2bhi.lst
../exe/as61860 -glaxff ../../../asxtst/asmt2bhi.asm
../exe/asxscn ../../../asxtst/asmt2bhi.lst

rm -f ../../../asxtst/asmt2blo.lst
../exe/as8085 -glaxff ../../../asxtst/asmt2blo.asm
../exe/asxscn ../../../asxtst/asmt2blo.lst

rm -f ../../../asxtst/asmt2bhi.lst
../exe/as8051 -glaxff ../../../asxtst/asmt2bhi.asm
../exe/asxscn ../../../asxtst/asmt2bhi.lst

rm -f ../../../asxtst/asmt2bhi.lst
../exe/asz8 -glaxff ../../../asxtst/asmt2bhi.asm
../exe/asxscn ../../../asxtst/asmt2bhi.lst

rm -f ../../../asxtst/asmt2blo.lst
../exe/asz80 -glaxff ../../../asxtst/asmt2blo.asm
../exe/asxscn ../../../asxtst/asmt2blo.lst

rm -f ../../../asxtst/asmt2blo.lst
../exe/asgb -glaxff ../../../asxtst/asmt2blo.asm
../exe/asxscn ../../../asxtst/asmt2blo.lst

rm -f ../../../asxtst/asmt3blo.lst
../exe/asez80 -glaxff ../../../asxtst/asmt3blo.asm
../exe/asxscn -3 ../../../asxtst/asmt3blo.lst

rm -f ../../../asxtst/asmt2blo.lst
../exe/asrab -glaxff ../../../asxtst/asmt2blo.asm
../exe/asxscn ../../../asxtst/asmt2blo.lst

rm -f ../../../asxtst/asmt2bhi.lst
../exe/asf2mc8 -glaxff ../../../asxtst/asmt2bhi.asm
../exe/asxscn ../../../asxtst/asmt2bhi.lst

rm -f ../../../asxtst/asmt2bhi.lst
../exe/as8xcxxx -glaxff ../../../asxtst/asmt2bhi.asm
../exe/asxscn ../../../asxtst/asmt2bhi.lst

rm -f ../../../asxtst/a24bit.lst
../exe/as8xcxxx -glaxff ../../../asxtst/a24bit.asm ../../../asxtst/asmt3bhi.asm
../exe/asxscn -3 ../../../asxtst/a24bit.lst
rm -f ../../../asxtst/asmt2bhi.lst
../exe/ash8 -glaxff ../../../asxtst/asmt2bhi.asm
../exe/asxscn ../../../asxtst/asmt2bhi.lst

rm -f ../../../asxtst/asmt2blo.lst
../exe/asavr -glaxff ../../../asxtst/asmt2blo.asm
../exe/asxscn ../../../asxtst/asmt2blo.lst
rm -f ../../../asxtst/a32bit.lst
../exe/asavr -glaxff ../../../asxtst/a32bit.asm ../../../asxtst/asmt4blo.asm
../exe/asxscn -4 ../../../asxtst/a32bit.lst

rm -f ../../../asxtst/asmt2bhi.lst
../exe/aspic -glaxff ../../../asxtst/asmt2bhi.asm
../exe/asxscn ../../../asxtst/asmt2bhi.lst
rm -f ../../../asxtst/a32bit.lst
../exe/aspic -glaxff ../../../asxtst/a32bit.asm ../../../asxtst/asmt4bhi.asm
../exe/asxscn -4 ../../../asxtst/a32bit.lst

rm -f ../../../asxtst/asmt2bhi.lst
../exe/ascheck -glaxff ../../../asxtst/asmt2bhi.asm
../exe/asxscn ../../../asxtst/asmt2bhi.lst

rm -f ../../../as430/t430.rel
rm -f ../../../as430/t430.lst
rm -f ../../../as430/t430.rst
../exe/as430 -gloaxff ../../../as430/t430.asm
../exe/asxscn ../../../as430/t430.lst
../exe/aslink -nxu ../../../as430/t430.rel
../exe/asxscn -i ../../../as430/t430.rst

rm -f ../../../as740/t740s.lst
../exe/as740 -glaxff ../../../as740/t740s.asm
../exe/asxscn ../../../as740/t740s.lst

rm -f ../../../as1802/t1802.lst
../exe/as1802 -glaxff ../../../as1802/t1802.asm
../exe/asxscn ../../../as1802/t1802.lst

rm -f ../../../as2650/t2650.rel
rm -f ../../../as2650/t2650.lst
rm -f ../../../as2650/t2650.rst
../exe/as2650 -gloaxff ../../../as2650/t2650.asm
../exe/asxscn ../../../as2650/t2650.lst
../exe/aslink -nxu -g xADDR=0 -g xBADD=0 -g xDATA2=0 -g xDATA8=0 -g xP=0 ../../../as2650/t2650.rel
../exe/asxscn -i ../../../as2650/t2650.rst

rm -f ../../../as6500/t6500.lst
../exe/as6500 -glaxff ../../../as6500/t6500.asm
../exe/asxscn ../../../as6500/t6500.lst
rm -f ../../../as6500/t6500s.lst
../exe/as6500 -glaxff ../../../as6500/t6500s.asm
../exe/asxscn ../../../as6500/t6500s.lst

rm -f ../../../as6800/t6800.lst
../exe/as6800 -glaxff ../../../as6800/t6800.asm
../exe/asxscn ../../../as6800/t6800.lst
rm -f ../../../as6800/t6800s.lst
../exe/as6800 -glaxff ../../../as6800/t6800s.asm
../exe/asxscn ../../../as6800/t6800s.lst

rm -f ../../../as6801/t6801.lst
../exe/as6801 -glaxff ../../../as6801/t6801.asm
../exe/asxscn ../../../as6801/t6801.lst
rm -f ../../../as6801/t6801s.lst
../exe/as6801 -glaxff ../../../as6801/t6801s.asm
../exe/asxscn ../../../as6801/t6801s.lst

rm -f ../../../as6804/t6804s.lst
../exe/as6804 -glaxff ../../../as6804/t6804s.asm
../exe/asxscn ../../../as6804/t6804s.lst

rm -f ../../../as6805/t6805s.lst
../exe/as6805 -glaxff ../../../as6805/t6805s.asm
../exe/asxscn ../../../as6805/t6805s.lst

rm -f ../../../as6808/t6808l.rel
rm -f ../../../as6808/t6808l.lst
rm -f ../../../as6808/t6808l.rst
../exe/as6808 -gloabxff ../../../as6808/t6808l.asm
../exe/asxscn ../../../as6808/t6808l.lst
../exe/aslink -nxu ../../../as6808/t6808l.rel
../exe/asxscn -i ../../../as6808/t6808l.rst
rm -f ../../../as6808/t6808g.rel
rm -f ../../../as6808/t6808g.lst
rm -f ../../../as6808/t6808g.rst
../exe/as6808 -gloabxff ../../../as6808/t6808g.asm
../exe/asxscn ../../../as6808/t6808g.lst
../exe/aslink -nxu -g extE=0 -g ix1E=0 -g ix2E=0 ../../../as6808/t6808g.rel
../exe/asxscn -i ../../../as6808/t6808g.rst

rm -f ../../../as6809/t6809.lst
../exe/as6809 -glaxff ../../../as6809/t6809.asm
../exe/asxscn ../../../as6809/t6809.lst

rm -f ../../../as6811/t6811.lst
../exe/as6811 -glaxff ../../../as6811/t6811.asm
../exe/asxscn ../../../as6811/t6811.lst
rm -f ../../../as6811/t6811s.lst
../exe/as6811 -glaxff ../../../as6811/t6811s.asm
../exe/asxscn ../../../as6811/t6811s.lst

rm -f ../../../as6812/t6812.lst
../exe/as6812 -glaxff ../../../as6812/t6812.asm
../exe/asxscn ../../../as6812/t6812.lst
rm -f ../../../as6812/t6812a.lst
../exe/as6812 -glaxff ../../../as6812/t6812a.asm
../exe/asxscn ../../../as6812/t6812a.lst
rm -f ../../../as6812/t6812b.lst
../exe/as6812 -glaxff ../../../as6812/t6812b.asm
../exe/asxscn ../../../as6812/t6812b.lst

rm -f ../../../as6816/t6816.lst
../exe/as6816 -glaxff ../../../as6816/t6816.asm
../exe/asxscn ../../../as6816/t6816.lst

rm -f ../../../as61860/t61860.lst
../exe/as61860 -glaxff ../../../as61860/t61860.asm
../exe/asxscn ../../../as61860/t61860.lst
rm -f ../../../as61860/t61860s.rel
rm -f ../../../as61860/t61860s.lst
rm -f ../../../as61860/t61860s.rst
../exe/as61860 -gloaxff ../../../as61860/t61860s.asm
../exe/asxscn ../../../as61860/t61860s.lst
../exe/aslink -nxu -g addr=0 -g reg=0 -g extrn=0 ../../../as61860/t61860s.rel
../exe/asxscn -i ../../../as61860/t61860s.rst

rm -f ../../../as8085/t8085.lst
../exe/as8085 -glaxff ../../../as8085/t8085.asm
../exe/asxscn ../../../as8085/t8085.lst

rm -f ../../../as8051/t8051.lst
../exe/as8051 -glaxff ../../../as8051/t8051.asm
../exe/asxscn ../../../as8051/t8051.lst

rm -f ../../../asz8/tz8.rel
rm -f ../../../asz8/tz8.lst
rm -f ../../../asz8/tz8.rst
../exe/asz8 -gloaxff ../../../asz8/tz8.asm
../exe/asxscn ../../../asz8/tz8.lst
../exe/aslink -nxu ../../../asz8/tz8.rel
../exe/asxscn -i ../../../asz8/tz8.rst

rm -f ../../../asz80/tz80.lst
../exe/asz80 -glaxff ../../../asz80/tz80.asm
../exe/asxscn ../../../asz80/tz80.lst

rm -f ../../../asgb/tgb.lst
../exe/asgb -glaxff ../../../asgb/tgb.asm
../exe/asxscn ../../../asgb/tgb.lst

rm -f ../../../asez80/tez80.rel
rm -f ../../../asez80/tez80.lst
rm -f ../../../asez80/tez80.rst
../exe/asez80 -gloaxff ../../../asez80/tez80.asm
../exe/asxscn -3 ../../../asez80/tez80.lst
../exe/aslink -nxu -g varx=0 ../../../asez80/tez80.rel
../exe/asxscn -3i ../../../asez80/tez80.rst

rm -f ../../../asrab/trabl.rel
rm -f ../../../asrab/trabl.lst
rm -f ../../../asrab/trabl.rst
../exe/asrab -gloabxff ../../../asrab/trabl.asm
../exe/asxscn ../../../asrab/trabl.lst
../exe/aslink -nxu ../../../asrab/trabl.rel
../exe/asxscn ../../../asrab/trabl.rst
rm -f ../../../asrab/trabg.rel
rm -f ../../../asrab/trabg.lst
rm -f ../../../asrab/trabg.rst
../exe/asrab -gloabxff ../../../asrab/trabg.asm
../exe/aslink -nxu -g offset=0x33 -g n=0x20 -g mn=0x0584 ../../../asrab/trabg.rel
../exe/asxscn ../../../asrab/trabg.rst

rm -f ../../../asf2mc8/tf2mc8.rel
rm -f ../../../asf2mc8/tf2mc8.lst
rm -f ../../../asf2mc8/tf2mc8.rst
../exe/asf2mc8 -gloaxff ../../../asf2mc8/tf2mc8.asm
../exe/asxscn ../../../asf2mc8/tf2mc8.lst
../exe/aslink -nxu -g dirx=0 -g extx=0 -g offx=0 -g vx=0 -g bx=0 -g v22x=0 -g v5678x=0 ../../../asf2mc8/tf2mc8.rel
../exe/asxscn -i ../../../asf2mc8/tf2mc8.rst

rm -f ../../../as8xcxxx/t80c390.lst
../exe/as8xcxxx -glaxff ../../../as8xcxxx/t80c390.asm
../exe/asxscn -3 ../../../as8xcxxx/t80c390.lst

rm -f ../../../ash8/th8.lst
../exe/ash8 -glaxff ../../../ash8/th8.asm
../exe/asxscn ../../../ash8/th8.lst

rm -f ../../../asavr/tavr.rel
rm -f ../../../asavr/tavr.lst
rm -f ../../../asavr/tavr.rst
../exe/asavr -gloaxff ../../../asavr/tavr.asm
../exe/aslink -nxu -g zero=0 -g blbl=s_bra -g rlbl=s_rjmp ../../../asavr/tavr.rel
../exe/asxscn -4i ../../../asavr/tavr.rst

rm -f ../../../aspic/p12c5xx/tp12c5xx.lst
../exe/aspic -glaxff ../../../aspic/p12c5xx/tp12c5xx.asm
../exe/asxscn ../../../aspic/p12c5xx/tp12c5xx.lst
rm -f ../../../aspic/p12c67x/tp12c67x.lst
../exe/aspic -glaxff ../../../aspic/p12c67x/tp12c67x.asm
../exe/asxscn ../../../aspic/p12c67x/tp12c67x.lst
rm -f ../../../aspic/p16cxxx/tpic16cx.lst
../exe/aspic -glaxff ../../../aspic/p16cxxx/tpic16cx.asm
../exe/asxscn ../../../aspic/p16cxxx/tpic16cx.lst
rm -f ../../../aspic/p17cxxx/tpic17cx.lst
../exe/aspic -glaxff ../../../aspic/p17cxxx/tpic17cx.asm
../exe/asxscn ../../../aspic/p17cxxx/tpic17cx.lst
rm -f ../../../aspic/p18cxxx/tpic18cx.lst
../exe/aspic -glaxff ../../../aspic/p18cxxx/tpic18cx.asm
../exe/asxscn -4 ../../../aspic/p18cxxx/tpic18cx.lst

