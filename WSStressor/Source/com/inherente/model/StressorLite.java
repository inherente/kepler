package com.inherente.model;

import com.pool.SimpleConnection;

public class StressorLite {

	SimpleConnection pool;
	public StressorLite() {
		init();
	}
	private void init () {
		pool = new SimpleConnection ( ".properties", null);
		

	}

}
