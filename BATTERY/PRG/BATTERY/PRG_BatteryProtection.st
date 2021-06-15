PROGRAM PRG_BatteryProtection
VAR
	(* Find any BMS Array warning associated with a pre-warning*)
	batteryPreWarning: 			BOOL; 					(*True if any pack has one or more prewarning alarms*)
	BatteryPreWarnings_Array: 	ARRAY[1..16] OF INT; 	(*Array to gather information about prewarning alarms from all packs*)
	
	(*Find any common warning from the battery array*)
	batteryCommonWarning: 		BOOL; 					(*True if any pack has one or more warnings*)
	BatteryWarnings_Array: 		ARRAY[1..16] OF INT; 	(*Array to gather information about warning alarms from all packs*)
	
	(*Find any common fault from the battery array*)
	batteryCommonFault: 		BOOL; (*True if any pack has an active/unacknowledged fault*)

	(*Common Faults from Battery Array*)
	Common_SE_overVoltage_Fault_Array: 					ARRAY[1..16] OF INT; (*Array of BOOLs from BMS: *)
	Common_SE_underVoltage_Fault_Array: 				ARRAY[1..16] OF INT; (*Array of BOOLs from BMS: *)
	Common_SE_overTemperature_Fault_Array: 				ARRAY[1..16] OF INT; (*Array of BOOLs from BMS: *)
	Common_HVIL_Fault_Array: 							ARRAY[1..16] OF INT; (*Array of BOOLs from BMS: *)
	Common_E_Stop_Active_Fault_Array: 					ARRAY[1..16] OF INT; (*Array of BOOLs from BMS: *)
	Common_Safety_Shutdown_Fault_Array: 				ARRAY[1..16] OF INT; (*Array of BOOLs from BMS: *)
	Common_Ground_Fault_Fault_Array: 					ARRAY[1..16] OF INT; (*Array of BOOLs from BMS: *)
	Common_Contactor_Fault_Array: 						ARRAY[1..16] OF INT; (*Array of BOOLs from BMS: *)
	Common_Low_Temp_OverCurrent_Fault_Array: 			ARRAY[1..16] OF INT; (*Array of BOOLs from BMS: *)
	Common_Repeated_OverCharge_Lockout_Fault_Array: 	ARRAY[1..16] OF INT; (*Array of BOOLs from BMS: *)
	Common_Deep_OverDischarge_Lockout_Fault_Array: 		ARRAY[1..16] OF INT; (*Array of BOOLs from BMS: *)
	Common_PDM_OverTemperature_Fault_Array: 			ARRAY[1..16] OF INT; (*Array of BOOLs from BMS: *)
	
	Common_SE_overVoltage_Fault: 				BOOL; (*Any pack has a Cell Over Voltage Fault*)
	Common_SE_underVoltage_Fault: 				BOOL; (*Any pack has a Cell Under Voltage Fault*)
	Common_SE_overTemperature_Fault: 			BOOL; (*Any pack has a Cell Over Temperature Fault*)
	Common_HVIL_Fault: 							BOOL; (*Any pack has a High Voltage Interlock Loop fault*) 
	Common_E_Stop_Active_Fault: 				BOOL; (*Any pack has a Emergency Stop Active Fault*)
	Common_Safety_Shutdown_Fault: 				BOOL; (*Any pack has a Safety Shutdown Fault*)
	Common_Ground_Fault_Fault: 					BOOL; (*Any pack has a Ground Fault*)
	Common_Contactor_Fault: 					BOOL; (*Any pack has a Contactor Fault*)
	Common_Low_Temp_OverCurrent_Fault: 			BOOL; (*Any pack has a Low Temperature Over Current Fault*)
	Common_Repeated_OverCharge_Lockout_Fault: 	BOOL; (*Any pack has a Repeated Over Charge Lockout Fault*)
	Common_Deep_OverDischarge_Lockout_Fault: 	BOOL; (*Any pack has a Common Deep Over Discharge Lockout Fault*)
	Common_PDM_OverTemperature_Fault: 			BOOL; (*Any pack has a Power Distribution Module Over Temperature Fault*)
	

	(*Common Warnings from Battery Array*)
	Common_SE_overVoltage_Warning_Array: 		ARRAY[1..16] OF INT; (*Array of BOOLs from BMS: *)
	Common_SE_underVoltage_Warning_Array: 		ARRAY[1..16] OF INT; (*Array of BOOLs from BMS: *)
	Common_SE_overTemperature_Warning_Array: 	ARRAY[1..16] OF INT; (*Array of BOOLs from BMS: *)
	Common_Module_Communication_Warning_Array: 	ARRAY[1..16] OF INT; (*Array of BOOLs from BMS: *)
	Common_OverCurrent_Warning_Array: 			ARRAY[1..16] OF INT; (*Array of BOOLs from BMS: *)
	Common_Input_PowerLoss_Warning_Array: 		ARRAY[1..16] OF INT; (*Array of BOOLs from BMS: *)
	Common_PDM_overTemperature_Warning_Array: 	ARRAY[1..16] OF INT; (*Array of BOOLs from BMS: *)
	Common_CoolantLeak_Warning_Array: 			ARRAY[1..16] OF INT; (*Array of BOOLs from BMS: *)
	Common_SE_overVoltage_Warning: 				BOOL; (*Any pack has a Common Cell Over Voltage Warning*)
	Common_SE_underVoltage_Warning: 			BOOL; (*Any pack has a Common Cell Under Voltage Warning*)
	Common_SE_overTemperature_Warning: 			BOOL; (*Any pack has a Common Cell Over Temperature Warning*)
	Common_Module_Communication_Warning: 		BOOL; (*Any pack has a Common Module Communication Warning*)
	Common_OverCurrent_Warning: 				BOOL; (*Any pack has a Common Over Current Warning*)
	Common_Input_PowerLoss_Warning: 			BOOL; (*Any pack has a Common Input Powerloss Warning*)
	Common_PDM_overTemperature_Warning: 		BOOL; (*Any pack has a Common Power Distribution Module Over Temperature Warning*)
	Common_CoolantLeak_Warning: 				BOOL; (*Any pack has a Common Coolant Water Leakage Warning*)
	
	
	CorvusRead: 			ARRAY [1..16] OF str_Corvus_ALL; (*The almighty Corvus BMS Array-Array*)
	BatteryAlone :			BOOL; 			(*If battery is alone, lower SoC trip limit is decreased*)
	BatteryCharging:	 	BOOL;			(*If battery is charging, discharging is still allowed beyond limits*)
	ConfigError:			INT;			(*Check that all protection settings are within hardcoded limits*)
	
	TripBasket : 			fb_16DelayedSR;	(*Collection basket for protection trips*)
	WarningBasket :			fb_16DelayedSR; (*Collection basket for warnings*)
	ProtectionTrip: 		DINT;			(*All bits from protection trips*)
	ChargeLimitWord :		WORD;			(*Word with bit-conditions for stop charging*)
	DischargeLimitWord :	WORD;			(*Word with bit-conditions for stop discharging*)
	
	Warning_SoC_L : 				BOOL;	(*Warning or trip bit*)
	Warning_SoC_L_Offline :			BOOL;	(*Warning or trip bit*)
	Warning_SoC_LL_Offline :		BOOL;	(*Warning or trip bit*)
	Warning_SoC_H : 				BOOL;	(*Warning or trip bit*)
	Warning_Volt_L : 				BOOL;	(*Warning or trip bit*)
	Warning_Volt_H : 				BOOL;	(*Warning or trip bit*)
	Warning_CellVolt_H :			BOOL;	(*Warning or trip bit*)
	Warning_CellVolt_L :			BOOL;	(*Warning or trip bit*)
	Warning_CellVolt_L_Offline :	BOOL;	(*Warning or trip bit*)
	Warning_CellVolt_LL_Offline :	BOOL;	(*Warning or trip bit*)
	Warning_CellTemp_H :			BOOL;	(*Warning or trip bit*)
	Warning_CellTemp_L :			BOOL;	(*Warning or trip bit*)
	Warning_BattRoomTemp_HH:		BOOL;	(*Warning or trip bit*)
	Warning_BattRoomTemp_H:			BOOL;	(*Warning or trip bit*)
	Warning_BattRoomTemp_L:			BOOL;	(*Warning or trip bit*)
	Warning_BattRoomTemp_LL:		BOOL;	(*Warning or trip bit*)
	
	ProtectionTrip_SoC_HH: 			BOOL;	(*Warning or trip bit*)
	ProtectionTrip_SoC_LL: 			BOOL;	(*Warning or trip bit*)
	ProtectionTrip_SoC_LLL: 		BOOL;	(*Warning or trip bit*)
	ProtectionTrip_CellTemp_HH:		BOOL;	(*Warning or trip bit*)
	ProtectionTrip_CellVolt_HH:		BOOL;	(*Warning or trip bit*)
	ProtectionTrip_CellVolt_LL:		BOOL;	(*Warning or trip bit*)
	ProtectionTrip_Overvoltage: 	BOOL;	(*Warning or trip bit*)
	ProtectionTrip_Undervoltage: 	BOOL;	(*Warning or trip bit*)
	M:INT;
	
	(*Offline Protection*)
	ForceSleepMode :		BOOL;					(*Conditions are so that we want to force batteries to sleep*)
	i: 						INT;					(*Looping variable*)
	minCellVoltage: 		REAL := 0;				(*The lowest cell voltage in the array*)
	minCellVoltageArray: 	ARRAY[1..16] OF REAL;	(*Array of lowest cell voltages in battery packs*)
	maxCellVoltage: 		REAL := 0;				(*The highest cell voltage in the array*)
	maxCellVoltageArray: 	ARRAY[1..16] OF REAL;	(*Array of highest cell voltages in battery packs*)
	
	minCellTemp: 			REAL := 0;				(*The lowest cell temperature in the array*)
	minCellTempArray: 		ARRAY[1..16] OF REAL;	(*Array of lowest cell temperature in battery packs*)
	maxCellTemp: 			REAL := 0;				(*The highest cell temperature in the array*)
	maxCellTempArray: 		ARRAY[1..16] OF REAL;	(*Array of highest cell temperature in battery packs*)
	
	minPackSoC: 			REAL := 0;				(*The lowest pack state of charge in the array*)
	minPackSoCArray: 		ARRAY[1..16] OF REAL;	(*Array of lowest pack state of charge in battery arrays*)
	maxPackSoC: 			REAL := 0;				(*The highest pack state of charge in the array*)
	maxPackSoCArray: 		ARRAY[1..16] OF REAL;	(*Array of highest pack state of charge in battery arrays*)
END_VAR

(*Read variables from other programs*)
CorvusRead :=		PRG_BatteryComm.CorvusRead;
M := 				PRG_BatteryComm.M;
BatteryCharging := 	PRG_Battery.batteryCharging;


(*BatteryAlone signal from PMS - SoC LL Trip is lowered to minimum*)
BatteryAlone := PRG_IAS.IAS_BatteryAlone;

(*Make sure that limits are within allowed values to exit init state in prg_StateMain*)
ConfigError.0 :=	(PRG_HMI.SetupBatLimits.SoCTripHH > setup_SoC_HH_Trip);
ConfigError.1 :=	(PRG_HMI.SetupBatLimits.SoCTripLL < setup_SoC_LLL_Trip);
ConfigError.2 :=	(PRG_HMI.SetupBatLimits.VoltTripHH > setup_Battery_Max_Voltage);
ConfigError.3 :=	(PRG_HMI.SetupBatLimits.VoltTripLL < setup_Battery_Min_Voltage);
ConfigError.4 :=	(PRG_HMI.SetupBatLimits.CellVoltTripHH > setup_Battery_CellVolt_HH_Trip);
ConfigError.5 :=	(PRG_HMI.SetupBatLimits.CellVoltTripLL < setup_Battery_CellVolt_LL_Trip);
ConfigError.6 :=	(PRG_HMI.SetupBatLimits.SoCTripLL_Offline < setup_Battery_SoC_Offline_LL_Trip);
ConfigError.7 :=	(PRG_HMI.SetupBatLimits.CellVoltTripLL_Offline < setup_Battery_CellVolt_Offline_LL_Trip);
ConfigError.8 :=	(PRG_HMI.SetupBatLimits.CellTempTripHH > setup_Battery_CellTemp_HH_Trip);
ConfigError.9 :=	FALSE;
ConfigError.10 :=	FALSE;
ConfigError.11 :=	FALSE;
ConfigError.12 :=	FALSE;
ConfigError.13 :=	FALSE;
ConfigError.14 :=	FALSE;
ConfigError.15 :=	FALSE;


ChargeLimitWord.0 := 	CorvusRead[M].theArray.systemOnlineSOC	> 	PRG_HMI.SetupBatLimits.SoCAlarmH;
ChargeLimitWord.1 := 	CorvusRead[M].theArray.maxCellVoltage	> 	PRG_HMI.SetupBatLimits.CellVoltAlarmH;
ChargeLimitWord.2 := 	CorvusRead[M].theArray.busVoltage 		> 	PRG_HMI.SetupBatLimits.VoltAlarmH;
ChargeLimitWord.3 := 	CorvusRead[M].theArray.systemOnlineSOC 	> 	PRG_HMI.SetupBatLimits.SoCAlarmH;

DischargeLimitWord.0 := (CorvusRead[M].theArray.systemOnlineSOC < 	PRG_HMI.SetupBatLimits.SoCAlarmL) 		AND PRG_Battery.BatteryMinOneConnected AND NOT BatteryAlone AND NOT (PRG_StateMain.State = e_Stopping);
DischargeLimitWord.1 :=	(CorvusRead[M].theArray.minCellVoltage 	< 	PRG_HMI.SetupBatLimits.CellVoltAlarmL) AND PRG_Battery.BatteryMinOneConnected AND NOT BatteryAlone AND NOT (PRG_StateMain.State = e_Stopping);
DischargeLimitWord.2 := (CorvusRead[M].theArray.busVoltage 		< 	PRG_HMI.SetupBatLimits.VoltAlarmL) 	AND PRG_Battery.BatteryMinOneConnected AND NOT BatteryAlone AND NOT (PRG_StateMain.State = e_Stopping);


(*All faults are collected here with individual time delay and latched output*)
TripBasket(
 
 	(* Prevent over SoC when charging *)
	in1 := ((CorvusRead[M].theArray.systemOnlineSOC > PRG_HMI.SetupBatLimits.SoCTripHH)
	 		AND (PRG_BatteryComm.CorvusRead[M].theArray.busPowerCalculated > -50) (*must be more than 50 kW discharging power before cancelling trip timer*)
	),
	delay1 := T#30s,
	out1 => ProtectionTrip_SoC_HH,

	(* Prevent Under SoC when discharging and there are other power sources on the switchboard *)
	in2 := ((CorvusRead[M].theArray.systemOnlineSOC < PRG_HMI.SetupBatLimits.SoCTripLL)
			AND NOT BatteryCharging
	 		AND PRG_Battery.BatteryMinOneConnected
	 		AND NOT BatteryAlone
	),
	delay2 := T#30s,
	out2 => ProtectionTrip_SoC_LL,

	(* Prevent Under SoC when discharging*)
	in3 := ((CorvusRead[M].theArray.systemOnlineSOC < PRG_HMI.SetupBatLimits.SoCTripLL) 
	 		AND PRG_Battery.BatteryMinOneConnected
	 		AND (PRG_BatteryComm.CorvusRead[M].theArray.busPowerCalculated < 50) (*must be more than 50 kW charging power before cancelling trip timer*)
	),
	delay3 := T#30s,
	out3 => ProtectionTrip_SoC_LLL,
	
	(*Over Voltage Trip*)
	in4 := ((CorvusRead[M].theArray.busVoltage > PRG_HMI.SetupBatLimits.VoltTripHH)
	 		AND BatteryCharging 
	),
	delay4 := T#30s,
	out4 => ProtectionTrip_Overvoltage,
	
	(*Under Voltage Trip*)
	in5 := ((CorvusRead[M].theArray.busVoltage < PRG_HMI.SetupBatLimits.VoltTripLL)
	 		AND NOT BatteryCharging 
			AND  PRG_Battery.BatteryMinOneConnected
	),
	delay5 := T#30s,
	out5 => ProtectionTrip_Undervoltage,
	
	(*Cell over voltage trip*)
	in6 := (maxCellVoltage > PRG_HMI.SetupBatLimits.CellVoltTripHH
	 		AND PRG_Battery.BatteryMinOneConnected
	),
	delay6 := T#30s,
	out6 => ProtectionTrip_CellVolt_HH,
	
	(*Cell under voltage trip*)
	in7 := ((minCellVoltage < PRG_HMI.SetupBatLimits.CellVoltTripLL)
			AND NOT BatteryCharging 
			AND  PRG_Battery.BatteryMinOneConnected
	),
	delay7 := T#30s,
	out7 => ProtectionTrip_CellVolt_LL,
	
	(*Cell over temperature trip*)
	in8 := (maxCellTemp > PRG_HMI.SetupBatLimits.CellTempTripHH 
	 		AND PRG_Battery.BatteryMinOneConnected),
	delay8 := T#30s,
	out8 => ProtectionTrip_CellTemp_HH,
	
	in9 := FALSE,
	delay9 := T#0s,
	out9 => ,
	
	in10 := FALSE,
	delay10 := T#0s,
	out10 => ,
	
	in11 := FALSE,
	delay11 := T#0s,
	out11 => ,
	
	in12 := FALSE,
	delay12 := T#0s,
	out12 => ,
	
	in13 := FALSE,
	delay13 := T#0s,
	out13 => ,
	
	in14 := FALSE,
	delay14 := T#0s,
	out14 => ,
	
	in15 := FALSE,
	delay15 := T#0s,
	out15 => ,
	
	in16 := FALSE,
	delay16 := T#0s,
	out16 => ,
	
	Reset := PRG_Functions.Reset,
	outCommon => ProtectionTrip
);


(*All warnings are collected here with individual time delay and latched output*)
WarningBasket(
 
 	(*Low State of Charge Warning*)
	in1 := (CorvusRead[M].theArray.systemOnlineSOC < PRG_HMI.SetupBatLimits.SoCAlarmL) 
			AND (CorvusRead[M].theArray.nrOfPackConnected > 0),
	delay1 := T#5s,
	out1 => Warning_SoC_L,
	
	(*High State of Charge Warning*)
	in2 := (CorvusRead[M].theArray.systemOnlineSOC > PRG_HMI.SetupBatLimits.SoCAlarmH),
	delay2 := T#5s,
	out2 => Warning_SoC_H,
	
	(*Low Battery Voltage Warning*)
	in3 := (CorvusRead[M].theArray.busVoltage < PRG_HMI.SetupBatLimits.VoltAlarmL) 
			AND (CorvusRead[M].theArray.nrOfPackConnected > 0),
	delay3 := T#5s,
	out3 => Warning_Volt_L,
	
	(*High Battery Voltage Warning*)
	in4 := CorvusRead[M].theArray.busVoltage > PRG_HMI.SetupBatLimits.VoltAlarmH,
	delay4 := T#5s,
	out4 => Warning_Volt_H,
	
	(*High Cell Voltage*)
	in5 := maxCellVoltage > PRG_HMI.SetupBatLimits.CellVoltAlarmH,
	delay5 := T#5s,
	out5 => Warning_CellVolt_H,
	
	(*High Cell Temperature*)
	in6 := maxCellTemp > PRG_HMI.SetupBatLimits.CellTempAlarmH,
	delay6 := T#5s,
	out6 => Warning_CellTemp_H,
	
	(*Low Cell Voltage*)
	in7 := ((minCellVoltage < PRG_HMI.SetupBatLimits.CellVoltAlarmL) 
	 			AND (minCellVoltage <> 0) (*We don't believe in zero values*)
	 			AND NOT PRG_BatteryComm.CorvusBMS_Total_Comm_Fault
	),
	delay7 := T#5s,
	out7 => Warning_CellVolt_L,
	
	(*Low Cell Temperature*)
	in8 := ((minCellTemp < PRG_HMI.SetupBatLimits.CellTempAlarmL) 
	 			AND (minCellTemp <> 0) (*Zero might be plausible here, but if it is real it has nonetheless triggered the alarm when passing the limit on its way down*)
	 			AND NOT PRG_BatteryComm.CorvusBMS_Total_Comm_Fault
	),
	delay8 := T#5s,
	out8 => Warning_CellTemp_L,
	
	(*OFFLINE: Low SoC*)
	in9 := ((minPackSoC < PRG_HMI.SetupBatLimits.SoCAlarmL_Offline)
	 			AND NOT PRG_BatteryComm.CorvusBMS_Total_Comm_Fault
	),
	delay9 := T#5s,
	out9 => Warning_SoC_L_Offline,
	
	(*OFFLINE: Low Cell Voltage*)
	in10 := ((minCellVoltage < PRG_HMI.SetupBatLimits.CellVoltAlarmL_Offline) 
	 			AND (minCellVoltage <> 0)  (*We don't believe in zero values*)
	 			AND NOT PRG_BatteryComm.CorvusBMS_Total_Comm_Fault
	),
	delay10 := T#5s,
	out10 => Warning_CellVolt_L_Offline,
	
	(*OFFLINE: Low Low Cell Voltage*)
	in11 := ((minCellVoltage < PRG_HMI.SetupBatLimits.CellVoltTripLL_Offline) 
	 			AND (minCellVoltage <> 0)  (*We don't believe in zero values*)
	 			AND NOT PRG_BatteryComm.CorvusBMS_Total_Comm_Fault),
	delay11 := T#5s,
	out11 => Warning_CellVolt_LL_Offline,
	
	(*Low SoC while Offline*)
	in12 := ((minPackSoC < PRG_HMI.SetupBatLimits.SoCTripLL_Offline) 
	 			AND NOT PRG_BatteryComm.CorvusBMS_Total_Comm_Fault
	),
	delay12 := T#5s,
	out12 => Warning_SoC_LL_Offline,
	
	Reset:= PRG_Functions.Reset,
	outCommon => 
);



(* 
 * ======================================================================================================================================= 
 * Offline Protection
 * =======================================================================================================================================
*)


ForceSleepMode := ((minCellTemp < PRG_HMI.SetupBatLimits.CellVoltTripLL_Offline) OR (minPackSoC < PRG_HMI.SetupBatLimits.SoCTripLL_Offline)) AND NOT BatteryCharging;


(*----------------------------------------Find lowest and highest cell voltage----------------------------------------*)

(*Find lowest cell voltage in array*)
FOR i:=1 TO PRG_HMI.setup_Battery_total_nr_of_packs BY 1 DO
	minCellVoltageArray[i] := DINT_TO_REAL(CorvusRead[i].Pack.minCellVoltage);
END_FOR
(*If there are fewer packs than 16, make sure that there are no zeros in the array as we are looking for the lowest number. *)
IF (PRG_HMI.setup_Battery_total_nr_of_packs < 16) THEN
	FOR i:=(PRG_HMI.setup_Battery_total_nr_of_packs+1) TO 16 BY 1 DO
		minCellVoltageArray[i] := 9999;
	END_FOR
END_IF
(*Finally, find the lowest cell voltage and store it*)
minCellVoltage := REAL_TO_INT(ARRAY_MIN(pt := ADR(minCellVoltageArray), size:=SIZEOF(minCellVoltageArray)));


(*Find highest cell voltage in array*)
FOR i:=1 TO PRG_HMI.setup_Battery_total_nr_of_packs BY 1 DO
	maxCellVoltageArray[i] := DINT_TO_REAL(CorvusRead[i].Pack.maxCellVoltage);
END_FOR

(*Finally, find the highest cell voltage and store it*)
maxCellVoltage := REAL_TO_INT(ARRAY_MAX(pt := ADR(maxCellVoltageArray), size:=SIZEOF(maxCellVoltageArray)));


(*--------------------------------------Find lowest and highest cell temperature--------------------------------------*)

(*Find lowest cell temperature in array*)
FOR i:=1 TO PRG_HMI.setup_Battery_total_nr_of_packs BY 1 DO
	minCellTempArray[i] := DINT_TO_REAL(CorvusRead[i].Pack.minCellTemp);
END_FOR
(*If there are fewer packs than 16, make sure that there are no zeros in the array as we are looking for the lowest number. *)
IF (PRG_HMI.setup_Battery_total_nr_of_packs < 16) THEN
	FOR i:=(PRG_HMI.setup_Battery_total_nr_of_packs+1) TO 16 BY 1 DO
		minCellTempArray[i] := 9999;
	END_FOR
END_IF
(*Finally, find the lowest cell temperature and store it*)
minCellTemp := REAL_TO_INT(ARRAY_MIN(pt := ADR(minCellTempArray), size:=SIZEOF(minCellTempArray)));


(*Find highest cell temperature in array*)
FOR i:=1 TO PRG_HMI.setup_Battery_total_nr_of_packs BY 1 DO
	maxCellTempArray[i] := DINT_TO_REAL(CorvusRead[i].Pack.maxCellTemp);
END_FOR

(*Finally, find the highest cell temperature and store it*)
maxCellTemp := REAL_TO_INT(ARRAY_MAX(pt := ADR(maxCellTempArray), size:=SIZEOF(maxCellTempArray)));


(*------------------------------------------Find lowest and highest pack SoC------------------------------------------*)

(*Find lowest pack SoC in array*)
FOR i:=1 TO PRG_HMI.setup_Battery_total_nr_of_packs BY 1 DO
	minPackSoCArray[i] := DINT_TO_REAL(CorvusRead[i].Pack.SOC);
END_FOR
(*If there are fewer packs than 16, make sure that there are no zeros in the array as we are looking for the lowest number. *)
IF (PRG_HMI.setup_Battery_total_nr_of_packs < 16) THEN
	FOR i:=(PRG_HMI.setup_Battery_total_nr_of_packs+1) TO 16 BY 1 DO
		minPackSoCArray[i] := 9999;
	END_FOR
END_IF
(*Finally, find the lowest pack SoC and store it*)
minPackSoC := REAL_TO_INT(ARRAY_MIN(pt := ADR(minPackSoCArray), size:=SIZEOF(minPackSoCArray)));


(*Find highest pack SoC in array*)
FOR i:=1 TO PRG_HMI.setup_Battery_total_nr_of_packs BY 1 DO
	maxPackSoCArray[i] := DINT_TO_REAL(CorvusRead[i].Pack.SOC);
END_FOR

(*Finally, find the highest pack SoC and store it*)
maxPackSoC := REAL_TO_INT(ARRAY_MAX(pt := ADR(maxPackSoCArray), size:=SIZEOF(maxPackSoCArray)));







(* 
 * ======================================================================================================================================= 
 * Check and for faults, warning and prewarnings
 * =======================================================================================================================================
*)


(*Check for any faults*)
batteryCommonFault := (PRG_BatteryComm.CorvusRead[M].theArray.nrOfPackFault <> 0);

(* 
 * ======================================================================================================================================= 
 * Search and Create Common Warnings and Faults from BMS
 * =======================================================================================================================================
*)

FOR i:=1 TO PRG_HMI.setup_Battery_total_nr_of_packs BY 1 DO

	(*---------------------------WARNINGS---------------------------*)
	
	(*Common Cell Over Voltage Warning*)
	IF (PRG_BatteryComm.CorvusRead[i].FW.SE_overVoltage_Warning) THEN
			Common_SE_overVoltage_Warning_Array[i] := 1*i;
	ELSE	Common_SE_overVoltage_Warning_Array[i] := 0;
	END_IF
	
	(*Common Cell Under Voltage Warning*)
	IF (PRG_BatteryComm.CorvusRead[i].FW.SE_underVoltage_Warning) THEN
			Common_SE_underVoltage_Warning_Array[i] := 1*i;
	ELSE	Common_SE_underVoltage_Warning_Array[i] := 0;
	END_IF
	
	(*Common Cell Over Temperature Warning*)
	IF (PRG_BatteryComm.CorvusRead[i].FW.SE_overTemperature_Warning) THEN
			Common_SE_overTemperature_Warning_Array[i] := 1*i;
	ELSE	Common_SE_overTemperature_Warning_Array[i] := 0;
	END_IF
	
	(*Common Module Communication Warning*)
	IF (PRG_BatteryComm.CorvusRead[i].FW.Module_Communication_Warning) THEN
			Common_Module_Communication_Warning_Array[i] := 1*i;
	ELSE	Common_Module_Communication_Warning_Array[i] := 0;
	END_IF
	
	(*Common Over Current Warning*)
	IF (PRG_BatteryComm.CorvusRead[i].FW.OverCurrent_Warning) THEN
			Common_OverCurrent_Warning_Array[i] := 1*i;
	ELSE	Common_OverCurrent_Warning_Array[i] := 0;
	END_IF
	
	(* Common Input Powerloss Warning*)
	IF (PRG_BatteryComm.CorvusRead[i].FW.Input_PowerLoss_Warning) THEN
			Common_Input_PowerLoss_Warning_Array[i] := 1*i;
	ELSE	Common_Input_PowerLoss_Warning_Array[i] := 0;
	END_IF
	
	(*Common Power Distribution Module Over Temperature Warning*)
	IF (PRG_BatteryComm.CorvusRead[i].FW.PDM_overTemperature_Warning) THEN
			Common_PDM_overTemperature_Warning_Array[i] := 1*i;
	ELSE	Common_PDM_overTemperature_Warning_Array[i] := 0;
	END_IF
	
	(*Common Coolant Water Leakage Warning*)
	IF (PRG_BatteryComm.CorvusRead[i].FW.CoolantLeak_Warning) THEN
			Common_CoolantLeak_Warning_Array[i] := 1*i;
	ELSE	Common_CoolantLeak_Warning_Array[i] := 0;
	END_IF
	
	
	(*---------------------------FAULTS---------------------------*)
	
	
	(*Common Cell Over Voltage Fault*)
	IF (PRG_BatteryComm.CorvusRead[i].FW.SE_overVoltage_Fault) THEN
			Common_SE_overVoltage_Fault_Array[i] := 1*i;
	ELSE	Common_SE_overVoltage_Fault_Array[i] := 0;
	END_IF	
		
	(*Common Cell Under Voltage Fault*)
	IF (PRG_BatteryComm.CorvusRead[i].FW.SE_underVoltage_Fault) THEN
			Common_SE_underVoltage_Fault_Array[i] := 1*i;
	ELSE	Common_SE_underVoltage_Fault_Array[i] := 0;
	END_IF	
	
		
	(*Common Cell Over Temperature Fault*)
	IF (PRG_BatteryComm.CorvusRead[i].FW.SE_overTemperature_Fault) THEN
			Common_SE_overTemperature_Fault_Array[i] := 1*i;
	ELSE	Common_SE_overTemperature_Fault_Array[i] := 0;
	END_IF	
	
		
	(*Common High Voltage Interlock Loop fault*)
	IF (PRG_BatteryComm.CorvusRead[i].FW.HVIL_Fault) THEN
			Common_HVIL_Fault_Array[i] := 1*i;
	ELSE	Common_HVIL_Fault_Array[i] := 0;
	END_IF	
		
	(*Common Emergency Stop Active Fault*)
	IF (PRG_BatteryComm.CorvusRead[i].FW.E_Stop_Active_Fault) THEN
			Common_E_Stop_Active_Fault_Array[i] := 1*i;
	ELSE	Common_E_Stop_Active_Fault_Array[i] := 0;
	END_IF	
		
	(*Common Safety Shutdown Fault*)
	IF (PRG_BatteryComm.CorvusRead[i].FW.Safety_Shutdown_Fault) THEN
			Common_Safety_Shutdown_Fault_Array[i] := 1*i;
	ELSE	Common_Safety_Shutdown_Fault_Array[i] := 0;
	END_IF	
		
	(*Common Ground Fault*)
	IF (PRG_BatteryComm.CorvusRead[i].FW.Ground_Fault) THEN
			Common_Ground_Fault_Fault_Array[i] := 1*i;
	ELSE	Common_Ground_Fault_Fault_Array[i] := 0;
	END_IF	
		
	(*Common Contactor Fault*)
	IF (PRG_BatteryComm.CorvusRead[i].FW.Contactor_Fault) THEN
			Common_Contactor_Fault_Array[i] := 1*i;
	ELSE	Common_Contactor_Fault_Array[i] := 0;
	END_IF	
		
	(*Common Low Temperature Over Current Fault*)
	IF (PRG_BatteryComm.CorvusRead[i].FW.Low_Temp_OverCurrent_Fault) THEN
			Common_Low_Temp_OverCurrent_Fault_Array[i] := 1*i;
	ELSE	Common_Low_Temp_OverCurrent_Fault_Array[i] := 0;
	END_IF	
		
	(*Common Repeated Over Charge Lockout Fault*)
	IF (PRG_BatteryComm.CorvusRead[i].FW.Repeated_OverCharge_Lockout_Fault) THEN
			Common_Repeated_OverCharge_Lockout_Fault_Array[i] := 1*i;
	ELSE	Common_Repeated_OverCharge_Lockout_Fault_Array[i] := 0;
	END_IF	
		
	(*Common Deep Over Discharge Lockout Fault*)
	IF (PRG_BatteryComm.CorvusRead[i].FW.Deep_OverDischarge_Lockout_Fault) THEN
			Common_Deep_OverDischarge_Lockout_Fault_Array[i] := 1*i;
	ELSE	Common_Deep_OverDischarge_Lockout_Fault_Array[i] := 0;
	END_IF	
		
	(*Common Power Distribution Module Over Temperature Fault*)
	IF (PRG_BatteryComm.CorvusRead[i].FW.PDM_OverTemperature_Fault) THEN
			Common_PDM_OverTemperature_Fault_Array[i] := 1*i;
	ELSE	Common_PDM_OverTemperature_Fault_Array[i] := 0;
	END_IF	
	
	


	(* Search for any common warning amongst the battery arrays*)
	IF (PRG_BatteryComm.CorvusRead[i].FW.Alarm_status = 2) THEN
			BatteryWarnings_Array[i] := 1*i;
	ELSE	BatteryWarnings_Array[i] := 0;
	END_IF


	(*Search for warnings associated with pre-warnings*)
	IF (PRG_BatteryComm.CorvusRead[i].FW.OverCurrent_Warning OR
	 PRG_BatteryComm.CorvusRead[i].FW.PDM_overTemperature_Warning OR
	 PRG_BatteryComm.CorvusRead[i].FW.SE_overTemperature_Warning OR
	 PRG_BatteryComm.CorvusRead[i].FW.SE_overVoltage_Warning OR
	 PRG_BatteryComm.CorvusRead[i].FW.OverCurrent_Warning OR
	 PRG_BatteryComm.CorvusRead[i].FW.SE_underVoltage_Warning)
	 THEN
			BatteryPreWarnings_Array[i] := 1*i;
	ELSE	BatteryPreWarnings_Array[i] := 0;
	END_IF



	
END_FOR
(*Find any warning from battery array*)
Common_SE_overVoltage_Warning := 		( ARRAY_MAX(pt := ADR(Common_SE_overVoltage_Warning_Array), 		size := SIZEOF(Common_SE_overVoltage_Warning_Array))   <> 0);
Common_SE_underVoltage_Warning := 		( ARRAY_MAX(pt := ADR(Common_SE_underVoltage_Warning_Array), 		size := SIZEOF(Common_SE_underVoltage_Warning_Array))   <> 0);
Common_SE_overTemperature_Warning := 	( ARRAY_MAX(pt := ADR(Common_SE_overTemperature_Warning_Array), 	size := SIZEOF(Common_SE_overTemperature_Warning_Array))   <> 0);
Common_Module_Communication_Warning := 	( ARRAY_MAX(pt := ADR(Common_Module_Communication_Warning_Array), 	size := SIZEOF(Common_Module_Communication_Warning_Array))   <> 0);
Common_OverCurrent_Warning := 			( ARRAY_MAX(pt := ADR(Common_OverCurrent_Warning_Array), 			size := SIZEOF(Common_OverCurrent_Warning_Array))   <> 0);
Common_Input_PowerLoss_Warning := 		( ARRAY_MAX(pt := ADR(Common_Input_PowerLoss_Warning_Array), 		size := SIZEOF(Common_Input_PowerLoss_Warning_Array))   <> 0);
Common_PDM_overTemperature_Warning := 	( ARRAY_MAX(pt := ADR(Common_PDM_overTemperature_Warning_Array), 	size := SIZEOF(Common_PDM_overTemperature_Warning_Array))   <> 0);
Common_CoolantLeak_Warning := 			( ARRAY_MAX(pt := ADR(Common_CoolantLeak_Warning_Array), 			size := SIZEOF(Common_CoolantLeak_Warning_Array))   <> 0);

(*Find any fault from battery array*)
Common_SE_overVoltage_Fault := 				( ARRAY_MAX(pt := ADR(Common_SE_overVoltage_Fault_Array), 				size := SIZEOF(Common_SE_overVoltage_Fault_Array))   <> 0);
Common_SE_underVoltage_Fault := 			( ARRAY_MAX(pt := ADR(Common_SE_underVoltage_Fault_Array), 				size := SIZEOF(Common_SE_underVoltage_Fault_Array))   <> 0);
Common_SE_overTemperature_Fault := 			( ARRAY_MAX(pt := ADR(Common_SE_overTemperature_Fault_Array), 			size := SIZEOF(Common_SE_overTemperature_Fault_Array))   <> 0);
Common_HVIL_Fault := 						( ARRAY_MAX(pt := ADR(Common_HVIL_Fault_Array), 						size := SIZEOF(Common_HVIL_Fault_Array))   <> 0);
Common_E_Stop_Active_Fault := 				( ARRAY_MAX(pt := ADR(Common_E_Stop_Active_Fault_Array), 				size := SIZEOF(Common_E_Stop_Active_Fault_Array))   <> 0);
Common_Safety_Shutdown_Fault := 			( ARRAY_MAX(pt := ADR(Common_Safety_Shutdown_Fault_Array), 				size := SIZEOF(Common_Safety_Shutdown_Fault_Array))   <> 0);
Common_Ground_Fault_Fault := 				( ARRAY_MAX(pt := ADR(Common_Ground_Fault_Fault_Array), 				size := SIZEOF(Common_Ground_Fault_Fault_Array))   <> 0);
Common_Contactor_Fault := 					( ARRAY_MAX(pt := ADR(Common_Contactor_Fault_Array), 					size := SIZEOF(Common_Contactor_Fault_Array))   <> 0);
Common_Low_Temp_OverCurrent_Fault := 		( ARRAY_MAX(pt := ADR(Common_Low_Temp_OverCurrent_Fault_Array),			size := SIZEOF(Common_Low_Temp_OverCurrent_Fault_Array))   <> 0);
Common_Repeated_OverCharge_Lockout_Fault := ( ARRAY_MAX(pt := ADR(Common_Repeated_OverCharge_Lockout_Fault_Array),	size := SIZEOF(Common_Repeated_OverCharge_Lockout_Fault_Array))   <> 0);
Common_Deep_OverDischarge_Lockout_Fault := 	( ARRAY_MAX(pt := ADR(Common_Deep_OverDischarge_Lockout_Fault_Array), 	size := SIZEOF(Common_Deep_OverDischarge_Lockout_Fault_Array))   <> 0);
Common_PDM_OverTemperature_Fault := 		( ARRAY_MAX(pt := ADR(Common_PDM_OverTemperature_Fault_Array), 			size := SIZEOF(Common_PDM_OverTemperature_Fault_Array))   <> 0);

(*Prewarning*)
batteryPreWarning := 		(ARRAY_MAX(pt := ADR(BatteryPreWarnings_Array), 	size := SIZEOF(BatteryPreWarnings_Array)) <> 0);

(*Common Warning*)
batteryCommonWarning :=		(ARRAY_MAX(pt := ADR(BatteryWarnings_Array), 		size := SIZEOF(BatteryWarnings_Array)) <> 0);


END_PROGRAM