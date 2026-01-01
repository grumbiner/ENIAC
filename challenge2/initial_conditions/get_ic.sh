#!/bin/sh

#Get Initial Condition data for ENIAC challenge
#Robert Grumbine 15 February 2021

#General notes:
#  You must have get_grib.pl, get_inv.pl, and wgrib2 in BIN_DIR
#
#  curl must be available from your PATH 
#
#  The default is to retrieve the 500 mb height field from the 00z cycle 
#       of the GDAS for the present day. 
#  cycle is controlled by environment variable cyc (00, 06, 12, 18 UTC)
#  date is controlled by environment variable tag (YYYYMMDD) and for the default source, 
#      will only allow going back 2 weeks.  Determine and use correct nomads link or 
#      cfsv2 link to go back farther. 

#  Output is placed in directory OUTDIR, environment variable
#  output is given in text, netcdf, and grib2 format,
#    but for default netcdf, wgrib2 must have been built for it.
#  

export tag=${tag:-`date +"%Y%m%d"`}
export cyc=${cyc:-00}

#res : one of 0p25 0p50, 1p00 (0.25, 0.50, 1.00 degree lat-long grids from the NWS GFS model)
export res=${res:-0p25}

# Data SOURCE
#The sources provide inputs through curl calls invoked by get_grib.pl and get_inv.pl
#ftpprd is NWS operational (and shorter retention)
source=https://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gdas.${tag}/${cyc}/atmos

#cfsv2 is the climate forecast system reanalysis, provinding information 1979-present
#source=http://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.${tag}${cyc}
#cfsv2 a:
#cfsv2 b:

BASE=`pwd`
BIN_DIR=${BIN_DIR:-${BASE}/../bin}
if [ ! -d $BIN_DIR ] ; then
  echo no BIN_DIR at $BIN_DIR exiting
  exit
fi

MODEL_DIR=${MODEL_DIR:-$BASE}
if [ ! -d $MODEL_DIR ] ; then
  echo no MODEL_DIR at $MODEL_DIR exiting
  exit
fi

#cd to a working directory
RUN_DIR=${RUN_DIR:-running}
if [ ! -d $RUN_DIR ] ; then
  mkdir -p $RUN_DIR
  err=$?
  if [ $err -ne 0 ] ; then
    echo Making rundir failed with error $err exiting now
    exit
  fi
  cd $RUN_DIR
 else
  cd $RUN_DIR
fi

######### # get info and reprocess #############################################################
hr=000
#Get initial fields:
if [ ! -f eniac.$res.$tag.f$hr.grib2 ] ; then
  ${BIN_DIR}/get_inv.pl $source/gdas.t${cyc}z.pgrb2.${res}.f${hr}.idx | grep :HGT | grep :500 |
  ${BIN_DIR}/get_grib.pl $source/gdas.t${cyc}z.pgrb2.${res}.f${hr}   eniac.$res.$tag.f$hr.grib2

  ${BIN_DIR}/wgrib2 eniac.$res.$tag.f$hr.grib2 | ${BIN_DIR}/wgrib2 -i eniac.$res.$tag.f$hr.grib2 -no_header -order we:ns -text eniac.$res.$tag.txt
#  ${BIN_DIR}/wgrib2 eniac.$res.$tag.f$hr.grib2 | ${BIN_DIR}/wgrib2 -i eniac.$res.$tag.f$hr.grib2 -no_header -order we:sn -netcdf eniac.$tag.nc
fi

exit
######### # Share some output #############################################################

OUTDIR=${OUTDIR:-$~/grumbinescience.org/eniac}

gzip eniac.$res.$tag.txt
mv eniac.$res.$tag.txt.gz $OUTDIR
mv eniac.$res.$tag.f$hr.grib2 $OUTDIR
#mv eniac.$res.$tag.nc $OUTDIR

########## # Cleanup #############################################################
