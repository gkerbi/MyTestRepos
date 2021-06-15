PROGRAM PRG_Operation
VAR
	(*Novel Voltage Regulator - not in use*)
	VoltageRegulator : 				FT_PIWL;	(*Voltage regulator with current reference output*)
	CurrentRefFilter : 				FILTER_I;	(*Filter to reference current*)
	CurrentReferenceFiltered_eng: 	REAL;		(*Filtered current reference*)
	CurrentReferenceLimited_eng: 	REAL;		(*Limited current reference*)
	DcLinkDiff: 					REAL;		(*Difference between setpoint and actual dc link voltage*)
	DcLinkRef: 						REAL;		(*DC Link reference from inc/dec function block*)
	DcLinkActual: 					REAL;		(*Actual DC link voltage*)
	ResetVoltageRegulatorCommand: 	BOOL;		(*Reset bit to voltage regulator to set the command to zero*)
	(*end*)

	ControlPlace:					fb_ControlPlace;	(*Handling of start/stop/inc/dec commands*)
	VoltIncDec:						fb_IncDec;			(*Handling of reference*)	
	
	IASCtrlLocation: 				UINT := 0; 			(*Control location info to IAS*)
	
	VoltRefMargin_pu:				REAL;			(*Margin between over and under voltage reference in per unit of vacon nominal dc link voltage*)
	VoltRefMargin_eng:				REAL;			(*Margin between over and under voltage reference in volt*)
	OverVoltageRefFiltered_eng: 	DINT := 0;		(*Over voltage reference in Volt after filtering*)
	UnderVoltageRefFiltered_eng: 	DINT := 0;		(*Under voltage reference in Volt after filtering*)
	OverVoltageRef_eng: 			DINT := 0;		(*Over voltage reference in Volt before filtering*)
	UnderVoltageRef_eng: 			DINT := 0;		(*Under voltage reference in Volt before filtering*)
	OverVoltRef_Filter: 			FILTER_I;		(*Filter to smooth under voltage reference*)
	UnderVoltRef_Filter: 			FILTER_I;		(*Filter to smooth under voltage reference*)
	RefFilterTime: 					TIME:=T#2s;		(*Filter time for under voltage filter*)
	
	RefInUpperLimit: 				BOOL;
	RefInLowerLimit: 				BOOL;
END_VAR



(*---------------------Handle commands for start/stop and inc/dec------------------------------*)
ControlPlace(
 	Local := PRG_DI.di_LocalMode.PV,
 	Remote := PRG_DI.di_RemoteMode.PV,
 	Start_local := PRG_DI.di_LocalStart.PV,
 	Start_remote := PRG_IAS.IAS_Start,
 	Stop_local := PRG_DI.di_LocalStop.PV,
 	Stop_remote := PRG_IAS.IAS_Stop,
 	Inc_local := PRG_DI.di_LocalIncrease.PV,
 	Inc_remote := PRG_IAS.IAS_Increase,
 	Dec_local := PRG_DI.di_LocalDecrease.PV,
 	Dec_remote := PRG_IAS.IAS_Decrease,
 	reset := PRG_Functions.Reset,
 	Start => (*Output is read by statemachine in PRG_StateMain*),
 	Stop => (*Output is read by statemachine in PRG_StateMain*),
 	Increase =>(*Output is read by statemachine in PRG_StateMain*) ,
 	Decrease => (*Output is read by statemachine in PRG_StateMain*),
 	alarmDeviation => (*Output is read by statemachine in PRG_Alarms*)
 );



(* 
 * ======================================================================================================================================= 
 * Handle reference
 * =======================================================================================================================================
*)

VoltIncDec(
	RefMax_eng := PRG_HMI.IncDecSetup.RefMax_eng,
	RefMin_eng := PRG_HMI.IncDecSetup.RefMin_eng,
	RefZero_eng := PRG_HMI.IncDecSetup.RefZero_eng,
	Increase := ControlPlace.Increase,
	Decrease := ControlPlace.Decrease,
	StepSize_eng := PRG_HMI.IncDecSetup.StepSize_eng,
	ResetSpeed := PRG_HMI.IncDecSetup.ResetSpeed,
	StepSpeed := PRG_HMI.IncDecSetup.StepSpeed,
	en_HoldIncDec := PRG_HMI.IncDecSetup.en_HoldIncDec,
	ResetToZero := PRG_StateMain.State = e_Starting OR PRG_StateMain.State = e_Stopping,
	Ref_eng => ,
	MaxRefReached => RefInUpperLimit,
	MinRefReached => RefInLowerLimit
);




(*How far from each other should the over voltage and under voltage reference be? *)
VoltRefMargin_pu := 0.01;	(*In per-unit of vacon nominal dc link voltage*)
VoltRefMargin_eng := PRG_HMI.DriveSettings.NominalDcLinkVoltage * VoltRefMargin_pu / 2; (*in volt*)



(*Edit the over and under voltage regulator references while in limitation mode*)

(*Prevent charging by moving over voltage reference far away*)
IF PRG_Battery.StopChargeTOF.Q THEN
	UnderVoltageRef_eng := REAL_TO_INT(VoltIncDec.Ref_eng - VoltRefMargin_eng);
	OverVoltageRef_eng := REAL_TO_DINT(PRG_HMI.IncDecSetup.RefMax_eng);
	
(*Prevent discharging by moving under voltage reference far away*)
ELSIF PRG_Battery.StopDischargeTOF.Q THEN
	UnderVoltageRef_eng := REAL_TO_DINT(PRG_HMI.IncDecSetup.RefMin_eng);
	OverVoltageRef_eng := REAL_TO_INT(VoltIncDec.Ref_eng + VoltRefMargin_eng);
	
(*Normal operation*)
ELSE 
	(*Envelope the reference signal go provide breathing room for the Vacon regulator*)
	UnderVoltageRef_eng := REAL_TO_INT(VoltIncDec.Ref_eng - VoltRefMargin_eng);
	OverVoltageRef_eng := REAL_TO_INT(VoltIncDec.Ref_eng + VoltRefMargin_eng);
END_IF;

(*Filter the output to soften sudden changes in reference, i.e. when limits go on and off*)
OverVoltRef_Filter(
	X := DINT_TO_INT(OverVoltageRef_eng),
	T := T#1s,
	Y => OverVoltageRefFiltered_eng
);

UnderVoltRef_Filter(
	X := DINT_TO_INT(UnderVoltageRef_eng),
	T := T#1s,
	Y => UnderVoltageRefFiltered_eng
);


(* 
 * ======================================================================================================================================= 
 * Novel voltage regulator (not in use)
 * =======================================================================================================================================
*)

DcLinkActual := PRG_Drive.Data.DcLinkVoltage_eng;		(*Process value*)
DcLinkRef := VoltIncDec.Ref_eng;						(*Reference signal*)
DcLinkDiff := DcLinkActual - DcLinkRef;					(*Error signal*)

(*Reset regulator command signal when a limit has been reached so that it can more quickly change direction*)
IF (PRG_Battery.StopChargeTOF.Q OR PRG_Battery.StopDischargeTOF.Q) THEN
	ResetVoltageRegulatorCommand := TRUE;
END_IF

VoltageRegulator(
	IN := DcLinkDiff,								(*The DC link voltage setpoint error*)
	KP := 0.001,									(*How fast to respond to actual difference*)
	KI := 0.0001,									(*How fast to respond to lasting difference*)
	LIM_L := PRG_HMI.DriveSettings.SourceNomCurrent*-1,		(*Maximum current allowed in discharge direction*)
	LIM_H := PRG_HMI.DriveSettings.SourceNomCurrent,		(*Maximum current allowed in charge direction*)
	RST := ResetVoltageRegulatorCommand,			(*Set command to zero*)
	Y => ,											(*Command to fix the voltage deviation in Ampere*)
	LIM => 
);

(*Limit current between max discharge current and max charge current*)
CurrentReferenceLimited_eng := LIMIT(PRG_Battery.BMS_DischargeLimit_eng, VoltageRegulator.Y, PRG_Battery.BMS_ChargeLimit_eng);

(*Filter the output to prevent abrupt changes*)
CurrentRefFilter(
	X := REAL_TO_INT(CurrentReferenceLimited_eng),
	T := T#1s,
	Y => 
);

(*Send engineering value to PRG_Drive*)
CurrentReferenceFiltered_eng := INT_TO_REAL(CurrentRefFilter.Y);


(* 
 * ======================================================================================================================================= 
 * Stuff to IAS
 * =======================================================================================================================================
*)

(*Re-code control location to IAS*)
IF (ControlPlace.ctrlLocation = 2) THEN
	IASCtrlLocation.2 := TRUE;
	IASCtrlLocation.1 := FALSE;
	IASCtrlLocation.0 := FALSE;
ELSE
	IASCtrlLocation.2 := FALSE;
	IASCtrlLocation.1 := FALSE;
	IASCtrlLocation.0 := FALSE;  
END_IF
;
END_PROGRAM

ACTIONS

END_ACTIONS