package com.obelit.util;

public class StateBox {

	private String previousState ;
	private String currentState ;
	private String nextState ;
	private String state;
	public static final String ATTEND_STATUS="ATTEND";
	public static final String READY_STATUS="READY";
	public static final String INITIAL_STATUS="RESET";
	public void reset() {
		currentState = INITIAL_STATUS;
	}

	public String getPreviousState() {
		return previousState;
	}
	public void setPreviousState(String previousState) {
		this.previousState = previousState;
	}
	public String getCurrentState() {
		return currentState;
	}
	public void setCurrentState(String currentState) {
		this.currentState = currentState;
	}
	public String getNextState() {
		return nextState;
	}
	public void setNextState(String nextState) {
		this.nextState = nextState;
	}
	public String getState() {
		return state;
	}
	public void setState(String state) {
		this.state = state;
		setCurrentState(state);
	}

}
