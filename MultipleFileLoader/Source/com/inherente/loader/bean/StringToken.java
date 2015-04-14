package com.inherente.loader.bean;

import java.util.logging.Logger;// import java.util.StringTokenizer;

public class StringToken {
	private String name;
	private int lenght;
	private int location;
	public static final String PARTNER_ID_FIELD_LABEL= "CurrentPartnerId";
	public static final String PARTNER_NAME_FIELD_LABEL= "CurrentPartnerName";
	static Logger log = Logger.getLogger(StringToken.class.getName());

	public StringToken (String name) {
		this(name, 0, 0);
	}

	public StringToken (String name, int lenght, int location) {
		log.info("name = "+ name+ " lenght = "+ lenght + " location = "+ location);
		setName(name);
		setLenght(lenght);
		setLocation(location);
	}

	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public int getLenght() {
		return lenght;
	}
	public void setLenght(int lenght) {
		this.lenght = lenght;
	}
	public int getLocation() {
		return location;
	}
	public void setLocation(int location) {
		this.location = location;
	}

	public static void main (String[] argument) {
		StringToken.parseMainArgument(argument);		
	}

	public static StringToken[] parseMainArgument (String[] argument) {
		StringToken[] returnValue= null;
		String name;
		String next;
		int lenght;// int location;
		int tokenAmount = 0;// StringTokenizer tokenizer = new StringTokenizer (argument);

		log.info("in");
		if (argument != null && (tokenAmount = argument.length) > 1) {
			returnValue= new StringToken[tokenAmount-1];
		}
		for (int i= 1; i < tokenAmount; i++) {
			next=argument[i]; // log.info("argument [ "+i +"] "+ next);
			name= next.substring(0, next.indexOf(":"));
			lenght=Integer.parseInt( next.substring( next.indexOf(":")+ 1, next.length()) );
			returnValue[i -1]= new StringToken(name, lenght, i);
		}
		return returnValue; 
	} 

}
