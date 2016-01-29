package com.obelit.input;

import javax.jws.WebMethod;
import javax.jws.WebService;

import org.jboss.logging.Logger;


@WebService(name = "Port", targetNamespace = "http://localhost/wsdl",endpointInterface = "com.obelit.input.Port")
public class PortImpl implements Port {
	Logger log =Logger.getLogger(PortImpl.class.getName());

	@Override
	@WebMethod
	public void receiveProduct(String message) {
		log.info(message);

	}

}
