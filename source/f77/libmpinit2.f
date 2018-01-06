!-----------------------------------------------------------------------
! Fortran Library for initialization of domains and particles
! 2D MPI/OpenMP PIC Codes:
! PDICOMP2L determines uniform integer spatial decomposition for
!           uniform distribution of particles for 2d code
!           integer boundaries set, of equal size except for remainders
! PDNICOMP2L determines uniform integer spatial decomposition for
!            uniform distribution of particles for 2d code
!            integer boundaries set, but might be of unequal size
! PDCOMP2L determines uniform real spatial boundaries for uniform
!          distribution of particles for 2d code
!          real boundaries set, of equal size
! PDISTR2 calculates initial particle co-ordinates and velocities with
!         uniform density and maxwellian velocity with drift
!         for 2d code
! PDISTR2H calculates initial particle co-ordinates and velocities with
!          uniform density and maxwellian velocity with drift
!          for 2-1/2d code
! PPDBLKP2L finds the maximum number of particles in each tile
! ranorm gaussian random number generator
! randum uniform random number generator
! written by Viktor K. Decyk, UCLA
! copyright 2016, regents of the university of california
! update: february 9, 2016
!-----------------------------------------------------------------------
      subroutine PDICOMP2L(edges,nyp,noff,nypmx,nypmn,ny,kstrt,nvp,idps)
! this subroutine determines spatial boundaries for uniform particle
! decomposition, calculates number of grid points in each spatial
! region, and the offset of these grid points from the global address
! integer boundaries are set, of equal size except for remainders
! nvp must be < ny.  some combinations of ny and nvp result in a zero
! value of nyp.  this is not supported.
! input: ny, kstrt, nvp, idps, output: edges, nyp, noff, nypmx, nypmn
! edges(1) = lower boundary of particle partition
! edges(2) = upper boundary of particle partition
! nyp = number of primary (complete) gridpoints in particle partition
! noff = lowermost global gridpoint in particle partition
! nypmx = maximum size of particle partition, including guard cells
! nypmn = minimum value of nyp
! ny = system length in y direction
! kstrt = starting data block number (processor id + 1)
! nvp = number of real or virtual processors
! idps = number of partition boundaries
      implicit none
      integer nyp, noff, nypmx, nypmn, ny, kstrt, nvp, idps
      real edges
      dimension edges(idps)
! local data
      integer kb, kyp
      real at1, any
      integer mypm, iwork2
      dimension mypm(2), iwork2(2)
      any = real(ny)
! determine decomposition
      kb = kstrt - 1
      kyp = (ny - 1)/nvp + 1
      at1 = real(kyp)
      edges(1) = at1*real(kb)
      if (edges(1).gt.any) edges(1) = any
      noff = edges(1)
      edges(2) = at1*real(kb + 1)
      if (edges(2).gt.any) edges(2) = any
      kb = edges(2)
      nyp = kb - noff
! find maximum/minimum partition size
      mypm(1) = nyp
      mypm(2) = -nyp
      call PPIMAX(mypm,iwork2,2)
      nypmx = mypm(1) + 1
      nypmn = -mypm(2)
      return
      end
!-----------------------------------------------------------------------
!      subroutine PDNICOMP2L(edges,nyp,noff,nypmx,nypmn,ny,kstrt,nvp,idps&
!     &)                                                                       ! M. Touati
      subroutine PDNICOMP2L(edges,nyp,noff,nypmx,nypmn,ny,kstrt,nvp,idps&
     &,delta)                                                                  ! M. Touati
! this subroutine determines spatial boundaries for uniform particle
! decomposition, calculates number of grid points in each spatial
! region, and the offset of these grid points from the global address
! integer boundaries are set, but might be of unequal size
! input: ny, kstrt, nvp, idps, output: edges, nyp, noff, nypmx, nypmn
! edges(1) = lower boundary of particle partition
! edges(2) = upper boundary of particle partition
! nyp = number of primary (complete) gridpoints in particle partition
! noff = lowermost global gridpoint in particle partition
! nypmx = maximum size of particle partition, including guard cells
! nypmn = minimum value of nyp
! ny = system length in y direction
! kstrt = starting data block number (processor id + 1)
! nvp = number of real or virtual processors
! idps = number of partition boundaries
      implicit none
      integer nyp, noff, nypmx, nypmn, ny, kstrt, nvp, idps
!      real edges                                                              ! M. Touati
!      dimension edges(idps)                                                   ! M. Touati
      real edges, delta                                                        ! M. Touati
      dimension edges(idps), delta(2)                                          ! M. Touati
! local data
      integer kb
      real at1, at2
      integer mypm, iwork2
      dimension mypm(2), iwork2(2)
! determine decomposition
      kb = kstrt - 1
!      at1 = real(ny)/real(nvp)                                                ! M. Touati
!      at2 = at1*real(kb)                                                      ! M. Touati
!      noff = at2                                                              ! M. Touati
!      edges(1) = real(noff)                                                   ! M. Touati
!      at2 = at1*real(kb + 1)                                                  ! M. Touati
!      if (kstrt.eq.nvp) at2 = real(ny)                                        ! M. Touati
!      kb = at2                                                                ! M. Touati
!      edges(2) = real(kb)                                                     ! M. Touati
!      nyp = kb - noff                                                         ! M. Touati
      at1 = real(ny)*delta(2)/real(nvp)                                        ! M. Touati
      at2 = at1*real(kb)                                                       ! M. Touati
      noff = floor(at2/delta(2))                                               ! M. Touati
      edges(1) = real(noff)*delta(2)                                           ! M. Touati
      at2 = at1*real(kb + 1)                                                   ! M. Touati
      if (kstrt.eq.nvp) at2 = real(ny)*delta(2)                                ! M. Touati
      kb = floor(at2/delta(2))                                                 ! M. Touati
      edges(2) = real(kb)*delta(2)                                             ! M. Touati
      nyp = kb - noff                                                          ! M. Touati
! find maximum/minimum partition size
      mypm(1) = nyp
      mypm(2) = -nyp
      call PPIMAX(mypm,iwork2,2)
      nypmx = mypm(1) + 1
      nypmn = -mypm(2)
      return
      end
!-----------------------------------------------------------------------
      subroutine PDCOMP2L(edges,nyp,myp,lyp,noff,nypmx,ny,kstrt,nvp,idps&
     &)
! this subroutine determines spatial boundaries for uniform particle
! decomposition, calculates number of grid points in each spatial
! region, and the offset of these grid points from the global address
! real boundaries set, of equal size
! input: ny, kstrt, nvp, idps, output: edges, nyp, noff, myp, lyp, nypmx
! edges(1) = lower boundary of particle partition
! edges(2) = upper boundary of particle partition
! nyp = number of primary (complete) gridpoints in particle partition
! myp = number of full or partial grids in particle partition
! lyp = number of guard cells for processor on left
! noff = lowermost global gridpoint in particle partition
! nypmx = maximum size of particle partition, including guard cells
! ny = system length in y direction
! kstrt = starting data block number (processor id + 1)
! nvp = number of real or virtual processors
! idps = number of partition boundaries
      implicit none
      integer nyp, noff, myp, lyp, nypmx, ny, kstrt, nvp, idps
      real edges
      dimension edges(idps)
! local data
      integer kb
      real at1, dt1
      integer mypm, iwork1
      dimension mypm(1), iwork1(1)
! determine decomposition
      kb = kstrt - 1
      at1 = real(ny)/real(nvp)
      edges(1) = at1*real(kb)
      noff = edges(1)
      dt1 = edges(1) - real(noff)
      if (dt1.eq.0.0) edges(1) = real(noff)
      edges(2) = at1*real(kb + 1)
      if (kstrt.eq.nvp) edges(2) = real(ny)
      kb = edges(2)
      dt1 = edges(2) - real(kb)
      if (dt1.eq.0.0) edges(2) = real(kb)
      nyp = kb - noff
      myp = nyp
      if (dt1.gt.0.0) myp = myp + 1
! find number of guard cells on the left
      mypm(1) = myp - nyp + 1
      call PPISHFTR(mypm,iwork1,1)
      lyp = mypm(1)
! find maximum partition size
      mypm(1) = myp
      call PPIMAX(mypm,iwork1,1)
      nypmx = mypm(1) + 1
      return
      end
!-----------------------------------------------------------------------
!      subroutine PDISTR2(part,edges,npp,nps,vtx,vty,vdx,vdy,npx,npy,nx, &
!     &ny,idimp,npmax,idps,ipbc,ierr)                                          ! M. Touati
      subroutine PDISTR2(part,edges,npp,nps,vtx,vty,vdx,vdy,npx,npy,nx, &
     &ny,idimp,npmax,idps,ipbc,x,y,ierr)                                       ! M. Touati
! for 2d code, this subroutine calculates initial particle co-ordinates
! and velocities with uniform density and maxwellian velocity with drift
! for distributed data.
! input: all except part, npp, ierr, output: part, npp, ierr
! part(1,n) = position x of particle n in partition
! part(2,n) = position y of particle n in partition
! part(3,n) = velocity vx of particle n in partition
! part(4,n) = velocity vy of particle n in partition
! edges(1) = lower boundary of particle partition
! edges(2) = upper boundary of particle partition
! npp = number of particles in partition
! nps = starting address of particles in partition
! vtx/vty = thermal velocity of electrons in x/y direction
! vdx/vdy = drift velocity of beam electrons in x/y direction
! npx/npy = initial number of particles distributed in x/y direction
! nx/ny = system length in x/y direction
! idimp = size of phase space = 4
! npmax = maximum number of particles in each partition
! idps = number of partition boundaries
! ipbc = particle boundary condition = (0,1,2,3) =
! (none,2d periodic,2d reflecting,mixed reflecting/periodic)
! ierr = (0,1) = (no,yes) error condition exists
! ranorm = gaussian random number with zero mean and unit variance
! with spatial decomposition
      implicit none
      integer npp, nps, npx, npy, nx, ny, idimp, npmax, idps, ipbc, ierr
      real vtx, vty, vdx, vdy
      real part, edges
      dimension part(idimp,npmax), edges(idps)
      real x, y                                                                ! M. Touati
      dimension x(nx+2), y(ny+2)                                               ! M. Touati
! local data
      integer j, k, npt, npxyp
      real edgelx, edgely, at1, at2, xt, yt, vxt, vyt
      double precision dnpx, dnpxy, dt1
      integer ierr1, iwork1
      double precision sum3, work3
      dimension ierr1(1), iwork1(1), sum3(3), work3(3)
      double precision ranorm
      ierr = 0
! particle distribution constant
      dnpx = dble(npx)
! set boundary values
!      edgelx = 0.0                                                            ! M. Touati
!      edgely = 0.0                                                            ! M. Touati
!      at1 = real(nx)/real(npx)                                                ! M. Touati
!      at2 = real(ny)/real(npy)                                                ! M. Touati
      edgelx = x(1)                                                            ! M. Touati
      edgely = y(1)                                                            ! M. Touati
      at1 = (x(nx+1)-x(1))/real(npx)                                           ! M. Touati
      at2 = (y(ny+1)-y(1))/real(npy)                                           ! M. Touati
      if (ipbc.eq.2) then
!         edgelx = 1.0                                                         ! M. Touati
!         edgely = 1.0                                                         ! M. Touati
!         at1 = real(nx-2)/real(npx)                                           ! M. Touati
!         at2 = real(ny-2)/real(npy)                                           ! M. Touati
         edgelx = x(2)                                                         ! M. Touati
         edgely = y(2)                                                         ! M. Touati
         at1 = (x(nx)-x(2))/real(npx)                                          ! M. Touati
         at2 = (y(ny)-y(2))/real(npy)                                          ! M. Touati
      else if (ipbc.eq.3) then
!         edgelx = 1.0                                                         ! M. Touati
!         at1 = real(nx-2)/real(npx)                                           ! M. Touati
         edgelx = x(2)                                                         ! M. Touati
         at1 = (x(nx)-x(2))/real(npx)                                          ! M. Touati
      endif
! uniform density profile
      do 20 k = 1, npy
      yt = edgely + at2*(real(k) - 0.5)
      do 10 j = 1, npx
      xt = edgelx + at1*(real(j) - 0.5)
! maxwellian velocity distribution
      vxt = vtx*ranorm()
      vyt = vty*ranorm()
      if ((yt.ge.edges(1)).and.(yt.lt.edges(2))) then
         npt = npp + 1
         if (npt.le.npmax) then
            part(1,npt) = xt
            part(2,npt) = yt
            part(3,npt) = vxt
            part(4,npt) = vyt
            npp = npt
         else
            ierr = ierr + 1
         endif
      endif
   10 continue
   20 continue
      npxyp = 0
! add correct drift
      sum3(1) = 0.0d0
      sum3(2) = 0.0d0
      do 30 j = nps, npp
      npxyp = npxyp + 1
      sum3(1) = sum3(1) + part(3,j)
      sum3(2) = sum3(2) + part(4,j)
   30 continue
      sum3(3) = npxyp
      call PPDSUM(sum3,work3,3)
      dnpxy = sum3(3)
      ierr1(1) = ierr
      call PPIMAX(ierr1,iwork1,1)
      ierr = ierr1(1)
      dt1 = 1.0d0/dnpxy
      sum3(1) = dt1*sum3(1) - vdx
      sum3(2) = dt1*sum3(2) - vdy
      do 40 j = nps, npp
      part(3,j) = part(3,j) - sum3(1)
      part(4,j) = part(4,j) - sum3(2)
   40 continue
! process errors
      dnpxy = dnpxy - dnpx*dble(npy)
      if (dnpxy.ne.0.0d0) ierr = dnpxy
      return
      end
!-----------------------------------------------------------------------
!      subroutine PDISTR2H(part,edges,npp,nps,vtx,vty,vtz,vdx,vdy,vdz,npx&
!     &,npy,nx,ny,idimp,npmax,idps,ipbc,ierr)                                  ! M. Touati
      subroutine PDISTR2H(part,edges,npp,nps,vtx,vty,vtz,vdx,vdy,vdz,npx&
     &,npy,nx,ny,idimp,npmax,idps,ipbc,x,y,ierr)                               ! M. Touati
! for 2-1/2d code, this subroutine calculates initial particle
! co-ordinates and velocities with uniform density and maxwellian
! velocity with drift for distributed data.
! input: all except part, ierr, output: part, npp, ierr
! part(1,n) = position x of particle n in partition
! part(2,n) = position y of particle n in partition
! part(3,n) = velocity vx of particle n in partition
! part(4,n) = velocity vy of particle n in partition
! part(5,n) = velocity vz of particle n in partition
! edges(1) = lower boundary of particle partition
! edges(2) = upper boundary of particle partition
! npp = number of particles in partition
! nps = starting address of particles in partition
! vtx/vty/vtz = thermal velocity of electrons in x/y/z direction
! vdx/vdy/vdz = drift velocity of beam electrons in x/y/z direction
! npx/npy = initial number of particles distributed in x/y direction
! nx/ny = system length in x/y direction
! idimp = size of phase space = 5
! npmax = maximum number of particles in each partition
! idps = number of partition boundaries
! ipbc = particle boundary condition = (0,1,2,3) =
! (none,2d periodic,2d reflecting,mixed reflecting/periodic)
! ierr = (0,1) = (no,yes) error condition exists
! ranorm = gaussian random number with zero mean and unit variance
! with spatial decomposition
      implicit none
      integer npp, nps, npx, npy, nx, ny, idimp, npmax, idps, ipbc, ierr
      real vtx, vty, vtz, vdx, vdy, vdz
      real part, edges
      dimension part(idimp,npmax), edges(idps)
      real x, y                                                                ! M. Touati
      dimension x(nx+2), y(ny+2)                                               ! M. Touati
! local data
      integer j, k, npt, npxyp
      real edgelx, edgely, at1, at2, xt, yt, vxt, vyt, vzt
      double precision dnpx, dnpxy, dt1
      integer ierr1, iwork1
      double precision sum4, work4
      dimension ierr1(1), iwork1(1), sum4(4), work4(4)
      double precision ranorm
      ierr = 0
! particle distribution constant
      dnpx = dble(npx)
! set boundary values
!      edgelx = 0.0                                                            ! M. Touati
!      edgely = 0.0                                                            ! M. Touati
!      at1 = real(nx)/real(npx)                                                ! M. Touati
!      at2 = real(ny)/real(npy)                                                ! M. Touati
      edgelx = x(1)                                                            ! M. Touati
      edgely = y(1)                                                            ! M. Touati
      at1 = (x(nx+1)-x(1))/real(npx)                                           ! M. Touati
      at2 = (y(ny+1)-y(1))/real(npy)                                           ! M. Touati
      if (ipbc.eq.2) then
!         edgelx = 1.0                                                         ! M. Touati
!         edgely = 1.0                                                         ! M. Touati
!         at1 = real(nx-2)/real(npx)                                           ! M. Touati
!         at2 = real(ny-2)/real(npy)                                           ! M. Touati
         edgelx = x(2)                                                         ! M. Touati
         edgely = y(2)                                                         ! M. Touati
         at1 = (x(nx)-x(2))/real(npx)                                          ! M. Touati
         at2 = (y(ny)-y(2))/real(npy)                                          ! M. Touati
      else if (ipbc.eq.3) then
!         edgelx = 1.0                                                         ! M. Touati
!         at1 = real(nx-2)/real(npx)                                           ! M. Touati
         edgelx = x(2)                                                         ! M. Touati
         at1 = (x(nx)-x(2))/real(npx)                                          ! M. Touati
      endif
! uniform density profile
      do 20 k = 1, npy
      yt = edgely + at2*(real(k) - 0.5)
      do 10 j = 1, npx
      xt = edgelx + at1*(real(j) - 0.5)
! maxwellian velocity distribution
      vxt = vtx*ranorm()
      vyt = vty*ranorm()
      vzt = vtz*ranorm()
      if ((yt.ge.edges(1)).and.(yt.lt.edges(2))) then
         npt = npp + 1
         if (npt.le.npmax) then
            part(1,npt) = xt
            part(2,npt) = yt
            part(3,npt) = vxt
            part(4,npt) = vyt
            part(5,npt) = vzt
            npp = npt
         else
            ierr = ierr + 1
         endif
      endif
   10 continue
   20 continue
      npxyp = 0
! add correct drift
      sum4(1) = 0.0d0
      sum4(2) = 0.0d0
      sum4(3) = 0.0d0
      do 30 j = nps, npp
      npxyp = npxyp + 1
      sum4(1) = sum4(1) + part(3,j)
      sum4(2) = sum4(2) + part(4,j)
      sum4(3) = sum4(3) + part(5,j)
   30 continue
      sum4(4) = npxyp
      call PPDSUM(sum4,work4,4)
      dnpxy = sum4(4)
      ierr1(1) = ierr
      call PPIMAX(ierr1,iwork1,1)
      ierr = ierr1(1)
      dt1 = 1.0d0/dnpxy
      sum4(1) = dt1*sum4(1) - vdx
      sum4(2) = dt1*sum4(2) - vdy
      sum4(3) = dt1*sum4(3) - vdz
      do 40 j = nps, npp
      if (mod(j,2) == 0.) then ! added for ensemble averaging test
	      part(3,j) = part(3,j) - 0.5*sum4(1)
    	  part(4,j) = part(4,j) - 0.5*sum4(2)
      	  part(5,j) = part(5,j) - 0.5*sum4(3)
      else ! added for ensemble averaging test
	      part(3,j) = part(3,j) + 0.5*sum4(1) ! added for ensemble averaging test
    	  part(4,j) = part(4,j) + 0.5*sum4(2) ! added for ensemble averaging test
      	  part(5,j) = part(5,j) + 0.5*sum4(3) ! added for ensemble averaging test
      end if
   40 continue
! process errors
      dnpxy = dnpxy - dnpx*dble(npy)
      if (dnpxy.ne.0.0d0) ierr = dnpxy
      return
      end
!-----------------------------------------------------------------------
!      subroutine PPDBLKP2L(part,kpic,npp,noff,nppmx,idimp,npmax,mx,my,  &
!     &mx1,mxyp1,irc)                                                          ! M. Touati
      subroutine PPDBLKP2L(part,kpic,npp,noff,nppmx,idimp,npmax,mx,my,  &
     &mx1,mxyp1,delta,irc)                                                     ! M. Touati
! this subroutine finds the maximum number of particles in each tile of
! mx, my to calculate size of segmented particle array ppart
! linear interpolation, spatial decomposition in y direction
! input: all except kpic, nppmx, output: kpic, nppmx
! part = input particle array
! part(1,n) = position x of particle n in partition
! part(2,n) = position y of particle n in partition
! kpic = output number of particles per tile
! nppmx = return maximum number of particles in tile
! npp = number of particles in partition
! noff = backmost global gridpoint in particle partition
! idimp = size of phase space = 4
! npmax = maximum number of particles in each partition
! mx/my = number of grids in sorting cell in x and y
! mx1 = (system length in x direction - 1)/mx + 1
! mxyp1 = mx1*myp1, where myp1=(partition length in y direction-1)/my+1
! irc = maximum overflow, returned only if error occurs, when irc > 0
      implicit none
      integer nppmx, idimp, npmax, mx, my, mx1, mxyp1, irc
      integer kpic, npp, noff
      real part
      dimension part(idimp,npmax)
      dimension kpic(mxyp1)
      real delta                                                               ! M. Touati
      dimension delta(2)                                                       ! M. Touati
! local data
      integer j, k, n, m, mnoff, isum, ist, npx, ierr
      mnoff = noff
      ierr = 0
! clear counter array
      do 10 k = 1, mxyp1
      kpic(k) = 0
   10 continue
! find how many particles in each tile
      do 20 j = 1, npp
!      n = part(1,j)                                                           ! M. Touati
	  n = floor(part(1,j)/delta(1))                                            ! M. Touati
      n = n/mx + 1
!      m = part(2,j)                                                           ! M. Touati
	  m = floor(part(2,j)/delta(2))                                            ! M. Touati
      m = (m - mnoff)/my
      m = n + mx1*m
      if (m.le.mxyp1) then
         kpic(m) = kpic(m) + 1
      else
         ierr = max(ierr,m-mxyp1)
      endif
   20 continue
! find maximum
      isum = 0
      npx = 0
      do 30 k = 1, mxyp1
      ist = kpic(k)
      npx = max(npx,ist)
      isum = isum + ist
   30 continue
      nppmx = npx
! check for errors
      if (ierr.gt.0) then
         irc = ierr
      else if (isum.ne.npp) then
         irc = -1
      endif
      return
      end
!-----------------------------------------------------------------------
      function ranorm()
! this program calculates a random number y from a gaussian distribution
! with zero mean and unit variance, according to the method of
! mueller and box:
!    y(k) = (-2*ln(x(k)))**1/2*sin(2*pi*x(k+1))
!    y(k+1) = (-2*ln(x(k)))**1/2*cos(2*pi*x(k+1)),
! where x is a random number uniformly distributed on (0,1).
! written for the ibm by viktor k. decyk, ucla
      implicit none
      integer iflg,isc,i1,r1,r2,r4,r5
      double precision ranorm,h1l,h1u,h2l,r0,r3,asc,bsc,temp
      save iflg,r1,r2,r4,r5,h1l,h1u,h2l,r0
      data r1,r2,r4,r5 /885098780,1824280461,1396483093,55318673/
      data h1l,h1u,h2l /65531.0d0,32767.0d0,65525.0d0/
      data iflg,r0 /0,0.0d0/
      if (iflg.eq.0) go to 10
      ranorm = r0
      r0 = 0.0d0
      iflg = 0
      return
   10 isc = 65536
      asc = dble(isc)
      bsc = asc*asc
      i1 = r1 - (r1/isc)*isc
      r3 = h1l*dble(r1) + asc*h1u*dble(i1)
      i1 = r3/bsc
      r3 = r3 - dble(i1)*bsc
      bsc = 0.5d0*bsc
      i1 = r2/isc
      isc = r2 - i1*isc
      r0 = h1l*dble(r2) + asc*h1u*dble(isc)
      asc = 1.0d0/bsc
      isc = r0*asc
      r2 = r0 - dble(isc)*bsc
      r3 = r3 + (dble(isc) + 2.0d0*h1u*dble(i1))
      isc = r3*asc
      r1 = r3 - dble(isc)*bsc
      temp = dsqrt(-2.0d0*dlog((dble(r1) + dble(r2)*asc)*asc))
      isc = 65536
      asc = dble(isc)
      bsc = asc*asc
      i1 = r4 - (r4/isc)*isc
      r3 = h2l*dble(r4) + asc*h1u*dble(i1)
      i1 = r3/bsc
      r3 = r3 - dble(i1)*bsc
      bsc = 0.5d0*bsc
      i1 = r5/isc
      isc = r5 - i1*isc
      r0 = h2l*dble(r5) + asc*h1u*dble(isc)
      asc = 1.0d0/bsc
      isc = r0*asc
      r5 = r0 - dble(isc)*bsc
      r3 = r3 + (dble(isc) + 2.0d0*h1u*dble(i1))
      isc = r3*asc
      r4 = r3 - dble(isc)*bsc
      r0 = 6.28318530717959d0*((dble(r4) + dble(r5)*asc)*asc)
      ranorm = temp*dsin(r0)
      r0 = temp*dcos(r0)
      iflg = 1
      return
      end
!-----------------------------------------------------------------------
      function randum()
! this is a version of the random number generator dprandom due to
! c. bingham and the yale computer center, producing numbers
! in the interval (0,1).  written for the sun by viktor k. decyk, ucla
      implicit none
      integer isc,i1,r1,r2
      double precision randum,h1l,h1u,r0,r3,asc,bsc
      save r1,r2,h1l,h1u
      data r1,r2 /1271199957,1013501921/
      data h1l,h1u /65533.0d0,32767.0d0/
      isc = 65536
      asc = dble(isc)
      bsc = asc*asc
      i1 = r1 - (r1/isc)*isc
      r3 = h1l*dble(r1) + asc*h1u*dble(i1)
      i1 = r3/bsc
      r3 = r3 - dble(i1)*bsc
      bsc = 0.5d0*bsc
      i1 = r2/isc
      isc = r2 - i1*isc
      r0 = h1l*dble(r2) + asc*h1u*dble(isc)
      asc = 1.0d0/bsc
      isc = r0*asc
      r2 = r0 - dble(isc)*bsc
      r3 = r3 + (dble(isc) + 2.0d0*h1u*dble(i1))
      isc = r3*asc
      r1 = r3 - dble(isc)*bsc
      randum = (dble(r1) + dble(r2)*asc)*asc
      return
      end
!-----------------------------------------------------------------------