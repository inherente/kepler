package com.obelit.help.view;

import java.awt.BorderLayout;
import java.awt.Component;
import java.awt.FlowLayout;
import java.awt.event.ActionListener;
import java.util.logging.Logger;

import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTabbedPane;
import javax.swing.JTable;
import javax.swing.JTextField;
import javax.swing.ScrollPaneConstants;
import javax.swing.table.AbstractTableModel;
import javax.swing.table.DefaultTableModel;


public class QueryView {
	public static final String [] CURRENT_DEFAULT_QRY= {"getInternalOrder"};
	public static final String QUERY_GO= "Go";
	public static final int INPUT_LENGTH= 15;
	ActionListener main;
	JPanel content= new JPanel();
	JPanel panelQuery= new JPanel();
	JPanel panelSelection;// JPanel panelGrid;
	JPanel panelActionCommand;
	JScrollPane gridScrollpane;
	JTable queryGrid;
	DefaultTableModel tableModel;
	JComboBox<String> combo;
	JButton goQuery;
	JTabbedPane tabbedPane;
	JTextField documentId;
	SimpleTableModel tm;
	BorderLayout gb;
	String[] catalog;
	Logger log= Logger.getLogger(QueryView.class.getName());

	public QueryView(ActionListener control) {
		this(control, null);

	} 

	public QueryView(ActionListener control, String function[] ) {
		main =control;
		gb = new BorderLayout ();
		catalog= function;
		init ();
	} 

	private void init () {

		combo= new JComboBox<String>(catalog==null?CURRENT_DEFAULT_QRY:catalog);
		combo.setEditable(false);
		goQuery= new JButton(QUERY_GO);
		goQuery.addActionListener(main);
		documentId = new JTextField(INPUT_LENGTH);
		tm= new SimpleTableModel();

		queryGrid = new JTable(
				new DefaultTableModel(
						new Object[][]{{"", "", "", "", "", "", "", "", "", ""} },
						new String[]{"0000000000", "0000000001", "0000000002", "0000000003", "0000000004", "0000000005", "0000000006", "0000000007", "0000000008", "0000000009"}
				)
		);

		content= new JPanel();
		content.setLayout(gb);
		panelSelection= new JPanel();
		panelSelection.setLayout(new FlowLayout());
		panelSelection.add(combo);
		panelSelection.add(documentId);		
		panelSelection.add(goQuery);

		gridScrollpane = new JScrollPane(queryGrid);
		queryGrid.setFillsViewportHeight(true);

		gridScrollpane.setVerticalScrollBarPolicy(ScrollPaneConstants.VERTICAL_SCROLLBAR_ALWAYS);
		gridScrollpane.setHorizontalScrollBarPolicy(ScrollPaneConstants.HORIZONTAL_SCROLLBAR_AS_NEEDED);
		panelActionCommand= new JPanel();
		panelActionCommand.setLayout(new FlowLayout());

		content.add(panelSelection,  BorderLayout.PAGE_START);
		content.add(gridScrollpane, BorderLayout.CENTER);
		content.add(panelActionCommand, BorderLayout.PAGE_END);

	}

	public Component getContentPane() {
		return this.content;
	}

	public String getText() {
		return documentId.getText();
	}
	public String getSelectedText() {
		return (String)combo.getSelectedItem();
	}

	public String setDataModel(Object[][] data, String[] columnName) {
		int deletedRow =0;
		int deletedCol =0;
		int addCol =0;
		int i;
	 	tableModel= (DefaultTableModel) queryGrid.getModel();
	 //	log.info(data.length + " & " + data[0].length);
	 //	tableModel= new DefaultTableModel(0, 0);
	 	log.info("Current "+ tableModel.getRowCount()+ " row(s) loaded.");
	 	for ( i =tableModel.getRowCount()- 1 ; i > -1 ; i--) {
	 		tableModel.removeRow(i);
	 		deletedRow++;
	 	}
	 	log.info("Currently loaded {" +tableModel.getColumnCount()+ "} Colmun(s) in model and {"+ columnName.length + "} new." );
	 	if ( tableModel != null && tableModel.getColumnCount() > columnName.length) {
		 	for (int y= tableModel.getColumnCount() ; columnName != null && y > columnName.length ; y--) {
		 		log.info("To remove column {"+ y +"}");
		 	 // Remove from Table	
		 		queryGrid.removeColumn(queryGrid.getColumnModel().getColumn(y-1));
		 	 //	queryGrid.getColumnModel().removeColumn(queryGrid.getColumnModel().getColumn(y-1));
		 		log.info("Set {"+ y +"} column Count");
		 	 	tableModel.setColumnCount(y-1);
		 	 //	tableModel.getColumnIdentifiers();
		 		deletedCol++;
		 	}
	 	}

	 	log.info("Removed {"+ deletedCol +"} Colmun(s)");
	 	if (deletedCol==0 && tableModel != null && tableModel.getColumnCount() < columnName.length) {
		 	for (int y= tableModel.getColumnCount() ; columnName != null && y < columnName.length ; y++) {
		 		log.info("To add column {"+ y +"}");
		 	 // Add to Table	
		 		log.info("Add {"+ columnName[y] +"} column");
		 	 	tableModel.addColumn(columnName[y]);
		 	 	tableModel.setColumnCount(y+1);
		 	 //	tableModel.getColumnIdentifiers();
		 		addCol++;
		 	}
	 	}

	 	tableModel.fireTableRowsDeleted(0, deletedRow);
	 	if (addCol> 0 || deletedCol >0) tableModel.fireTableStructureChanged();

	 	if ( data != null && data.length > 0) {
			for (int y =0 ; y< data.length; y++) {
			 //	log.info("-added ( "+ y + ") " + Integer.bitCount(y));
				tableModel.addRow(data[y]);// for(int x= 0; x< data[y].length; x++) {}
			 //	tableModel.fireTableRowsInserted(y, y);
			}
		}

	 // Set Name(s) for the column.	
	 	for (int n=0; columnName != null && n < columnName.length ; n++) {
	 		queryGrid.getColumnModel().getColumn(n).setHeaderValue(columnName[n]);

	 	}

	 //	tm.updateData(data);
	 //	queryGrid= new JTable (data, columnName);
	 //	queryGrid.setModel(tableModel);
		log.info("Query "+ queryGrid.getRowCount());
	 //	queryGrid = new JTable (data,new String[]{"", "", "", "", "", "", "", "", "", ""});
	 //	queryGrid.changeSelection(queryGrid.getRowCount() - 1, 0, false, false);
	 //	tableModel = (DefaultTableModel) queryGrid.getModel();	
	 	tableModel.fireTableDataChanged();
	 	queryGrid.getTableHeader().repaint();
		return documentId.getText();
	}

	@SuppressWarnings("serial")
	class SimpleTableModel extends AbstractTableModel {
    	Object rowData[][]; 

    	Object data[][] = { 
    		{ "Row1-Column1", "Row1-Column2", "Row1-Column3"},
            { "Row2-Column1", "Row2-Column2", "Row2-Column3"} 
    	};
    	String columnName[] = { "Column One", "Column Two", "Column Three"};

    	public SimpleTableModel ( ) {
    		this(null, null);    		    		
    	}

    	public SimpleTableModel (Object d[][], String[] column ) {
    		data= d;
    		columnName= column;    		    		
    	}
    	public void updateData(Object d[][]) {
    		data =d;
    		fireTableRowsInserted(data.length, data.length);
    		log.info("updated");
    		
    	}

		@Override
		public int getColumnCount() {
			int i= 0;
			if (columnName == null) {
				i= 0;
			} else {
				i = columnName.length;
			}
			return i ;
		}

		@Override
		public int getRowCount() {
			int i= 0;
			if (data == null) {
				i= 0;
			} else {
				i = data.length;
			}
			return i;
		}

		@Override
		public Object getValueAt(int row, int column) {
			String v= "<empty>";
			if (data != null && data[row] != null && data[row][column]!= null) {
				v= (String) data[row][column];				
			}
			return v;
		}
    	
    }
}
