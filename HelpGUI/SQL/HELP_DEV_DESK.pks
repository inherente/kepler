CREATE OR REPLACE PACKAGE V3_SYSADMIN.HELP_DEV_DESK is
    type cursorType is ref cursor;

    days_To_Consider CONSTANT number := 30;
    maxExc_To_Consider CONSTANT number := 10000;
    max_Delay_In_Minutes_Allowed CONSTANT number := 10;
    centro CONSTANT varchar2(1024) := 'MX7B';
    USER_WITH_NO_ASIGNED_TERR CONSTANT varchar2(1024) := 'Sin Territorio Asignado';
    INACTIVE_USER_TEXT CONSTANT varchar2(1024) := 'Sin conexion (No es necesario Reportarlo a V3-SystAdm)';
    INFORM_TO_V3SYSADMIN_TEXT CONSTANT varchar2(1024) := 'Not Ok (Reportarlo a V3-SystAdm)';
    DONOT_INFORM_V3SYSADMIN_TEXT CONSTANT varchar2(1024) := 'Ok. (No es necesario reportarlo a V3-SystAdm)';
    
    HANGED_USER_TEXT CONSTANT varchar2(1024) := 'Hanged (Reportar a V3 SystAdm)';
    TXN_PROCESS_OK_TEXT CONSTANT varchar2(1024) := 'TxnProcOK';
    TXN_PROCESS_FAIL_TEXT CONSTANT varchar2(1024) := 'TxnRcvFail';
    NOTRANSACTION_TEXT CONSTANT varchar2(1024) := 'NoTransaction ';
    COMPLETED_TEXT CONSTANT varchar2(1024) := 'Completed';
    SCHEDULED_SYNC_TEXT CONSTANT varchar2(1024) := 'Scheduled:Sync';
    
  /* TODO enter package declarations (types, exceptions, methods etc) here */

    function GET_ANYTHING RETURN VARCHAR2;

    function GET_ACCOUNT_STATUS(p_name varchar2) RETURN VARCHAR2;
    function translate_STATUS(p_name varchar2) RETURN VARCHAR2;

    procedure getThingsToWork (
        p_option in number ,
        p_value out cursorType,
        p_row out number
    );
    procedure log_Event (
        p_option in varchar2 ,
        p_value in varchar2,
        p_UserName in varchar2
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

    procedure KillSession (
        p_Transaction in varchar2,
        p_row out varchar2
    );

    procedure alterUser (
        p_Transaction in varchar2,
        p_Pass in varchar2,
        p_row out varchar2
    );

    procedure RECOVERUSERINFO (
        p_Transaction in varchar2,
        p_row out varchar2
    );

    procedure recoverUserPass (
        p_User in varchar2,
        p_row out varchar2,
        p_code out number
    );


    procedure getServerSession (
        p_Transaction in varchar2,
        p_row out varchar2
    );

    procedure getInternalOrder (
        p_Transaction in varchar2,
        p_row out cursorType
    );

    FUNCTION GET_CE_DOCTO  ( P_ROW_ID IN VARCHAR2 )
    RETURN  NUMBER ;
END;
/