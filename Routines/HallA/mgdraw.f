      SUBROUTINE MGDRAW ( ICODE, MREG )

      INCLUDE 'dblprc.inc'
      INCLUDE 'dimpar.inc'
      INCLUDE 'iounit.inc'
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

      DIMENSION DTQUEN ( MXTRCK, MAXQMG )

      CHARACTER*20 FILNAM
      CHARACTER*8 FL_InReg
      CHARACTER*8 FL_OutReg
      character(8)  :: date
      character(10) :: time

      INTEGER :: SURFID1
      INTEGER :: SURFID2

120   FORMAT (100A20,5X)
121   FORMAT (I20,2A20,2I20,13ES20.7,I20,4ES20.7)

      LOGICAL LFCOPE
      SAVE LFCOPE
      DATA LFCOPE / .FALSE. /
      
      CHARACTER(len=8), DIMENSION(22) :: InRegTopDet, OutRegTopDet
      CHARACTER(len=8), DIMENSION(23) :: InRegUpDet, OutRegUpDet
      
      InRegTopDet = [CHARACTER(len=8) :: "Dirth4","Dirth4","Dirth4",         !3
     & "Dirth4","Dirth4","Dirth4","Dirth4","Dirth4","Dirth4","UP_DET22",      !10
     & "Dirth4","Dirth4","Dirth4","Dirth4","Dirth4","Dirth4","Dirth4",        !17
     & "Dirth4","Dirth4","Dirth4","Dirth4","Dirth4"]                          !22
      
      OutRegTopDet = [CHARACTER(len=8) :: "DET1","DET2","DET3","DET4",        !4
     & "DET5","DET6","DET7","DET8","DET9","DET10","DET11","DET12",
     & "DET13","DET14","DET15","DET16","DET17","DET18","DET19","DET20",
     & "DET21","DET22"]

      InRegUpDet = [CHARACTER(len=8) :: "NATM","UP_DET1","UP_DET2",          !3
     & "UP_DET3","UP_DET4","UP_DET5","UP_DET6","UP_DET7","UP_DET8",           !9
     & "UP_DET9","UP_DET10","UP_DET11","UP_DET12","UP_DET13",                 !14
     & "UP_DET14","UP_DET15","UP_DET16","UP_DET17","UP_DET18",                !19
     & "UP_DET19","UP_DET20","UP_DET21","UP_DET22"]                           !22

      OutRegUpDet = [CHARACTER(len=8) :: "UP_DET1","UP_DET2","UP_DET3",
     & "UP_DET4","UP_DET5","UP_DET6","UP_DET7","UP_DET8","UP_DET9",
     & "UP_DET10","UP_DET11","UP_DET12","UP_DET13","UP_DET14",
     & "UP_DET15","UP_DET16","UP_DET17","UP_DET18","UP_DET19",
     & "UP_DET20","UP_DET21","UP_DET22","DET10"]                  

      RETURN

*****************************************************************************************
*****************************************************************************************
*****************************************************************************************

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
      CALL date_and_time(DATE=date,TIME=time)
      WRITE (IODRAW,'(a,2x,a,2x,a)') date, time, "s -> Starting date and time"
      WRITE(IODRAW,120) "NCase","RegionIn","RegionOut",
     &       "SurfaceID","ParticleID","ETot","P","Vx","Vy",
     &       "Vz","Px","Py","Pz","Cx","Cy","Cz","Weight1",
     &       "Weight2","MotherID","MotherETot",
     &       "MotherVx","MotherVy","MotherVz"
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
      SURFID1 = n+100
      IF((FL_InReg.eq.InRegTopDet(n)).and.
     & (FL_OutReg.eq.OutRegTopDet(n))) THEN      
      
      IF(            
     &   (JTRACK.eq.8)                                                  !neutron                                     
     &  ) THEN

      WRITE(IODRAW,121) NCASE, FL_InReg, FL_OutReg,
     &                  SURFID1,JTRACK,ETRACK,PTRACK,
     &                  XSCO, YSCO, ZSCO,
     &                  PTRACK*CXTRCK, PTRACK*CYTRCK, PTRACK*CZTRCK,
     &                  CXTRCK, CYTRCK, CZTRCK,
     &                  WTRACK, WSCRNG,
     &                  ISPUSR(1),
     &                  SPAUSR(1),SPAUSR(2),SPAUSR(3),SPAUSR(4)

      END IF
      END IF
      END DO

      DO n=1, 23
      SURFID2 = n
      IF((FL_InReg.eq.InRegUpDet(n)).and.
     & (FL_OutReg.eq.OutRegUpDet(n))) THEN      
      
      IF(                  
     &   (JTRACK.eq.8)                                                  !neutron                                         
     &  ) THEN

      WRITE(IODRAW,121) NCASE, FL_InReg, FL_OutReg,
     &                  SURFID2,JTRACK,ETRACK,PTRACK,
     &                  XSCO, YSCO, ZSCO,
     &                  PTRACK*CXTRCK, PTRACK*CYTRCK, PTRACK*CZTRCK,
     &                  CXTRCK, CYTRCK, CZTRCK,
     &                  WTRACK, WSCRNG,
     &                  ISPUSR(1),
     &                  SPAUSR(1),SPAUSR(2),SPAUSR(3),SPAUSR(4)

      END IF
      END IF
      END DO

      IF((FL_InReg.eq."Dumpcov").and.(FL_OutReg.eq."Dirth1").or.
     &   (FL_InReg.eq."UP_DET14").and.(FL_OutReg.eq."UP_DET15")) THEN      
      
      IF(                  
     &   (JTRACK.eq.8).and.(CYTRCK.gt.0)                                           !neutron                                         
     &  ) THEN

      WRITE(IODRAW,121) NCASE, FL_InReg, FL_OutReg,
     &                  500,JTRACK,ETRACK,PTRACK,
     &                  XSCO, YSCO, ZSCO,
     &                  PTRACK*CXTRCK, PTRACK*CYTRCK, PTRACK*CZTRCK,
     &                  CXTRCK, CYTRCK, CZTRCK,
     &                  WTRACK, WSCRNG,
     &                  ISPUSR(1),
     &                  SPAUSR(1),SPAUSR(2),SPAUSR(3),SPAUSR(4)

      END IF
      END IF

      RETURN

      ENTRY EEDRAW ( ICODE )

      RETURN

      ENTRY ENDRAW ( ICODE, MREG, RULL, XSCO, YSCO, ZSCO )

      RETURN

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

