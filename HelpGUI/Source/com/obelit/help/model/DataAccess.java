package com.obelit.help.model;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Types;
import java.util.logging.Logger;

import com.pool.SimpleConnection;

public class DataAccess {
	public final static String RECOVER_USER_INFO= "{call HELP_DESK.RECOVERUSERINFO(?,?)}";
	public final static String GET_SERVER_VERSSION= "{call HELP_DESK.getServerSession(?,?)}";

	Connection con;

	final static String DB_URL = "jdbc:oracle:thin:V3_SYSADMIN/TEST_A@z1t1brpapld17.BR.BATGEN.COM:1521/z1orp25p"; //"jdbc:oracle:thin:ROSALESE/AKIRE2000@z1t1brpapld17.BR.BATGEN.COM:1521:z1orp25p"; // "jdbc:oracle:thin:SIEBELETL/BAHIA_BLANCA$36@z1t1brpapld17.BR.BATGEN.COM:1521:z1orp25p"
	Logger log= Logger.getLogger(DataAccess.class.getName());
	public DataAccess (Connection conn) {
    	SimpleConnection me;
    	if (conn == null) {
        	me = new SimpleConnection(".", DB_URL);
        	con= me.getConnection();
    	} else {
    		con= conn;
    	}
	}

	public DataAccess () {
		this(null);
	}

	public void bye () {
		if (con == null) {
			log.info("null connection");
		} else {
			try {con.close();} catch (SQLException e) {e.printStackTrace();}
			log.info("clo(sed) connection");
		}		
	}

	public void alterUSer() {
		CallableStatement theStatement ;

		try {
	        theStatement = con.prepareCall("call SIEBELETL.HELP_DESK.alterUser(?,?)");

	     // Passing an array to the procedure -
	        theStatement.setString(1, "x");
	        theStatement.registerOutParameter(2, Types.VARCHAR);
	     // theStatement.registerOutParameter(3,OracleTypes.ARRAY,"");
	        theStatement.execute();
	        log.info("- " + theStatement.getString(2) + " incomming from in the array");

		} catch (SQLException e) {
		 // TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	public String recoverUserInfo(String u) {
		CallableStatement theStatement ;
		String r= "";

		try {
	        theStatement = con.prepareCall(RECOVER_USER_INFO);// (GET_SERVER_VERSSION)

	     // Passing an array to the procedure -
	        theStatement.setString(1, u);
	        theStatement.registerOutParameter(2, Types.VARCHAR);
	     // theStatement.registerOutParameter(3,OracleTypes.ARRAY,"");
	        theStatement.execute();
	        r = theStatement.getString(2);
	        log.info("- " + r + " incomming from in the array");
	        theStatement.close();

		} catch (SQLException e) {
		 // TODO Auto-generated catch block
			e.printStackTrace();
		}
		return r;
	}

	public String createUserPass(String u) {
		CallableStatement theStatement ;
		String r= "";
		int code= 0;

		try {
	        theStatement = con.prepareCall("{call HELP_DESK.RECOVERUSERPASS(?,?,?)}");

	     // Passing an array to the procedure -
	        theStatement.setString(1, u);
	        theStatement.registerOutParameter(2, Types.VARCHAR);
	        theStatement.registerOutParameter(3, Types.NUMERIC);

	        theStatement.execute();
	        r = theStatement.getString(2);
	        code = theStatement.getInt(3);
	        log.info("- " + r + " incomming from in the array");
	        theStatement.close();

		} catch (SQLException e) {
		 // TODO Auto-generated catch block
			e.printStackTrace();
		}

        if (code == 0) {
        	log.info("-" + code);	
        } else {
        	r= "Error. " + r;
        }

		return r;
	}

}
