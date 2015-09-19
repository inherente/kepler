CREATE OR REPLACE PACKAGE HELP_DESK is
    type cursorType is ref cursor;

    days_To_Consider CONSTANT number := 30;
    maxExc_To_Consider CONSTANT number := 10000;
    centro CONSTANT varchar2(1024) := 'MX7B';
  /* TODO enter package declarations (types, exceptions, methods etc) here */

    function GET_ANYTHING RETURN VARCHAR2;

    procedure getThingsToWork (
        p_option in number ,
        p_value out cursorType,
        p_row out number
    );

    procedure process (
        p_option in arrayTable ,
        p_row out number
    );

    procedure processOrder (
        p_Transaction in varchar2,
        p_option in arrayTable ,
        p_row out number
    );

    FUNCTION GET_CE_DOCTO  ( P_ROW_ID IN VARCHAR2 )
    RETURN  NUMBER ;
END;
/


CREATE OR REPLACE package body HELP_DESK 
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

    procedure processOrden (
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
    l_inst_Sql varchar2(1024);
    l_Final_Sql varchar2(1024);
    begin
        dbms_output.put_line ('-');
     -- i := 0; 
        p_row := 0;
        l_inst_Sql := 'Update ALA_Order set :1 = :2 Where Transaction_Id = :3';-- ' ';
        l_Transaction_Id := ALA_Order_SEQ.nextval;
        begin
            FOR i IN 1 .. p_option.COUNT
            LOOP
                Begin
                    l_CurentField :=p_option (i);
                    DBMS_OUTPUT.put_line (l_Transaction_Id || ' . ' || l_CurentField );
                    If i = 1 Then
                        Insert Into ALA_Order (Transaction_Id, User_Login) 
                        Values (
                            l_Transaction_Id, user
                        );
                        commit;
                    End If;
                    Select INSTR(l_CurentField, '=', 1, 1) into l_Equal_Pos From dual;
                    Select Substr (l_CurentField, 0, l_Equal_Pos - 1 ) Into l_CurentKey From dual;
                    Select Substr (l_CurentField, l_Equal_Pos +1, length(l_CurentField ) - l_Equal_Pos) Into l_CurentValue From dual;
                    DBMS_OUTPUT.put_line (l_CurentKey || ' = ' || l_CurentValue || ' Where Transaction_Id = ' || l_Transaction_Id );
                    l_Final_Sql := REPLACE(REPLACE(REPLACE(l_inst_Sql ,':3', l_Transaction_Id ) ,':2',  chr (39)|| l_CurentValue ||  chr (39)) ,':1',  l_CurentKey);
                    DBMS_OUTPUT.put_line (' . ' || l_Final_Sql );
                 -- Execute immediate l_inst_Sql using l_CurentKey, l_CurentValue, l_Transaction_Id;
                    Execute immediate l_Final_Sql;
                    Update ALA_Order set Transaction_Date = sysdate Where Transaction_Id = l_Transaction_Id;
                    p_row := p_row +1;
                Exception When Others Then
                    Insert Into ALA_EXCEPTION_LOG values (
                        '', l_Final_Sql ,'processOrder', 'Faliure', sysdate, user
                    );
                End;
            END LOOP;
        Exception When Others Then
            p_Row := -1;
        END;
        commit;
    end processOrden;

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
