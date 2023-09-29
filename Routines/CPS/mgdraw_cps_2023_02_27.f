*                                                                      *
*=== mgdraw ===========================================================*
*                                                                      *
      SUBROUTINE MGDRAW ( ICODE, MREG )

      INCLUDE 'dblprc.inc'
      INCLUDE 'dimpar.inc'
      INCLUDE 'iounit.inc'
*
*----------------------------------------------------------------------*
*                                                                      *
*     Copyright (C) 2003-2019:  CERN & INFN                            *
*     All Rights Reserved.                                             *
*                                                                      *
*     MaGnetic field trajectory DRAWing: actually this entry manages   *
*                                        all trajectory dumping for    *
*                                        drawing                       *
*                                                                      *
*     Created on   01 March 1990   by        Alfredo Ferrari           *
*                                              INFN - Milan            *
*                                                                      *
*----------------------------------------------------------------------*
*
      INCLUDE 'caslim.inc'
      INCLUDE 'comput.inc'
      INCLUDE 'sourcm.inc'
      INCLUDE 'fheavy.inc'
      INCLUDE 'flkstk.inc'
      INCLUDE 'genstk.inc'
      INCLUDE 'mgddcm.inc'
      INCLUDE 'paprop.inc'
      INCLUDE 'quemgd.inc'
      INCLUDE 'sumcou.inc'
      INCLUDE 'trackr.inc'
*
      DIMENSION DTQUEN ( MXTRCK, MAXQMG )
*
      CHARACTER*20 FILNAM
      CHARACTER*8 FL_InReg
      CHARACTER*8 FL_OutReg
      character(8)  :: date
      character(10) :: time

120   FORMAT (100A20,5X)
121   FORMAT (I20,2A20,2I20,13ES20.7,2I20,4ES20.7)

      LOGICAL LFCOPE
      SAVE LFCOPE
      DATA LFCOPE / .FALSE. /
    
*
*----------------------------------------------------------------------*
*                                                                      *
*     Icode = 1: call from Kaskad                                      *
*     Icode = 2: call from Emfsco                                      *
*     Icode = 3: call from Kasneu                                      *
*     Icode = 4: call from Kashea                                      *
*     Icode = 5: call from Kasoph                                      *
*                                                                      *
*----------------------------------------------------------------------*
*                                                                      *

      RETURN
*
*======================================================================*
*                                                                      *
*     Boundary-(X)crossing DRAWing:                                    *
*                                                                      *
*     Icode = 1x: call from Kaskad                                     *
*             19: boundary crossing                                    *
*     Icode = 2x: call from Emfsco                                     *
*             29: boundary crossing                                    *
*     Icode = 3x: call from Kasneu                                     *
*             39: boundary crossing                                    *
*     Icode = 4x: call from Kashea                                     *
*             49: boundary crossing                                    *
*     Icode = 5x: call from Kasoph                                     *
*             59: boundary crossing                                    *
*                                                                      *
*======================================================================*
*                                                                      *
      ENTRY BXDRAW ( ICODE, MREG, NEWREG, XSCO, YSCO, ZSCO )

      IF ( .NOT. LFCOPE ) THEN
            LFCOPE = .TRUE.
            IF ( KOMPUT .EQ. 2 ) THEN
               FILNAM = '/'//CFDRAW(1:8)//' DUMP A'
            ELSE
               FILNAM = CFDRAW
            END IF
*     unità e nome del file vanno dati nel file di input così
            OPEN ( UNIT = IODRAW, FILE = FILNAM, STATUS = 'NEW', FORM =
     &          'FORMATTED' )
      call date_and_time(DATE=date,TIME=time)
      WRITE (IODRAW,'(a,2x,a,2x,a)') date, time, "s -> Starting date and time"
      WRITE(IODRAW,120) "NCase","RegionIn","RegionOut",
     &       "SurfaceID","ParticleID","ETot","P","Vx","Vy",
     &       "Vz","Px","Py","Pz","Cx","Cy","Cz","Weight1",
     &       "Weight2","MotherID","ProcessID","MotherETot",
     &       "MotherVx","MotherVy","MotherVz"
         END IF

*     Ottiene il nome della regione d'uscita e lo mette in NAMREG
      CALL GEOR2N (MREG, FL_InReg, IERR)
*     Ottiene il nome  della regione d'entrata e lo mette in NAMREG2
      CALL GEOR2N (NEWREG, FL_OutReg, IERR)

      !     0th detector
      IF((FL_InReg .eq. "BEAMHOLE") .and.(FL_OutReg .eq."MUDET0").or.
     &   (FL_InReg .eq. "HALLAIR").and.(FL_OutReg .eq."MUDET0").or.
     &   (FL_InReg .eq. "DUMP5")  .and.(FL_OutReg .eq."MUDET0").or.
     &   (FL_InReg .eq. "DUMP4")  .and.(FL_OutReg .eq."MUDET0").or.
     &   (FL_InReg .eq. "DUMP3")  .and.(FL_OutReg .eq."MUDET0")) THEN
      
      
      WRITE(IODRAW,121) NCASE, FL_InReg, FL_OutReg,
     &                  1,JTRACK,ETRACK,PTRACK,
     &                  XSCO, YSCO, ZSCO,
     &                  PTRACK*CXTRCK, PTRACK*CYTRCK, PTRACK*CZTRCK,
     &                  CXTRCK, CYTRCK, CZTRCK,
     &                  WTRACK, WSCRNG,
     &                  ISPUSR(1),ISPUSR(2),
     &                  SPAUSR(1),SPAUSR(2),SPAUSR(3),SPAUSR(4)
      END IF

!     1st detector
      IF((FL_InReg .eq. "BEVAC2") .and.(FL_OutReg .eq."MUDET1_4").or.
     &   (FL_InReg .eq. "BEPIP2") .and.(FL_OutReg .eq."MUDET1_3").or.
     &   (FL_InReg .eq. "CPSDSSH").and.(FL_OutReg .eq."MUDET1_2").or.
     &   (FL_InReg .eq. "HALLAIR").and.(FL_OutReg .eq."MUDET1_1").or.
     &   (FL_InReg .eq. "DUMP5")  .and.(FL_OutReg .eq."MUDET1_1").or.
     &   (FL_InReg .eq. "DUMP4")  .and.(FL_OutReg .eq."MUDET1_1").or.
     &   (FL_InReg .eq. "DUMP3")  .and.(FL_OutReg .eq."MUDET1_1")) THEN
      
      
      WRITE(IODRAW,121) NCASE, FL_InReg, FL_OutReg,
     &                  2,JTRACK,ETRACK,PTRACK,
     &                  XSCO, YSCO, ZSCO,
     &                  PTRACK*CXTRCK, PTRACK*CYTRCK, PTRACK*CZTRCK,
     &                  CXTRCK, CYTRCK, CZTRCK,
     &                  WTRACK, WSCRNG,
     &                  ISPUSR(1),ISPUSR(2),
     &                  SPAUSR(1),SPAUSR(2),SPAUSR(3),SPAUSR(4)
      END IF


!     2nd detector
      IF((FL_InReg .eq. "BEVAC2") .and.(FL_OutReg .eq."MUDET2_5").or.
     &   (FL_InReg .eq. "BEPIP2") .and.(FL_OutReg .eq."MUDET2_4").or.
     &   (FL_InReg .eq. "HALLAIR").and.(FL_OutReg .eq."MUDET2_3").or.
     &   (FL_InReg .eq. "PERMAG") .and.(FL_OutReg .eq."MUDET2_2").or.
     &   (FL_InReg .eq. "HALLAIR").and.(FL_OutReg .eq."MUDET2_1").or.
     &   (FL_InReg .eq. "DUMP5")  .and.(FL_OutReg .eq."MUDET2_1").or.
     &   (FL_InReg .eq. "DUMP4")  .and.(FL_OutReg .eq."MUDET2_1").or.
     &   (FL_InReg .eq. "DUMP3")  .and.(FL_OutReg .eq."MUDET2_1")) THEN      

      
      WRITE(IODRAW,121) NCASE, FL_InReg, FL_OutReg,
     &                  3,JTRACK,ETRACK,PTRACK,
     &                  XSCO, YSCO, ZSCO,
     &                  PTRACK*CXTRCK, PTRACK*CYTRCK, PTRACK*CZTRCK,
     &                  CXTRCK, CYTRCK, CZTRCK,
     &                  WTRACK, WSCRNG,
     &                  ISPUSR(1),ISPUSR(2),
     &                  SPAUSR(1),SPAUSR(2),SPAUSR(3),SPAUSR(4)
      END IF


!     3rd detector
      IF((FL_InReg .eq. "BEVAC2") .and.(FL_OutReg .eq."MUDET3_5").or.
     &   (FL_InReg .eq. "BEPIP2") .and.(FL_OutReg .eq."MUDET3_4").or.
     &   (FL_InReg .eq. "HALLAIR").and.(FL_OutReg .eq."MUDET3_3").or.
     &   (FL_InReg .eq. "PERMAG") .and.(FL_OutReg .eq."MUDET3_2").or.
     &   (FL_InReg .eq. "HALLAIR").and.(FL_OutReg .eq."MUDET3_1").or.
     &   (FL_InReg .eq. "DUMP5")  .and.(FL_OutReg .eq."MUDET3_1").or.
     &   (FL_InReg .eq. "DUMP4")  .and.(FL_OutReg .eq."MUDET3_1").or.
     &   (FL_InReg .eq. "DUMP3")  .and.(FL_OutReg .eq."MUDET3_1")) THEN      

      
      WRITE(IODRAW,121) NCASE, FL_InReg, FL_OutReg,
     &                  4,JTRACK,ETRACK,PTRACK,
     &                  XSCO, YSCO, ZSCO,
     &                  PTRACK*CXTRCK, PTRACK*CYTRCK, PTRACK*CZTRCK,
     &                  CXTRCK, CYTRCK, CZTRCK,
     &                  WTRACK, WSCRNG,
     &                  ISPUSR(1),ISPUSR(2),
     &                  SPAUSR(1),SPAUSR(2),SPAUSR(3),SPAUSR(4)
      END IF


!     4th detector
      IF((FL_InReg .eq. "BEVAC3") .and.(FL_OutReg .eq."MUDET4_3").or.
     &   (FL_InReg .eq. "BEPIP3") .and.(FL_OutReg .eq."MUDET4_2").or.
     &   (FL_InReg .eq. "HALLAIR").and.(FL_OutReg .eq."MUDET4_1").or.
     &   (FL_InReg .eq. "DUMP5")  .and.(FL_OutReg .eq."MUDET4_1").or.
     &   (FL_InReg .eq. "DUMP4")  .and.(FL_OutReg .eq."MUDET4_1").or.
     &   (FL_InReg .eq. "DUMP3")  .and.(FL_OutReg .eq."MUDET4_1")) THEN      

      
      WRITE(IODRAW,121) NCASE, FL_InReg, FL_OutReg,
     &                  5,JTRACK,ETRACK,PTRACK,
     &                  XSCO, YSCO, ZSCO,
     &                  PTRACK*CXTRCK, PTRACK*CYTRCK, PTRACK*CZTRCK,
     &                  CXTRCK, CYTRCK, CZTRCK,
     &                  WTRACK, WSCRNG,
     &                  ISPUSR(1),ISPUSR(2),
     &                  SPAUSR(1),SPAUSR(2),SPAUSR(3),SPAUSR(4)
      END IF


!     5th detector
      IF((FL_InReg .eq. "BEVAC3") .and.(FL_OutReg .eq."MUDET5_3").or.
     &   (FL_InReg .eq. "BEPIP3") .and.(FL_OutReg .eq."MUDET5_2").or.
     &   (FL_InReg .eq. "HALLAIR").and.(FL_OutReg .eq."MUDET5_1").or.
     &   (FL_InReg .eq. "DUMP5")  .and.(FL_OutReg .eq."MUDET5_1")) THEN      

      
      WRITE(IODRAW,121) NCASE, FL_InReg, FL_OutReg,
     &                  6,JTRACK,ETRACK,PTRACK,
     &                  XSCO, YSCO, ZSCO,
     &                  PTRACK*CXTRCK, PTRACK*CYTRCK, PTRACK*CZTRCK,
     &                  CXTRCK, CYTRCK, CZTRCK,
     &                  WTRACK, WSCRNG,
     &                  ISPUSR(1),ISPUSR(2),
     &                  SPAUSR(1),SPAUSR(2),SPAUSR(3),SPAUSR(4)
      END IF

      !     6th detector
      IF((FL_InReg .eq. "MUDETR0") .and.(FL_OutReg .eq."MUDETR1")) THEN      

      WRITE(IODRAW,121) NCASE, FL_InReg, FL_OutReg,
     &                  7,JTRACK,ETRACK,PTRACK,
     &                  XSCO, YSCO, ZSCO,
     &                  PTRACK*CXTRCK, PTRACK*CYTRCK, PTRACK*CZTRCK,
     &                  CXTRCK, CYTRCK, CZTRCK,
     &                  WTRACK, WSCRNG,
     &                  ISPUSR(1),ISPUSR(2),
     &                  SPAUSR(1),SPAUSR(2),SPAUSR(3),SPAUSR(4)
      END IF

      RETURN
*
*======================================================================*
*                                                                      *
*     Event End DRAWing:                                               *
*                                                                      *
*======================================================================*
*                                                                      *
      ENTRY EEDRAW ( ICODE )
      RETURN
*
*======================================================================*
*                                                                      *
*     ENergy deposition DRAWing:                                       *
*                                                                      *
*     Icode = 1x: call from Kaskad                                     *
*             10: elastic interaction recoil                           *
*             11: inelastic interaction recoil                         *
*             12: stopping particle                                    *
*             13: pseudo-neutron deposition                            *
*             14: escape                                               *
*             15: time kill                                            *
*             16: recoil from (heavy) bremsstrahlung                   *
*     Icode = 2x: call from Emfsco                                     *
*             20: local energy deposition (i.e. photoelectric)         *
*             21: below threshold, iarg=1                              *
*             22: below threshold, iarg=2                              *
*             23: escape                                               *
*             24: time kill                                            *
*     Icode = 3x: call from Kasneu                                     *
*             30: target recoil                                        *
*             31: below threshold                                      *
*             32: escape                                               *
*             33: time kill                                            *
*     Icode = 4x: call from Kashea                                     *
*             40: escape                                               *
*             41: time kill                                            *
*             42: delta ray stack overflow                             *
*     Icode = 5x: call from Kasoph                                     *
*             50: optical photon absorption                            *
*             51: escape                                               *
*             52: time kill                                            *
*                                                                      *
*======================================================================*
*                                                                      *
      ENTRY ENDRAW ( ICODE, MREG, RULL, XSCO, YSCO, ZSCO )
      RETURN
*
*======================================================================*
*                                                                      *
*     SOurce particle DRAWing:                                         *
*                                                                      *
*======================================================================*
*
      ENTRY SODRAW

      RETURN
*
*======================================================================*
*                                                                      *
*     USer dependent DRAWing:                                          *
*                                                                      *
*     Icode = 10x: call from Kaskad                                    *
*             100: elastic   interaction secondaries                   *
*             101: inelastic interaction secondaries                   *
*             102: particle decay  secondaries                         *
*             103: delta ray  generation secondaries                   *
*             104: pair production secondaries                         *
*             105: bremsstrahlung  secondaries                         *
*             110: radioactive decay products                          *
*     Icode = 20x: call from Emfsco                                    *
*             208: bremsstrahlung secondaries                          *
*             210: Moller secondaries                                  *
*             212: Bhabha secondaries                                  *
*             214: in-flight annihilation secondaries                  *
*             215: annihilation at rest   secondaries                  *
*             217: pair production        secondaries                  *
*             219: Compton scattering     secondaries                  *
*             221: photoelectric          secondaries                  *
*             225: Rayleigh scattering    secondaries                  *
*             237: mu pair production     secondaries                  *
*     Icode = 30x: call from Kasneu                                    *
*             300: interaction secondaries                             *
*     Icode = 40x: call from Kashea                                    *
*             400: delta ray  generation secondaries                   *
*     Icode = 50x: call from synstp                                    *
*             500: synchrotron radiation photons from e-/e+            *
*             501: synchrotron radiation photons from other charged    *
*                  particles                                           *
*  For all interactions secondaries are put on GENSTK common (kp=1,np) *
*  but for KASHEA delta ray generation where only the secondary elec-  *
*  tron is present and stacked on FLKSTK common for kp=npflka          *
*                                                                      *
*======================================================================*
*
      ENTRY USDRAW ( ICODE, MREG, XSCO, YSCO, ZSCO )

      SPAUSR(1) = ETRACK

      SPAUSR(2) = XSCO
      SPAUSR(3) = YSCO
      SPAUSR(4) = ZSCO

      ISPUSR(1) = JTRACK
      ISPUSR(2) = ICODE

* No output by default:
      RETURN
*=== End of subrutine Mgdraw ==========================================*
      END

