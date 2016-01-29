package com.pool;

import java.io.File;
import java.io.FileNotFoundException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Scanner;
import java.util.logging.Logger;


public class SimpleConnection {
	public static String SIEBELET_TAO="jdbc:oracle:thin:SIEBELETL/SIEBELETL$36@10.90.218.165:1521/z1orr25p";
	Connection con ;
	File io;
	Scanner theScanner;
	String url;
	Logger log = Logger.getLogger(SimpleConnection.class.getName());
	String array[] = {"one", "two", "three","four"}; 
    public SimpleConnection () {
    	this(null, SIEBELET_TAO);

    }
    public SimpleConnection (String fullfilename, String uri) {
    	log.info("init");
    	if (uri == null) {
    		log.info(fullfilename);
    		io = new File(fullfilename);
    		try {
    			theScanner = new Scanner(io);
    			uri= theScanner.nextLine();
    			theScanner.close();
    		} catch (FileNotFoundException e) {
    			// TODO Auto-generated catch block
    			e.printStackTrace();
    		}

    	}
    	url= uri;
    	try {
			Class.forName("oracle.jdbc.OracleDriver");
		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}         

    }

    public void cancel() {
    	log.info("cancel");
    	if (con == null) {
    		log.info("Already null");
    	} else {
    		try {
				con.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
    	}    	
    }

    public Connection getConnection () {
    	log.info("get [" + url + "]");
    	try {
    		if (con == null) con= DriverManager.getConnection(url);
			log.info("got");
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}; 
    	return con;    	
    }

    public static void main (String argument[]) throws SQLException {
    	SimpleConnection me;
    	me = new SimpleConnection();
    	me.getConnection();
    	me.cancel();
    	
    }
}
