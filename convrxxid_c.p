/* Richard Tardivon - PSC */
/* Outil pour conversion d'un Rowid => Recid et inversemment */
DEFINE INPUT  PARAMETER irRowid      AS ROWID      NO-UNDO.
DEFINE INPUT  PARAMETER irRecid      AS RECID      NO-UNDO.
DEFINE OUTPUT PARAMETER orRowid      AS ROWID      NO-UNDO.
DEFINE OUTPUT PARAMETER orRecid      AS RECID      NO-UNDO.

DEFINE VARIABLE cTemp1 AS CHARACTER   NO-UNDO.

/* Conversion d'un Recid => Rowid */
IF irRecid <> ? THEN DO:
    RUN intToHex (irRecid,OUTPUT cTemp1).
    orRowid = TO-ROWID(cTemp1).
END.
/* Conversion d'un Rowid => Recid */
ELSE RUN hexToInt (STRING(irRowid),OUTPUT orRecid).

/* Procédure de conversion d'un entier (RECID) vers un Hexa (Rowid) */
PROCEDURE intToHex:

    DEFINE INPUT  PARAMETER i AS INTEGER   NO-UNDO. 
    DEFINE OUTPUT PARAMETER c AS CHARACTER NO-UNDO. 

    DEFINE VARIABLE j AS INTEGER  NO-UNDO. 

    DO WHILE TRUE: 
        j = i MODULO 16. 
        c = (IF j < 10 THEN STRING(j) ELSE CHR(ASC("a") + j - 10)) + c. 
        IF i < 16 THEN LEAVE. 
        i = (i - j) / 16. 
    END. 

    j = 8 - LENGTH(c). 
    DO i = 1 TO j: 
        c = "0" + c. 
    END. 
    c = "0x" + c. 

END PROCEDURE.

/* Procédure de conversion d'un Hexa (Rowid) vers un entier (RECID) */
PROCEDURE hexToInt :

    DEFINE INPUT  PARAMETER icRowid AS CHARACTER  NO-UNDO.
    DEFINE OUTPUT PARAMETER oiRecid AS INTEGER    NO-UNDO.

    DEFINE VARIABLE iTemp1 AS INTEGER    NO-UNDO.

    ASSIGN icRowid = SUBSTRING(icRowid,3,LENGTH(icRowid))
           icRowid = CAPS(icRowid).

    DO iTemp1 = 1 TO LENGTH(icRowid):
        IF CAN-DO("0,1,2,3,4,5,6,7,8,9", (SUBSTRING(icRowid, iTemp1, 1))) THEN
            oiRecid = oiRecid + 
                      INTEGER(SUBSTRING(icRowid, iTemp1, 1)) *
                      EXP(16, (LENGTH(icRowid) - iTemp1)).
        ELSE
            oiRecid = oiRecid +
                      (KEYCODE(SUBSTRING(icRowid, iTemp1, 1)) - KEYCODE("A") + 10) * 
                      EXP(16, (LENGTH(icRowid) - iTemp1)).
    END.

END PROCEDURE.

