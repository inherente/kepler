package com.obelit.help.model;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.logging.Logger;

import com.obelit.common.Commander;

public class TerminalInput implements Runnable {
	Thread t;
	Process p;
	InputStream terminalStandardout;
	BufferedReader reader;
	Commander controller;
	public final static String CONNECTED_OK = "Connected to:";
	public final static String SYSDATE_OK = "SYSDATE";
	public final static int SLEEP_TIME_IN_MILIS = 99;
	static Logger log = Logger.getLogger(TerminalInput.class.getName());

	public TerminalInput(Commander control, Process pp) {
		p= pp;
		controller= control;
		terminalStandardout = p.getInputStream ();
		reader = new BufferedReader (new InputStreamReader(terminalStandardout));
	}

	public void run() {
		String line;
		String lastLine ="";

		// TODO Auto-generated method stub
		try {

			while ((line = reader.readLine ()) != null) {

			    System.out.println ("Standar out: " + line);
				try {Thread.sleep(SLEEP_TIME_IN_MILIS);} catch (InterruptedException e) {e.printStackTrace();}
			    if (CONNECTED_OK.equalsIgnoreCase(line) ) {
			    	controller.controlBackToYou(line);
			    }else if (line != null && line.indexOf("sqlplus" ) != -1) {
			    	line = "sqlplus";
			    	
			    } else { // (line != null && line.indexOf(controller.getArgument() ) != -1 ) 
			    	lastLine =line;
			    	controller.controlBackToYou(lastLine);
			    	
			    }

			}

		} catch (IOException e) {
			log.info("truncated of run");
			e.printStackTrace();
		}
		log.info("out of run");

	}
	public void go() {
		if (t == null) t= new Thread (this);
		t.start();
	}

}
