package com.obelit.input;

import javax.jws.WebService;

@WebService
public interface Port {
	public void receiveProduct(String message) ;
}
