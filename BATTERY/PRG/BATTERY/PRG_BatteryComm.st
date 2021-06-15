(*
 * This program instantiates the Corvus Orca communication function block and gathers write-commands from other programs.
 * Made by: YS
 * Last changed: 2018-09-18
*)
PROGRAM PRG_BatteryComm

VAR
	mb_BMS_arrayData: 	ARRAY [1..16] OF str_Corvus_Array; 		(*Almighty array containing all information about PV and alarms for analog input signals*)
	mb_BMS_packData: 	ARRAY [1..16] OF str_Corvus_packData;	(*Almighty array containing all information about PV and alarms for analog input signals*)
	mb_BMS_packFW: 		ARRAY [1..16] OF str_Corvus_packFW; 	(*Almighty array containing all information about PV and alarms for analog input signals*)
    CorvusRead: 		ARRAY [1..16] OF str_Corvus_ALL; 		(*The almighty Corvus BMS Array-Array*)
	CorvusWrite: 		ARRAY [1..16] OF str_Corvus_Write;		(*Command Register Array to Corvus pack controllers*)
	
	CorvusModbusFault_TON: 				TON;							(*Timer to declare modbus communication fault*)
	Modbus_Wait:						BOOL;							(*Start to wait before restarting modbus fault checking*)
	Modbus_WaitRT:						R_TRIG;							(*Puls detection to start timer*)
	Modbus_WaitTryFT:					F_TRIG;							(*Puls detection that timer has ended*)
	ModbusFault_WaitTry_TP:				TP;								(*Timer to wait before restarting check of array*)
	CorvusBMS_Total_Comm_Fault_SR:		SR;								(*The Total Modbus Fault must be latched unntil we know it is healthy again*)
	CorvusBMS_Reset_Total_Comm_Fault_TON:TON;							(*Wait this long before declaring that communication is OK again*)
	NoPrechargePackComm: 				BOOL; 							(*Alarm when there is modbus fault on all packs which can start/stop*)
	n: 									INT := 0; 						(*Looping variable for reset function*)
	i: 									INT; 							(*Looping variable for checking comm fault across packs*)
	M : 								INT:=1; 						(*Pack number for current Array Master: The pack that array information is gathered from*)
	P : 								INT:=1; 						(*Pack number for current Array Precharge Master: The pack that can initiate start/connect requests*)
	Corvus_Array : 						fb_CorvusOrcaComm; 				(*All corvus data*)
	WriteCommands : 					ARRAY[1..16] OF str_Corvus_Write; (*Command Register Array to Corvus pack controllers*)
	
	(*Commands read from other programs*)
	Reset : 							BOOL; 							(*Reset command for battery packs*)
	CorvusBMS_Total_Comm_Fault_TON : 	TON;
	CorvusBMS_Total_Comm_Fault: 		BOOL; 							(*No communication with any Corvus batteries :( *)
	
	(*Variables to HMI*)
	setup_AlarmDelay_Modbus : 			TIME:=T#5s;		(*Delay before issuing total comm failure alarm*)
END_VAR

Reset := PRG_Functions.Reset;




(* 
 * ======================================================================================================================================= 
 * Communication with Corvus Orca Battery Management
 * =======================================================================================================================================
*)
Corvus_Array(
 	First_Card_ID:=PRG_HMI.setup_Battery_First_Card_Nr, 
 	Number_of_packs_in_array:=PRG_HMI.setup_Battery_total_nr_of_packs , 
 	corvusWrite := WriteCommands,
 	Reset := Reset,
 	output => CorvusRead
);

(* 
 * ======================================================================================================================================= 
 * Find Array Master (M) - This is the array we use most data from
 * =======================================================================================================================================
*)

IF CorvusRead[M].ModbusFault AND CorvusRead[1].ModbusFault AND  M<= PRG_HMI.setup_Battery_total_nr_of_packs AND NOT ModbusFault_WaitTry_TP.Q  THEN
	(*If current array master and pack 1 has comm fault, try next one as long as we still have more packs in the array to try*)
	M := M+1;
	Modbus_Wait := FALSE;
ELSIF M > PRG_HMI.setup_Battery_total_nr_of_packs OR NOT CorvusRead[1].ModbusFault THEN
	(*If array 1 is ok *OR* there are no more arrays to try - go for number 1*)
	M := 1;
	Modbus_Wait := TRUE;	(*After running through all arrays, wait before restarting so that CorvusBMS_Total_Comm_Fault_TON can detect that we have no-one to talk to*)
END_IF

Modbus_WaitRT(CLK := Modbus_Wait); (*Create an R_trig to start the TP*) 
ModbusFault_WaitTry_TP(				(*When we have tested all arrays and found no-one to communicate with, take a pause before re-starting so that we can detect the comm fault*)
		IN := Modbus_WaitRT.Q,
		PT := setup_AlarmDelay_Modbus + INT_TO_TIME(1000) (*Make sure that the re-try delay is longer than the alarm delay. 1000 = 1 s *)
	);
Modbus_WaitTryFT(CLK := ModbusFault_WaitTry_TP.Q); (*Detect when the pause is finished so that the pause-command can be turned off*)

IF(Modbus_WaitTryFT.Q OR NOT CorvusRead[M].ModbusFault) THEN
	Modbus_Wait := FALSE;
END_IF


(*No success in finding an Array master without communication fault - issue alarm*)
CorvusBMS_Total_Comm_Fault_TON(
	IN := CorvusRead[M].ModbusFault,
	PT := setup_AlarmDelay_Modbus
);

(*Make sure that the re-established communication is stable before clearing the alarm*)
CorvusBMS_Reset_Total_Comm_Fault_TON(
	IN := NOT Modbus_Wait,
	PT := setup_AlarmDelay_Modbus + INT_TO_TIME(2000), (*The "stable time" must be longer than the pause between retry-attemps*)
	Q => ,
	ET => 
);

(*Latch the modbus fault and reset it when communication has been restored for a time*)
CorvusBMS_Total_Comm_Fault_SR(
	SET1 := CorvusBMS_Total_Comm_Fault_TON.Q,
	RESET := CorvusBMS_Reset_Total_Comm_Fault_TON.Q OR PRG_Functions.Reset,
	Q1 => CorvusBMS_Total_Comm_Fault
);





(* 
 * ======================================================================================================================================= 
 * Find Array Precharge Master (P) - This is the array we send start commands to
 * =======================================================================================================================================
*)

IF NOT CorvusRead[setup_Battery_PrechargePackA].ModbusFault THEN
	(*If pack A is home sick but pack B is ok - it's all good*)
	P := setup_Battery_PrechargePackA;
	NoPrechargePackComm := FALSE;
ELSE
	NoPrechargePackComm := TRUE;
END_IF
	



(* 
 * ======================================================================================================================================= 
 * Write Commands
 * =======================================================================================================================================
*)

(*Connect Commands*)
WriteCommands[M].connectPack1to8 := PRG_Battery.ConnectPack1to8;

(*Power Save Commands*)
IF (PRG_Battery.EnterPowerSaveModeTP.Q) THEN
	WriteCommands[M].systemPowerSaveControl := 2;
ELSIF (PRG_Battery.ExitPowerSaveModeTP.Q) THEN
	WriteCommands[M].systemPowerSaveControl := 3;
ELSE
	WriteCommands[M].systemPowerSaveControl := 0;
END_IF

(* Reset all pack controllers *)
IF (Reset AND CorvusRead[M].theArray.nrOfPackFault > 0) THEN
	FOR n := 1 TO PRG_HMI.setup_Battery_total_nr_of_packs BY 1 DO
		WriteCommands[n].systemAlarmReset := 1;
	END_FOR 
	n := 1;
ELSIF(Reset AND CorvusRead[M].theArray.nrOfPackFault = 0) THEN
	FOR n := 1 TO PRG_HMI.setup_Battery_total_nr_of_packs BY 1 DO
		WriteCommands[n].systemAlarmReset := 0;
	END_FOR 
	n := 1;
ELSIF(NOT Reset) THEN
	FOR n := 1 TO PRG_HMI.setup_Battery_total_nr_of_packs BY 1 DO
		WriteCommands[n].systemAlarmReset := 0;
	END_FOR 
	n := 1;
END_IF


;
END_PROGRAM

ACTIONS

END_ACTIONS