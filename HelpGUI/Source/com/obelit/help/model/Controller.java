package com.obelit.help.model;

import java.awt.Component;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.logging.Logger;

import javax.swing.Icon;
import javax.swing.JButton;
import javax.swing.JOptionPane;
import javax.swing.JTextField;

import com.obelit.common.Control;
import com.obelit.help.gui.MainFrame;
import com.obelit.util.StateBox;

public class Controller implements ActionListener, Control {
	public static final String LOCKED_STATUS = "LOCKED";
	public static final String LOCKED_TIMED_STATUS = "LOCKED(TIMED)";
	Handler handler= null;
	StateBox box;
	Logger log= Logger.getLogger(Controller.class.getName());
	MainFrame frame;
	public Controller(MainFrame fm) {
		this( fm, null);
		
	}
	public Controller(MainFrame fm, String wd) {
		frame= fm;
		handler= new Handler( new DataAccess(), wd);
		box = new StateBox (); 
		
		
	}

	public boolean checkPrivilege () {
		return checkPrivilege(System.getProperty("user.name"));
	}
	public boolean checkPrivilege (String u) {
		dispatch(MainFrame.LOGIN_AUTO);
		return false;
	}

	@Override
	public void actionPerformed(ActionEvent e) {
		String label= "";
		Object eventSource;
		log.info("action");

		eventSource = e.getSource();
		if (eventSource instanceof JButton ) {
			label= ( ( JButton )eventSource).getText();
		}

		if (eventSource instanceof JTextField ) {
			log.info("event catch");
			if(MainFrame.HANGED_JTEXT_NAME.equalsIgnoreCase( ((JTextField)eventSource ).getName()) )
			label= MainFrame.SEARCH_TITLE;
			if(MainFrame.PASS_JTEXT_NAME.equalsIgnoreCase( ((JTextField)eventSource ).getName()) )
			label= MainFrame.FIND_TITLE;
		}
		log.info(". " + dispatch(label));
	}

	public boolean dispatch(String name) {
		return dispatch(name, null);
	}

	public boolean dispatch(String name, String option) {
		boolean value= false;
		Icon icon = null;
		String feedback;
		String r;
		log.info("dispatching");
		if (option != null && LOCKED_STATUS.equalsIgnoreCase(option) ) {
			name =MainFrame.NO_ACTION_TITLE;
		}

		if (option != null && LOCKED_TIMED_STATUS.equalsIgnoreCase(option) ) {
			name =MainFrame.UNLOCK_TITLE;
		}

		if (name != null && name.equalsIgnoreCase(MainFrame.NO_ACTION_TITLE)) {

			JOptionPane.showMessageDialog(
					frame.getFrame(), option, frame.getHHUName(null),
				    JOptionPane.PLAIN_MESSAGE
			);

			value= true;
		}
		if (name != null && name.equalsIgnoreCase(MainFrame.LOGIN_AUTO)) {
			handler.login(this);
			value= true;
		}
		if (name != null && name.equalsIgnoreCase(MainFrame.SEARCH_TITLE)) {
			r =handler.findSyncStatus(MainFrame.TAB_TITLE[1], frame.getHangedUName(frame.getHHUName(null)), this);
			JOptionPane.showMessageDialog(
					frame.getFrame(), r, frame.getHangedUName(null),
				    JOptionPane.PLAIN_MESSAGE
			);

			value= true;
		}
		if (name != null && name.equalsIgnoreCase(MainFrame.FIND_TITLE)) {
			handler.findHH("0", frame.getHHUName(""), this);
			value= true;
		}
		if (name != null && name.equalsIgnoreCase(MainFrame.RESET_TITLE)) {
			feedback= handler.findNewPass("-", frame.getHHUName(null), this);
			if (feedback != null & feedback.startsWith("Error")) {
				JOptionPane.showMessageDialog(
						frame.getFrame(), feedback, frame.getHHUName(null),
					    JOptionPane.PLAIN_MESSAGE
				);
				feedback= "";
			} else {
			   feedback = (String)JOptionPane.showInputDialog(
                    frame.getFrame(),
                    CHANGE_PASS_SENTENCE + frame.getHHUName(null)+ "\n" + CHANGE_PASS_FINAL_SENTENCE,
                    "Confirmation Dialog",
                    JOptionPane.PLAIN_MESSAGE,
                    icon,
                    null,
                    feedback
                );
			}
			if ((feedback != null) && (feedback.length() > 0) && feedback.indexOf("Error") == -1) {
				handler.resetPassword(frame.getHHUName(null),feedback);
			}			
			value= true;
		}
		if (name != null && name.equalsIgnoreCase(MainFrame.UNLOCK_TITLE)) {
			feedback = (String)JOptionPane.showInputDialog(
                    frame.getFrame(),
                    UNLOCK_USER_SENTENCE + frame.getHHUName(null),
                    "Confirmation Dialog",
                    JOptionPane.PLAIN_MESSAGE,
                    icon,
                    null,
                    frame.getHHUName(null)
            );
			if ((feedback != null) && (feedback.length() > 0)) {
				handler.unlock(feedback);
			}			
			value= true;
		}
		if (name != null && name.equalsIgnoreCase(MainFrame.LOCK_TITLE)) {
			feedback = (String)JOptionPane.showInputDialog(
                    frame.getFrame(),
                    LOCK_USER_SENTENCE + frame.getHHUName(null),
                    "Confirmation Dialog",
                    JOptionPane.PLAIN_MESSAGE,
                    icon,
                    null,
                    frame.getHHUName(null)
            );
			if ((feedback != null) && (feedback.length() > 0)) {
				handler.lock(feedback);
			}			
			value= true;
		}
		log.info("dispatched");

		return value;
		
	}
	public void exit() {
		log.info("exit");
		handler.end();
		
	}

	@Override
	public String applyPrivilege( String c) {
		// TODO Auto-generated method stub
		log.info(c);
	 //	frame.setTextAreaValue(c);
		frame.enableRole(c);
		return null;
	}

	@Override
	public String callback(String id, String c) {
		String boxState= "";
		log.info(c);

		boxState = (box ==null)?"-":box.getCurrentState();

		if (MainFrame.TAB_TITLE[1].equalsIgnoreCase(id)) {
			frame.appendOtherTextAreaValue(c);
		} else {
	 //	frame.setTextAreaValue(c);
		frame.appendTextAreaValue(c+ "\n");
		}

		if (StateBox.READY_STATUS.equalsIgnoreCase(boxState) && c != null && c.length() > 1 ) {
		 // This line Should be the previous to State.
			log.info("Ready. This is it ("+ c +" )");
			box.reset();
			dispatch(MainFrame.RESET_TITLE, c);
		 //	frame.passwordDialog(c);
			
		}

		if ("ACCOUNT_STATUS".equalsIgnoreCase(boxState) ) {
		 // This line Should be the previous to State.
			log.info("Pepared. Almost there");
			box.setState(StateBox.READY_STATUS);
		}

		if ("ACCOUNT_STATUS".equalsIgnoreCase(c)) {
			 // Status coming in the next line
			    log.info("Alert. It is coming");
				box.setState(c);
		}
		return null;
	}

	@Override
	public String callback(String c) {
		// TODO Auto-generated method stub
		return callback( null, c);
	}
	@Override
	public Component getFrame() {
		// TODO Auto-generated method stub
		return frame.getFrame();
	}

}
