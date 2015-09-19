CREATE OR REPLACE PACKAGE SIEBELETL.HELP_DESK is
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

    procedure alterUser (
        p_Transaction in varchar2,
        p_row out varchar2
    );

    procedure recoverUserInfo (
        p_Transaction in varchar2,
        p_row out varchar2
    );

    procedure recoverUserPass (
        p_User in varchar2,
        p_row out varchar2
    );

    FUNCTION GET_CE_DOCTO  ( P_ROW_ID IN VARCHAR2 )
    RETURN  NUMBER ;
END;
/