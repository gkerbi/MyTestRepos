PROGRAM PRG_AO
VAR
	BatteryVoltage_pc_minmax_range: 	REAL; 	(*Battery Bus voltage, part of which is over the minimum voltage as defined by sourceminvoltage*)
	BatteryChargeDischargeCurrent_pc: 	REAL;	(*Battery charge or discharge current in percent of sourcenominalcurrent*)
	BatteryVoltage_pc: 					REAL;	(*Battery voltage in percent of range between min and max source voltage*)
	BatteryPower_pc: 					REAL;	(*Battery power in percent of sourcenompower*)
	BatteryCurrent_pc: 					REAL;	(*Battery current in percent of sourcenominalcurrent*)
	BatterySoC_pc:						REAL;	(*Battery State of Charge in percent*)
	
	BatteryChargeDischargeCurrent_eng: 	REAL;	(*Battery charge or discharge current in Ampere*)
	BatteryVoltage_eng: 				REAL;	(*Battery voltage in volt*)
	BatteryPower_eng: 					REAL;	(*Battery power in kilowatt*)
	BatteryCurrent_eng: 				REAL;	(*Battery current in ampere*)
	BatterySoC_eng:						REAL;	(*Battery State of Charge in kWh*)
	
	BatteryChargeDischargeCurrent_Instr: 	REAL;	(*Battery charge or discharge current value to instrument*)
	BatteryVoltage_Instr: 					REAL;	(*Battery voltage value to instrument*)
	BatteryPower_Instr: 					REAL;	(*Battery power value to instrument*)
	BatteryCurrent_Instr: 					REAL;	(*Battery current value to instrument*)
	BatterySoC_Instr:						REAL;	(*Battery State of Charge value to instrument*)
	
	F_Trig : ARRAY[1..cnst_num_ao] OF F_TRIG;
	i : INT;	(*Loop variable*)
	ManualFixChannels : BOOL; (*Will reset channels if faulty, i.e. card number is zero*)
	Reset: BOOL;
	Firstrun : BOOL;
	
	(*Internal variables*)
	CurrentFilter : 				FILTER_I;
	PowerFilter : 					FILTER_I;
	VoltageFilter : 				FILTER_I;
	ChargeDischargeLimitFilter : 	FILTER_I;
	SoCFilter: 						FILTER_I;

	(*Analog Outputs*)
	ao_BatteryCurrentInstr_daemon: fb_AoProcess;
	ao_BatteryPowerInstr_daemon: fb_AoProcess;
	ao_BatteryVoltageInstr_daemon: fb_AoProcess;
	ao_BatterySocInstr_daemon: fb_AoProcess;
	ao_BatteryChrgDischrgInstr_daemon: fb_AoProcess;
	
	ao_BatteryCurrentInstr: str_AoProcess;
	ao_BatteryPowerInstr: str_AoProcess;
	ao_BatteryVoltageInstr: str_AoProcess;
	ao_BatterySocInstr: str_AoProcess;
	ao_BatteryChrgDischrgInstr: str_AoProcess;
END_VAR

VAR RETAIN
	ao_BatteryCurrentInstr_setup: str_AoSetup;
	ao_BatteryPowerInstr_setup: str_AoSetup;
	ao_BatteryVoltageInstr_setup: str_AoSetup;
	ao_BatterySocInstr_setup: str_AoSetup;
	ao_BatteryChrgDischrgInstr_setup: str_AoSetup;
END_VAR

Reset := PRG_Functions.Reset;

(*Setup the HMI variables so that they are equal to actual used variables*)
IF (NOT Firstrun) THEN
	hmi_AoSetup[1] := ao_BatteryCurrentInstr_setup;
	hmi_AoSetup[2] := ao_BatteryPowerInstr_setup;
	hmi_AoSetup[3] := ao_BatteryVoltageInstr_setup;
	hmi_AoSetup[4] := ao_BatterySocInstr_setup;
	hmi_AoSetup[5] := ao_BatteryChrgDischrgInstr_setup;
	Firstrun := TRUE;
END_IF


IF PRG_HMI.DoorSettings.enAmpInstrument THEN
	ao_BatteryCurrentInstr_daemon (setup:=ao_BatteryCurrentInstr_setup,reset:=Reset,inPV:=ao_BatteryCurrentInstr);
	hmi_AoPV[1]:=ao_BatteryCurrentInstr_daemon.inPV;
END_IF

IF PRG_HMI.DoorSettings.enkWInstrument THEN
	ao_BatteryPowerInstr_daemon (setup:=ao_BatteryPowerInstr_setup,reset:=Reset,inPV:=ao_BatteryPowerInstr);
	hmi_AoPV[2]:=ao_BatteryPowerInstr_daemon.inPV;
END_IF

IF PRG_HMI.DoorSettings.enVoltInstrument THEN
	ao_BatteryVoltageInstr_daemon (setup:=ao_BatteryVoltageInstr_setup,reset:=Reset,inPV:=ao_BatteryVoltageInstr);
	hmi_AoPV[3]:=ao_BatteryVoltageInstr_daemon.inPV;
END_IF

IF PRG_HMI.DoorSettings.enSoCInstrument THEN
	ao_BatterySocInstr_daemon (setup:=ao_BatterySocInstr_setup,reset:=Reset,inPV:=ao_BatterySocInstr);
	hmi_AoPV[4]:=ao_BatterySocInstr_daemon.inPV;
END_IF

IF PRG_HMI.DoorSettings.enChrgDischrgInstrument THEN
	ao_BatteryChrgDischrgInstr_daemon (setup:=ao_BatteryChrgDischrgInstr_setup,reset:=Reset,inPV:=ao_BatteryChrgDischrgInstr);
	hmi_AoPV[5]:=ao_BatteryChrgDischrgInstr_daemon.inPV;
END_IF



(*---------------------------------------- Channel initialization ----------------------------------------------*)


IF (ManualFixChannels) THEN  (*If manually forced: re-configure the channels*)
	FOR i:=0 TO cnst_num_ao BY 1 DO				(*Check if channel info is empty and restore if so.*)
		IF (hmi_AoSetup[i].CardNb = 0 AND PRG_HMI.setup_AioCard1_Number <> 0) THEN
			hmi_RestoreDefault_ao[i] := TRUE;
		END_IF
	END_FOR;
	ManualFixChannels := FALSE;
END_IF




(* 
 * ======================================================================================================================================= 
 * Calculate instrument values in percent (_pc) and engineering values (_eng)
 * =======================================================================================================================================
*)

BatteryCurrent_pc := 100*fun_SafeDivide(
 						divident := DINT_TO_REAL(ABS(PRG_BatteryComm.CorvusRead[PRG_BatteryComm.M].theArray.busCurrent)) , 
 						devisor := PRG_HMI.DriveSettings.SourceNomCurrent
);
BatteryCurrent_eng := DINT_TO_REAL(PRG_BatteryComm.CorvusRead[PRG_BatteryComm.M].theArray.busCurrent);


BatteryPower_pc := 100*fun_SafeDivide(
 						divident := PRG_BatteryComm.CorvusRead[PRG_BatteryComm.M].theArray.busPowerCalculated , 
 						devisor := PRG_HMI.DriveSettings.SourceNomPower
);
BatteryPower_eng := PRG_BatteryComm.CorvusRead[PRG_BatteryComm.M].theArray.busPowerCalculated;


BatteryVoltage_pc := 100*fun_SafeDivide(
	 						divident :=(PRG_BatteryComm.CorvusRead[PRG_BatteryComm.M].theArray.busVoltage - PRG_HMI.DriveSettings.SourceMinVoltage), 
	 						devisor := (PRG_HMI.DriveSettings.SourceMaxVoltage-PRG_HMI.DriveSettings.SourceMinVoltage)
);
BatteryVoltage_eng := PRG_BatteryComm.CorvusRead[PRG_BatteryComm.M].theArray.busVoltage;

BatterySoC_pc := PRG_BatteryComm.CorvusRead[PRG_BatteryComm.M].theArray.systemOnlineSOC;
BatterySoC_eng := PRG_Battery.AvailableEnergy;

IF (PRG_Battery.batteryCharging) THEN
	BatteryChargeDischargeCurrent_pc := 100 * fun_SafeDivide(
 						divident := PRG_Battery.DriveChargeLimit_eng, 
 						devisor := PRG_HMI.DriveSettings.SourceNomCurrent
 	);
	BatteryChargeDischargeCurrent_eng := PRG_Battery.DriveChargeLimit_eng;
ELSE
	BatteryChargeDischargeCurrent_pc := 100 * fun_SafeDivide(
 						divident := PRG_Battery.DriveDischargeLimit_eng, 
 						devisor := PRG_HMI.DriveSettings.SourceNomCurrent
);
	BatteryChargeDischargeCurrent_eng := PRG_Battery.DriveDischargeLimit_eng;
END_IF



(* 
 * ======================================================================================================================================= 
 * Select percent (_pc) or engineering values (_eng)
 * =======================================================================================================================================
*)
IF (PRG_HMI.DoorSettings.enPercentAmpInstrument) THEN
	BatteryCurrent_Instr :=  BatteryCurrent_pc;
ELSE
	BatteryCurrent_Instr := BatteryCurrent_eng;
END_IF

IF (PRG_HMI.DoorSettings.enPercentVoltInstrument) THEN
	BatteryVoltage_Instr :=  BatteryVoltage_pc;
ELSE
	BatteryVoltage_Instr := BatteryVoltage_eng;
END_IF

IF (PRG_HMI.DoorSettings.enPercentkWInstrument) THEN
	BatteryPower_Instr :=  BatteryPower_pc;
ELSE
	BatteryPower_Instr := BatteryPower_eng;
END_IF

IF (PRG_HMI.DoorSettings.enPercentSoCInstrument) THEN
	BatterySoC_Instr :=  BatterySoC_pc;
ELSE
	BatterySoC_Instr := BatterySoC_eng;
END_IF

IF (PRG_HMI.DoorSettings.enPercentChrgDischrgInstrument) THEN
	BatteryChargeDischargeCurrent_Instr :=  BatteryChargeDischargeCurrent_pc;
ELSE
	BatteryChargeDischargeCurrent_Instr := BatteryChargeDischargeCurrent_eng;
END_IF



(* 
 * ======================================================================================================================================= 
 * Enable absolute values
 * =======================================================================================================================================
*)
IF (PRG_HMI.DoorSettings.enAbsValuesAmpInstrument) THEN
	BatteryCurrent_Instr :=  ABS(BatteryCurrent_Instr);
END_IF

IF (PRG_HMI.DoorSettings.enAbsValuesVoltInstrument) THEN
	BatteryVoltage_Instr :=  ABS(BatteryVoltage_Instr);
END_IF

IF (PRG_HMI.DoorSettings.enAbsValueskWInstrument) THEN
	BatteryPower_Instr :=  ABS(BatteryPower_Instr);
END_IF

IF (PRG_HMI.DoorSettings.enAbsValuesSoCInstrument) THEN
	BatterySoC_Instr :=  ABS(BatterySoC_Instr);
END_IF

IF (PRG_HMI.DoorSettings.enAbsValuesChrgDischrgInstrument) THEN
	BatteryChargeDischargeCurrent_Instr :=  ABS(BatteryChargeDischargeCurrent_Instr);
END_IF


(* 
 * ======================================================================================================================================= 
 * Filter outputs
 * =======================================================================================================================================
*)



CurrentFilter(
	X := REAL_TO_INT(BatteryCurrent_Instr),
	T := PRG_HMI.DoorSettings.InstrumentFilterTime,
	Y => ao_BatteryCurrentInstr.PV
);

VoltageFilter(
	X := REAL_TO_INT(BatteryVoltage_Instr),
	T := PRG_HMI.DoorSettings.InstrumentFilterTime,
	Y => ao_BatteryVoltageInstr.PV
);

PowerFilter(
	X := REAL_TO_INT(BatteryPower_Instr),
	T := PRG_HMI.DoorSettings.InstrumentFilterTime,
	Y => ao_BatteryPowerInstr.PV
);

		
ChargeDischargeLimitFilter(
	X := LIMIT(0, REAL_TO_INT(BatteryChargeDischargeCurrent_pc), REAL_TO_INT(PRG_HMI.DriveSettings.SourceNomCurrent)),
	T := PRG_HMI.DoorSettings.InstrumentFilterTime,
	Y => ao_BatteryChrgDischrgInstr.PV
);

SoCFilter(
	X := REAL_TO_INT(BatterySoC_Instr),
	T := PRG_HMI.DoorSettings.InstrumentFilterTime,
	Y => ao_BatterySocInstr.PV
);

ChargeDischargeLimitFilter(
	X := REAL_TO_INT(BatteryChargeDischargeCurrent_Instr),
	T := PRG_HMI.DoorSettings.InstrumentFilterTime,
	Y => ao_BatteryChrgDischrgInstr.PV
);



END_PROGRAM

ACTIONS

ACTION Settings  

(***************ao_BatteryCurrentInstr***************)
IF (RestoreAllToDefault OR ao_BatteryCurrentInstr_setup.RestoreDefault  OR hmi_RestoreDefault_ao[1]) THEN
	ao_BatteryCurrentInstr_setup.Name:='ao_BatteryCurrentInstr'; 
	ao_BatteryCurrentInstr_setup.CardNb:=PRG_HMI.setup_AioCard1_Number; 
	ao_BatteryCurrentInstr_setup.ChannelMode:=16#62;
	ao_BatteryCurrentInstr_setup.ChannelNb:=3;
 	ao_BatteryCurrentInstr_setup.Enable.Forcing:=0; 
 	ao_BatteryCurrentInstr_setup.Enable.WireBreak:=1; 
 	ao_BatteryCurrentInstr_setup.Enable.OOR:=1; 
 	ao_BatteryCurrentInstr_setup.Delay.WireBreak:=T#1s; 
 	ao_BatteryCurrentInstr_setup.Delay.OoR:=T#1s; 
 	ao_BatteryCurrentInstr_setup.Levels.minPv:=0; 
 	ao_BatteryCurrentInstr_setup.Levels.maxPv:=120; 
 	ao_BatteryCurrentInstr_setup.Levels.MinOutputRaw:=0; 
 	ao_BatteryCurrentInstr_setup.Levels.MaxOutputRaw:=65536; 
 	ao_BatteryCurrentInstr_setup.Levels.ForceValue:=0; 
END_IF
IF (hmi_RestoreDefault_ao[1] OR RestoreAllToDefault OR ao_BatteryCurrentInstr_setup.RestoreDefault) THEN (*Copy values into HMI variable and reset*)
	hmi_AoSetup[1]:=ao_BatteryCurrentInstr_setup; (*Copy setup values from retain into hmi variable*)
	hmi_RestoreDefault_ao[1]:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
	ao_BatteryCurrentInstr_setup.RestoreDefault:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
END_IF
IF (hmi_AoWriteSetup[1]) THEN
	ao_BatteryCurrentInstr_setup:=hmi_AoSetup[1]; (*Paste hmi changes back into setup variable*)
	hmi_AoWriteSetup[1]:=FALSE; (*Make sure that the write variable is turned off after one write command*)
END_IF
F_Trig[1](CLK:=hmi_AoPV[1].IsForced); (*Reset HMI forcing dialog when timer runs out*)
IF (F_Trig[1].Q) THEN hmi_AoSetup[1].Enable.Forcing:=FALSE;ao_BatteryCurrentInstr_setup.Enable.Forcing:=FALSE; END_IF
(**************************************************)



(***************ao_BatteryPowerInstr***************)
IF (RestoreAllToDefault OR ao_BatteryPowerInstr_setup.RestoreDefault  OR hmi_RestoreDefault_ao[2]) THEN
	ao_BatteryPowerInstr_setup.Name:='ao_BatteryPowerInstr'; 
	ao_BatteryPowerInstr_setup.CardNb:=PRG_HMI.setup_AioCard1_Number; 
	ao_BatteryPowerInstr_setup.ChannelMode:=16#62;
	ao_BatteryPowerInstr_setup.ChannelNb:=5;
 	ao_BatteryPowerInstr_setup.Enable.Forcing:=0; 
 	ao_BatteryPowerInstr_setup.Enable.WireBreak:=1; 
 	ao_BatteryPowerInstr_setup.Enable.OOR:=1; 
 	ao_BatteryPowerInstr_setup.Delay.WireBreak:=T#1s; 
 	ao_BatteryPowerInstr_setup.Delay.OoR:=T#1s; 
 	ao_BatteryPowerInstr_setup.Levels.minPv:=0; 
 	ao_BatteryPowerInstr_setup.Levels.maxPv:=120; 
 	ao_BatteryPowerInstr_setup.Levels.MinOutputRaw:=0; 
 	ao_BatteryPowerInstr_setup.Levels.MaxOutputRaw:=65536; 
 	ao_BatteryPowerInstr_setup.Levels.ForceValue:=0; 
END_IF
IF (hmi_RestoreDefault_ao[2] OR RestoreAllToDefault OR ao_BatteryPowerInstr_setup.RestoreDefault) THEN (*Copy values into HMI variable and reset*)
	hmi_AoSetup[2]:=ao_BatteryPowerInstr_setup; (*Copy setup values from retain into hmi variable*)
	hmi_RestoreDefault_ao[2]:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
	ao_BatteryPowerInstr_setup.RestoreDefault:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
END_IF
IF (hmi_AoWriteSetup[2]) THEN
	ao_BatteryPowerInstr_setup:=hmi_AoSetup[2]; (*Paste hmi changes back into setup variable*)
	hmi_AoWriteSetup[2]:=FALSE; (*Make sure that the write variable is turned off after one write command*)
END_IF
F_Trig[2](CLK:=hmi_AoPV[2].IsForced); (*Reset HMI forcing dialog when timer runs out*)
IF (F_Trig[2].Q) THEN hmi_AoSetup[2].Enable.Forcing:=FALSE;ao_BatteryPowerInstr_setup.Enable.Forcing:=FALSE; END_IF
(**************************************************)



(***************ao_BatteryVoltageInstr***************)
IF (RestoreAllToDefault OR ao_BatteryVoltageInstr_setup.RestoreDefault  OR hmi_RestoreDefault_ao[3]) THEN
	ao_BatteryVoltageInstr_setup.Name:='ao_BatteryVoltageInstr'; 
	ao_BatteryVoltageInstr_setup.CardNb:=PRG_HMI.setup_AioCard1_Number; 
	ao_BatteryVoltageInstr_setup.ChannelMode:=16#62;
	ao_BatteryVoltageInstr_setup.ChannelNb:=7;
 	ao_BatteryVoltageInstr_setup.Enable.Forcing:=0; 
 	ao_BatteryVoltageInstr_setup.Enable.WireBreak:=1; 
 	ao_BatteryVoltageInstr_setup.Enable.OOR:=1; 
 	ao_BatteryVoltageInstr_setup.Delay.WireBreak:=T#1s; 
 	ao_BatteryVoltageInstr_setup.Delay.OoR:=T#1s; 
 	ao_BatteryVoltageInstr_setup.Levels.minPv:=0; 
 	ao_BatteryVoltageInstr_setup.Levels.maxPv:=120; 
 	ao_BatteryVoltageInstr_setup.Levels.MinOutputRaw:=0; 
 	ao_BatteryVoltageInstr_setup.Levels.MaxOutputRaw:=65536; 
 	ao_BatteryVoltageInstr_setup.Levels.ForceValue:=0; 
END_IF
IF (hmi_RestoreDefault_ao[3] OR RestoreAllToDefault OR ao_BatteryVoltageInstr_setup.RestoreDefault) THEN (*Copy values into HMI variable and reset*)
	hmi_AoSetup[3]:=ao_BatteryVoltageInstr_setup; (*Copy setup values from retain into hmi variable*)
	hmi_RestoreDefault_ao[3]:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
	ao_BatteryVoltageInstr_setup.RestoreDefault:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
END_IF
IF (hmi_AoWriteSetup[3]) THEN
	ao_BatteryVoltageInstr_setup:=hmi_AoSetup[3]; (*Paste hmi changes back into setup variable*)
	hmi_AoWriteSetup[3]:=FALSE; (*Make sure that the write variable is turned off after one write command*)
END_IF
F_Trig[3](CLK:=hmi_AoPV[3].IsForced); (*Reset HMI forcing dialog when timer runs out*)
IF (F_Trig[3].Q) THEN hmi_AoSetup[3].Enable.Forcing:=FALSE;ao_BatteryVoltageInstr_setup.Enable.Forcing:=FALSE; END_IF
(**************************************************)



(***************ao_BatterySocInstr***************)
IF (RestoreAllToDefault OR ao_BatterySocInstr_setup.RestoreDefault  OR hmi_RestoreDefault_ao[4]) THEN
	ao_BatterySocInstr_setup.Name:='ao_BatterySocInstr'; 
	ao_BatterySocInstr_setup.CardNb:=PRG_HMI.setup_AioCard1_Number; 
	ao_BatterySocInstr_setup.ChannelMode:=16#62;
	ao_BatterySocInstr_setup.ChannelNb:=9;
 	ao_BatterySocInstr_setup.Enable.Forcing:=0; 
 	ao_BatterySocInstr_setup.Enable.WireBreak:=1; 
 	ao_BatterySocInstr_setup.Enable.OOR:=1; 
 	ao_BatterySocInstr_setup.Delay.WireBreak:=T#1s; 
 	ao_BatterySocInstr_setup.Delay.OoR:=T#1s; 
 	ao_BatterySocInstr_setup.Levels.minPv:=0; 
 	ao_BatterySocInstr_setup.Levels.maxPv:=120; 
 	ao_BatterySocInstr_setup.Levels.MinOutputRaw:=0; 
 	ao_BatterySocInstr_setup.Levels.MaxOutputRaw:=65536; 
 	ao_BatterySocInstr_setup.Levels.ForceValue:=0; 
END_IF
IF (hmi_RestoreDefault_ao[4] OR RestoreAllToDefault OR ao_BatterySocInstr_setup.RestoreDefault) THEN (*Copy values into HMI variable and reset*)
	hmi_AoSetup[4]:=ao_BatterySocInstr_setup; (*Copy setup values from retain into hmi variable*)
	hmi_RestoreDefault_ao[4]:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
	ao_BatterySocInstr_setup.RestoreDefault:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
END_IF
IF (hmi_AoWriteSetup[4]) THEN
	ao_BatterySocInstr_setup:=hmi_AoSetup[4]; (*Paste hmi changes back into setup variable*)
	hmi_AoWriteSetup[4]:=FALSE; (*Make sure that the write variable is turned off after one write command*)
END_IF
F_Trig[4](CLK:=hmi_AoPV[4].IsForced); (*Reset HMI forcing dialog when timer runs out*)
IF (F_Trig[4].Q) THEN hmi_AoSetup[4].Enable.Forcing:=FALSE;ao_BatterySocInstr_setup.Enable.Forcing:=FALSE; END_IF
(**************************************************)



(***************ao_BatteryChrgDischrgInstr***************)
IF (RestoreAllToDefault OR ao_BatteryChrgDischrgInstr_setup.RestoreDefault  OR hmi_RestoreDefault_ao[5]) THEN
	ao_BatteryChrgDischrgInstr_setup.Name:='ao_BatteryChrgDischrgInstr'; 
	ao_BatteryChrgDischrgInstr_setup.CardNb:=PRG_HMI.setup_AioCard1_Number; 
	ao_BatteryChrgDischrgInstr_setup.ChannelMode:=16#62;
	ao_BatteryChrgDischrgInstr_setup.ChannelNb:=11;
 	ao_BatteryChrgDischrgInstr_setup.Enable.Forcing:=0; 
 	ao_BatteryChrgDischrgInstr_setup.Enable.WireBreak:=1; 
 	ao_BatteryChrgDischrgInstr_setup.Enable.OOR:=1; 
 	ao_BatteryChrgDischrgInstr_setup.Delay.WireBreak:=T#1s; 
 	ao_BatteryChrgDischrgInstr_setup.Delay.OoR:=T#1s; 
 	ao_BatteryChrgDischrgInstr_setup.Levels.minPv:=0; 
 	ao_BatteryChrgDischrgInstr_setup.Levels.maxPv:=120; 
 	ao_BatteryChrgDischrgInstr_setup.Levels.MinOutputRaw:=0; 
 	ao_BatteryChrgDischrgInstr_setup.Levels.MaxOutputRaw:=65536; 
 	ao_BatteryChrgDischrgInstr_setup.Levels.ForceValue:=0; 
END_IF
IF (hmi_RestoreDefault_ao[5] OR RestoreAllToDefault OR ao_BatteryChrgDischrgInstr_setup.RestoreDefault) THEN (*Copy values into HMI variable and reset*)
	hmi_AoSetup[5]:=ao_BatteryChrgDischrgInstr_setup; (*Copy setup values from retain into hmi variable*)
	hmi_RestoreDefault_ao[5]:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
	ao_BatteryChrgDischrgInstr_setup.RestoreDefault:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
END_IF
IF (hmi_AoWriteSetup[5]) THEN
	ao_BatteryChrgDischrgInstr_setup:=hmi_AoSetup[5]; (*Paste hmi changes back into setup variable*)
	hmi_AoWriteSetup[5]:=FALSE; (*Make sure that the write variable is turned off after one write command*)
END_IF
F_Trig[5](CLK:=hmi_AoPV[5].IsForced); (*Reset HMI forcing dialog when timer runs out*)
IF (F_Trig[5].Q) THEN hmi_AoSetup[5].Enable.Forcing:=FALSE;ao_BatteryChrgDischrgInstr_setup.Enable.Forcing:=FALSE; END_IF
(**************************************************)





END_ACTION

END_ACTIONS