#!/bin/bash
#PBS -N ALARO_SURFEX
#PBS -q short
#PBS -l walltime=3:00:00
#PBS -l select=6:ncpus=24:mpiprocs=24:ompthreads=1:mem=240gb
#PBS -joe
#PBS -o /path/to/output/directory/ALARO_SURFEX.out
#PBS -e /path/to/error/directory/ALARO_SURFEX.err
#PBS -l place=scatter:excl
#PBS -m a

# Source the configuration file
source /path/to/configuration.sh

# Define functions from the provided scripts
function e927 {
  set -x
  
  cDATE=$1
  cHHH=$2
  cCPLNR=$3
  cEXP=$4
  
  ANA_DATE=$cDATE
  let cTIME=10#$cHHH
  while [ $cTIME -ge 0024 ]; do
    ANA_DATE=`$DECDATE ${ANA_DATE} +1`
    let cTIME=10#$cTIME-10#24
  done
  
  cYYYY=`echo $ANA_DATE | cut -c1-4`
  cMM=`echo $ANA_DATE | cut -c5-6`
  cDD=`echo $ANA_DATE | cut -c7-8`
  
  if [[ $cTIME -le 9 ]]; then
    cTIME=0${cTIME}
  fi
  
  if [ ! -f "${LBCDIR}/LBC_AFRI_${ANA_DATE}_${cTIME}" ]; then
    scp $REMOTE:$COUPLING/LBC_AFRI_12.5km_l46_${cYYYY}${cMM}.tar ${LBCDIR}/
    tar -xf ${LBCDIR}/LBC_AFRI_12.5km_l46_${cYYYY}${cMM}.tar -C ${LBCDIR}/
    rm -v ${LBCDIR}/LBC_AFRI_12.5km_l46_${cYYYY}${cMM}.tar
  fi
  
  if [[ $cHHH = 000 ]]; then
    if [[ ! -d prepSurf ]]; then
      mkdir prepSurf
    fi
    rm -rf prepSurf/*
    
    cd prepSurf
    
    scp ${CLIM_TRG}${cMM} const.clim.${cEXP}
    scp ${CLIM_LBC}${cMM} Const.Clim
    scp $PGDFILE const.clim.sfx.${cEXP}
    scp $REMOTE:${DATADIR_ECOCLIMAP}/*.bin .
    scp $REMOTE:${DATADIR_RRTM}/RADRRTM .
    scp $REMOTE:${DATADIR_RRTM}/RADSRTM .
    scp $REMOTE:${DATADIR_RRTM}/MCICA .
    
    echo 'echo MONITOR: $* >&2' >monitor.needs
    chmod +x monitor.needs
    
    cat ${NAM927_SFX} ${NAM927_LVL} | grep -v '^!' | \
      sed -e "s/!.*//" \
          -e "s/{nproc}/${NPROC}/g" \
          -e "s/{domain}/${cEXP}/g" \
          -e "s/{levels}/${LEVELS}/g" \
    > fort.4
    
    ln -sf $LBCDIR/LBC_AFRI_${ANA_DATE}_${cTIME} ICMSHABOFINIT
    ln -sf ${MASTER} ./MASTER
    
    /usr/bin/time mpiexec_mpt -np ${NPROC} omplace ./MASTER > log.out 2>log.err
    cp PFABOF${cEXP}+0000.sfx ../ICMSH${cEXP}INIT.sfx
    cp const.clim.sfx.${cEXP} ../Const.Clim.sfx 
    cp const.clim.${cEXP} ../Const.Clim
    cp const.clim.${cEXP} ../const.clim.${cEXP}
    cp ecoclimapI_covers_param.bin ../ecoclimapI_covers_param.bin
    cp ecoclimapII_eu_covers_param.bin ../ecoclimapII_eu_covers_param.bin
    cd ..
  fi
  
  if [[ ! -d prep ]]; then 
    mkdir prep
  fi
  
  rm prep/*
  cd prep
  
  scp ${CLIM_TRG}${cMM} const.clim.${cEXP}
  scp ${CLIM_LBC}${cMM} Const.Clim
  scp $REMOTE:${DATADIR_RRTM}/RADRRTM .
  scp $REMOTE:${DATADIR_RRTM}/RADSRTM .
  scp $REMOTE:${DATADIR_RRTM}/MCICA .
  
  echo 'echo MONITOR: $* >&2' >monitor.needs
  chmod +x monitor.needs
  echo $NPROC
  
  . $ENV
  
  cat ${NAM927} ${NAM927_LVL} | grep -v '^!' | \
    sed -e "s/!.*//" \
        -e "s/{nproc}/${NPROC}/g" \
        -e "s/{domain}/${cEXP}/g" \
        -e "s/{levels}/${LEVELS}/g" \
  > fort.4
  
  ln -sf $LBCDIR/LBC_AFRI_${ANA_DATE}_${cTIME} ICMSHABOFINIT
  ln -sf ${MASTER} ./MASTER
  
  /usr/bin/time mpiexec_mpt -np ${NPROC} omplace ./MASTER > log.out 2>log.err
  
  mv PFABOF${cEXP}+0000 ../ELSCF${cEXP}ALBC${cCPLNR}
  
  cd ..
}

function get_coupling {
  set -x
  
  COUPDATE=$1
  COUPRUN=$2
  NHOURS=$3
  COUPEXP=$4
  
  let NCOUP=10#${NHOURS}/3+10#1
  
  if [[ $NCOUP -le 99 ]]; then
    if [[ $NCOUP -le 9 ]]; then
      NCOUP=00${NCOUP}
    else
      NCOUP=0${NCOUP}
    fi
  fi
  
  CPLNR=0
  
  let CTIME=$COUPRUN
  
  if [[ $CTIME -le 99 ]]; then
    if [[ $CTIME -le 9 ]]; then
      CTIME=00${CTIME}
    else
      CTIME=0${CTIME}
    fi
  fi
  
  if [[ $CPLNR -le 99 ]]; then
    if [[ $CPLNR -le 9 ]]; then
      CPLNR=00${CPLNR}
    else
      CPLNR=0${CPLNR}
    fi
  fi
  
  while [ $CPLNR != $NCOUP ]; do
    e927 ${COUPDATE} $CTIME ${CPLNR} ${COUPEXP}
    
    let CPLNR=10#$CPLNR+1
    let CTIME=10#$CTIME+3
    
    if [[ $CTIME -le 99 ]]; then
      if [[ $CTIME -le 9 ]]; then
        CTIME=00${CTIME}
      else
        CTIME=0${CTIME}
      fi
    fi
    
    if [[ $CPLNR -le 99 ]]; then
      if [[ $CPLNR -le 9 ]]; then
        CPLNR=00${CPLNR}
      else
        CPLNR=0${CPLNR}
      fi
    fi
  done
  
  rm -f BC*
}

# Get the command-line arguments from environment variables
INIDATE=$INIDATE
STARTDATE=$STARTDATE
STOPDATE=$STOPDATE

if [ -z "$STOPDATE" ]; then
  STOPDATE=$STARTDATE
fi

echo "Kickstarting $STARTDATE to $STOPDATE from original $INIDATE"

DATE=$STARTDATE
RSTART=$INIDATE
echo ${RSTART}

. $ENV

while [ $DATE -le $STOPDATE ]; do
  YYYY=`echo $DATE | cut -c1-4`
  MM=`echo $DATE | cut -c5-6`
  DD=`echo $DATE | cut -c7-8`
  echo ${YYYY}
  echo ${MM}
  echo ${DD}
  
  if [[ ! -d $WORKDIR/${RSTART}/${YYYY}${MM}${DD} ]]; then
    mkdir -pv $WORKDIR/${RSTART}/${YYYY}${MM}${DD}
  fi
  
  rm -f $WORKDIR/${RSTART}/${YYYY}${MM}${DD}/*
  cd $WORKDIR/${RSTART}/${YYYY}${MM}${DD}
  
  pwd 
  ls
  
  NEXTDATE=`date -d "${DATE} + 1 day" +%Y%m%d`
  HOURRANGE=24
  
  echo $HOURRANGE
  
  if [[ ! -d $LBCDIR ]]; then 
    mkdir -pv $LBCDIR
  fi
  
  get_coupling $DATE ${RUNSTARTHH} $HOURRANGE $EXP
  
  if [ ${YYYY}${MM}${DD} -eq $RSTART ]; then
    rsync -l ELSCF${EXP}ALBC000 ICMSH${EXP}INIT
  else
    module purge
    source $ENVFAREP
    
    echo 'entering ALARO FAreplace'
    mkdir -p FArep
    cp ELSCF${EXP}ALBC000 FArep/newfields
    cp ${WORKDIR}/${RSTART}/${PREVYYYY}${PREVMM}${PREVDD}/ICMSH${EXP}+00${PREVHOURRANGE} FArep/original
    cd FArep
    cp ${NAMFAREP} fort.4
    ${FAREPLACE}/FAREPLACE_NEW
    cd ..
    mv FArep/original ICMSH${EXP}INIT
    rm -r FArep
    rm ${WORKDIR}/${RSTART}/${PREVYYYY}${PREVMM}${PREVDD}/ICMSH${EXP}+00${PREVHOURRANGE}
    
    echo 'entering SURFEX FAreplace'
    mkdir -p FArep2
    cp ELSCF${EXP}ALBC000 FArep2/indterremer
    cp ICMSH${EXP}INIT.sfx FArep2/newfields
    cp ${WORKDIR}/${RSTART}/${PREVYYYY}${PREVMM}${PREVDD}/ICMSH${EXP}+00${PREVHOURRANGE}.sfx FArep2/original
    cd FArep2
    cp ${NAMFAREPSFX} fort.4
    ${FAREPLACE}/FAREPLACE_NEW_SFX
    cd ..
    mv FArep2/original ICMSH${EXP}INIT.sfx
    rm -r FArep2
    rm ${WORKDIR}/${RSTART}/${PREVYYYY}${PREVMM}${PREVDD}/ICMSH${EXP}+00${PREVHOURRANGE}.sfx
  fi
  
  . $ENV
  
  echo 'echo MONITOR: $* >&2' >monitor.needs
  chmod +x monitor.needs
  
  cp $NAMSFX ./EXSEG1.nam
  ln -sf ${MASTER} ./MASTER
  
  cat $NAM001 | grep -v '^!' | sed -e "s/!.*//" \
    -e "s/{ldfi}/.F./" \
    -e "s/{lsprt}/.T./" \
    -e "s/{laststep}/$(( (HOURRANGE*3600)/TIMESTEP ))/" \
    -e "s/{nproc}/${NPROC}/g" \
    -e "s/{nproca}/${NPROCA}/g" \
    -e "s/{nprocb}/${NPROCB}/g" \
    -e "s/{timestep}/${TIMESTEP}/g" \
    -e "s/{nstop}/$(( (HOURRANGE*3600)/TIMESTEP ))/" > fort.4
  
  /usr/bin/time mpiexec_mpt -np ${NPROC} omplace ./MASTER -e${EXP} -vmeteo -c001 -maladin -n0 > log.out 2>log.err
  
  tar -zcvf "pf${YYYY}${MM}${DD}.tar.gz" "pf"*
  
  scp "pf${YYYY}${MM}${DD}.tar.gz" $REMOTE:${OUTPUTDIR}/
  scp "ICMSHABOF+"* $REMOTE:${OUTPUTDIR}/${YYYY}/${MM}/${DD}
  
  rm "ELS"*
  rm "pf"*
  rm "drhook"*
  rm -r "prep"
  rm -r "prepSurf"
  rm "Const"*
  rm "const"*
  rm "eco"*
  
  PREVDD=$DD
  PREVMM=$MM
  PREVYYYY=$YYYY
  PREVHOURRANGE=$HOURRANGE
  
  NEWDD=`echo $NEXTDATE | cut -c7-8`
  if [ ${NEWDD} -eq 01 ]; then
    rm "${LBCDIR}/LBC"*
  fi
  
  DATE=$NEXTDATE
done
