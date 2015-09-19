package com.obelit.help.model;

import java.io.BufferedWriter;
import java.io.IOException;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.util.logging.Logger;

import com.obelit.common.Commander;

public class TerminalOutput implements Runnable {
	Thread t;
	Process p;
	OutputStream terminalStandardin;

	BufferedWriter writer ;
	Commander controller;
	public final static String CONNECTED_OK = "Connected to:";
	static Logger log = Logger.getLogger(TerminalOutput.class.getName());

	public TerminalOutput(Commander control, Process pp) {
		p= pp;
		controller= control;
		terminalStandardin = p.getOutputStream ();
		writer = new BufferedWriter (new OutputStreamWriter(terminalStandardin));
	}

	public void run() {

		log.info("out of run");

	}
	public String type (String line)  {
		try {
			writer.write(line);
			writer.flush();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		return "";
		
	}
	public void go() {
		if (t == null) t= new Thread (this);
		t.start();
	}

}
