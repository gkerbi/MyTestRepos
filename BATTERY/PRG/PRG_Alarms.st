PROGRAM PRG_Alarms
VAR
	pack: 					INT := 0;
	BMS_Alarm_Word: 		INT := 8; (*Must be first available word number after the ordinary alarms*)
	
	(*Two dimensional array for Set/Reset blocks. First index refers to word number (e.g. Alarmword[1]), second index refers to bit number*)
	AlarmSR: 				ARRAY[1..32,0..15] OF SR;
	Repeat_Alarm: 			fb_RepeatAlarm;
	Repeat_AlarmAppWarning:	fb_RepeatAlarm;
	E0AlarmWord:			fb_BitToWord;
		
	Reset : 				BOOL;
	CommonWarning: 			BOOL;
	CommonPLCWarning:		BOOL;
	CommonAppWarning:		BOOL;
	CommonIoWarning:		BOOL;
	CommonLevelWarning:		BOOL;
	CommonSignalWarning:	BOOL;
	CommonE0Warning:		BOOL;		
END_VAR


Reset := PRG_Functions.Reset;

(*Gorup alarms with blinking on new alarms within their group*)
CommonWarning :=  		Repeat_Alarm.Alarm_common;
CommonPLCWarning := 	Repeat_Alarm.Alarm_Repeat1;
CommonSignalWarning:= 	Repeat_Alarm.Alarm_Repeat2;
CommonIoWarning	 := 	Repeat_Alarm.Alarm_Repeat3;
CommonLevelWarning := 	Repeat_Alarm.Alarm_Repeat4;
CommonAppWarning := 	Repeat_AlarmAppWarning.Alarm_common;
CommonE0Warning := 		Repeat_Alarm.Alarm_Repeat20;


(*Single alarms used for E0 *)
E0AlarmWord(
	EN := TRUE,
	Bit0 := PRG_DI.di_WaterLeakageDetected.PV,
	Bit1 := PRG_BatteryProtection.batteryPreWarning,
	Bit2 := PRG_BatteryProtection.Warning_CellTemp_L,
	Bit3 := PRG_BatteryProtection.Warning_CellVolt_L_Offline,
	Bit4 := PRG_BatteryProtection.Warning_CellVolt_LL_Offline,
	Bit5 := PRG_BatteryProtection.Warning_SoC_L_Offline,
	Bit6 := FALSE,
	Bit7 := FALSE,
	Bit8 := FALSE,
	Bit9 := FALSE,
	Bit10 := FALSE,
	Bit11 := FALSE,
	Bit12 := FALSE,
	Bit13 := FALSE,
	Bit14 := FALSE,
	Bit15 := FALSE,
	OUT => 
);

(*General PLC warnings*)
AlarmSR[1,0] (SET1:=(PRG_HW.HwAlarmCPU.AlarmCpuLoad) ,  Q1=>AlarmWord[1].0, RESET:=PRG_Functions.Reset);(*High Load on CPU*)
AlarmSR[1,1] (SET1:=(PRG_HW.HwAlarmCPU.AlarmCpuTemp) ,  Q1=>AlarmWord[1].1, RESET:=PRG_Functions.Reset);(*High Temperature on CPU*)
AlarmSR[1,2] (SET1:=(PRG_HW.HwAlarmCPU.AlarmFreeMem) ,  Q1=>AlarmWord[1].2, RESET:=PRG_Functions.Reset);(*Low Free Memory on PLC CPU*)
AlarmSR[1,3] (SET1:=(PRG_HW.Em0In.Alarm) ,  Q1=>AlarmWord[1].3, RESET:=PRG_Functions.Reset);(*High Load on EM213 Network Card*)
AlarmSR[1,4] (SET1:=(PRG_HW.Eth0In.Alarm) ,  Q1=>AlarmWord[1].4, RESET:=PRG_Functions.Reset);(*High Load on Ethernet Port ETH1*)
AlarmSR[1,5] (SET1:=(PRG_HW.Eth1In.Alarm) ,  Q1=>AlarmWord[1].5, RESET:=PRG_Functions.Reset);(*High Load on Ethernet Port ETH2*)

(*Signal warnings, OOR and wirebreak etc*)
AlarmSR[2,0] (SET1:=(PRG_AI.ai_BatteryRoomTemperature.Alarm.common) ,  Q1=>AlarmWord[2].0, RESET:=PRG_Functions.Reset);(*Battery Room Temperature - 4mA loop fail*)
AlarmSR[2,1] (SET1:=(PRG_AI.ai_CabinetTemperature.Alarm.common) ,  Q1=>AlarmWord[2].1, RESET:=PRG_Functions.Reset);(*Cabinet Temperature - Loop Failure*)
AlarmSR[2,2] (SET1:=(PRG_AI.ai_FilterTemperature.Alarm.common) ,  Q1=>AlarmWord[2].2, RESET:=PRG_Functions.Reset);(*LC Filter Temperature - Loop Failure*)
AlarmSR[2,3] (SET1:=(PRG_AO.ao_BatteryCurrentInstr.Alarm.common) ,  Q1=>AlarmWord[2].3, RESET:=PRG_Functions.Reset);(*Current Instrument 4-20mA Loop Failure*)
AlarmSR[2,4] (SET1:=(PRG_AO.ao_BatteryPowerInstr.Alarm.common) ,  Q1=>AlarmWord[2].4, RESET:=PRG_Functions.Reset);(*Power Instrument 4-20mA Loop Failure*)
AlarmSR[2,5] (SET1:=(PRG_AO.ao_BatteryVoltageInstr.Alarm.common) ,  Q1=>AlarmWord[2].5, RESET:=PRG_Functions.Reset);(*Voltage Instrument 4-20mA Loop Failure*)
AlarmSR[2,6] (SET1:=(PRG_AO.ao_BatterySocInstr.Alarm.common) ,  Q1=>AlarmWord[2].6, RESET:=PRG_Functions.Reset);(*SoC Instrument 4-20mA Loop Failure*)
AlarmSR[2,7] (SET1:=(PRG_AO.ao_BatteryChrgDischrgInstr.Alarm.common) ,  Q1=>AlarmWord[2].7, RESET:=PRG_Functions.Reset);(*Charge/Discharge Instrument 4-20mA Loop Failure*)

(*IO warnings, alarm contacts, module error etc*)
AlarmSR[3,0] (SET1:=(PRG_HW.AioCardError1) ,  Q1=>AlarmWord[3].0, RESET:=PRG_Functions.Reset);(*Common Alarm from PLC I/O Analog IO Card*)
AlarmSR[3,1] (SET1:=(PRG_HW.DioCardError1) ,  Q1=>AlarmWord[3].1, RESET:=PRG_Functions.Reset);(*Common Alarm from PLC I/O Digital IO Card*)
AlarmSR[3,2] (SET1:=(PRG_Functions.Breaker.Alarm_delayed) ,  Q1=>AlarmWord[3].2, RESET:=PRG_Functions.Reset);(*Voting Alarm DC Breaker Position*)
AlarmSR[3,3] (SET1:=(PRG_DI.di_EmergencyStopLoopFault.PV) ,  Q1=>AlarmWord[3].3, RESET:=PRG_Functions.Reset);(*Emergency Stop Loop Alarm*)
AlarmSR[3,4] (SET1:=(PRG_Operation.ControlPlace.alarmDeviation) ,  Q1=>AlarmWord[3].4, RESET:=PRG_Functions.Reset);(*Voting Alarm Local/Remote Switch*)
AlarmSR[3,5] (SET1:=(NOT PRG_DI.di_EthernetSwitchAlarm.PV AND PRG_HMI.enEthernetSwitchAlarm) ,  Q1=>AlarmWord[3].5, RESET:=PRG_Functions.Reset);(*External Ethernet Switch Alarm*)

(*Level warning, high or low etc*)
AlarmSR[4,0] (SET1:=(PRG_AI.ai_BatteryRoomTemperature.Alarm.HH) ,  Q1=>AlarmWord[4].0, RESET:=PRG_Functions.Reset);(*Battery Room High Temperature*)
AlarmSR[4,1] (SET1:=(PRG_AI.ai_BatteryRoomTemperature.Alarm.LL) ,  Q1=>AlarmWord[4].1, RESET:=PRG_Functions.Reset);(*Battery Room Low Temperature*)
AlarmSR[4,2] (SET1:=(PRG_AI.ai_BatteryRoomTemperature.Alarm.HHH) ,  Q1=>AlarmWord[4].2, RESET:=PRG_Functions.Reset);(*Battery Room HighHigh Temperature*)
AlarmSR[4,3] (SET1:=(PRG_AI.ai_BatteryRoomTemperature.Alarm.LLL) ,  Q1=>AlarmWord[4].3, RESET:=PRG_Functions.Reset);(*Battery Room LowLow Temperature*)
AlarmSR[4,4] (SET1:=(PRG_AI.ai_CabinetTemperature.Alarm.HH) ,  Q1=>AlarmWord[4].4, RESET:=PRG_Functions.Reset);(*Cabinet High Temperature*)
AlarmSR[4,5] (SET1:=(PRG_AI.ai_CabinetTemperature.Alarm.LL) ,  Q1=>AlarmWord[4].5, RESET:=PRG_Functions.Reset);(*Cabinet Low Temperature*)
AlarmSR[4,6] (SET1:=(PRG_AI.ai_FilterTemperature.Alarm.HH) ,  Q1=>AlarmWord[4].6, RESET:=PRG_Functions.Reset);(*LC Filter High Temperature*)
AlarmSR[4,7] (SET1:=(PRG_AI.ai_FilterTemperature.Alarm.LL) ,  Q1=>AlarmWord[4].7, RESET:=PRG_Functions.Reset);(*LC Filter Low Temperature*)
AlarmSR[4,8] (SET1:=(PRG_Drive.UnitOverTempAlarm) ,  Q1=>AlarmWord[4].8, RESET:=PRG_Functions.Reset);(*Vacon Unit High Temperature*)


(*Application specific warnings*)
AlarmSR[5,0] (SET1:=(PRG_Drive.Status.Warning) ,  Q1=>AlarmWord[5].0, RESET:=PRG_Functions.Reset);(*Common Alarm from DC/DC Converter*)
AlarmSR[5,1] (SET1:=(PRG_BatteryProtection.batteryCommonWarning) ,  Q1=>AlarmWord[5].1, RESET:=PRG_Functions.Reset);(*Common Alarm from Battery Management System*)
AlarmSR[5,2] (SET1:=(PRG_StateMain.StartingTimeout) ,  Q1=>AlarmWord[5].2, RESET:=PRG_Functions.Reset);(*Start Sequence Timeout*)
AlarmSR[5,3] (SET1:=(PRG_StateMain.StoppingTimeout) ,  Q1=>AlarmWord[5].3, RESET:=PRG_Functions.Reset);(*Stop Sequence Timeout - Failsafe Trip*)
AlarmSR[5,4] (SET1:=(PRG_DI.di_WaterLeakageDetected.PV) ,  Q1=>AlarmWord[5].4, RESET:=PRG_Functions.Reset);(*Water Leakage in DC/DC Section*)
AlarmSR[5,5] (SET1:=(PRG_Battery.StopChargeTOF.Q) ,  Q1=>AlarmWord[5].5, RESET:=PRG_Functions.Reset);(*Battery Charge Limit in Effect*)
AlarmSR[5,6] (SET1:=(PRG_Battery.StopDischargeTOF.Q) ,  Q1=>AlarmWord[5].6, RESET:=PRG_Functions.Reset);(*Battery Discharge Limit in Effect*)
AlarmSR[5,7] (SET1:=(NOT PRG_Functions.Breaker.DI_Verif_delay OR NOT PRG_DI.di_DcBreakerEarlyBreak.PV) ,  Q1=>AlarmWord[5].7, RESET:=PRG_Functions.Reset);(*DC Breaker Open - Start Inhibited*)
AlarmSR[5,8] (SET1:=(PRG_Operation.ControlPlace.ctrlLocation = e_Local) ,  Q1=>AlarmWord[5].8, RESET:=PRG_Functions.Reset);(*In Local Control*)
AlarmSR[5,9] (SET1:=(PRG_IAS.IasCommunication.Alarm) ,  Q1=>AlarmWord[5].9, RESET:=PRG_Functions.Reset);(*IAS Communication Alarm*)
AlarmSR[5,10] (SET1:=(PRG_BatteryComm.NoPrechargePackComm) ,  Q1=>AlarmWord[5].10, RESET:=PRG_Functions.Reset);(*Comm. Failure Battery Precharge System*)
AlarmSR[5,11] (SET1:=((PRG_StateMain.RunningTON.Q) AND NOT PRG_Battery.BatteryAllConnected) ,  Q1=>AlarmWord[5].11, RESET:=PRG_Functions.Reset);(*All Batteries are not Connected*)
AlarmSR[5,12] (SET1:=(PRG_StateMain.BatteryConnectionTimeout) ,  Q1=>AlarmWord[5].12, RESET:=PRG_Functions.Reset);(*Battery Connection Timeout during Starting*)
AlarmSR[5,13] (SET1:=(PRG_StateMain.BatteryDisconnectionTimeout) ,  Q1=>AlarmWord[5].13, RESET:=PRG_Functions.Reset);(*Battery Disconnection Timeout during Stopping*)

(*Battery Specific PLC Alarms*)
AlarmSR[6,0] (SET1:=(PRG_BatteryProtection.batteryPreWarning) ,  Q1=>AlarmWord[6].0, RESET:=PRG_Functions.Reset);(*Prewarning from Battery Management System*)
AlarmSR[6,1] (SET1:=(PRG_BatteryProtection.Warning_SoC_L) ,  Q1=>AlarmWord[6].1, RESET:=PRG_Functions.Reset);(*State of Charge Low Alarm - Start Charging*)
AlarmSR[6,2] (SET1:=(PRG_BatteryProtection.Warning_SoC_H) ,  Q1=>AlarmWord[6].2, RESET:=PRG_Functions.Reset);(*State of Charge High Alarm*)
AlarmSR[6,3] (SET1:=(PRG_BatteryProtection.Warning_Volt_H) ,  Q1=>AlarmWord[6].3, RESET:=PRG_Functions.Reset);(*High Battery Voltage Alarm*)
AlarmSR[6,4] (SET1:=(PRG_BatteryProtection.Warning_Volt_L) ,  Q1=>AlarmWord[6].4, RESET:=PRG_Functions.Reset);(*Low Battery Voltage Alarm*)
AlarmSR[6,5] (SET1:=(PRG_BatteryProtection.Warning_CellVolt_L) ,  Q1=>AlarmWord[6].5, RESET:=PRG_Functions.Reset);(*Low Cell Voltage Alarm*)
AlarmSR[6,6] (SET1:=(PRG_BatteryProtection.Warning_CellVolt_H) ,  Q1=>AlarmWord[6].6, RESET:=PRG_Functions.Reset);(*High Cell Voltage Alarm*)
AlarmSR[6,7] (SET1:=(PRG_BatteryProtection.Warning_CellTemp_L) ,  Q1=>AlarmWord[6].7, RESET:=PRG_Functions.Reset);(*Low Cell Temperature Alarm*)
AlarmSR[6,8] (SET1:=(PRG_BatteryProtection.Warning_CellTemp_H) ,  Q1=>AlarmWord[6].8, RESET:=PRG_Functions.Reset);(*High Cell Temperature Alarm*)
AlarmSR[6,9] (SET1:=(PRG_BatteryProtection.Warning_SoC_L_Offline) ,  Q1=>AlarmWord[6].9, RESET:=PRG_Functions.Reset);(*Offline Low SoC: Connect and Charge Now*)
AlarmSR[6,10] (SET1:=(PRG_BatteryProtection.Warning_CellVolt_L_Offline) ,  Q1=>AlarmWord[6].10, RESET:=PRG_Functions.Reset);(*Offline Low Cell Voltage: Connect and Charge Now*)
AlarmSR[6,11] (SET1:=(PRG_BatteryProtection.Warning_CellVolt_LL_Offline) ,  Q1=>AlarmWord[6].11, RESET:=PRG_Functions.Reset);(*Offline Low Cell Voltage: Critical Level - Charge Now*)
AlarmSR[6,12] (SET1:=(PRG_HMI.SoHVerifModeActive) ,  Q1=>AlarmWord[6].12, RESET:=PRG_Functions.Reset);(*SoH Verification Mode Active: SoC Limits Extended*)


(*Auto generated alarms from Corvus BMS*)

BMS_Alarm_Word:= 8; (*Next available alarmword*)
FOR pack := 1 TO DINT_TO_INT(PRG_HMI.setup_Battery_total_nr_of_packs) BY 1 DO
	AlarmSR[BMS_Alarm_Word,0] (SET1:=(PRG_BatteryComm.CorvusRead[pack].FW.Input_PowerLoss_Warning) ,  Q1=>AlarmWord[BMS_Alarm_Word].0, RESET:=Reset);(*BMS Pack  Input Power Loss Warning*)
	AlarmSR[BMS_Alarm_Word,1] (SET1:=(PRG_BatteryComm.CorvusRead[pack].FW.Module_Communication_Warning) ,  Q1=>AlarmWord[BMS_Alarm_Word].1, RESET:=Reset);(*BMS Pack  Module Communication Warning*)
	AlarmSR[BMS_Alarm_Word,2] (SET1:=(PRG_BatteryComm.CorvusRead[pack].FW.OverCurrent_Warning) ,  Q1=>AlarmWord[BMS_Alarm_Word].2, RESET:=Reset);(*BMS Pack  Over Current Warning*)
	AlarmSR[BMS_Alarm_Word,3] (SET1:=(PRG_BatteryComm.CorvusRead[pack].FW.PDM_overTemperature_Warning) ,  Q1=>AlarmWord[BMS_Alarm_Word].3, RESET:=Reset);(*BMS Pack  PDM Over Temperature Warning*)
	AlarmSR[BMS_Alarm_Word,4] (SET1:=(PRG_BatteryComm.CorvusRead[pack].FW.SE_overTemperature_Warning) ,  Q1=>AlarmWord[BMS_Alarm_Word].4, RESET:=Reset);(*BMS Pack  Cell Over Temperature Warning*)
	AlarmSR[BMS_Alarm_Word,5] (SET1:=(PRG_BatteryComm.CorvusRead[pack].FW.SE_overVoltage_Warning) ,  Q1=>AlarmWord[BMS_Alarm_Word].5, RESET:=Reset);(*BMS Pack  Cell Over Voltage Warning*)
	AlarmSR[BMS_Alarm_Word,6] (SET1:=(PRG_BatteryComm.CorvusRead[pack].FW.SE_underVoltage_Warning) ,  Q1=>AlarmWord[BMS_Alarm_Word].6, RESET:=Reset);(*BMS Pack  Cell Under Voltage Warning*)
	AlarmSR[BMS_Alarm_Word,7] (SET1:=(PRG_BatteryComm.CorvusRead[pack].ModbusFault AND NOT PRG_BatteryComm.CorvusBMS_Total_Comm_Fault) ,  Q1=>AlarmWord[BMS_Alarm_Word].7, RESET:=Reset);(*BMS Pack Communication Alarm*)
	BMS_Alarm_Word :=  BMS_Alarm_Word+1;
END_FOR



(*Blinks the alarm output*)

Repeat_AlarmAppWarning(
	AlarmWord5:= INT_TO_WORD(AlarmWord[5]),
	AlarmWord6:= INT_TO_WORD(AlarmWord[6]),
);

Repeat_Alarm(
	AlarmWord1:= INT_TO_WORD(AlarmWord[1]),
	AlarmWord2:= INT_TO_WORD(AlarmWord[2]),
	AlarmWord3:= INT_TO_WORD(AlarmWord[3]),
	AlarmWord4:= INT_TO_WORD(AlarmWord[4]),
	AlarmWord5:= INT_TO_WORD(AlarmWord[5]),
	AlarmWord6:= INT_TO_WORD(AlarmWord[6]),
	AlarmWord7:= INT_TO_WORD(AlarmWord[7]),
	AlarmWord8:= INT_TO_WORD(AlarmWord[8]),
	AlarmWord9:= INT_TO_WORD(AlarmWord[9]),
	AlarmWord10:= INT_TO_WORD(AlarmWord[10]),
	AlarmWord11:= INT_TO_WORD(AlarmWord[11]),
	AlarmWord12:= INT_TO_WORD(AlarmWord[12]),
	AlarmWord13:= INT_TO_WORD(AlarmWord[13]),
	AlarmWord14:= INT_TO_WORD(AlarmWord[14]),
	AlarmWord15:= INT_TO_WORD(AlarmWord[15]),
	AlarmWord16:= INT_TO_WORD(AlarmWord[16]),
	AlarmWord17:= INT_TO_WORD(AlarmWord[17]),
	AlarmWord18:= INT_TO_WORD(AlarmWord[18]),
	AlarmWord19:= INT_TO_WORD(AlarmWord[19]),
	AlarmWord20:= DINT_TO_WORD(E0AlarmWord.OUT),
	Alarm_common => ,
	Alarm_count => ,
	Alarm_Repeat1 => ,
	Alarm_Repeat2 => ,
	Alarm_Repeat3 => ,
	Alarm_Repeat4 => ,
	Alarm_Repeat5 => ,
	Alarm_Repeat6 => ,
	Alarm_Repeat7 => ,
	Alarm_Repeat8 => ,
	Alarm_Repeat9 => ,
	Alarm_Repeat10 => ,
	Alarm_Repeat11 => ,
	Alarm_Repeat12 => ,
	Alarm_Repeat13 => ,
	Alarm_Repeat14 => ,
	Alarm_Repeat15 => ,
	Alarm_Repeat16 => ,
	Alarm_Repeat17 => ,
	Alarm_Repeat18 => ,
	Alarm_Repeat19 => ,
	Alarm_Repeat20 => 
);

END_PROGRAM

ACTIONS 
ACTION hmi_Alarms
hmi_AlarmWord[1].0 := AlarmSR[1,0].Q1;
hmi_AlarmWord[1].1 := AlarmSR[1,1].Q1;
hmi_AlarmWord[1].2 := AlarmSR[1,2].Q1;
hmi_AlarmWord[1].3 := AlarmSR[1,3].Q1;
hmi_AlarmWord[1].4 := AlarmSR[1,4].Q1;
hmi_AlarmWord[1].5 := AlarmSR[1,5].Q1;
hmi_AlarmWord[1].6 := AlarmSR[1,6].Q1;
hmi_AlarmWord[1].7 := AlarmSR[1,7].Q1;
hmi_AlarmWord[1].8 := AlarmSR[1,8].Q1;
hmi_AlarmWord[1].9 := AlarmSR[1,9].Q1;
hmi_AlarmWord[1].10 := AlarmSR[1,10].Q1;
hmi_AlarmWord[1].11 := AlarmSR[1,11].Q1;
hmi_AlarmWord[1].12 := AlarmSR[1,12].Q1;
hmi_AlarmWord[1].13 := AlarmSR[1,13].Q1;
hmi_AlarmWord[1].14 := AlarmSR[1,14].Q1;
hmi_AlarmWord[1].15 := AlarmSR[1,15].Q1;
hmi_AlarmWord[2].0 := AlarmSR[2,0].Q1;
hmi_AlarmWord[2].1 := AlarmSR[2,1].Q1;
hmi_AlarmWord[2].2 := AlarmSR[2,2].Q1;
hmi_AlarmWord[2].3 := AlarmSR[2,3].Q1;
hmi_AlarmWord[2].4 := AlarmSR[2,4].Q1;
hmi_AlarmWord[2].5 := AlarmSR[2,5].Q1;
hmi_AlarmWord[2].6 := AlarmSR[2,6].Q1;
hmi_AlarmWord[2].7 := AlarmSR[2,7].Q1;
hmi_AlarmWord[2].8 := AlarmSR[2,8].Q1;
hmi_AlarmWord[2].9 := AlarmSR[2,9].Q1;
hmi_AlarmWord[2].10 := AlarmSR[2,10].Q1;
hmi_AlarmWord[2].11 := AlarmSR[2,11].Q1;
hmi_AlarmWord[2].12 := AlarmSR[2,12].Q1;
hmi_AlarmWord[2].13 := AlarmSR[2,13].Q1;
hmi_AlarmWord[2].14 := AlarmSR[2,14].Q1;
hmi_AlarmWord[2].15 := AlarmSR[2,15].Q1;
hmi_AlarmWord[3].0 := AlarmSR[3,0].Q1;
hmi_AlarmWord[3].1 := AlarmSR[3,1].Q1;
hmi_AlarmWord[3].2 := AlarmSR[3,2].Q1;
hmi_AlarmWord[3].3 := AlarmSR[3,3].Q1;
hmi_AlarmWord[3].4 := AlarmSR[3,4].Q1;
hmi_AlarmWord[3].5 := AlarmSR[3,5].Q1;
hmi_AlarmWord[3].6 := AlarmSR[3,6].Q1;
hmi_AlarmWord[3].7 := AlarmSR[3,7].Q1;
hmi_AlarmWord[3].8 := AlarmSR[3,8].Q1;
hmi_AlarmWord[3].9 := AlarmSR[3,9].Q1;
hmi_AlarmWord[3].10 := AlarmSR[3,10].Q1;
hmi_AlarmWord[3].11 := AlarmSR[3,11].Q1;
hmi_AlarmWord[3].12 := AlarmSR[3,12].Q1;
hmi_AlarmWord[3].13 := AlarmSR[3,13].Q1;
hmi_AlarmWord[3].14 := AlarmSR[3,14].Q1;
hmi_AlarmWord[3].15 := AlarmSR[3,15].Q1;
hmi_AlarmWord[4].0 := AlarmSR[4,0].Q1;
hmi_AlarmWord[4].1 := AlarmSR[4,1].Q1;
hmi_AlarmWord[4].2 := AlarmSR[4,2].Q1;
hmi_AlarmWord[4].3 := AlarmSR[4,3].Q1;
hmi_AlarmWord[4].4 := AlarmSR[4,4].Q1;
hmi_AlarmWord[4].5 := AlarmSR[4,5].Q1;
hmi_AlarmWord[4].6 := AlarmSR[4,6].Q1;
hmi_AlarmWord[4].7 := AlarmSR[4,7].Q1;
hmi_AlarmWord[4].8 := AlarmSR[4,8].Q1;
hmi_AlarmWord[4].9 := AlarmSR[4,9].Q1;
hmi_AlarmWord[4].10 := AlarmSR[4,10].Q1;
hmi_AlarmWord[4].11 := AlarmSR[4,11].Q1;
hmi_AlarmWord[4].12 := AlarmSR[4,12].Q1;
hmi_AlarmWord[4].13 := AlarmSR[4,13].Q1;
hmi_AlarmWord[4].14 := AlarmSR[4,14].Q1;
hmi_AlarmWord[4].15 := AlarmSR[4,15].Q1;
hmi_AlarmWord[5].0 := AlarmSR[5,0].Q1;
hmi_AlarmWord[5].1 := AlarmSR[5,1].Q1;
hmi_AlarmWord[5].2 := AlarmSR[5,2].Q1;
hmi_AlarmWord[5].3 := AlarmSR[5,3].Q1;
hmi_AlarmWord[5].4 := AlarmSR[5,4].Q1;
hmi_AlarmWord[5].5 := AlarmSR[5,5].Q1;
hmi_AlarmWord[5].6 := AlarmSR[5,6].Q1;
hmi_AlarmWord[5].7 := AlarmSR[5,7].Q1;
hmi_AlarmWord[5].8 := AlarmSR[5,8].Q1;
hmi_AlarmWord[5].9 := AlarmSR[5,9].Q1;
hmi_AlarmWord[5].10 := AlarmSR[5,10].Q1;
hmi_AlarmWord[5].11 := AlarmSR[5,11].Q1;
hmi_AlarmWord[5].12 := AlarmSR[5,12].Q1;
hmi_AlarmWord[5].13 := AlarmSR[5,13].Q1;
hmi_AlarmWord[5].14 := AlarmSR[5,14].Q1;
hmi_AlarmWord[5].15 := AlarmSR[5,15].Q1;
hmi_AlarmWord[6].0 := AlarmSR[6,0].Q1;
hmi_AlarmWord[6].1 := AlarmSR[6,1].Q1;
hmi_AlarmWord[6].2 := AlarmSR[6,2].Q1;
hmi_AlarmWord[6].3 := AlarmSR[6,3].Q1;
hmi_AlarmWord[6].4 := AlarmSR[6,4].Q1;
hmi_AlarmWord[6].5 := AlarmSR[6,5].Q1;
hmi_AlarmWord[6].6 := AlarmSR[6,6].Q1;
hmi_AlarmWord[6].7 := AlarmSR[6,7].Q1;
hmi_AlarmWord[6].8 := AlarmSR[6,8].Q1;
hmi_AlarmWord[6].9 := AlarmSR[6,9].Q1;
hmi_AlarmWord[6].10 := AlarmSR[6,10].Q1;
hmi_AlarmWord[6].11 := AlarmSR[6,11].Q1;
hmi_AlarmWord[6].12 := AlarmSR[6,12].Q1;
hmi_AlarmWord[6].13 := AlarmSR[6,13].Q1;
hmi_AlarmWord[6].14 := AlarmSR[6,14].Q1;
hmi_AlarmWord[6].15 := AlarmSR[6,15].Q1;
hmi_AlarmWord[7].0 := AlarmSR[7,0].Q1;
hmi_AlarmWord[7].1 := AlarmSR[7,1].Q1;
hmi_AlarmWord[7].2 := AlarmSR[7,2].Q1;
hmi_AlarmWord[7].3 := AlarmSR[7,3].Q1;
hmi_AlarmWord[7].4 := AlarmSR[7,4].Q1;
hmi_AlarmWord[7].5 := AlarmSR[7,5].Q1;
hmi_AlarmWord[7].6 := AlarmSR[7,6].Q1;
hmi_AlarmWord[7].7 := AlarmSR[7,7].Q1;
hmi_AlarmWord[7].8 := AlarmSR[7,8].Q1;
hmi_AlarmWord[7].9 := AlarmSR[7,9].Q1;
hmi_AlarmWord[7].10 := AlarmSR[7,10].Q1;
hmi_AlarmWord[7].11 := AlarmSR[7,11].Q1;
hmi_AlarmWord[7].12 := AlarmSR[7,12].Q1;
hmi_AlarmWord[7].13 := AlarmSR[7,13].Q1;
hmi_AlarmWord[7].14 := AlarmSR[7,14].Q1;
hmi_AlarmWord[7].15 := AlarmSR[7,15].Q1;
hmi_AlarmWord[8].0 := AlarmSR[8,0].Q1;
hmi_AlarmWord[8].1 := AlarmSR[8,1].Q1;
hmi_AlarmWord[8].2 := AlarmSR[8,2].Q1;
hmi_AlarmWord[8].3 := AlarmSR[8,3].Q1;
hmi_AlarmWord[8].4 := AlarmSR[8,4].Q1;
hmi_AlarmWord[8].5 := AlarmSR[8,5].Q1;
hmi_AlarmWord[8].6 := AlarmSR[8,6].Q1;
hmi_AlarmWord[8].7 := AlarmSR[8,7].Q1;
hmi_AlarmWord[8].8 := AlarmSR[8,8].Q1;
hmi_AlarmWord[8].9 := AlarmSR[8,9].Q1;
hmi_AlarmWord[8].10 := AlarmSR[8,10].Q1;
hmi_AlarmWord[8].11 := AlarmSR[8,11].Q1;
hmi_AlarmWord[8].12 := AlarmSR[8,12].Q1;
hmi_AlarmWord[8].13 := AlarmSR[8,13].Q1;
hmi_AlarmWord[8].14 := AlarmSR[8,14].Q1;
hmi_AlarmWord[8].15 := AlarmSR[8,15].Q1;
hmi_AlarmWord[9].0 := AlarmSR[9,0].Q1;
hmi_AlarmWord[9].1 := AlarmSR[9,1].Q1;
hmi_AlarmWord[9].2 := AlarmSR[9,2].Q1;
hmi_AlarmWord[9].3 := AlarmSR[9,3].Q1;
hmi_AlarmWord[9].4 := AlarmSR[9,4].Q1;
hmi_AlarmWord[9].5 := AlarmSR[9,5].Q1;
hmi_AlarmWord[9].6 := AlarmSR[9,6].Q1;
hmi_AlarmWord[9].7 := AlarmSR[9,7].Q1;
hmi_AlarmWord[9].8 := AlarmSR[9,8].Q1;
hmi_AlarmWord[9].9 := AlarmSR[9,9].Q1;
hmi_AlarmWord[9].10 := AlarmSR[9,10].Q1;
hmi_AlarmWord[9].11 := AlarmSR[9,11].Q1;
hmi_AlarmWord[9].12 := AlarmSR[9,12].Q1;
hmi_AlarmWord[9].13 := AlarmSR[9,13].Q1;
hmi_AlarmWord[9].14 := AlarmSR[9,14].Q1;
hmi_AlarmWord[9].15 := AlarmSR[9,15].Q1;
hmi_AlarmWord[10].0 := AlarmSR[10,0].Q1;
hmi_AlarmWord[10].1 := AlarmSR[10,1].Q1;
hmi_AlarmWord[10].2 := AlarmSR[10,2].Q1;
hmi_AlarmWord[10].3 := AlarmSR[10,3].Q1;
hmi_AlarmWord[10].4 := AlarmSR[10,4].Q1;
hmi_AlarmWord[10].5 := AlarmSR[10,5].Q1;
hmi_AlarmWord[10].6 := AlarmSR[10,6].Q1;
hmi_AlarmWord[10].7 := AlarmSR[10,7].Q1;
hmi_AlarmWord[10].8 := AlarmSR[10,8].Q1;
hmi_AlarmWord[10].9 := AlarmSR[10,9].Q1;
hmi_AlarmWord[10].10 := AlarmSR[10,10].Q1;
hmi_AlarmWord[10].11 := AlarmSR[10,11].Q1;
hmi_AlarmWord[10].12 := AlarmSR[10,12].Q1;
hmi_AlarmWord[10].13 := AlarmSR[10,13].Q1;
hmi_AlarmWord[10].14 := AlarmSR[10,14].Q1;
hmi_AlarmWord[10].15 := AlarmSR[10,15].Q1;
hmi_AlarmWord[11].0 := AlarmSR[11,0].Q1;
hmi_AlarmWord[11].1 := AlarmSR[11,1].Q1;
hmi_AlarmWord[11].2 := AlarmSR[11,2].Q1;
hmi_AlarmWord[11].3 := AlarmSR[11,3].Q1;
hmi_AlarmWord[11].4 := AlarmSR[11,4].Q1;
hmi_AlarmWord[11].5 := AlarmSR[11,5].Q1;
hmi_AlarmWord[11].6 := AlarmSR[11,6].Q1;
hmi_AlarmWord[11].7 := AlarmSR[11,7].Q1;
hmi_AlarmWord[11].8 := AlarmSR[11,8].Q1;
hmi_AlarmWord[11].9 := AlarmSR[11,9].Q1;
hmi_AlarmWord[11].10 := AlarmSR[11,10].Q1;
hmi_AlarmWord[11].11 := AlarmSR[11,11].Q1;
hmi_AlarmWord[11].12 := AlarmSR[11,12].Q1;
hmi_AlarmWord[11].13 := AlarmSR[11,13].Q1;
hmi_AlarmWord[11].14 := AlarmSR[11,14].Q1;
hmi_AlarmWord[11].15 := AlarmSR[11,15].Q1;
hmi_AlarmWord[12].0 := AlarmSR[12,0].Q1;
hmi_AlarmWord[12].1 := AlarmSR[12,1].Q1;
hmi_AlarmWord[12].2 := AlarmSR[12,2].Q1;
hmi_AlarmWord[12].3 := AlarmSR[12,3].Q1;
hmi_AlarmWord[12].4 := AlarmSR[12,4].Q1;
hmi_AlarmWord[12].5 := AlarmSR[12,5].Q1;
hmi_AlarmWord[12].6 := AlarmSR[12,6].Q1;
hmi_AlarmWord[12].7 := AlarmSR[12,7].Q1;
hmi_AlarmWord[12].8 := AlarmSR[12,8].Q1;
hmi_AlarmWord[12].9 := AlarmSR[12,9].Q1;
hmi_AlarmWord[12].10 := AlarmSR[12,10].Q1;
hmi_AlarmWord[12].11 := AlarmSR[12,11].Q1;
hmi_AlarmWord[12].12 := AlarmSR[12,12].Q1;
hmi_AlarmWord[12].13 := AlarmSR[12,13].Q1;
hmi_AlarmWord[12].14 := AlarmSR[12,14].Q1;
hmi_AlarmWord[12].15 := AlarmSR[12,15].Q1;
hmi_AlarmWord[13].0 := AlarmSR[13,0].Q1;
hmi_AlarmWord[13].1 := AlarmSR[13,1].Q1;
hmi_AlarmWord[13].2 := AlarmSR[13,2].Q1;
hmi_AlarmWord[13].3 := AlarmSR[13,3].Q1;
hmi_AlarmWord[13].4 := AlarmSR[13,4].Q1;
hmi_AlarmWord[13].5 := AlarmSR[13,5].Q1;
hmi_AlarmWord[13].6 := AlarmSR[13,6].Q1;
hmi_AlarmWord[13].7 := AlarmSR[13,7].Q1;
hmi_AlarmWord[13].8 := AlarmSR[13,8].Q1;
hmi_AlarmWord[13].9 := AlarmSR[13,9].Q1;
hmi_AlarmWord[13].10 := AlarmSR[13,10].Q1;
hmi_AlarmWord[13].11 := AlarmSR[13,11].Q1;
hmi_AlarmWord[13].12 := AlarmSR[13,12].Q1;
hmi_AlarmWord[13].13 := AlarmSR[13,13].Q1;
hmi_AlarmWord[13].14 := AlarmSR[13,14].Q1;
hmi_AlarmWord[13].15 := AlarmSR[13,15].Q1;
hmi_AlarmWord[13].0 := AlarmSR[13,0].Q1;
hmi_AlarmWord[13].1 := AlarmSR[13,1].Q1;
hmi_AlarmWord[13].2 := AlarmSR[13,2].Q1;
hmi_AlarmWord[13].3 := AlarmSR[13,3].Q1;
hmi_AlarmWord[13].4 := AlarmSR[13,4].Q1;
hmi_AlarmWord[13].5 := AlarmSR[13,5].Q1;
hmi_AlarmWord[13].6 := AlarmSR[13,6].Q1;
hmi_AlarmWord[13].7 := AlarmSR[13,7].Q1;
hmi_AlarmWord[13].8 := AlarmSR[13,8].Q1;
hmi_AlarmWord[13].9 := AlarmSR[13,9].Q1;
hmi_AlarmWord[13].10 := AlarmSR[13,10].Q1;
hmi_AlarmWord[13].11 := AlarmSR[13,11].Q1;
hmi_AlarmWord[13].12 := AlarmSR[13,12].Q1;
hmi_AlarmWord[13].13 := AlarmSR[13,13].Q1;
hmi_AlarmWord[13].14 := AlarmSR[13,14].Q1;
hmi_AlarmWord[13].15 := AlarmSR[13,15].Q1;
hmi_AlarmWord[14].0 := AlarmSR[14,0].Q1;
hmi_AlarmWord[14].1 := AlarmSR[14,1].Q1;
hmi_AlarmWord[14].2 := AlarmSR[14,2].Q1;
hmi_AlarmWord[14].3 := AlarmSR[14,3].Q1;
hmi_AlarmWord[14].4 := AlarmSR[14,4].Q1;
hmi_AlarmWord[14].5 := AlarmSR[14,5].Q1;
hmi_AlarmWord[14].6 := AlarmSR[14,6].Q1;
hmi_AlarmWord[14].7 := AlarmSR[14,7].Q1;
hmi_AlarmWord[14].8 := AlarmSR[14,8].Q1;
hmi_AlarmWord[14].9 := AlarmSR[14,9].Q1;
hmi_AlarmWord[14].10 := AlarmSR[14,10].Q1;
hmi_AlarmWord[14].11 := AlarmSR[14,11].Q1;
hmi_AlarmWord[14].12 := AlarmSR[14,12].Q1;
hmi_AlarmWord[14].13 := AlarmSR[14,13].Q1;
hmi_AlarmWord[14].14 := AlarmSR[14,14].Q1;
hmi_AlarmWord[14].15 := AlarmSR[14,15].Q1;
hmi_AlarmWord[15].0 := AlarmSR[15,0].Q1;
hmi_AlarmWord[15].1 := AlarmSR[15,1].Q1;
hmi_AlarmWord[15].2 := AlarmSR[15,2].Q1;
hmi_AlarmWord[15].3 := AlarmSR[15,3].Q1;
hmi_AlarmWord[15].4 := AlarmSR[15,4].Q1;
hmi_AlarmWord[15].5 := AlarmSR[15,5].Q1;
hmi_AlarmWord[15].6 := AlarmSR[15,6].Q1;
hmi_AlarmWord[15].7 := AlarmSR[15,7].Q1;
hmi_AlarmWord[15].8 := AlarmSR[15,8].Q1;
hmi_AlarmWord[15].9 := AlarmSR[15,9].Q1;
hmi_AlarmWord[15].10 := AlarmSR[15,10].Q1;
hmi_AlarmWord[15].11 := AlarmSR[15,11].Q1;
hmi_AlarmWord[15].12 := AlarmSR[15,12].Q1;
hmi_AlarmWord[15].13 := AlarmSR[15,13].Q1;
hmi_AlarmWord[15].14 := AlarmSR[15,14].Q1;
hmi_AlarmWord[15].15 := AlarmSR[15,15].Q1;
hmi_AlarmWord[16].0 := AlarmSR[16,0].Q1;
hmi_AlarmWord[16].1 := AlarmSR[16,1].Q1;
hmi_AlarmWord[16].2 := AlarmSR[16,2].Q1;
hmi_AlarmWord[16].3 := AlarmSR[16,3].Q1;
hmi_AlarmWord[16].4 := AlarmSR[16,4].Q1;
hmi_AlarmWord[16].5 := AlarmSR[16,5].Q1;
hmi_AlarmWord[16].6 := AlarmSR[16,6].Q1;
hmi_AlarmWord[16].7 := AlarmSR[16,7].Q1;
hmi_AlarmWord[16].8 := AlarmSR[16,8].Q1;
hmi_AlarmWord[16].9 := AlarmSR[16,9].Q1;
hmi_AlarmWord[16].10 := AlarmSR[16,10].Q1;
hmi_AlarmWord[16].11 := AlarmSR[16,11].Q1;
hmi_AlarmWord[16].12 := AlarmSR[16,12].Q1;
hmi_AlarmWord[16].13 := AlarmSR[16,13].Q1;
hmi_AlarmWord[16].14 := AlarmSR[16,14].Q1;
hmi_AlarmWord[16].15 := AlarmSR[16,15].Q1;
hmi_AlarmWord[17].0 := AlarmSR[17,0].Q1;
hmi_AlarmWord[17].1 := AlarmSR[17,1].Q1;
hmi_AlarmWord[17].2 := AlarmSR[17,2].Q1;
hmi_AlarmWord[17].3 := AlarmSR[17,3].Q1;
hmi_AlarmWord[17].4 := AlarmSR[17,4].Q1;
hmi_AlarmWord[17].5 := AlarmSR[17,5].Q1;
hmi_AlarmWord[17].6 := AlarmSR[17,6].Q1;
hmi_AlarmWord[17].7 := AlarmSR[17,7].Q1;
hmi_AlarmWord[17].8 := AlarmSR[17,8].Q1;
hmi_AlarmWord[17].9 := AlarmSR[17,9].Q1;
hmi_AlarmWord[17].10 := AlarmSR[17,10].Q1;
hmi_AlarmWord[17].11 := AlarmSR[17,11].Q1;
hmi_AlarmWord[17].12 := AlarmSR[17,12].Q1;
hmi_AlarmWord[17].13 := AlarmSR[17,13].Q1;
hmi_AlarmWord[17].14 := AlarmSR[17,14].Q1;
hmi_AlarmWord[17].15 := AlarmSR[17,15].Q1;
hmi_AlarmWord[18].0 := AlarmSR[18,0].Q1;
hmi_AlarmWord[18].1 := AlarmSR[18,1].Q1;
hmi_AlarmWord[18].2 := AlarmSR[18,2].Q1;
hmi_AlarmWord[18].3 := AlarmSR[18,3].Q1;
hmi_AlarmWord[18].4 := AlarmSR[18,4].Q1;
hmi_AlarmWord[18].5 := AlarmSR[18,5].Q1;
hmi_AlarmWord[18].6 := AlarmSR[18,6].Q1;
hmi_AlarmWord[18].7 := AlarmSR[18,7].Q1;
hmi_AlarmWord[18].8 := AlarmSR[18,8].Q1;
hmi_AlarmWord[18].9 := AlarmSR[18,9].Q1;
hmi_AlarmWord[18].10 := AlarmSR[18,10].Q1;
hmi_AlarmWord[18].11 := AlarmSR[18,11].Q1;
hmi_AlarmWord[18].12 := AlarmSR[18,12].Q1;
hmi_AlarmWord[18].13 := AlarmSR[18,13].Q1;
hmi_AlarmWord[18].14 := AlarmSR[18,14].Q1;
hmi_AlarmWord[18].15 := AlarmSR[18,15].Q1;
hmi_AlarmWord[19].0 := AlarmSR[19,0].Q1;
hmi_AlarmWord[19].1 := AlarmSR[19,1].Q1;
hmi_AlarmWord[19].2 := AlarmSR[19,2].Q1;
hmi_AlarmWord[19].3 := AlarmSR[19,3].Q1;
hmi_AlarmWord[19].4 := AlarmSR[19,4].Q1;
hmi_AlarmWord[19].5 := AlarmSR[19,5].Q1;
hmi_AlarmWord[19].6 := AlarmSR[19,6].Q1;
hmi_AlarmWord[19].7 := AlarmSR[19,7].Q1;
hmi_AlarmWord[19].8 := AlarmSR[19,8].Q1;
hmi_AlarmWord[19].9 := AlarmSR[19,9].Q1;
hmi_AlarmWord[19].10 := AlarmSR[19,10].Q1;
hmi_AlarmWord[19].11 := AlarmSR[19,11].Q1;
hmi_AlarmWord[19].12 := AlarmSR[19,12].Q1;
hmi_AlarmWord[19].13 := AlarmSR[19,13].Q1;
hmi_AlarmWord[19].14 := AlarmSR[19,14].Q1;
hmi_AlarmWord[19].15 := AlarmSR[19,15].Q1;

END_ACTION
END_ACTIONS