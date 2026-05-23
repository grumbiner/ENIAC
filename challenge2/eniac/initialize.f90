SUBROUTINE initialize(s,t,v,r,f,h,z,zeta,eta)
  IMPLICIT none

  INCLUDE "grid.inc"

!  Declare temporary arrays -
!    These were used because of the memory constraint on the ENIAC -- 
!      these values were on punched cards recycled through the system
  REAL s(0:p,0:p), t(0:q,0:q), v(0:p,0:q)
  REAL r(0:p,0:q), f(0:p,0:q), h(0:p,0:q)
  
!  Declare data, physical info.
  REAL z(0:p,0:q), zeta(0:p,0:q), eta(0:p,0:q)
  
!  Declare computational variables
  INTEGER i, j, l, m
  
!***********************************************************!!

! BEGIN THE EXECUTION HERE
! This file is not comparable to anything in the original program.
  OPEN (UNIT=1, FILE="ENIAC.OUT", FORM="FORMATTED")
  
  s = 0.
  t = 0.
  v = 0.
  r = 0.
  h = 0.
  f = 0.
  zeta = 0.0
  eta  = 0.0
  

  PRINT *,SECOND()*1000.,' ms'

!  Prepare the fixed field data decks - used due to memory constraints
  DO i = 1, p-1
    DO l = 1, p-1
      s(l,i) = SIN(pi*i*l/p)
    ENDDO
  ENDDO
   
  DO j = 1, q-1
    DO m = 1, q-1
      t(m,j) = SIN(pi*m*j/q)
    ENDDO
  ENDDO
   
  DO i = 0, p
    DO j = 0, q
      v(i,j) = p*q*(SIN(pi*i/(2*p))**2 + SIN(pi*j/(2*q))**2 )
      r(i,j) = (ds/(2*radius))**2 *((i-ip)**2+(j-jp)**2)
    ENDDO
  ENDDO
   
! metric -- 
! the nondimensionalized r = cos(phi)/(1+sin(phi)) where phi = latitude
!    and r**2 = (x-xp)**2 + (y-yp)**2
! f, h address the mapping/magnification factor
  f = (1.-r)/(1.+r)
  h = g/(2*omega*ds)**2 * (1.+r)**3 / (1.-r) 

! Now get initial condition -- 500 mb height field -------------
!  !read in z (in 10's of feet)
!  z = z - 820
!! Rescale the heights (10's of feet) to metric
!  z    = z / fttom
  !OPEN(11, FILE="ic.txt", FORM="UNFORMATTED", STATUS="OLD")
  OPEN(11, FILE="ic.txt", FORM="FORMATTED", STATUS="OLD")
  READ(11, *) z
  CLOSE(11)
!for GFS initial conditions
  z = z - 5400.
  z = z / 10.
!  PRINT *, z

  DO i = 1, p-1
    DO j = 1, q-1
      zeta(i,j) = z(i+1,j)+z(i,j+1)+z(i-1,j)+z(i,j-1) - 4.*z(i,j)
    ENDDO
  ENDDO
  DO j = 0, q
    zeta(0,j) = 2.*zeta(1,j)  - zeta(2,j)
    zeta(p,j) = 2.*zeta(p-1,j)- zeta(p-2,j)
  ENDDO
  DO i = 0, p
    zeta(i,0) = 2.*zeta(i,1)   - zeta(i,2)
    zeta(i,q) = 2.*zeta(i,q-1) - zeta(i,q-2)
  ENDDO
   
  eta = f + h*zeta
   
! END OF THE PRELIMINARY SET UP SECTION
  RETURN
END SUBROUTINE initialize
