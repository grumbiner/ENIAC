! Added: resolution ratio vs. original model
  INTEGER ratio
  PARAMETER (ratio = 1.)
!  Non-dimensional constants
  INTEGER p, q, n, ip, jp
  PARAMETER (p  = 18*ratio)
  PARAMETER (q  = 15*ratio)
  PARAMETER (ip =  9*ratio)   ! i,j location of the pole for stereographic projection
  PARAMETER (jp = 13*ratio)
  PARAMETER (n = 24*ratio)   ! number of time steps per day

!  Declare Dimensional Constants
  REAL g, radius, omega, ds, dt
  PARAMETER (g      = 9.81)
  PARAMETER (radius = 6.37E6)
  PARAMETER (omega  = 7.292E-5)
  PARAMETER (ds     = 7.36E5/ratio)
  PARAMETER (dt     = omega*86400/n)

!  Rescale feet (input dimension of Z's) to meters
  REAL fttom
  PARAMETER (fttom = 3.048)
  REAL pi
  PARAMETER (pi = 3.141592653565898)
