#!/usr/bin/env python3
from math import sin, cos, atan2, atan, pi, sqrt

import numpy as np

import matplotlib
import matplotlib.pyplot as plt

import cartopy.crs as ccrs
import cartopy.feature as cfeature

matplotlib.use('agg') #non-interactive
#-------------------------------------------

#------------------------------------------
#eniac lons, lats
def eniac_pos(lons, lats, nx, ny, ratio):
  jp = 13
  ip =  9
  ds = 7.36e5
  jpole = jp*ratio
  ipole = ip*ratio
  #jpole = int(ny/2)
  #ipole = int(nx/2)
  dsnew = ds/ratio

  phi_ts = 60.*pi/180. # True scale at 60 N

  for i in range(0,nx):
    for j in range(0,ny):
      lons[j,i] = atan2( j-jpole, (i-ipole) )*180./pi 

      r = sqrt( (i-ipole)**2 + (j-jpole)**2)*dsnew
      lats[j,i] = 90-r/111.1e3


  
#------------------------------------------

def plot_world_map(lons, lats, data):
    vmin = np.nanmin(data)
    vmax = np.nanmax(data)

    proj = ccrs.LambertConformal(central_longitude=-90, central_latitude=35., cutoff=-25.)
    #proj = ccrs.NorthPolarStereo(true_scale_latitude=60.)
    #proj = ccrs.Stereographic(central_longitude=-70, central_latitude=60. )
    #proj = ccrs.PlateCarree(central_longitude=-70)
    #debug: print("proj = ",proj,flush=True)

    ax = plt.axes(projection = proj)
    fig = plt.figure(figsize=(640/50,480/50))
    #fig = plt.figure( )
    ax = fig.add_subplot(1, 1, 1, projection = proj)

    #ax.set_extent((-180, 0, -20, 90), crs=ccrs.PlateCarree())

    xlocs = np.linspace(-220, 20, 25)
    ylocs = np.linspace(-10, 85, 20)
    #ax.gridlines(crs=ccrs.PlateCarree(), xlocs=[-180, -170, -150, -120], ylocs=[40,50,60,66.6,70,80] )
    ax.gridlines(crs=ccrs.PlateCarree(), xlocs = xlocs, ylocs = ylocs)

    #'natural earth' -- coast only -- ax.coastlines(resolution='10m')
    #print("add_feature -- coastlines",flush=True)

    ax.add_feature(cfeature.GSHHSFeature(levels=[1,2,3,4], scale="l") )

# can't convert gif, jpeg, jpg, pdf, png, ps,
# doesn't write: pgf,
# preview doesn't read: raw,

    cbarlabel = '%s' % ("hello1")
    #debug: plttitle = 'Plot of variable %s' % ("hello2")
    #debug: plt.title(plttitle)

    #Establish the color bar
    #colors=matplotlib.cm.get_cmap('jet')
    #colors=matplotlib.pyplot.get_cmap('gray')
    #colors=matplotlib.pyplot.get_cmap('terrain')
    colors=matplotlib.pyplot.get_cmap('bwr')

    #cs = ax.pcolormesh(lons, lats, data,vmin=vmin,vmax=vmax,cmap=colors, transform=ccrs.PlateCarree() )
    cs = ax.pcolormesh(lons, lats, data,vmax=vmax,cmap=colors, transform=ccrs.PlateCarree() )
    cb = plt.colorbar(cs, extend='both', orientation='horizontal', shrink=0.5, pad=.04)
    cb.set_label(cbarlabel, fontsize=12)

    plt.savefig("hello3.png")

    plt.close('all')
#----------------------------------------------------

#----------------------------------------------------
p  = 19
q  = 16
ratio = 1
nx = int(p * ratio)
ny = int(q * ratio)
lons = np.zeros((ny,nx))
lats = np.zeros((ny,nx))
data = np.zeros((ny,nx))

eniac_pos(lons, lats, nx, ny, ratio)
#debug: 
print("lons ",lons.max(), lons.min(), lons.sum()/nx/ny )
#debug: 
print("lats ",lats.max(), lats.min(), lats.sum()/nx/ny )
#data = lats 

with open("original_eniac_ic.txt","r",encoding="utf-8") as fin:
  line = fin.readline()
  values = line.split()
  for k in range (0,nx*ny):
    i = k % nx
    j = int(k/nx)
    data[j,i] = float(values[k])
print(len(values), nx*ny)


plot_world_map(lons, lats, data)

