package com.obelit.help.model;

import java.awt.Component;
import java.util.Hashtable;
import java.util.logging.Logger;

import com.obelit.common.Control;
import com.obelit.common.HandlerDriver;
import com.obelit.help.bean.Report;
import com.obelit.help.gui.MainFrame;

public class Handler implements HandlerDriver {
	Logger log= Logger.getLogger(Handler.class.getName());
	DataAccess dao;
	Control controller;
	Loader5Commander com; 
	Hashtable<String, String> ht= null;
	String wd;

	public Handler (DataAccess d) {
		this(d, null);
	}

	public Handler (DataAccess d, String wdir) {
		dao= d;
		com= new Loader5Commander(wdir, null , null);// System.getProperty("user.dir")
		wd= wdir;
	}

	public boolean login(String uName, Control control) {
		log.info("login()");
		controller = control;
		com.setCommand(wd+ "\\"+MainFrame.FIND_STATUS_COMMAND);
		com.monitor(com.load("@privilege.sql", uName), this);

		return false;
		
	}
	public Component getFrame () {
		return controller.getFrame();
	}

	public boolean login( Control control) {

		return login(System.getProperty("user.name"), control);
		
	}
	public String[] getFunctionCatalog() {
		return dao.recoverCatalog(null);
	}

	public boolean doSearch() {
		log.info("doSearch()");
		return false;
		
	}

	public String findNewPass(String trn ,String uName, Control control) {
		String r;
		log.info("findNewPass()");
		controller = control;
		r= dao.createUserPass(uName);
		controller.callback(trn, r);

		return r;
		
	}
	
	public Report recoverInternalOrder(String trn ,String uName, Control control) {
		String r= "";
		Report bean ;//	Object[][] data;
		log.info("recoverInternalOrder()");
		controller = control;
		bean= dao.recoverInternalOrder(uName);
		controller.callback(trn, r);

		return bean ;
		
	}
	public Report recoverReport(String trn ,String uName, String function, Control control) {
		String r= "";
		Report bean ;//	Object[][] data;
		log.info("recoverReport()");
		controller = control;
		bean= dao.recoverReport(uName, function);
		controller.callback(trn, r);

		return bean ;
		
	}
	public String findSyncStatus(String trn ,String uName, Control control) {
		String r;
		log.info("findSyncStatus()");
		controller = control;
		r= dao.recoverUserInfo(uName);
		controller.callback(trn, r);

		return r;
		
	}

	public boolean findSyncoStatus(String trn ,String uName, Control control) {
		log.info("findSyncoStatus()");
		controller = control;
		com.setCommand(MainFrame.FIND_STATUS_COMMAND);
		com.monitor(com.load("@halt.sql", uName), this);

		return false;
		
	}

	public String findHH(String trn ,String uName, Control control) {
		String value= "";
		controller = control;
		com.setCommand(MainFrame.FIND_STATUS_COMMAND);
		com.monitor(com.load("@query.sql", uName), this);
		return value;
	}

	public boolean resetPassword(String u, String p) {
		log.info("resetPassword()" + u + " - " + p);
	 //	dao.alterUSer();
		com.setCommand(MainFrame.FIND_STATUS_COMMAND);
		com.monitor(com.load("@alter.sql", u , p, System.getProperty("user.name")), this);
		return false;
		
	}

	public boolean unlock(String u) {
		log.info("unlock()");
		com.setCommand(MainFrame.FIND_STATUS_COMMAND);
		com.monitor(com.load("@unlock.sql", u ,System.getProperty("user.name")), this);
		return false;
		
	}

	public boolean lock(String u) {
		log.info("unlock()");
		com.setCommand(MainFrame.FIND_STATUS_COMMAND);
		com.monitor(com.load("@lock.sql", u ,System.getProperty("user.name")), this);
		return false;
		
	}

	public void end() {
		log.info("#end");
		if (dao == null) {
			log.info("null DAO");
		} else {
			dao.bye();
		}
		
	}
	@Override
	public String callBack(String v) {
		// TODO Auto-generated method stub
		log.info(v);
		controller.callback(v);
		return null;
	}

	@Override
	public String updateRole(String v) {
		log.info(v);
		controller.applyPrivilege(v);
		return null;
	}

}
