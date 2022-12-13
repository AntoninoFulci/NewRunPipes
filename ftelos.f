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

      IF ( KOMPUT .EQ. 2 ) THEN
            FILNAM = '/'//CFDRAW(1:8)//' DUMP A'
      ELSE
            FILNAM = CFDRAW
      END IF
*     unità e nome del file vanno dati nel file di input così
      OPEN ( UNIT = 99, FILE = FILNAM, STATUS = 'OLD', FORM =
     &          'FORMATTED' )

114   FORMAT (A55,I20)
115   FORMAT (A55,ES20.7,5X,A)

      WRITE (99,*) "#####"
      WRITE (99,115) "Average CPU time used to follow a primary particle: ", TPMEAN, "s"
      WRITE (99,115) "Total CPU time used to follow all primary particles: ", TRNTOT, "s"
      WRITE (99,114) "Total number of primaries: ", NCASE




      RETURN
*=== End of subroutine Ftelos =========================================*
      END

