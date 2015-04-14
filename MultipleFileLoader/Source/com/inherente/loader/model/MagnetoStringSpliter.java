package com.inherente.loader.model;
import java.nio.channels.FileChannel;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FilenameFilter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.util.ArrayList;
import java.util.Hashtable;
import java.util.List;
import java.util.StringTokenizer;
import java.io.FileInputStream;
import java.util.logging.Logger;

import com.inherente.loader.bean.StringToken;

public class MagnetoStringSpliter {
	final static String DEFAULT_FILENAME = "C:\\Users\\GUTIERREZLE\\Development\\workSpace\\TaO\\CControl\\documentoVacio.txt";
	final static String CONTROL_FILENAME = "\\Stock.ready.doc";
	final static String LOADER_POSTFIX = ".ldr"; 
	final static String[] LINE_TO_BE_IGNORED = {"Campo", "Centro", "Consigna","Embalajes", "Layout", "Cliente", "Ce."};
	File io;
	FileInputStream input ;
	BufferedReader reader;
	FileOutputStream output ;
	BufferedWriter writer;
	List<Hashtable<String, String>> fullContent;
	private StringToken[] model;
	private StringToken[] outPutModel;
	private String currentPartnerId;
	private String currentPartnerName;
	private String outputFileName;
	private String controlFileName;
	private String inputFileName;
	private String workingDirectory;
	FilenameFilter filter;
	static Logger log = Logger.getLogger(MagnetoStringSpliter.class.getName());

	public static void mani (String[] argument) {
		MagnetoStringSpliter.createControlFileName(DEFAULT_FILENAME);
	}

	public static void main (String[] argument) {
		MagnetoStringSpliter magneto;

		magneto= new MagnetoStringSpliter(argument[0]);
		magneto.setModel(StringToken.parseMainArgument(argument));
		magneto.setOutPutModel(magneto.createOutPutModel(magneto.getModel()));
		magneto.process();
	}

	public void processSingleFile () {
		processTextFile();
		outPutTextFile();
		copyTextFile();
		
	}

	public void process () {
		File[] listOfFiles;
		File folder = null;
		File currentOutputFile;

		folder= new File (getWorkingDirectory());
		listOfFiles = folder.listFiles(filter);
		log.info("¿File Folder? = " +folder.isDirectory());
		log.info("process("+ getWorkingDirectory() +") " + listOfFiles.length + " file(s)");
		try {
			for (File currentFile: listOfFiles ) {
				if (input == null); else input.close(); // Free Stream
				clrearContent();
				log.info("process( "+ currentFile.getName()+ ")");
				input = new FileInputStream(currentFile);
				reader = new BufferedReader (new InputStreamReader (input));
				setOutputFileName(createOutputFileName(currentFile.getName()));
				processTextFile(reader );
				currentOutputFile = new File(getOutputFileName());
				if (output == null); else output.close();// Free Stream
				output = new FileOutputStream(currentOutputFile);
				writer = new BufferedWriter (new OutputStreamWriter (output));
				outPutTextFile(writer );
				copyTextFile();

			}
			
		} catch (Exception err) {
			log.info(err.toString());
			
		}
				
	}

	public MagnetoStringSpliter () {
		this(DEFAULT_FILENAME);
	}

	public MagnetoStringSpliter (String fileName) {
		log.info(fileName);
		File oi; 

		setInputFileName(fileName);
		io = new File(fileName);
		filter = new FilenameFilter() {
			public boolean accept(File dir, String name) {
				boolean returnValue= false;
				if (name.indexOf("(ANSI).txt")> 0)
					returnValue= true;
				else returnValue= false;
				return returnValue;
			}
			
		};

		try {
			input = new FileInputStream(io);
			reader = new BufferedReader (new InputStreamReader (input));
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		setOutputFileName(createOutputFileName(fileName));
		setControlFileName(createControlFileName(fileName));
		setWorkingDirectory(System.getProperty("user.dir"));// extractWorkingDirectory(fileName)
		oi = new File(getOutputFileName());
		try {
			output = new FileOutputStream(oi);
			writer = new BufferedWriter (new OutputStreamWriter (output));
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}

	public static String createOutputFileName(String name) {
		String output= DEFAULT_FILENAME;
		String actualExt = "txt";
		String firstPart = "C:";
		if (name != null && name.length() > 1) {
			actualExt= name.substring(name.lastIndexOf("."), name.length());
			firstPart = name.substring(0, name.indexOf(actualExt));// log.info(firstPart );
		}
		output= firstPart+ LOADER_POSTFIX +actualExt ;
		log.info(output);
		return output;
		
	}
	
	public static String extractWorkingDirectory(String name) {

		String firstPart = "C:";
		if (name != null && name.length() > 1) {

			firstPart = name.substring(0, name.lastIndexOf("\\"));// log.info(firstPart );
		}

		log.info(firstPart);
		return firstPart;
		
	}

	public static String createControlFileName(String name) {
		String output= DEFAULT_FILENAME;
		String firstPart = "C:";
		if (name != null && name.length() > 1) {

			firstPart = name.substring(0, name.lastIndexOf("\\"));// log.info(firstPart );
		}
		output= firstPart+ CONTROL_FILENAME;
		log.info(output);
		return output;
		
	}

	void addLine (Hashtable<String, String> arg0) {
		if(fullContent == null)
			fullContent= new ArrayList<Hashtable<String, String>>();
		fullContent.add(arg0);// log.info(arg0.toString());
		
	}
	void clrearContent() {
		fullContent = null;
	}

	Hashtable<String, String> getNextLine () {
		Hashtable<String, String> current = null;
		if(fullContent == null || fullContent.size() < 1)
			current = null;
		else current =fullContent.remove(0);
		return current ;
		
	}

	public boolean findHeader (String line) {
		boolean found= false;
		String firstElement;
		StringTokenizer token;

		token= new StringTokenizer (line);
		firstElement= token.nextToken();
		try {
			Integer.parseInt(firstElement);
			found = true;
			setCurrentPartnerId(firstElement);
			setCurrentPartnerName(line.substring(firstElement.length(), line.length() ));

		} catch (Exception exc) {
			found = false;
			
		}
		log.info("found " + found);
		return found;
		
	}

	public boolean isUndefinedLine (String line) {
		boolean found= false;
		String firstElement;
		StringTokenizer token;

		token= new StringTokenizer (line);
		firstElement= token.nextToken();
		for (String val: LINE_TO_BE_IGNORED) {
			if(val != null && firstElement.startsWith(val)) {
				found= true;
				break;
			} else {
				continue;
			}
			
		}
		log.info("ignore " + found);
		return found;
		
	}

	public void copyTextFile() {
		copyTextFile(getOutputFileName());
	}

	public void copyTextFile(String fromFileName) {
		FileChannel inChannel = null;
		FileChannel outChannel = null;
		FileInputStream in = null;
		FileOutputStream out= null;
		long bytesTransferred = 0;
		try {
			try {
				in = new FileInputStream(new File(fromFileName));
				out= new FileOutputStream(new File(getControlFileName()), true);
				inChannel= in.getChannel();
				outChannel = out.getChannel();
				log.info("coping to "+ getControlFileName());
			 // defensive loop - there's usually only a single iteration :
				while(bytesTransferred < inChannel.size()){
					bytesTransferred += inChannel.transferTo(0, inChannel.size(), outChannel);
				}
				log.info("copied to "+ getControlFileName());
			} finally {
				in.close();
				out.close();
				inChannel.close();
				outChannel.close();
			}
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}


	}

	public void processTextFile() {
		processTextFile(null);
	}

	public void processTextFile(BufferedReader rr) {
		if (rr == null )rr= reader;
		String line= "";
		try {
			while (rr!= null && (line= rr.readLine() ) != null ) {
				line= line.replaceAll("[\\t]", "");
				log.info(line+ " ."+ line.length());
				if(line == null || line.length() <= 1 +1) continue; // ignore line with no data
				if(isUndefinedLine(line)) continue;// ignore header line(s)
				if (findHeader(line)); else
				addLine(processTextLine(line));

			}
			rr.close();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}

	public void outPutTextFile() {
		outPutTextFile(null);// getOutputFileName()
		
	}

	public void outPutTextFile(BufferedWriter wrr) {
		String line= "";
		int n =0;
		StringToken currentModel= null;
		String currentValue;
		Hashtable<String, String> current;
		if (wrr == null ) wrr= writer;

		try {
			while ( (current= getNextLine() ) != null && current.size() > 1 ) {
				n++;
				line = "";
				for (int i =0 ; outPutModel != null && i < outPutModel.length; i++  ) {

					currentModel = outPutModel[i];
					currentValue = current.get(currentModel.getName());// replaceAll("[\\t ]", "");
				 //	log.info("Column Name "+ currentModel.getName()+ " & Length ="+ currentModel.getLenght()+ " Column Value "+ currentValue);
					line+= currentValue.trim() + (i==outPutModel.length-1?"":",") ;

				}
				log.info("["+ n + "]" + line);
				wrr.write(line+ "\n");
			}
			wrr.close();

		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	public Hashtable<String, String> processTextLine( String line) {
		int currentIndex = 0;
		Hashtable<String, String> row;
		StringToken currentModel= null;
		String currentValue;

		row = new Hashtable<String, String>();
		for (int i =0 ; model != null && i < model.length; i++  ) {
			currentModel = model[i];// log.info("Column Name "+ currentModel.getName()+ " & Length ="+ currentModel.getLenght() + " Config(" +currentIndex+"/" + currentModel.getLenght()+ ")");
			currentValue = line.substring(currentIndex, currentIndex+ currentModel.getLenght()- 1);// log.info("Column Value "+ currentValue );

			row.put(currentModel.getName(), currentValue.replaceAll(",", ""));
			currentIndex += currentModel.getLenght();
		}
		row.put(StringToken.PARTNER_ID_FIELD_LABEL, getCurrentPartnerId());
		row.put(StringToken.PARTNER_NAME_FIELD_LABEL, getCurrentPartnerName());
		return row;
	}

	StringToken[] createOutPutModel(StringToken[] input) {
		StringToken[] output;
		int inputLenght;
		if (input != null && (inputLenght= input.length )> 1) {
			output = new StringToken[inputLenght+ 1+ 1];
			output[0] = new StringToken(StringToken.PARTNER_ID_FIELD_LABEL);
			output[1] = new StringToken(StringToken.PARTNER_NAME_FIELD_LABEL);
			for (int i =0; i< inputLenght; i++) {
				output[i+ 1+ 1] = input[i];
			}

		} else {
			output= new StringToken[0];
		}
		return output;
		
	}

	public StringToken[] getModel() {
		return model;
	}

	public void setModel(StringToken[] model) {
		this.model = model;
	}

	public StringToken[] getOutPutModel() {
		return outPutModel;
	}

	public void setOutPutModel(StringToken[] outPutModel) {
		this.outPutModel = outPutModel;
	}

	public String getCurrentPartnerId() {
		return currentPartnerId;
	}

	public void setCurrentPartnerId(String currentPartnerId) {
		this.currentPartnerId = currentPartnerId;
	}

	public String getCurrentPartnerName() {
		return currentPartnerName;
	}

	public void setCurrentPartnerName(String currentPartnerName) {
		this.currentPartnerName = currentPartnerName;
		log.info(currentPartnerName);
	}

	public String getOutputFileName() {
		return outputFileName;
	}

	public void setOutputFileName(String outputFileName) {
		this.outputFileName = outputFileName;
	}

	public String getInputFileName() {
		return inputFileName;
	}

	public void setInputFileName(String inputFileName) {
		this.inputFileName = inputFileName;
	}

	public String getControlFileName() {
		return controlFileName;
	}

	public void setControlFileName(String controlFileName) {
		this.controlFileName = controlFileName;
	}

	public String getWorkingDirectory() {
		return workingDirectory;
	}

	public void setWorkingDirectory(String workingDirectory) {
		this.workingDirectory = workingDirectory;
	}

}
