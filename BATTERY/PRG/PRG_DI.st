PROGRAM PRG_DI
VAR
	F_Trig : ARRAY[1..cnst_num_di] OF F_TRIG;
	i : INT;
	ManualFixChannels : BOOL; (*Will reset channels if faulty, i.e. card number is zero*)
	Reset: BOOL;
	Firstrun : BOOL;
	
	di_DcBreakerEarlyBreak_daemon: fb_DiProcess;
	di_LocalIncrease_daemon: fb_DiProcess;
	di_LocalDecrease_daemon: fb_DiProcess;
	di_LocalMode_daemon: fb_DiProcess;
	di_RemoteMode_daemon: fb_DiProcess;
	di_LocalStart_daemon: fb_DiProcess;
	di_LocalStop_daemon: fb_DiProcess;
	di_LocalReset_daemon: fb_DiProcess;
	di_LocalEmergencyStop_daemon: fb_DiProcess;
	di_FusesOK_daemon: fb_DiProcess;
	di_DcBreakerOpen_daemon: fb_DiProcess;
	di_DcBreakerClosed_daemon: fb_DiProcess;
	di_EthernetSwitchAlarm_daemon: fb_DiProcess;
	di_EmergencyStopLoopFault_daemon: fb_DiProcess;
	di_BatteryAuxOK_daemon: fb_DiProcess;
	di_BatteryAuxNotOK_daemon: fb_DiProcess;
	di_WaterLeakageDetected_daemon: fb_DiProcess;
	di_RemoteEmergencyStop_daemon: fb_DiProcess;
	di_SpareChannel32_daemon: fb_DiProcess;
	
	di_DcBreakerEarlyBreak: str_DiProcess;
	di_LocalIncrease: str_DiProcess;
	di_LocalDecrease: str_DiProcess;
	di_LocalMode: str_DiProcess;
	di_RemoteMode: str_DiProcess;
	di_LocalStart: str_DiProcess;
	di_LocalStop: str_DiProcess;
	di_LocalReset: str_DiProcess;
	di_LocalEmergencyStop: str_DiProcess;
	di_FusesOK: str_DiProcess;
	di_DcBreakerOpen: str_DiProcess;
	di_DcBreakerClosed: str_DiProcess;
	di_EthernetSwitchAlarm: str_DiProcess;
	di_EmergencyStopLoopFault: str_DiProcess;
	di_BatteryAuxOK: str_DiProcess;
	di_BatteryAuxNotOK: str_DiProcess;
	di_WaterLeakageDetected: str_DiProcess;
	di_RemoteEmergencyStop: str_DiProcess;
	di_SpareChannel32: str_DiProcess;
END_VAR

VAR RETAIN
	di_DcBreakerEarlyBreak_setup: str_DiSetup;
	di_LocalIncrease_setup: str_DiSetup;
	di_LocalDecrease_setup: str_DiSetup;
	di_LocalMode_setup: str_DiSetup;
	di_RemoteMode_setup: str_DiSetup;
	di_LocalStart_setup: str_DiSetup;
	di_LocalStop_setup: str_DiSetup;
	di_LocalReset_setup: str_DiSetup;
	di_LocalEmergencyStop_setup: str_DiSetup;
	di_FusesOK_setup: str_DiSetup;
	di_DcBreakerOpen_setup: str_DiSetup;
	di_DcBreakerClosed_setup: str_DiSetup;
	di_EthernetSwitchAlarm_setup: str_DiSetup;
	di_EmergencyStopLoopFault_setup: str_DiSetup;
	di_BatteryAuxOK_setup: str_DiSetup;
	di_BatteryAuxNotOK_setup: str_DiSetup;
	di_WaterLeakageDetected_setup: str_DiSetup;
	di_RemoteEmergencyStop_setup: str_DiSetup;
	di_SpareChannel32_setup: str_DiSetup;
END_VAR

Reset := PRG_Functions.Reset;

(*Setup the HMI variables so that they are equal to actual used variables*)
IF (NOT Firstrun) THEN
	hmi_DiSetup[1]:=di_DcBreakerEarlyBreak_setup;
	hmi_DiSetup[2]:=di_LocalIncrease_setup;
	hmi_DiSetup[3]:=di_LocalDecrease_setup;
	hmi_DiSetup[4]:=di_LocalMode_setup;
	hmi_DiSetup[5]:=di_RemoteMode_setup;
	hmi_DiSetup[6]:=di_LocalStart_setup;
	hmi_DiSetup[7]:=di_LocalStop_setup;
	hmi_DiSetup[8]:=di_LocalReset_setup;
	hmi_DiSetup[9]:=di_LocalEmergencyStop_setup;
	hmi_DiSetup[10]:=di_FusesOK_setup;
	hmi_DiSetup[11]:=di_DcBreakerOpen_setup;
	hmi_DiSetup[12]:=di_DcBreakerClosed_setup;
	hmi_DiSetup[13]:=di_EthernetSwitchAlarm_setup;
	hmi_DiSetup[14]:=di_EmergencyStopLoopFault_setup;
	hmi_DiSetup[15]:=di_BatteryAuxOK_setup;
	hmi_DiSetup[16]:=di_BatteryAuxNotOK_setup;
	hmi_DiSetup[17]:=di_WaterLeakageDetected_setup;
	hmi_DiSetup[18]:=di_RemoteEmergencyStop_setup;
	hmi_DiSetup[19]:=di_SpareChannel32_setup;
	Firstrun := TRUE;
END_IF

di_DcBreakerEarlyBreak_daemon (setup:=di_DcBreakerEarlyBreak_setup,outPV=>di_DcBreakerEarlyBreak);
di_LocalIncrease_daemon (setup:=di_LocalIncrease_setup,outPV=>di_LocalIncrease);
di_LocalDecrease_daemon (setup:=di_LocalDecrease_setup,outPV=>di_LocalDecrease);
di_LocalMode_daemon (setup:=di_LocalMode_setup,outPV=>di_LocalMode);
di_RemoteMode_daemon (setup:=di_RemoteMode_setup,outPV=>di_RemoteMode);
di_LocalStart_daemon (setup:=di_LocalStart_setup,outPV=>di_LocalStart);
di_LocalStop_daemon (setup:=di_LocalStop_setup,outPV=>di_LocalStop);
di_LocalReset_daemon (setup:=di_LocalReset_setup,outPV=>di_LocalReset);
di_LocalEmergencyStop_daemon (setup:=di_LocalEmergencyStop_setup,outPV=>di_LocalEmergencyStop);
di_FusesOK_daemon (setup:=di_FusesOK_setup,outPV=>di_FusesOK);
di_DcBreakerOpen_daemon (setup:=di_DcBreakerOpen_setup,outPV=>di_DcBreakerOpen);
di_DcBreakerClosed_daemon (setup:=di_DcBreakerClosed_setup,outPV=>di_DcBreakerClosed);
di_EthernetSwitchAlarm_daemon (setup:=di_EthernetSwitchAlarm_setup,outPV=>di_EthernetSwitchAlarm);
di_EmergencyStopLoopFault_daemon (setup:=di_EmergencyStopLoopFault_setup,outPV=>di_EmergencyStopLoopFault);
di_BatteryAuxOK_daemon (setup:=di_BatteryAuxOK_setup,outPV=>di_BatteryAuxOK);
di_BatteryAuxNotOK_daemon (setup:=di_BatteryAuxNotOK_setup,outPV=>di_BatteryAuxNotOK);
di_WaterLeakageDetected_daemon (setup:=di_WaterLeakageDetected_setup,outPV=>di_WaterLeakageDetected);
di_RemoteEmergencyStop_daemon (setup:=di_RemoteEmergencyStop_setup,outPV=>di_RemoteEmergencyStop);
di_SpareChannel32_daemon (setup:=di_SpareChannel32_setup,outPV=>di_SpareChannel32);


hmi_DiPV[1]:=di_DcBreakerEarlyBreak_daemon.outPV;
hmi_DiPV[2]:=di_LocalIncrease_daemon.outPV;
hmi_DiPV[3]:=di_LocalDecrease_daemon.outPV;
hmi_DiPV[4]:=di_LocalMode_daemon.outPV;
hmi_DiPV[5]:=di_RemoteMode_daemon.outPV;
hmi_DiPV[6]:=di_LocalStart_daemon.outPV;
hmi_DiPV[7]:=di_LocalStop_daemon.outPV;
hmi_DiPV[8]:=di_LocalReset_daemon.outPV;
hmi_DiPV[9]:=di_LocalEmergencyStop_daemon.outPV;
hmi_DiPV[10]:=di_FusesOK_daemon.outPV;
hmi_DiPV[11]:=di_DcBreakerOpen_daemon.outPV;
hmi_DiPV[12]:=di_DcBreakerClosed_daemon.outPV;
hmi_DiPV[13]:=di_EthernetSwitchAlarm_daemon.outPV;
hmi_DiPV[14]:=di_EmergencyStopLoopFault_daemon.outPV;
hmi_DiPV[15]:=di_BatteryAuxOK_daemon.outPV;
hmi_DiPV[16]:=di_BatteryAuxNotOK_daemon.outPV;
hmi_DiPV[17]:=di_WaterLeakageDetected_daemon.outPV;
hmi_DiPV[18]:=di_RemoteEmergencyStop_daemon.outPV;
hmi_DiPV[19]:=di_SpareChannel32_daemon.outPV;


IF (ManualFixChannels) THEN  (*If manually forced: re-configure the channels*)
	FOR i:=1 TO cnst_num_di BY 1 DO			(*Check if channel info is empty and restore if so.*)
		IF (hmi_DiSetup[i].CardNb = 0 AND PRG_HMI.setup_DioCard1_Number <> 0) THEN
			hmi_RestoreDefault_di[i] := TRUE;
		END_IF
	END_FOR;
	ManualFixChannels := FALSE;
END_IF

END_PROGRAM

ACTIONS

ACTION Settings

(**************di_DcBreakerEarlyBreak***********************)
IF (RestoreAllToDefault OR di_DcBreakerEarlyBreak_setup.RestoreDefault  OR hmi_RestoreDefault_di[1]) THEN
	di_DcBreakerEarlyBreak_setup.Name:='di_DcBreakerEarlyBreak'; 
	di_DcBreakerEarlyBreak_setup.CardNb:=PRG_HMI.setup_DioCard1_Number; 
	di_DcBreakerEarlyBreak_setup.ChannelMode:=1;
	di_DcBreakerEarlyBreak_setup.ChannelNb:=7;
 	di_DcBreakerEarlyBreak_setup.Delay.TOF:=T#0ms; 
	di_DcBreakerEarlyBreak_setup.Delay.TON:=T#0ms; 
	di_DcBreakerEarlyBreak_setup.Enable.Forcing:=0; 
	di_DcBreakerEarlyBreak_setup.Enable.TON:=0; 
	di_DcBreakerEarlyBreak_setup.Enable.TOF:=0; 
	di_DcBreakerEarlyBreak_setup.Levels.ForceValue:=0;
END_IF
IF (hmi_RestoreDefault_di[1] OR RestoreAllToDefault OR di_DcBreakerEarlyBreak_setup.RestoreDefault) THEN (*Copy values into HMI variable and reset*)
	hmi_DiSetup[1]:=di_DcBreakerEarlyBreak_setup; (*Copy setup values from retain into hmi variable*)
	hmi_RestoreDefault_di[1]:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
	di_DcBreakerEarlyBreak_setup.RestoreDefault:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
END_IF
IF (hmi_DiWriteSetup[1]) THEN
	di_DcBreakerEarlyBreak_setup:=hmi_DiSetup[1]; (*Paste hmi changes back into setup variable*)
	hmi_DiWriteSetup[1]:=FALSE; (*Make sure that the write variable is turned off after one write command*)
END_IF
F_Trig[1](CLK:=hmi_DiPV[1].IsForced); (*Reset HMI forcing dialog when timer runs out*)
IF (F_Trig[1].Q) THEN hmi_DiSetup[1].Enable.Forcing:=FALSE;di_DcBreakerEarlyBreak_setup.Enable.Forcing:=FALSE; END_IF
(**************************************************)



(**************di_LocalIncrease***********************)
IF (RestoreAllToDefault OR di_LocalIncrease_setup.RestoreDefault  OR hmi_RestoreDefault_di[2]) THEN
	di_LocalIncrease_setup.Name:='di_LocalIncrease'; 
	di_LocalIncrease_setup.CardNb:=PRG_HMI.setup_DioCard1_Number; 
	di_LocalIncrease_setup.ChannelMode:=1;
	di_LocalIncrease_setup.ChannelNb:=8;
 	di_LocalIncrease_setup.Delay.TOF:=T#0ms; 
	di_LocalIncrease_setup.Delay.TON:=T#0ms; 
	di_LocalIncrease_setup.Enable.Forcing:=0; 
	di_LocalIncrease_setup.Enable.TON:=0; 
	di_LocalIncrease_setup.Enable.TOF:=0; 
	di_LocalIncrease_setup.Levels.ForceValue:=0;
END_IF
IF (hmi_RestoreDefault_di[2] OR RestoreAllToDefault OR di_LocalIncrease_setup.RestoreDefault) THEN (*Copy values into HMI variable and reset*)
	hmi_DiSetup[2]:=di_LocalIncrease_setup; (*Copy setup values from retain into hmi variable*)
	hmi_RestoreDefault_di[2]:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
	di_LocalIncrease_setup.RestoreDefault:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
END_IF
IF (hmi_DiWriteSetup[2]) THEN
	di_LocalIncrease_setup:=hmi_DiSetup[2]; (*Paste hmi changes back into setup variable*)
	hmi_DiWriteSetup[2]:=FALSE; (*Make sure that the write variable is turned off after one write command*)
END_IF
F_Trig[2](CLK:=hmi_DiPV[2].IsForced); (*Reset HMI forcing dialog when timer runs out*)
IF (F_Trig[2].Q) THEN hmi_DiSetup[2].Enable.Forcing:=FALSE;di_LocalIncrease_setup.Enable.Forcing:=FALSE; END_IF
(**************************************************)



(**************di_LocalDecrease***********************)
IF (RestoreAllToDefault OR di_LocalDecrease_setup.RestoreDefault  OR hmi_RestoreDefault_di[3]) THEN
	di_LocalDecrease_setup.Name:='di_LocalDecrease'; 
	di_LocalDecrease_setup.CardNb:=PRG_HMI.setup_DioCard1_Number; 
	di_LocalDecrease_setup.ChannelMode:=1;
	di_LocalDecrease_setup.ChannelNb:=9;
 	di_LocalDecrease_setup.Delay.TOF:=T#0ms; 
	di_LocalDecrease_setup.Delay.TON:=T#0ms; 
	di_LocalDecrease_setup.Enable.Forcing:=0; 
	di_LocalDecrease_setup.Enable.TON:=0; 
	di_LocalDecrease_setup.Enable.TOF:=0; 
	di_LocalDecrease_setup.Levels.ForceValue:=0;
END_IF
IF (hmi_RestoreDefault_di[3] OR RestoreAllToDefault OR di_LocalDecrease_setup.RestoreDefault) THEN (*Copy values into HMI variable and reset*)
	hmi_DiSetup[3]:=di_LocalDecrease_setup; (*Copy setup values from retain into hmi variable*)
	hmi_RestoreDefault_di[3]:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
	di_LocalDecrease_setup.RestoreDefault:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
END_IF
IF (hmi_DiWriteSetup[3]) THEN
	di_LocalDecrease_setup:=hmi_DiSetup[3]; (*Paste hmi changes back into setup variable*)
	hmi_DiWriteSetup[3]:=FALSE; (*Make sure that the write variable is turned off after one write command*)
END_IF
F_Trig[3](CLK:=hmi_DiPV[3].IsForced); (*Reset HMI forcing dialog when timer runs out*)
IF (F_Trig[3].Q) THEN hmi_DiSetup[3].Enable.Forcing:=FALSE;di_LocalDecrease_setup.Enable.Forcing:=FALSE; END_IF
(**************************************************)



(**************di_LocalMode***********************)
IF (RestoreAllToDefault OR di_LocalMode_setup.RestoreDefault  OR hmi_RestoreDefault_di[4]) THEN
	di_LocalMode_setup.Name:='di_LocalMode'; 
	di_LocalMode_setup.CardNb:=PRG_HMI.setup_DioCard1_Number; 
	di_LocalMode_setup.ChannelMode:=1;
	di_LocalMode_setup.ChannelNb:=17;
 	di_LocalMode_setup.Delay.TOF:=T#0ms; 
	di_LocalMode_setup.Delay.TON:=T#0ms; 
	di_LocalMode_setup.Enable.Forcing:=0; 
	di_LocalMode_setup.Enable.TON:=0; 
	di_LocalMode_setup.Enable.TOF:=0; 
	di_LocalMode_setup.Levels.ForceValue:=0;
END_IF
IF (hmi_RestoreDefault_di[4] OR RestoreAllToDefault OR di_LocalMode_setup.RestoreDefault) THEN (*Copy values into HMI variable and reset*)
	hmi_DiSetup[4]:=di_LocalMode_setup; (*Copy setup values from retain into hmi variable*)
	hmi_RestoreDefault_di[4]:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
	di_LocalMode_setup.RestoreDefault:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
END_IF
IF (hmi_DiWriteSetup[4]) THEN
	di_LocalMode_setup:=hmi_DiSetup[4]; (*Paste hmi changes back into setup variable*)
	hmi_DiWriteSetup[4]:=FALSE; (*Make sure that the write variable is turned off after one write command*)
END_IF
F_Trig[4](CLK:=hmi_DiPV[4].IsForced); (*Reset HMI forcing dialog when timer runs out*)
IF (F_Trig[4].Q) THEN hmi_DiSetup[4].Enable.Forcing:=FALSE;di_LocalMode_setup.Enable.Forcing:=FALSE; END_IF
(**************************************************)



(**************di_RemoteMode***********************)
IF (RestoreAllToDefault OR di_RemoteMode_setup.RestoreDefault  OR hmi_RestoreDefault_di[5]) THEN
	di_RemoteMode_setup.Name:='di_RemoteMode'; 
	di_RemoteMode_setup.CardNb:=PRG_HMI.setup_DioCard1_Number; 
	di_RemoteMode_setup.ChannelMode:=1;
	di_RemoteMode_setup.ChannelNb:=18;
 	di_RemoteMode_setup.Delay.TOF:=T#0ms; 
	di_RemoteMode_setup.Delay.TON:=T#0ms; 
	di_RemoteMode_setup.Enable.Forcing:=0; 
	di_RemoteMode_setup.Enable.TON:=0; 
	di_RemoteMode_setup.Enable.TOF:=0; 
	di_RemoteMode_setup.Levels.ForceValue:=0;
END_IF
IF (hmi_RestoreDefault_di[5] OR RestoreAllToDefault OR di_RemoteMode_setup.RestoreDefault) THEN (*Copy values into HMI variable and reset*)
	hmi_DiSetup[5]:=di_RemoteMode_setup; (*Copy setup values from retain into hmi variable*)
	hmi_RestoreDefault_di[5]:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
	di_RemoteMode_setup.RestoreDefault:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
END_IF
IF (hmi_DiWriteSetup[5]) THEN
	di_RemoteMode_setup:=hmi_DiSetup[5]; (*Paste hmi changes back into setup variable*)
	hmi_DiWriteSetup[5]:=FALSE; (*Make sure that the write variable is turned off after one write command*)
END_IF
F_Trig[5](CLK:=hmi_DiPV[5].IsForced); (*Reset HMI forcing dialog when timer runs out*)
IF (F_Trig[5].Q) THEN hmi_DiSetup[5].Enable.Forcing:=FALSE;di_RemoteMode_setup.Enable.Forcing:=FALSE; END_IF
(**************************************************)



(**************di_LocalStart***********************)
IF (RestoreAllToDefault OR di_LocalStart_setup.RestoreDefault  OR hmi_RestoreDefault_di[6]) THEN
	di_LocalStart_setup.Name:='di_LocalStart'; 
	di_LocalStart_setup.CardNb:=PRG_HMI.setup_DioCard1_Number; 
	di_LocalStart_setup.ChannelMode:=1;
	di_LocalStart_setup.ChannelNb:=19;
 	di_LocalStart_setup.Delay.TOF:=T#0ms; 
	di_LocalStart_setup.Delay.TON:=T#0ms; 
	di_LocalStart_setup.Enable.Forcing:=0; 
	di_LocalStart_setup.Enable.TON:=0; 
	di_LocalStart_setup.Enable.TOF:=0; 
	di_LocalStart_setup.Levels.ForceValue:=0;
END_IF
IF (hmi_RestoreDefault_di[6] OR RestoreAllToDefault OR di_LocalStart_setup.RestoreDefault) THEN (*Copy values into HMI variable and reset*)
	hmi_DiSetup[6]:=di_LocalStart_setup; (*Copy setup values from retain into hmi variable*)
	hmi_RestoreDefault_di[6]:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
	di_LocalStart_setup.RestoreDefault:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
END_IF
IF (hmi_DiWriteSetup[6]) THEN
	di_LocalStart_setup:=hmi_DiSetup[6]; (*Paste hmi changes back into setup variable*)
	hmi_DiWriteSetup[6]:=FALSE; (*Make sure that the write variable is turned off after one write command*)
END_IF
F_Trig[6](CLK:=hmi_DiPV[6].IsForced); (*Reset HMI forcing dialog when timer runs out*)
IF (F_Trig[6].Q) THEN hmi_DiSetup[6].Enable.Forcing:=FALSE;di_LocalStart_setup.Enable.Forcing:=FALSE; END_IF
(**************************************************)



(**************di_LocalStop***********************)
IF (RestoreAllToDefault OR di_LocalStop_setup.RestoreDefault  OR hmi_RestoreDefault_di[7]) THEN
	di_LocalStop_setup.Name:='di_LocalStop'; 
	di_LocalStop_setup.CardNb:=PRG_HMI.setup_DioCard1_Number; 
	di_LocalStop_setup.ChannelMode:=1;
	di_LocalStop_setup.ChannelNb:=20;
 	di_LocalStop_setup.Delay.TOF:=T#0ms; 
	di_LocalStop_setup.Delay.TON:=T#0ms; 
	di_LocalStop_setup.Enable.Forcing:=0; 
	di_LocalStop_setup.Enable.TON:=0; 
	di_LocalStop_setup.Enable.TOF:=0; 
	di_LocalStop_setup.Levels.ForceValue:=0;
END_IF
IF (hmi_RestoreDefault_di[7] OR RestoreAllToDefault OR di_LocalStop_setup.RestoreDefault) THEN (*Copy values into HMI variable and reset*)
	hmi_DiSetup[7]:=di_LocalStop_setup; (*Copy setup values from retain into hmi variable*)
	hmi_RestoreDefault_di[7]:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
	di_LocalStop_setup.RestoreDefault:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
END_IF
IF (hmi_DiWriteSetup[7]) THEN
	di_LocalStop_setup:=hmi_DiSetup[7]; (*Paste hmi changes back into setup variable*)
	hmi_DiWriteSetup[7]:=FALSE; (*Make sure that the write variable is turned off after one write command*)
END_IF
F_Trig[7](CLK:=hmi_DiPV[7].IsForced); (*Reset HMI forcing dialog when timer runs out*)
IF (F_Trig[7].Q) THEN hmi_DiSetup[7].Enable.Forcing:=FALSE;di_LocalStop_setup.Enable.Forcing:=FALSE; END_IF
(**************************************************)



(**************di_LocalReset***********************)
IF (RestoreAllToDefault OR di_LocalReset_setup.RestoreDefault  OR hmi_RestoreDefault_di[8]) THEN
	di_LocalReset_setup.Name:='di_LocalReset'; 
	di_LocalReset_setup.CardNb:=PRG_HMI.setup_DioCard1_Number; 
	di_LocalReset_setup.ChannelMode:=1;
	di_LocalReset_setup.ChannelNb:=21;
 	di_LocalReset_setup.Delay.TOF:=T#0ms; 
	di_LocalReset_setup.Delay.TON:=T#0ms; 
	di_LocalReset_setup.Enable.Forcing:=0; 
	di_LocalReset_setup.Enable.TON:=0; 
	di_LocalReset_setup.Enable.TOF:=0; 
	di_LocalReset_setup.Levels.ForceValue:=0;
END_IF
IF (hmi_RestoreDefault_di[8] OR RestoreAllToDefault OR di_LocalReset_setup.RestoreDefault) THEN (*Copy values into HMI variable and reset*)
	hmi_DiSetup[8]:=di_LocalReset_setup; (*Copy setup values from retain into hmi variable*)
	hmi_RestoreDefault_di[8]:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
	di_LocalReset_setup.RestoreDefault:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
END_IF
IF (hmi_DiWriteSetup[8]) THEN
	di_LocalReset_setup:=hmi_DiSetup[8]; (*Paste hmi changes back into setup variable*)
	hmi_DiWriteSetup[8]:=FALSE; (*Make sure that the write variable is turned off after one write command*)
END_IF
F_Trig[8](CLK:=hmi_DiPV[8].IsForced); (*Reset HMI forcing dialog when timer runs out*)
IF (F_Trig[8].Q) THEN hmi_DiSetup[8].Enable.Forcing:=FALSE;di_LocalReset_setup.Enable.Forcing:=FALSE; END_IF
(**************************************************)



(**************di_LocalEmergencyStop***********************)
IF (RestoreAllToDefault OR di_LocalEmergencyStop_setup.RestoreDefault  OR hmi_RestoreDefault_di[9]) THEN
	di_LocalEmergencyStop_setup.Name:='di_LocalEmergencyStop'; 
	di_LocalEmergencyStop_setup.CardNb:=PRG_HMI.setup_DioCard1_Number; 
	di_LocalEmergencyStop_setup.ChannelMode:=1;
	di_LocalEmergencyStop_setup.ChannelNb:=22;
 	di_LocalEmergencyStop_setup.Delay.TOF:=T#0ms; 
	di_LocalEmergencyStop_setup.Delay.TON:=T#0ms; 
	di_LocalEmergencyStop_setup.Enable.Forcing:=0; 
	di_LocalEmergencyStop_setup.Enable.TON:=0; 
	di_LocalEmergencyStop_setup.Enable.TOF:=0; 
	di_LocalEmergencyStop_setup.Levels.ForceValue:=0;
END_IF
IF (hmi_RestoreDefault_di[9] OR RestoreAllToDefault OR di_LocalEmergencyStop_setup.RestoreDefault) THEN (*Copy values into HMI variable and reset*)
	hmi_DiSetup[9]:=di_LocalEmergencyStop_setup; (*Copy setup values from retain into hmi variable*)
	hmi_RestoreDefault_di[9]:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
	di_LocalEmergencyStop_setup.RestoreDefault:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
END_IF
IF (hmi_DiWriteSetup[9]) THEN
	di_LocalEmergencyStop_setup:=hmi_DiSetup[9]; (*Paste hmi changes back into setup variable*)
	hmi_DiWriteSetup[9]:=FALSE; (*Make sure that the write variable is turned off after one write command*)
END_IF
F_Trig[9](CLK:=hmi_DiPV[9].IsForced); (*Reset HMI forcing dialog when timer runs out*)
IF (F_Trig[9].Q) THEN hmi_DiSetup[9].Enable.Forcing:=FALSE;di_LocalEmergencyStop_setup.Enable.Forcing:=FALSE; END_IF
(**************************************************)



(**************di_FusesOK***********************)
IF (RestoreAllToDefault OR di_FusesOK_setup.RestoreDefault  OR hmi_RestoreDefault_di[10]) THEN
	di_FusesOK_setup.Name:='di_FusesOK'; 
	di_FusesOK_setup.CardNb:=PRG_HMI.setup_DioCard1_Number; 
	di_FusesOK_setup.ChannelMode:=1;
	di_FusesOK_setup.ChannelNb:=23;
 	di_FusesOK_setup.Delay.TOF:=T#0ms; 
	di_FusesOK_setup.Delay.TON:=T#0ms; 
	di_FusesOK_setup.Enable.Forcing:=0; 
	di_FusesOK_setup.Enable.TON:=0; 
	di_FusesOK_setup.Enable.TOF:=0; 
	di_FusesOK_setup.Levels.ForceValue:=0;
END_IF
IF (hmi_RestoreDefault_di[10] OR RestoreAllToDefault OR di_FusesOK_setup.RestoreDefault) THEN (*Copy values into HMI variable and reset*)
	hmi_DiSetup[10]:=di_FusesOK_setup; (*Copy setup values from retain into hmi variable*)
	hmi_RestoreDefault_di[10]:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
	di_FusesOK_setup.RestoreDefault:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
END_IF
IF (hmi_DiWriteSetup[10]) THEN
	di_FusesOK_setup:=hmi_DiSetup[10]; (*Paste hmi changes back into setup variable*)
	hmi_DiWriteSetup[10]:=FALSE; (*Make sure that the write variable is turned off after one write command*)
END_IF
F_Trig[10](CLK:=hmi_DiPV[10].IsForced); (*Reset HMI forcing dialog when timer runs out*)
IF (F_Trig[10].Q) THEN hmi_DiSetup[10].Enable.Forcing:=FALSE;di_FusesOK_setup.Enable.Forcing:=FALSE; END_IF
(**************************************************)



(**************di_DcBreakerOpen***********************)
IF (RestoreAllToDefault OR di_DcBreakerOpen_setup.RestoreDefault  OR hmi_RestoreDefault_di[11]) THEN
	di_DcBreakerOpen_setup.Name:='di_DcBreakerOpen'; 
	di_DcBreakerOpen_setup.CardNb:=PRG_HMI.setup_DioCard1_Number; 
	di_DcBreakerOpen_setup.ChannelMode:=1;
	di_DcBreakerOpen_setup.ChannelNb:=24;
 	di_DcBreakerOpen_setup.Delay.TOF:=T#0ms; 
	di_DcBreakerOpen_setup.Delay.TON:=T#0ms; 
	di_DcBreakerOpen_setup.Enable.Forcing:=0; 
	di_DcBreakerOpen_setup.Enable.TON:=0; 
	di_DcBreakerOpen_setup.Enable.TOF:=0; 
	di_DcBreakerOpen_setup.Levels.ForceValue:=0;
END_IF
IF (hmi_RestoreDefault_di[11] OR RestoreAllToDefault OR di_DcBreakerOpen_setup.RestoreDefault) THEN (*Copy values into HMI variable and reset*)
	hmi_DiSetup[11]:=di_DcBreakerOpen_setup; (*Copy setup values from retain into hmi variable*)
	hmi_RestoreDefault_di[11]:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
	di_DcBreakerOpen_setup.RestoreDefault:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
END_IF
IF (hmi_DiWriteSetup[11]) THEN
	di_DcBreakerOpen_setup:=hmi_DiSetup[11]; (*Paste hmi changes back into setup variable*)
	hmi_DiWriteSetup[11]:=FALSE; (*Make sure that the write variable is turned off after one write command*)
END_IF
F_Trig[11](CLK:=hmi_DiPV[11].IsForced); (*Reset HMI forcing dialog when timer runs out*)
IF (F_Trig[11].Q) THEN hmi_DiSetup[11].Enable.Forcing:=FALSE;di_DcBreakerOpen_setup.Enable.Forcing:=FALSE; END_IF
(**************************************************)



(**************di_DcBreakerClosed***********************)
IF (RestoreAllToDefault OR di_DcBreakerClosed_setup.RestoreDefault  OR hmi_RestoreDefault_di[12]) THEN
	di_DcBreakerClosed_setup.Name:='di_DcBreakerClosed'; 
	di_DcBreakerClosed_setup.CardNb:=PRG_HMI.setup_DioCard1_Number; 
	di_DcBreakerClosed_setup.ChannelMode:=1;
	di_DcBreakerClosed_setup.ChannelNb:=25;
 	di_DcBreakerClosed_setup.Delay.TOF:=T#0ms; 
	di_DcBreakerClosed_setup.Delay.TON:=T#0ms; 
	di_DcBreakerClosed_setup.Enable.Forcing:=0; 
	di_DcBreakerClosed_setup.Enable.TON:=0; 
	di_DcBreakerClosed_setup.Enable.TOF:=0; 
	di_DcBreakerClosed_setup.Levels.ForceValue:=0;
END_IF
IF (hmi_RestoreDefault_di[12] OR RestoreAllToDefault OR di_DcBreakerClosed_setup.RestoreDefault) THEN (*Copy values into HMI variable and reset*)
	hmi_DiSetup[12]:=di_DcBreakerClosed_setup; (*Copy setup values from retain into hmi variable*)
	hmi_RestoreDefault_di[12]:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
	di_DcBreakerClosed_setup.RestoreDefault:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
END_IF
IF (hmi_DiWriteSetup[12]) THEN
	di_DcBreakerClosed_setup:=hmi_DiSetup[12]; (*Paste hmi changes back into setup variable*)
	hmi_DiWriteSetup[12]:=FALSE; (*Make sure that the write variable is turned off after one write command*)
END_IF
F_Trig[12](CLK:=hmi_DiPV[12].IsForced); (*Reset HMI forcing dialog when timer runs out*)
IF (F_Trig[12].Q) THEN hmi_DiSetup[12].Enable.Forcing:=FALSE;di_DcBreakerClosed_setup.Enable.Forcing:=FALSE; END_IF
(**************************************************)



(**************di_EthernetSwitchAlarm***********************)
IF (RestoreAllToDefault OR di_EthernetSwitchAlarm_setup.RestoreDefault  OR hmi_RestoreDefault_di[13]) THEN
	di_EthernetSwitchAlarm_setup.Name:='di_EthernetSwitchAlarm'; 
	di_EthernetSwitchAlarm_setup.CardNb:=PRG_HMI.setup_DioCard1_Number; 
	di_EthernetSwitchAlarm_setup.ChannelMode:=1;
	di_EthernetSwitchAlarm_setup.ChannelNb:=26;
 	di_EthernetSwitchAlarm_setup.Delay.TOF:=T#0ms; 
	di_EthernetSwitchAlarm_setup.Delay.TON:=T#0ms; 
	di_EthernetSwitchAlarm_setup.Enable.Forcing:=0; 
	di_EthernetSwitchAlarm_setup.Enable.TON:=0; 
	di_EthernetSwitchAlarm_setup.Enable.TOF:=0; 
	di_EthernetSwitchAlarm_setup.Levels.ForceValue:=0;
END_IF
IF (hmi_RestoreDefault_di[13] OR RestoreAllToDefault OR di_EthernetSwitchAlarm_setup.RestoreDefault) THEN (*Copy values into HMI variable and reset*)
	hmi_DiSetup[13]:=di_EthernetSwitchAlarm_setup; (*Copy setup values from retain into hmi variable*)
	hmi_RestoreDefault_di[13]:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
	di_EthernetSwitchAlarm_setup.RestoreDefault:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
END_IF
IF (hmi_DiWriteSetup[13]) THEN
	di_EthernetSwitchAlarm_setup:=hmi_DiSetup[13]; (*Paste hmi changes back into setup variable*)
	hmi_DiWriteSetup[13]:=FALSE; (*Make sure that the write variable is turned off after one write command*)
END_IF
F_Trig[13](CLK:=hmi_DiPV[13].IsForced); (*Reset HMI forcing dialog when timer runs out*)
IF (F_Trig[13].Q) THEN hmi_DiSetup[13].Enable.Forcing:=FALSE;di_EthernetSwitchAlarm_setup.Enable.Forcing:=FALSE; END_IF
(**************************************************)



(**************di_EmergencyStopLoopFault***********************)
IF (RestoreAllToDefault OR di_EmergencyStopLoopFault_setup.RestoreDefault  OR hmi_RestoreDefault_di[14]) THEN
	di_EmergencyStopLoopFault_setup.Name:='di_EmergencyStopLoopFault'; 
	di_EmergencyStopLoopFault_setup.CardNb:=PRG_HMI.setup_DioCard1_Number; 
	di_EmergencyStopLoopFault_setup.ChannelMode:=1;
	di_EmergencyStopLoopFault_setup.ChannelNb:=27;
 	di_EmergencyStopLoopFault_setup.Delay.TOF:=T#0ms; 
	di_EmergencyStopLoopFault_setup.Delay.TON:=T#0ms; 
	di_EmergencyStopLoopFault_setup.Enable.Forcing:=0; 
	di_EmergencyStopLoopFault_setup.Enable.TON:=0; 
	di_EmergencyStopLoopFault_setup.Enable.TOF:=0; 
	di_EmergencyStopLoopFault_setup.Levels.ForceValue:=0;
END_IF
IF (hmi_RestoreDefault_di[14] OR RestoreAllToDefault OR di_EmergencyStopLoopFault_setup.RestoreDefault) THEN (*Copy values into HMI variable and reset*)
	hmi_DiSetup[14]:=di_EmergencyStopLoopFault_setup; (*Copy setup values from retain into hmi variable*)
	hmi_RestoreDefault_di[14]:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
	di_EmergencyStopLoopFault_setup.RestoreDefault:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
END_IF
IF (hmi_DiWriteSetup[14]) THEN
	di_EmergencyStopLoopFault_setup:=hmi_DiSetup[14]; (*Paste hmi changes back into setup variable*)
	hmi_DiWriteSetup[14]:=FALSE; (*Make sure that the write variable is turned off after one write command*)
END_IF
F_Trig[14](CLK:=hmi_DiPV[14].IsForced); (*Reset HMI forcing dialog when timer runs out*)
IF (F_Trig[14].Q) THEN hmi_DiSetup[14].Enable.Forcing:=FALSE;di_EmergencyStopLoopFault_setup.Enable.Forcing:=FALSE; END_IF
(**************************************************)



(**************di_BatteryAuxOK***********************)
IF (RestoreAllToDefault OR di_BatteryAuxOK_setup.RestoreDefault  OR hmi_RestoreDefault_di[15]) THEN
	di_BatteryAuxOK_setup.Name:='di_BatteryAuxOK'; 
	di_BatteryAuxOK_setup.CardNb:=PRG_HMI.setup_DioCard1_Number; 
	di_BatteryAuxOK_setup.ChannelMode:=1;
	di_BatteryAuxOK_setup.ChannelNb:=28;
 	di_BatteryAuxOK_setup.Delay.TOF:=T#0ms; 
	di_BatteryAuxOK_setup.Delay.TON:=T#0ms; 
	di_BatteryAuxOK_setup.Enable.Forcing:=0; 
	di_BatteryAuxOK_setup.Enable.TON:=0; 
	di_BatteryAuxOK_setup.Enable.TOF:=0; 
	di_BatteryAuxOK_setup.Levels.ForceValue:=0;
END_IF
IF (hmi_RestoreDefault_di[15] OR RestoreAllToDefault OR di_BatteryAuxOK_setup.RestoreDefault) THEN (*Copy values into HMI variable and reset*)
	hmi_DiSetup[15]:=di_BatteryAuxOK_setup; (*Copy setup values from retain into hmi variable*)
	hmi_RestoreDefault_di[15]:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
	di_BatteryAuxOK_setup.RestoreDefault:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
END_IF
IF (hmi_DiWriteSetup[15]) THEN
	di_BatteryAuxOK_setup:=hmi_DiSetup[15]; (*Paste hmi changes back into setup variable*)
	hmi_DiWriteSetup[15]:=FALSE; (*Make sure that the write variable is turned off after one write command*)
END_IF
F_Trig[15](CLK:=hmi_DiPV[15].IsForced); (*Reset HMI forcing dialog when timer runs out*)
IF (F_Trig[15].Q) THEN hmi_DiSetup[15].Enable.Forcing:=FALSE;di_BatteryAuxOK_setup.Enable.Forcing:=FALSE; END_IF
(**************************************************)



(**************di_BatteryAuxNotOK***********************)
IF (RestoreAllToDefault OR di_BatteryAuxNotOK_setup.RestoreDefault  OR hmi_RestoreDefault_di[16]) THEN
	di_BatteryAuxNotOK_setup.Name:='di_BatteryAuxNotOK'; 
	di_BatteryAuxNotOK_setup.CardNb:=PRG_HMI.setup_DioCard1_Number; 
	di_BatteryAuxNotOK_setup.ChannelMode:=1;
	di_BatteryAuxNotOK_setup.ChannelNb:=29;
 	di_BatteryAuxNotOK_setup.Delay.TOF:=T#0ms; 
	di_BatteryAuxNotOK_setup.Delay.TON:=T#0ms; 
	di_BatteryAuxNotOK_setup.Enable.Forcing:=0; 
	di_BatteryAuxNotOK_setup.Enable.TON:=0; 
	di_BatteryAuxNotOK_setup.Enable.TOF:=0; 
	di_BatteryAuxNotOK_setup.Levels.ForceValue:=0;
END_IF
IF (hmi_RestoreDefault_di[16] OR RestoreAllToDefault OR di_BatteryAuxNotOK_setup.RestoreDefault) THEN (*Copy values into HMI variable and reset*)
	hmi_DiSetup[16]:=di_BatteryAuxNotOK_setup; (*Copy setup values from retain into hmi variable*)
	hmi_RestoreDefault_di[16]:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
	di_BatteryAuxNotOK_setup.RestoreDefault:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
END_IF
IF (hmi_DiWriteSetup[16]) THEN
	di_BatteryAuxNotOK_setup:=hmi_DiSetup[16]; (*Paste hmi changes back into setup variable*)
	hmi_DiWriteSetup[16]:=FALSE; (*Make sure that the write variable is turned off after one write command*)
END_IF
F_Trig[16](CLK:=hmi_DiPV[16].IsForced); (*Reset HMI forcing dialog when timer runs out*)
IF (F_Trig[16].Q) THEN hmi_DiSetup[16].Enable.Forcing:=FALSE;di_BatteryAuxNotOK_setup.Enable.Forcing:=FALSE; END_IF
(**************************************************)



(**************di_WaterLeakageDetected***********************)
IF (RestoreAllToDefault OR di_WaterLeakageDetected_setup.RestoreDefault  OR hmi_RestoreDefault_di[17]) THEN
	di_WaterLeakageDetected_setup.Name:='di_WaterLeakageDetected'; 
	di_WaterLeakageDetected_setup.CardNb:=PRG_HMI.setup_DioCard1_Number; 
	di_WaterLeakageDetected_setup.ChannelMode:=1;
	di_WaterLeakageDetected_setup.ChannelNb:=30;
 	di_WaterLeakageDetected_setup.Delay.TOF:=T#0ms; 
	di_WaterLeakageDetected_setup.Delay.TON:=T#0ms; 
	di_WaterLeakageDetected_setup.Enable.Forcing:=0; 
	di_WaterLeakageDetected_setup.Enable.TON:=0; 
	di_WaterLeakageDetected_setup.Enable.TOF:=0; 
	di_WaterLeakageDetected_setup.Levels.ForceValue:=0;
END_IF
IF (hmi_RestoreDefault_di[17] OR RestoreAllToDefault OR di_WaterLeakageDetected_setup.RestoreDefault) THEN (*Copy values into HMI variable and reset*)
	hmi_DiSetup[17]:=di_WaterLeakageDetected_setup; (*Copy setup values from retain into hmi variable*)
	hmi_RestoreDefault_di[17]:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
	di_WaterLeakageDetected_setup.RestoreDefault:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
END_IF
IF (hmi_DiWriteSetup[17]) THEN
	di_WaterLeakageDetected_setup:=hmi_DiSetup[17]; (*Paste hmi changes back into setup variable*)
	hmi_DiWriteSetup[17]:=FALSE; (*Make sure that the write variable is turned off after one write command*)
END_IF
F_Trig[17](CLK:=hmi_DiPV[17].IsForced); (*Reset HMI forcing dialog when timer runs out*)
IF (F_Trig[17].Q) THEN hmi_DiSetup[17].Enable.Forcing:=FALSE;di_WaterLeakageDetected_setup.Enable.Forcing:=FALSE; END_IF
(**************************************************)



(**************di_RemoteEmergencyStop***********************)
IF (RestoreAllToDefault OR di_RemoteEmergencyStop_setup.RestoreDefault  OR hmi_RestoreDefault_di[18]) THEN
	di_RemoteEmergencyStop_setup.Name:='di_RemoteEmergencyStop'; 
	di_RemoteEmergencyStop_setup.CardNb:=PRG_HMI.setup_DioCard1_Number; 
	di_RemoteEmergencyStop_setup.ChannelMode:=1;
	di_RemoteEmergencyStop_setup.ChannelNb:=31;
 	di_RemoteEmergencyStop_setup.Delay.TOF:=T#0ms; 
	di_RemoteEmergencyStop_setup.Delay.TON:=T#0ms; 
	di_RemoteEmergencyStop_setup.Enable.Forcing:=0; 
	di_RemoteEmergencyStop_setup.Enable.TON:=0; 
	di_RemoteEmergencyStop_setup.Enable.TOF:=0; 
	di_RemoteEmergencyStop_setup.Levels.ForceValue:=0;
END_IF
IF (hmi_RestoreDefault_di[18] OR RestoreAllToDefault OR di_RemoteEmergencyStop_setup.RestoreDefault) THEN (*Copy values into HMI variable and reset*)
	hmi_DiSetup[18]:=di_RemoteEmergencyStop_setup; (*Copy setup values from retain into hmi variable*)
	hmi_RestoreDefault_di[18]:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
	di_RemoteEmergencyStop_setup.RestoreDefault:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
END_IF
IF (hmi_DiWriteSetup[18]) THEN
	di_RemoteEmergencyStop_setup:=hmi_DiSetup[18]; (*Paste hmi changes back into setup variable*)
	hmi_DiWriteSetup[18]:=FALSE; (*Make sure that the write variable is turned off after one write command*)
END_IF
F_Trig[18](CLK:=hmi_DiPV[18].IsForced); (*Reset HMI forcing dialog when timer runs out*)
IF (F_Trig[18].Q) THEN hmi_DiSetup[18].Enable.Forcing:=FALSE;di_RemoteEmergencyStop_setup.Enable.Forcing:=FALSE; END_IF
(**************************************************)



(**************di_SpareChannel32***********************)
IF (RestoreAllToDefault OR di_SpareChannel32_setup.RestoreDefault  OR hmi_RestoreDefault_di[19]) THEN
	di_SpareChannel32_setup.Name:='di_SpareChannel32'; 
	di_SpareChannel32_setup.CardNb:=PRG_HMI.setup_DioCard1_Number; 
	di_SpareChannel32_setup.ChannelMode:=1;
	di_SpareChannel32_setup.ChannelNb:=32;
 	di_SpareChannel32_setup.Delay.TOF:=T#0ms; 
	di_SpareChannel32_setup.Delay.TON:=T#0ms; 
	di_SpareChannel32_setup.Enable.Forcing:=0; 
	di_SpareChannel32_setup.Enable.TON:=0; 
	di_SpareChannel32_setup.Enable.TOF:=0; 
	di_SpareChannel32_setup.Levels.ForceValue:=0;
END_IF
IF (hmi_RestoreDefault_di[19] OR RestoreAllToDefault OR di_SpareChannel32_setup.RestoreDefault) THEN (*Copy values into HMI variable and reset*)
	hmi_DiSetup[19]:=di_SpareChannel32_setup; (*Copy setup values from retain into hmi variable*)
	hmi_RestoreDefault_di[19]:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
	di_SpareChannel32_setup.RestoreDefault:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
END_IF
IF (hmi_DiWriteSetup[19]) THEN
	di_SpareChannel32_setup:=hmi_DiSetup[19]; (*Paste hmi changes back into setup variable*)
	hmi_DiWriteSetup[19]:=FALSE; (*Make sure that the write variable is turned off after one write command*)
END_IF
F_Trig[19](CLK:=hmi_DiPV[19].IsForced); (*Reset HMI forcing dialog when timer runs out*)
IF (F_Trig[19].Q) THEN hmi_DiSetup[19].Enable.Forcing:=FALSE;di_SpareChannel32_setup.Enable.Forcing:=FALSE; END_IF
(**************************************************)







END_ACTION

END_ACTIONS