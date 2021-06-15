PROGRAM PRG_Drive
VAR
	(*Unit over temp alarm*)
	UnitOverTempTON : 		TON; (*Timer with time delay for over temperature alarm*)
	UnitOverTempAlarm : 	BOOL; (*Vacon unit is over heated*)

	(*Vacon Data variables*)
	Profinet_IO	:	ARRAY[1..4] OF pnVaconIO;		(*Function block handling IO to and from Vacon Profidrive*)
	CW :			str_VaconCW_DcDc;					(*Command word to vacon*)
	CommandWord :	DINT;								(*Command word in DINT format to Vacon*)
	SW :			ARRAY[1..4] OF str_VaconSW_DcDc;	(*Standard FB status word ID68 + extended application status word ID43*)
	StatusWord:		ARRAY[1..4] OF fb_BitToWord;		(*Status Word*)
	FW :			ARRAY[1..4] OF str_VaconFW_DcDc;	(*Fault Word 1*)
	FW2 :			ARRAY[1..4] OF str_VaconFW2_DcDc;	(*Fault Word 2*)
	PDO :			ARRAY[1..4] OF str_VaconPDO_DcDc;	(*Analog data from vacon in engineering and perunit values*)
	PDI :			ARRAY[1..4] OF str_VaconPDI_DcDc; 	(*Analog values prepared for transmittal to Vacon*)
	
	(*Watchdog and comm faults*)
	Watchdog:				ARRAY[1..4] OF pnVaconWD;
	Watchdog_Setup:			str_VaconWd;
	CommFault :				ARRAY[1..4] OF BOOL;
	
	i : INT; (*Looping variable*)
	
	(*Analog Values from Vacon Drives*)
	Data:				str_DriveData_DcDc; 	(*Formatted values in per-unit or engineering values from drive*)
	Status:				str_DriveStatus_DcDc; 	(*Status word from master drive*)
		
	(*Misc*)
	StartStop: 				RS;
	StartTON: 				TON;
END_VAR

(* 
 * ======================================================================================================================================= 
 * Raw information to and from Vacon ProfiDrive
 * =======================================================================================================================================
*)
Profinet_IO[1](
 	(*Commands and references to Vacon*)
	CW := CommandWord,						(*ID1160 FB Control Word*)
	Ref := PDI[1].Ref,						(*Reference not in use*)
	PDI_1 := PDI[1].PDI1_UndervoltageRef ,	(*ID1567: Under Voltage Reference *)
	PDI_2 := PDI[1].PDI2_OvervoltageRef ,	(*ID1528: Over Voltage Reference*)
	PDI_3 := PDI[1].PDI3_ChargeLimit ,		(*ID1290: Charging current limit in percentage of Source Nom Current *)
	PDI_4 := PDI[1].PDI4_DischargeLimit ,	(*ID1289: Discharging current limit in percentage of Source Nom Current *)
	PDI_5 := PDI[1].PDI5_SourceMaxVoltage ,	(*ID1895: Source Max Voltage*)
	PDI_6 := PDI[1].PDI6_SourceMinVoltage ,	(*ID1893: Source Min Voltage*)
	PDI_7 := 0,		
	PDI_8 := 0,
	moduleNr := PRG_HMI.setup_Drive_PnMasterCardNr[1],
	
	(*Status and values from Vacon*)
	SW =>  ,									(*ID68: Fieldbus Status Word*)
	ACT => PDO[1].ACT_DcLinkVoltage_eng ,		(*Feedback DC Link Voltage*)
	PDO_1 => PDO[1].PDO1_ActiveCurrent_pu ,		(*ID1125: Active Current*)
	PDO_2 => PDO[1].PDO2_SourcePower_pu ,		(*ID5: Source Power *)
	PDO_3 => PDO[1].PDO3_SourceVoltage_eng ,	(*ID1107: Source Voltage*)
	PDO_4 => PDO[1].PDO4_SW43 ,					(*ID43: Application Specific Status Word*)
	PDO_5 => PDO[1].PDO5_UnitTemp_eng ,			(*ID1109: Unit Temperature*)
	PDO_6 => PDO[1].PDO6_UsedDischargeLimit_pu,	(*ID1855: Discharge Limit*)
	PDO_7 => PDO[1].PDO7_FaultWord2DcDc,		(*ID1173: Fault Word 2*)
	PDO_8 => PDO[1].PDO8_FaultWordDcDc ,		(*ID1172: Fault Word 1*)
	mioGetError => ,
	mioSetError => 
);

(* 
 * ======================================================================================================================================= 
 * Set Status Words
 * =======================================================================================================================================
*)

(*General Part from ID68*)
SW[1].b0_ReadyOn := 			Profinet_IO[1].SW.0;	(*Drive ready to start charging *)
SW[1].b1_ReadyRun := 			Profinet_IO[1].SW.1;	(*Drive ready and Main Contactor is ON*)
SW[1].b2_Running := 			Profinet_IO[1].SW.2;	(*Drive in Run state (Modulating)*)
SW[1].b3_Fault := 				Profinet_IO[1].SW.3;	(*Fault is active*)
SW[1].b4_RunEnable := 			Profinet_IO[1].SW.4;	(*Run Enabled. Drive can be started.*)
SW[1].b5_Spare := 				Profinet_IO[1].SW.5; 	(*Bit 5 NOT in use*)
SW[1].b6_Inhibit := 			Profinet_IO[1].SW.6;	(*Run disabled or fault state.*)
SW[1].b7_Warning := 			Profinet_IO[1].SW.7;	(*Warning active*)
SW[1].b8_Spare := 				Profinet_IO[1].SW.8;	(*Bit 8 NOT in use*)
SW[1].b9_FieldbusCtrlActive := 	Profinet_IO[1].SW.9;	(*Fieldbus control active  *)
SW[1].b10_Spare := 				Profinet_IO[1].SW.10;	(*Bit 10 NOT in use*)
SW[1].b11_Spare := 				Profinet_IO[1].SW.11;	(*Bit 11 NOT in use*)
SW[1].b12_Spare := 				Profinet_IO[1].SW.12;	(*Bit 12 NOT in use*)
SW[1].b13_Spare := 				Profinet_IO[1].SW.13;	(*Bit 13 NOT in use*)
SW[1].b14_Spare := 				Profinet_IO[1].SW.14;	(*Bit 14 NOT in use*)
SW[1].b15_WatchdogPulse := 		Profinet_IO[1].SW.15;	(*Same as received on bit 11 of the main control word.*)

(*Application Specific Status Word ID43*)
SW[1].app.b0_ClosedLoopActive := 	PDO[1].PDO4_SW43.0;		(*Closed Loop Control active *)
SW[1].app.b1_Ready := 				PDO[1].PDO4_SW43.1;		(*Drive in ready state, start command can be given. *)
SW[1].app.b2_Running:= 				PDO[1].PDO4_SW43.2;		(*Drive is modulating. *)
SW[1].app.b3_Fault := 				PDO[1].PDO4_SW43.3;		(*Drive has active faults.*)
SW[1].app.b4_DischargeAllowed := 	PDO[1].PDO4_SW43.4;		(*Discharging allowed*)
SW[1].app.b5_ChargeAllowed := 		PDO[1].PDO4_SW43.5;		(*Charging allowed*)
SW[1].app.b6_RunEnable := 			PDO[1].PDO4_SW43.6;		(*Run Enable command to motor control is high. *)
SW[1].app.b7_Warning := 			PDO[1].PDO4_SW43.7;		(*Drive has active warning signal. Warning signal not stop the operation.*)
SW[1].app.b8_ChargeSwitchClosed :=	PDO[1].PDO4_SW43.8;		(*DC voltage level is above closing limit and no interlock active internally. *)
SW[1].app.b9_OverVoltRegActive := 	PDO[1].PDO4_SW43.9;		(*Over Voltage Regulator Active*)
SW[1].app.b10_UnderVoltRegActive :=	PDO[1].PDO4_SW43.10;	(*Under Voltage Regulator Active*)
SW[1].app.b11_Spare := 				PDO[1].PDO4_SW43.11;	(*Not In Use*)
SW[1].app.b12_RunRequest := 		PDO[1].PDO4_SW43.12;	(*Run Request*)
SW[1].app.b13_RegulatorsActive := 	PDO[1].PDO4_SW43.13;	(*One or more regulators active*)
SW[1].app.b14_VoltageCtrlMode := 	PDO[1].PDO4_SW43.14;	(*Voltage Control Mode*)
SW[1].app.b15_Spare := 				PDO[1].PDO4_SW43.15;	(*Not In Use*)



(* 
 * ======================================================================================================================================= 
 * Watchdog
 * =======================================================================================================================================
*)

Watchdog[1](
	Puls_IN	  := SW[1].b15_WatchdogPulse,
	inVacon	  := Watchdog_Setup,
	Reset  	  := PRG_Functions.Reset,
	Puls_OUT  => ,
	Alarm	  =>,
	AlarmAuto => 
);

CommFault[1] := ((Profinet_IO[1].mioGetError <> 0) OR (Profinet_IO[1].mioSetError <> 0) OR Watchdog[1].AlarmAuto);

(* 
 * ======================================================================================================================================= 
 * Explode Fault Word
 * =======================================================================================================================================
*)

(*Feedback Fault Word*)
FW[1].b0_F1_Overcurrent := 			PDO[1].PDO8_FaultWordDcDc.0;
FW[1].b1_F2_OverVoltage  := 		PDO[1].PDO8_FaultWordDcDc.1;
FW[1].b2_F9_UnderVoltage := 		PDO[1].PDO8_FaultWordDcDc.2;
FW[1].b3_Spare :=					PDO[1].PDO8_FaultWordDcDc.3;
FW[1].b4_F3_EarthFaultDrive :=		PDO[1].PDO8_FaultWordDcDc.4;
FW[1].b5_Spare :=					PDO[1].PDO8_FaultWordDcDc.5;
FW[1].b6_F14_UnitOverTemp :=		PDO[1].PDO8_FaultWordDcDc.6;
FW[1].b7_F29_ThermistorFault :=		PDO[1].PDO8_FaultWordDcDc.7;
FW[1].b8_Spare :=					PDO[1].PDO8_FaultWordDcDc.8;
FW[1].b9_Spare :=					PDO[1].PDO8_FaultWordDcDc.9;
FW[1].b10_Spare :=					PDO[1].PDO8_FaultWordDcDc.10;
FW[1].b11_F52_KeypadCommFault := 	PDO[1].PDO8_FaultWordDcDc.11;
FW[1].b12_F53_FieldbusCommFault := 	PDO[1].PDO8_FaultWordDcDc.12;
FW[1].b13_Spare := 					PDO[1].PDO8_FaultWordDcDc.13;
FW[1].b14_F54_SlotCommFault := 		PDO[1].PDO8_FaultWordDcDc.14;
FW[1].b15_F50_4mAFault := 			PDO[1].PDO8_FaultWordDcDc.15;

FW2[1].b0_F11_OutputPhase :=	PDO[1].PDO7_FaultWord2DcDc.0;
FW2[1].b6_F51_ExternalFault :=	PDO[1].PDO7_FaultWord2DcDc.6;
FW2[1].b9_F31_F41_IGBT :=		PDO[1].PDO7_FaultWord2DcDc.9;
FW2[1].b14_F64_MainSwitchStateFault :=	PDO[1].PDO7_FaultWord2DcDc.14;


(* 
 * ======================================================================================================================================= 
 * Write Command Word
 * =======================================================================================================================================
*)
CommandWord.0 := 	CW.b0_DcChargeContactor := 	StartStop.Q1;
CommandWord.3 := 	CW.b3_Start := 				StartTON.Q;
CommandWord.7 := 	CW.b7_Reset :=				PRG_Functions.Reset;
CommandWord.10 := 	CW.b10_FieldbusCtrl :=		TRUE;
CommandWord.11 := 	CW.b11_Watchdog :=			Watchdog[1].Puls_OUT;



(* 
 * ======================================================================================================================================= 
 * Translate analog data FROM vacon to per unit or engineering values
 * =======================================================================================================================================
*)

(*DC Link Voltage in Volt*)
Data.DcLinkVoltage_eng := PDO[1].ACT_DcLinkVoltage_eng;

(*Current to Source in Amp*)
Data.SourceCurrent_eng[1] := fun_U2S(PDO[1].PDO1_ActiveCurrent_pu) * PRG_HMI.DriveSettings.SourceNomCurrent/1000;
Data.SourceCurrent_eng[2] := fun_U2S(PDO[2].PDO1_ActiveCurrent_pu) * PRG_HMI.DriveSettings.SourceNomCurrent/1000;
Data.SourceCurrent_eng[3] := fun_U2S(PDO[3].PDO1_ActiveCurrent_pu) * PRG_HMI.DriveSettings.SourceNomCurrent/1000;
Data.SourceCurrent_eng[4] := fun_U2S(PDO[4].PDO1_ActiveCurrent_pu) * PRG_HMI.DriveSettings.SourceNomCurrent/1000;

Data.SourceCurrentTotal_eng := (Data.SourceCurrent_eng[1]
 							+	Data.SourceCurrent_eng[2]
 							+	Data.SourceCurrent_eng[3]
 							+	Data.SourceCurrent_eng[4]
							);

(*Power to Source in per-unit of source nominal power and kW*)
Data.SourcePower_pu[1] := fun_U2S(PDO[1].PDO2_SourcePower_pu)/1000 ;
Data.SourcePower_pu[2] := fun_U2S(PDO[2].PDO2_SourcePower_pu)/1000 ;
Data.SourcePower_pu[3] := fun_U2S(PDO[3].PDO2_SourcePower_pu)/1000 ;
Data.SourcePower_pu[4] := fun_U2S(PDO[4].PDO2_SourcePower_pu)/1000 ;

Data.SourcePower_eng[1] := Data.SourcePower_pu[1] * PRG_HMI.DriveSettings.SourceNomPower;
Data.SourcePower_eng[2] := Data.SourcePower_pu[2] * PRG_HMI.DriveSettings.SourceNomPower;
Data.SourcePower_eng[3] := Data.SourcePower_pu[3] * PRG_HMI.DriveSettings.SourceNomPower;
Data.SourcePower_eng[4] := Data.SourcePower_pu[4] * PRG_HMI.DriveSettings.SourceNomPower;

Data.SourcePowerTotal_eng := (	Data.SourcePower_eng[1] 
 							+ 	Data.SourcePower_eng[2]
 							+ 	Data.SourcePower_eng[3]
 							+ 	Data.SourcePower_eng[4]
 								);

(*Source Voltage in Volt*)
Data.SourceVoltage_eng := DINT_TO_REAL(PDO[1].PDO3_SourceVoltage_eng)/10;

(*Unit Temperature in °C*)
Data.UnitTemp_eng[1] :=  DINT_TO_REAL(PDO[1].PDO5_UnitTemp_eng);
Data.UnitTemp_eng[2] :=  DINT_TO_REAL(PDO[2].PDO5_UnitTemp_eng);
Data.UnitTemp_eng[3] :=  DINT_TO_REAL(PDO[3].PDO5_UnitTemp_eng);
Data.UnitTemp_eng[4] :=  DINT_TO_REAL(PDO[4].PDO5_UnitTemp_eng);

Data.UnitTempMax_eng := MAX(MAX(MAX(Data.UnitTemp_eng[1], Data.UnitTemp_eng[2]),Data.UnitTemp_eng[3]),Data.UnitTemp_eng[4]);

(*Used Charge and Discharge Limit in per-unit of source nominal current and Ampere*)
Data.UsedDischargeLimit_pu := 	DINT_TO_REAL(PDO[1].PDO6_UsedDischargeLimit_pu)/100;
Data.UsedDischargeLimit_eng := 	fun_SafeDivide(divident := Data.UsedDischargeLimit_pu, devisor := PRG_HMI.DriveSettings.SourceNomCurrent);
Data.UsedChargeLimit_eng := 	fun_SafeDivide(divident := Data.UsedChargeLimit_pu, devisor := PRG_HMI.DriveSettings.SourceNomCurrent);



(* 
 * ======================================================================================================================================= 
 * Set status word from Master drive
 * =======================================================================================================================================
*)



(*General Feedback statuses*)
Status.ReadyOn := 	SW[1].b0_ReadyOn;
Status.ReadyRun := 	SW[1].b1_ReadyRun; 
Status.Running := 	SW[1].b2_Running;
Status.Fault := 	SW[1].b3_Fault;
Status.Warning := 	SW[1].b7_Warning;
Status.Remote :=	SW[1].b9_FieldbusCtrlActive;
Status.Commfault :=	Watchdog[1].AlarmAuto;



(* 
 * ======================================================================================================================================= 
 * Translate analog data TO vacon friendly format before sending
 * =======================================================================================================================================
*)


(*Set Values to Vacon*)
FOR i:=1 TO PRG_HMI.DriveSettings.NumberOfDrives BY 1 DO

	(*Set the under/over voltage reference used for load control. Must be between *)
	PDI[i].PDI1_UndervoltageRef := 	REAL_TO_DINT(fun_SafeDivide(divident := PRG_Operation.UnderVoltageRefFiltered_eng, devisor := (PRG_HMI.DriveSettings.NominalDcLinkVoltage/10000)));
	PDI[i].PDI2_OvervoltageRef := 	REAL_TO_DINT(fun_SafeDivide(divident := PRG_Operation.OverVoltageRefFiltered_eng, devisor := (PRG_HMI.DriveSettings.NominalDcLinkVoltage/10000)));
	
	(*Set the charge or discharge limit between 2% and 100% of the rated source current *)
	PDI[i].PDI3_ChargeLimit := 		LIMIT(20,	REAL_TO_DINT(fun_SafeDivide(divident := PRG_Battery.DriveChargeLimit_eng, devisor := (PRG_HMI.DriveSettings.SourceNomCurrent/1000))), 	1000);
	PDI[i].PDI4_DischargeLimit := 	LIMIT(20,	REAL_TO_DINT(fun_SafeDivide(divident := PRG_Battery.DriveDischargeLimit_eng, devisor := (PRG_HMI.DriveSettings.SourceNomCurrent/1000))), 1000);
	
	(*Set Min and Max voltage to somewhere between the system's min and max voltage, e.g. 720 and 1008 VDC *)
	PDI[i].PDI5_SourceMaxVoltage := 10*REAL_TO_DINT(PRG_HMI.DriveSettings.SourceMaxVoltage);
	PDI[i].PDI6_SourceMinVoltage := 10*REAL_TO_DINT(PRG_HMI.DriveSettings.SourceMinVoltage);
END_FOR



(* 
 * ======================================================================================================================================= 
 * Prepare digital commands for the control word
 * =======================================================================================================================================
*)


(* Start and stop commands*)
StartStop(
	SET := PRG_StateMain.StartDrive,
	RESET1 := PRG_StateMain.StopDrive OR (PRG_StateMain.tripStatus <> 0)
);

StartTON(
	IN := StartStop.Q1,
	PT := T#500ms
);


(* 
 * ======================================================================================================================================= 
 * Unit over temperature alarm
 * =======================================================================================================================================
*)

UnitOverTempTON(
	IN := Data.UnitTempMax_eng > PRG_HMI.DriveSettings.UnitTempAlarmLevel,
	PT := PRG_HMI.DriveSettings.UnitTempAlarmDelay,
	Q => UnitOverTempAlarm,
	ET => 
);

END_PROGRAM

ACTIONS

END_ACTIONS