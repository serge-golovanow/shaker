/*******************************************************************************
 * locksload.p : return locks for connected base
 * Maxime D., Serge Golovanow
 ******************************************************************************/
 
DEFINE TEMP-TABLE ttLock
    FIELD cDBNAME       AS CHARACTER
    FIELD lockUser      LIKE _lock._lock-usr
    FIELD lockName      LIKE _lock._lock-name
    FIELD lockFlag      LIKE _lock._lock-flag
    FIELD LockTable     LIKE _lock._lock-table    
    FIELD lockShare     AS   LOGICAL FORMAT "X/"
    FIELD lockExclusive AS   LOGICAL FORMAT "X/"
    FIELD lockLimbo     AS   LOGICAL FORMAT "X/"
    FIELD lockUpgrade   AS   LOGICAL FORMAT "X/"
    FIELD lockQueued    AS   LOGICAL FORMAT "X/"
    FIELD lockFile     LIKE _file._file-name
    FIELD userName      LIKE _connect._connect-name   FORMAT "X(30)"
    FIELD userDevice    LIKE _connect._connect-device
    FIELD valIndex      AS   CHARACTER                FORMAT "X(100)"
    FIELD colIndex      AS   CHARACTER                FORMAT "X(30)"
    FIELD nomIndex      AS   CHARACTER                FORMAT "X(15)"
    FIELD nbRecords     AS   INTEGER
    FIELD iRECID        AS   RECID.

DEFINE INPUT-OUTPUT PARAMETER TABLE FOR ttLock.
DEFINE INPUT  PARAMETER icDBName AS CHARACTER   NO-UNDO.

DEFINE VARIABLE cTemp1  AS CHARACTER   NO-UNDO.
DEFINE VARIABLE iTemp1  AS INTEGER     NO-UNDO.
DEFINE VARIABLE hBuffer AS HANDLE      NO-UNDO.
DEFINE VARIABLE rRowid  AS ROWID       NO-UNDO.
DEFINE VARIABLE rRecid  AS RECID       NO-UNDO.
DEFINE VARIABLE iNbrRecord AS INTEGER     NO-UNDO.

FOR EACH monAlias._lock NO-LOCK
    WHILE monAlias._Lock._Lock-Flag <> ?:

    FIND FIRST monAlias._connect
        WHERE monAlias._connect._connect-usr = monAlias._lock._lock-usr
        NO-LOCK NO-ERROR.
    FIND FIRST monAlias._file
        WHERE monAlias._file._file-num = monAlias._lock._lock-table
        NO-LOCK NO-ERROR.

    IF monAlias._lock._lock-usr = ? THEN NEXT.
    FIND ttLock
        WHERE ttLock.lockUser  = monAlias._lock._lock-usr
        AND   ttLock.lockFile = monAlias._file._file-name
        NO-ERROR.
    IF NOT AVAILABLE ttLock THEN DO:
        CREATE ttLock.
        iNbrRecord = 0.
    END.
    ASSIGN ttLock.lockUser   = monAlias._lock._lock-usr 
           ttLock.lockTable  = monAlias._lock._lock-table
           ttLock.lockName   = monAlias._lock._lock-name
           ttLock.lockFlag   = monAlias._lock._lock-flag
           ttLock.lockFile  = monAlias._file._file-name
           ttLock.userName   = monAlias._connect._connect-name
           ttLock.userDevice = monAlias._connect._connect-device
           ttLock.cDBName    = icDBName
           ttLock.iREcid     = monAlias._lock._lock-recid.

    IF ttLock.lockFlag MATCHES "*X*" THEN ttLock.lockExclusive = YES.
    IF ttLock.lockFlag MATCHES "*L*" THEN ttLock.lockLimbo     = YES.
    IF ttLock.lockFlag MATCHES "*U*" THEN ttLock.lockUpgrade   = YES.
    IF ttLock.lockFlag MATCHES "*S*" THEN ttLock.lockShare     = YES.
    IF ttLock.lockFlag MATCHES "*Q*" THEN ttLock.lockQueued    = YES.

    RUN convrxxid_c.p (?,_lock._lock-recid,
                                    OUTPUT rRowid,OUTPUT rRecid).

    IF rRowid <> ? THEN DO:
        FIND FIRST monAlias._index
            WHERE RECID(monAlias._index) = monAlias._file._Prime-Index
            NO-LOCK NO-ERROR.
        IF AVAILABLE monAlias._index THEN DO:
            cTemp1 = "".
            FOR EACH monAlias._index-field OF monAlias._index NO-LOCK,
            FIRST monAlias._field OF monAlias._index-field NO-LOCK:
                cTemp1 = cTemp1 + "," + monAlias._field._field-name.
            END.
            cTemp1 = SUBSTRING(cTemp1,2).
            ASSIGN ttLock.colIndex = cTemp1
                   ttLock.nomIndex = monAlias._index._index-name.
        END.

        CREATE BUFFER hBuffer FOR TABLE monAlias._file._file-name.
        hBuffer:FIND-BY-ROWID(rRowid,NO-LOCK).
        IF hBuffer:AVAILABLE THEN DO:
            DO iTemp1 = 1 TO NUM-ENTRIES(cTemp1):
                ttLock.valIndex = ttLock.valIndex + "#" + hBuffer:BUFFER-FIELD(ENTRY(iTemp1,cTemp1)):BUFFER-VALUE.
            END.
            ttLock.valIndex = SUBSTRING(ttLock.valIndex,2).
        END.
        ttLock.nbRecords  = ttLock.nbRecords + 1.
        DELETE OBJECT hBuffer.
    END.
END.

