CREATE OR REPLACE PACKAGE BODY SIEBELETL.HELP_DESK
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

    procedure getThingsToWork (
        p_option in number ,
        p_value out cursorType,
        p_row out number
    ) is
    i number;
    begin
        dbms_output.put_line ('-');
        p_row := 0;
        Select Count (1) into p_row
            From ALA_Catalog a
            Where a.status = 'Y';

        open p_value for

            Select a.Formal_Name, a.Stored_Procedure_Name, a.JS_Function_Content ,
                a.search_patern , a.Position_Order
            From ALA_Catalog a
            Where a.status = 'Y';
        begin
            DBMS_OUTPUT.put_line (p_row);
        Exception When Others Then
            p_Row := 1;
        END;
    end getThingsToWork;


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
        l_Row_Id := ALA_Invoice_SEQ.nextval;
        begin
            FOR i IN 1 .. p_option.COUNT
            LOOP
                Begin
                    p_row := p_row+ 1;
                    l_inst_Sql := 'Update ALA_Order set [1] = [2] Where Transaction_Id = [3]';-- ' ';
                    l_CurentField :=p_option (i);
                    DBMS_OUTPUT.put_line (l_Row_Id || ' . [orignal] ' || l_CurentField );
                    Insert Into ALA_EXCEPTION_LOG values (
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
                    Insert Into ALA_EXCEPTION_LOG values (
                            p_row || '.b', l_CurentField|| ' :' || l_CurentKey || ' = ' || l_CurentValue || '..'  ,'processOrder', 'Debug', sysdate, user
                    );

                    DBMS_OUTPUT.put_line (l_CurentKey || ' = ' || l_CurentValue || ' Where Transaction_Id = ' || l_Transaction_Id );
                 --
                 -- Verify if we got that document aleady.
                    Select count(1) into l_Inserted_Already From ALA_Order inv
                    Where Transaction_Id= p_Transaction;-- inv.Invoice_Num = l_CurentValue

                    If l_Inserted_Already = 0 Then -- First Element basically ignored.
                        Insert Into ALA_EXCEPTION_LOG values (
                            p_row || '.c', p_Transaction || ': ..'  ,'processOrder', 'Debug', sysdate, user
                        );
                        Insert Into ALA_Order (Row_Id, Transaction_Id, User_Login)
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
                        Insert Into ALA_EXCEPTION_LOG values (
                            p_row || '.d', l_Final_Sql, 'processOrder', 'Debug', sysdate, user
                        );
                    Else
                        Execute immediate l_Final_Sql;
                    End If;
                 -- Update ALA_Invoice set Transaction_Date = sysdate Where Transaction_Id = l_Transaction_Id;
                    Update ALA_Order set LAST_UPD_DATE = sysdate Where Transaction_Id = p_Transaction;
                 -- p_row := p_row +1;
                Exception When Others Then
                    Insert Into ALA_EXCEPTION_LOG values (
                        'x', l_Final_Sql ,'processOrder', 'Faliure', sysdate, user
                    );
                End;
            END LOOP;
        Exception When Others Then
            p_Row := -1;
        END;
        commit;
    end processOrder;

    procedure alterUser (
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

        begin
            SELECT to_Char(sysdate) into p_row FROM DUAL;

        Exception When Others Then
            p_Row := '-1';
        END;
        commit;
    end alterUser;

    procedure recoverUserInfo (
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
            select STATUS_SINC into p_row from (
            SELECT SHSS.SYNC_TYPE_CD AS TIPO_SINC,SHSS.created, 
            sh.txn_proc_cmplt_ts,
            SHSS.SYNC_STATUS_CD,
            SH.SYNC_TS,
            SHSS.TXN_PROC_STAT_CD,
            SHSS.txn_received_ts,
            SH.LAST_UPD as last_upd3,
            CASE 
             WHEN (SHSS.SYNC_STATUS_CD = 'TxnProcInProgress' and ROUND((SYSDATE - SH.LAST_UPD)*1440,2) < 15)OR
                  (SHSS.SYNC_TYPE_CD = 'FullSync' AND SHSS.SYNC_STATUS_CD ='TxnProcOK')OR
                  (SHSS.SYNC_TYPE_CD = 'FullSync' AND SHSS.SYNC_STATUS_CD ='DBExtOK')OR
                  (SHSS.SYNC_TYPE_CD = 'FullSync' AND SHSS.SYNC_STATUS_CD ='InitOK'AND SHSS.TXN_PROC_STAT_CD ='NoTransaction')OR
                  (SHSS.SYNC_TYPE_CD = 'UploadOnly' AND SHSS.SYNC_STATUS_CD ='TxnRcvFail'AND ROUND((SYSDATE - SH.LAST_UPD)*1440,2) < 15)OR
                  (SHSS.SYNC_TYPE_CD = 'Unknown' AND SHSS.SYNC_STATUS_CD = 'InitOK' AND SHSS.TXN_PROC_STAT_CD ='NoTransaction' AND SHSS.txn_proc_cmplt_ts = SHSS.CREATED AND ROUND((SYSDATE - SH.LAST_UPD)*1440,2) < 8 AND SHSS.txn_received_ts IS NULL )
             THEN 'En Progreso'
             WHEN SHSS.SYNC_STATUS_CD = 'TxnProcInProgress' and ROUND((SYSDATE - SH.LAST_UPD)*1440,2) > 15
             THEN 'COLGADO/POSIBLE HALTED'   
             WHEN (SHSS.SYNC_STATUS_CD ='TxnRcvOK' and (ROUND((SYSDATE - SH.LAST_UPD)*1440,2)) > 15)OR
                  (SHSS.SYNC_TYPE_CD = 'UploadOnly' AND SHSS.SYNC_STATUS_CD ='TxnRcvOK' and (ROUND((SYSDATE - SH.LAST_UPD)*1440,2)) > 10 and SHSS.TXN_PROC_STAT_CD ='NoTransaction' )OR
                  (SHSS.SYNC_STATUS_CD ='TxnRcvFail' and SH.txn_proc_cmplt_ts = SHSS.created and (ROUND((SYSDATE - SH.LAST_UPD)*1440,2)) > 10)or
                  (SHSS.SYNC_TYPE_CD = 'Unknown' AND SHSS.SYNC_STATUS_CD = 'TxnRcvFail' AND SHSS.TXN_PROC_STAT_CD ='NoTransaction' AND TO_DATE(SHSS.txn_proc_cmplt_ts,'DD/MM/YYYY HH24:MI') = TO_DATE(SHSS.CREATED,'DD/MM/YYYY HH24:MI'))or
                  (SHSS.SYNC_TYPE_CD = 'Unknown' AND SHSS.SYNC_STATUS_CD = 'InitOK' AND SHSS.TXN_PROC_STAT_CD ='NoTransaction' AND ROUND((SYSDATE - SH.LAST_UPD)*1440,2) > 10 AND SHSS.txn_received_ts IS NULL)--checar esta linea
             THEN 'COLGADO'
              WHEN (SHSS.SYNC_TYPE_CD = 'UploadOnly' AND SHSS.SYNC_STATUS_CD ='InitOK' AND SHSS.TXN_PROC_STAT_CD ='NoTransaction' and SH.SYNC_TS = sh.txn_proc_cmplt_ts and SH.txn_proc_cmplt_ts = SHSS.created) OR
                   (SHSS.SYNC_TYPE_CD = 'Unknown' AND SHSS.SYNC_STATUS_CD = 'DBExtDownloadFail' AND SHSS.TXN_PROC_STAT_CD ='NoTransaction')OR
                   (SHSS.SYNC_TYPE_CD = 'Unknown' AND SHSS.SYNC_STATUS_CD = 'TxnRcvOK' AND SHSS.TXN_PROC_STAT_CD ='NoTransaction')OR
                   (SHSS.SYNC_TYPE_CD = 'Unknown' AND SHSS.SYNC_STATUS_CD = 'InitOK' AND SHSS.TXN_PROC_STAT_CD ='NoTransaction' AND SHSS.txn_received_ts IS NULL )or
                   (SHSS.SYNC_TYPE_CD = 'Unknown' AND SHSS.SYNC_STATUS_CD = 'InitOK' AND SHSS.TXN_PROC_STAT_CD ='NoTransaction' and SH.SYNC_TS = SHSS.LAST_UPD)or
                   (SHSS.SYNC_STATUS_CD ='TxnRcvFail' and SHSS.TXN_PROC_STAT_CD ='NoTransaction' and SH.SYNC_TS != sh.txn_proc_cmplt_ts and SH.txn_proc_cmplt_ts != SHSS.created)
             THEN 'NO ESTA CONECTADO'                 
              WHEN (SHSS.SYNC_TYPE_CD = 'FullSync' AND SHSS.SYNC_STATUS_CD ='DBExtDownloadOK'AND SHSS.txn_proc_cmplt_ts < SYSDATE)OR
                   (SHSS.SYNC_TYPE_CD = 'UploadOnly' AND SHSS.SYNC_STATUS_CD ='TxnProcOK')OR
                   (SHSS.SYNC_TYPE_CD = 'Unknown' AND SHSS.SYNC_STATUS_CD ='TxnProcOK' AND SHSS.TXN_PROC_STAT_CD ='Completed' AND SHSS.txn_received_ts < SYSDATE)OR
                   (SHSS.SYNC_TYPE_CD = 'UploadDeferredDownload' AND SHSS.SYNC_STATUS_CD ='DBExtDownloadFail' AND SHSS.TXN_PROC_STAT_CD ='Completed')OR
                   (SHSS.SYNC_TYPE_CD = 'UploadDeferredDownload' AND SHSS.SYNC_STATUS_CD ='DBExtDownloadFail' AND SHSS.TXN_PROC_STAT_CD ='NoTransaction') 
             THEN 'TERMINÓ OK'
             end STATUS_SINC, 
            SYSDATE , 
            SH.DB_LAST_UPD AS ULTIMO_MOV,
            SHSS.LAST_UPD,
            SH.SYNC_TS HORA_FIN,  
            ROUND((SYSDATE - SH.LAST_UPD)*1440,2) TIEMPO_ESPERA
            FROM 
            SIEBEL.S_HH_SYNC_SUM SH,
            SIEBEL.S_USER SU,
            SIEBEL.S_HH_USER SHU,
            SIEBEL.S_HH_SYNC_SESSN SHSS
            WHERE SU.LOGIN = p_Transaction -- 'U76005895'
                AND SU.ROW_ID = SHU.USER_ID
                AND SHU.ROW_ID =  SH.HH_USER_ID
                AND SH.SYNC_TS >= trunc(SYSDATE) +6/24
                AND SHSS.HH_SYNC_SUM_ID = SH.ROW_ID
                AND SHSS.SYNC_TS >= trunc(SYSDATE) +6/24
            order by SHSS.SYNC_TS desc
            )
            where rownum <2;
        Exception When Others Then
            p_Row := '-1';
        END;
        commit;
    end recoverUserInfo;

    procedure recoverUserPass (
        p_User in varchar2,
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

        SELECT to_Char(sysdate) into p_row FROM DUAL;
        DBMS_OUTPUT.PUT_LINE('[' || P_ROW || '] Row');
        begin
            SELECT to_Char(sysdate) into p_row -- A.ACCOUNT_STATUS, A.USERNAME USUARIO,
             -- CASE WHEN TERR.NAME = NULL THEN 'NO DESBLOQUEAR, EL USUARIO HA SIDO DADO DE BAJA O CAMBIADO'
             -- ELSE ''||SUBSTR(C.FST_NAME,0,2)||SUBSTR(C.LAST_NAME,0,2)||substr(to_char(systimestamp,'ddmmyyyyhh24miss.FF'),16,4)||''
             -- END CAMBIO_PASS
            FROM dual;-- DBA_USERS A,S_USER B,S_CONTACT C,S_INVLOC SINV,S_POSTN POS ,S_ASGN_GRP TERR
             -- WHERE B.LOGIN(+) = A.USERNAME AND C.PAR_ROW_ID(+) = B.ROW_ID AND A.USERNAME = B.LOGIN(+) AND SINV.INV_ASSIGN_TO_ID(+) = B.ROW_ID
             -- AND SINV.PR_POSTN_ID=POS.ROW_ID(+) AND SINV.PR_POSTN_ID=TERR.PR_POSTN_ID(+) 
             -- AND A.USERNAME = p_User-- IN ('U76005329', trim('U00003403'))
        Exception When Others Then
            p_Row := '-1';
        END;
        commit;
    end recoverUserPass;

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