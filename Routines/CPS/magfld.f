*
*===magfld=============================================================*
*
      SUBROUTINE MAGFLD ( X, Y, Z, BTX, BTY, BTZ, B, NREG, IDISC )

      INCLUDE 'dblprc.inc'
      INCLUDE 'dimpar.inc'
      INCLUDE 'iounit.inc'
*
*----------------------------------------------------------------------*
*                                                                      *
*     Copyright (C) 2003-2019:  CERN & INFN                            *
*     All Rights Reserved.                                             *
*                                                                      *
*     Created  in     1988         by    Alberto Fasso`                *
*                                                                      *
*     Input variables:                                                 *
*            x,y,z = current position                                  *
*            nreg  = current region                                    *
*     Output variables:                                                *
*            btx,bty,btz = cosines of the magn. field vector           *
*            B = magnetic field intensity (Tesla)                      *
*            idisc = set to 1 if the particle has to be discarded      *
*                                                                      *
*----------------------------------------------------------------------*
*
      INCLUDE 'cmemfl.inc'
      INCLUDE 'csmcry.inc'
      INCLUDE 'blnkcm.inc'
      ! INCLUDE 'sfemfl.inc'

*VBT-----------------------------
	character*8 namreg
      logical firent, condit, check, check1,cdt
***      save firent,check,check1
      data check /.true./
      data check1/.true./
      data firent/.true./
	integer ientry
	save ientry
	data ientry/0/

*VBT-----------------------------

* 2 Tesla uniform field along +z:
      BTX   = 0.!UMGFLD
      BTY   = 0.!VMGFLD
      BTZ   = 1.!WMGFLD
      B     = 0.!BIFUNI

      

      if(firent) then
      b1=0.241
      b2=0.251
      b3=0.22
      ! write (LUNERR,*) "V.BAT 08/23/22 magfld.f/coord B=",b1,b2,b3
*****      write (LUNERR,*) 'BATURIN  region based  mgfld.f is working '
      firent=.false.
      endif !(firent)

      ientry=ientry+1

      btx= 0.
      bty= 0.
      btz= 0.
      b=   0.

!       if(
!      +   (X.ge.-6.5).and.(X.le.6.5).and.
!      +   (Y.ge.-6.5).and.(Y.le.6.5).and.
!      +   (Z.ge.370.98).and.(Z.le.509.9)
!      +  ) then
!             btx= 1.5  !was -1.! was +1
!             bty= 0.
!             btz= 0.           
!       return
!       endif
             

      if(
     +   (X.ge.-6.5).and.(X.le.+6.5).and.
     +   (Y.ge.-6.5).and.(Y.le.+6.5)
     +  ) then

      if((Z.ge.-25.0).and.(Z.le.+25.)) then ! upstream coil
            btx=+1  !was -1.! was +1
            bty= 0.
            btz= 0.           
            b=b1!0.4802 !0.2401  !0.2501
      return
      endif
      
      if((Z.gt.+237.).and.(Z.le.+287)) then ! downstream coil
            btx= +1 !was -1.! +1.! was -1. 
            bty= 0.
            btz= 0.
            b=b2!0.50 !0.2501 ! 0.351 !+0.2501
***           IF(IENTRY.le.10) WRITE(lunerr,*) "vbt, ds b=",b
      return
      endif

1543  if((Z.gt.+510.).and.(Z.le.+880)) then ! permanant magnet
            btx=-1.
            bty= 0.
            btz= 0.        
            b=b3!+0.22
      return
      endif
      else
            btx=0.
            bty=0.
            btz=0.
            b=0.
      return
      endif
      RETURN
      return     


condit=(namreg.eq."BEAMHOLE")
      if(condit) then
            btx=0.
            bty=1.
            btz=0.
            b= 1.100
      return
****	 write (LUNERR,*) namreg,"reg#=",nreg, condit,"BATURIN B=",b
      endif                     !(condit)

      condit=(namreg.eq."DIPOLE2")
      if(condit) then
      btx=0.
      bty=1.
      btz=0.
      b= 0.15
*        else
*	btx=0.
*	bty=0.
*	btz=1.
*	b=0.
*          return
*	 write (LUNERR,*) namreg,"reg#=",nreg, condit,"D=2",b
      return
      endif                     !(condit)

      if((4570.le.Z).and.(Z.le.5030).and.
     +     (-010.le.X).and.(X.le.+010).and.
     +     (+142.le.Y).and.(Y.le.+164)  
     +  )  then    ! dipole field in dZ=5030-4570 = 460 cm 

            btx=-1. !-to lower radii - inbending by 2.1 deg
            bty=0.
            btz=0.
            b=+7.302188329 !+7.3038235 !+0.581219873
*      write (LUNERR,*) condit,namreg,nreg,btx,"B=",b
      RETURN
      endif

      if((0220.le.Z).and.(Z.le.0460).and.
     +     (-150.le.X).and.(X.le.+150).and.
     +     (-050.le.Y).and.(Y.le.+050)  
     +  )  then    ! dipole field in dZ=-520+660 = 140 cm 

      btx=+0. !+to higher radii-outbending by 2.1*140/460= 0.639130435 deg
      bty=1.
      btz=0.
      b=+3.302188329 !+7.3038235 !+0.581219873
*      write (LUNERR,*) condit,namreg,nreg,btx,"B=",b
      RETURN
      endif


      if ((namreg.eq."VOID1R" .and.check).or.
     +      (namreg.eq."PBEAM1R".and.check)) then
            ! write (LUNERR,*) namreg,nreg, condit,"!!!BATTPC=",b
            check=.false.
      endif


      if ((namreg.eq."PIDL" .and.check1).or.
     +      (namreg.eq."PIDR".and.check1)) then
      ! write (LUNERR,*) namreg,nreg, condit,"!!!BATTPC=",b
      check1=.false.
      endif


 


      RETURN
*=== End of subroutine Magfld =========================================*
      END

