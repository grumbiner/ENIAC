PROGRAM s1_scoring
  IMPLICIT none
  INTEGER, parameter :: nx = 19
  INTEGER, parameter :: ny = 16
  REAL fcst(nx, ny), obs(nx, ny)
  REAL s1, correl, rms
  INTEGER i, j

  !read in fcst
  OPEN(FILE='fcst.txt', FORM='FORMATTED', STATUS='OLD', UNIT=10)
 9001 FORMAT(16F7.2)
  READ(10, 9001) ((fcst(i,j),j=1,ny),i=1,nx)

  !read in verification
  OPEN(FILE='ic.txt', FORM='FORMATTED', STATUS='OLD', UNIT=11)
  READ (11, *) obs


  CALL find_s1(fcst, obs, nx, ny, s1, correl, rms)
  PRINT *,'s1, correl, rms = ', s1, correl, rms

END


SUBROUTINE find_s1(fcst, obs, nx, ny, s1, correl, rms)
  IMPLICIT none
  INTEGER nx, ny
  REAL :: fcst(nx, ny), obs(nx, ny)

  INTEGER :: i, j, n
  REAL :: dfdx, dfdy, dodx, dody
  REAL :: errx, erry, maxgx, maxgy
  REAL :: sum_err, sum_max_grad
  REAL :: s1, correl, rms
  REAL :: sumx, sumy, sumxy, sumx2, sumy2
  REAL :: xm, ym

  sum_err = 0
  sum_max_grad = 0
  sumx  = 0
  sumx2 = 0
  sumy  = 0
  sumy2 = 0
  sumxy = 0

  PRINT *,'max fcst, obs ',MAXVAL(fcst), MAXVAL(obs)

  DO j = 1, ny-1
  DO i = 1, nx-1 
    dfdx = fcst(i+1, j) - fcst(i, j)
    dfdy = fcst(i, j+1) - fcst(i, j)

    dodx = obs(i+1, j) - obs(i,j)
    dody = obs(i, j+1) - obs(i,j)

    errx = abs(dfdx - dodx)
    erry = abs(dfdy - dody)

    maxgx = max(abs(dfdx), abs(dodx))
    maxgy = max(abs(dfdy), abs(dody))

    sum_err      = sum_err      + errx  + erry
    sum_max_grad = sum_max_grad + maxgx + maxgy

    sumx  = sumx  + fcst(i,j)
    sumx2 = sumx2 + fcst(i,j)*fcst(i,j)
    sumy  = sumy  + obs(i,j)
    sumy2 = sumy2 + obs(i,j)*obs(i,j)
    sumxy = sumxy + fcst(i,j)*obs(i,j)

  ENDDO
  ENDDO

  n = (nx-1)*(ny-1)
  xm = sumx / n
  ym = sumy / n
  rms = sumx2 / n
  rms = sqrt(rms)
  correl = (sumxy - n*xm*ym)/sqrt(sumx2-n*xm*xm)/sqrt(sumy2-n*ym*ym)

  s1 = 100. * (sum_err / sum_max_grad)

  RETURN
END
