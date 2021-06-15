PROGRAM PRG_StateMain
VAR

	LedBlink: 			BOOL;				(*Blinking boolean for lamps etc*)
	RunningOutput: 		BOOL;				(*Running status indication to other vendors. Does not blink.*)
	RunningLamp: 		BOOL;				(*Running status indication to own lamps - may blink*)
	StoppedOutput: 		BOOL;				(*Stopped status indication to other vendors. Does not blink.*)
	StoppedLamp: 		BOOL;				(*Stopped status indication to own lamps - may blink*)
	
	appError: 			BOOL;				(*Something is very wrong with the statemachine's CASE block*)
	LedBlinker:			fb_ClockPulse;		(*Pulse block for led blinking*)
	RunningTON:			TON;				(*10s delayed running state*)
	initializingDone: 	BOOL;
	
	(*State*)	
	State:				enum_State;
	StateStarting:		enum_StateStarting;
	
	(*SW*)
	tripStatus:			DINT;				(*Bits used to trip converter and disconnect batteries*)
	
	(*Timeouts*)
	StartingTON: 					TON;	(*Start timeout timer*)
	StoppingTON: 					TON;	(*Stop timeout timer*)
	BatteryConnectionTON : 			TON;	(*Timeout connect batteries*)
	BatteryDisconnectionTON : 		TON;	(*Timeout disconnect batteries*)
	StartingSR:						SR;		(*SR to latch a start timeout*)
	StoppingSR:						SR;		(*SR to latch a stop timeout*)
	StartInhibit: 					INT;	(*Bits used to prevent start signal*)
	StartingTimeout:				BOOL;	(*Flag activated when starting has lasted too long before entering running state*)
	StoppingTimeout:				BOOL;	(*Flag activated when stopping has lasted too long before entering stopped state*)
	BatteryConnectionTimeout:		BOOL;	(*Flag activating when batteries fails to connect during starting sequence*)		
	BatteryDisconnectionTimeout:	BOOL;	(*Flag activating when batteries fails to disconnect during stopping sequence*)		
	
	(*Statedata CW*)
	StartDrive: 		BOOL;	(*Start command to Drive*)
	StopDrive: 			BOOL;	(*Stop command to Drive*)
	ConnectBattery: 	BOOL;	(*Connect batteries*)
	DisconnectBattery:	BOOL;	(*Disconnect batteries*)
	CloseAcBreaker:		BOOL;	(*Close AC Breaker, including synch check*)
	OpenAcBreaker: 		BOOL;	(*Open AC Breaker*)
	
	(*State R_trig and F_trig*)
	InitRT : 		R_TRIG;
	InitFT : 		F_TRIG;
	StoppedRT: 		R_TRIG;
	StoppedFT : 	F_TRIG;
	StartingRT: 	R_TRIG;
	StartingFT : 	F_TRIG;
	RunningRT:		R_TRIG;
	RunningFT:		R_TRIG;
	StoppingRT:		R_TRIG;
	StoppingFT:		F_TRIG;
		
END_VAR

(* 
 * ======================================================================================================================================= 
 * State Machine
 * =======================================================================================================================================
*)

CASE State OF
(*--------------------------------------------------------------------------------------*)
	e_Init:
		StoppedLamp := LedBlink;
		RunningLamp := LedBlink;
		initializingDone:= NOT PRG_Drive.Status.Commfault AND (PRG_BatteryProtection.ConfigError = 0);
		IF(initializingDone)THEN
			State := e_Stopped;
		ELSE
			State := e_Init;
		END_IF
(*--------------------------------------------------------------------------------------*)
	e_Stopped:
		StoppedLamp := TRUE;
		StoppedOutput := TRUE;
		RunningLamp := FALSE;
		RunningOutput := FALSE;
	
		IF(PRG_Operation.ControlPlace.Start AND (StartInhibit = 0)) THEN 
			State := e_Starting; 
		ELSE
			State := e_Stopped;
		END_IF
		(*Reset Stop Commands*)
		StopDrive := FALSE;
		StartDrive := FALSE;
		DisconnectBattery:= TRUE;
		ConnectBattery:= FALSE;
(*--------------------------------------------------------------------------------------*)
	e_Starting:
		StoppedLamp := FALSE;
		StoppedOutput := FALSE;
		RunningLamp := LedBlink;
		RunningOutput := FALSE;
		DisconnectBattery:= FALSE;
		
		(*------------------------------------Startup sequence-------------------------------------------*)
		IF ( tripStatus <> 0 OR PRG_Operation.ControlPlace.Stop OR StartingTimeout)THEN
			State := e_Stopping;
			StateStarting := e_startInit;
		ELSE
			CASE StateStarting OF
				e_startInit:
					StartDrive := FALSE;
					IF(PRG_Drive.Status.ReadyRun AND PRG_Battery.BatteryAllConnected)THEN
						StateStarting := e_startDrive;
					ELSIF(PRG_Battery.BatteryReadyConnect AND NOT PRG_HMI.TestStartingTimeout)THEN
						StateStarting := e_startBatPrecharge;
					ELSE
						StateStarting := e_startInit;
					END_IF
					
				e_startBatPrecharge:
					ConnectBattery:= TRUE;
					IF(PRG_Battery.BatteryMinOneConnected) THEN
						StateStarting := e_startDrive;
					ELSE
						StateStarting := e_startBatPrecharge;
					END_IF
		
				e_startDrive:
					StopDrive := FALSE;
					StartDrive := TRUE;
					IF(PRG_Drive.Status.Running)THEN
						StateStarting := e_startingDone;
					ELSE
						StateStarting := e_startDrive;
					END_IF
		
				e_startingDone:
					State := e_Running; (*Set main state machine to running*)
					StateStarting := e_startInit;
		
				e_startingFailed:
					StateStarting := e_startInit;
					State := e_Stopping;
			END_CASE
		END_IF
(*--------------------------------------------------------------------------------------*)
	e_Running:
		StoppedLamp := FALSE;
		StoppedOutput := FALSE;
		RunningLamp := TRUE;
		RunningOutput := TRUE;
			
		IF PRG_Operation.ControlPlace.Stop OR tripStatus <> 0 THEN
			State := e_Stopping;
		ELSE
			State := e_Running;
		END_IF
(*--------------------------------------------------------------------------------------*)
	e_Stopping:
		StoppedLamp := LedBlink;
		StoppedOutput := FALSE;
		RunningLamp := FALSE;
		RunningOutput := FALSE;
		
		(*Stop all devices from running*)
		IF (tripStatus <> 0) THEN (*Stopping the fast way*)
			DisconnectBattery:=TRUE;
			ConnectBattery:= FALSE;
			
			StopDrive := TRUE;
			StartDrive := FALSE;
			
		ELSE (*Stopping with deloading*)
			IF (PRG_Drive.Data.SourcePower_pu[1] < (PRG_HMI.Setup_StopWithRampMaxLoad_pc/100)) THEN		
				DisconnectBattery:=TRUE;
				ConnectBattery:= FALSE;
				
				StopDrive := TRUE;
				StartDrive := FALSE;
				
			END_IF
		END_IF
			
		(*Conditions required to complete stop sequence*)
		IF(NOT PRG_Drive.Status.Running AND PRG_Battery.BatteryDisconnected AND NOT PRG_HMI.TestStoppingTimeout OR StoppingTimeout) THEN
			State := e_Stopped;
		ELSE
			State := e_Stopping;
		END_IF
(*--------------------------------------------------------------------------------------*)
ELSE
	appError:= TRUE;
END_CASE



(* 
 * ======================================================================================================================================= 
 * Start Inhibits
 * =======================================================================================================================================
*)

StartInhibit.0 := tripStatus <> 0; (*No active trips*)
StartInhibit.1 := NOT PRG_Drive.Status.ReadyOn; (*DCDC Drive is ready*)
StartInhibit.2 := NOT PRG_Drive.Status.Remote; (*DCDC Drive is in Fieldbus Control Mode*) 
StartInhibit.3 := NOT PRG_Battery.BatteryReadyConnect; (*Battery pack with precharge module not ready*)
StartInhibit.4 := NOT (PRG_Functions.Breaker.DI_Verif_delay);	(*DC breaker must be closed*)
StartInhibit.5 := NOT PRG_DI.di_DcBreakerEarlyBreak.PV;	(*DC breaker "early break" contact must be cleared*)
StartInhibit.6 := ((PRG_Drive.Data.DcLinkVoltage_eng < PRG_HMI.MinStartVoltageDcLink) AND NOT PRG_HMI.OverrideStartVoltageDcLink) ; (*If no voltage on DC link, do not start the batteries*)

(* 
 * ======================================================================================================================================= 
 * Trip Signals
 * =======================================================================================================================================
*)
tripStatus.0 := NOT PRG_DI.di_LocalEmergencyStop.PV;
tripStatus.1 := PRG_Drive.Status.Fault;
tripStatus.2 := PRG_Drive.Status.Commfault;
tripStatus.3 := NOT PRG_DI.di_FusesOK.PV;
tripStatus.4 := NOT PRG_DI.di_DcBreakerEarlyBreak.PV;
tripStatus.6 := PRG_BatteryProtection.ProtectionTrip <> 0;
tripStatus.7 := PRG_BatteryProtection.batteryCommonFault;
tripStatus.8 := PRG_Faults.Repeat_Fault.Alarm_count <> 0;







(*------------------------------------LED-Blinker------------------------------------------------*)
LedBlinker(
	Half_Periode:= T#333ms, 
	CLK_Pulse=> LedBlink
);

(*------------------------------------Startup timeout--------------------------------------------*)
StartingTON(
	IN:=(State = e_Starting) , 
	PT:=REAL_TO_TIME(PRG_HMI.Delay_StartingTimeOut*1000)
);

StartingSR(
	SET1:=StartingTON.Q , 
	RESET:=PRG_Functions.Reset , 
	Q1=>StartingTimeout
);


(*-------------------------Battery Connect/Disconnect timeout timeout-----------------------------*)

BatteryConnectionTON(
	IN := (StateStarting = e_startBatPrecharge) AND NOT PRG_Battery.BatteryMinOneConnected,
	PT := T#10s,
	Q => BatteryConnectionTimeout,
	ET => 
);

BatteryDisconnectionTON(
	IN := DisconnectBattery AND NOT PRG_Battery.BatteryDisconnected,
	PT := T#10s,
	Q => BatteryDisconnectionTimeout,
	ET => 
);

(*------------------------------------Stopping timeout--------------------------------------------*)
StoppingTON(
	IN:=(State = e_Stopping) , 
	PT:= REAL_TO_TIME(PRG_HMI.Delay_StoppingTimeOut*1000)
);

StoppingSR(
	SET1:=StoppingTON.Q , 
	RESET:=PRG_Functions.Reset , 
	Q1=>StoppingTimeout
);

IF (StoppingSR.Q1) THEN
	State := e_Stopped;
END_IF


(*----------------------------------------Running delayed----------------------------------------*)

RunningTON(
	IN := (PRG_StateMain.State = e_Running),
	PT := T#10s);

RestoreAllToDefault:=FALSE; (*Prevent that this is left true*)

END_PROGRAM