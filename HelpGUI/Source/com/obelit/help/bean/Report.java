package com.obelit.help.bean;

public class Report {
	private Object data[][];
	private String columnName[];
	public Object[][] getData() {
		return data;
	}
	public void setData(Object data[][]) {
		this.data = data;
	}
	public String[] getColumnName() {
		return columnName;
	}
	public void setColumnName(String columnName[]) {
		this.columnName = columnName;
	}

}
