PROGRAM PRG_AI
VAR
	F_Trig : ARRAY[1..cnst_num_ai] OF F_TRIG;
	i : INT;	(*Loop variable*)
	ManualFixChannels : BOOL; (*Will reset channels if faulty, i.e. card number is zero*)
	Reset: BOOL;
	Firstrun: BOOL;
	
	ai_CabinetTemperature_daemon: fb_AiProcess;
	ai_BatteryRoomTemperature_daemon: fb_AiProcess;
	ai_FilterTemperature_daemon: fb_AiProcess;
	
	ai_CabinetTemperature: str_AiProcess;
	ai_BatteryRoomTemperature: str_AiProcess;
	ai_FilterTemperature: str_AiProcess;
	
END_VAR

VAR RETAIN
	ai_CabinetTemperature_setup: str_AiSetup;
	ai_BatteryRoomTemperature_setup: str_AiSetup;
	ai_FilterTemperature_setup: str_AiSetup;
END_VAR

Reset := PRG_Functions.Reset;

(*Setup the HMI variables so that they are equal to actual used variables*)
IF (NOT Firstrun) THEN
	hmi_AiSetup[1] := ai_CabinetTemperature_setup;
	hmi_AiSetup[2] := ai_BatteryRoomTemperature_setup;
	hmi_AiSetup[3] := ai_FilterTemperature_setup;
	Firstrun := TRUE;
END_IF


(*Analog Input Signals*)
	ai_CabinetTemperature_daemon (setup:=ai_CabinetTemperature_setup,reset:=Reset,outPV=>ai_CabinetTemperature);
	ai_BatteryRoomTemperature_daemon (setup:=ai_BatteryRoomTemperature_setup,reset:=Reset,outPV=>ai_BatteryRoomTemperature);
	ai_FilterTemperature_daemon (setup:=ai_FilterTemperature_setup,reset:=Reset,outPV=>ai_FilterTemperature);

(*HMI Assign*)
	hmi_AiPV[1]:=ai_CabinetTemperature_daemon.outPV;
	hmi_AiPV[2]:=ai_BatteryRoomTemperature_daemon.outPV;
	hmi_AiPV[3]:=ai_FilterTemperature_daemon.outPV;


IF (ManualFixChannels) THEN  (*If manually forced: re-configure the channels*)
	FOR i:=0 TO cnst_num_ai BY 1 DO				(*Check if channel info is empty and restore if so.*)
		IF (PRG_HMI.setup_AioCard1_Number <> 0) THEN
			hmi_RestoreDefault_ai[i] := TRUE;
		END_IF
	END_FOR;
	ManualFixChannels := FALSE;
END_IF


END_PROGRAM

ACTIONS

ACTION Settings
(*
THIS SECTION CONTAINS HARD-CODED CHANNEL SETTINGS FOR EACH OF THE ANALOG INPUTS.

The settings are stored in retain memory, but whenever permanent changes are made, they should be hard coded into the appropriate channel below.
Each channel has settings for:

- Channel name (used for presentation in HMI)
- Channel- and card number (used to retrieve channel value via MIO lib)
- Channel type (4-20mA, PT100 etc)
- Channel forcing (force value and a bool flag to enable/disable forcing)
- Channel error flags, along with enable/disable flag + time delays
- Channel level flags, along with enable/disable flag + time delays

All setup values in retain memory can be forced to default (hard coded) values by setting RestoreAllToDefault, 
or individually by setting hmi_RestoreDefault_ai[]. The latter is primary used from HMI.
*)
(***************ai_CabinetTemperature***************)
IF (RestoreAllToDefault OR ai_CabinetTemperature_setup.RestoreDefault  OR hmi_RestoreDefault_ai[1]) THEN
	ai_CabinetTemperature_setup.Name:='ai_CabinetTemperature'; 
	ai_CabinetTemperature_setup.CardNb:=PRG_HMI.setup_AioCard1_Number; 
	ai_CabinetTemperature_setup.ChannelMode:=16#D3;
	ai_CabinetTemperature_setup.ChannelNb:=1;
 	ai_CabinetTemperature_setup.Enable.Forcing:=0; 
 	ai_CabinetTemperature_setup.Enable.LLL:=0; 
 	ai_CabinetTemperature_setup.Enable.LL:=0; 
 	ai_CabinetTemperature_setup.Enable.L:=0; 
 	ai_CabinetTemperature_setup.Enable.H:=0; 
 	ai_CabinetTemperature_setup.Enable.HH:=0; 
 	ai_CabinetTemperature_setup.Enable.HHH:=0; 
 	ai_CabinetTemperature_setup.Enable.WireBreak:=1; 
 	ai_CabinetTemperature_setup.Enable.Freeze:=1; 
 	ai_CabinetTemperature_setup.Enable.High:=1; 
 	ai_CabinetTemperature_setup.Enable.OOR:=1; 
 	ai_CabinetTemperature_setup.Delay.LLL:=T#1s; 
 	ai_CabinetTemperature_setup.Delay.LL:=T#1s; 
 	ai_CabinetTemperature_setup.Delay.L:=T#1s; 
 	ai_CabinetTemperature_setup.Delay.H:=T#1s; 
 	ai_CabinetTemperature_setup.Delay.HH:=T#1s; 
 	ai_CabinetTemperature_setup.Delay.HHH:=T#1s; 
 	ai_CabinetTemperature_setup.Delay.WireBreak:=T#1s; 
 	ai_CabinetTemperature_setup.Delay.High:=T#1s; 
 	ai_CabinetTemperature_setup.Delay.OOR:=T#1s; 
 	ai_CabinetTemperature_setup.Levels.LLL:=0; 
 	ai_CabinetTemperature_setup.Levels.LL:=0; 
 	ai_CabinetTemperature_setup.Levels.L:=0; 
 	ai_CabinetTemperature_setup.Levels.H:=0; 
 	ai_CabinetTemperature_setup.Levels.HH:=0; 
 	ai_CabinetTemperature_setup.Levels.HHH:=0; 
 	ai_CabinetTemperature_setup.Levels.Scale4mA:=0; 
 	ai_CabinetTemperature_setup.Levels.Scale20mA:=100; 
 	ai_CabinetTemperature_setup.Levels.ForceValue:=0; 
END_IF
IF (hmi_RestoreDefault_ai[1] OR RestoreAllToDefault OR ai_CabinetTemperature_setup.RestoreDefault) THEN (*Copy values into HMI variable and reset*)
	hmi_AiSetup[1]:=ai_CabinetTemperature_setup; (*Copy setup values from retain into hmi variable*)
	hmi_RestoreDefault_ai[1]:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
	ai_CabinetTemperature_setup.RestoreDefault:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
END_IF
IF (hmi_AiWriteSetup[1]) THEN
	ai_CabinetTemperature_setup:=hmi_AiSetup[1]; (*Paste hmi changes back into setup variable*)
	hmi_AiWriteSetup[1]:=FALSE; (*Make sure that the write variable is turned off after one write command*)
END_IF
F_Trig[1](CLK:=hmi_AiPV[1].IsForced); (*Reset HMI forcing dialog when timer runs out*)
IF (F_Trig[1].Q) THEN hmi_AiSetup[1].Enable.Forcing:=FALSE;ai_CabinetTemperature_setup.Enable.Forcing:=FALSE; END_IF
(**************************************************)



(***************ai_BatteryRoomTemperature***************)
IF (RestoreAllToDefault OR ai_BatteryRoomTemperature_setup.RestoreDefault  OR hmi_RestoreDefault_ai[2]) THEN
	ai_BatteryRoomTemperature_setup.Name:='ai_BatteryRoomTemperature'; 
	ai_BatteryRoomTemperature_setup.CardNb:=PRG_HMI.setup_AioCard1_Number; 
	ai_BatteryRoomTemperature_setup.ChannelMode:=16#D3;
	ai_BatteryRoomTemperature_setup.ChannelNb:=2;
 	ai_BatteryRoomTemperature_setup.Enable.Forcing:=0; 
 	ai_BatteryRoomTemperature_setup.Enable.LLL:=0; 
 	ai_BatteryRoomTemperature_setup.Enable.LL:=0; 
 	ai_BatteryRoomTemperature_setup.Enable.L:=0; 
 	ai_BatteryRoomTemperature_setup.Enable.H:=0; 
 	ai_BatteryRoomTemperature_setup.Enable.HH:=0; 
 	ai_BatteryRoomTemperature_setup.Enable.HHH:=0; 
 	ai_BatteryRoomTemperature_setup.Enable.WireBreak:=1; 
 	ai_BatteryRoomTemperature_setup.Enable.Freeze:=1; 
 	ai_BatteryRoomTemperature_setup.Enable.High:=1; 
 	ai_BatteryRoomTemperature_setup.Enable.OOR:=1; 
 	ai_BatteryRoomTemperature_setup.Delay.LLL:=T#1s; 
 	ai_BatteryRoomTemperature_setup.Delay.LL:=T#1s; 
 	ai_BatteryRoomTemperature_setup.Delay.L:=T#1s; 
 	ai_BatteryRoomTemperature_setup.Delay.H:=T#1s; 
 	ai_BatteryRoomTemperature_setup.Delay.HH:=T#1s; 
 	ai_BatteryRoomTemperature_setup.Delay.HHH:=T#1s; 
 	ai_BatteryRoomTemperature_setup.Delay.WireBreak:=T#1s; 
 	ai_BatteryRoomTemperature_setup.Delay.High:=T#1s; 
 	ai_BatteryRoomTemperature_setup.Delay.OOR:=T#1s; 
 	ai_BatteryRoomTemperature_setup.Levels.LLL:=0; 
 	ai_BatteryRoomTemperature_setup.Levels.LL:=0; 
 	ai_BatteryRoomTemperature_setup.Levels.L:=0; 
 	ai_BatteryRoomTemperature_setup.Levels.H:=0; 
 	ai_BatteryRoomTemperature_setup.Levels.HH:=0; 
 	ai_BatteryRoomTemperature_setup.Levels.HHH:=0; 
 	ai_BatteryRoomTemperature_setup.Levels.Scale4mA:=-20; 
 	ai_BatteryRoomTemperature_setup.Levels.Scale20mA:=80; 
 	ai_BatteryRoomTemperature_setup.Levels.ForceValue:=0; 
END_IF
IF (hmi_RestoreDefault_ai[2] OR RestoreAllToDefault OR ai_BatteryRoomTemperature_setup.RestoreDefault) THEN (*Copy values into HMI variable and reset*)
	hmi_AiSetup[2]:=ai_BatteryRoomTemperature_setup; (*Copy setup values from retain into hmi variable*)
	hmi_RestoreDefault_ai[2]:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
	ai_BatteryRoomTemperature_setup.RestoreDefault:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
END_IF
IF (hmi_AiWriteSetup[2]) THEN
	ai_BatteryRoomTemperature_setup:=hmi_AiSetup[2]; (*Paste hmi changes back into setup variable*)
	hmi_AiWriteSetup[2]:=FALSE; (*Make sure that the write variable is turned off after one write command*)
END_IF
F_Trig[2](CLK:=hmi_AiPV[2].IsForced); (*Reset HMI forcing dialog when timer runs out*)
IF (F_Trig[2].Q) THEN hmi_AiSetup[2].Enable.Forcing:=FALSE;ai_BatteryRoomTemperature_setup.Enable.Forcing:=FALSE; END_IF
(**************************************************)



(***************ai_FilterTemperature***************)
IF (RestoreAllToDefault OR ai_FilterTemperature_setup.RestoreDefault  OR hmi_RestoreDefault_ai[3]) THEN
	ai_FilterTemperature_setup.Name:='ai_FilterTemperature'; 
	ai_FilterTemperature_setup.CardNb:=PRG_HMI.setup_AioCard1_Number; 
	ai_FilterTemperature_setup.ChannelMode:=16#D1;
	ai_FilterTemperature_setup.ChannelNb:=4;
 	ai_FilterTemperature_setup.Enable.Forcing:=0; 
 	ai_FilterTemperature_setup.Enable.LLL:=0; 
 	ai_FilterTemperature_setup.Enable.LL:=0; 
 	ai_FilterTemperature_setup.Enable.L:=0; 
 	ai_FilterTemperature_setup.Enable.H:=0; 
 	ai_FilterTemperature_setup.Enable.HH:=0; 
 	ai_FilterTemperature_setup.Enable.HHH:=0; 
 	ai_FilterTemperature_setup.Enable.WireBreak:=1; 
 	ai_FilterTemperature_setup.Enable.Freeze:=1; 
 	ai_FilterTemperature_setup.Enable.High:=1; 
 	ai_FilterTemperature_setup.Enable.OOR:=1; 
 	ai_FilterTemperature_setup.Delay.LLL:=T#1s; 
 	ai_FilterTemperature_setup.Delay.LL:=T#1s; 
 	ai_FilterTemperature_setup.Delay.L:=T#1s; 
 	ai_FilterTemperature_setup.Delay.H:=T#1s; 
 	ai_FilterTemperature_setup.Delay.HH:=T#1s; 
 	ai_FilterTemperature_setup.Delay.HHH:=T#1s; 
 	ai_FilterTemperature_setup.Delay.WireBreak:=T#1s; 
 	ai_FilterTemperature_setup.Delay.High:=T#1s; 
 	ai_FilterTemperature_setup.Delay.OOR:=T#1s; 
 	ai_FilterTemperature_setup.Levels.LLL:=0; 
 	ai_FilterTemperature_setup.Levels.LL:=0; 
 	ai_FilterTemperature_setup.Levels.L:=0; 
 	ai_FilterTemperature_setup.Levels.H:=0; 
 	ai_FilterTemperature_setup.Levels.HH:=0; 
 	ai_FilterTemperature_setup.Levels.HHH:=0; 
 	ai_FilterTemperature_setup.Levels.Scale4mA:=0; 
 	ai_FilterTemperature_setup.Levels.Scale20mA:=100; 
 	ai_FilterTemperature_setup.Levels.ForceValue:=0; 
END_IF
IF (hmi_RestoreDefault_ai[3] OR RestoreAllToDefault OR ai_FilterTemperature_setup.RestoreDefault) THEN (*Copy values into HMI variable and reset*)
	hmi_AiSetup[3]:=ai_FilterTemperature_setup; (*Copy setup values from retain into hmi variable*)
	hmi_RestoreDefault_ai[3]:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
	ai_FilterTemperature_setup.RestoreDefault:=FALSE; (*Make sure that the restore variable is turned off after one restore command*)
END_IF
IF (hmi_AiWriteSetup[3]) THEN
	ai_FilterTemperature_setup:=hmi_AiSetup[3]; (*Paste hmi changes back into setup variable*)
	hmi_AiWriteSetup[3]:=FALSE; (*Make sure that the write variable is turned off after one write command*)
END_IF
F_Trig[3](CLK:=hmi_AiPV[3].IsForced); (*Reset HMI forcing dialog when timer runs out*)
IF (F_Trig[3].Q) THEN hmi_AiSetup[3].Enable.Forcing:=FALSE;ai_FilterTemperature_setup.Enable.Forcing:=FALSE; END_IF
(**************************************************)







END_ACTION

END_ACTIONS