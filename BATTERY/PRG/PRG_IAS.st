PROGRAM PRG_IAS
VAR

	Extended_Statemachine: UINT := 0; (*Extended state machine for IAS, containing prewarning and shutdown  *)
	
	(*Stuff used when testing IAS Interface*)
	IasInterfaceTest_TON : 	TON;	(*Timer to automatically reset interface testing*)
	IasInterfaceTest:		BOOL;	(*When true, all IAS communication is deactivated so that variables can be forced for testing purposes.*)
	IasInterfaceTestMinLeft: INT;	(*Minutes left of interface testing*)
	
	(*Take INTS and UINTS of bitwise data and copy them into arrays of bools so that HMI can read them more easily*)
	Array_STAT_OperationalMode : 		fb_IntToArray; (*Copy of INT with bits, but in "array of bool"-form*)
	Array_STAT_Breaker : 				fb_IntToArray; (*Copy of INT with bits, but in "array of bool"-form*)
	Array_STAT_Status :					fb_IntToArray; (*Copy of INT with bits, but in "array of bool"-form*)
	Array_STAT_CellBalancingStatus : 	fb_IntToArray; (*Copy of INT with bits, but in "array of bool"-form*)
	Array_STAT_CellsInBalance : 		fb_IntToArray; (*Copy of INT with bits, but in "array of bool"-form*)
	Array_STAT_ConnectionWord :			fb_IntToArray; (*Copy of INT with bits, but in "array of bool"-form*)
	Array_ALM_AlarmWord_1 :				fb_IntToArray; (*Copy of INT with bits, but in "array of bool"-form*)
	Array_ALM_AlarmWord_2 :				fb_IntToArray; (*Copy of INT with bits, but in "array of bool"-form*)
	Array_ALM_FaultWord_1 :				fb_IntToArray; (*Copy of INT with bits, but in "array of bool"-form*)
	Array_ALM_FaultWord_2 :				fb_IntToArray; (*Copy of INT with bits, but in "array of bool"-form*)
	
	hmi_STAT_OperationalMode : 		ARRAY[1..16] OF BOOL; (*Array representation of IAS_STAT_OperationalMode*)
	hmi_STAT_Breaker : 				ARRAY[1..16] OF BOOL; (*Array representation of IAS_STAT_Breaker*)
	hmi_STAT_Status : 				ARRAY[1..16] OF BOOL; (*Array representation of IAS_STAT_Status*)
	hmi_STAT_CellBalancingStatus : 	ARRAY[1..16] OF BOOL; (*Array representation of IAS_STAT_CellBalancingStatus*)
	hmi_STAT_CellsInBalance : 		ARRAY[1..16] OF BOOL; (*Array representation of IAS_STAT_CellsInBalance*)
	hmi_STAT_ConnectionWord : 		ARRAY[1..16] OF BOOL; (*Array representation of IAS_STAT_ConnectionWord*)
	hmi_ALM_AlarmWord1 : 			ARRAY[1..16] OF BOOL; (*Array representation of IAS_STAT_AlarmWord1*)
	hmi_ALM_AlarmWord2 : 			ARRAY[1..16] OF BOOL; (*Array representation of IAS_STAT_AlarmWord2*)
	hmi_ALM_FaultWord1 : 			ARRAY[1..16] OF BOOL; (*Array representation of IAS_STAT_FaultWord1*)
	hmi_ALM_FaultWord2 : 			ARRAY[1..16] OF BOOL; (*Array representation of IAS_STAT_FaultWord2*)
	
	(*Imported Variables / shorthand*)
	CorvusRead:				ARRAY [1..16] OF str_Corvus_ALL; (*The almighty Corvus BMS Array-Array*)
	M : 					INT; 							(*Pack number for current Array Master: The pack that array information is gathered from*)
	IasCommunication: 		fb_WdUint;						(*IAS Watchdog*)
	
	IAS_Start: 			BOOL;	(*Start command from IAS*)
	IAS_Stop: 			BOOL;	(*Stop command from IAS*)
	IAS_Reset: 			BOOL;	(*Reset command from IAS*)
	IAS_Increase: 		BOOL;	(*Increase command from IAS*)
	IAS_Decrease:		BOOL;	(*Decrease command from IAS*)
	IAS_BatteryAlone: 	BOOL; 	(*Flag from IAS to tell the battery that there are no other power sources on the bus*)
	IAS_FireAlarm: 		BOOL;	(*Flag from IAS to report fire in the battery room*)
	
	IAS_STAT_Watchdog:			UINT; 	(*Watchdog from QB to IAS*)
	IAS_STAT_OperationalMode:	UINT; 	(*b0: Undefined, b1: Pure Electric Mode, b2: Hybrid Mode, b3: Diesel Electric Mode, b4: Service charge Mode, b5: Spare, b6: Spare, b7: Spare, b8: Spare, b9: Spare, b10: Spare, b11: Spare, b12: Spare, b13: Spare, b14: Spare, b15: Spare*)
	IAS_STAT_ControlMode:		UINT; 	(*0: Undefined, 1: NotInUse, 2: Remote, 3: Local*)
	IAS_STAT_State_Battery:		UINT; 	(*0: Undefined, 1: Stopped, 2: Starting, 3: Running  4: Stopping  5: Spare  6: PreWarning  7: Fault/Shutdown*)
	IAS_STAT_Breaker:			UINT; 	(*b0: DC Breaker Open, b1: DC Breaker Closed, b2: AC Breaker Open, b3: AC Breaker Closed, b4: Spare, b5: Spare, b6: Spare, b7: Spare, b8: Spare, b9: Spare, b10: Spare, b11: Spare, b12: Spare, b13: Spare, b14: Spare, b15: Spare*)
	IAS_STAT_Status:			UINT; 	(*b0: Running, b1: Ready, b2: Common Warning, b3: Common Fault, b4: Spare, b5: Spare, b6: In local, b7: In remote, b8: In Limit, b9: Spare, b10: Spare, b11: Spare, b12: Spare, b13: Spare, b14: Spare, b15: Spare*)
	
	IAS_AO_kW:					INT; 	(*System power*)
	IAS_AO_Current:				INT; 	(*System current*)
	IAS_AO_SOC:					INT; 	(*System state of charge in connected system*)
	IAS_AO_SOH:					INT; 	(*System state of health in connected system*)
	IAS_AO_BusVoltage:			INT; 	(*System bus voltage*)
	IAS_AO_StringVoltage:		INT; 	(*System string voltage*)
	IAS_AO_AvailablePower:		UINT; 	(*Available discharge power*)
	IAS_AO_TimeRemaining:		UINT; 	(*Time remaining on current load in minutes*)
	IAS_AO_EnergyRemaining:		UINT; 	(*System energy remaining*)
	IAS_AO_CellVoltageMax:		UINT; 	(*Maximum cell voltage in connected system*)
	IAS_AO_CellVoltageMin:		UINT; 	(*Minumum cell voltage in connected system*)
	IAS_AO_CellVoltageAverage:	UINT; 	(*Average cell voltage in connected system*)
	IAS_AO_CellTempMax:			INT; 	(*Maxumum cell temperature in connected system*)
	IAS_AO_CellTempMin:			INT; 	(*Minumum cell temperature in connected system*)
	IAS_AO_CellTempAverage:		INT; 	(*Average cell temperature in connected system*)
	
	IAS_STAT_CellBalancingStatus:	UINT; (*b0: 1=Pack 1 Cell Balancing in Progress.  0=Cell Balancing not in Progress, b1: 1=Pack 2 Cell Balancing in Progress.  0=Cell Balancing not in Progress, b2: 1=Pack 3 Cell Balancing in Progress.  0=Cell Balancing not in Progress, b3: 1=Pack 4 Cell Balancing in Progress.  0=Cell Balancing not in Progress, b4: 1=Pack 5 Cell Balancing in Progress.  0=Cell Balancing not in Progress, b5: 1=Pack 6 Cell Balancing in Progress.  0=Cell Balancing not in Progress, b6: 1=Pack 7 Cell Balancing in Progress.  0=Cell Balancing not in Progress, b7: 1=Pack 7 Cell Balancing in Progress.  0=Cell Balancing not in Progress, b8: 1=Pack 8 Cell Balancing in Progress.  0=Cell Balancing not in Progress, b9: 1=Pack 9 Cell Balancing in Progress.  0=Cell Balancing not in Progress, b10: 1=Pack 10 Cell Balancing in Progress.  0=Cell Balancing not in Progress, b11: 1=Pack 11 Cell Balancing in Progress.  0=Cell Balancing not in Progress, b12: 1=Pack 12 Cell Balancing in Progress.  0=Cell Balancing not in Progress, b13: 1=Pack 13 Cell Balancing in Progress.  0=Cell Balancing not in Progress, b14: 1=Pack 14 Cell Balancing in Progress.  0=Cell Balancing not in Progress, b15: 1=Pack 15 Cell Balancing in Progress.  0=Cell Balancing not in Progress*)
	IAS_STAT_CellsInBalance:		UINT; (*b0: 1=Pack 1 All cells in the pack are in balance.  0=One or more cells in the pack are outside the balanced threshold., b1: 1=Pack 2 All cells in the pack are in balance.  0=One or more cells in the pack are outside the balanced threshold., b2: 1=Pack 3 All cells in the pack are in balance.  0=One or more cells in the pack are outside the balanced threshold., b3: 1=Pack 4 All cells in the pack are in balance.  0=One or more cells in the pack are outside the balanced threshold., b4: 1=Pack 5 All cells in the pack are in balance.  0=One or more cells in the pack are outside the balanced threshold., b5: 1=Pack 6 All cells in the pack are in balance.  0=One or more cells in the pack are outside the balanced threshold., b6: 1=Pack 7 All cells in the pack are in balance.  0=One or more cells in the pack are outside the balanced threshold., b7: 1=Pack 7 All cells in the pack are in balance.  0=One or more cells in the pack are outside the balanced threshold., b8: 1=Pack 8 All cells in the pack are in balance.  0=One or more cells in the pack are outside the balanced threshold., b9: 1=Pack 9 All cells in the pack are in balance.  0=One or more cells in the pack are outside the balanced threshold., b10: 1=Pack 10 All cells in the pack are in balance.  0=One or more cells in the pack are outside the balanced threshold., b11: 1=Pack 11 All cells in the pack are in balance.  0=One or more cells in the pack are outside the balanced threshold., b12: 1=Pack 12 All cells in the pack are in balance.  0=One or more cells in the pack are outside the balanced threshold., b13: 1=Pack 13 All cells in the pack are in balance.  0=One or more cells in the pack are outside the balanced threshold., b14: 1=Pack 14 All cells in the pack are in balance.  0=One or more cells in the pack are outside the balanced threshold., b15: 1=Pack 15 All cells in the pack are in balance.  0=One or more cells in the pack are outside the balanced threshold.*)
	
	
	IAS_AO_SOC_Pack1:	UINT; (*State of Charge for Pack 1*)
	IAS_AO_SOC_Pack2:	UINT; (*State of Charge for Pack 2*)
	IAS_AO_SOC_Pack3:	UINT; (*State of Charge for Pack 3*)
	IAS_AO_SOC_Pack4:	UINT; (*State of Charge for Pack 4*)
	IAS_AO_SOC_Pack5:	UINT; (*State of Charge for Pack 5*)
	IAS_AO_SOC_Pack6:	UINT; (*State of Charge for Pack 6*)
	IAS_AO_SOC_Pack7:	UINT; (*State of Charge for Pack 7*)
	IAS_AO_SOC_Pack8:	UINT; (*State of Charge for Pack 8*)
	IAS_AO_SOC_Pack9:	UINT; (*State of Charge for Pack 9*)
	IAS_AO_SOC_Pack10:	UINT; (*State of Charge for Pack 10*)
	IAS_AO_SOC_Pack11:	UINT; (*State of Charge for Pack 11*)
	IAS_AO_SOC_Pack12:	UINT; (*State of Charge for Pack 12*)
	IAS_AO_SOC_Pack13:	UINT; (*State of Charge for Pack 13*)
	IAS_AO_SOC_Pack14:	UINT; (*State of Charge for Pack 14*)
	IAS_AO_SOC_Pack15:	UINT; (*State of Charge for Pack 15*)
	IAS_AO_SOC_Pack16:	UINT; (*State of Charge for Pack 16*)
	
	IAS_STAT_ConnectionWord:	UINT; 	(*b0: Pack 1 is connected, b1: Pack 2 is connected, b2: Pack 3 is connected, b3: Pack 4 is connected, b4: Pack 5 is connected, b5: Pack 6 is connected, b6: Pack 7 is connected, b7: Pack 7 is connected, b8: Pack 8 is connected, b9: Pack 9 is connected, b10: Pack 10 is connected, b11: Pack 11 is connected, b12: Pack 12 is connected, b13: Pack 13 is connected, b14: Pack 14 is connected, b15: Pack 15 is connected*)
	IAS_AO_NrOfStringsInArray:	UINT; 	(*Total number of battery packs in this array*)
	IAS_AO_BatteryRoomTemp:		INT; 	(*Temperature in the battery room*)
	
	IAS_AO_Spare1:UINT; (*Spare1*)
	IAS_AO_Spare2:UINT; (*Spare2*)
	IAS_AO_Spare3:UINT; (*Spare3*)
	IAS_AO_Spare4:UINT; (*Spare4*)
	IAS_AO_Spare5:UINT; (*Spare5*)
	IAS_AO_Spare6:UINT; (*Spare6*)
	IAS_AO_Spare7:UINT; (*Spare7*)
	IAS_AO_Spare8:UINT; (*Spare8*)
	IAS_AO_Spare9:UINT; (*Spare9*)
	IAS_AO_Spare10:UINT; (*Spare10*)
	IAS_AO_Spare11:UINT; (*Spare11*)
	IAS_AO_Spare12:UINT; (*Spare12*)
	IAS_AO_Spare13:UINT; (*Spare13*)
	IAS_AO_Spare14:UINT; (*Spare14*)
	IAS_AO_Spare15:UINT; (*Spare15*)
	IAS_AO_Spare16:UINT; (*Spare16*)
	IAS_AO_Spare17:UINT; (*Spare17*)
	IAS_AO_Spare18:UINT; (*Spare18*)
	IAS_AO_Spare19:UINT; (*Spare19*)
	IAS_AO_Spare20:UINT; (*Spare20*)
	IAS_AO_Spare21:UINT; (*Spare21*)
	IAS_AO_Spare22:UINT; (*Spare22*)
	IAS_AO_Spare23:UINT; (*Spare23*)
	IAS_AO_Spare24:UINT; (*Spare24*)
	IAS_AO_Spare25:UINT; (*Spare25*)
	IAS_AO_Spare26:UINT; (*Spare26*)
	IAS_AO_Spare27:UINT; (*Spare27*)
	IAS_AO_Spare28:UINT; (*Spare28*)
	IAS_AO_Spare29:UINT; (*Spare29*)
	IAS_AO_Spare30:UINT; (*Spare30*)
	IAS_AO_Spare31:UINT; (*Spare31*)
	IAS_AO_Spare32:UINT; (*Spare32*)
	IAS_AO_Spare33:UINT; (*Spare33*)
	IAS_AO_Spare34:UINT; (*Spare34*)
	IAS_AO_Spare35:UINT; (*Spare35*)
	IAS_AO_Spare36:UINT; (*Spare36*)
	IAS_AO_Spare37:UINT; (*Spare37*)
	IAS_AO_Spare38:UINT; (*Spare38*)
	IAS_AO_Spare39:UINT; (*Spare39*)
	IAS_AO_Spare40:UINT; (*Spare40*)
	IAS_AO_Spare41:UINT; (*Spare41*)
	IAS_AO_Spare42:UINT; (*Spare42*)
	IAS_AO_Spare43:UINT; (*Spare43*)

	IAS_ALM_AlarmWord_1:	UINT; (*b0: Common PLC Warning, b1: Common Application Warning, b2: Common IO Warning, b3: Common Level Warning, b4: Common Signal Warning, b5: Common E0, b6: [spare], b7: [spare], b8: [spare], b9: [spare], b10: [spare], b11: [spare], b12: [spare], b13: [spare], b14: [spare], b15: [spare]*)
	IAS_ALM_AlarmWord_2:	UINT; (*b0: Common Cell Over Voltage Warning, b1: Common Cell Under Voltage Warning, b2: Common Cell Over Temperature Warning, b3: Common Module Communication Warning, b4: Common Over Current Warning, b5: Common Input Powerloss Warning, b6: Common Power Distribution Module Over Temperature Warning, b7: Common Coolant Water Leakage Warning, b8: Battery State of Charge Low Alarm, b9: Battery State of Charge High Alarm, b10: Prewarning from Battery Management System, b11: [spare], b12: [spare], b13: [spare], b14: [spare], b15: [spare]*)
	IAS_ALM_AlarmWord_3:	UINT; (*b0: [spare], b1: [spare], b2: [spare], b3: [spare], b4: [spare], b5: [spare], b6: [spare], b7: [spare], b8: [spare], b9: [spare], b10: [spare], b11: [spare], b12: [spare], b13: [spare], b14: [spare], b15: [spare]*)
	IAS_ALM_AlarmWord_4:	UINT; (*b0: [spare], b1: [spare], b2: [spare], b3: [spare], b4: [spare], b5: [spare], b6: [spare], b7: [spare], b8: [spare], b9: [spare], b10: [spare], b11: [spare], b12: [spare], b13: [spare], b14: [spare], b15: [spare]*)
	IAS_ALM_AlarmWord_5:	UINT; (*b0: [spare], b1: [spare], b2: [spare], b3: [spare], b4: [spare], b5: [spare], b6: [spare], b7: [spare], b8: [spare], b9: [spare], b10: [spare], b11: [spare], b12: [spare], b13: [spare], b14: [spare], b15: [spare]*)
	IAS_ALM_AlarmWord_6:	UINT; (*b0: [spare], b1: [spare], b2: [spare], b3: [spare], b4: [spare], b5: [spare], b6: [spare], b7: [spare], b8: [spare], b9: [spare], b10: [spare], b11: [spare], b12: [spare], b13: [spare], b14: [spare], b15: [spare]*)
	IAS_ALM_AlarmWord_7:	UINT; (*b0: [spare], b1: [spare], b2: [spare], b3: [spare], b4: [spare], b5: [spare], b6: [spare], b7: [spare], b8: [spare], b9: [spare], b10: [spare], b11: [spare], b12: [spare], b13: [spare], b14: [spare], b15: [spare]*)
	IAS_ALM_AlarmWord_8:	UINT; (*b0: [spare], b1: [spare], b2: [spare], b3: [spare], b4: [spare], b5: [spare], b6: [spare], b7: [spare], b8: [spare], b9: [spare], b10: [spare], b11: [spare], b12: [spare], b13: [spare], b14: [spare], b15: [spare]*)
	IAS_ALM_AlarmWord_9:	UINT; (*b0: [spare], b1: [spare], b2: [spare], b3: [spare], b4: [spare], b5: [spare], b6: [spare], b7: [spare], b8: [spare], b9: [spare], b10: [spare], b11: [spare], b12: [spare], b13: [spare], b14: [spare], b15: [spare]*)
	IAS_ALM_AlarmWord_10:	UINT; (*b0: [spare], b1: [spare], b2: [spare], b3: [spare], b4: [spare], b5: [spare], b6: [spare], b7: [spare], b8: [spare], b9: [spare], b10: [spare], b11: [spare], b12: [spare], b13: [spare], b14: [spare], b15: [spare]*)
	IAS_ALM_FaultWord_1:	UINT; (*b0: Common Application Fault, b1: Common Level Fault, b2: [spare], b3: [spare], b4: [spare], b5: [spare], b6: [spare], b7: [spare], b8: [spare], b9: [spare], b10: [spare], b11: [spare], b12: [spare], b13: [spare], b14: [spare], b15: [spare]*)
	IAS_ALM_FaultWord_2:	UINT; (*b0: Common Cell Over Voltage Fault, b1: Common Cell Under Voltage Fault, b2: Common Cell Over Temperature Fault, b3: Common High Voltage Interlock Loop fault, b4: Common Emergency Stop Active Fault, b5: Common Safety Shutdown Fault, b6: Common Ground Fault, b7: Common Contactor Fault, b8: Common Low Temperature Over Current Fault, b9: Common Repeated Over Charge Lockout Fault, b10: Common Deep Over Discharge Lockout Fault, b11: Common Power Distribution Module Over Temperature Fault, b12: Battery Protection Trip: High State of Charge, b13: Battery Protection Trip: Low State of Charge, b14: [spare], b15: [spare]*)
	IAS_ALM_FaultWord_3:	UINT; (*b0: [spare], b1: [spare], b2: [spare], b3: [spare], b4: [spare], b5: [spare], b6: [spare], b7: [spare], b8: [spare], b9: [spare], b10: [spare], b11: [spare], b12: [spare], b13: [spare], b14: [spare], b15: [spare]*)
	IAS_ALM_FaultWord_4:	UINT; (*b0: [spare], b1: [spare], b2: [spare], b3: [spare], b4: [spare], b5: [spare], b6: [spare], b7: [spare], b8: [spare], b9: [spare], b10: [spare], b11: [spare], b12: [spare], b13: [spare], b14: [spare], b15: [spare]*)
	IAS_ALM_FaultWord_5:	UINT; (*b0: [spare], b1: [spare], b2: [spare], b3: [spare], b4: [spare], b5: [spare], b6: [spare], b7: [spare], b8: [spare], b9: [spare], b10: [spare], b11: [spare], b12: [spare], b13: [spare], b14: [spare], b15: [spare]*)
	
	
	
	
	
	IAS_CTRL_WatchdogFB:		UINT; (*Watchdog feedback from IAS to QB*)
	IAS_CTRL_OperationalMode:	UINT; (*b0: Undefined, b1: Pure Electric Mode, b2: Hybrid Mode, b3: Diesel Electric Mode, b4: Service charge Mode, b5: [spare], b6: [spare], b7: [spare], b8: [spare], b9: [spare], b10: [spare], b11: [spare], b12: [spare], b13: [spare], b14: [spare], b15: [spare]*)
	IAS_CTRL_Commands:			UINT; (*b0: No Function, b1: Reserved, b2: Start Converter, b3: Reserved, b4: Stop Converter, b5: Reset, b6: Increase Load, b7: Decrease Load, b8: BatteryAloneOnBus, b9: [spare], b10: [spare], b11: [spare], b12: [spare], b13: [spare], b14: [spare], b15: [spare]*)
	IAS_CTRL_ExtAlarms : 		UINT; (*b0: Fire Alarm in Battery Room, b1: [spare], b2: [spare], b3: [spare], b4: [spare], b5: [spare], b6: [spare], b7: [spare], b8: [spare], b9: [spare], b10: [spare], b11: [spare], b12: [spare], b13: [spare], b14: [spare], b15: [spare]*)
	IAS_CTRL_Hours :			INT;  (*Time in hours from IAS  (range 0 - 23)*)
	IAS_CTRL_Minutes :			INT;  (*Time in minutes from IAS (range 0 - 59)*)	
	IAS_CTRL_Seconds :			INT;  (*Time in seconds from IAS (range 0 - 59)*)

	IAS_CTRL_Spare_1:			UINT; (*Spare8*)
	IAS_CTRL_Spare_2:			UINT; (*Spare9*)
	IAS_CTRL_Spare_3:			UINT; (*Spare10*)
END_VAR

(* Imported variables for shorthand use in this program *)
CorvusRead := PRG_BatteryComm.CorvusRead;
M := PRG_BatteryComm.M;

(*Set timeout for altered charge/discharge limits*)
IasInterfaceTest_TON (IN:=IasInterfaceTest, PT:=T#60m);

(*Disable after timeout or when start bit has been deactivated*)
IF 	(IasInterfaceTest_TON.Q) THEN
	IasInterfaceTest := FALSE;
END_IF

IasInterfaceTestMinLeft := REAL_TO_INT(TIME_TO_REAL(IasInterfaceTest_TON.PT - IasInterfaceTest_TON.ET)/60000);

	
	


	
(*Commands from IAS*)
IAS_Start := 		IAS_CTRL_Commands.2;
IAS_Stop := 		IAS_CTRL_Commands.4;
IAS_Reset := 		IAS_CTRL_Commands.5;
IAS_Increase := 	IAS_CTRL_Commands.6;
IAS_Decrease := 	IAS_CTRL_Commands.7;
IAS_BatteryAlone := IAS_CTRL_Commands.8;
IAS_FireAlarm := 	IAS_CTRL_ExtAlarms.0;


IF (NOT IasInterfaceTest) THEN


(*
 * Copies actual values into the HMI arrays when not interface testing. 
 * This way, the real values are shown in HMI in normal mode and when testing - the values can be over written
*)
	Array_STAT_OperationalMode		(Input := IAS_STAT_OperationalMode, 	xArray => hmi_STAT_OperationalMode );	
	Array_STAT_Breaker				(Input := IAS_STAT_Breaker, 			xArray => hmi_STAT_Breaker );
	Array_STAT_Status				(Input := IAS_STAT_Status, 				xArray => hmi_STAT_Status);	
	Array_STAT_CellBalancingStatus	(Input := IAS_STAT_CellBalancingStatus,	xArray => hmi_STAT_CellBalancingStatus );
	Array_STAT_CellsInBalance		(Input := IAS_STAT_CellsInBalance, 		xArray => hmi_STAT_CellsInBalance);
	Array_ALM_AlarmWord_1			(Input := IAS_ALM_AlarmWord_1, 			xArray => hmi_ALM_AlarmWord1);
	Array_ALM_AlarmWord_2			(Input := IAS_ALM_AlarmWord_2, 			xArray => hmi_ALM_AlarmWord2);
	Array_ALM_FaultWord_1			(Input := IAS_ALM_FaultWord_1, 			xArray => hmi_ALM_FaultWord1);
	Array_ALM_FaultWord_2			(Input := IAS_ALM_FaultWord_2, 			xArray => hmi_ALM_FaultWord2);

	(**************************************************************************************************************
	 * Actual interface sent to IAS
	***************************************************************************************************************)

	IAS_STAT_Watchdog:= 			0; 											(*Watchdog from QB to IAS*)
	IAS_STAT_OperationalMode:= 		IAS_CTRL_OperationalMode; 					(*0: Undefined, 1: Pure electric mode, 2: Hybrid mode, 3: Diesel electric mode, 4: Service charging mode*)
	IAS_STAT_ControlMode:=			PRG_Operation.ControlPlace.ctrlLocation; 	(*0: Undefined, 1: NotInUse, 2: Remote, 3: Local*)
	IAS_STAT_State_Battery:=		Extended_Statemachine; 						(*0: Undefined, 1: Stopped, 2: Starting, 3: Running  4: Stopping  5: Spare  6: PreWarning  7: Fault/Shutdown*)
	
	IAS_STAT_Breaker.0:=			NOT PRG_Functions.Breaker.DI_Verif; 		(*b0: DC Breaker Open*)
	IAS_STAT_Breaker.1:=			PRG_Functions.Breaker.DI_Verif; 			(*b1: DC Breaker Closed*)
	IAS_STAT_Breaker.2:=			FALSE; 										(*b2: AC Breaker Open*)
	IAS_STAT_Breaker.3:=			FALSE; 										(*b3: AC Breaker Closed*)
	
	IAS_STAT_Status.0:=				PRG_StateMain.State = e_Running; 			(*b0: Running*)
	IAS_STAT_Status.1:=				PRG_StateMain.startInhibit = 0; 			(*b1: Ready*) 
	IAS_STAT_Status.2:=				PRG_Alarms.Repeat_Alarm.Alarm_common; 					(*b2: Common Warning*);
	IAS_STAT_Status.3:=				PRG_Faults.Repeat_Fault.Alarm_common; 					(*b3: Common Fault*)  
	IAS_STAT_Status.4:=				FALSE; 													(*b4: Spare*)  
	IAS_STAT_Status.5:=				FALSE; 													(*b5: Spare*)  
	IAS_STAT_Status.6:=				PRG_Operation.ControlPlace.ctrlLocation = e_Local; 		(*b6: In Local*)  
	IAS_STAT_Status.7:=				PRG_Operation.ControlPlace.ctrlLocation = e_Remote; 	(*b7: In Remote*)  
	IAS_STAT_Status.8:=				PRG_Battery.Battery_Current_Limiter.ChargingLimited OR
									PRG_Battery.Battery_Current_Limiter.DischargingLimited;	(*b8: In Limit*)  
	
	IAS_AO_kW:=						REAL_TO_INT(CorvusRead[M].theArray.busPowerCalculated*-1); 		(*System power*)
	IAS_AO_Current:=				DINT_TO_INT(CorvusRead[M].theArray.busCurrent*-1); 				(*System current*)
	IAS_AO_SOC:=					DINT_TO_INT(CorvusRead[M].theArray.systemOnlineSOC);			(*System state of charge in connected system*)
	IAS_AO_SOH:=					DINT_TO_INT(CorvusRead[M].theArray.systemOnlineSOH);			(*System state of health in connected system*)
	IAS_AO_BusVoltage:=				REAL_TO_UINT(PRG_Drive.Data.DcLinkVoltage_eng); 				(*System bus voltage*)
	IAS_AO_StringVoltage:=			DINT_TO_INT(CorvusRead[M].theArray.busVoltage); 				(*System string voltage*)
	IAS_AO_AvailablePower:=			PRG_Battery.AvailablePower; 									(*Available discharge power*)
	IAS_AO_TimeRemaining:=			REAL_TO_INT(PRG_Battery.MinutesRemaining); 						(*Time remaining on current load in minutes*)
	IAS_AO_EnergyRemaining:=		REAL_TO_INT(PRG_Battery.AvailableEnergy); 						(*System energy remaining*)
	IAS_AO_CellVoltageMax:=			DINT_TO_INT(CorvusRead[M].theArray.maxCellVoltage); 			(*Maximum cell voltage in connected system*)
	IAS_AO_CellVoltageMin:=			DINT_TO_INT(CorvusRead[M].theArray.minCellVoltage); 			(*Minumum cell voltage in connected system*)
	IAS_AO_CellVoltageAverage:=		PRG_Battery.avgCellVolt;	 									(*Average cell voltage in connected system*)
	IAS_AO_CellTempMax:=			DINT_TO_INT(CorvusRead[M].theArray.maxCellTemp); 				(*Maxumum cell temperature in connected system*)
	IAS_AO_CellTempMin:=			DINT_TO_INT(CorvusRead[M].theArray.minCellTemp); 				(*Minumum cell temperature in connected system*)
	IAS_AO_CellTempAverage:=		PRG_Battery.avgCellTemp; 										(*Average cell temperature in connected system*)
	
	IAS_STAT_CellBalancingStatus.0:= 	PRG_Battery.cellBalancingStatus[1]; 	(*b0: 1=Pack 1 All cells in the pack are in balance. *)
	IAS_STAT_CellBalancingStatus.1:= 	PRG_Battery.cellBalancingStatus[2]; 	(*b1: 1=Pack 2 All cells in the pack are in balance. *)
	IAS_STAT_CellBalancingStatus.2:= 	PRG_Battery.cellBalancingStatus[3]; 	(*b2: 1=Pack 3 All cells in the pack are in balance. *)
	IAS_STAT_CellBalancingStatus.3:= 	PRG_Battery.cellBalancingStatus[4]; 	(*b3: 1=Pack 4 All cells in the pack are in balance. *)
	IAS_STAT_CellBalancingStatus.4:= 	PRG_Battery.cellBalancingStatus[5]; 	(*b4: 1=Pack 5 All cells in the pack are in balance. *)
	IAS_STAT_CellBalancingStatus.5:= 	PRG_Battery.cellBalancingStatus[6]; 	(*b5: 1=Pack 6 All cells in the pack are in balance. *)
	IAS_STAT_CellBalancingStatus.6:= 	PRG_Battery.cellBalancingStatus[7]; 	(*b6: 1=Pack 7 All cells in the pack are in balance. *)
	IAS_STAT_CellBalancingStatus.7:= 	PRG_Battery.cellBalancingStatus[8]; 	(*b7: 1=Pack 8 All cells in the pack are in balance. *)
	IAS_STAT_CellBalancingStatus.8:= 	PRG_Battery.cellBalancingStatus[9]; 	(*b8: 1=Pack 9 All cells in the pack are in balance. *)
	IAS_STAT_CellBalancingStatus.9:= 	PRG_Battery.cellBalancingStatus[10]; 	(*b9: 1=Pack 10 All cells in the pack are in balance. *)
	IAS_STAT_CellBalancingStatus.10:= 	PRG_Battery.cellBalancingStatus[11]; 	(*b10: 1=Pack 11 All cells in the pack are in balance. *)
	IAS_STAT_CellBalancingStatus.11:= 	PRG_Battery.cellBalancingStatus[12]; 	(*b11: 1=Pack 12 All cells in the pack are in balance. *)
	IAS_STAT_CellBalancingStatus.12:= 	PRG_Battery.cellBalancingStatus[13]; 	(*b12: 1=Pack 13 All cells in the pack are in balance. *)
	IAS_STAT_CellBalancingStatus.13:= 	PRG_Battery.cellBalancingStatus[14]; 	(*b13: 1=Pack 14 All cells in the pack are in balance. *)
	IAS_STAT_CellBalancingStatus.14:= 	PRG_Battery.cellBalancingStatus[15]; 	(*b14: 1=Pack 15 All cells in the pack are in balance. *)
	IAS_STAT_CellBalancingStatus.15:= 	PRG_Battery.cellBalancingStatus[16]; 	(*b15: 1=Pack 16 All cells in the pack are in balance. *)
	
	IAS_STAT_CellsInBalance.0:= 		PRG_Battery.CellsInBalance[1]; 			(*b0: 1=Pack 1 All cells in the pack are in balance. *)
	IAS_STAT_CellsInBalance.1:= 		PRG_Battery.CellsInBalance[2]; 			(*b1: 1=Pack 2 All cells in the pack are in balance. *)
	IAS_STAT_CellsInBalance.2:= 		PRG_Battery.CellsInBalance[3]; 			(*b2: 1=Pack 3 All cells in the pack are in balance. *)
	IAS_STAT_CellsInBalance.3:= 		PRG_Battery.CellsInBalance[4]; 			(*b3: 1=Pack 4 All cells in the pack are in balance. *)
	IAS_STAT_CellsInBalance.4:= 		PRG_Battery.CellsInBalance[5]; 			(*b4: 1=Pack 5 All cells in the pack are in balance. *)
	IAS_STAT_CellsInBalance.5:= 		PRG_Battery.CellsInBalance[6]; 			(*b5: 1=Pack 6 All cells in the pack are in balance. *)
	IAS_STAT_CellsInBalance.6:= 		PRG_Battery.CellsInBalance[7]; 			(*b6: 1=Pack 7 All cells in the pack are in balance. *)
	IAS_STAT_CellsInBalance.7:= 		PRG_Battery.CellsInBalance[8]; 			(*b7: 1=Pack 8 All cells in the pack are in balance. *)
	IAS_STAT_CellsInBalance.8:= 		PRG_Battery.CellsInBalance[9]; 			(*b8: 1=Pack 9 All cells in the pack are in balance. *)
	IAS_STAT_CellsInBalance.9:= 		PRG_Battery.CellsInBalance[10]; 		(*b9: 1=Pack 10 All cells in the pack are in balance. *)
	IAS_STAT_CellsInBalance.10:= 		PRG_Battery.CellsInBalance[11]; 		(*b10: 1=Pack 11 All cells in the pack are in balance. *)
	IAS_STAT_CellsInBalance.11:= 		PRG_Battery.CellsInBalance[12]; 		(*b11: 1=Pack 12 All cells in the pack are in balance. *)
	IAS_STAT_CellsInBalance.12:= 		PRG_Battery.CellsInBalance[13]; 		(*b12: 1=Pack 13 All cells in the pack are in balance. *)
	IAS_STAT_CellsInBalance.13:= 		PRG_Battery.CellsInBalance[14]; 		(*b13: 1=Pack 14 All cells in the pack are in balance. *)
	IAS_STAT_CellsInBalance.14:= 		PRG_Battery.CellsInBalance[15]; 		(*b14: 1=Pack 15 All cells in the pack are in balance. *)
	IAS_STAT_CellsInBalance.15:= 		PRG_Battery.CellsInBalance[16]; 		(*b15: 1=Pack 16 All cells in the pack are in balance. *)
	
	IAS_AO_SOC_Pack1:=					DINT_TO_UINT(PRG_BatteryComm.CorvusRead[1].Pack.SOC); (*State of Charge for Pack 1*)
	IAS_AO_SOC_Pack2:=					DINT_TO_UINT(PRG_BatteryComm.CorvusRead[2].Pack.SOC); (*State of Charge for Pack 2*)
	IAS_AO_SOC_Pack3:=					DINT_TO_UINT(PRG_BatteryComm.CorvusRead[3].Pack.SOC); (*State of Charge for Pack 3*)
	IAS_AO_SOC_Pack4:=					DINT_TO_UINT(PRG_BatteryComm.CorvusRead[4].Pack.SOC); (*State of Charge for Pack 4*)
	IAS_AO_SOC_Pack5:=					DINT_TO_UINT(PRG_BatteryComm.CorvusRead[5].Pack.SOC); (*State of Charge for Pack 5*)
	IAS_AO_SOC_Pack6:=					DINT_TO_UINT(PRG_BatteryComm.CorvusRead[6].Pack.SOC); (*State of Charge for Pack 6*)
	IAS_AO_SOC_Pack7:=					DINT_TO_UINT(PRG_BatteryComm.CorvusRead[7].Pack.SOC); (*State of Charge for Pack 7*)
	IAS_AO_SOC_Pack8:=					DINT_TO_UINT(PRG_BatteryComm.CorvusRead[8].Pack.SOC); (*State of Charge for Pack 8*)
	IAS_AO_SOC_Pack9:=					DINT_TO_UINT(PRG_BatteryComm.CorvusRead[9].Pack.SOC); (*State of Charge for Pack 9*)
	IAS_AO_SOC_Pack10:=					DINT_TO_UINT(PRG_BatteryComm.CorvusRead[10].Pack.SOC); (*State of Charge for Pack 10*)
	IAS_AO_SOC_Pack11:=					DINT_TO_UINT(PRG_BatteryComm.CorvusRead[11].Pack.SOC); (*State of Charge for Pack 11*)
	IAS_AO_SOC_Pack12:=					DINT_TO_UINT(PRG_BatteryComm.CorvusRead[12].Pack.SOC); (*State of Charge for Pack 12*)
	IAS_AO_SOC_Pack13:=					DINT_TO_UINT(PRG_BatteryComm.CorvusRead[13].Pack.SOC); (*State of Charge for Pack 13*)
	IAS_AO_SOC_Pack14:=					DINT_TO_UINT(PRG_BatteryComm.CorvusRead[14].Pack.SOC); (*State of Charge for Pack 14*)
	IAS_AO_SOC_Pack15:=					DINT_TO_UINT(PRG_BatteryComm.CorvusRead[15].Pack.SOC); (*State of Charge for Pack 15*)
	IAS_AO_SOC_Pack16:=					DINT_TO_UINT(PRG_BatteryComm.CorvusRead[16].Pack.SOC); (*State of Charge for Pack 16*)
	
	IAS_STAT_ConnectionWord.0:= 		PRG_Battery.connectionArray[1]; (*b0: Pack 1 is connected*) 
	IAS_STAT_ConnectionWord.1:= 		PRG_Battery.connectionArray[2]; (*b1: Pack 2 is connected*) 
	IAS_STAT_ConnectionWord.2:= 		PRG_Battery.connectionArray[3]; (*b2: Pack 3 is connected*) 
	IAS_STAT_ConnectionWord.3:= 		PRG_Battery.connectionArray[4]; (*b3: Pack 4 is connected*) 
	IAS_STAT_ConnectionWord.4:= 		PRG_Battery.connectionArray[5]; (*b4: Pack 5 is connected*) 
	IAS_STAT_ConnectionWord.5:= 		PRG_Battery.connectionArray[6]; (*b5: Pack 6 is connected*) 
	IAS_STAT_ConnectionWord.6:= 		PRG_Battery.connectionArray[7]; (*b6: Pack 7 is connected*) 
	IAS_STAT_ConnectionWord.7:= 		PRG_Battery.connectionArray[8]; (*b7: Pack 8 is connected*) 
	IAS_STAT_ConnectionWord.8:= 		PRG_Battery.connectionArray[9]; (*b8: Pack 9 is connected*) 
	IAS_STAT_ConnectionWord.9:= 		PRG_Battery.connectionArray[10]; (*b9: Pack 10 is connected*) 
	IAS_STAT_ConnectionWord.10:= 		PRG_Battery.connectionArray[11]; (*b10: Pack 11 is connected*) 
	IAS_STAT_ConnectionWord.11:= 		PRG_Battery.connectionArray[12]; (*b11: Pack 12 is connected*) 
	IAS_STAT_ConnectionWord.12:= 		PRG_Battery.connectionArray[13]; (*b12: Pack 13 is connected*) 
	IAS_STAT_ConnectionWord.13:= 		PRG_Battery.connectionArray[14]; (*b13: Pack 14 is connected*) 
	IAS_STAT_ConnectionWord.14:= 		PRG_Battery.connectionArray[15]; (*b14: Pack 15 is connected*) 
	IAS_STAT_ConnectionWord.15:= 		PRG_Battery.connectionArray[16]; (*b15: Pack 16 is connected*) 
	
	IAS_AO_NrOfStringsInArray:=			PRG_HMI.setup_Battery_total_nr_of_packs; (*Total number of battery packs in this array*)
	IAS_AO_BatteryRoomTemp:= 			REAL_TO_INT(PRG_AI.ai_BatteryRoomTemperature.PV); (*Temperature in the battery room*)
	
	IAS_AO_Spare1:=0; 		(*Spare2*)
	IAS_AO_Spare2:=0;		(*Spare3*)
	IAS_AO_Spare3:=0; 		(*Spare4*)
	IAS_AO_Spare4:=0; 		(*Spare5*)
	IAS_AO_Spare5:=0; 		(*Spare6*)
	IAS_AO_Spare6:=0; 		(*Spare7*)
	IAS_AO_Spare7:=0; 		(*Spare8*)
	IAS_AO_Spare8:=0; 		(*Spare9*)
	IAS_AO_Spare9:=0; 		(*Spare10*)
	IAS_AO_Spare10:=0; 		(*Spare11*)
	IAS_AO_Spare11:=0; 		(*Spare12*)
	IAS_AO_Spare12:=0; 		(*Spare13*)
	IAS_AO_Spare13:=0; 		(*Spare14*)
	IAS_AO_Spare14:=0; 		(*Spare15*)
	IAS_AO_Spare15:=0; 		(*Spare16*)
	IAS_AO_Spare16:=0; 		(*Spare17*)
	IAS_AO_Spare17:=0; 		(*Spare18*)
	IAS_AO_Spare18:=0; 		(*Spare19*)
	
	IAS_ALM_AlarmWord_1.0:= PRG_Alarms.CommonPLCWarning;; 		(*b0: Common PLC Warning*)
	IAS_ALM_AlarmWord_1.1:= PRG_Alarms.CommonAppWarning; 		(*b1: Common Application Warning*)
	IAS_ALM_AlarmWord_1.2:= PRG_Alarms.CommonIoWarning; 		(*b2: Common IO Warning*)
	IAS_ALM_AlarmWord_1.3:= PRG_Alarms.CommonLevelWarning; 		(*b3: Common Level Warning*)
	IAS_ALM_AlarmWord_1.4:= PRG_Alarms.CommonSignalWarning; 	(*b4: Common Signal Warning*)
	IAS_ALM_AlarmWord_1.5:= PRG_Alarms.CommonE0Warning;			(*b5: Common E0*)
	IAS_ALM_AlarmWord_1.6:= FALSE; (*b6: [spare]*)
	IAS_ALM_AlarmWord_1.7:= FALSE; (*b7: [spare]*)
	IAS_ALM_AlarmWord_1.8:= FALSE; (*b8: [spare]*)
	IAS_ALM_AlarmWord_1.9:= FALSE; (*b9: [spare]*)
	IAS_ALM_AlarmWord_1.10:= FALSE; (*b10: [spare]*)
	IAS_ALM_AlarmWord_1.11:= FALSE; (*b11: [spare]*)
	IAS_ALM_AlarmWord_1.12:= FALSE; (*b12: [spare]*)
	IAS_ALM_AlarmWord_1.13:= FALSE; (*b13: [spare]*)
	IAS_ALM_AlarmWord_1.14:= FALSE; (*b14: [spare]*)
	IAS_ALM_AlarmWord_1.15:= FALSE; (*b15: [spare]*)
	
	IAS_ALM_AlarmWord_2.0:= PRG_BatteryProtection.Common_SE_overVoltage_Warning; 		(*b0: Common Cell Over Voltage Warning*)
	IAS_ALM_AlarmWord_2.1:= PRG_BatteryProtection.Common_SE_underVoltage_Warning; 		(*b1: Common Cell Under Voltage Warning*)
	IAS_ALM_AlarmWord_2.2:= PRG_BatteryProtection.Common_SE_overTemperature_Warning; 	(*b2: Common Cell Over Temperature Warning*)
	IAS_ALM_AlarmWord_2.3:= PRG_BatteryProtection.Common_Module_Communication_Warning; 	(*b3: Common Module Communication Warning*)
	IAS_ALM_AlarmWord_2.4:= PRG_BatteryProtection.Common_OverCurrent_Warning; 			(*b4: Common Over Current Warning*)
	IAS_ALM_AlarmWord_2.5:= PRG_BatteryProtection.Common_Input_PowerLoss_Warning; 		(*b5: Common Input Powerloss Warning*)
	IAS_ALM_AlarmWord_2.6:= PRG_BatteryProtection.Common_PDM_overTemperature_Warning; 	(*b6: Common Power Distribution Module Over Temperature Warning*)
	IAS_ALM_AlarmWord_2.7:= PRG_BatteryProtection.Common_CoolantLeak_Warning; 			(*b7: Common Coolant Water Leakage Warning*)
	IAS_ALM_AlarmWord_2.8:= PRG_BatteryProtection.Warning_SoC_L; 						(*b8: Battery State of Charge Low Alarm*)
	IAS_ALM_AlarmWord_2.9:= PRG_BatteryProtection.Warning_SoC_H; 						(*b9: Battery State of Charge High Alarm*)
	IAS_ALM_AlarmWord_2.10:= PRG_BatteryProtection.batteryPreWarning; 					(*b10: Prewarning from Battery Management System*)
	IAS_ALM_AlarmWord_2.11:= FALSE; (*b11: [spare]*)
	IAS_ALM_AlarmWord_2.12:= FALSE; (*b12: [spare]*)
	IAS_ALM_AlarmWord_2.13:= FALSE; (*b13: [spare]*)
	IAS_ALM_AlarmWord_2.14:= FALSE; (*b14: [spare]*)
	IAS_ALM_AlarmWord_2.15:= FALSE; (*b15: [spare]*)
	
	
	
	
	IAS_ALM_AlarmWord_3:= 0; (* [spare] *)
	IAS_ALM_AlarmWord_4:= 0; (* [spare] *)
	IAS_ALM_AlarmWord_5:= 0; (* [spare] *)
	IAS_ALM_AlarmWord_6:= 0; (* [spare] *)
	IAS_ALM_AlarmWord_7:= 0; (* [spare] *)
	IAS_ALM_AlarmWord_8:= 0; (* [spare] *)
	IAS_ALM_AlarmWord_9:= 0; (* [spare] *)
	IAS_ALM_AlarmWord_10:= 0; (* [spare] *)
	
	IAS_ALM_FaultWord_1.0:= PRG_Faults.CommonAppFault; (*b0: Common Application Fault*)
	IAS_ALM_FaultWord_1.1:= PRG_Faults.CommonLevelFault; (* b1: Common Level Fault*)
	IAS_ALM_FaultWord_1.2:= FALSE; (* b2: [spare]*)
	IAS_ALM_FaultWord_1.3:= FALSE; (* b3: [spare]*)
	IAS_ALM_FaultWord_1.4:= FALSE; (* b4: [spare]*)
	IAS_ALM_FaultWord_1.5:= FALSE; (* b5: [spare]*)
	IAS_ALM_FaultWord_1.6:= FALSE; (* b6: [spare]*)
	IAS_ALM_FaultWord_1.7:= FALSE; (* b7: [spare]*)
	IAS_ALM_FaultWord_1.8:= FALSE; (* b8: [spare]*)
	IAS_ALM_FaultWord_1.9:= FALSE; (* b9: [spare]*)
	IAS_ALM_FaultWord_1.10:= FALSE; (* b10: [spare]*)
	IAS_ALM_FaultWord_1.11:= FALSE; (* b11: [spare]*)
	IAS_ALM_FaultWord_1.12:= FALSE; (* b12: [spare]*)
	IAS_ALM_FaultWord_1.13:= FALSE; (* b13: [spare]*)
	IAS_ALM_FaultWord_1.14:= FALSE; (* b14: [spare]*)
	IAS_ALM_FaultWord_1.15:= FALSE; (* b15: [spare]*)
	
	IAS_ALM_FaultWord_2.0:= PRG_BatteryProtection.Common_SE_overVoltage_Fault; 					(*b0: Common Cell Over Voltage Fault*)
	IAS_ALM_FaultWord_2.1:= PRG_BatteryProtection.Common_SE_underVoltage_Fault; 				(* b1: Common Cell Under Voltage Fault*)
	IAS_ALM_FaultWord_2.2:= PRG_BatteryProtection.Common_SE_overTemperature_Fault; 				(* b2: Common Cell Over Temperature Fault*)
	IAS_ALM_FaultWord_2.3:= PRG_BatteryProtection.Common_HVIL_Fault; 							(* b3: Common High Voltage Interlock Loop fault*)
	IAS_ALM_FaultWord_2.4:= PRG_BatteryProtection.Common_E_Stop_Active_Fault; 					(* b4: Common Emergency Stop Active Fault*)
	IAS_ALM_FaultWord_2.5:= PRG_BatteryProtection.Common_Safety_Shutdown_Fault; 				(* b5: Common Safety Shutdown Fault*)
	IAS_ALM_FaultWord_2.6:= PRG_BatteryProtection.Common_Ground_Fault_Fault; 					(* b6: Common Ground Fault*)
	IAS_ALM_FaultWord_2.7:= PRG_BatteryProtection.Common_Contactor_Fault; 						(* b7: Common Contactor Fault*)
	IAS_ALM_FaultWord_2.8:= PRG_BatteryProtection.Common_Low_Temp_OverCurrent_Fault; 			(* b8: Common Low Temperature Over Current Fault*)
	IAS_ALM_FaultWord_2.9:= PRG_BatteryProtection.Common_Repeated_OverCharge_Lockout_Fault; 	(* b9: Common Repeated Over Charge Lockout Fault*)
	IAS_ALM_FaultWord_2.10:= PRG_BatteryProtection.Common_Deep_OverDischarge_Lockout_Fault; 	(* b10: Common Deep Over Discharge Lockout Fault*)
	IAS_ALM_FaultWord_2.11:= PRG_BatteryProtection.Common_PDM_OverTemperature_Fault; 			(* b11: Common Power Distribution Module Over Temperature Fault*)
	IAS_ALM_FaultWord_2.12:= PRG_BatteryProtection.ProtectionTrip_SoC_HH; 						(* b12: Battery Protection Trip: High State of Charge*)
	IAS_ALM_FaultWord_2.13:= PRG_BatteryProtection.ProtectionTrip_SoC_LL 
							OR PRG_BatteryProtection.ProtectionTrip_SoC_LLL; 					(* b13: Battery Protection Trip: Low State of Charge*)
	IAS_ALM_FaultWord_2.14:= FALSE; (* b14: [spare]*)
	IAS_ALM_FaultWord_2.15:= FALSE; (* b15: [spare]*)
	
	
	
	IAS_ALM_FaultWord_3:= 0; (* [spare] *)
	IAS_ALM_FaultWord_4:= 0; (* [spare] *)
	IAS_ALM_FaultWord_5:= 0; (* [spare] *)
ELSE
	(**
	 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	 * this stuff is only written to when interface testing is ongoing
	 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	*)
					
	
				IAS_STAT_Breaker.0:=			hmi_STAT_Breaker[1]; (*b0: DC Breaker Open*)
				IAS_STAT_Breaker.1:=			hmi_STAT_Breaker[2]; (*b1: DC Breaker Closed*)
				IAS_STAT_Breaker.2:=			hmi_STAT_Breaker[3]; (*b2: AC Breaker Open*)
				IAS_STAT_Breaker.3:=			hmi_STAT_Breaker[4]; (*b3: AC Breaker Closed*)
				
				IAS_STAT_Status.0:=				hmi_STAT_Status[1];	(*b0: Running*)
				IAS_STAT_Status.1:=				hmi_STAT_Status[2];	(*b1: Ready*) 
				IAS_STAT_Status.2:=				hmi_STAT_Status[3];	(*b2: Common Warning*);
				IAS_STAT_Status.3:=				hmi_STAT_Status[4];	(*b3: Common Fault*)  
				IAS_STAT_Status.4:=				hmi_STAT_Status[5];	(*b4: Spare*)  
				IAS_STAT_Status.5:=				hmi_STAT_Status[6];	(*b5: Spare*)  
				IAS_STAT_Status.6:=				hmi_STAT_Status[7];	(*b6: In Local*)  
				IAS_STAT_Status.7:=				hmi_STAT_Status[8];	(*b7: In Remote*)  
				
				IAS_STAT_CellBalancingStatus.0:= 	hmi_STAT_CellBalancingStatus[1]; 	(*b0: 1=Pack 1 All cells in the pack are in balance. *)
				IAS_STAT_CellBalancingStatus.1:= 	hmi_STAT_CellBalancingStatus[2]; 	(*b1: 1=Pack 2 All cells in the pack are in balance. *)
				IAS_STAT_CellBalancingStatus.2:= 	hmi_STAT_CellBalancingStatus[3]; 	(*b2: 1=Pack 3 All cells in the pack are in balance. *)
				IAS_STAT_CellBalancingStatus.3:= 	hmi_STAT_CellBalancingStatus[4]; 	(*b3: 1=Pack 4 All cells in the pack are in balance. *)
				IAS_STAT_CellBalancingStatus.4:= 	hmi_STAT_CellBalancingStatus[5]; 	(*b4: 1=Pack 5 All cells in the pack are in balance. *)
				IAS_STAT_CellBalancingStatus.5:= 	hmi_STAT_CellBalancingStatus[6]; 	(*b5: 1=Pack 6 All cells in the pack are in balance. *)
				IAS_STAT_CellBalancingStatus.6:= 	hmi_STAT_CellBalancingStatus[7]; 	(*b6: 1=Pack 7 All cells in the pack are in balance. *)
				IAS_STAT_CellBalancingStatus.7:= 	hmi_STAT_CellBalancingStatus[8]; 	(*b7: 1=Pack 8 All cells in the pack are in balance. *)
				IAS_STAT_CellBalancingStatus.8:= 	hmi_STAT_CellBalancingStatus[9]; 	(*b8: 1=Pack 9 All cells in the pack are in balance. *)
				IAS_STAT_CellBalancingStatus.9:= 	hmi_STAT_CellBalancingStatus[10]; 	(*b9: 1=Pack 10 All cells in the pack are in balance. *)
				IAS_STAT_CellBalancingStatus.10:= 	hmi_STAT_CellBalancingStatus[11]; 	(*b10: 1=Pack 11 All cells in the pack are in balance. *)
				IAS_STAT_CellBalancingStatus.11:= 	hmi_STAT_CellBalancingStatus[12]; 	(*b11: 1=Pack 12 All cells in the pack are in balance. *)
				IAS_STAT_CellBalancingStatus.12:= 	hmi_STAT_CellBalancingStatus[13]; 	(*b12: 1=Pack 13 All cells in the pack are in balance. *)
				IAS_STAT_CellBalancingStatus.13:= 	hmi_STAT_CellBalancingStatus[14]; 	(*b13: 1=Pack 14 All cells in the pack are in balance. *)
				IAS_STAT_CellBalancingStatus.14:= 	hmi_STAT_CellBalancingStatus[15]; 	(*b14: 1=Pack 15 All cells in the pack are in balance. *)
				IAS_STAT_CellBalancingStatus.15:= 	hmi_STAT_CellBalancingStatus[16]; 	(*b15: 1=Pack 16 All cells in the pack are in balance. *)
				
				IAS_STAT_CellsInBalance.0:= 		hmi_STAT_CellsInBalance[1];	(*b0: 1=Pack 1 All cells in the pack are in balance. *)
				IAS_STAT_CellsInBalance.1:= 		hmi_STAT_CellsInBalance[2];	(*b1: 1=Pack 2 All cells in the pack are in balance. *)
				IAS_STAT_CellsInBalance.2:= 		hmi_STAT_CellsInBalance[3];	(*b2: 1=Pack 3 All cells in the pack are in balance. *)
				IAS_STAT_CellsInBalance.3:= 		hmi_STAT_CellsInBalance[4];	(*b3: 1=Pack 4 All cells in the pack are in balance. *)
				IAS_STAT_CellsInBalance.4:= 		hmi_STAT_CellsInBalance[5];	(*b4: 1=Pack 5 All cells in the pack are in balance. *)
				IAS_STAT_CellsInBalance.5:= 		hmi_STAT_CellsInBalance[6];	(*b5: 1=Pack 6 All cells in the pack are in balance. *)
				IAS_STAT_CellsInBalance.6:= 		hmi_STAT_CellsInBalance[7];	(*b6: 1=Pack 7 All cells in the pack are in balance. *)
				IAS_STAT_CellsInBalance.7:= 		hmi_STAT_CellsInBalance[8];	(*b7: 1=Pack 8 All cells in the pack are in balance. *)
				IAS_STAT_CellsInBalance.8:= 		hmi_STAT_CellsInBalance[9];	(*b8: 1=Pack 9 All cells in the pack are in balance. *)
				IAS_STAT_CellsInBalance.9:= 		hmi_STAT_CellsInBalance[10];(*b9: 1=Pack 10 All cells in the pack are in balance. *)
				IAS_STAT_CellsInBalance.10:= 		hmi_STAT_CellsInBalance[11];(*b10: 1=Pack 11 All cells in the pack are in balance. *)
				IAS_STAT_CellsInBalance.11:= 		hmi_STAT_CellsInBalance[12];(*b11: 1=Pack 12 All cells in the pack are in balance. *)
				IAS_STAT_CellsInBalance.12:= 		hmi_STAT_CellsInBalance[13];(*b12: 1=Pack 13 All cells in the pack are in balance. *)
				IAS_STAT_CellsInBalance.13:= 		hmi_STAT_CellsInBalance[14];(*b13: 1=Pack 14 All cells in the pack are in balance. *)
				IAS_STAT_CellsInBalance.14:= 		hmi_STAT_CellsInBalance[15];(*b14: 1=Pack 15 All cells in the pack are in balance. *)
				IAS_STAT_CellsInBalance.15:= 		hmi_STAT_CellsInBalance[16];(*b15: 1=Pack 16 All cells in the pack are in balance. *)
				
				IAS_STAT_ConnectionWord.0:= 		hmi_STAT_ConnectionWord[1]; (*b0: Pack 1 is connected*) 
				IAS_STAT_ConnectionWord.1:= 		hmi_STAT_ConnectionWord[2]; (*b1: Pack 2 is connected*) 
				IAS_STAT_ConnectionWord.2:= 		hmi_STAT_ConnectionWord[3]; (*b2: Pack 3 is connected*) 
				IAS_STAT_ConnectionWord.3:= 		hmi_STAT_ConnectionWord[4]; (*b3: Pack 4 is connected*) 
				IAS_STAT_ConnectionWord.4:= 		hmi_STAT_ConnectionWord[5]; (*b4: Pack 5 is connected*) 
				IAS_STAT_ConnectionWord.5:= 		hmi_STAT_ConnectionWord[6]; (*b5: Pack 6 is connected*) 
				IAS_STAT_ConnectionWord.6:= 		hmi_STAT_ConnectionWord[7]; (*b6: Pack 7 is connected*) 
				IAS_STAT_ConnectionWord.7:= 		hmi_STAT_ConnectionWord[8]; (*b7: Pack 8 is connected*) 
				IAS_STAT_ConnectionWord.8:= 		hmi_STAT_ConnectionWord[9]; (*b8: Pack 9 is connected*) 
				IAS_STAT_ConnectionWord.9:= 		hmi_STAT_ConnectionWord[10]; (*b9: Pack 10 is connected*) 
				IAS_STAT_ConnectionWord.10:= 		hmi_STAT_ConnectionWord[11]; (*b10: Pack 11 is connected*) 
				IAS_STAT_ConnectionWord.11:= 		hmi_STAT_ConnectionWord[12]; (*b11: Pack 12 is connected*) 
				IAS_STAT_ConnectionWord.12:= 		hmi_STAT_ConnectionWord[13]; (*b12: Pack 13 is connected*) 
				IAS_STAT_ConnectionWord.13:= 		hmi_STAT_ConnectionWord[14]; (*b13: Pack 14 is connected*) 
				IAS_STAT_ConnectionWord.14:= 		hmi_STAT_ConnectionWord[15]; (*b14: Pack 15 is connected*) 
				IAS_STAT_ConnectionWord.15:= 		hmi_STAT_ConnectionWord[16]; (*b15: Pack 16 is connected*) 
				
				IAS_ALM_AlarmWord_1.0:= hmi_ALM_AlarmWord1[1];	(*b0: Common PLC Warning*)
				IAS_ALM_AlarmWord_1.1:= hmi_ALM_AlarmWord1[2];	(*b1: Common Application Warning*)
				IAS_ALM_AlarmWord_1.2:= hmi_ALM_AlarmWord1[3];	(*b2: Common IO Warning*)
				IAS_ALM_AlarmWord_1.3:= hmi_ALM_AlarmWord1[4];	(*b3: Common Level Warning*)
				IAS_ALM_AlarmWord_1.4:= hmi_ALM_AlarmWord1[5];	(*b4: Common Signal Warning*)
				IAS_ALM_AlarmWord_1.5:= hmi_ALM_AlarmWord1[6];	(*b5: Common E0*)
				IAS_ALM_AlarmWord_1.6:= hmi_ALM_AlarmWord1[7]; 	(*b6: [spare]*)
				IAS_ALM_AlarmWord_1.7:= hmi_ALM_AlarmWord1[8]; 	(*b7: [spare]*)
				IAS_ALM_AlarmWord_1.8:= hmi_ALM_AlarmWord1[9]; 	(*b8: [spare]*)
				IAS_ALM_AlarmWord_1.9:= hmi_ALM_AlarmWord1[10]; (*b9: [spare]*)
				IAS_ALM_AlarmWord_1.10:= hmi_ALM_AlarmWord1[11];(*b10: [spare]*)
				IAS_ALM_AlarmWord_1.11:= hmi_ALM_AlarmWord1[12];(*b11: [spare]*)
				IAS_ALM_AlarmWord_1.12:= hmi_ALM_AlarmWord1[13];(*b12: [spare]*)
				IAS_ALM_AlarmWord_1.13:= hmi_ALM_AlarmWord1[14];(*b13: [spare]*)
				IAS_ALM_AlarmWord_1.14:= hmi_ALM_AlarmWord1[15];(*b14: [spare]*)
				IAS_ALM_AlarmWord_1.15:= hmi_ALM_AlarmWord1[16];(*b15: [spare]*)
				
				IAS_ALM_AlarmWord_2.0:= hmi_ALM_AlarmWord2[1];	(*b0: Common Cell Over Voltage Warning*)
				IAS_ALM_AlarmWord_2.1:= hmi_ALM_AlarmWord2[2]; 	(*b1: Common Cell Under Voltage Warning*)
				IAS_ALM_AlarmWord_2.2:= hmi_ALM_AlarmWord2[3]; 	(*b2: Common Cell Over Temperature Warning*)
				IAS_ALM_AlarmWord_2.3:= hmi_ALM_AlarmWord2[4]; 	(*b3: Common Module Communication Warning*)
				IAS_ALM_AlarmWord_2.4:= hmi_ALM_AlarmWord2[5]; 	(*b4: Common Over Current Warning*)
				IAS_ALM_AlarmWord_2.5:= hmi_ALM_AlarmWord2[6]; 	(*b5: Common Input Powerloss Warning*)
				IAS_ALM_AlarmWord_2.6:= hmi_ALM_AlarmWord2[7]; 	(*b6: Common Power Distribution Module Over Temperature Warning*)
				IAS_ALM_AlarmWord_2.7:= hmi_ALM_AlarmWord2[8]; 	(*b7: Common Coolant Water Leakage Warning*)
				IAS_ALM_AlarmWord_2.8:= hmi_ALM_AlarmWord2[9]; 	(*b8: Battery State of Charge Low Alarm*)
				IAS_ALM_AlarmWord_2.9:= hmi_ALM_AlarmWord2[10]; (*b9: Battery State of Charge High Alarm*)
				IAS_ALM_AlarmWord_2.10:= hmi_ALM_AlarmWord2[11];(*b10: Prewarning from Battery Management System*)
				IAS_ALM_AlarmWord_2.11:= hmi_ALM_AlarmWord2[12];(*b11: [spare]*)
				IAS_ALM_AlarmWord_2.12:= hmi_ALM_AlarmWord2[13];(*b12: [spare]*)
				IAS_ALM_AlarmWord_2.13:= hmi_ALM_AlarmWord2[14];(*b13: [spare]*)
				IAS_ALM_AlarmWord_2.14:= hmi_ALM_AlarmWord2[15];(*b14: [spare]*)
				IAS_ALM_AlarmWord_2.15:= hmi_ALM_AlarmWord2[16];(*b15: [spare]*)
				
				IAS_ALM_FaultWord_1.0:= hmi_ALM_FaultWord1[1];	(*b0: Common Application Fault*)
				IAS_ALM_FaultWord_1.1:= hmi_ALM_FaultWord1[2]; 	(* b1: Common Level Fault*)
				IAS_ALM_FaultWord_1.2:= hmi_ALM_FaultWord1[3]; 	(* b2: [spare]*)
				IAS_ALM_FaultWord_1.3:= hmi_ALM_FaultWord1[4]; 	(* b3: [spare]*)
				IAS_ALM_FaultWord_1.4:= hmi_ALM_FaultWord1[5]; 	(* b4: [spare]*)
				IAS_ALM_FaultWord_1.5:= hmi_ALM_FaultWord1[6]; 	(* b5: [spare]*)
				IAS_ALM_FaultWord_1.6:= hmi_ALM_FaultWord1[7]; 	(* b6: [spare]*)
				IAS_ALM_FaultWord_1.7:= hmi_ALM_FaultWord1[8]; 	(* b7: [spare]*)
				IAS_ALM_FaultWord_1.8:= hmi_ALM_FaultWord1[9]; 	(* b8: [spare]*)
				IAS_ALM_FaultWord_1.9:= hmi_ALM_FaultWord1[10];	(* b9: [spare]*)
				IAS_ALM_FaultWord_1.10:= hmi_ALM_FaultWord1[11];(* b10: [spare]*)
				IAS_ALM_FaultWord_1.11:= hmi_ALM_FaultWord1[12];(* b11: [spare]*)
				IAS_ALM_FaultWord_1.12:= hmi_ALM_FaultWord1[13];(* b12: [spare]*)
				IAS_ALM_FaultWord_1.13:= hmi_ALM_FaultWord1[14];(* b13: [spare]*)
				IAS_ALM_FaultWord_1.14:= hmi_ALM_FaultWord1[15];(* b14: [spare]*)
				IAS_ALM_FaultWord_1.15:= hmi_ALM_FaultWord1[16];(* b15: [spare]*)
				
				IAS_ALM_FaultWord_2.0:= hmi_ALM_FaultWord2[1];	(*b0: Common Cell Over Voltage Fault*)
				IAS_ALM_FaultWord_2.1:= hmi_ALM_FaultWord2[2]; 	(* b1: Common Cell Under Voltage Fault*)
				IAS_ALM_FaultWord_2.2:= hmi_ALM_FaultWord2[3]; 	(* b2: Common Cell Over Temperature Fault*)
				IAS_ALM_FaultWord_2.3:= hmi_ALM_FaultWord2[4]; 	(* b3: Common High Voltage Interlock Loop fault*)
				IAS_ALM_FaultWord_2.4:= hmi_ALM_FaultWord2[5]; 	(* b4: Common Emergency Stop Active Fault*)
				IAS_ALM_FaultWord_2.5:= hmi_ALM_FaultWord2[6]; 	(* b5: Common Safety Shutdown Fault*)
				IAS_ALM_FaultWord_2.6:= hmi_ALM_FaultWord2[7]; 	(* b6: Common Ground Fault*)
				IAS_ALM_FaultWord_2.7:= hmi_ALM_FaultWord2[8]; 	(* b7: Common Contactor Fault*)
				IAS_ALM_FaultWord_2.8:= hmi_ALM_FaultWord2[9]; 	(* b8: Common Low Temperature Over Current Fault*)
				IAS_ALM_FaultWord_2.9:= hmi_ALM_FaultWord2[10]; (* b9: Common Repeated Over Charge Lockout Fault*)
				IAS_ALM_FaultWord_2.10:= hmi_ALM_FaultWord2[11];(* b10: Common Deep Over Discharge Lockout Fault*)
				IAS_ALM_FaultWord_2.11:= hmi_ALM_FaultWord2[12];(* b11: Common Power Distribution Module Over Temperature Fault*)
				IAS_ALM_FaultWord_2.12:= hmi_ALM_FaultWord2[13];(* b12: Battery Protection Trip: High State of Charge*)
				IAS_ALM_FaultWord_2.13:= hmi_ALM_FaultWord2[14];(* b13: Battery Protection Trip: Low State of Charge*)
				IAS_ALM_FaultWord_2.14:= hmi_ALM_FaultWord2[15];(* b14: [spare]*)
				IAS_ALM_FaultWord_2.15:= hmi_ALM_FaultWord2[16];(* b15: [spare]*)	
	
	
	
	(*
	 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	 * end of stuff that is written to in interface test mode
	 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *  
	*)
	
END_IF



IasCommunication(
	WD_IN				:= 		IAS_CTRL_WatchdogFB,
	Alarm_Delay 		:=		PRG_HMI.SetupIasCom.iasComAlarmDelay,
	Reset 				:= 		PRG_Functions.Reset,
	EnExtCount 			:= 		PRG_HMI.SetupIasCom.enableExternalCounter,
	enableAlarm			:=		PRG_HMI.SetupIasCom.enableAlarm,
	Counter_delay 		:= 		PRG_HMI.SetupIasCom.iasComCounterDelay,
	WD_OUT 				=>		IAS_STAT_Watchdog,
	Alarm 				=> 		 
);


(* IAS extended state machine status containing prewarning and shutdown *)
IF (PRG_BatteryProtection.batteryPreWarning AND NOT (PRG_StateMain.tripStatus <> 0)) THEN
	Extended_Statemachine := 6;
ELSIF (PRG_StateMain.tripStatus <> 0) THEN
	Extended_Statemachine := 7;
ELSE
	Extended_Statemachine := PRG_StateMain.State;;
END_IF

END_PROGRAM

ACTIONS

END_ACTIONS