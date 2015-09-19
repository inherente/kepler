package com.obelit.help.model;


import java.awt.Cursor;
import java.io.File;
import java.io.IOException;
import java.util.logging.Logger;

import com.obelit.common.Commander;
import com.obelit.common.HandlerDriver;

public class Loader5Commander implements Runnable , Commander {
	static Logger log = Logger.getLogger(Loader5Commander.class.getName());
	Thread monitor;
	TerminalOutput terminal;
	private int localSemaphore =-1;// -1 off 0 ready 1 on
	private static final int SEMAPHORE_OFF =-1;
	private static final int SEMAPHORE_READY =0;
	private static final int SEMAPHORE_ON =1;
	private static final int SEMAPHORE_DISABLE= 2;
	private static final String[] SEMAPHORE= {"CATEGORY", "--------------------------------------------------------------------------------"};
	private Process process;
	private String workingDirectory;
	private String fileName;
	private String command;
	private String param[];
	private String argument;
	HandlerDriver callback;

	public static final String LOADER_COMAND= "sqlldr userid=EAI/EAI$TAO@LEGDB_TAOQAS control=C:\\Users\\GUTIERREZLE\\Development\\workSpace\\TaO\\CControl\\CONTROL.ctl log=process.log";
	public static final String DEFAULT_WORKING_DIRECTORY= "C:\\Users\\GUTIERREZLE\\git\\Sandbox\\MultipleFileLoader\\export";
	public static final String DEFAULT_COMMAND= "sqlplus ROSALESE/AKIRE2000@10.90.217.200:1521/z1orp25p";
 //	sqlldr userid=EAI/EAI$TAO@LEGDB_TAOQAS control=E:\IntegrationToolBox\Venta\CONTROL.ctl log=process.log

	public Loader5Commander () {
		this(null, null, null);
		
	}

	public Loader5Commander (String workingDiectory, String command, String param[]) {
		this(workingDiectory, command, param, null);

	}

	public Loader5Commander (String workingDiectory, String command, String param[], HandlerDriver handler) {
		
		if(workingDiectory== null) workingDiectory= DEFAULT_WORKING_DIRECTORY;
		if (command== null) command =DEFAULT_COMMAND ;
		setWorkingDirectory(workingDiectory);log.info(workingDiectory);
		setParam(param);
	 //	setCommand("sqlldr userid="+ param[0] + " control=" + getWorkingDirectory()+ "\\CONTROL.ctl log=process.log");
		setCommand(command);

	}

	public void run() {
		callback.getFrame().setCursor(Cursor.getPredefinedCursor(Cursor.WAIT_CURSOR));
		while (true) {
			log.info("waiting");
			try {
				Thread.sleep(1000);
				getProcess().waitFor();
			} catch (InterruptedException e) {e.printStackTrace();}
			break;
		}
		callback.getFrame().setCursor(Cursor.getDefaultCursor());
		log.info("out of run");
	}

	public Process load() {
		return load(null);
	}

	public Process load(String argument) {

		return load(argument, null);
	}

	public Process load(String argument, String followArgument) {

		return load(argument, followArgument, "");
	}

	public Process load(String argument, String followArgument, String thirdArgument) {

		return load(argument, followArgument, thirdArgument, "");
	}

	public Process load(String argument, String followArgument, String thirdArgument, String fourthArgument) {
		ProcessBuilder builder ;// Runtime rt;
		Process p= null;// File dir;
		setArgument (argument);

		builder = new ProcessBuilder(getCommand(), argument, followArgument, thirdArgument, fourthArgument);
		builder.redirectErrorStream(true);// rt= Runtime.getRuntime();
		builder.directory(new File (getWorkingDirectory()));
		log.info(getCommand()+ ": (1) "+ argument+ " (2) "+ followArgument+ " (3) "+ thirdArgument+ " (4) "+ fourthArgument);

		try {

			p= builder.start();// p= rt.exec( getCommand(), null, dir); 
		} catch (IOException e) {
			e.printStackTrace();
			p= null;
		}

		return p;
	}

	void monitor (Process p, Handler cb) {
		callback= cb;
		monitor = new Thread(this);
		setProcess(p);
		new TerminalInput(this, p).go();
		terminal= new TerminalOutput(this, p);
		monitor.start();
		
	}

	public static void main(String[] argm) {
		Loader5Commander com;
		String c= DEFAULT_COMMAND ;
		log.info("init");
		if (argm == null || argm.length ==0) {
			log.info("no argument");
		}else {
			c = argm[0];
		}
		log.info("main "+ c);
		com= new Loader5Commander(System.getProperty("user.dir"),c , null);
		com.monitor(com.load( argm[1]), null);
		log.info("exit");
		
	}

	public String getCommand() {
		return command;
	}

	public void setCommand(String command) {
		this.command = command;
	}

	public String getWorkingDirectory() {
		return workingDirectory;
	}
	public void setWorkingDirectory(String workingDiectory) {
		this.workingDirectory = workingDiectory;
	}
	public String getFileName() {
		return fileName;
	}
	public void setFileName(String fileName) {
		this.fileName = fileName;
	}
	public String[] getParam() {
		return param;
	}
	public void setParam(String param[]) {
		this.param = param;
	}

	public Process getProcess() {
		return process;
	}

	public void setProcess(Process process) {
		this.process = process;
	}

	private int setStatus (String v) {
		if (localSemaphore== Loader5Commander.SEMAPHORE_OFF) {
			if (Loader5Commander.SEMAPHORE[0].equalsIgnoreCase(v))localSemaphore =Loader5Commander.SEMAPHORE_ON;			
		} else if (localSemaphore== Loader5Commander.SEMAPHORE_ON) {
			if (Loader5Commander.SEMAPHORE[1].equalsIgnoreCase(v) )localSemaphore= Loader5Commander.SEMAPHORE_READY;
		} else if (localSemaphore== Loader5Commander.SEMAPHORE_READY) {
			callback.updateRole(v);
			localSemaphore= Loader5Commander.SEMAPHORE_DISABLE;
			
		}
		return 0; 
	}

	public String controlBackToYou(String r) {
		// TODO Auto-generated method stub
		log.info(r);
		callback.callBack(r);
		setStatus(r);
	 // terminal.type("select sysdate from dual;");
		return null;
	}

	public String getArgument() {
		return argument;
	}

	public void setArgument(String argument) {
		this.argument = argument;
	}

}
