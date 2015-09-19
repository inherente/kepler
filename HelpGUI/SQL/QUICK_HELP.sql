CREATE OR REPLACE PACKAGE QUICK_HELP is
    type cursorType is ref cursor;
  /* TODO enter package declarations (types, exceptions, methods etc) here */

    function GET_OUT_MOVEMENT_BY_VAN (
        p_inicial in varchar2 ,
        p_final in varchar2 ,
        p_option in varchar2 
    ) return cursorType;

    procedure FIND_ANY_EXCEPTION (
        p_option in exception_catalog.common_name%type ,
        p_value out cursorType,
        p_row out number
    );

END;
/


CREATE OR REPLACE package body QUICK_HELP
is

    function GET_OUT_MOVEMENT_BY_VAN (
        p_inicial in varchar2 ,
        p_final in varchar2 ,
        p_option in varchar2 
    ) return cursorType
    is p_value cursorType;
    p_nada number;
    begin
        open p_value for
        SELECT SAM.ACTIVITY_ID, SAM.ROW_ID, SAM.CREATED, SAM.COMMIT_TXNS_FLG,
            SAM.X_COMMITTED_DATE, SAM.SOURCE_CD, SAM.PART_STATUS_CD, SP.NAME,
            SP.PART_NUM, SAM.QTY
        FROM SIEBEL.S_EVT_ACT SE, 
            SIEBEL.S_ACTPART_MVMT SAM,
            siebel.s_prod_int sp,
            siebel.s_invloc van
        WHERE SE.CREATED >= to_date(p_inicial,'dd/mm/yyyy') and SE.CREATED < to_date(p_final,'dd/mm/yyyy')
            AND SE.ROW_ID = SAM.ACTIVITY_ID
            AND SAM.SOURCE_CD = 'Jaula o Almacén'
            AND van.name = p_option
            AND SAM.TRUNK_INVLOC_ID = VAN.ROW_ID
            AND SAM.PRDINT_ID = SP.ROW_ID ;
        return p_value;
    end;

 --
 -- This procedure will execute the differente routines defined to find
 -- exceptions and will publish all of them into a System Table.
    procedure FIND_ANY_EXCEPTION (
        p_option in exception_catalog.common_name%type,
        p_value out cursorType,
        p_row out number
    ) is
    l_value cursorType;
    l_option number;
    l_output varchar2(1024);
    l_common_name varchar2(1024);
    l_function_name varchar2(1024);
    l_Cte_Name varchar2(1024);
    l_Cte_Credit_Days number(2);
    l_Cte_Loc varchar2(1024);
    l_Created date;
    l_Invc_Num varchar2(1024);
    l_Inv_Sub_Type_cd varchar2(1024);
    l_Due_dt date ;
    l_Credit_Limit number(8,2);
    l_Invc_amt number(8,2);
    l_Territory varchar2(1024);
    l_Sales_Rep_Name varchar2(1024);
    l_Avail_Credit_amt number(8,2);
    l_Manager_Name varchar2(1024);
    l_Boss_Name varchar2(1024);
    l_Region varchar2(1024);
    l_Rep_Nomina varchar2(1024);
    l_Position_Rep_Name varchar2(1024);
    begin
        select count(1) into p_row from exception_catalog mm;
        p_value := GET_EXCEPTION_CATALOG(null);
        delete from exception_to_Publish;

        LOOP
        FETCH p_value
        INTO l_common_name, l_function_name;
        EXIT WHEN p_value%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE(l_common_name || ' | ' || l_function_name );
            execute immediate 'begin :this := ' || l_function_name || '; end;'
            using in out l_value;
         -- open l_value;
            loop
            fetch l_value
            into l_Cte_Name, l_Avail_Credit_amt, l_Cte_Credit_Days, l_Cte_Loc,
                l_Created, l_Invc_Num, l_Inv_Sub_Type_cd, l_Due_Dt ,
                l_Credit_Limit, l_Invc_amt, l_Territory, l_Sales_Rep_Name,
                l_Manager_Name, l_Region, l_Position_Rep_Name, l_Rep_Nomina;
         -- if l_value%FOUND then
            exit when (l_value%NOTFOUND) or (l_value%rowcount > 9) ;
                begin
                    insert into exception_to_Publish (
                        common_Name, cte_Name, Avail_Credit_amt, Credit_Days,
                        Cte_Loc, Inv_Created, Inv_Num, Inv_Amount,
                        Inv_Sub_Type_Cd, Due_Dt, credit_Limit, Territory,
                        Sales_Rep_Roster, Sales_Rep_Name, Manager_Name, Region,
                        last_Update_Date, last_modification_by
                    ) values (
                        l_common_name, l_Cte_Name, l_Avail_Credit_amt,
                        l_Cte_Credit_Days, l_Cte_Loc, l_Created, l_Invc_Num,
                        l_Invc_amt, l_Inv_Sub_Type_cd, l_Due_dt, l_Credit_Limit,
                        l_Territory, l_Rep_Nomina ,
                        l_Sales_Rep_Name , l_Manager_Name, l_Region,
                        sysdate, user
                    );
                    DBMS_OUTPUT.PUT_LINE(l_Cte_Name || ' | ' || l_Invc_Num || ' | ' || l_Inv_Sub_Type_cd );
                end;
            end loop;
            DBMS_OUTPUT.PUT_LINE('cnotinue after loop (done)');
            if l_value%isopen then
                        close l_Value;
                        DBMS_OUTPUT.PUT_LINE('Ref Cursor Closed .');
            end if;
        END LOOP;
        commit;
        DBMS_OUTPUT.PUT_LINE('commita done');
    end FIND_ANY_EXCEPTION;

end; -- end of package body
/
