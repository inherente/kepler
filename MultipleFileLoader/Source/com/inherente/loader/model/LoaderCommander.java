package com.inherente.loader.model;

import java.io.File;
import java.io.IOException;
import java.util.logging.Logger;

public class LoaderCommander implements Runnable {
	static Logger log = Logger.getLogger(LoaderCommander.class.getName());
	Thread monitor;
	private Process process;
	private String workingDirectory;
	private String fileName;
	private String command;
	private String param[];
	public static final String LOADER_COMAND= "sqlldr userid=EAI/EAI$TAO@LEGDB_TAOQAS control=C:\\Users\\GUTIERREZLE\\Development\\workSpace\\TaO\\CControl\\CONTROL.ctl log=process.log";
	public static final String DEFAULT_WORKING_DIRECTORY= "C:\\Users\\GUTIERREZLE\\Development\\workSpace\\TaO\\CControl";
 //	sqlldr userid=EAI/EAI$TAO@LEGDB_TAOQAS control=E:\IntegrationToolBox\Venta\CONTROL.ctl log=process.log

	public LoaderCommander () {
		this(null, null);
		
	}

	public LoaderCommander (String workingDiectory, String param[]) {
		if(workingDiectory== null) workingDiectory= DEFAULT_WORKING_DIRECTORY;
		setWorkingDirectory(workingDiectory);log.info(workingDiectory);
		setParam(param);
		setCommand("sqlldr userid="+ param[0] + " control=" + getWorkingDirectory()+ "\\CONTROL.ctl log=process.log");

	}

	public void run() {
		while (true) {
			log.info("waiting");
			try {
				Thread.sleep(1000);
				getProcess().waitFor();
			} catch (InterruptedException e) {e.printStackTrace();}
			break;
		}
		log.info("out of run");
	}

	public Process load() {
		Runtime rt;
		Process p= null;
		File dir;
		dir = new File(getWorkingDirectory());
		rt= Runtime.getRuntime();
		log.info(getCommand());

		try {
			p= rt.exec( getCommand(), null, dir);
		} catch (IOException e) {
			e.printStackTrace();
			p= null;
		}

		return p;
	}

	void monitor (Process p) {
		monitor = new Thread(this);
		setProcess(p);
		monitor.start();
		
	}

	public static void main(String[] argm) {
		LoaderCommander com;
		log.info("init");
		com= new LoaderCommander(System.getProperty("user.dir"), new String[]{argm[0]});
		com.monitor(com.load());
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

}
