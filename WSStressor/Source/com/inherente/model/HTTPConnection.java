package com.inherente.model;

import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.UnknownHostException;// import java.sql.Connection;
import java.util.Date;
import java.util.logging.Logger;

import org.apache.axis.encoding.Base64;

public class HTTPConnection {
	HttpURLConnection con;
	URL url;
	private String address;
	private String login;
	private String password;
	private String encoding;
	OutputStream conStream;
	public static final String DEFAULT_USER_NAME ="Administrator";
	public static final String DEFAULT_USER_PASSWORD ="manage";
	Logger log =Logger.getLogger(HTTPConnection.class.getName());

	public HTTPConnection (String address) {
    	this(address, DEFAULT_USER_NAME, DEFAULT_USER_PASSWORD);

    }

	public HTTPConnection (String address, String u, String p) {
		String up;
    	setLogin(u);
    	setPassword(p);
    	setAddress(address);
    	up= getLogin() + ":" + getPassword();

    	setEncodedCode(Base64.encode(up.getBytes()));
    	try {url = new URL (address);} catch (MalformedURLException e) {e.printStackTrace();}
    }

    public String putAll (String fullFolderName) {

    	return "";
    }

    public String put (String xml) {
    	int code;
    	String up= "PI_BC_User:BC_PI_User";//"Administrator:manage"
    	log.info("init");
	    try {

	     // 1. Create HttpURLConnection object with the end point URL
	        log.info (address);
	        con = (HttpURLConnection) url.openConnection();
	        log.info("connection url done\n"); // Base64.encode(up.getBytes())

	     // 2. Set the HTTP POST
	        con.setRequestMethod("POST");

	     // 3. Use the setRequestProperty() method to set header lines
	        con.setRequestProperty("Content-type", "text/xml; charset=utf-8"); //application/x-www-form-urlencoded
	        con.setRequestProperty("SOAPAction","incoming/Customer"); // ¿Does This Line make any difference?
	        log.info("Content-type text/xml; charset=utf-8");
	        con.setRequestProperty("Authorization", "Basic "+ getEncodedCode() ) ;// "Basic ODEwNTQw:YjM2cGljMWJi"

	        log.info("wait for code\n");
	     // 4. Prepare the entire SOAP request XML message
	     // write the XML message to the connection

	        con.setDoOutput(true);
	        con.setDoInput(true);
	        con.setAllowUserInteraction(false);
	        conStream= con.getOutputStream();
	        log.info("back to the future\n");
	        conStream.write(xml.getBytes());//FileHelper.getFileContent(FileHelper.SALES_ORDER_MESSAGE_FILE)
	        conStream.close();
	     // Step 4. is only required when the it is expecting a message from this client
	     // In that case comment out the connect() and getResponseCode lines

	        con.connect();
	        code =con.getResponseCode();
	        log.info("code " + code);
	        log.info(new Date().toString()+ " got code \n");

	    } catch (UnknownHostException ue) {
	        log.info("cannot get code \n"+ ue);
	    } catch(MalformedURLException exc) {
	        log.info ("cannot create file \n"+ exc);

	    } catch (java.io.IOException exc) {
	        log.info ("cannot io \n"+ exc);
	        log.info("cannot io \n"+ exc);
	    }

    	return up;
    }

    public String getAddress() {
		return address;
	}

    public void setAddress(String address) {
		this.address = address;
	}

    public String getLogin() {
		return login;
	}

    public void setLogin(String login) {
		this.login = login;
	}

    public String getPassword() {
		return password;
	}

    public void setPassword(String password) {
		this.password = password;
	}

	public String getEncodedCode() {
		return encoding;
	}

	public void setEncodedCode(String encoding) {
		this.encoding = encoding;
	}
}
