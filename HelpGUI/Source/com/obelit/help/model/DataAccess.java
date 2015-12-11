package com.obelit.help.model;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Types;
import java.util.logging.Logger;

import oracle.jdbc.OracleTypes;

import com.obelit.help.bean.Report;
import com.pool.SimpleConnection;

public class DataAccess {
	public final static String RECOVER_USER_INFO= "{call HELP_DESK.RECOVERUSERINFO(?,?)}";
	public final static String RECOVER_INTERNAL_ORDER= "{call HELP_DESK.getInternalOrder(?,?,?)}";
	public final static String GET_ALL_FUNCTION= "{call HELP_DESK.getFunctionCatalog(?,?,?)}";
	public final static String GET_SERVER_VERSSION= "{call HELP_DESK.getServerSession(?,?)}";
	public final static String CRASH_MESSAGE = "Algo Salio Mal. Reinicia la app";

	Connection con;

	final static String DB_URL = "jdbc:oracle:thin:V3_SYSADMIN/TEST_A@z1t1brpapld17.BR.BATGEN.COM:1521/z1orp25p"; //"jdbc:oracle:thin:ROSALESE/AKIRE2000@z1t1brpapld17.BR.BATGEN.COM:1521:z1orp25p"; // "jdbc:oracle:thin:SIEBELETL/BAHIA_BLANCA$36@z1t1brpapld17.BR.BATGEN.COM:1521:z1orp25p"
	Logger log= Logger.getLogger(DataAccess.class.getName());
	public DataAccess (Connection conn) {
    	SimpleConnection me;
    	if (conn == null) {
    		log.info("created connection");
        	me = new SimpleConnection(".", null);
        	con= me.getConnection();
    	} else {
    		log.info("connection (ok) given");
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
			r= CRASH_MESSAGE;
			e.printStackTrace();
		}
		return r;
	}

	public Report recoverInternalOrder(String u) {
		return recoverInternalOrder(u, null);

	}

	public Report recoverInternalOrder(String u, String function ) {
		Report bean;
		CallableStatement theStatement ;
		ResultSet r = null;// String r= "";
		Object rowData[][]= null;
		String[] columnName= null;
		String query= "";
		ResultSetMetaData metaData;
		int columnCount= 0;
		int rowAmount= 0;
		int rowCount= 0;

		log.info("-" + u);
		if (function == null) {
			query= RECOVER_INTERNAL_ORDER;
		} else {
			query= "{call " + function + "(?,?,?)}"; 
		}
		
		try {
	        theStatement = con.prepareCall(query);// (GET_SERVER_VERSSION)

	     // Passing an array to the procedure -
	        theStatement.setString(1, u);
	        theStatement.registerOutParameter(2, OracleTypes.CURSOR);
	        theStatement.registerOutParameter(3, Types.INTEGER);
	        theStatement.execute();
	        r = (ResultSet)theStatement.getObject(2);
	        rowAmount= theStatement.getInt(3);
	        metaData= r.getMetaData();
	        columnCount= metaData.getColumnCount();
	        rowData = new Object[rowAmount][columnCount];
	        columnName= new String[columnCount];
	        for (int i= 1; metaData!= null && i<= columnCount ; i++ ) {
	        	columnName[i-1]= metaData.getColumnName(i);
	        	
	        }

	        log.info("before loop "+ rowAmount + " element(s)");	        
	        while (r != null && r.next()) {

	         //	comment= r.getString(1); log.info("- " + comment + " incomming from in the array");
	        	rowData[rowCount][0]= r.getString(1);
	        	rowData[rowCount][1]= r.getString(2);
	        	rowData[rowCount][2]= r.getString(3);
	        	rowData[rowCount][3]= r.getString(4);
	        	rowData[rowCount][4]= r.getString(5);
	        	rowData[rowCount][5]= r.getString(6);
	        	rowData[rowCount][6]= r.getString(7);
	        	rowData[rowCount][7]= r.getString(8);
	        	rowData[rowCount][8]= r.getString(9);
	        	rowData[rowCount][9]= r.getString(10);
	        	rowCount++;	        	
	        }
	        theStatement.close();

		} catch (SQLException e) {
		 // TODO Auto-generated catch block
			e.printStackTrace();
		}
		bean= new Report();
		bean.setColumnName(columnName);
		bean.setData(rowData);
		return bean;
	}

	public Report recoverReport(String u, String function ) {
		Report bean;
		CallableStatement theStatement ;
		ResultSet r = null;// String r= "";
		Object rowData[][]= null;
		String[] columnName= null;
		String query= "";
		ResultSetMetaData metaData;
		int columnCount= 0;
		int rowAmount= 0;
		int rowCount= 0;

		log.info("-" + u);
		if (function == null) {
			query= RECOVER_INTERNAL_ORDER;
		} else {
			query= "{call " + function + "(?,?,?)}"; 
		}
		
		try {
	        theStatement = con.prepareCall(query);// (GET_SERVER_VERSSION)

	     // Passing an array to the procedure -
	        theStatement.setString(1, u);
	        theStatement.registerOutParameter(2, OracleTypes.CURSOR);
	        theStatement.registerOutParameter(3, Types.INTEGER);
	        theStatement.execute();
	        r = (ResultSet)theStatement.getObject(2);
	        rowAmount= theStatement.getInt(3);
	        metaData= r.getMetaData();
	        columnCount= metaData.getColumnCount();
	        rowData = new Object[rowAmount][columnCount];
	        columnName= new String[columnCount];
	        for (int i= 1; metaData!= null && i<= columnCount ; i++ ) {
	        	columnName[i-1]= metaData.getColumnName(i);
	        	
	        }

	        log.info("before loop "+ rowAmount + " element(s)");	        
	        while (r != null && r.next()) {

	         //	comment= r.getString(1); log.info("- " + comment + " incomming from in the array");
	        	for (int i=0 ; i < columnCount; i++) {
	        		rowData[rowCount][i]= r.getString(i +1);
	        	}
	        	rowCount++;	        	
	        }
	        theStatement.close();

		} catch (SQLException e) {
		 // TODO Auto-generated catch block
			e.printStackTrace();
		}
		bean= new Report();
		bean.setColumnName(columnName);
		bean.setData(rowData);
		return bean;
	}

	public String[] recoverCatalog(String u) {
		return recoverCatalog(u, null);
		
	}

	public String[] recoverCatalog(String u, String function) {
		CallableStatement theStatement ;
		ResultSet r = null;// String r= "";
		String comment;// String reference;
		String rowData[]= null;
		String query= "";

		int rowAmount= 0;
		int rowCount= 0;

		log.info("-" + u);
		if (function == null) {
			query= GET_ALL_FUNCTION;
		} else {
			query= "{call " + function + "(?,?,?)}"; 
		}
		try {
	        theStatement = con.prepareCall(query);// (GET_SERVER_VERSSION)

	     // Passing an array to the procedure -
	        theStatement.setString(1, u);
	        theStatement.registerOutParameter(2, OracleTypes.CURSOR);
	        theStatement.registerOutParameter(3, Types.INTEGER);
	        theStatement.execute();
	        r = (ResultSet)theStatement.getObject(2);
	        rowAmount= theStatement.getInt(3);
	        rowData = new String[rowAmount];

	        log.info("before loop "+ rowAmount + " element(s)");	        
	        while (r != null && r.next()) {

	        	comment= r.getString(1);
	        	log.info("- " + comment + " incomming from in the array");
	        	rowData[rowCount]= r.getString(1);
	        	rowCount++;	        	
	        }
	        theStatement.close();

		} catch (SQLException e) {
		 // TODO Auto-generated catch block
			e.printStackTrace();
		}
		return rowData;
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
			r= CRASH_MESSAGE;
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
