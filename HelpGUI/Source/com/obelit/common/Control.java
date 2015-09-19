package com.obelit.common;

import java.awt.Component;

public interface Control {
	final static String CHANGE_PASS_SENTENCE = "Alter User ";
	final static String CHANGE_PASS_FINAL_SENTENCE = "New Pass:";
	final static String UNLOCK_USER_SENTENCE = "Unlock User ";
	final static String LOCK_USER_SENTENCE = "Lock User ";

	public String applyPrivilege(String c);
	public String callback(String c);
	public String callback(String t, String c);
	public Component getFrame();
	public boolean checkPrivilege();
}
