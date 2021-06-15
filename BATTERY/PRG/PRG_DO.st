PROGRAM PRG_DO
VAR
	F_Trig : ARRAY[1..cnst_num_do] OF F_TRIG;
	i: INT;
	ManualFixChannels : BOOL; (*Will reset channels if faulty, i.e. card number is zero*)
	Reset: BOOL;
	Firstrun: BOOL;
	(*Interal variables*)
	Fan_SR : 				SR;
	
	(* Digital Outputs*)
	do_RunningLamp: str_DoProcess;
	do_Running: str_DoProcess;
	do_StoppedLamp: str_DoProcess;
	do_Stopped: str_DoProcess;
	do_FaultLamp: str_DoProcess;
	do_WarningLamp: str_DoProcess;
	do_StartFan: str_DoProcess;
	do_EnergizedLamp: str_DoProcess;
	do_LampTest: str_DoProcess;
	do_ReadyLamp: str_DoProcess;
	do_ChargingLamp: str_DoProcess;
	do_ShutdownPlcFailure: str_DoProcess;
	do_LocalLamp: str_DoProcess;
		
	do_RunningLamp_daemon: fb_DoProcess;
	do_Running_daemon: fb_DoProcess;
	do_StoppedLamp_daemon: fb_DoProcess;
	do_Stopped_daemon: fb_DoProcess;
	do_FaultLamp_daemon: fb_DoProcess;
	do_WarningLamp_daemon: fb_DoProcess;
	do_StartFan_daemon: fb_DoProcess;
	do_EnergizedLamp_daemon: fb_DoProcess;
	do_LampTest_daemon: fb_DoProcess;
	do_ReadyLamp_daemon: fb_DoProcess;
	do_ChargingLamp_daemon: fb_DoProcess;
	do_ShutdownPlcFailure_daemon: fb_DoProcess;
	do_LocalLamp_daemon: fb_DoProcess;
END_VAR

VAR RETAIN
	do_RunningLamp_setup: str_DoSetup;
	do_Running_setup: str_DoSetup;
	do_StoppedLamp_setup: str_DoSetup;
	do_Stopped_setup: str_DoSetup;
	do_FaultLamp_setup: str_DoSetup;
	do_WarningLamp_setup: str_DoSetup;
	do_StartFan_setup: str_DoSetup;
	do_EnergizedLamp_setup: str_DoSetup;
	do_LampTest_setup: str_DoSetup;
	do_ReadyLamp_setup: str_DoSetup;
	do_ChargingLamp_setup: str_DoSetup;
	do_ShutdownPlcFailure_setup: str_DoSetup;
	do_LocalLamp_setup: str_DoSetup;
END_VAR


Reset := PRG_Functions.Reset;

(*Setup the HMI variables so that they are equal to actual used variables*)
IF (NOT Firstrun) THEN
	hmi_DoSetup[1]:=do_RunningLamp_setup;
	hmi_DoSetup[2]:=do_Running_setup;
	hmi_DoSetup[3]:=do_StoppedLamp_setup;
	hmi_DoSetup[4]:=do_Stopped_setup;
	hmi_DoSetup[5]:=do_FaultLamp_setup;
	hmi_DoSetup[6]:=do_WarningLamp_setup;
	hmi_DoSetup[7]:=do_StartFan_setup;
	hmi_DoSetup[8]:=do_EnergizedLamp_setup;
	hmi_DoSetup[9]:=do_LampTest_setup;
	hmi_DoSetup[10]:=do_ReadyLamp_setup;
	hmi_DoSetup[11]:=do_ChargingLamp_setup;
	hmi_DoSetup[12]:=do_ShutdownPlcFailure_setup;
	hmi_DoSetup[13]:=do_LocalLamp_setup;
	Firstrun := TRUE;
END_IF

do_StartFan_daemon (setup:=do_StartFan_setup,inPV:=do_StartFan);
do_LampTest_daemon (setup:=do_LampTest_setup,inPV:=do_LampTest);
do_Running_daemon (setup:=do_Running_setup,inPV:=do_Running);
do_Stopped_daemon (setup:=do_Stopped_setup,inPV:=do_Stopped);
do_ShutdownPlcFailure_daemon (setup:=do_ShutdownPlcFailure_setup,inPV:=do_ShutdownPlcFailure);

IF PRG_HMI.DoorSettings.enRunningLamp THEN
	do_RunningLamp_daemon (setup:=do_RunningLamp_setup,inPV:=do_RunningLamp);
END_IF

IF PRG_HMI.DoorSettings.enStoppedLamp THEN
	do_StoppedLamp_daemon (setup:=do_StoppedLamp_setup,inPV:=do_StoppedLamp);
END_IF

IF PRG_HMI.DoorSettings.enFaultLamp THEN
	do_FaultLamp_daemon (setup:=do_FaultLamp_setup,inPV:=do_FaultLamp);
END_IF

IF PRG_HMI.DoorSettings.enWarningLamp THEN
	do_WarningLamp_daemon (setup:=do_WarningLamp_setup,inPV:=do_WarningLamp);
END_IF

IF PRG_HMI.DoorSettings.enChargingLamp THEN
	do_ChargingLamp_daemon (setup:=do_ChargingLamp_setup,inPV:=do_ChargingLamp);
END_IF

IF PRG_HMI.DoorSettings.enLocalLamp THEN
	do_LocalLamp_daemon (setup:=do_LocalLamp_setup,inPV:=do_LocalLamp);
END_IF

IF PRG_HMI.DoorSettings.enReadyLamp THEN
	do_ReadyLamp_daemon (setup:=do_ReadyLamp_setup,inPV:=do_ReadyLamp);
END_IF

IF PRG_HMI.DoorSettings.enEnergizedLamp THEN
	do_EnergizedLamp_daemon (setup:=do_EnergizedLamp_setup,inPV:=do_EnergizedLamp);
END_IF



hmi_DoPV[1]:=do_RunningLamp_daemon.inPV;
hmi_DoPV[2]:=do_Running_daemon.inPV;
hmi_DoPV[3]:=do_StoppedLamp_daemon.inPV;
hmi_DoPV[4]:=do_Stopped_daemon.inPV;
hmi_DoPV[5]:=do_FaultLamp_daemon.inPV;
hmi_DoPV[6]:=do_WarningLamp_daemon.inPV;
hmi_DoPV[7]:=do_StartFan_daemon.inPV;
hmi_DoPV[8]:=do_EnergizedLamp_daemon.inPV;
hmi_DoPV[9]:=do_LampTest_daemon.inPV;
hmi_DoPV[10]:=do_ReadyLamp_daemon.inPV;
hmi_DoPV[11]:=do_ChargingLamp_daemon.inPV;
hmi_DoPV[12]:=do_ShutdownPlcFailure_daemon.inPV;
hmi_DoPV[13]:=do_LocalLamp_daemon.inPV;


IF (ManualFixChannels) THEN  (*If manually forced: re-configure the channels*)
	FOR i:=0 TO cnst_num_do BY 1 DO				(*Check if channel info is empty and restore if so.*)
		IF (hmi_DoSetup[i].CardNb = 0 AND PRG_HMI.setup_DioCard1_Number <> 0) THEN
			hmi_RestoreDefault_do[i] := TRUE;
		END_IF
	END_FOR;
	ManualFixChannels := FALSE;
END_IF



(*------------------------------------Control of cabinet lamps -------------------------------------*)

(*In Local Lamp*)
IF PRG_HMI.DoorSettings.enLocalLamp THEN
	IF(PRG_IAS.IasCommunication.Alarm AND (PRG_Operation.ControlPlace.ctrlLocation = e_Remote)) THEN
		do_LocalLamp.PV := PRG_StateMain.LedBlinker.CLK_Pulse;
	ELSE
		do_LocalLamp.PV	:= PRG_Operation.ControlPlace.ctrlLocation = e_Local XOR PRG_HMI.LamptestPulsetrain.CLK_Pulse;
	END_IF
END_IF

(*Running Lamp*)
IF PRG_HMI.DoorSettings.enRunningLamp THEN
	do_RunningLamp.PV := (PRG_StateMain.RunningLamp XOR PRG_HMI.LamptestPulsetrain.CLK_Pulse);
END_IF

(*Stopped Lamp*)
IF PRG_HMI.DoorSettings.enStoppedLamp THEN
	do_StoppedLamp.PV := (PRG_StateMain.StoppedLamp XOR PRG_HMI.LamptestPulsetrain.CLK_Pulse );
END_IF

(*Warning Lamp*)
IF PRG_HMI.DoorSettings.enWarningLamp THEN
	do_WarningLamp.PV := (PRG_Alarms.Repeat_Alarm.Alarm_common XOR PRG_HMI.LamptestPulsetrain.CLK_Pulse);
END_IF

(*Fault Lamp*)
IF PRG_HMI.DoorSettings.enFaultLamp THEN
	do_FaultLamp.PV := (PRG_Faults.Repeat_Fault.Alarm_common XOR PRG_HMI.LamptestPulsetrain.CLK_Pulse);
END_IF

(*Charging Lamp*)
IF PRG_HMI.DoorSettings.enChargingLamp THEN
	do_ChargingLamp.PV := (PRG_Battery.batteryCharging XOR PRG_HMI.LamptestPulsetrain.CLK_Pulse);
END_IF

(*Ready to Start Lamp*)
IF PRG_HMI.DoorSettings.enReadyLamp THEN
	do_ReadyLamp.PV := (PRG_HMI.ReadyToStart XOR PRG_HMI.LamptestPulsetrain.CLK_Pulse);
END_IF

(*Energized Lamp*)
IF PRG_HMI.DoorSettings.enEnergizedLamp THEN
	do_EnergizedLamp.PV := (PRG_Battery.BatteryMinOneConnected XOR PRG_HMI.LamptestPulsetrain.CLK_Pulse);
END_IF

(*Lamp test relay for lamps not connected to PLC*)
do_LampTest.PV := PRG_HMI.LamptestPulsetrain.CLK_Pulse;


(*------------------------------------Hardwire Status Outputs -------------------------------------*)

do_Stopped.PV := PRG_StateMain.StoppedOutput;
do_Running.PV := PRG_StateMain.RunningOutput;

(*------------------------------------Control of cabinet fan -------------------------------------*)
Fan_SR(
	SET1 := PRG_AI.ai_CabinetTemperature.Level.H,
	RESET := PRG_AI.ai_CabinetTemperature.Level.L,
	Q1 => do_StartFan.PV
);


(*------------------------------------ Hardwire Shutdown -------------------------------------*)
(*If modbus fault or no stopping - drop the white gloves.*)
IF 	(PRG_BatteryComm.CorvusBMS_Total_Comm_Fault OR PRG_StateMain.stoppingTON.Q OR PRG_Drive.CommFault[1]) THEN
	do_ShutdownPlcFailure.PV := FALSE; 
ELSE 
	do_ShutdownPlcFailure.PV := TRUE;
END_IF





END_PROGRAM

ACTIONS

ACTION Settings

(**************do_RunningLamp***********************)
IF (RestoreAllToDefault OR do_RunningLamp_setup.RestoreDefault  OR hmi_RestoreDefault_do[1]) THEN
	do_RunningLamp_setup.Name:='do_RunningLamp'; 
	do_RunningLamp_setup.CardNb:=PRG_HMI.setup_DioCard1_Number; 
	do_RunningLamp_setup.ChannelMode:=2;
	do_RunningLamp_setup.ChannelNb:=1;
	do_RunningLamp_setup.Enable.Forcing:=0; 
	do_RunningLamp_setup.Levels.ForceValue:=0;
END_IF
IF (hmi_RestoreDefault_do[1] OR RestoreAllToDefault OR do_RunningLamp_setup.RestoreDefault) THEN (*Copy values into HMI variable and reset*)
	hmi_DoSetup[1]:=do_RunningLamp_setup; (*Copy setup values from retain into hmi variable*)
	hmi_RestoreDefault_do[1]:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
	do_RunningLamp_setup.RestoreDefault:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
END_IF
IF (hmi_DoWriteSetup[1]) THEN
	do_RunningLamp_setup:=hmi_DoSetup[1]; (*Paste hmi changes back into setup variable*)
	hmi_DoWriteSetup[1]:=FALSE; (*Make sure that the write variable is turned off after one write command*)
END_IF
F_Trig[1](CLK:=hmi_DoPV[1].IsForced); (*Reset HMI forcing dialog when timer runs out*)
IF (F_Trig[1].Q) THEN hmi_DoSetup[1].Enable.Forcing:=FALSE;do_RunningLamp_setup.Enable.Forcing:=FALSE; END_IF
(**************************************************)



(**************do_Running***********************)
IF (RestoreAllToDefault OR do_Running_setup.RestoreDefault  OR hmi_RestoreDefault_do[2]) THEN
	do_Running_setup.Name:='do_Running'; 
	do_Running_setup.CardNb:=PRG_HMI.setup_DioCard1_Number; 
	do_Running_setup.ChannelMode:=2;
	do_Running_setup.ChannelNb:=2;
	do_Running_setup.Enable.Forcing:=0; 
	do_Running_setup.Levels.ForceValue:=0;
END_IF
IF (hmi_RestoreDefault_do[2] OR RestoreAllToDefault OR do_Running_setup.RestoreDefault) THEN (*Copy values into HMI variable and reset*)
	hmi_DoSetup[2]:=do_Running_setup; (*Copy setup values from retain into hmi variable*)
	hmi_RestoreDefault_do[2]:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
	do_Running_setup.RestoreDefault:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
END_IF
IF (hmi_DoWriteSetup[2]) THEN
	do_Running_setup:=hmi_DoSetup[2]; (*Paste hmi changes back into setup variable*)
	hmi_DoWriteSetup[2]:=FALSE; (*Make sure that the write variable is turned off after one write command*)
END_IF
F_Trig[2](CLK:=hmi_DoPV[2].IsForced); (*Reset HMI forcing dialog when timer runs out*)
IF (F_Trig[2].Q) THEN hmi_DoSetup[2].Enable.Forcing:=FALSE;do_Running_setup.Enable.Forcing:=FALSE; END_IF
(**************************************************)



(**************do_StoppedLamp***********************)
IF (RestoreAllToDefault OR do_StoppedLamp_setup.RestoreDefault  OR hmi_RestoreDefault_do[3]) THEN
	do_StoppedLamp_setup.Name:='do_StoppedLamp'; 
	do_StoppedLamp_setup.CardNb:=PRG_HMI.setup_DioCard1_Number; 
	do_StoppedLamp_setup.ChannelMode:=2;
	do_StoppedLamp_setup.ChannelNb:=3;
	do_StoppedLamp_setup.Enable.Forcing:=0; 
	do_StoppedLamp_setup.Levels.ForceValue:=0;
END_IF
IF (hmi_RestoreDefault_do[3] OR RestoreAllToDefault OR do_StoppedLamp_setup.RestoreDefault) THEN (*Copy values into HMI variable and reset*)
	hmi_DoSetup[3]:=do_StoppedLamp_setup; (*Copy setup values from retain into hmi variable*)
	hmi_RestoreDefault_do[3]:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
	do_StoppedLamp_setup.RestoreDefault:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
END_IF
IF (hmi_DoWriteSetup[3]) THEN
	do_StoppedLamp_setup:=hmi_DoSetup[3]; (*Paste hmi changes back into setup variable*)
	hmi_DoWriteSetup[3]:=FALSE; (*Make sure that the write variable is turned off after one write command*)
END_IF
F_Trig[3](CLK:=hmi_DoPV[3].IsForced); (*Reset HMI forcing dialog when timer runs out*)
IF (F_Trig[3].Q) THEN hmi_DoSetup[3].Enable.Forcing:=FALSE;do_StoppedLamp_setup.Enable.Forcing:=FALSE; END_IF
(**************************************************)



(**************do_Stopped***********************)
IF (RestoreAllToDefault OR do_Stopped_setup.RestoreDefault  OR hmi_RestoreDefault_do[4]) THEN
	do_Stopped_setup.Name:='do_Stopped'; 
	do_Stopped_setup.CardNb:=PRG_HMI.setup_DioCard1_Number; 
	do_Stopped_setup.ChannelMode:=2;
	do_Stopped_setup.ChannelNb:=4;
	do_Stopped_setup.Enable.Forcing:=0; 
	do_Stopped_setup.Levels.ForceValue:=0;
END_IF
IF (hmi_RestoreDefault_do[4] OR RestoreAllToDefault OR do_Stopped_setup.RestoreDefault) THEN (*Copy values into HMI variable and reset*)
	hmi_DoSetup[4]:=do_Stopped_setup; (*Copy setup values from retain into hmi variable*)
	hmi_RestoreDefault_do[4]:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
	do_Stopped_setup.RestoreDefault:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
END_IF
IF (hmi_DoWriteSetup[4]) THEN
	do_Stopped_setup:=hmi_DoSetup[4]; (*Paste hmi changes back into setup variable*)
	hmi_DoWriteSetup[4]:=FALSE; (*Make sure that the write variable is turned off after one write command*)
END_IF
F_Trig[4](CLK:=hmi_DoPV[4].IsForced); (*Reset HMI forcing dialog when timer runs out*)
IF (F_Trig[4].Q) THEN hmi_DoSetup[4].Enable.Forcing:=FALSE;do_Stopped_setup.Enable.Forcing:=FALSE; END_IF
(**************************************************)



(**************do_FaultLamp***********************)
IF (RestoreAllToDefault OR do_FaultLamp_setup.RestoreDefault  OR hmi_RestoreDefault_do[5]) THEN
	do_FaultLamp_setup.Name:='do_FaultLamp'; 
	do_FaultLamp_setup.CardNb:=PRG_HMI.setup_DioCard1_Number; 
	do_FaultLamp_setup.ChannelMode:=2;
	do_FaultLamp_setup.ChannelNb:=5;
	do_FaultLamp_setup.Enable.Forcing:=0; 
	do_FaultLamp_setup.Levels.ForceValue:=0;
END_IF
IF (hmi_RestoreDefault_do[5] OR RestoreAllToDefault OR do_FaultLamp_setup.RestoreDefault) THEN (*Copy values into HMI variable and reset*)
	hmi_DoSetup[5]:=do_FaultLamp_setup; (*Copy setup values from retain into hmi variable*)
	hmi_RestoreDefault_do[5]:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
	do_FaultLamp_setup.RestoreDefault:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
END_IF
IF (hmi_DoWriteSetup[5]) THEN
	do_FaultLamp_setup:=hmi_DoSetup[5]; (*Paste hmi changes back into setup variable*)
	hmi_DoWriteSetup[5]:=FALSE; (*Make sure that the write variable is turned off after one write command*)
END_IF
F_Trig[5](CLK:=hmi_DoPV[5].IsForced); (*Reset HMI forcing dialog when timer runs out*)
IF (F_Trig[5].Q) THEN hmi_DoSetup[5].Enable.Forcing:=FALSE;do_FaultLamp_setup.Enable.Forcing:=FALSE; END_IF
(**************************************************)



(**************do_WarningLamp***********************)
IF (RestoreAllToDefault OR do_WarningLamp_setup.RestoreDefault  OR hmi_RestoreDefault_do[6]) THEN
	do_WarningLamp_setup.Name:='do_WarningLamp'; 
	do_WarningLamp_setup.CardNb:=PRG_HMI.setup_DioCard1_Number; 
	do_WarningLamp_setup.ChannelMode:=2;
	do_WarningLamp_setup.ChannelNb:=6;
	do_WarningLamp_setup.Enable.Forcing:=0; 
	do_WarningLamp_setup.Levels.ForceValue:=0;
END_IF
IF (hmi_RestoreDefault_do[6] OR RestoreAllToDefault OR do_WarningLamp_setup.RestoreDefault) THEN (*Copy values into HMI variable and reset*)
	hmi_DoSetup[6]:=do_WarningLamp_setup; (*Copy setup values from retain into hmi variable*)
	hmi_RestoreDefault_do[6]:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
	do_WarningLamp_setup.RestoreDefault:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
END_IF
IF (hmi_DoWriteSetup[6]) THEN
	do_WarningLamp_setup:=hmi_DoSetup[6]; (*Paste hmi changes back into setup variable*)
	hmi_DoWriteSetup[6]:=FALSE; (*Make sure that the write variable is turned off after one write command*)
END_IF
F_Trig[6](CLK:=hmi_DoPV[6].IsForced); (*Reset HMI forcing dialog when timer runs out*)
IF (F_Trig[6].Q) THEN hmi_DoSetup[6].Enable.Forcing:=FALSE;do_WarningLamp_setup.Enable.Forcing:=FALSE; END_IF
(**************************************************)



(**************do_StartFan***********************)
IF (RestoreAllToDefault OR do_StartFan_setup.RestoreDefault  OR hmi_RestoreDefault_do[7]) THEN
	do_StartFan_setup.Name:='do_StartFan'; 
	do_StartFan_setup.CardNb:=PRG_HMI.setup_DioCard1_Number; 
	do_StartFan_setup.ChannelMode:=2;
	do_StartFan_setup.ChannelNb:=10;
	do_StartFan_setup.Enable.Forcing:=0; 
	do_StartFan_setup.Levels.ForceValue:=0;
END_IF
IF (hmi_RestoreDefault_do[7] OR RestoreAllToDefault OR do_StartFan_setup.RestoreDefault) THEN (*Copy values into HMI variable and reset*)
	hmi_DoSetup[7]:=do_StartFan_setup; (*Copy setup values from retain into hmi variable*)
	hmi_RestoreDefault_do[7]:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
	do_StartFan_setup.RestoreDefault:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
END_IF
IF (hmi_DoWriteSetup[7]) THEN
	do_StartFan_setup:=hmi_DoSetup[7]; (*Paste hmi changes back into setup variable*)
	hmi_DoWriteSetup[7]:=FALSE; (*Make sure that the write variable is turned off after one write command*)
END_IF
F_Trig[7](CLK:=hmi_DoPV[7].IsForced); (*Reset HMI forcing dialog when timer runs out*)
IF (F_Trig[7].Q) THEN hmi_DoSetup[7].Enable.Forcing:=FALSE;do_StartFan_setup.Enable.Forcing:=FALSE; END_IF
(**************************************************)



(**************do_EnergizedLamp***********************)
IF (RestoreAllToDefault OR do_EnergizedLamp_setup.RestoreDefault  OR hmi_RestoreDefault_do[8]) THEN
	do_EnergizedLamp_setup.Name:='do_EnergizedLamp'; 
	do_EnergizedLamp_setup.CardNb:=PRG_HMI.setup_DioCard1_Number; 
	do_EnergizedLamp_setup.ChannelMode:=2;
	do_EnergizedLamp_setup.ChannelNb:=11;
	do_EnergizedLamp_setup.Enable.Forcing:=0; 
	do_EnergizedLamp_setup.Levels.ForceValue:=0;
END_IF
IF (hmi_RestoreDefault_do[8] OR RestoreAllToDefault OR do_EnergizedLamp_setup.RestoreDefault) THEN (*Copy values into HMI variable and reset*)
	hmi_DoSetup[8]:=do_EnergizedLamp_setup; (*Copy setup values from retain into hmi variable*)
	hmi_RestoreDefault_do[8]:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
	do_EnergizedLamp_setup.RestoreDefault:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
END_IF
IF (hmi_DoWriteSetup[8]) THEN
	do_EnergizedLamp_setup:=hmi_DoSetup[8]; (*Paste hmi changes back into setup variable*)
	hmi_DoWriteSetup[8]:=FALSE; (*Make sure that the write variable is turned off after one write command*)
END_IF
F_Trig[8](CLK:=hmi_DoPV[8].IsForced); (*Reset HMI forcing dialog when timer runs out*)
IF (F_Trig[8].Q) THEN hmi_DoSetup[8].Enable.Forcing:=FALSE;do_EnergizedLamp_setup.Enable.Forcing:=FALSE; END_IF
(**************************************************)




(**************do_LampTest***********************)
IF (RestoreAllToDefault OR do_LampTest_setup.RestoreDefault  OR hmi_RestoreDefault_do[9]) THEN
	do_LampTest_setup.Name:='do_LampTest'; 
	do_LampTest_setup.CardNb:=PRG_HMI.setup_DioCard1_Number; 
	do_LampTest_setup.ChannelMode:=2;
	do_LampTest_setup.ChannelNb:=12;
	do_LampTest_setup.Enable.Forcing:=0; 
	do_LampTest_setup.Levels.ForceValue:=0;
END_IF
IF (hmi_RestoreDefault_do[9] OR RestoreAllToDefault OR do_LampTest_setup.RestoreDefault) THEN (*Copy values into HMI variable and reset*)
	hmi_DoSetup[9]:=do_LampTest_setup; (*Copy setup values from retain into hmi variable*)
	hmi_RestoreDefault_do[9]:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
	do_LampTest_setup.RestoreDefault:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
END_IF
IF (hmi_DoWriteSetup[9]) THEN
	do_LampTest_setup:=hmi_DoSetup[9]; (*Paste hmi changes back into setup variable*)
	hmi_DoWriteSetup[9]:=FALSE; (*Make sure that the write variable is turned off after one write command*)
END_IF
F_Trig[9](CLK:=hmi_DoPV[9].IsForced); (*Reset HMI forcing dialog when timer runs out*)
IF (F_Trig[9].Q) THEN hmi_DoSetup[9].Enable.Forcing:=FALSE;do_LampTest_setup.Enable.Forcing:=FALSE; END_IF
(**************************************************)



(**************do_ReadyLamp***********************)
IF (RestoreAllToDefault OR do_ReadyLamp_setup.RestoreDefault  OR hmi_RestoreDefault_do[10]) THEN
	do_ReadyLamp_setup.Name:='do_ReadyLamp'; 
	do_ReadyLamp_setup.CardNb:=PRG_HMI.setup_DioCard1_Number; 
	do_ReadyLamp_setup.ChannelMode:=2;
	do_ReadyLamp_setup.ChannelNb:=13;
	do_ReadyLamp_setup.Enable.Forcing:=0; 
	do_ReadyLamp_setup.Levels.ForceValue:=0;
END_IF
IF (hmi_RestoreDefault_do[10] OR RestoreAllToDefault OR do_ReadyLamp_setup.RestoreDefault) THEN (*Copy values into HMI variable and reset*)
	hmi_DoSetup[10]:=do_ReadyLamp_setup; (*Copy setup values from retain into hmi variable*)
	hmi_RestoreDefault_do[10]:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
	do_ReadyLamp_setup.RestoreDefault:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
END_IF
IF (hmi_DoWriteSetup[10]) THEN
	do_ReadyLamp_setup:=hmi_DoSetup[10]; (*Paste hmi changes back into setup variable*)
	hmi_DoWriteSetup[10]:=FALSE; (*Make sure that the write variable is turned off after one write command*)
END_IF
F_Trig[10](CLK:=hmi_DoPV[10].IsForced); (*Reset HMI forcing dialog when timer runs out*)
IF (F_Trig[10].Q) THEN hmi_DoSetup[10].Enable.Forcing:=FALSE;do_ReadyLamp_setup.Enable.Forcing:=FALSE; END_IF
(**************************************************)




(**************do_ChargingLamp***********************)
IF (RestoreAllToDefault OR do_ChargingLamp_setup.RestoreDefault  OR hmi_RestoreDefault_do[11]) THEN
	do_ChargingLamp_setup.Name:='do_ChargingLamp'; 
	do_ChargingLamp_setup.CardNb:=PRG_HMI.setup_DioCard1_Number; 
	do_ChargingLamp_setup.ChannelMode:=2;
	do_ChargingLamp_setup.ChannelNb:=14;
	do_ChargingLamp_setup.Enable.Forcing:=0; 
	do_ChargingLamp_setup.Levels.ForceValue:=0;
END_IF
IF (hmi_RestoreDefault_do[11] OR RestoreAllToDefault OR do_ChargingLamp_setup.RestoreDefault) THEN (*Copy values into HMI variable and reset*)
	hmi_DoSetup[11]:=do_ChargingLamp_setup; (*Copy setup values from retain into hmi variable*)
	hmi_RestoreDefault_do[11]:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
	do_ChargingLamp_setup.RestoreDefault:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
END_IF
IF (hmi_DoWriteSetup[11]) THEN
	do_ChargingLamp_setup:=hmi_DoSetup[11]; (*Paste hmi changes back into setup variable*)
	hmi_DoWriteSetup[11]:=FALSE; (*Make sure that the write variable is turned off after one write command*)
END_IF
F_Trig[11](CLK:=hmi_DoPV[11].IsForced); (*Reset HMI forcing dialog when timer runs out*)
IF (F_Trig[11].Q) THEN hmi_DoSetup[11].Enable.Forcing:=FALSE;do_ChargingLamp_setup.Enable.Forcing:=FALSE; END_IF
(**************************************************)



(**************do_ShutdownPlcFailure***********************)
IF (RestoreAllToDefault OR do_ShutdownPlcFailure_setup.RestoreDefault  OR hmi_RestoreDefault_do[12]) THEN
	do_ShutdownPlcFailure_setup.Name:='do_ShutdownPlcFailure'; 
	do_ShutdownPlcFailure_setup.CardNb:=PRG_HMI.setup_DioCard1_Number; 
	do_ShutdownPlcFailure_setup.ChannelMode:=2;
	do_ShutdownPlcFailure_setup.ChannelNb:=15;
	do_ShutdownPlcFailure_setup.Enable.Forcing:=0; 
	do_ShutdownPlcFailure_setup.Levels.ForceValue:=0;
END_IF
IF (hmi_RestoreDefault_do[12] OR RestoreAllToDefault OR do_ShutdownPlcFailure_setup.RestoreDefault) THEN (*Copy values into HMI variable and reset*)
	hmi_DoSetup[12]:=do_ShutdownPlcFailure_setup; (*Copy setup values from retain into hmi variable*)
	hmi_RestoreDefault_do[12]:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
	do_ShutdownPlcFailure_setup.RestoreDefault:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
END_IF
IF (hmi_DoWriteSetup[12]) THEN
	do_ShutdownPlcFailure_setup:=hmi_DoSetup[12]; (*Paste hmi changes back into setup variable*)
	hmi_DoWriteSetup[12]:=FALSE; (*Make sure that the write variable is turned off after one write command*)
END_IF
F_Trig[12](CLK:=hmi_DoPV[12].IsForced); (*Reset HMI forcing dialog when timer runs out*)
IF (F_Trig[12].Q) THEN hmi_DoSetup[12].Enable.Forcing:=FALSE;do_ShutdownPlcFailure_setup.Enable.Forcing:=FALSE; END_IF
(**************************************************)



(**************do_LocalLamp***********************)
IF (RestoreAllToDefault OR do_LocalLamp_setup.RestoreDefault  OR hmi_RestoreDefault_do[13]) THEN
	do_LocalLamp_setup.Name:='do_LocalLamp'; 
	do_LocalLamp_setup.CardNb:=PRG_HMI.setup_DioCard1_Number; 
	do_LocalLamp_setup.ChannelMode:=2;
	do_LocalLamp_setup.ChannelNb:=16;
	do_LocalLamp_setup.Enable.Forcing:=0; 
	do_LocalLamp_setup.Levels.ForceValue:=0;
END_IF
IF (hmi_RestoreDefault_do[13] OR RestoreAllToDefault OR do_LocalLamp_setup.RestoreDefault) THEN (*Copy values into HMI variable and reset*)
	hmi_DoSetup[13]:=do_LocalLamp_setup; (*Copy setup values from retain into hmi variable*)
	hmi_RestoreDefault_do[13]:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
	do_LocalLamp_setup.RestoreDefault:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
END_IF
IF (hmi_DoWriteSetup[13]) THEN
	do_LocalLamp_setup:=hmi_DoSetup[13]; (*Paste hmi changes back into setup variable*)
	hmi_DoWriteSetup[13]:=FALSE; (*Make sure that the write variable is turned off after one write command*)
END_IF
F_Trig[13](CLK:=hmi_DoPV[13].IsForced); (*Reset HMI forcing dialog when timer runs out*)
IF (F_Trig[13].Q) THEN hmi_DoSetup[13].Enable.Forcing:=FALSE;do_LocalLamp_setup.Enable.Forcing:=FALSE; END_IF
(**************************************************)






END_ACTION

END_ACTIONS