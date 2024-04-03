library(Rfa)
ff=FAopen("ELSCFABOFALBC020")
for (ii in 1:87) {
  fld=sprintf('S%03iTEMPERATURE',ii)
  zz=FAdec(ff,fld)
  zz=zz-2
  FAenc(ff,fld,zz,nbits=18)        # nbits argument is necessary for some fields (e.g. SURFZ0.FOIS.G)
}
 

