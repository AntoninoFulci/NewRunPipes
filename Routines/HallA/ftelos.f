*
*=== Ftelos ===========================================================*
*
      SUBROUTINE FTELOS

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

*
*----------------------------------------------------------------------*
*                                                                      *
*     Copyright (C) 2003-2019:  CERN & INFN                            *
*     All Rights Reserved.                                             *
*                                                                      *
*     Fluka TELOS (death): this routine is called at the very end of a *
*                          FLUKA run                                   *
*                                                                      *
*     Created on   12 November 2009   by         Alfredo Ferrari       *
*                                                   CERN - EN          *
*                                                                      *
*----------------------------------------------------------------------*
*
      CHARACTER*20 FILNAM
      character(8)  :: date
      character(10) :: time

      IF ( KOMPUT .EQ. 2 ) THEN
            FILNAM = '/'//CFDRAW(1:8)//' DUMP A'
      ELSE
            FILNAM = CFDRAW
      END IF
*     unità e nome del file vanno dati nel file di input così
      OPEN ( UNIT = 99, FILE = FILNAM, STATUS = 'OLD', FORM =
     &          'FORMATTED' )

114   FORMAT (I20,3X,A)
115   FORMAT (ES20.7,3X,A)


      WRITE (99,*) "#####"
      WRITE (99,115) TPMEAN, "s -> Average CPU time used to follow a primary particle"
      call date_and_time(DATE=date,TIME=time)
      WRITE (99,'(a,2x,a,2x, a)') date, time, "s -> Ending date and time"
      WRITE (99,114) NCASE,  "  -> Total number of primaries"




      RETURN
*=== End of subroutine Ftelos =========================================*
      END

