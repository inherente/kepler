CREATE OR REPLACE package body V3_SYSADMIN.HELP_DESK
is
 -- Region (ok)
 -- Area (x)
 -- Territorio (ok)
 -- Nomina Gerente de area (x)
 -- Nombre Gerente de area (ok)
 -- Nomina Jefe Operativo (x)
 -- Nombre Jefe Operativo (x)
 -- Nomina del representante (ok)
 -- Nombre del representante (ok)
 -- Factura (ok)
 -- Fecha registro del incidente (ok)
 -- Tipo de incidente (ok)
 -- Monto de la factura (ok)

    FUNCTION GET_ANYTHING RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Hola';
    END;

    FUNCTION GET_ACCOUNT_STATUS(p_name varchar2) RETURN VARCHAR2
    IS
    l_Last_value varchar2(1024);
    l_value varchar2(1024);
    BEGIN
        
            execute immediate 
                'SELECT A.ACCOUNT_STATUS , A.USERNAME USUARIO FROM DBA_USERS A, S_USER B,S_CONTACT C,S_INVLOC SINV,S_POSTN POS ,S_ASGN_GRP TERR WHERE B.LOGIN(+) = A.USERNAME AND C.PAR_ROW_ID(+) = B.ROW_ID AND A.USERNAME = B.LOGIN(+) AND SINV.INV_ASSIGN_TO_ID(+) = B.ROW_ID AND SINV.PR_POSTN_ID=POS.ROW_ID(+) AND SINV.PR_POSTN_ID=TERR.PR_POSTN_ID(+) AND A.USERNAME = :1'
         -- Select 500, 501 into l_Last_value, l_value from dual;
            using p_name;
            dbms_output.put_line (l_value || ' . ' || l_Last_value);
        RETURN 'Hola';

    END;

    FUNCTION translate_STATUS(p_name varchar2) RETURN VARCHAR2
    IS
    l_Last_value varchar2(1024);
    l_value varchar2(1024);
    default_value varchar2(1024);
    BEGIN
        l_Value := INFORM_TO_V3SYSADMIN_TEXT;
        default_value:= l_Value ; 
        Select decode(p_Name,
            NOTRANSACTION_TEXT, INFORM_TO_V3SYSADMIN_TEXT,
            COMPLETED_TEXT, DONOT_INFORM_V3SYSADMIN_TEXT,
            default_Value 
        ) into l_Value from dual;
        
         -- Select 500, 501 into l_Last_value, l_value from dual;
            dbms_output.put_line (l_value || ' . ' || l_Last_value);
        RETURN l_Value;

    END;

    procedure getThingsToWork (
        p_option in number ,
        p_value out cursorType,
        p_row out number
    ) is
    i number;
    PN_SID NUMBER;
    PN_SERIAL NUMBER;

    begin
        dbms_output.put_line ('-');
        begin

            Select 0, 0 into PN_SID, PN_SERIAL 
            From dual a;-- Where a.status = 'Y';
        Exception When Others Then
            p_Row := 1;
        END;
    end getThingsToWork;

    procedure log_Event (
        p_option in varchar2 ,
        p_value in varchar2,
        p_UserName in varchar2
    ) is
    i number;
    begin
        dbms_output.put_line ('-');

        begin
            INSERT into HELPDESK_EVENT_LOG (
                COMMON_NAME ,
                DESCRIPTION ,
                FUNCTION_NAME ,
                CATEGORY ,
                LAST_UPDATE_DATE ,
                LAST_MODIFICATION_BY
            ) VALUES (
                'EVENT',
                p_option,
                p_value,
                'HELP_DESK',
                sysdate,
                p_UserName
            );
        Exception When Others Then 
            i := 0;
        END;
    end log_Event;

    procedure process (
        p_option in arrayTable,
        p_row out number
    ) is
    l_option number;
    i number;
    begin
        dbms_output.put_line ('-');
        p_row := 0;
        begin
            FOR i IN 1 .. p_option.COUNT
            LOOP
                DBMS_OUTPUT.put_line (p_option (i));
                p_row := p_row + 1;
            END LOOP;
        Exception When Others Then
            p_Row := 1;
        END;
    end process;

    procedure processOrder (
        p_Transaction in varchar2,
        p_option in arrayTable,
        p_row out number
    ) is
 -- i number;
    l_option number;
    i number;
    l_CurentField varchar2(1024);
    l_CurentKey varchar2(1024);
    l_CurentValue varchar2(1024);
    l_Equal_Pos number;
    l_Transaction_Id number;
    l_Row_Id number;
    l_Document_Id varchar2(1024);
    l_inst_Sql varchar2(1024);
    l_Final_Sql varchar2(1024);
    l_Inserted_Already number;

    begin
        dbms_output.put_line ('-');
     -- i := 0;
        p_row := 0;
     -- l_inst_Sql := 'Update ALA_Invoice set :1 = :2 Where Invoice_Num = :3';-- ' ';
        l_Row_Id := SiebelETL.ALA_Invoice_SEQ.nextval;
        begin
            FOR i IN 1 .. p_option.COUNT
            LOOP
                Begin
                    p_row := p_row+ 1;
                    l_inst_Sql := 'Update ALA_Order set [1] = [2] Where Transaction_Id = [3]';-- ' ';
                    l_CurentField :=p_option (i);
                    DBMS_OUTPUT.put_line (l_Row_Id || ' . [orignal] ' || l_CurentField );
                    Insert Into SiebelETL.ALA_EXCEPTION_LOG values (
                            p_row || '.a', '[orignal] ' || p_Transaction || ' - ' || l_CurentField|| ' :.'  ,'processOrder', 'Debug', sysdate, user
                    );
                    If l_CurentField is null or length(l_CurentField) < (1 + 1) Then
                        p_row := p_row -1; -- Ignored. Next element should be considered as Fisrt element .
                        continue;
                    End If;
                --
                -- Prepare Data.
                    Select INSTR(l_CurentField, '=', 1, 1) into l_Equal_Pos From dual;
                    Select Substr (l_CurentField, 0, l_Equal_Pos - 1 ) Into l_CurentKey From dual;
                    Select Substr (l_CurentField, l_Equal_Pos +1, length(l_CurentField ) - l_Equal_Pos) Into l_CurentValue From dual;
                    Insert Into SiebelETL.ALA_EXCEPTION_LOG values (
                            p_row || '.b', l_CurentField|| ' :' || l_CurentKey || ' = ' || l_CurentValue || '..'  ,'processOrder', 'Debug', sysdate, user
                    );

                    DBMS_OUTPUT.put_line (l_CurentKey || ' = ' || l_CurentValue || ' Where Transaction_Id = ' || l_Transaction_Id );
                 --
                 -- Verify if we got that document aleady.
                    Select count(1) into l_Inserted_Already From SiebelETL.ALA_Order inv
                    Where Transaction_Id= p_Transaction;-- inv.Invoice_Num = l_CurentValue

                    If l_Inserted_Already = 0 Then -- First Element basically ignored.
                        Insert Into SiebelETL.ALA_EXCEPTION_LOG values (
                            p_row || '.c', p_Transaction || ': ..'  ,'processOrder', 'Debug', sysdate, user
                        );
                        Insert Into SiebelETL.ALA_Order (Row_Id, Transaction_Id, User_Login)
                        Values (
                            l_Row_Id, p_Transaction, user
                        );
                        commit;
                    End If;

                 -- commit;
                 -- (for) Second loop

                    l_Final_Sql := REPLACE(REPLACE(REPLACE(l_inst_Sql ,'[3]', chr (39) || p_Transaction || chr (39) ) ,'[2]',  chr (39)|| l_CurentValue ||  chr (39)) ,'[1]',  l_CurentKey);
                    DBMS_OUTPUT.put_line (' . ' || l_Final_Sql );
                 -- Execute immediate l_inst_Sql using l_CurentKey, l_CurentValue, l_Transaction_Id;
                 -- Don't Execute if Value is NULL
                    If (l_CurentValue = 'null') Then
                        Insert Into SiebelETL.ALA_EXCEPTION_LOG values (
                            p_row || '.d', l_Final_Sql, 'processOrder', 'Debug', sysdate, user
                        );
                    Else
                        Execute immediate l_Final_Sql;
                    End If;
                 -- Update ALA_Invoice set Transaction_Date = sysdate Where Transaction_Id = l_Transaction_Id;
                    Update SiebelETL.ALA_Order set LAST_UPD_DATE = sysdate Where Transaction_Id = p_Transaction;
                 -- p_row := p_row +1;
                Exception When Others Then
                    Insert Into SiebelETL.ALA_EXCEPTION_LOG values (
                        'x', l_Final_Sql ,'processOrder', 'Faliure', sysdate, user
                    );
                End;
            END LOOP;
        Exception When Others Then
            p_Row := -1;
        END;
        commit;
    end processOrder;

    procedure KillSession (
        p_Transaction in varchar2,
        p_row out varchar2
    ) is
 -- i number;
    l_option number;
    i number;
    l_CurentField varchar2(1024);
    l_CurentKey varchar2(1024);
    l_CurentValue varchar2(1024);
    l_Equal_Pos number;
    l_inst_Sql varchar2(1024);
    l_Final_Sql varchar2(1024);
    begin
        dbms_output.put_line ('-');
     -- i := 0;
        p_row := 0;
        l_inst_Sql := 'ALTER USER :1 IDENTIFIED BY :2';-- ' ';
        begin
            SELECT to_Char(sysdate) into p_row FROM DUAL;
            dbms_output.put_line ('before');
            Execute immediate l_inst_Sql using p_Transaction, l_CurentValue ;
            dbms_output.put_line ('done');

        Exception When Others Then
            dbms_output.put_line('error');
            dbms_output.put_line(SQLERRM);
            p_Row := '-1';
        END;
        commit;
    end KillSession;

    procedure alterUser (
        p_Transaction in varchar2,
        p_Pass in varchar2,
        p_row out varchar2
    ) is
 -- i number;
    l_option number;
    i number;
    l_CurentField varchar2(1024);
    l_CurentKey varchar2(1024);
    l_CurentValue varchar2(1024);
    l_Equal_Pos number;
    l_inst_Sql varchar2(1024);
    l_Final_Sql varchar2(1024);
    begin
        dbms_output.put_line ('-');
     -- i := 0;
        p_row := 0;
        l_inst_Sql := 'ALTER USER :1 IDENTIFIED BY :2';-- ' ';
        begin
            SELECT to_Char(sysdate) into p_row FROM DUAL;
            dbms_output.put_line ('before');
            Execute immediate l_inst_Sql using p_Transaction, p_Pass ;
            dbms_output.put_line ('done');

        Exception When Others Then
            dbms_output.put_line('error');
            dbms_output.put_line(SQLERRM);
            p_Row := '-1';
        END;
        commit;
    end alterUser;

    procedure RECOVERUSERINFO (
        p_Transaction in varchar2,
        p_row out varchar2
    ) is
 -- i number;
    l_option number;
    i number;
    l_CurentField varchar2(1024);
    l_CurentKey varchar2(1024);
    l_CurentValue varchar2(1024);
    l_Equal_Pos number;

    l_inst_Sql varchar2(1024);
    l_Final_Sql varchar2(1024);
    begin
        dbms_output.put_line ('-');
     -- i := 0;
        p_row := 0;
        l_inst_Sql := 'Update ALA_Order set :1 = :2 Where Transaction_Id = :3';-- ' ';

        SELECT to_Char(sysdate) into p_row FROM DUAL;
        begin
            SELECT STATUS_SINC into p_Row FROM ( SELECT  CASE  WHEN   
                                     (SHSS.SYNC_TYPE_CD = 'FullSync'                   AND SHSS.SYNC_STATUS_CD = 'DBExtOK'          AND SH.SYNC_STATUS_CD ='DBExtOK'               AND SHSS.TXN_PROC_STAT_CD ='Completed'      AND SH.TXN_PROC_STAT_CD ='Completed'         AND SHSS.DBXTRACT_STAT_CD = 'Extracted'                                                                                                                                                                             AND ROUND((SYSDATE - SH.LAST_UPD)*1440,2)   < 15)  OR
                                     (SHSS.SYNC_TYPE_CD = 'FullSync'                   AND SHSS.SYNC_STATUS_CD = 'DBExtDownloadOK'  AND SH.SYNC_STATUS_CD ='DBExtDownloadOK'       AND SHSS.TXN_PROC_STAT_CD ='Completed'      AND SH.TXN_PROC_STAT_CD ='Completed'         AND SHSS.DBXTRACT_STAT_CD = 'Downloaded'                                                                                                                                                                            AND ROUND((SYSDATE - SH.LAST_UPD)*1440,2)   < 2)  OR
                                     (SHSS.SYNC_TYPE_CD = 'FullSync'                   AND SHSS.SYNC_STATUS_CD = 'InitOK'           AND SH.SYNC_STATUS_CD ='InitOK'                AND SHSS.TXN_PROC_STAT_CD ='NoTransaction'  AND SH.TXN_PROC_STAT_CD ='Completed'         AND SHSS.DBXTRACT_STAT_CD = 'Failed'                                                                                                                                                                                AND ROUND((SYSDATE - SH.LAST_UPD)*1440,2)   < 15)  OR
                                     (SHSS.SYNC_TYPE_CD = 'FullSync'                   AND SHSS.SYNC_STATUS_CD = 'TxnRcvFail'       AND SH.SYNC_STATUS_CD ='TxnRcvFail'            AND SHSS.TXN_PROC_STAT_CD ='Completed'      AND SH.TXN_PROC_STAT_CD ='Completed'         AND SHSS.DBXTRACT_STAT_CD = 'NoExtraction'                                                                                                                                                                          AND ROUND((SYSDATE - SH.LAST_UPD)*1440,2)   < 15)  OR
                                     (SHSS.SYNC_TYPE_CD = 'FullSync'                   AND SHSS.SYNC_STATUS_CD = 'TxnProcInProgress'AND SH.SYNC_STATUS_CD ='TxnProcInProgress'     AND SHSS.TXN_PROC_STAT_CD ='Completed'      AND SH.TXN_PROC_STAT_CD ='Completed'         AND SHSS.DBXTRACT_STAT_CD = 'NoExtraction'                                                                                                                                                                          AND ROUND((SYSDATE - SH.LAST_UPD)*1440,2)   < 15)  OR
                                     (SHSS.SYNC_TYPE_CD = 'FullSync'                   AND SHSS.SYNC_STATUS_CD ='TxnProcOK'         AND SH.SYNC_STATUS_CD ='TxnProcOK'             AND SHSS.TXN_PROC_STAT_CD ='Completed'      AND SH.TXN_PROC_STAT_CD ='Completed'         AND SHSS.DBXTRACT_STAT_CD = 'NoExtraction'                                                                                                                                                                          AND ROUND((SYSDATE - SH.LAST_UPD)*1440,2)   < 10)  OR
                                     --
                                     (SHSS.SYNC_TYPE_CD = 'UploadOnly'                 AND SHSS.SYNC_STATUS_CD ='TxnRcvFail'                                                                                                                                                                                                                                                                                                                                                                    AND ROUND((SYSDATE - SH.LAST_UPD)*1440,2)   < 5)   OR
                                     (SHSS.SYNC_TYPE_CD = 'UploadOnly'                 AND SHSS.SYNC_STATUS_CD ='InitOK'            AND SH.SYNC_STATUS_CD ='InitOK'                AND SHSS.TXN_PROC_STAT_CD ='NoTransaction' AND SH.TXN_PROC_STAT_CD ='Completed'         AND SHSS.DBXTRACT_STAT_CD = 'NoExtraction'                                                                                                                                                                           AND ROUND((SYSDATE - SH.LAST_UPD)*1440,2)   < 5)   OR------
                                     (SHSS.SYNC_TYPE_CD = 'UploadOnly'                 AND SHSS.SYNC_STATUS_CD ='TxnRcvOK'                                                         AND SHSS.TXN_PROC_STAT_CD ='NoTransaction'                                              AND SHSS.DBXTRACT_STAT_CD = 'NoExtraction'                                                                                                                                                                           AND ROUND((SYSDATE - SH.LAST_UPD)*1440,2)   < 5)   OR
                                     (SHSS.SYNC_TYPE_CD = 'UploadOnly'                 AND SHSS.SYNC_STATUS_CD ='TxnRcvOK'                                                         AND SHSS.TXN_PROC_STAT_CD ='Scheduled:Sync'                                             AND SHSS.DBXTRACT_STAT_CD = 'Scheduled:Sync'                                                                                                                                                                         AND ROUND((SYSDATE - SH.LAST_UPD)*1440,2)   < 5)   OR
                                     (SHSS.SYNC_TYPE_CD = 'UploadOnly'                 AND SHSS.SYNC_STATUS_CD ='TxnProcInProgress'                                                AND SHSS.TXN_PROC_STAT_CD ='Scheduled:Sync'                                             AND SHSS.DBXTRACT_STAT_CD = 'Scheduled:Sync'                                                                                                                                                                         AND ROUND((SYSDATE - SH.LAST_UPD)*1440,2)   < 5)   OR
                                     (SHSS.SYNC_TYPE_CD = 'UploadOnly'                 AND SHSS.SYNC_STATUS_CD ='TxnProcInProgress'  AND SH.SYNC_STATUS_CD ='TxnProcInProgress'    AND SHSS.TXN_PROC_STAT_CD ='Scheduled:Sync'                                             AND SHSS.DBXTRACT_STAT_CD = 'Scheduled:Sync'                                                                                                                                                                         AND (ROUND((SYSDATE - SH.LAST_UPD)*1440,2)) < 5)   OR
                                     (SHSS.SYNC_TYPE_CD = 'DownloadOnly'               AND SHSS.SYNC_STATUS_CD ='DBExtDownloadOK'                                                  AND SHSS.TXN_PROC_STAT_CD ='NoTransaction'                                              AND SHSS.DBXTRACT_STAT_CD = 'Downloaded'                                                                                                                                                                             AND (ROUND((SYSDATE - SH.LAST_UPD)*1440,2)) < 5)   OR
                                     (SHSS.SYNC_TYPE_CD = 'Unknown'                    AND SHSS.SYNC_STATUS_CD ='InitOK'                                                           AND SHSS.TXN_PROC_STAT_CD ='Completed'                                                  AND SHSS.DBXTRACT_STAT_CD = 'Downloaded'                                                                                                                                                                                                                            )   OR
                                     (SHSS.SYNC_TYPE_CD = 'Unknown'                    AND SHSS.SYNC_STATUS_CD ='InitOK'                                                           AND SHSS.TXN_PROC_STAT_CD ='Completed'                                                  AND SHSS.DBXTRACT_STAT_CD = 'Scheduled:Sync'                                                                                                                                                                                                                        )   OR
                                     (SHSS.SYNC_TYPE_CD = 'Unknown'                    AND SHSS.SYNC_STATUS_CD ='TxnRcvFail'         AND SH.SYNC_STATUS_CD = 'TxnRcvFail'          AND SHSS.TXN_PROC_STAT_CD ='Completed'                                                                                                                                                                                                                                                                       AND ROUND((SYSDATE - SH.LAST_UPD)*1440,2)   < 5)   OR
                                     (SHSS.SYNC_TYPE_CD = 'Unknown'                    AND SHSS.SYNC_STATUS_CD ='TxnRcvFail'         AND SH.SYNC_STATUS_CD = 'TxnRcvFail'          AND SHSS.TXN_PROC_STAT_CD ='NoTransaction'                                                                                                                                                                                                                                                                   AND ROUND((SYSDATE - SH.LAST_UPD)*1440,2)   < 5)   OR
                                     (SHSS.SYNC_TYPE_CD = 'Unknown'                    AND SHSS.SYNC_STATUS_CD ='TxnProcInProgress'  AND SH.SYNC_STATUS_CD = 'TxnProcInProgress'   AND SHSS.TXN_PROC_STAT_CD ='Scheduled:Sync'AND SH.TXN_PROC_STAT_CD ='Scheduled:Sync'    AND SHSS.DBXTRACT_STAT_CD = 'Scheduled:Sync'                                                                                                                                                                         AND ROUND((SYSDATE - SH.LAST_UPD)*1440,2)   < 5)
                              THEN    'Sincronizacion en Progreso'
                              WHEN   (                                                     SHSS.SYNC_STATUS_CD = 'TxnProcInProgress'                                                                                                                                                                                                                                                                                                                                                            AND ROUND((SYSDATE - SH.LAST_UPD)*1440,2)   > 15)  OR
                                     (SHSS.SYNC_TYPE_CD = 'Unknown'                    AND SHSS.SYNC_STATUS_CD = 'TxnProcInProgress' AND SH.SYNC_STATUS_CD = 'TxnProcInProgress'   AND SHSS.TXN_PROC_STAT_CD ='Scheduled:Sync'                                             AND SHSS.DBXTRACT_STAT_CD = 'Scheduled:Sync'                                                                                                                                                                         AND ROUND((SYSDATE - SH.LAST_UPD)*1440,2)   > 15)  OR
                                     (SHSS.SYNC_TYPE_CD = 'Unknown'                    AND SHSS.SYNC_STATUS_CD = 'TxnRcvOK'                                                        AND SHSS.TXN_PROC_STAT_CD ='Scheduled:Sync'                                             AND SHSS.DBXTRACT_STAT_CD = 'Scheduled:Sync'                                                                                                                                                                         AND ROUND((SYSDATE - SH.LAST_UPD)*1440,2)   > 10)  OR
                                     (SHSS.SYNC_TYPE_CD = 'UploadOnly'                 AND SHSS.SYNC_STATUS_CD = 'TxnProcInProgress' AND SH.SYNC_STATUS_CD ='TxnProcInProgress'    AND SHSS.TXN_PROC_STAT_CD ='Scheduled:Sync'                                             AND SHSS.DBXTRACT_STAT_CD = 'Scheduled:Sync'                                                                                                                                                                         AND ROUND((SYSDATE - SH.LAST_UPD)*1440,2)   >  5)  OR
                                     (SHSS.SYNC_TYPE_CD = 'UploadOnly'                 AND SHSS.SYNC_STATUS_CD = 'TxnProcInProgress' AND SH.SYNC_STATUS_CD ='TxnProcInProgress'    AND SHSS.TXN_PROC_STAT_CD ='Scheduled:Sync'AND SH.TXN_PROC_STAT_CD ='Scheduled:Sync'    AND SHSS.DBXTRACT_STAT_CD = 'Scheduled:Sync'                                                                                                                                                                         AND ROUND((SYSDATE - SH.LAST_UPD)*1440,2)   >  5)  OR
                                     (SHSS.SYNC_TYPE_CD = 'Unknown'                    AND SHSS.SYNC_STATUS_CD = 'TxnProcInProgress'                                               AND SHSS.TXN_PROC_STAT_CD ='Failed'        AND SH.TXN_PROC_STAT_CD ='TxnProcInProgress' AND SHSS.DBXTRACT_STAT_CD = 'Scheduled:Sync'                                                                                                                                                                         AND ROUND((SYSDATE - SH.LAST_UPD)*1440,2)   >  5)
                              THEN   'Colgado/Posible Halted - Reportar a SysAdmin'
                              WHEN   
                                     (SHSS.SYNC_TYPE_CD = 'FullSync'                   AND SHSS.SYNC_STATUS_CD = 'DBExtOK'         AND SH.SYNC_STATUS_CD ='DBExtOK'                AND SHSS.TXN_PROC_STAT_CD ='Completed'     AND SH.TXN_PROC_STAT_CD ='Completed'            AND SHSS.DBXTRACT_STAT_CD = 'Extracted'                                                                                                                                                                           AND ROUND((SYSDATE - SH.LAST_UPD)*1440,2)   > 10)  OR
                                     (SHSS.SYNC_TYPE_CD = 'FullSync'                   AND SHSS.SYNC_STATUS_CD = 'DBExtDownloadOK' AND SH.SYNC_STATUS_CD ='DBExtDownloadOK'        AND SHSS.TXN_PROC_STAT_CD ='NoTransaction' AND SH.TXN_PROC_STAT_CD ='Completed'            AND SHSS.DBXTRACT_STAT_CD = 'Downloaded'                                                                                                                                                                          AND (ROUND((SYSDATE - SH.LAST_UPD)*1440,2)) > 10 ) OR--
                                     (SHSS.SYNC_TYPE_CD = 'FullSync'                   AND SHSS.SYNC_STATUS_CD ='TxnProcOK'         AND SH.SYNC_STATUS_CD ='TxnProcOK'             AND SHSS.TXN_PROC_STAT_CD ='Completed'      AND SH.TXN_PROC_STAT_CD ='Completed'         AND SHSS.DBXTRACT_STAT_CD = 'NoExtraction'                                                                                                                                                                          AND ROUND((SYSDATE - SH.LAST_UPD)*1440,2)   > 10)  OR
                                     (SHSS.SYNC_TYPE_CD = 'UploadOnly'                 AND SHSS.SYNC_STATUS_CD = 'TxnRcvOK'                                                        AND SHSS.TXN_PROC_STAT_CD ='NoTransaction'                                                                                                                                                                                                                                                                   AND (ROUND((SYSDATE - SH.LAST_UPD)*1440,2)) > 15)OR
                                     (SHSS.SYNC_TYPE_CD = 'Unknown'                    AND SHSS.SYNC_STATUS_CD = 'InitOK'                                                          AND SHSS.TXN_PROC_STAT_CD ='NoTransaction'                                                                                                         AND SH.SYNC_TS = SHSS.LAST_UPD                                                                                                                            AND (ROUND((SYSDATE - SH.LAST_UPD)*1440,2)) > 10) OR
                                     (SHSS.SYNC_TYPE_CD = 'Unknown'                    AND SHSS.SYNC_STATUS_CD = 'InitOK'                                                          AND SHSS.TXN_PROC_STAT_CD ='NoTransaction'                                                 AND SHSS.DBXTRACT_STAT_CD = 'NoExtraction'                                                                                                                                      AND SHSS.TXN_RECEIVED_TS IS NULL  AND (ROUND((SYSDATE - SH.LAST_UPD)*1440,2)) > 5 ) OR--
                                     (SHSS.SYNC_TYPE_CD = 'Unknown'                    AND SHSS.SYNC_STATUS_CD ='TxnProcOK'                                                        AND SHSS.TXN_PROC_STAT_CD ='Completed'                                                     AND SHSS.DBXTRACT_STAT_CD = 'Scheduled:Sync'                                                                                                                                                                      AND (ROUND((SYSDATE - SH.LAST_UPD)*1440,2)) > 2  AND ((ROUND((SYSDATE - SH.LAST_UPD)*1440,2)) < 5 )) OR
                                     (SHSS.SYNC_TYPE_CD = 'DownloadOnly'               AND SHSS.SYNC_STATUS_CD = 'DBExtDownloadOK'                                                 AND SHSS.TXN_PROC_STAT_CD ='NoTransaction'                                                 AND SHSS.DBXTRACT_STAT_CD = 'Downloaded'                                                                                                                                                                          AND (ROUND((SYSDATE - SH.LAST_UPD)*1440,2)) > 2 ) OR--
                                     (SHSS.SYNC_TYPE_CD = 'UploadOnly'                 AND SHSS.SYNC_STATUS_CD = 'TxnProcOK'                                                       AND SHSS.TXN_PROC_STAT_CD ='Completed'                                                     AND SHSS.DBXTRACT_STAT_CD = 'Scheduled:Sync'                                                                                                                                                                      AND (ROUND((SYSDATE - SH.LAST_UPD)*1440,2)) > 10 and ((ROUND((SYSDATE - SH.LAST_UPD)*1440,2)) < 30)) OR
                                     (SHSS.SYNC_TYPE_CD = 'UploadOnly'                 AND SHSS.SYNC_STATUS_CD = 'TxnRcvOK'                                                        AND SHSS.TXN_PROC_STAT_CD ='Scheduled:Sync'                                                AND SHSS.DBXTRACT_STAT_CD = 'Scheduled:Sync'                                                                                                                                                                      AND (ROUND((SYSDATE - SH.LAST_UPD)*1440,2)) > 10) OR
                                     (SHSS.SYNC_TYPE_CD = 'UploadOnly'                 AND SHSS.SYNC_STATUS_CD = 'TxnRcvFail'                                                      AND SHSS.TXN_PROC_STAT_CD ='TxnRcvFail'                                                    AND SHSS.DBXTRACT_STAT_CD = 'NoExtraction'                                                                                                                                                                        AND (ROUND((SYSDATE - SH.LAST_UPD)*1440,2)) > 5 ) OR--
                                     (SHSS.SYNC_TYPE_CD = 'UploadOnly'                 AND SHSS.SYNC_STATUS_CD ='TxnRcvFail'        AND SH.SYNC_STATUS_CD ='TxnRcvFail'           AND SHSS.TXN_PROC_STAT_CD ='NoTransaction' AND SH.TXN_PROC_STAT_CD ='Completed'             AND SHSS.DBXTRACT_STAT_CD='NoExtraction'                                                                                                                                                                          AND (ROUND((SYSDATE - SH.LAST_UPD)*1440,2)) > 5 AND ((ROUND((SYSDATE - SH.LAST_UPD)*1440,2)) < 10))or
                                     (SHSS.SYNC_TYPE_CD = 'Unknown'                    AND SHSS.SYNC_STATUS_CD ='TxnRcvFail'        AND SH.SYNC_STATUS_CD ='TxnRcvFail'           AND SHSS.TXN_PROC_STAT_CD ='NoTransaction' AND SH.TXN_PROC_STAT_CD ='NoTransaction'         AND SHSS.DBXTRACT_STAT_CD='NoExtraction'                                                                                                                                                                          AND (ROUND((SYSDATE - SH.LAST_UPD)*1440,2)) > 10 )                                                                                                               
                              THEN   'Colgado - Reportar a SysAdmin'
                              WHEN   
                                     (SHSS.SYNC_TYPE_CD = 'UploadOnly'                  AND SHSS.SYNC_STATUS_CD ='InitOK'                                                          AND SHSS.TXN_PROC_STAT_CD ='NoTransaction'                                                                                                        AND SH.SYNC_TS = SH.TXN_PROC_CMPLT_TS   AND SH.TXN_PROC_CMPLT_TS = SHSS.CREATED                                                                                                                            ) OR
                                     (SHSS.SYNC_TYPE_CD = 'UploadOnly'                  AND SHSS.SYNC_STATUS_CD ='InitOK'                                                          AND SHSS.TXN_PROC_STAT_CD ='NoTransaction'                                                                                                                                                                                                                                                                   AND ROUND((SYSDATE - SH.LAST_UPD)*1440,2) > 5   ) OR
                                     (SHSS.SYNC_TYPE_CD = 'UploadOnly'                  AND SHSS.SYNC_STATUS_CD ='TxnRcvFail'                                                      AND SHSS.TXN_PROC_STAT_CD ='NoTransaction'                                                 AND SHSS.DBXTRACT_STAT_CD='NoExtraction'               AND SH.SYNC_TS = SHSS.LAST_UPD                                                                                                                                                                             ) OR --
                                     (SHSS.SYNC_TYPE_CD = 'UploadOnly'                 AND SHSS.SYNC_STATUS_CD = 'TxnProcOK'                                                       AND SHSS.TXN_PROC_STAT_CD ='Completed'                                                     AND SHSS.DBXTRACT_STAT_CD = 'Scheduled:Sync'                                                                                                                                                                      AND (ROUND((SYSDATE - SH.LAST_UPD)*1440,2)) > 30) OR
                                     (SHSS.SYNC_TYPE_CD = 'UploadOnly'                  AND SHSS.SYNC_STATUS_CD ='TxnRcvFail'        AND SH.SYNC_STATUS_CD ='TxnRcvFail'           AND SHSS.TXN_PROC_STAT_CD ='NoTransaction' AND SH.TXN_PROC_STAT_CD ='Completed'            AND SHSS.DBXTRACT_STAT_CD='NoExtraction'                                                                                                                                                                          AND (ROUND((SYSDATE - SH.LAST_UPD)*1440,2)) > 10 ) OR                                    
                                     (SHSS.SYNC_TYPE_CD = 'Unknown'                     AND SHSS.SYNC_STATUS_CD = 'DBExtDownloadFail'                                              AND SHSS.TXN_PROC_STAT_CD ='NoTransaction'                                                                                                                                                                                                                                                                   AND ROUND((SYSDATE - SH.LAST_UPD)*1440,2) > 5   )OR
                                     (SHSS.SYNC_TYPE_CD = 'Unknown'                     AND SHSS.SYNC_STATUS_CD = 'TxnRcvOK'                                                       AND SHSS.TXN_PROC_STAT_CD ='NoTransaction'                                                                                                                                                                                                                                                                                                                   )OR
                                     (SHSS.SYNC_TYPE_CD = 'Unknown'                     AND SHSS.SYNC_STATUS_CD = 'InitOK'                                                         AND SHSS.TXN_PROC_STAT_CD ='NoTransaction'                                                                                                        AND SH.SYNC_TS = SHSS.LAST_UPD                                                                                                                                                                             ) OR
                                     (SHSS.SYNC_TYPE_CD = 'Unknown'                                                                  AND SH.SYNC_STATUS_CD   = 'TxnRcvOK'          AND SHSS.TXN_PROC_STAT_CD ='NoTransaction'                                                                                                                                                                                                                                AND SHSS.TXN_RECEIVED_TS IS NULL                                                   ) OR--
                                     (SHSS.SYNC_TYPE_CD = 'Unknown'                     AND SHSS.SYNC_STATUS_CD = 'TxnRcvFail'                                                     AND SHSS.TXN_PROC_STAT_CD ='NoTransaction'                                                                                                        AND SH.SYNC_TS  > SH.TXN_PROC_CMPLT_TS  AND SH.TXN_PROC_CMPLT_TS > SHSS.CREATED                                                                                                                            )OR
                                     (SHSS.SYNC_TYPE_CD = 'Unknown'                     AND SHSS.SYNC_STATUS_CD = 'TxnRcvFail'       AND SH.SYNC_STATUS_CD ='TxnRcvFail'           AND SHSS.TXN_PROC_STAT_CD ='NoTransaction' AND SH.TXN_PROC_STAT_CD ='Completed'            AND SHSS.DBXTRACT_STAT_CD ='NoExtraction'                                                                                                                                                                        AND (ROUND((SYSDATE - SH.LAST_UPD)*1440,2)) > 10) OR --
                                     (SHSS.SYNC_TYPE_CD = 'Unknown'                    AND SHSS.SYNC_STATUS_CD ='TxnProcOK'                                                        AND SHSS.TXN_PROC_STAT_CD ='Completed'                                                     AND SHSS.DBXTRACT_STAT_CD = 'Scheduled:Sync'                                                                                                                                                                      AND (ROUND((SYSDATE - SH.LAST_UPD)*1440,2)) > 5 )                                       
                              THEN   'No esta conectado'               
                              WHEN   (SHSS.SYNC_TYPE_CD = 'FullSync'                    AND SHSS.SYNC_STATUS_CD ='DBExtDownloadOK'   AND SH.SYNC_STATUS_CD ='DBExtDownloadOK'      AND SHSS.TXN_PROC_STAT_CD ='Completed'     AND SH.TXN_PROC_STAT_CD ='Completed'            AND SHSS.DBXTRACT_STAT_CD ='Downloaded'                                                                                                   AND SHSS.TXN_PROC_CMPLT_TS < SYSDATE                                    AND ROUND((SYSDATE - SH.LAST_UPD)*1440,2) > 2   )OR
                                     (SHSS.SYNC_TYPE_CD = 'FullSync'                    AND SHSS.SYNC_STATUS_CD ='DBExtDownloadFail' AND SH.SYNC_STATUS_CD ='DBExtDownloadFail'                                                                                                                                                                                                                                         AND SHSS.TXN_PROC_CMPLT_TS < SYSDATE                                                                                    )OR 
                                     (SHSS.SYNC_TYPE_CD = 'FullSync'                    AND SHSS.SYNC_STATUS_CD ='DBExtDownloadFail' AND SH.SYNC_STATUS_CD ='InitOK'                                                                                                                                                                                                                                                    AND SHSS.TXN_PROC_CMPLT_TS < SYSDATE                                                                                    )OR 
                                     --(SHSS.SYNC_TYPE_CD = 'FullSync'                    AND SHSS.SYNC_STATUS_CD ='TxnProcOK'         AND SH.SYNC_STATUS_CD = 'TxnProcOK'           AND SHSS.TXN_PROC_STAT_CD ='Completed'                                                                                                                                                                                                                                                                                                                       )OR
                                     (SHSS.SYNC_TYPE_CD = 'FullSync'                    AND SHSS.SYNC_STATUS_CD = 'DBExtDownloadOK'  AND SH.SYNC_STATUS_CD ='DBExtDownloadOK'      AND SHSS.TXN_PROC_STAT_CD ='NoTransaction' AND SH.TXN_PROC_STAT_CD ='Completed'            AND SHSS.DBXTRACT_STAT_CD = 'Downloaded'                                                                                                                                                                          AND (ROUND((SYSDATE - SH.LAST_UPD)*1440,2)) < 10 ) OR--                                     
                                     (SHSS.SYNC_TYPE_CD = 'UploadOnly'                  AND SHSS.SYNC_STATUS_CD ='TxnProcOK'                                                       AND SHSS.TXN_PROC_STAT_CD ='Completed'                                                     AND SHSS.DBXTRACT_STAT_CD = 'Scheduled:Sync'                                                                                                                                                                                                                      )OR
                                     (SHSS.SYNC_TYPE_CD = 'UploadDeferredDownload'      AND SHSS.SYNC_STATUS_CD ='DBExtDownloadFail'                                               AND SHSS.TXN_PROC_STAT_CD ='Completed'                                                                                                                                                                                                                                                                                                                       )OR
                                     (SHSS.SYNC_TYPE_CD = 'UploadDeferredDownload'      AND SHSS.SYNC_STATUS_CD ='DBExtDownloadFail'                                               AND SHSS.TXN_PROC_STAT_CD ='NoTransaction'                                                                                                                                                                                                                                                                                                                   )OR
                                     (SHSS.SYNC_TYPE_CD = 'Unknown'                     AND SHSS.SYNC_STATUS_CD ='DBExtDownloadOK'   AND SH.SYNC_STATUS_CD = 'DBExtDownloadOK'     AND SHSS.TXN_PROC_STAT_CD ='NoTransaction'                                                 AND SHSS.DBXTRACT_STAT_CD ='Downloaded'                                                                                                                                                                                                                           )OR
                                     (SHSS.SYNC_TYPE_CD = 'Unknown'                     AND SHSS.SYNC_STATUS_CD ='TxnProcOK'          AND SH.SYNC_STATUS_CD = 'TxnProcOK'          AND SHSS.TXN_PROC_STAT_CD ='Completed'     AND SH.TXN_PROC_STAT_CD ='Completed'            AND SHSS.DBXTRACT_STAT_CD = 'Scheduled:Sync'                                                                                                                                                                         AND ROUND((SYSDATE - SH.LAST_UPD)*1440,2)   < 5)
                              THEN   'Termino OK Validar venta'
                              ELSE   'Indeterminado - Reportar a SysAdmin'
                              END    STATUS_SINC,
                        --SHSS.CREATED, 
                        --SH.TXN_PROC_CMPLT_TS,
                        SH.SYNC_STATUS_CD as stats_cd,
                        SHSS.SYNC_STATUS_CD,
                        --SH.SYNC_TS,
                        SHSS.TXN_PROC_STAT_CD,
                        --SHSS.TXN_RECEIVED_TS,
                        --SH.LAST_UPD AS last_upd3,
                        SHSS.DBXTRACT_STAT_CD,
                        --SH.DB_LAST_UPD AS ULTIMO_MOV,
                        SHSS.LAST_UPD,
                        SH.SYNC_TS HORA_FIN,  
                        SYSDATE,
                        ROUND((SYSDATE - SH.LAST_UPD)*1440,2) TIEMPO_ESPERA
                FROM    SIEBEL.S_HH_SYNC_SUM SH,
                        SIEBEL.S_USER SU,
                        SIEBEL.S_HH_USER SHU,
                        SIEBEL.S_HH_SYNC_SESSN SHSS
                WHERE SU.LOGIN =p_Transaction
                AND SU.ROW_ID = SHU.USER_ID
                AND SHU.ROW_ID =  SH.HH_USER_ID
                AND SH.SYNC_TS >= trunc(SYSDATE) +6/24
                AND SHSS.HH_SYNC_SUM_ID = SH.ROW_ID
                AND SHSS.SYNC_TS >= trunc(SYSDATE) +6/24
                ORDER BY SHSS.SYNC_TS desc  )
            WHERE ROWNUM <= 1;

            Insert into HELPDESK_EVENT_LOG VALUES (
            'EVENT' , p_Row,  'recoverUserInfo', 'HELP_DESK', sysdate, user
            );

        Exception When Others Then
            p_Row := 'No se encontro informacion';
        END;
        commit;
    end recoverUserInfo;

    procedure recoverUserPass (
        p_User in varchar2,
        p_row out varchar2,
        p_code out number
    ) is
 -- i number;
    l_option number;
    i number;
    l_Terr varchar2(1024);
    l_CurentStatus varchar2(1024);
    l_CurentKey varchar2(1024);
    l_CurentValue varchar2(1024);
    l_Equal_Pos number;

    l_inst_Sql varchar2(1024);
    l_Final_Sql varchar2(1024);
    begin
        dbms_output.put_line ('-');
     -- i := 0;

        SELECT to_Char(sysdate) into p_row FROM DUAL;
        SELECT 0 into p_code FROM DUAL;
        DBMS_OUTPUT.PUT_LINE('[' || P_ROW || '] Row');
        begin

            SELECT 
                distinct(nvl(TERR.NAME ,'Not Found') ) into l_Terr
            FROM -- DBA_USERS A,
                S_USER B,
                Siebel.S_INVLOC SINV,
                Siebel.S_POSTN POS ,
                Siebel.S_ASGN_GRP TERR
            WHERE SINV.INV_ASSIGN_TO_ID(+) = B.ROW_ID
                AND SINV.PR_POSTN_ID=POS.ROW_ID(+) 
                AND SINV.PR_POSTN_ID=TERR.PR_POSTN_ID(+) 
                AND B.LOGIN = p_User;-- IN ('U76005329', trim('U00003403'))

            If (l_Terr = 'Not Found') then p_row := -1;
            End if;

            SELECT ltrim(SUBSTR(C.FST_NAME,0,2) ) || ltrim(SUBSTR(C.LAST_NAME,0,2)) || substr(to_char(systimestamp,'ddmmyyyyhh24miss.FF'),16,4) 
                into p_Row
            FROM 
                S_USER B,
                Siebel.S_CONTACT C
            WHERE C.PAR_ROW_ID(+) = B.ROW_ID
                AND B.LOGIN = p_User;
            DBMS_OUTPUT.PUT_LINE('[' || P_ROW || '] Row (end)');

        Exception When Others Then
            p_code := '-1';
            p_Row := USER_WITH_NO_ASIGNED_TERR;
        END;
        commit;
    end recoverUserPass;


    procedure getServerSession (
        p_Transaction in varchar2,
        p_row out varchar2
    ) is
 -- i number;
    l_count number;
    i number;
    l_CurentField varchar2(1024);
    l_CurentStatus varchar2(1024);
    l_CurentKey varchar2(1024);
    l_CurentValue varchar2(1024);
    l_Equal_Pos number;

    l_inst_Sql varchar2(1024);
    l_Final_Sql varchar2(1024);
    CURSOR SyncData IS
        Select ssum.Txn_Proc_Stat_CD ,-- u.login, 
            ssum.Row_Id, ssum.created_By, ssum.Last_Upd, ssum.modification_Num, ssum.conflict_Id, ssum.HH_Comp_Id, ssum.HH_User_Id, ssum.Sync_Node, ssum.Sync_Status_CD, ssum.txn_Received_TS,
            ss.txn_Proc_Stat_CD as TXN_Proc_Session_Stat,
            (sysdate -ssum.Last_Upd )*24*60 as idle_Time_In_Minutes 
             -- ss.* --DB_LAST_UPD 
        From Siebel.S_HH_SYNC_SUM ssum
                    join Siebel.S_HH_SYNC_Sessn ss on ssum.Row_Id = ss.hh_Sync_Sum_Id
                    join SIEBEL.S_HH_User hhu on HHU.Row_ID= ssum.HH_User_Id
                    join Siebel.S_User u on u.Row_Id = HHU.USER_ID
        Where ss.created is not null-- ss. txn_Received_TS is not null
                And trunc (ss.created ) = trunc (sysdate) 
             -- And trunc (ss.txn_Received_TS ) = trunc (sysdate)
                And u.login = p_Transaction --'U76000661'
                order by ss. txn_Received_TS desc;
        CURSOR SessionData IS select sysdate from dual; 
        --Select v.* From SYS.V$Session v Where schemaName = p_Transaction;
    begin
        dbms_output.put_line ('-');
     -- i := 0;
        p_row := 0;

        SELECT to_Char(sysdate) into p_row FROM DUAL;
        DBMS_OUTPUT.PUT_LINE('[' || P_ROW || '] Row');
        begin

            Select count(0) into l_count
            From Siebel.S_HH_SYNC_SUM ssum
            join Siebel.S_HH_SYNC_Sessn ss on ssum.Row_Id = ss.hh_Sync_Sum_Id
            join SIEBEL.S_HH_User hhu on HHU.Row_ID= ssum.HH_User_Id
            join Siebel.S_User u on u.Row_Id = HHU.USER_ID
            -- join Siebel.S_HH_DBEXT_INFO inf on INF.HH_SYNC_SESSION_ID = SS.ROW_ID
            Where ss. txn_Received_TS is not null 
            And trunc (ss.txn_Received_TS ) = trunc (sysdate) 
            And u.login = p_Transaction ;

            IF l_count = 0 Then
                Select INACTIVE_USER_TEXT into p_row From dual;
            End If;

            FOR SyncRow IN SyncData LOOP
                p_Row := SyncRow.TXN_Proc_Session_Stat; --Txn_Proc_Stat_CD
                If SyncRow.Sync_Status_CD= TXN_PROCESS_FAIL_TEXT-- TxnRcvFail
                Then p_Row := HANGED_USER_TEXT ; 
                End If;                  
                dbms_output.put_Line ('ok '|| p_Row);              
                If (p_Row = NOTRANSACTION_TEXT and SyncRow.idle_Time_In_Minutes < max_Delay_In_Minutes_Allowed) Then
                    p_Row :=DONOT_INFORM_V3SYSADMIN_TEXT;
                End If;


            END LOOP;

            p_Row := translate_STATUS(p_Row);
        Exception When Others Then
            p_Row := '-1';
        END;

        commit;
    end getServerSession;


    procedure getInternalOrder (
        p_Transaction in varchar2,
        p_Row out cursorType
    ) is
 -- i number;
    l_count number;
    i number;
    l_CurentField varchar2(1024);
    l_CurentStatus varchar2(1024);
    l_CurentKey varchar2(1024);
    l_CurentValue varchar2(1024);
    l_Equal_Pos number;

    l_inst_Sql varchar2(1024);
    l_Final_Sql varchar2(1024);
        CURSOR SessionData IS select sysdate from dual; 
        --Select v.* From SYS.V$Session v Where schemaName = p_Transaction;
    begin
        dbms_output.put_line ('-');
     -- i := 0;

        DBMS_OUTPUT.PUT_LINE('[' || 0 || '] Row');
        begin

            open p_Row For
            SELECT   /*+parallel (txn,10)*/
                SUBSTR( Txn.Comments, 8, (INSTR( Txn.Comments, ',' )) - 8 ) as Referencia,
                Txn.Qty                              AS Qty_Txn    ,
                Txn.Txn_dt                           AS DocDate    ,
                Prod.Part_Num                        AS SKU        ,
                Prod.UOM_CD                          AS Unidad_Medida,
                Txn.Comments ,
                CASE
                    WHEN Dest.Name = 'External Location' THEN Src.Name
                    WHEN Src.Name  = 'External Location' THEN Dest.Name
                    ELSE 'CheckTransaction'
                    END                                  AS VanName    ,
                CASE
                    WHEN Dest.Name = 'External Location' THEN 'Pick-Up'
                    WHEN Src.Name  = 'External Location' THEN 'Fill-Up'
                    ELSE 'CheckTransaction'
                    END                                  AS OrderType,
                Txn.Txn_dt, Txn.Created
                FROM Siebel.S_Inv_Txn@v03    Txn ,
                    Siebel.S_Prod_Int@v03   Prod,
                    Siebel.S_InvLoc@v03     Dest,
                    Siebel.S_InvLoc@v03     Src
                WHERE Txn.Txn_dt             > (select trunc(order_dt) from siebel.s_order@v03 where order_num = p_Transaction)
                    and Txn.Txn_dt             < (select trunc(order_dt)+2 from siebel.s_order@v03 where order_num = p_Transaction)
                    AND Txn.Created_By         = '1-80QF'
                    AND Txn.Commit_Flg         = 'Y'
                    AND Txn.Phys_Prod_ID       = Prod.Row_ID
                    AND Txn.Phys_Dest_InvLc_ID = Dest.Row_ID(+)
                    AND Txn.Phys_Src_InvLoc_ID = Src.Row_ID(+)
                    AND Txn.Comments LIKE 'Order#:I20150920:000676%';
        Exception When Others Then
            open p_Row for Select 'Error' from dual;
        END;

        commit;
    end getInternalOrder;


    FUNCTION GET_CE_DOCTO ( P_ROW_ID IN VARCHAR2 )
    RETURN NUMBER IS

    sRow_ID          VARCHAR2(20) ;
    dtFechaDoc       DATE         ;
    dtFechaVenc      DATE         ;
    nCondPago        NUMBER(2)    ;
    nDiasCE          NUMBER(2)    ;
    sDoc_Num         VARCHAR2(50) ;
    sOrder_Num       VARCHAR2(50) ;
    sCEFact          VARCHAR2(50) ;
    sCEPed           VARCHAR2(50) ;
    dtFechaIni       DATE         ;
    dtFechaFin       DATE         ;
    l_Dias NUMBER(2) ;
    BEGIN
    l_Dias := 0 ;
 -- DBMS_OUTPUT.PUT_LINE('[' || P_ROW_ID || '] Row');
    SELECT 0 into l_Dias from dual;

--
    RETURN l_Dias ;
    END ;

end; -- end of package body
/