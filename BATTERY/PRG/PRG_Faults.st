PROGRAM PRG_Faults
VAR
	BMS_Fault_Word: 			INT := 8; (*Must be first available word number after the ordinary faults*)
	pack: 						INT := 0;
	FaultSR: 					ARRAY[1..20,0..15] OF SR;
	Repeat_Fault: 				fb_RepeatAlarm;
	Reset: 						BOOL;
	CommonAppFault: 			BOOL;
	CommonLevelFault: 			BOOL;
END_VAR

Reset := PRG_Functions.Reset;

CommonAppFault := Repeat_Fault.Alarm_Repeat1 OR Repeat_Fault.Alarm_Repeat3;
CommonLevelFault := Repeat_Fault.Alarm_Repeat2;

(*Common Application Fault*)
FaultSR[1,0] (SET1:=(PRG_BatteryProtection.batteryCommonFault) ,  Q1=>FaultWord[1].0, RESET:=Reset);(*Common Fault from Battery Management System*)
FaultSR[1,1] (SET1:=(NOT PRG_DI.di_FusesOK.PV) ,  Q1=>FaultWord[1].1, RESET:=Reset);(*Line Fuse(s) broken*)
FaultSR[1,2] (SET1:=(NOT PRG_DI.di_LocalEmergencyStop.PV) ,  Q1=>FaultWord[1].2, RESET:=Reset);(*Local Emergency Stop Activated*)
FaultSR[1,3] (SET1:=(NOT PRG_DO.do_ShutdownPlcFailure.PV) ,  Q1=>FaultWord[1].3, RESET:=Reset);(*Fail Safe Shutdown*)
FaultSR[1,4] (SET1:=(NOT PRG_DI.di_DcBreakerEarlyBreak.PV AND PRG_Drive.Status.Running) ,  Q1=>FaultWord[1].4, RESET:=Reset);(*DC Breaker Opened While Running*)
FaultSR[1,5] (SET1:=(PRG_IAS.IAS_FireAlarm) ,  Q1=>FaultWord[1].5, RESET:=Reset);(*Fire Alarm trip from IAS*)
FaultSR[1,6] (SET1:=(PRG_Drive.Status.Fault) ,  Q1=>FaultWord[1].6, RESET:=Reset);(*Vacon Unit -  Common Fault*)
FaultSR[1,7] (SET1:=(PRG_Drive.Status.Commfault) ,  Q1=>FaultWord[1].7, RESET:=Reset);(*Vacon Unit -  Communication Fault*)
FaultSR[1,8] (SET1:=(PRG_Drive.FW2[1].b6_F51_ExternalFault AND PRG_DO.do_ShutdownPlcFailure.PV) ,  Q1=>FaultWord[1].8, RESET:=Reset);(*Remote Emergency Stop*)
FaultSR[1,9] (SET1:=(PRG_BatteryComm.CorvusBMS_Total_Comm_Fault) ,  Q1=>FaultWord[1].9, RESET:=Reset);(*Battery System Total Communication Outage*)
FaultSR[1,10] (SET1:=(NOT PRG_DI.di_RemoteEmergencyStop.PV AND PRG_HMI.enRemoteEstopInput) ,  Q1=>FaultWord[1].10, RESET:=Reset);(*Remote Emergency Stop Activated*)


(*Common Level Fault*)
FaultSR[2,0] (SET1:=(PRG_BatteryProtection.ProtectionTrip_SoC_LL) ,  Q1=>FaultWord[2].0, RESET:=Reset);(*Battery Protection Trip: Low State of Charge*)
FaultSR[2,1] (SET1:=(PRG_BatteryProtection.ProtectionTrip_SoC_HH) ,  Q1=>FaultWord[2].1, RESET:=Reset);(*Battery Protection Trip: High State of Charge*)
FaultSR[2,2] (SET1:=(PRG_BatteryProtection.ProtectionTrip_SoC_LLL) ,  Q1=>FaultWord[2].2, RESET:=Reset);(*Battery Protection Trip: LowLow State of Charge*)
FaultSR[2,3] (SET1:=(PRG_BatteryProtection.ProtectionTrip_Undervoltage) ,  Q1=>FaultWord[2].3, RESET:=Reset);(*Battery Protection Trip: Low Battery Voltage*)
FaultSR[2,4] (SET1:=(PRG_BatteryProtection.ProtectionTrip_Overvoltage) ,  Q1=>FaultWord[2].4, RESET:=Reset);(*Battery Protection Trip: High Battery Voltage*)
FaultSR[2,5] (SET1:=(PRG_BatteryProtection.ProtectionTrip_CellVolt_HH) ,  Q1=>FaultWord[2].5, RESET:=Reset);(*Battery Protection Trip: High Cell Voltage*)
FaultSR[2,6] (SET1:=(PRG_BatteryProtection.ProtectionTrip_CellVolt_LL) ,  Q1=>FaultWord[2].6, RESET:=Reset);(*Battery Protection Trip: Low Cell Voltage*)
FaultSR[2,7] (SET1:=(PRG_BatteryProtection.ProtectionTrip_CellTemp_HH) ,  Q1=>FaultWord[2].7, RESET:=Reset);(*Battery Protection Trip: High Cell Temperature*)
FaultSR[2,8] (SET1:=(PRG_AI.ai_FilterTemperature.Alarm.HHH) ,  Q1=>FaultWord[2].8, RESET:=Reset);(*Filter Temperature High High*)

(*Vacon Drive Faults*)
FaultSR[3,0] (SET1:=(PRG_Drive.FW[1].b0_F1_Overcurrent) ,  Q1=>FaultWord[3].0, RESET:=Reset);(*Vacon Unit -  Over Current Fault*)
FaultSR[3,1] (SET1:=(PRG_Drive.FW[1].b1_F2_OverVoltage) ,  Q1=>FaultWord[3].1, RESET:=Reset);(*Vacon Unit -  Over Voltage Fault*)
FaultSR[3,2] (SET1:=(PRG_Drive.FW[1].b2_F9_UnderVoltage) ,  Q1=>FaultWord[3].2, RESET:=Reset);(*Vacon Unit -  Under Voltage Fault*)
FaultSR[3,3] (SET1:=(PRG_Drive.FW[1].b4_F3_EarthFaultDrive) ,  Q1=>FaultWord[3].3, RESET:=Reset);(*Vacon Unit -  Earth Fault*)
FaultSR[3,4] (SET1:=(PRG_Drive.FW[1].b6_F14_UnitOverTemp) ,  Q1=>FaultWord[3].4, RESET:=Reset);(*Vacon Unit -  Over Temperature Fault*)
FaultSR[3,5] (SET1:=(PRG_Drive.FW[1].b7_F29_ThermistorFault) ,  Q1=>FaultWord[3].5, RESET:=Reset);(*Vacon Unit -  Temperature Measurement Fault*)
FaultSR[3,6] (SET1:=(PRG_Drive.FW[1].b11_F52_KeypadCommFault) ,  Q1=>FaultWord[3].6, RESET:=Reset);(*Vacon Unit -  Keypad Communication Fault*)
FaultSR[3,7] (SET1:=(PRG_Drive.FW[1].b12_F53_FieldbusCommFault) ,  Q1=>FaultWord[3].7, RESET:=Reset);(*Vacon Unit -  Fieldbus Communication Fault*)
FaultSR[3,8] (SET1:=(PRG_Drive.FW[1].b14_F54_SlotCommFault) ,  Q1=>FaultWord[3].8, RESET:=Reset);(*Vacon Unit -  Expansion Slot Communication Fault*)
FaultSR[3,9] (SET1:=(PRG_Drive.FW[1].b15_F50_4mAFault) ,  Q1=>FaultWord[3].9, RESET:=Reset);(*Vacon Unit -  4 mA Fault*)



(*Auto generated alarms from Corvus BMS*)
BMS_Fault_Word := 4; (*Next available faultword*)
FOR pack := 1 TO PRG_HMI.setup_Battery_total_nr_of_packs BY 1 DO
	FaultSR[BMS_Fault_Word,0] (SET1 := (PRG_BatteryComm.CorvusRead[pack].FW.Contactor_Fault), Q1 => FaultWord[BMS_Fault_Word].0, RESET := Reset); 					(*BMS Pack Contactor Fault*)
	FaultSR[BMS_Fault_Word,1] (SET1 := (PRG_BatteryComm.CorvusRead[pack].FW.Deep_OverDischarge_Lockout_Fault), Q1 => FaultWord[BMS_Fault_Word].1, RESET := Reset); 	(*BMS Pack Over Discharge Lockout Fault*)
	FaultSR[BMS_Fault_Word,2] (SET1 := (PRG_BatteryComm.CorvusRead[pack].FW.E_Stop_Active_Fault), Q1 => FaultWord[BMS_Fault_Word].2, RESET := Reset); 				(*BMS Pack E-stop Active*)
	FaultSR[BMS_Fault_Word,3] (SET1 := (PRG_BatteryComm.CorvusRead[pack].FW.Ground_Fault), Q1 => FaultWord[BMS_Fault_Word].3, RESET := Reset); 						(*BMS Pack Ground Fault*)
	FaultSR[BMS_Fault_Word,4] (SET1 := (PRG_BatteryComm.CorvusRead[pack].FW.HVIL_Fault), Q1 => FaultWord[BMS_Fault_Word].4, RESET := Reset); 							(*BMS Pack High Voltage Interlock Loop Open*)
	FaultSR[BMS_Fault_Word,5] (SET1 := (PRG_BatteryComm.CorvusRead[pack].FW.Low_Temp_OverCurrent_Fault), Q1 => FaultWord[BMS_Fault_Word].5, RESET := Reset); 			(*BMS Pack Low Temp. Over Current Fault*)
	FaultSR[BMS_Fault_Word,6] (SET1 := (PRG_BatteryComm.CorvusRead[pack].FW.PDM_OverTemperature_Fault), Q1 => FaultWord[BMS_Fault_Word].6, RESET := Reset); 			(*BMS Pack Over Temperature Fault*)
	FaultSR[BMS_Fault_Word,7] (SET1 := (PRG_BatteryComm.CorvusRead[pack].FW.Repeated_OverCharge_Lockout_Fault), Q1 => FaultWord[BMS_Fault_Word].7, RESET := Reset); 	(*BMS Pack Over Charge Lockout Fault*)
	FaultSR[BMS_Fault_Word,8] (SET1 := (PRG_BatteryComm.CorvusRead[pack].FW.Safety_Shutdown_Fault), Q1 => FaultWord[BMS_Fault_Word].8, RESET := Reset); 				(*BMS Pack Safety Shutdown Fault*)
	FaultSR[BMS_Fault_Word,9] (SET1 := (PRG_BatteryComm.CorvusRead[pack].FW.SE_overTemperature_Fault), Q1 => FaultWord[BMS_Fault_Word].9, RESET := Reset); 			(*BMS Pack Cell Over Temperature Fault*)
	FaultSR[BMS_Fault_Word,10] (SET1 := (PRG_BatteryComm.CorvusRead[pack].FW.SE_overVoltage_Fault), Q1 => FaultWord[BMS_Fault_Word].10, RESET := Reset); 				(*BMS Pack Cell Over Voltage Fault*)
	FaultSR[BMS_Fault_Word,11] (SET1 := (PRG_BatteryComm.CorvusRead[pack].FW.SE_underVoltage_Fault), Q1 => FaultWord[BMS_Fault_Word].11, RESET:=Reset);				(*BMS Pack Cell Under Voltage Fault*)
	BMS_Fault_Word :=  BMS_Fault_Word+1;
END_FOR

(*Blinks the alarm output*)

Repeat_Fault(
	AlarmWord1:= INT_TO_WORD(FaultWord[1]),
	AlarmWord2:= INT_TO_WORD(FaultWord[2]),
	AlarmWord3:= INT_TO_WORD(FaultWord[3]),
	AlarmWord4:= INT_TO_WORD(FaultWord[4]),
	AlarmWord5:= INT_TO_WORD(FaultWord[5]),
	AlarmWord6:= INT_TO_WORD(FaultWord[6]),
	AlarmWord7:= INT_TO_WORD(FaultWord[7]),
	AlarmWord8:= INT_TO_WORD(FaultWord[8]),
	AlarmWord9:= INT_TO_WORD(FaultWord[9]),
	AlarmWord10:= INT_TO_WORD(FaultWord[10]),
	AlarmWord11:= INT_TO_WORD(FaultWord[11]),
	AlarmWord12:= INT_TO_WORD(FaultWord[12]),
	AlarmWord13:= INT_TO_WORD(FaultWord[13]),
	AlarmWord14:= INT_TO_WORD(FaultWord[14]),
	AlarmWord15:= INT_TO_WORD(FaultWord[15]),
	AlarmWord16:= INT_TO_WORD(FaultWord[16]),
	AlarmWord17:= INT_TO_WORD(FaultWord[17]),
	AlarmWord18:= INT_TO_WORD(FaultWord[18]),
	AlarmWord19:= INT_TO_WORD(FaultWord[19]),
	AlarmWord20:= INT_TO_WORD(FaultWord[20]),
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
ACTION hmi_Faults
hmi_FaultWord[1].0 := FaultSR[1,0].Q1;
hmi_FaultWord[1].1 := FaultSR[1,1].Q1;
hmi_FaultWord[1].2 := FaultSR[1,2].Q1;
hmi_FaultWord[1].3 := FaultSR[1,3].Q1;
hmi_FaultWord[1].4 := FaultSR[1,4].Q1;
hmi_FaultWord[1].5 := FaultSR[1,5].Q1;
hmi_FaultWord[1].6 := FaultSR[1,6].Q1;
hmi_FaultWord[1].7 := FaultSR[1,7].Q1;
hmi_FaultWord[1].8 := FaultSR[1,8].Q1;
hmi_FaultWord[1].9 := FaultSR[1,9].Q1;
hmi_FaultWord[1].10 := FaultSR[1,10].Q1;
hmi_FaultWord[1].11 := FaultSR[1,11].Q1;
hmi_FaultWord[1].12 := FaultSR[1,12].Q1;
hmi_FaultWord[1].13 := FaultSR[1,13].Q1;
hmi_FaultWord[1].14 := FaultSR[1,14].Q1;
hmi_FaultWord[1].15 := FaultSR[1,15].Q1;
hmi_FaultWord[2].0 := FaultSR[2,0].Q1;
hmi_FaultWord[2].1 := FaultSR[2,1].Q1;
hmi_FaultWord[2].2 := FaultSR[2,2].Q1;
hmi_FaultWord[2].3 := FaultSR[2,3].Q1;
hmi_FaultWord[2].4 := FaultSR[2,4].Q1;
hmi_FaultWord[2].5 := FaultSR[2,5].Q1;
hmi_FaultWord[2].6 := FaultSR[2,6].Q1;
hmi_FaultWord[2].7 := FaultSR[2,7].Q1;
hmi_FaultWord[2].8 := FaultSR[2,8].Q1;
hmi_FaultWord[2].9 := FaultSR[2,9].Q1;
hmi_FaultWord[2].10 := FaultSR[2,10].Q1;
hmi_FaultWord[2].11 := FaultSR[2,11].Q1;
hmi_FaultWord[2].12 := FaultSR[2,12].Q1;
hmi_FaultWord[2].13 := FaultSR[2,13].Q1;
hmi_FaultWord[2].14 := FaultSR[2,14].Q1;
hmi_FaultWord[2].15 := FaultSR[2,15].Q1;
hmi_FaultWord[3].0 := FaultSR[3,0].Q1;
hmi_FaultWord[3].1 := FaultSR[3,1].Q1;
hmi_FaultWord[3].2 := FaultSR[3,2].Q1;
hmi_FaultWord[3].3 := FaultSR[3,3].Q1;
hmi_FaultWord[3].4 := FaultSR[3,4].Q1;
hmi_FaultWord[3].5 := FaultSR[3,5].Q1;
hmi_FaultWord[3].6 := FaultSR[3,6].Q1;
hmi_FaultWord[3].7 := FaultSR[3,7].Q1;
hmi_FaultWord[3].8 := FaultSR[3,8].Q1;
hmi_FaultWord[3].9 := FaultSR[3,9].Q1;
hmi_FaultWord[3].10 := FaultSR[3,10].Q1;
hmi_FaultWord[3].11 := FaultSR[3,11].Q1;
hmi_FaultWord[3].12 := FaultSR[3,12].Q1;
hmi_FaultWord[3].13 := FaultSR[3,13].Q1;
hmi_FaultWord[3].14 := FaultSR[3,14].Q1;
hmi_FaultWord[3].15 := FaultSR[3,15].Q1;
hmi_FaultWord[4].0 := FaultSR[4,0].Q1;
hmi_FaultWord[4].1 := FaultSR[4,1].Q1;
hmi_FaultWord[4].2 := FaultSR[4,2].Q1;
hmi_FaultWord[4].3 := FaultSR[4,3].Q1;
hmi_FaultWord[4].4 := FaultSR[4,4].Q1;
hmi_FaultWord[4].5 := FaultSR[4,5].Q1;
hmi_FaultWord[4].6 := FaultSR[4,6].Q1;
hmi_FaultWord[4].7 := FaultSR[4,7].Q1;
hmi_FaultWord[4].8 := FaultSR[4,8].Q1;
hmi_FaultWord[4].9 := FaultSR[4,9].Q1;
hmi_FaultWord[4].10 := FaultSR[4,10].Q1;
hmi_FaultWord[4].11 := FaultSR[4,11].Q1;
hmi_FaultWord[4].12 := FaultSR[4,12].Q1;
hmi_FaultWord[4].13 := FaultSR[4,13].Q1;
hmi_FaultWord[4].14 := FaultSR[4,14].Q1;
hmi_FaultWord[4].15 := FaultSR[4,15].Q1;
hmi_FaultWord[5].0 := FaultSR[5,0].Q1;
hmi_FaultWord[5].1 := FaultSR[5,1].Q1;
hmi_FaultWord[5].2 := FaultSR[5,2].Q1;
hmi_FaultWord[5].3 := FaultSR[5,3].Q1;
hmi_FaultWord[5].4 := FaultSR[5,4].Q1;
hmi_FaultWord[5].5 := FaultSR[5,5].Q1;
hmi_FaultWord[5].6 := FaultSR[5,6].Q1;
hmi_FaultWord[5].7 := FaultSR[5,7].Q1;
hmi_FaultWord[5].8 := FaultSR[5,8].Q1;
hmi_FaultWord[5].9 := FaultSR[5,9].Q1;
hmi_FaultWord[5].10 := FaultSR[5,10].Q1;
hmi_FaultWord[5].11 := FaultSR[5,11].Q1;
hmi_FaultWord[5].12 := FaultSR[5,12].Q1;
hmi_FaultWord[5].13 := FaultSR[5,13].Q1;
hmi_FaultWord[5].14 := FaultSR[5,14].Q1;
hmi_FaultWord[5].15 := FaultSR[5,15].Q1;
hmi_FaultWord[6].0 := FaultSR[6,0].Q1;
hmi_FaultWord[6].1 := FaultSR[6,1].Q1;
hmi_FaultWord[6].2 := FaultSR[6,2].Q1;
hmi_FaultWord[6].3 := FaultSR[6,3].Q1;
hmi_FaultWord[6].4 := FaultSR[6,4].Q1;
hmi_FaultWord[6].5 := FaultSR[6,5].Q1;
hmi_FaultWord[6].6 := FaultSR[6,6].Q1;
hmi_FaultWord[6].7 := FaultSR[6,7].Q1;
hmi_FaultWord[6].8 := FaultSR[6,8].Q1;
hmi_FaultWord[6].9 := FaultSR[6,9].Q1;
hmi_FaultWord[6].10 := FaultSR[6,10].Q1;
hmi_FaultWord[6].11 := FaultSR[6,11].Q1;
hmi_FaultWord[6].12 := FaultSR[6,12].Q1;
hmi_FaultWord[6].13 := FaultSR[6,13].Q1;
hmi_FaultWord[6].14 := FaultSR[6,14].Q1;
hmi_FaultWord[6].15 := FaultSR[6,15].Q1;
hmi_FaultWord[7].0 := FaultSR[7,0].Q1;
hmi_FaultWord[7].1 := FaultSR[7,1].Q1;
hmi_FaultWord[7].2 := FaultSR[7,2].Q1;
hmi_FaultWord[7].3 := FaultSR[7,3].Q1;
hmi_FaultWord[7].4 := FaultSR[7,4].Q1;
hmi_FaultWord[7].5 := FaultSR[7,5].Q1;
hmi_FaultWord[7].6 := FaultSR[7,6].Q1;
hmi_FaultWord[7].7 := FaultSR[7,7].Q1;
hmi_FaultWord[7].8 := FaultSR[7,8].Q1;
hmi_FaultWord[7].9 := FaultSR[7,9].Q1;
hmi_FaultWord[7].10 := FaultSR[7,10].Q1;
hmi_FaultWord[7].11 := FaultSR[7,11].Q1;
hmi_FaultWord[7].12 := FaultSR[7,12].Q1;
hmi_FaultWord[7].13 := FaultSR[7,13].Q1;
hmi_FaultWord[7].14 := FaultSR[7,14].Q1;
hmi_FaultWord[7].15 := FaultSR[7,15].Q1;
hmi_FaultWord[8].0 := FaultSR[8,0].Q1;
hmi_FaultWord[8].1 := FaultSR[8,1].Q1;
hmi_FaultWord[8].2 := FaultSR[8,2].Q1;
hmi_FaultWord[8].3 := FaultSR[8,3].Q1;
hmi_FaultWord[8].4 := FaultSR[8,4].Q1;
hmi_FaultWord[8].5 := FaultSR[8,5].Q1;
hmi_FaultWord[8].6 := FaultSR[8,6].Q1;
hmi_FaultWord[8].7 := FaultSR[8,7].Q1;
hmi_FaultWord[8].8 := FaultSR[8,8].Q1;
hmi_FaultWord[8].9 := FaultSR[8,9].Q1;
hmi_FaultWord[8].10 := FaultSR[8,10].Q1;
hmi_FaultWord[8].11 := FaultSR[8,11].Q1;
hmi_FaultWord[8].12 := FaultSR[8,12].Q1;
hmi_FaultWord[8].13 := FaultSR[8,13].Q1;
hmi_FaultWord[8].14 := FaultSR[8,14].Q1;
hmi_FaultWord[8].15 := FaultSR[8,15].Q1;
hmi_FaultWord[9].0 := FaultSR[9,0].Q1;
hmi_FaultWord[9].1 := FaultSR[9,1].Q1;
hmi_FaultWord[9].2 := FaultSR[9,2].Q1;
hmi_FaultWord[9].3 := FaultSR[9,3].Q1;
hmi_FaultWord[9].4 := FaultSR[9,4].Q1;
hmi_FaultWord[9].5 := FaultSR[9,5].Q1;
hmi_FaultWord[9].6 := FaultSR[9,6].Q1;
hmi_FaultWord[9].7 := FaultSR[9,7].Q1;
hmi_FaultWord[9].8 := FaultSR[9,8].Q1;
hmi_FaultWord[9].9 := FaultSR[9,9].Q1;
hmi_FaultWord[9].10 := FaultSR[9,10].Q1;
hmi_FaultWord[9].11 := FaultSR[9,11].Q1;
hmi_FaultWord[9].12 := FaultSR[9,12].Q1;
hmi_FaultWord[9].13 := FaultSR[9,13].Q1;
hmi_FaultWord[9].14 := FaultSR[9,14].Q1;
hmi_FaultWord[9].15 := FaultSR[9,15].Q1;
hmi_FaultWord[10].0 := FaultSR[10,0].Q1;
hmi_FaultWord[10].1 := FaultSR[10,1].Q1;
hmi_FaultWord[10].2 := FaultSR[10,2].Q1;
hmi_FaultWord[10].3 := FaultSR[10,3].Q1;
hmi_FaultWord[10].4 := FaultSR[10,4].Q1;
hmi_FaultWord[10].5 := FaultSR[10,5].Q1;
hmi_FaultWord[10].6 := FaultSR[10,6].Q1;
hmi_FaultWord[10].7 := FaultSR[10,7].Q1;
hmi_FaultWord[10].8 := FaultSR[10,8].Q1;
hmi_FaultWord[10].9 := FaultSR[10,9].Q1;
hmi_FaultWord[10].10 := FaultSR[10,10].Q1;
hmi_FaultWord[10].11 := FaultSR[10,11].Q1;
hmi_FaultWord[10].12 := FaultSR[10,12].Q1;
hmi_FaultWord[10].13 := FaultSR[10,13].Q1;
hmi_FaultWord[10].14 := FaultSR[10,14].Q1;
hmi_FaultWord[10].15 := FaultSR[10,15].Q1;

END_ACTION
END_ACTIONS
