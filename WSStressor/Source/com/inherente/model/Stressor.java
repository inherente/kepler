package com.inherente.model;

import java.io.File;
import java.io.FileInputStream;
import java.io.FilenameFilter;// import java.io.IOException;
import java.util.logging.Logger;


public class Stressor {
	public static final String DEFAULT_WORKING_FOLDER  = "C:\\Users\\GUTIERREZLE\\Development\\workSpace\\Kepler\\WSStressor\\input";
	public static final String DEFAULT_CONTENT  = "<content xsi:type=\"xsd:string\">contenido</content>";
	public static final String TEST_WS_ADDRESS ="http://Z1T1BRTCVLA148.br.batgen.com:5555/invoke/incoming/CustomerMaster"; //.z1t1brpavta144
	FilenameFilter filter;
	static Logger log = Logger.getLogger(Stressor.class.getName());
	String address;

	public Stressor () {
		this(TEST_WS_ADDRESS);

	}

	public Stressor (String a) {
		filter = new FilenameFilter() {
			public boolean accept(File dir, String name) {
				boolean returnValue= false;
				if (name.indexOf(".xml")> 0)
					returnValue= true;
				else returnValue= false;
				return returnValue;
			}
		};
		address =a;
	}

	public void doItAll(String wdir) {
		HTTPConnection con;
		log.info("max");
		con = new HTTPConnection (address);// con.put(DEFAULT_CONTENT);
		File[] listOfFiles;
		File folder = null;// File currentOutputFile;
		FileInputStream currentFileInput = null; 
		String content;

		byte[] data ; // = new byte[(int) file.length()];

		folder= new File (wdir);
		listOfFiles = folder.listFiles(filter);
		log.info("¿File Folder? = " +folder.isDirectory());
		log.info("process("+ wdir +") " + listOfFiles.length + " file(s)");
		try {
			for (File currentFile: listOfFiles ) {
				log.info("doItAll( "+ currentFile.getName()+ ")");
				currentFileInput= new FileInputStream(currentFile);
				data = new byte[(int) currentFile.length()];
				currentFileInput.read(data);
				currentFileInput.close();
				content= new String(data, "UTF-8");
				con.put(content);

			}
		} catch (Exception io) {log.info("Shit.");}
	}

	public static void main (String[] a) {
		String dir;
		String address= null;
		log.info("main");
		if (a== null || a.length< 1) {
			dir =DEFAULT_WORKING_FOLDER;
		} else {
			dir= a[0];
		}		
		if (a != null && a.length >1) {
			address= a[1];
		} else {
			address = TEST_WS_ADDRESS;
		}
		new Stressor(address).doItAll(dir);
	}
}
