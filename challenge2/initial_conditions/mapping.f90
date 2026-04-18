PROGRAM mapping
  IMPLICIT none
  INCLUDE "grid.inc"
  INCLUDE "ic.inc"

  INTEGER i,j,ti, tj
  REAL r, rlat, phi, phi_0, dsnew
  INTEGER ratio, ipole, jpole
  REAL tlat, tlon, zin(nx, ny), zout(0:p, 0:q)

  ! ratio is the ratio (inverse) of the grid spacing. 2 means half the grid spacing of the original
  ! while this program is capable of generating higher resolution files, the current ENIAC adjacent
  !   cannot work with higher resolution grids
  ratio = 1
  jpole = jp*ratio
  ipole = ip*ratio
  dsnew = ds/ratio

  OPEN(10, FILE="gfs.txt", FORM="FORMATTED")
  DO j = 1, ny
  DO i = 1, nx
    READ(10,*) zin(i,j)
  ENDDO
  ENDDO
! ! PRINT *,zin(:,1), zin(:,ny/2)
  CLOSE(10)
  !zin = 5400.

  DO j = 0,q*ratio
  DO i = 0,p*ratio
! longitude is accurate
    tlon = atan2(FLOAT(j-jpole), FLOAT(i-ipole))*180./pi
    ti = NINT( (tlon - firstlon)/dlon)
    IF (ti < 0) ti = ti + nx
! latitude is a rather approximate estimate
    r = sqrt(float( (i-ipole)**2+(j-jpole)**2) )*ds/ratio
    tlat = (90.-r/111.1e3)
    tj = NINT( (tlat - firstlat)/dlat)
    zout(i,j) = zin(ti, tj)
    !debug: WRITE (*,*) tlat, tlon, ti, tj
  ENDDO
  ENDDO
  !zout(p/2,q/2) = 5400. + 100.

  OPEN(11, FILE="ic.txt", FORM="FORMATTED")
  WRITE (11, *) zout
  CLOSE(11)

END
