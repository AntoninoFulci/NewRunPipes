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

      INTEGER :: SURFID

120   FORMAT (100A20,5X)
121   FORMAT (I20,2A20,2I20,100ES20.7)

      LOGICAL LFCOPE
      SAVE LFCOPE
      DATA LFCOPE / .FALSE. /
      
      CHARACTER(len=8), DIMENSION(22) :: InRegTopDet, OutRegTopDet

      InRegTopDet  = [CHARACTER(len=8) :: "Dirth4","Dirth4","Dirth4",
     & "Dirth4","Dirth4","Dirth4","Dirth4","Dirth4","Dirth4","UP_DET22",
     & "Dirth4","Dirth4","Dirth4","Dirth4","Dirth4","Dirth4","Dirth4",
     & "Dirth4","Dirth4","Dirth4","Dirth4","Dirth4"]

      OutRegTopDet = [CHARACTER(len=8) :: "DET1","DET2","DET3","DET4",
     & "DET5","DET6","DET7","DET8","DET9","DET10","DET11","DET12",
     & "DET13","DET14","DET15","DET16","DET17","DET18","DET19","DET20",
     & "DET21","DET22"]
    
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
            WRITE(IODRAW,120) "NCase","RegionIn","RegionOut",
     &       "SurfaceID","ParticleID","ETot","P","Vx","Vy",
     &       "Vz","Px","Py","Pz","Cx","Cy","Cz","Weight1",
     &       "Weight2"
         END IF

*     Ottiene il nome della regione d'uscita e lo mette in NAMREG
      CALL GEOR2N (MREG, FL_InReg, IERR)
*     Ottiene il nome  della regione d'entrata e lo mette in NAMREG2
      CALL GEOR2N (NEWREG, FL_OutReg, IERR)
      
*     Loop for the top detectors
*     Ogni volta che c'è una particella che attraversa una superficie 
*     tra due regioni fluka fa partire il loop
*     comparando i nomi delle superfici
*     non appena trova una corrispondenza esce dal ciclo
*     perchè non possono essere le altre

      DO n=1, 22
      SURFID = n
      IF((FL_InReg.eq.InRegTopDet(n)).and.
     & (FL_OutReg.eq.OutRegTopDet(n))) THEN      
      
      IF(
     &   (JTRACK.eq.10).or.(JTRACK.eq.11)                               !mu+/mu-
     &   .or.                           
     &   (JTRACK.eq.8)                                                  !neutron
     &   .or.                                              
     &   (JTRACK.eq.5).or.(JTRACK.eq.6)                                 !nue/anue
     &   .or.
     &   (JTRACK.eq.27).or.(JTRACK.eq.28)                               !num/anum
     &   .or.
     &   (JTRACK.eq.43).or.(JTRACK.eq.44)                               !nut/anut
     &  ) THEN

      WRITE(IODRAW,121) NCASE, FL_InReg, FL_OutReg,
     &                  SURFID,JTRACK,ETRACK,PTRACK,
     &                  XSCO, YSCO, ZSCO,
     &                  PTRACK*CXTRCK, PTRACK*CYTRCK, PTRACK*CZTRACK,
     &                  CXTRCK, CYTRCK, CZTRCK,
     &                  WTRACK, WSCRNG

      END IF
      EXIT
      END IF
      END DO



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

* No output by default:
      RETURN
*=== End of subrutine Mgdraw ==========================================*
      END

