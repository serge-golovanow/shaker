/*******************************************************************************
 * locks.p : display locks for connected base
 * Maxime D., Serge Golovanow
 ******************************************************************************/
   
DEFINE VARIABLE i AS INTEGER     NO-UNDO.
/* define variable ligne as character. */

DEFINE TEMP-TABLE ttLock NO-UNDO
    FIELD cDBName       AS CHARACTER
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
    FIELD iREcid        AS   RECID.

REPEAT i=1 TO NUM-DBS :
    CREATE ALIAS monAlias FOR DATABASE VALUE(LDBNAME(i)).

    RUN locksload.p (INPUT-OUTPUT TABLE ttLock, INPUT LDBNAME(i)).

    DELETE ALIAS monAlias.
END.

FOR EACH ttLock NO-LOCK :
    disp
    ttLock.Lockuser format ">>>9"
    ttLock.Lockname    
    iRECID format "99999999"    
    ttLock.lockTable FORMAT ">>9"
    ttLock.lockFile FORMAT "X(12)"
    /* ttLock.colIndex */
    ttLock.Lockflag
    with width 110.
    
    /*assign ligne = 
      STRING(ttLock.lockTable)
      + ";" + ttLock.lockFile
      + "." + ttlock.colIndex
      + ";" + STRING(ttlock.Lockuser)
      + ";" + ttlock.Lockname
      + ";" + ttlock.Lockflag
      + ";" + STRING(iRECID)
    .
    disp ligne format "x(130)" with width 132.*/
END.

