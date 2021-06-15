PROGRAM PRG_Battery
VAR
	ManualEnterPowerSaveMode: BOOL;	(*Manual Command to enter Power Save Mode for all packs*)
	ManualExitPowerSaveMode: BOOL;	(*Manual Command to exit Power Save Mode for all packs*)
	
	Extended_Statemachine: UINT := 0; (*Extended state machine for IAS, containing prewarning and shutdown  *)

	M : INT; (*Master of array information in Corvus BMS*)
	P : INT; (*Pack or packs with precharge module. Must receive connect command*)
	
	(*Battery Commands*)
	Connect: 				BOOL; (*Connect command from state machine*)
	Disconnect: 			BOOL; (*Disconnect command from state machine*)
	Tripstatus: 			DINT; (*Trip status from state machine*)
	ConnectPack1to8: 		DINT; (* Connect command read by communication programs*)
	testPrechargeTimeout: 	BOOL; (* Used to test precharge timeout *)	
	ResetBattery : 			INT; (*Reset flag to Corvus BMS. 1 or 0 for true and false.*)
	CorvusConnect: 			fb_BitToWord; (*Split word to decide which packs to connect	*)
	
	(* Select and connect packs *)
	bms_Connect_Pack1: BOOL;
	bms_Select_Pack1: BOOL;
	bms_Connect_Pack2: BOOL;
	bms_Select_Pack2: BOOL;
	bms_Connect_Pack3: BOOL;
	bms_Select_Pack3: BOOL;
	bms_Connect_Pack4: BOOL;
	bms_Select_Pack4: BOOL;
	bms_Connect_Pack5: BOOL;
	bms_Select_Pack5: BOOL;
	bms_Connect_Pack6: BOOL;
	bms_Select_Pack6: BOOL;
	bms_Connect_Pack7: BOOL;
	bms_Select_Pack7: BOOL;
	bms_Connect_Pack8: BOOL;
	bms_Select_Pack8: BOOL;
	ConnectRS: RS;
	DeSelectTOF: TOF;
	
	(*Battery Feedback*)
	BatteryAllConnected: 	BOOL; (*All packs are connected*)
	BatteryMinOneConnected: BOOL; (*At least one pack is connected*)
	BatteryDisconnected : 	BOOL; (*All packs are disconnected*)
	BatteryReady: 			BOOL; (*Precharge pack is ready to connect or in power save mode*)
	BatteryConnecting: 		BOOL; (*Precharge pack is currently connecting*)
	BatteryReadyConnect:	BOOL; (*Battery is ready to connect or already connected or in power save mode - start sequence allowed*)
	
	(*Power Save Mode*)
	BatteryPackPowerSaveArray : 		ARRAY[1..16] OF INT; 	(*Count packs in power save mode*)
	BatteryCountPowerSave : 			DWORD;		(* Check how many packs are in power save mode*)
	BatteryNumInPowerSave : 			INT; 		(*Number of packs in power save mode*)
	BatteryAllPacksSleeping: 			BOOL; 		(*All battery packs are in power save mode*)
	ExitPowerSaveMode : 				BOOL;		(*Command to exit power save mode for all packs.*)
	GoToPowerSaveModeTP : 				TP;			(*Command Pulse*)
	ExitPowerSaveModeTP : 				TP;			(*Command Pulse*)
	LastPackDisconnectedRT: 			R_TRIG;		(*Rising edge trigger to detect when battery pack is no longer connected*)
	DelayPowerSaveAfterDisconnectTOF: 	TOF; 		(*Delay after last pack disconnect before entering power save mode*)
	DelayPowerSaveAfterDisconnectFT:	F_TRIG;		(*Falling edge trigger to enter power save when timer has run out*)
	EmergencyGoToPowerSaveRT: 			R_TRIG;		(*Detect when battery protection calls for emergency power save*)
	ForceSleepMode:						BOOL;		(*Bit from *)
	EnterPowerSaveModeTP:				TP;			(*Pulse to enable power save mode to Corvus*)
	AllowPowerSaveMode:					BOOL;		(*Power Save is only allowed for packs not in Connected eller Connecting State*)
	BatteriesInPowerSaveArray:			ARRAY[1..16] OF INT;	(*Array to register packs in power save mode*)
	BatteriesNotAllowedToSleepArray:	ARRAY[1..16] OF INT;	(*Array to register packs which are not allowed to sleep*)
	
	
	
	(*SoH Verification Testing*)
	SoHCurrent: 				INT := 0; (* Current limit during SoH Verification Testing*)
	
	
	(*Battery Charge/Discharge control*)
	StopDischargeTOF: 					TOF;					(*Discharge limit reached - limit discharge current to zero for some time*)
	StopChargeTOF: 						TOF;					(*Charge limit reached - limit charge current to zero for some time*)
	BMS_DischargeLimit_eng: 			DINT := 0;				(*Current limit in ampere*)
	BMS_ChargeLimit_eng: 				DINT := 0;				(*Current limit in ampere*)
	Battery_Current_Limiter: 	fb_CorvusOrcaCurrentLimiter;	(*Limitation function based on current*)
	ChargeLimitFilter:					FILTER_I;				(*Current filter used when stopping normally*)
	DischargeLimitFilter:				FILTER_I;				(*Current filter used when stopping normally*)
	ChargeLimit_eng: 					REAL := 0;				(* Charge limit in in ampere*)
	DischargeLimit_eng: 				REAL := 0;				(* Discharge limit in in ampere*)
	DriveDischargeLimit_eng: 			REAL := 0;				(* Discharge current in ampere used to limit DC/DC drive*)
	DriveChargeLimit_eng: 				REAL := 0;				(* Charge current in ampere used to limit DC/DC drive*)
	
	
	
	
	(*Readings and statuses*)
	SoC_Floor : INT; (*Current SoC level where the batteries are disconnected due to safety reasons / undervoltage*)
	busPower: REAL := 0; (* Power in kW to/from the batteries*)
	packSOH: ARRAY [1..16] OF REAL; (*Array of all pack's State of Health*)
	packSOC: ARRAY [1..16] OF REAL; (*Array of all pack's State of Charge*)
	
	MinutesRemaining: REAL := 0; (*Minutes remaining till current SoC_Floor, i.e. when batteries will auto disconnect. SoC Floor can vary depending on mode.*)
	hoursRemaining: REAL := 0; (*Hours remaining till current SoC_Floor, i.e. when batteries will auto disconnect. SoC Floor can vary depending on mode.*)
	energyRemaining: REAL := 0; (*Energy remaining on batteries in kWh*)
	energyRemainingOffline: REAL := 0; (*Energy in kWh remaining on batteries in offline mode. The lowest SoC is used.*)
	EnergyToFull: REAL := 0; (*Energy in kWh remaining until fully charged, SoC = 100% *)
	EnergyToDisconnect: REAL := 0; (*Energy in kWh remaining until completely discharged, SoC = 0% *)
	batteryCharging: BOOL; (*True if current is positive, i.e. current is flowing into the batteries*)
	
	(*Counter variables*)
	i:INT;
	y:INT;

	
	(*IAS Calculated variables*)
	avgCellVolt_sum: REAL := 0;
	avgCellTemp_sum: REAL := 0;
	AvailablePower : UINT;
	avgCellVolt : INT;
	avgCellTemp : INT;
	cellBalancingStatus : ARRAY[1..16] OF BOOL;
	CellsInBalance : ARRAY[1..16] OF BOOL;
	connectionArray : ARRAY[1..16] OF BOOL;
	AvailableEnergy : UINT;
END_VAR


(* 
 * ======================================================================================================================================= 
 * Initial paper work; select Master and map commands from state machine
 * =======================================================================================================================================
*)


(*Decide which Corvus Controller to use as (M)aster for array data and (P)recharge/connect commands*)
M := PRG_BatteryComm.M;
P := PRG_BatteryComm.P;

(*Read commands from prg_Statemachine*)
Connect := PRG_StateMain.ConnectBattery ;
Disconnect := PRG_StateMain.DisconnectBattery ;
Tripstatus := PRG_StateMain.tripStatus ;




(* 
 * ======================================================================================================================================= 
 * Connect and Disconnect Commands
 * =======================================================================================================================================
*)

(*RS function to hold connect command to Corvus.  *)
ConnectRS(SET := (Connect AND NOT testPrechargeTimeout), RESET1 := Disconnect OR (Tripstatus <> 0));
	
bms_Connect_Pack1 := (PRG_HMI.setup_Battery_total_nr_of_packs >= 1) AND ConnectRS.Q1;
bms_Connect_Pack2 := (PRG_HMI.setup_Battery_total_nr_of_packs >= 2) AND ConnectRS.Q1;
bms_Connect_Pack3 := (PRG_HMI.setup_Battery_total_nr_of_packs >= 3) AND ConnectRS.Q1;
bms_Connect_Pack4 := (PRG_HMI.setup_Battery_total_nr_of_packs >= 4) AND ConnectRS.Q1;
bms_Connect_Pack5 := (PRG_HMI.setup_Battery_total_nr_of_packs >= 5) AND ConnectRS.Q1;
bms_Connect_Pack6 := (PRG_HMI.setup_Battery_total_nr_of_packs >= 6) AND ConnectRS.Q1;
bms_Connect_Pack7 := (PRG_HMI.setup_Battery_total_nr_of_packs >= 7) AND ConnectRS.Q1;
bms_Connect_Pack8 := (PRG_HMI.setup_Battery_total_nr_of_packs >= 8) AND ConnectRS.Q1;
	
DeSelectTOF(
		IN := ConnectRS.Q1,
		PT := T#2500ms
);

(*Make sure packs are not de-selected prior to disconnect command*)
bms_Select_Pack1 := DeSelectTOF.Q;
bms_Select_Pack2 := DeSelectTOF.Q;
bms_Select_Pack3 := DeSelectTOF.Q;
bms_Select_Pack4 := DeSelectTOF.Q;
bms_Select_Pack5 := DeSelectTOF.Q;
bms_Select_Pack6 := DeSelectTOF.Q;
bms_Select_Pack7 := DeSelectTOF.Q;
bms_Select_Pack8 := DeSelectTOF.Q;

(*Prepare connection setup to Corvus*)
CorvusConnect(
	EN := TRUE,
	Bit0 := bms_Connect_Pack1,
	Bit1 := bms_Select_Pack1,
	Bit2 := bms_Connect_Pack2,
	Bit3 := bms_Select_Pack2,
	Bit4 := bms_Connect_Pack3,
	Bit5 := bms_Select_Pack3,
	Bit6 := bms_Connect_Pack4,
	Bit7 := bms_Select_Pack4,
	Bit8 := bms_Connect_Pack5,
	Bit9 := bms_Select_Pack5,
	Bit10 := bms_Connect_Pack6,
	Bit11 := bms_Select_Pack6,
	Bit12 := bms_Connect_Pack7,
	Bit13 := bms_Select_Pack7,
	Bit14 := bms_Connect_Pack8,
	Bit15 := bms_Select_Pack8,
	OUT => ConnectPack1to8
);


(*Battery is connected only when all packs are connected*)
BatteryAllConnected := (PRG_BatteryComm.CorvusRead[M].theArray.nrOfPackConnected = PRG_HMI.setup_Battery_total_nr_of_packs);

(*At least one pack is connected*)
BatteryMinOneConnected := (PRG_BatteryComm.CorvusRead[M].theArray.nrOfPackConnected >= 1);

(*Battery is disconnected only when all packs are disconnected*)
BatteryDisconnected := (PRG_BatteryComm.CorvusRead[M].theArray.nrOfPackConnected = 0);

(*Battery is ready when Pack controller with precharge is ready*)
BatteryReady := ((PRG_BatteryComm.CorvusRead[P].Pack.operationMode = 3) OR (PRG_BatteryComm.CorvusRead[P].Pack.operationMode = 1));

(*Connecting when precharge pack is working its magic*)
BatteryConnecting := (PRG_BatteryComm.CorvusRead[P].Pack.operationMode = 4);

(*Battery Ready to be Connected*)
BatteryReadyConnect := ((PRG_BatteryComm.CorvusRead[P].Pack.operationMode = 3) OR (PRG_BatteryComm.CorvusRead[P].Pack.operationMode = 5) OR (PRG_BatteryComm.CorvusRead[P].Pack.operationMode = 1));


(* 
 * ======================================================================================================================================= 
 * Power Save Mode
 * =======================================================================================================================================
*)

(*Protection conditions to enter power save mode*)
EmergencyGoToPowerSaveRT(CLK := ForceSleepMode);

(*Enter power save mode when disconnect timer has run out*)
LastPackDisconnectedRT(
	CLK := (NOT BatteryMinOneConnected),
);

(*Enter power save mode when disconnect timer has run out*)
DelayPowerSaveAfterDisconnectTOF(
	IN := LastPackDisconnectedRT.Q,
	PT := REAL_TO_TIME(PRG_HMI.Delay_EnterPowerSaveMode*3600000)
);
DelayPowerSaveAfterDisconnectFT(CLK:=DelayPowerSaveAfterDisconnectTOF.Q);



EnterPowerSaveModeTP(
	IN := (DelayPowerSaveAfterDisconnectFT.Q OR ManualEnterPowerSaveMode OR EmergencyGoToPowerSaveRT.Q) AND PRG_HMI.enPowerSaveMode AND AllowPowerSaveMode,
	PT := T#2s,
	Q => (*Output is read in PRG_BatteryComm*),
	ET =>
);



(*Exit power save mode when starting*)
ExitPowerSaveModeTP(
	IN := PRG_Operation.ControlPlace.Start OR ManualExitPowerSaveMode,
	PT := T#2s,
	Q => ExitPowerSaveMode,
	ET =>
);




(*For loop to check how the batteries are sleeping or if they are allowed to go to sleep*)
FOR i:=1 TO PRG_HMI.setup_Battery_total_nr_of_packs BY 1 DO
	
	(*Check which batteries are in power save mode*)
	IF (PRG_BatteryComm.CorvusRead[i].Pack.operationMode = 1) THEN
		BatteriesInPowerSaveArray[i] := i*1;
	ELSE
		BatteriesInPowerSaveArray[i] := 0;
	END_IF
	

	(*Check which batteries are not allowed to enter power save*)
	IF (PRG_BatteryComm.CorvusRead[i].Pack.operationMode = 4 OR PRG_BatteryComm.CorvusRead[i].Pack.operationMode = 5) THEN
		BatteriesNotAllowedToSleepArray[i] := i*1;
	ELSE
		BatteriesNotAllowedToSleepArray[i] := 0;
	END_IF
		
END_FOR


(*Check how many battery packs are in power save mode*)
BatteryNumInPowerSave :=	BIT_COUNT(REAL_TO_DWORD((ARRAY_SUM(pt := ADR(BatteriesInPowerSaveArray), size := SIZEOF(BatteriesInPowerSaveArray)))));
IF (BatteryNumInPowerSave = PRG_HMI.setup_Battery_total_nr_of_packs) THEN
	BatteryAllPacksSleeping := TRUE;
ELSE
	BatteryAllPacksSleeping := FALSE;
END_IF

	

(*Power Save Mode is not allowed if any pack is either connected or connected*)
AllowPowerSaveMode := ( ARRAY_MAX(pt := ADR(BatteriesNotAllowedToSleepArray), size := SIZEOF(BatteriesNotAllowedToSleepArray))   <> 0);
 





(* 
 * ======================================================================================================================================= 
 * Limitation of power to and from battery
 * =======================================================================================================================================
*)



(*------------------------------------- Batterilimiter fra BMS----------------------------------------------*)
(*This logic alters current limiters being sent into the limiter block. The output is filtered and controlled to vacon*)
IF (PRG_HMI.ChargeDischargeCurrentTestActive) THEN
	BMS_ChargeLimit_eng := LIMIT (0,REAL_TO_DINT(PRG_HMI.ChargeCurrentLimit_scale.PV),PRG_BatteryComm.CorvusRead[M].theArray.systemChargelimit);
	BMS_DischargeLimit_eng := LIMIT (0,REAL_TO_DINT(PRG_HMI.DischargeCurrentLimit_scale.PV),PRG_BatteryComm.CorvusRead[M].theArray.systemDischargeLimit);
	
ELSIF (PRG_HMI.SoHVerifModeActive) THEN (*Limit current to C-rate during State of Health Verification testing*)
	BMS_ChargeLimit_eng := LIMIT (0,INT_TO_DINT(SoHCurrent),PRG_BatteryComm.CorvusRead[M].theArray.systemChargelimit);
	BMS_DischargeLimit_eng := LIMIT (0,INT_TO_DINT(SoHCurrent),PRG_BatteryComm.CorvusRead[M].theArray.systemDischargeLimit);
	
ELSE 
	BMS_ChargeLimit_eng := PRG_BatteryComm.CorvusRead[M].theArray.systemChargelimit;
	BMS_DischargeLimit_eng := PRG_BatteryComm.CorvusRead[M].theArray.systemDischargeLimit;
END_IF

(*Reading Charge/discharge limits and bus current in Ampere from BMS and compensates it by manipulating the reference*)
Battery_Current_Limiter(
	BMS_ChargeLimit_in := DINT_TO_INT(BMS_ChargeLimit_eng),
	BMS_DischargeLimit_in := DINT_TO_INT(BMS_DischargeLimit_eng),
	BatteryCurrent := PRG_BatteryComm.CorvusRead[M].theArray.busCurrent,
	NominalDriveCurrent := PRG_HMI.DriveSettings.SourceNomCurrent,
	BatteryConnected := BatteryMinOneConnected,
	ChargeLimit_eng => ,
	DischargeLimit_eng => ,
	ChargingLimited => ,
	DischargingLimited => 
);


(*Stop charging when battery voltage or SoC is too high*)
StopChargeTOF(
	IN := PRG_BatteryProtection.ChargeLimitWord <> 0,
	PT := T#30s, (*We want to stop charging for at least some time to prevent "blinking" of limits*)
	Q => ,
	ET => 
);
 
 
 (*Stop discharging when battery voltage or SoC is too low*)
StopDischargeTOF(
	IN:= PRG_BatteryProtection.DischargeLimitWord <> 0,
	PT := T#30s, (*We want to stop charging for at least some time to prevent "blinking" of limits*)
	Q => ,
	ET => 
); 





(*Calculate charge/discharge limit from C-rate - Used as input to BMS Limiter during SoH verification*)
SoHCurrent := REAL_TO_INT(PRG_HMI.SoHChargeDischargeRate * setup_Battery_C_Rate * PRG_BatteryComm.CorvusRead[M].theArray.nrOfPackConnected);




(*This logic alters limits. Used for deloading or limiting when past SoC Low and Soc High*)

(*Ramping down limits towards zero to deload when stopping*)
IF ((PRG_StateMain.State = e_Stopping))  THEN 
	ChargeLimit_eng := 0;
	DischargeLimit_eng := 0;
	
(*Limit when over charging - allowed to discharge*)	
ELSIF (StopChargeTOF.Q) THEN 
	ChargeLimit_eng := 0;
	DischargeLimit_eng := Battery_Current_Limiter.DischargeLimit_eng;
	
(*Limit when over discharging - allowed to charge*)
ELSIF (StopDischargeTOF.Q) THEN 
	ChargeLimit_eng := Battery_Current_Limiter.ChargeLimit_eng;
	DischargeLimit_eng :=	0;

(*Normal operational limits controlled by BMS and other protective functions*)
ELSE 
	ChargeLimit_eng := 		Battery_Current_Limiter.ChargeLimit_eng;
	DischargeLimit_eng := 	Battery_Current_Limiter.DischargeLimit_eng; 
END_IF



(* Filtering of limit value*)
DischargeLimitFilter( 
	X := REAL_TO_INT(DischargeLimit_eng),
	T := T#2s
);

ChargeLimitFilter( 
	X := REAL_TO_INT(ChargeLimit_eng),
	T := T#2s
);


(*Preparing limit value to PRG_Drive*)
DriveChargeLimit_eng := 		ChargeLimitFilter.Y;
DriveDischargeLimit_eng := 		DischargeLimitFilter.Y;




(* 
 * ======================================================================================================================================= 
 * Calculate Energy in batteries and time to full/empty/disconnect
 * =======================================================================================================================================
*)


(* Check if we are charging or discharging the battery *)
batteryCharging := (PRG_BatteryComm.CorvusRead[M].theArray.busPowerCalculated > 0 AND (PRG_BatteryComm.CorvusRead[M].Pack.operationMode = 5));


(*Calculate offline available energy, based on all packs and minimum state of charge*)
energyRemainingOffline := ( 
 	ARRAY_MIN(pt:=ADR(packSOC), size:=SIZEOF(packSOC)) *  	(* Lowest State of Charge *)
	setup_Energy_per_pack *									(* kWh per pack *)
	PRG_HMI.setup_Battery_total_nr_of_packs *				(* Total number of packs in array *)
	ARRAY_MIN(pt:=ADR(packSOH), size:=SIZEOF(packSOH)) *	(* Systems state of health *)
	0.0001													(* Correction factor *)
);


(*Calculate remaining energy to zero in an online system*)
EnergyToDisconnect := (
 	(PRG_BatteryComm.CorvusRead[M].theArray.systemOnlineSOC - REAL_TO_DINT(PRG_HMI.BMS_SoC.LL)) *  (* State of charge *)
	setup_Energy_per_pack *											(* kWh per pack *)
	PRG_BatteryComm.CorvusRead[M].theArray.nrOfPackConnected *		(* Number of packs online *)
	PRG_BatteryComm.CorvusRead[M].theArray.systemOnlineSOH *		(* Systems state of health *)
	0.0001															(* Correction factor *)
);

(*Calculate energy to full state of charge in an online system*)
EnergyToFull := (
 	setup_Energy_per_pack * 										(* kWh per pack *)
 	PRG_BatteryComm.CorvusRead[M].theArray.nrOfPackConnected *		(* Number of packs online *)
	PRG_BatteryComm.CorvusRead[M].theArray.systemOnlineSOH *		(* Systems state of health *)
	0.01															(* Correction factor *)
) - EnergyToDisconnect;												(* Subtract remaining energy *)

(*Prevent division by zero when calculating time remaining (This result is the denominator in the energy division) *)
IF PRG_BatteryComm.CorvusRead[M].theArray.busPowerCalculated = 0
	THEN busPower := 0.1;
	ELSE busPower := PRG_BatteryComm.CorvusRead[M].theArray.busPowerCalculated;
END_IF


(* Calculate time remaining to either 100% or 0% depending on whether the battery is charging or discharging *)
IF (batteryCharging) THEN
	hoursRemaining := EnergyToFull/busPower;
ELSE 
	hoursRemaining := EnergyToDisconnect/busPower;
END_IF

MinutesRemaining := ABS(hoursRemaining*60);



(* 
 * ======================================================================================================================================= 
 * Calculate values for IAS information
 * =======================================================================================================================================
*)


FOR i:=1 TO 16 BY 1 DO
	
	(*Set up all pack state of charges in an array*)
	IF ((PRG_BatteryComm.CorvusRead[i].Pack.SOC <> 0) OR PRG_BatteryComm.CorvusRead[i].ModbusFault) THEN
		packSOC[i] := DINT_TO_REAL(PRG_BatteryComm.CorvusRead[i].Pack.SOC);
	ELSE
		packSOC[i] := 999; (*prevent zeros in array when looking for the lowest value*)
	END_IF
	
	(*Set up all pack state of health in an array*)
	IF ((PRG_BatteryComm.CorvusRead[i].Pack.SOH <> 0) OR PRG_BatteryComm.CorvusRead[i].ModbusFault) THEN
		packSOH[i] := DINT_TO_REAL(PRG_BatteryComm.CorvusRead[i].Pack.SOH);
	ELSE
		packSOH[i] := 999; (*prevent zeros in array when looking for the lowest value*)
	END_IF
	
	(*Count pack balancing status*)
	IF (PRG_BatteryComm.CorvusRead[i].Pack.cellBalancingStatus = 1) THEN
		cellBalancingStatus[i] :=  TRUE;
	ELSE 
		cellBalancingStatus[i] :=  FALSE;
	END_IF; 
	
	(*Count pack balancing status 2*)
	IF (PRG_BatteryComm.CorvusRead[i].Pack.cellsInBalance = 1) THEN
		CellsInBalance[i] :=  TRUE;
	ELSE 
		CellsInBalance[i] :=  FALSE;
	END_IF; 
	
	(*Connection Array*)
	IF (PRG_BatteryComm.CorvusRead[i].Pack.operationMode = 5) THEN
		connectionArray[i] :=  TRUE;
	ELSE 
		connectionArray[i] :=  FALSE;
	END_IF; 
END_FOR


	
(*Find average cell temperature*)
avgCellTemp_sum := 0;
FOR i:=1 TO PRG_HMI.setup_Battery_total_nr_of_packs BY 1 DO
	avgCellTemp_sum := avgCellTemp_sum + DINT_TO_REAL(PRG_BatteryComm.CorvusRead[i].Pack.avgCellTemp);
END_FOR
avgCellTemp := REAL_TO_INT(fun_SafeDivide(divident := avgCellTemp_sum, devisor := PRG_HMI.setup_Battery_total_nr_of_packs));


(*Find average cell voltage*)
avgCellVolt_sum := 0;
FOR i:=1 TO PRG_HMI.setup_Battery_total_nr_of_packs BY 1 DO
	avgCellVolt_sum := avgCellVolt_sum + DINT_TO_REAL(PRG_BatteryComm.CorvusRead[i].Pack.avgCellVoltage);
END_FOR
avgCellVolt := REAL_TO_INT(fun_SafeDivide(divident := avgCellVolt_sum, devisor := PRG_HMI.setup_Battery_total_nr_of_packs));






(*Determine wether to use online or offline energy*)
IF (PRG_BatteryComm.CorvusRead[M].theArray.nrOfPackConnected > 0) THEN
	AvailableEnergy := REAL_TO_UINT(EnergyToDisconnect);
ELSE 
	AvailableEnergy := REAL_TO_UINT(energyRemainingOffline);
END_IF



(*Send offline estimated available power to IAS/PMS*)
IF (PRG_BatteryComm.CorvusRead[M].theArray.nrOfPackConnected > 0) THEN
	AvailablePower := REAL_TO_UINT( MIN(PRG_BatteryComm.CorvusRead[M].theArray.systemDischargeLimit,PRG_HMI.DriveSettings.SourceNomCurrent) * PRG_BatteryComm.CorvusRead[M].theArray.busVoltage/1000);
ELSE 
	AvailablePower := REAL_TO_UINT((PRG_HMI.DriveSettings.SourceNomCurrent * PRG_BatteryComm.CorvusRead[M].Pack.batteryVoltage)/1000);
END_IF



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