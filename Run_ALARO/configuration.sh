#!/bin/bash

# Directories
export COUPLING="/mnt/HDS_CLIMAVIN/CLIMAVIN/LBC_CORDEX_AFR_ERA5_michielv/"
export WORKDIR="/scratch-b/kvwever/ALARO1_SFX8_ERA5_4KM_FArep_ETH"
export LBCDIR="/scratch-b/kvwever/LBC_ETH/"
export OUTPUTDIR="/mnt/HDS_CLIMATE/CLIMATE/kvwever/ETHIOPIA/"
export ERADIR="/home/kvwever/ETHIOPIA/"
export DATADIR_ECOCLIMAP="/mnt/HDS_ALD_TEAM/ALD_TEAM/hamdi/ALARO1-SURFEX8/ECOCLIMAP"
export DATADIR_RRTM="/mnt/HDS_ALD_TEAM/ALD_TEAM/hamdi/ALARO1-SURFEX8/RRTM"

# Executables and environments
export DECDATE="/home/hamdi/bin/decdate"
export FAREPLACE="/home/hamdi/aladin/pack/cy36/bin"
export MASTER="/home/hamdi/aladin/pack/test/bin/MASTERODB"
export ENV="$ERADIR/scr/ENV_ALADIN_CY43T2NEW"
export ENVFAREP="/home/daand/aladin/runs/ref38t1/ENV_ALADIN"

# Namelists and other files
export NAM927="$ERADIR/namelist/name.e927"
export NAM927_SFX="$ERADIR/namelist/name.e927.sfx"
export NAM927_LVL="$ERADIR/namelist/ERA5a_46l"
export NAM001="$ERADIR/namelist/name.e001.CY43T2new.sfx.emnet"
export NAMSFX="$ERADIR/namelist/EXSEG1.nam.plus.emnet"
export NAMFAREP="$ERADIR/namelist/HIST_namelist_name.FAreplace_emnet"
export NAMFAREPSFX="$ERADIR/namelist/HIST_namelist_name.FAreplace_emnet.sfx"
export CLIM_LBC="/scratch-b/kvwever/CLIM923_AFR/clim_model_m"
export CLIM_TRG="/home/kvwever/ALARO_SURFEX_PGD/ETH/STEP_2/clim_4km_ETH_m"
export PGDFILE="/home/kvwever/ALARO_SURFEX_PGD/ETH/STEP_3/PGD_4km_ETH.fa"

# Other variables
export REMOTE="nori"
export EXP="ABOF"
export LEVELS="$(echo $(seq -f %2g, 1 1 46))"
export RUNSTARTHH="00"

# Forecast settings
export NPROCA=6
export NPROCB=24
export NPROC=$(( NPROCA * NPROCB ))
export OMP_NUM_THREADS=1
export TIMESTEP=120