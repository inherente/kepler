package com.obelit.help.gui;
import java.awt.Component;
import java.awt.Dimension;
import java.awt.FlowLayout;// import java.awt.GridLayout;
import java.awt.event.ActionListener;
import java.awt.event.WindowEvent;
import java.awt.event.WindowListener;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.logging.Logger;

import javax.swing.Icon;
import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTabbedPane;
import javax.swing.JTable;
import javax.swing.JTextArea;
import javax.swing.JTextField;
import javax.swing.text.DefaultCaret;

import com.obelit.common.Control;
import com.obelit.help.model.Controller;
import com.obelit.help.model.Loader5Commander;
import com.obelit.help.view.QueryView;
import com.pool.SimpleConnection;

public class MainFrame {
	static final String TITLE= "Help Desk (beta)";
	public static final String SYST_ADMIN_ROLE= "SystAdm";
	public static final String HELP_DESK_ROLE= "HelpDesk";
	public static final String SEARCH_TITLE= "Buscar Status HH";
	public static final String LOGIN_AUTO= "AutoCheck";
	public static final String FIND_TITLE= "Cambio Pass";
	public static final String QUERY_GO= "Go";

	public static final String RESET_TITLE= "Reset Pass";
	public static final String UNLOCK_TITLE= "Unlock User";
	public static final String NO_ACTION_TITLE= "NoAction";
	public static final String LOCK_TITLE= "Lock User";
	public static final String OPEN_TITLE= "OPEN";
	public static final String USER_LABEL= "HandHeld User:";
	public static final String FIND_STATUS_COMMAND= "find.bat"; // C:\\Users\\GUTIERREZLE\\git\\Sandbox\\MultipleFileLoader\\export\\find.bat
	public static final String HANGED_JTEXT_NAME= "HangName";
	public static final String PASS_JTEXT_NAME= "PassName";

	public static final int FIELD_LENGTH= 30;
	public static final int TEXT_AREA_ROWS= 20;
	public static final String [] TAB_TITLE= {"Password", "¿Colgado?", "Query"};
	public static final String [] CURRENT_DEFAULT_QRY= {"Internal Order"};
	static final Dimension d= new Dimension(400,200);
	static final Object rowData[][] = { 
		{ "Row1-Column1", "Row1-Column2", "Row1-Column3"},
        { "Row2-Column1", "Row2-Column2", "Row2-Column3"} 
	};
	static final Object columnName[] = { "Column One", "Column Two", "Column Three"};
	JFrame frame;
	JPanel panelHalted;
	JPanel panelButton;
	JPanel panelQuery;
	JPanel panelSelection;
	JPanel panelGrid;
	JPanel panelActionCommand;
	JPanel panelPassword;
	JButton findPass;
	JButton findHHU;
	JButton changePass;
	JButton unlock;
	JButton lock;
	JTable queryGrid;
	ActionListener controller;
	Control c;
	JComboBox<String> combo;
	JButton goQuery;
	JTabbedPane tabbedPane;
	JTextField documentId;
	JTextField handHeldUserHalted;
	JTextField handHeldUserPassword;
	JTextArea textAreaPass;
	JTextArea textAreaHH;
	DefaultCaret caret;
	DefaultCaret caretHH;
	JScrollPane gridScrollpane;
	JScrollPane textScrollpane;
	JScrollPane textHHScrollpane;
	private QueryView queryTab;
	Logger log= Logger.getLogger(MainFrame.class.getName());
	SimpleConnection pool;
	Connection con;

	public MainFrame() {
		this(null);
	}

	public MainFrame(String wd) {
		frame = new JFrame();
		pool = new SimpleConnection(wd+"\\conection.properties", null);
		con= pool.getConnection();
		
		controller= new Controller(this, wd);
		init();
		((Control)controller).checkPrivilege();

	}
	public void bye() {
		log.info("bye");
		if ( controller != null && controller instanceof Controller)
		((Controller)controller).exit();
		if (con == null)log.info("conection not opened");else {
			try {con.close();} catch (SQLException e) {e.printStackTrace();}
		}

	}

	private void init() {
		tabbedPane = new JTabbedPane();
		frame.setTitle(TITLE);

		frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		frame.addWindowListener(new WindowsHandler(this));
		setQueryView(new QueryView(controller));

		handHeldUserHalted =new JTextField(FIELD_LENGTH) ;
		handHeldUserHalted.addActionListener(controller);
		handHeldUserHalted.setName(HANGED_JTEXT_NAME);
		handHeldUserPassword =new JTextField(FIELD_LENGTH) ;
		handHeldUserPassword .addActionListener(controller);
		handHeldUserPassword.setName(PASS_JTEXT_NAME);

		log.info("JTextField Name- " + handHeldUserHalted.getName());
		log.info("JTextField Name- " + handHeldUserPassword.getName());

		findPass = new JButton(FIND_TITLE);
		changePass= new JButton(RESET_TITLE);
		unlock= new JButton(UNLOCK_TITLE);
		lock= new JButton(LOCK_TITLE);
		findPass.addActionListener(controller);
		changePass.addActionListener(controller);
		unlock.addActionListener(controller);
		lock.addActionListener(controller);
		findPass.setEnabled(false);
		changePass.setEnabled(false);
		unlock.setEnabled(false);
		lock.setEnabled(false);
		textAreaPass= new JTextArea(TEXT_AREA_ROWS, FIELD_LENGTH);
		caret = (DefaultCaret)textAreaPass.getCaret();
		caret.setUpdatePolicy(DefaultCaret.ALWAYS_UPDATE);
		textScrollpane = new JScrollPane(textAreaPass);

		combo= new JComboBox<String>(CURRENT_DEFAULT_QRY);
		goQuery= new JButton(QUERY_GO);
		goQuery.addActionListener(controller);
		documentId = new JTextField();
		queryGrid = new JTable(
				rowData, columnName
		);

		panelPassword= new JPanel();		
		panelButton= new JPanel();
		panelPassword.setLayout(new FlowLayout());
		panelPassword.add((new JLabel(USER_LABEL)));
		panelPassword.add(handHeldUserPassword);
		panelButton.add(changePass);
		panelButton.add(lock);
		panelButton.add(unlock);
		panelPassword.add(findPass);
	 //	panelPassword.add(textScrollpane);
		panelPassword.add(panelButton);

		findHHU= new JButton(SEARCH_TITLE);
		findHHU.addActionListener(controller);
		findHHU.setEnabled(false);
		textAreaHH= new JTextArea(TEXT_AREA_ROWS, FIELD_LENGTH);
		caretHH = (DefaultCaret)textAreaHH.getCaret();
		caretHH.setUpdatePolicy(DefaultCaret.ALWAYS_UPDATE);
		textHHScrollpane= new JScrollPane(textAreaHH);

		panelHalted= new JPanel();
		panelHalted.setLayout(new FlowLayout());
		panelHalted.add((new JLabel(USER_LABEL)));
		panelHalted.add(handHeldUserHalted);
		panelHalted.add(findHHU);
	 //	panelHalted.add(textHHScrollpane);

		panelQuery= new JPanel();
		panelQuery.setLayout(new FlowLayout());
		panelSelection= new JPanel();
		panelSelection.setLayout(new FlowLayout());
		panelSelection.add(combo);
		panelSelection.add(documentId);		
		panelSelection.add(goQuery);

		panelGrid= new JPanel();
		panelGrid.setLayout(new FlowLayout());
		panelGrid.add(queryGrid);
		gridScrollpane = new JScrollPane(panelGrid);
		panelActionCommand= new JPanel();
		panelActionCommand.setLayout(new FlowLayout());

		panelQuery.add(panelSelection);
		panelQuery.add(gridScrollpane);
		panelQuery.add(panelActionCommand);

		tabbedPane.addTab(TAB_TITLE[0], panelPassword);
		tabbedPane.addTab(TAB_TITLE[1], panelHalted);
		tabbedPane.addTab(TAB_TITLE[2], getQueryView().getContentPane());
		frame.setContentPane(tabbedPane);
		frame.setVisible(true);
		frame.setSize(d);
	}

	public boolean enableRole(String role) {
		if (role != null && role .equalsIgnoreCase(SYST_ADMIN_ROLE)) {
			changePass.setEnabled(true);
			unlock.setEnabled(true);
			lock.setEnabled(true);
			findHHU.setEnabled(true);
			findPass.setEnabled(true);

		}
		if (role != null && role .equalsIgnoreCase(HELP_DESK_ROLE)) {
			findHHU.setEnabled(true);
			findPass.setEnabled(true);

		}
		return false;
		
	}

	public static void main (String a[]) {
		final String wd= (a != null && a.length> 0)?a[0]:Loader5Commander.DEFAULT_WORKING_DIRECTORY;
	    javax.swing.SwingUtilities.invokeLater(
	    	new Runnable() {
	    		public void run() {
	    			new MainFrame(wd);
	    		}
	    	}
	    );		
	}

	public Component getFrame () {
		return frame;
	}

	public boolean passwordDialog(String uState) {
		String feedback= "";
		Icon icon = null;
		boolean value =false;
		log.info("in");
		if (uState != null && uState.equalsIgnoreCase(MainFrame.OPEN_TITLE)) {
			feedback = (String)JOptionPane.showInputDialog(
                    frame,
                    Control.CHANGE_PASS_SENTENCE + getHHUName(null),
                    "Confirmation Dialog",
                    JOptionPane.PLAIN_MESSAGE,
                    icon,
                    null,
                    getHHUName(null)
            );
			value= true;
		}
		log.info(feedback +".");
		return value;
		
	}

	public void setTextAreaValue (String value) {
		String cleanValue = "";
		if (value == null || value.length() < 1) {
			cleanValue = "<EMPTY/>";
		} else {
			cleanValue = value.trim();
			cleanValue = cleanValue .replaceAll("\t", "");
		}
		textAreaPass.setText(cleanValue);
		
	}

	public void appendTextAreaValue (String value) {
		String cleanValue = "";
		if (value == null || value.length() < 1) {
			cleanValue = "<EMPTY/>";
		} else {
			cleanValue = value.trim();
			cleanValue = cleanValue .replaceAll("\t", "");
		}

		if (textAreaPass == null) {
			log.info(value);
		} else {
			textAreaPass.append(cleanValue+ "\n");			
		}

	}

	public void appendOtherTextAreaValue (String value) {
		String cleanValue = "";
		if (value == null || value.length() < 1) {
			cleanValue = "<EMPTY/>";
		} else {
			cleanValue = value.trim();
			cleanValue = cleanValue .replaceAll("\t", "");
		}
		if (textAreaHH == null) {
			log.info(value);
		} else {
			textAreaHH.append(cleanValue+ "\n");			
		}
		
		
	}

	public String getHHUName (String value) {
		return handHeldUserPassword.getText();
		
	}
	public String getHangedUName (String value) {
		return handHeldUserHalted.getText();
		
	}
	
	public QueryView getQueryView() {
		return queryTab;
	}

	public void setQueryView(QueryView queryTab) {
		this.queryTab = queryTab;
	}

	class WindowsHandler implements WindowListener {
		
		MainFrame main;
		public WindowsHandler(MainFrame frame) {
			main = frame;
			
		} 
		@Override
		public void windowActivated(WindowEvent arg0) {
			// TODO Auto-generated method stub
			
		}

		@Override
		public void windowClosed(WindowEvent arg0) {
			
			
		}

		@Override
		public void windowClosing(WindowEvent arg0) {
			main.bye();
			
		}

		@Override
		public void windowDeactivated(WindowEvent arg0) {
			// TODO Auto-generated method stub
			
		}

		@Override
		public void windowDeiconified(WindowEvent arg0) {
			// TODO Auto-generated method stub
			
		}

		@Override
		public void windowIconified(WindowEvent arg0) {
			// TODO Auto-generated method stub
			
		}

		@Override
		public void windowOpened(WindowEvent arg0) {
			// TODO Auto-generated method stub
			
		}
		
	}

}
