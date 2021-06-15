PROGRAM PRG_HMI
VAR

	FirstCycle : 	BOOL := TRUE;
	i : 			INT; (*Looping variable*)
	(*Imported structs from other programs for shorthand use*)
	CorvusRead: 	ARRAY[1..16] OF str_Corvus_ALL;	(*All BMS data*)
	M : 			INT; (*Array master*)
	(*----------------------------------------------------------------------------------------------------------------*)
	
	
	(*Digital Mimics, statuses etc*)
		DcBusEnergized: 	BOOL;	(*Voltage present on DC-bus, used for green color indication*)
		DcBreakerClosed: 	BOOL; 	(*DC breaker is closed*)
		DcBreakerAlarm: 	BOOL;	(*DC breaker alarm, position feedback deviation*)
		DcBreakerLocal: 	BOOL; 	(*Breaker is in local mode*)
		BatteryCharging: 	BOOL; 	(*Power is flowing into battery*)
		
		SystemRunning:		BOOL;	(*System is in running state*)
		DriveRunning: 		BOOL;	(*Converter unit is in run mode*)
		ReadyToStart: 		BOOL; 	(*True when all start inhibits are false*)
		
		BatteryConnected: 	BOOL;	(*One or more battery contactors are closed*)
		CoolingFansRunning: BOOL;	(*Cooling Fans are Running*)
		InLimit: 			BOOL;	(*One or more limits are in effect*)
		CommonWarning: 		BOOL;	(*One or more warnings are active*)
		CommonFault: 		BOOL;	(*One or more faults are active*)
		StartInhibit: 		BOOL;	(*One or more start inhibits are active*)
		DriveFault:			BOOL;	(*Common fault from Vacon*)
		BatteryFault: 		BOOL;	(*Battery is in fault mode*)
		FuseBroken: 		BOOL;	(*Fuse(s) is broken*)
		LowSoC: 			BOOL;	(*Low State of Charge Alarm*)
		CommunicationFault: BOOL;	(*Common Communication Fault*)
		
		OtherSourcesOnBus: 		BOOL;	(*True if other power sources are present on the bus*)
		ChargeLimitActive : 	BOOL;	(*Charge limit is active*)
		DischargeLimitActive : 	BOOL;	(*Discharge limit is active*)
		
		StartInhibit0:			BOOL;	(*Start inhibit bit 1*)
		StartInhibit1:			BOOL;	(*Start inhibit bit 2*)
		StartInhibit2:			BOOL;	(*Start inhibit bit 3*)
		StartInhibit3:			BOOL;	(*Start inhibit bit 4*)
		StartInhibit4:			BOOL;	(*Start inhibit bit 5*)
		StartInhibit5:			BOOL;	(*Start inhibit bit 6*)
		StartInhibit6:			BOOL;	(*Start inhibit bit 8*)
		StartInhibit7:			BOOL;	(*Start inhibit bit 9*)
		
	(*Enums*)
		State: 			enum_State;					(*Init:=0, 1=Stopped, 2=Starting, 3=Running, 4=Stopping*)
		ControlPlace: 	enum_ControlPlace;			(**)
		ControlMode: 	INT;						(*PMS Control mode from IAS*)
		
		Version:		STRING(60);		(*Version Number*)	
		CommitHash:		STRING(7);		(*Commit hash this is built by*)
		PrechargeStatus: DINT := 0;		(*Corvus Precharge Status: 0 No Data. 1  Ready. 2  Pre-charging. 3  Finished. 4  Timed-out, retry ready. 5  Timed-out, cooling down. 6  Over temperature, cooling down*)
		
	(* Analog values without limit or min/max values*)
		BMS_SoH: 						DINT;	(*Online State of Health*)
		BMS_nrOfPacksInArray: 			DINT;	(*Number of packs configured in this array*)
		BMS_nrOfPackInNetwork: 			DINT;	(*Number of packs configured in this network*)
		BMS_nrOfPackConnected: 			DINT;	(*Number of packs in the array where the battery contactor is closed*)
		BMS_nrOfPackFault: 				DINT;	(*Number of faulted packs in the array*)
		BMS_maxUnconnectPackVoltage: 	DINT;	(*Highest pack voltage amongst the unconnected packs in the array*)
		BMS_minUnconnectPackVoltage:	DINT;	(*Lowest pack voltage amongst the unconnected packs in the array*)
		BMS_DischargeLimit_eng: 		DINT;
		BMS_ChargeLimit_eng: 			DINT;
		ChargeLimitComped_eng:			REAL;	(*Compensated and used current limit to drive (before re-scaling)*)
		DischargeLimitComped_eng:		REAL;	(*Compensated and used current limit to drive (before re-scaling)*)
		MinutesRemaining: 				REAL;	(*Minutes remaining til either 100% charge or disconnect SoC level*)
		EnergyRemaining: 				REAL;	(*Remaining kWh unntil automatic disconnection*)
		StartingTimeRemaining: 			TIME;	(*Time remaining of starting process*)
		VaconChargeCurrentLimit:		REAL;
		VaconDischargeCurrentLimit:		REAL;
		VaconOverVoltageRef:			REAL;
		VaconUnderVoltageRef:			REAL;
	
		CpuTemp : 						REAL;	(*CPU/TempCelcius*)
		CpuLoad : 						REAL;	(*CPU/UsageLast1s*)
		MemFreeAppPart02 : 				REAL;	(*Mem/AppPart02/Free*)
		MemFreeGlobPart : 				REAL;	(*Mem/GlobPart/Free*)
		MemFreeSysPart : 				REAL;	(*Mem/SysPart/Free*)
		Eth0kbps:						REAL;
		Eth1kbps:						REAL;
		Em0kbps:						REAL;
	
	(*Structs containing scaling and PV for non-hardwire AO-signals displayed in the HMI as bar mimics etc*)
	(*----------------------------------------------------------------------------------------------------------------*)
		(*Battery Bank*)
		BMS_SoC: str_HmiScale;								(*Online State of Charge*)
		BMS_MaxCellTemp: str_HmiScale;						(*Online Maximum Cell Temperature in degC*)
		BMS_MinCellTemp: str_HmiScale;						(*Online Minimum Cell Temperature in degC*)
		BMS_MaxCellVolt: str_HmiScale;						(*Online Maximum Cell Voltage in mV*)
		BMS_MinCellVolt: str_HmiScale;						(*Online Minimum Cell Voltage in mV*)
		BMS_MaxChargeCurrent: str_HmiScale;					(*Max Charge Current in A*)
		BMS_MaxDischargeCurrent: str_HmiScale;				(*Max Discharge Current in A*)
		BMS_MaxOfflinePackVolt: str_HmiScale;				(*Highest voltage in offline pack*)
		BMS_MinOfflinePackVolt: str_HmiScale;				(*Lowest voltage in offline pack*)
		BMS_BusCurrent: str_HmiScale;						(*Battery current in A*)
		BMS_PackCurrent: ARRAY[1..16] OF str_HmiScale;		(*Pack current in A*)
		BMS_BusVoltage: str_HmiScale;						(*Battery voltage in VDC*)
		BMS_BusPower: str_HmiScale;							(*Battery power in kW. Positive equals charging.*)
		BMS_PacksConnected: str_HmiScale;					(*Nr of packs connected in the array*)
		(*Values to instruments*)
		Instr_BatteryChargeDischargeCurrent_pc: 	REAL;	(*Battery charge or discharge current in percent of sourcenominalcurrent*)
		Instr_BatteryVoltage_pc: 					REAL;	(*Battery voltage in percent of range between min and max source voltage*)
		Instr_BatteryPower_pc: 						REAL;	(*Battery power in percent of sourcenompower*)
		Instr_BatteryCurrent_pc: 					REAL;	(*Battery current in percent of sourcenominalcurrent*)
		Instr_BatterySoC_pc:						REAL;	(*Battery State of Charge in percent*)
		Instr_BatteryChargeDischargeCurrent_eng: 	REAL;	(*Battery charge or discharge current in Ampere*)
		Instr_BatteryVoltage_eng: 					REAL;	(*Battery voltage in volt*)
		Instr_BatteryPower_eng: 					REAL;	(*Battery power in kilowatt*)
		Instr_BatteryCurrent_eng: 					REAL;	(*Battery current in ampere*)
		Instr_BatterySoC_eng:						REAL;	(*Battery State of Charge in kWh*)	
		ChargingLampStatus: 	BOOL; (*Lamp output status*)
		FaultLampStatus: 		BOOL; (*Lamp output status*)
		WarningLampStatus: 		BOOL; (*Lamp output status*)
		LocalLampStatus: 		BOOL; (*Lamp output status*)
		StoppedLampStatus: 		BOOL; (*Lamp output status*)
		ReadyLamp_Status: 		BOOL; (*Lamp output status*)
		RunningLamp_Status: 	BOOL; (*Lamp output status*)
		EnergizedLamp_Status: 	BOOL; (*Lamp output status*)

		(*Drive*)
		Drive_DCLink: 			str_HmiScale;
		Drive_ActivePower_eng: 	str_HmiScale;
		Drive_ActivePower_pc: 	str_HmiScale;
		Drive_Temp: 			str_HmiScale;
		Drive_TotalCurrent: 	str_HmiScale;
		CabinetTemp: 			str_HmiScale;
		
		(*Limiter and regulator*)
		Reference : str_HmiScale;	(*Shows the current voltage reference and the over/under voltage reference around it*)
		Limiter : str_HmiScale;		(*Shows current drive amps and current limits*)
		ReferenceActual : INT;		(*Actual desired voltage reference from user/pms*)
	

	(*User inputs from HMI*)
	(*----------------------------------------------------------------------------------------------------------------*)
		(*Digital Inputs from HMI*)
		TestStartingTimeout : 			BOOL:=FALSE;	(*Used to provoke a starting timeout for testing etc.*)
		TestStartingTimeout_TON : 		TON;			(*Timeout to autoreset starting timeout prevention*)
		TestStartingTimeoutTimeLeft : 	TIME;			(*Show time remaining to HMI*)
		TestStoppingTimeout: 			BOOL:=FALSE;	(*Used to provoke a stopping timeout for testing etc.*)
		TestStoppingTimeout_TON : 		TON;			(*Timeout to autoreset stopping timeout prevention*)
		TestStoppingTimeoutTimeLeft : 	TIME;			(*Show time remaining to HMI*)
		OverrideStartVoltageDcLink : 	BOOL:=FALSE;	(*Used to enable Battery Precharge with dead DC link*)
		OverrideStartVoltageDcLink_TON : 	TON;		(*Timer to automatically deactivate override mode*)
		OverrideStartVoltageDcLinkTimeLeft:	TIME;		(*Time left of override mode*)
		RetainExportCmd :				BOOL;			(*Trigger export of retain memory into folder RetainExport/filename*)
		
		SOHVerifMode_Request: 		BOOL;	(*Request from operator to enter SoH Verification Mode*)
		SoH_Verif_TimeRemaining: 	INT;	(*Time remaining to automatic disabling of InSOHVerifMode*)
		select_pack1: BOOL;					(*Select Pack for connection*)
		select_pack2: BOOL;					(*Select Pack for connection*)
		select_pack3: BOOL;					(*Select Pack for connection*)
		select_pack4: BOOL;					(*Select Pack for connection*)
		select_pack5: BOOL;					(*Select Pack for connection*)
		select_pack6: BOOL;					(*Select Pack for connection*)
		select_pack7: BOOL;					(*Select Pack for connection*)
		select_pack8: BOOL;					(*Select Pack for connection*)
		select_pack9: BOOL;					(*Select Pack for connection*)
		select_pack10: BOOL;				(*Select Pack for connection*)
		select_pack11: BOOL;				(*Select Pack for connection*)
		select_pack12: BOOL;				(*Select Pack for connection*)
		select_pack13: BOOL;				(*Select Pack for connection*)
		select_pack14: BOOL;				(*Select Pack for connection*)
		select_pack15: BOOL;				(*Select Pack for connection*)
		select_pack16: BOOL;				(*Select Pack for connection*)
		
		
		(*State of Health verification mode*)
		SoHVerifModeActive : 		BOOL;				(*User activated by HMI*)
		SoHVerifTimer : 			DINT := 12;			(*Default time is 12 hours*)
		SoHVerifCountdown :			DINT;				(*The countdown in seconds*)
		SoHChargeDischargeRate : 	REAL:=0.5;			(*Max charge and discharge rate in C*)
		SoHVerifModeActiveFT: 		F_TRIG;				(*Automatic disable when timer runs out*)
		SoHVerifTOF: 				TOF;				(*Timer to keep SoH mode active*)
		SoHVerifModeActiveRT: 		R_TRIG;				(*Trigger to start timer*)
		
		(*Lamp Test*)
		LamptestPulsetrain: 	fb_PulseTrain; 	(*Pulse train for lamp test output*)
		LamptestTOF:			TOF;			(*Duration of lamp test*)
		Lamptest:				BOOL;			(*Lamp test activation bit*)
		LamptestIndication :	BOOL;			(*Indication of lamp test is active*)
		
		(*User defined values for BMS charge/discharge current limit*)
		DischargeCurrentLimit_scale : 		str_HmiScale;	(*Simulate stricter discharge current level for testing*)
		ChargeCurrentLimit_scale : 			str_HmiScale;	(*Simulate stricter charge current level for testing*)
		ChargeDischargeCurrentTime : 		TIME;			(*Automatic timeout for simulation of stricter current limits*)
		ChargeCurrentLimitTest : 			DINT;			(*Used to input lower charge limit for testing purposes *)
		DischargeCurrentLimitTest : 		DINT;			(*Used to input lower discharge limit for testing purposes *)
		ChargeDischargeCurrentTestActive: 	BOOL;			(*Used to activate the charge/discharge current limits*)
		ChargeDischargeCurrent_TON: 		TON;			(*Timeout timer*)
		
		(*Variables used for indications of trip levels and stuff*)
		Indicate_BattVolt_HH_Timer : 	BOOL;	(*Indication that Battery over voltage trip timer is running*)
		Indicate_BattVolt_HH_Trip : 	BOOL;	(*Indicatio that Battery over voltage trip has occurred*)
		Indicate_BattVolt_LL_Timer : 	BOOL;	(*Indication that Battery under voltage trip timer is running*)
		Indicate_BattVolt_LL_Trip : 	BOOL;	(*Indication that Battery under voltage trip has occurred*)
		Indicate_SoC_HH_Timer : 		BOOL;	(*Indication that SoC over charge trip timer is running*)
		Indicate_SoC_HH_Trip :			BOOL;	(*Indication that SoC over charge trip has occurred*)
		Indicate_SoC_LL_Timer : 		BOOL;	(*Indication that SoC under charge trip timer is running*)
		Indicate_SoC_LL_Trip : 			BOOL;	(*Indication that SoC under charge trip has occurred*)
		Indicate_CellVolt_HH_Timer : 	BOOL;	(*Indication that cell over voltage trip timer is running*)
		Indicate_CellVolt_HH_Trip : 	BOOL;	(*Indication that cell over voltage has occurred*)
		Indicate_CellVolt_LL_Timer : 	BOOL;	(*Indication that cell under voltage trip timer is running*)
		Indicate_CellVolt_LL_Trip : 	BOOL;	(*Indication that cell under voltage trip has occurred*)
		Indicate_CellTemp_HH_Timer : 	BOOL;	(*Indication that cell over temp trip timer is running*)
		Indicate_CellTemp_HH_Trip : 	BOOL;	(*Indication that cell over temp trip has occurred*)
		
		Reset:							BOOL;	(*Reset button from hmi*)
		ResetTON:						TON;	(*TON to turn of reset in case HMI is unable to*)
		
		RestoreProtection : 			BOOL;	(*Used to set protection values back to default*)
END_VAR

VAR RETAIN (*Settings from HMI*)

	DoorSettings:			str_HmiDoorSettings;	(*Enable bits for instruments and buttons/lights in door*)
	SetupIasCom:        	str_IasWdUint;			(*IAS Communication setup*)
	SetupBatLimits:			str_BatterySetup;		(*Protection limits for batteries*)
	DriveSettings : 		str_DriveSettings_DcDc; (*Nominal Values and settings*)
	IncDecSetup:			str_incdecSetup;		(*Configuration of the inc/dec function in Operation*)
	NetStormSetup :			str_NetStormSetup;		(*Configure alarm levels and such for net storm detection*)
	(*User Settings*)		
	Setup_StopWithRampMaxLoad_pc : 		REAL; 	(*Direct stop without ramping if load is less than this value in pu*)
	Delay_StartingTimeOut : 			REAL;	(*Give up starting the system after this delay after start command*)
	Delay_StoppingTimeOut : 			REAL;	(*Panic stop and give up normal stopping after this delay after stop command*)
	MinStartVoltageDcLink :				REAL;	(*The DC link voltage must be at least this before start permission is given*)
	setup_Battery_total_nr_of_packs : 	INT; 	(*Number of packs/strings/racks in the battery array*)
	setup_Battery_First_Card_Nr :		INT;	(*First card number for modbus card to corvus orca*)
	
	setup_Drive_PnMasterCardNr :		ARRAY[1..4] OF DINT;	(*Vacon Profinet Card number in Solution Center*)
	enPowerSaveMode:					BOOL;	(*Enable the Corvus Orca Power Save Function*)
	enEthernetSwitchAlarm:				BOOL;	(*Enable external ethernet switch alarm*)
	enRemoteEstopInput:					BOOL;	(*Enable remote emergency stop digital input*)
	Delay_EnterPowerSaveMode :			REAL;	(*Put batteries in power save mode after this number of hours after use*)
	
	setup_AioCard1_Number :				INT;	(*Aio Card Module Number from Solution Center*)
	setup_DioCard1_Number :				INT;	(*Aio Card Module Number from Solution Center*)
	
	
	RetainSet: BOOL;	(*If Retain memory is not set, use this flag to configure initial values*)
END_VAR

	(* 
	 * ======================================================================================================================================= 
	 * Settings from HMI - Validate and limit inputs to prevent disaster
	 * =======================================================================================================================================
	*)
	
	Setup_StopWithRampMaxLoad_pc :=			LIMIT(4,Setup_StopWithRampMaxLoad_pc, 100);
	Delay_EnterPowerSaveMode;
	Delay_StartingTimeOut :=				LIMIT(0,Delay_StartingTimeOut,300);
	Delay_StoppingTimeOut :=				LIMIT(0,Delay_StoppingTimeOut,300);
	MinStartVoltageDcLink :=				LIMIT(900, MinStartVoltageDcLink, 1000);
	setup_Battery_total_nr_of_packs := 		LIMIT(1,setup_Battery_total_nr_of_packs, 16); 
	setup_Battery_First_Card_Nr := 			LIMIT(1,setup_Battery_First_Card_Nr, 9999);
	setup_Drive_PnMasterCardNr[1] := 		LIMIT(1,setup_Drive_PnMasterCardNr[1], 65536);
	setup_AioCard1_Number :=				LIMIT(0,setup_AioCard1_Number, 999); 
	setup_DioCard1_Number :=				LIMIT(0,setup_DioCard1_Number, 999);
	
	IncDecSetup.RefMax_eng := 				LIMIT(IncDecSetup.RefZero_eng+1,	IncDecSetup.RefMax_eng,		setup_IncDecUpperLimit);
	IncDecSetup.RefZero_eng :=				LIMIT(IncDecSetup.RefMin_eng+1,		IncDecSetup.RefZero_eng,	IncDecSetup.RefMax_eng-1);
	IncDecSetup.RefMin_eng :=				LIMIT(setup_IncDecLowerLimit,		IncDecSetup.RefMin_eng, 	IncDecSetup.RefZero_eng-1);
	IncDecSetup.StepSize_eng :=				LIMIT(1,							IncDecSetup.StepSize_eng,	(setup_IncDecUpperLimit-setup_IncDecLowerLimit)/10); (*Step size is mini 1 and max 10% of range between min and max*)
	IncDecSetup.ResetSpeed :=				LIMIT(50,							IncDecSetup.ResetSpeed, 	20000);
	IncDecSetup.StepSpeed :=				LIMIT(50,							IncDecSetup.StepSpeed,		20000); (*Ramp speed between 50 and 20 000 ms*)
	IncDecSetup.en_HoldIncDec;

(* Configure retain memory if not set  -  Does not re-write hardwire configuration *)
IF (NOT RetainSet) THEN	
	(*Setup Variables*)
	setup_Battery_total_nr_of_packs := 	1; 		(*Let's have at least one battery pack...*)
	setup_Battery_First_Card_Nr :=		999;	(*Module Number of First battery modbus card in solution center*)
	Setup_StopWithRampMaxLoad_pc := 	10; 	(*Direct stop without ramping if load is less than this value in percent*)
	setup_Drive_PnMasterCardNr[1] :=	9999;	(*Default value when not set*)
	setup_AioCard1_Number :=			0;		(*Default Module/Card number when not set*)
	setup_DioCard1_Number :=			0;		(*Default Module/Card number when not set*)
	Delay_StartingTimeOut := 			120; 	(*Give up starting the system after this delay after start command*)
	Delay_StoppingTimeOut := 			60; 	(*Panic stop and give up normal stopping after this delay after stop command*)
	Delay_EnterPowerSaveMode := 		24;		(*Put batteries in power save mode after this many hours after use*)
	IncDecSetup.RefMax_eng := 			1050 ;	(*Highest limit for over voltage regulator*)
	IncDecSetup.RefZero_eng := 			1000 ;	(*Default nominal value for voltage regulator*)
	IncDecSetup.RefMin_eng := 			950 ;	(*Lowest limit for voltage regulator*)
	IncDecSetup.ResetSpeed :=			500 ;	(*Default reset speed in ms*)
	IncDecSetup.StepSpeed :=			250 ;	(*Default step speed in ms*)
	IncDecSetup.StepSize_eng :=			1.0;	(*Default step size*)
	
	DriveSettings.AmpereScalingFactor :=	1;		(*For small drives, ampere is given with one decimal. If so, scaling factor is 10*)
	DriveSettings.NominalDcLinkVoltage := 	931;	(*Vacon's nominal DC Voltage, typically 931 V*)
	DriveSettings.NumberOfDrives := 		1;		(*Number of drives in Drive Synch (master-follower)*)
	DriveSettings.SourceMaxVoltage :=		1008;	(*Rated maximum voltage for batteries*)
	DriveSettings.SourceMinVoltage := 		720;	(*Rated minimum voltage for batteries*)
	DriveSettings.SourceNomCurrent := 		500;	(*Vacon Drive ID113*)
	DriveSettings.SourceNomPower := 		500;	(*Vacon Drive ID116*)
	DriveSettings.SourceNomVoltage := 		950;	(*Vacon Drive ID110*)
	DriveSettings.UnitTempAlarmDelay := 	T#5s;	(*Delay before issuing vacon temperature alarm*)
	DriveSettings.UnitTempAlarmLevel := 	60;		(*Limit for temperature alarm for Vacon unit temp*)

	RetainSet := 							TRUE;	(*Remember that this is actually done*)
	RestoreProtection := 					TRUE; 	(*set protection values*)
END_IF

(* Import variables from other programs for shorthand use*)
CorvusRead := PRG_BatteryComm.CorvusRead;
M := PRG_BatteryComm.M;
Version := PRG_Functions.Version.Version;
CommitHash := PRG_Functions.LastCommit.LastCommitFull;





(* 
 * ======================================================================================================================================= 
 * Status Screen 
 * =======================================================================================================================================
*)


(*Digital Values*)
DcBusEnergized := 		FALSE; (*Unknown value as program doesnt have reading from DC bus*)
DcBreakerAlarm := 		PRG_Functions.Breaker.Alarm_inst;
DcBreakerClosed := 		PRG_Functions.Breaker.DI_Verif_delay;
DcBreakerLocal := 		FALSE;
DriveRunning := 		PRG_Drive.Status.Running;
BatteryCharging := 		PRG_Battery.batteryCharging;

ReadyToStart := 		PRG_StateMain.StartInhibit = 0;
BatteryConnected := 	CorvusRead[M].theArray.nrOfPackConnected > 0;
CoolingFansRunning := 	PRG_DO.do_StartFan.PV;

DriveFault := 			PRG_Drive.Status.Fault;
BatteryFault := 		PRG_BatteryProtection.batteryCommonFault;
CommonWarning := 		PRG_Alarms.Repeat_Alarm.Alarm_common;
CommonFault := 			PRG_Faults.Repeat_Fault.Alarm_common;
LowSoC :=				PRG_BatteryProtection.ProtectionTrip_SoC_LL OR PRG_BatteryProtection.ProtectionTrip_SoC_LLL;

OtherSourcesOnBus := 	NOT PRG_BatteryProtection.BatteryAlone;
ChargeLimitActive :=	(PRG_Battery.StopChargeTOF.Q) OR (CorvusRead[M].theArray.busCurrent > CorvusRead[M].theArray.systemChargelimit);
DischargeLimitActive:=	(PRG_Battery.StopDischargeTOF.Q) OR (CorvusRead[M].theArray.busCurrent < CorvusRead[M].theArray.systemChargelimit*-1);
InLimit := 				ChargeLimitActive OR DischargeLimitActive OR PRG_Battery.Battery_Current_Limiter.ChargingLimited OR	PRG_Battery.Battery_Current_Limiter.DischargingLimited;

(*Analog Values*)
(*==========================================================================================================================================*)
EnergyRemaining := 		PRG_Battery.EnergyToDisconnect;
State := 				PRG_StateMain.State;
ControlPlace := 		PRG_Operation.ControlPlace.ctrlLocation;
ControlMode := 			PRG_IAS.IAS_CTRL_OperationalMode;
MinutesRemaining := 	PRG_Battery.MinutesRemaining;
BMS_ChargeLimit_eng :=		PRG_Battery.BMS_ChargeLimit_eng;
BMS_DischargeLimit_eng :=	PRG_Battery.BMS_DischargeLimit_eng;

(*Analog Structured Values*)
(*==========================================================================================================================================*)

(*Battery Related variables*)

BMS_SoC.HH := SetupBatLimits.SoCTripHH; 				(*Upper red line limit for State of Charge in HMI Mimic*)
BMS_SoC.H := SetupBatLimits.SoCAlarmH;					(*Upper yellow line limit for State of Charge in HMI Mimic*)
IF (PRG_Battery.BatteryMinOneConnected) THEN			(*Different limits when offline*)
	BMS_SoC.L := SetupBatLimits.SoCAlarmL;				(*Lower yellow line limit for State of Charge in HMI Mimic*)
	BMS_SoC.LL := SetupBatLimits.SoCTripLL;				(*Lower red line limit for State of Charge in HMI Mimic*)
ELSE
	BMS_SoC.L := SetupBatLimits.SoCAlarmL_Offline;		(*Lower yellow line limit for State of Charge in HMI Mimic*)
	BMS_SoC.LL := SetupBatLimits.SoCTripLL_Offline;		(*Lower red line limit for State of Charge in HMI Mimic*)
END_IF
BMS_SoC.MaxScale := 100;								(*Max scale for state of charge in %*)
BMS_SoC.MinScale := 0; 									(*Min scale for state of charge in %*)
BMS_SoC.PV := CorvusRead[M].theArray.systemOnlineSOC;


BMS_BusPower.HH := REAL_TO_INT(CorvusRead[M].theArray.busVoltage * CorvusRead[M].theArray.systemChargelimit*0.001); (*Calculated max power input*)
BMS_BusPower.H := BMS_BusPower.HH - 100;
BMS_BusPower.L := (BMS_BusPower.LL) + 100;
BMS_BusPower.LL :=REAL_TO_INT(CorvusRead[M].theArray.busVoltage * CorvusRead[M].theArray.systemDischargeLimit*-0.001); (*Calculated max power output*)
BMS_BusPower.MaxScale :=REAL_TO_INT(setup_Battery_Max_Voltage*DriveSettings.SourceNomCurrent*0.001)+200; (* Max Voltage times highest Current range and convert from W to kW. Then add some slack.*)
BMS_BusPower.MinScale :=REAL_TO_INT(setup_Battery_Max_Voltage*DriveSettings.SourceNomCurrent*-0.001)-200; (* Max Voltage times highest Current range and convert from W to kW. Then add some slack.*)
BMS_BusPower.PV := REAL_TO_INT(CorvusRead[M].theArray.busPowerCalculated);


BMS_BusCurrent.HH :=LIMIT(0,BMS_ChargeLimit_eng,REAL_TO_DINT(DriveSettings.SourceNomCurrent));
BMS_BusCurrent.H :=BMS_BusCurrent.HH-10;
BMS_BusCurrent.L :=(BMS_BusCurrent.LL+10);
BMS_BusCurrent.LL := LIMIT(REAL_TO_DINT(DriveSettings.SourceNomCurrent*-1), (BMS_DischargeLimit_eng*-1), 0);
BMS_BusCurrent.MaxScale := DriveSettings.SourceNomCurrent*1.1;
BMS_BusCurrent.MinScale := DriveSettings.SourceNomCurrent*-1.1;
BMS_BusCurrent.PV := CorvusRead[M].theArray.busCurrent; (*Process Value for mimic bar*)

FOR i := 1 TO 16 BY 1 DO
	BMS_PackCurrent[i].HH :=CorvusRead[i].Pack.chargeCurrentLimit;
	BMS_PackCurrent[i].H :=CorvusRead[i].Pack.chargeCurrentLimit-10;
	BMS_PackCurrent[i].L :=(CorvusRead[i].Pack.dischargeCurrentLimit-10)*-1;
	BMS_PackCurrent[i].LL := (CorvusRead[i].Pack.dischargeCurrentLimit)*-1;
	BMS_PackCurrent[i].MaxScale := setup_Battery_C_Rate * setup_Battery_C *2;
	BMS_PackCurrent[i].MinScale := setup_Battery_C_Rate * setup_Battery_C *-2;
	BMS_PackCurrent[i].PV := CorvusRead[i].Pack.current; (*Process Value for mimic bar*)
END_FOR

BMS_BusVoltage.HH := setup_Battery_Max_Voltage;
BMS_BusVoltage.H := setup_Battery_Max_Voltage-25;
BMS_BusVoltage.L :=setup_Battery_Min_Voltage+25;
BMS_BusVoltage.LL :=setup_Battery_Min_Voltage;
BMS_BusVoltage.MaxScale :=setup_Battery_Max_Voltage+100;
BMS_BusVoltage.MinScale :=setup_Battery_Min_Voltage;
BMS_BusVoltage.PV := CorvusRead[M].theArray.busVoltage;


Drive_DCLink.LL := 950;
Drive_DCLink.L := 970;
Drive_DCLink.H := 1050;
Drive_DCLink.HH := 1100;
Drive_DCLink.MaxScale:= 1250;
Drive_DCLink.MinScale:= 0;
Drive_DCLink.PV := PRG_Drive.Data.DcLinkVoltage_eng;

Drive_ActivePower_eng.HH := (PRG_Drive.Data.UsedChargeLimit_eng);
Drive_ActivePower_eng.H := (PRG_Drive.Data.UsedChargeLimit_eng - 10);
Drive_ActivePower_eng.L := (PRG_Drive.Data.UsedDischargeLimit_eng -10)*-1;
Drive_ActivePower_eng.LL := (PRG_Drive.Data.UsedDischargeLimit_eng*-1);
Drive_ActivePower_eng.MaxScale := DriveSettings.SourceNomPower;
Drive_ActivePower_eng.MinScale := DriveSettings.SourceNomPower*-1;
Drive_ActivePower_eng.PV := PRG_Drive.Data.SourcePowerTotal_eng;


Drive_ActivePower_pc.HH := 100;
Drive_ActivePower_pc.H := 95;
Drive_ActivePower_pc.L := -95;
Drive_ActivePower_pc.LL := -100;
Drive_ActivePower_pc.MaxScale := 120;
Drive_ActivePower_pc.MinScale := -120;
Drive_ActivePower_pc.PV := PRG_Drive.Data.SourcePower_pu[1]*100;


Drive_TotalCurrent.LL := 0;
Drive_TotalCurrent.L := 0;
Drive_TotalCurrent.H := REAL_TO_DINT(DriveSettings.SourceNomCurrent*1.05);
Drive_TotalCurrent.HH := REAL_TO_DINT(DriveSettings.SourceNomCurrent*1.1);
Drive_TotalCurrent.MaxScale := REAL_TO_DINT(DriveSettings.SourceNomCurrent*1.2);
Drive_TotalCurrent.MinScale := 0;
Drive_TotalCurrent.PV := PRG_Drive.Data.SourceCurrentTotal_eng;

CabinetTemp.LL := 			0;
CabinetTemp.L := 			0;
CabinetTemp.H := 			PRG_AI.ai_CabinetTemperature_setup.Levels.HH;
CabinetTemp.HH := 			PRG_AI.ai_CabinetTemperature_setup.Levels.HHH;
CabinetTemp.MaxScale := 	PRG_AI.ai_CabinetTemperature_setup.Levels.Scale20mA;
CabinetTemp.MinScale := 	PRG_AI.ai_CabinetTemperature_setup.Levels.Scale4mA;
CabinetTemp.PV := 			PRG_AI.ai_CabinetTemperature.PV;








(* 
 * ======================================================================================================================================= 
 * Readings Screen
 * =======================================================================================================================================
*)


BMS_PacksConnected.HH :=setup_Battery_total_nr_of_packs+1;
BMS_PacksConnected.H :=setup_Battery_total_nr_of_packs+1;
BMS_PacksConnected.L :=setup_Battery_total_nr_of_packs-1;
BMS_PacksConnected.LL := 1;
BMS_PacksConnected.MaxScale := setup_Battery_total_nr_of_packs;
BMS_PacksConnected.MinScale := 0;
BMS_PacksConnected.PV := CorvusRead[M].theArray.nrOfPackConnected; (*Process Value for mimic bar*)


BMS_MaxCellTemp.HH := setup_Battery_CellTemp_HH_Trip-5;			(*Fault trip temperature closing*)
BMS_MaxCellTemp.H := setup_Battery_CellTemp_H_Alarm-5;			(*Warning temperature closing*)
BMS_MaxCellTemp.L := setup_Battery_CellTemp_L_Alarm;			(**)
BMS_MaxCellTemp.LL := setup_Battery_CellTemp_LL_Alarm;			(**)
BMS_MaxCellTemp.MaxScale := setup_Battery_CellTemp_HH_Trip+10; 	(*Upper scaling of mimic bar*)
BMS_MaxCellTemp.MinScale := 0;									(*Lower scaling of mimic bar*)
BMS_MaxCellTemp.PV := CorvusRead[M].theArray.maxCellTemp; 		(*Process Value for mimic bar*)

BMS_MinCellTemp.HH := BMS_MaxCellTemp.HH;						(*Fault trip temperature closing*)
BMS_MinCellTemp.H := BMS_MaxCellTemp.H;							(*Warning temperature closing*)
BMS_MinCellTemp.L := BMS_MaxCellTemp.L;							(**)
BMS_MinCellTemp.LL := BMS_MaxCellTemp.LL;						(**)
BMS_MinCellTemp.MaxScale := BMS_MaxCellTemp.MaxScale; 			(*Upper scaling of mimic bar*)
BMS_MinCellTemp.MinScale := BMS_MaxCellTemp.MinScale;			(*Lower scaling of mimic bar*)
BMS_MinCellTemp.PV := CorvusRead[M].theArray.minCellTemp;		(*Process Value for mimic bar*)


BMS_MaxCellVolt.HH := setup_Battery_CellVolt_HH_Trip;			(*Fault trip voltage closing - converted to mV*)
BMS_MaxCellVolt.H := setup_Battery_CellVolt_H_Alarm;			(*Warning voltage closing - converted to mV*)
BMS_MaxCellVolt.L := setup_Battery_CellVolt_L_Alarm;			(**)
BMS_MaxCellVolt.LL := setup_Battery_CellVolt_LL_Trip;			(**)
BMS_MaxCellVolt.MaxScale := setup_Battery_CellVolt_HH_Trip+200; (*Upper scaling of mimic bar*)
BMS_MaxCellVolt.MinScale := setup_Battery_CellVolt_LL_Trip-200;	(*Lower scaling of mimic bar*)
BMS_MaxCellVolt.PV := CorvusRead[M].theArray.maxCellVoltage; 	(*Process Value for mimic bar*)

BMS_MaxDischargeCurrent.HH := 99999;										(*No highhigh colorization*)
BMS_MaxDischargeCurrent.H := 99999;											(*No high colorization*)
BMS_MaxDischargeCurrent.L := REAL_TO_DINT(BMS_BusCurrent.PV-10);			(*Yellow when close to actual current*)
BMS_MaxDischargeCurrent.LL := REAL_TO_DINT(BMS_BusCurrent.PV);				(*Red when at or higher than actual current*)
BMS_MaxDischargeCurrent.MaxScale := setup_Battery_total_nr_of_packs*setup_Battery_C_Rate*setup_Battery_C*2; 	(*Upper scaling of mimic bar*)
BMS_MaxDischargeCurrent.MinScale := 0;										(*Lower scaling of mimic bar*)
BMS_MaxDischargeCurrent.PV := CorvusRead[M].theArray.systemDischargeLimit; 	(*Process Value for mimic bar*)

BMS_MaxChargeCurrent.HH := 99999;										(*No highhigh colorization*)
BMS_MaxChargeCurrent.H := 99999;										(*No high colorization*)
BMS_MaxChargeCurrent.L := REAL_TO_DINT(ABS(BMS_BusCurrent.PV)-10);		(*Yellow when close to actual current*)
BMS_MaxChargeCurrent.LL := REAL_TO_DINT(ABS(BMS_BusCurrent.PV));		(*Red when at or higher than actual current*)
BMS_MaxChargeCurrent.MaxScale := setup_Battery_total_nr_of_packs*setup_Battery_C_Rate*setup_Battery_C*2; 	(*Upper scaling of mimic bar*)
BMS_MaxChargeCurrent.MinScale := 0;										(*Lower scaling of mimic bar*)
BMS_MaxChargeCurrent.PV := CorvusRead[M].theArray.systemChargelimit; 	(*Process Value for mimic bar*)

BMS_MaxOfflinePackVolt.HH := REAL_TO_DINT(BMS_MinOfflinePackVolt.PV + 20);		(*Red when too high for connection*)
BMS_MaxOfflinePackVolt.H := REAL_TO_DINT(BMS_MinOfflinePackVolt.PV + 10);		(*Yellow when different from bus voltage*)
BMS_MaxOfflinePackVolt.L := REAL_TO_DINT(BMS_MinOfflinePackVolt.PV-10);			(*Yellow when different from bus voltage*)
BMS_MaxOfflinePackVolt.LL := REAL_TO_DINT(BMS_MinOfflinePackVolt.PV-20);		(*Red when too low for connectio*)
BMS_MaxOfflinePackVolt.MaxScale := setup_Battery_Max_Voltage; 					(*Upper scaling of mimic bar*)
BMS_MaxOfflinePackVolt.MinScale := setup_Battery_Min_Voltage;					(*Lower scaling of mimic bar*)
BMS_MaxOfflinePackVolt.PV := CorvusRead[M].theArray.maxUnconnectPackVoltage; 	(*Process Value for mimic bar*)

BMS_MinOfflinePackVolt.HH := REAL_TO_DINT(BMS_MaxOfflinePackVolt.PV + 20);		(*Red when too high for connection*)
BMS_MinOfflinePackVolt.H := REAL_TO_DINT(BMS_MaxOfflinePackVolt.PV + 10);		(*Yellow when different from bus voltage*)
BMS_MinOfflinePackVolt.L := REAL_TO_DINT(BMS_MaxOfflinePackVolt.PV-10);			(*Yellow when different from bus voltage*)
BMS_MinOfflinePackVolt.LL := REAL_TO_DINT(BMS_MaxOfflinePackVolt.PV-20);		(*Red when too low for connectio*)
BMS_MinOfflinePackVolt.MaxScale := setup_Battery_Max_Voltage; 			(*Upper scaling of mimic bar*)
BMS_MinOfflinePackVolt.MinScale := setup_Battery_Min_Voltage;			(*Lower scaling of mimic bar*)
BMS_MinOfflinePackVolt.PV := CorvusRead[M].theArray.minUnconnectPackVoltage; 	(*Process Value for mimic bar*)

BMS_MinCellVolt.HH := BMS_MaxCellVolt.HH;						(*Fault trip voltage closing - converted to mV*)
BMS_MinCellVolt.H := BMS_MaxCellVolt.H;							(*Warning voltage closing - converted to mV*)
BMS_MinCellVolt.L := BMS_MaxCellVolt.L;							(**)
BMS_MinCellVolt.LL := BMS_MaxCellVolt.LL;						(**)
BMS_MinCellVolt.MaxScale := setup_Battery_CellVolt_HH_Trip+200; (*Upper scaling of mimic bar*)
BMS_MinCellVolt.MinScale := setup_Battery_CellVolt_LL_Trip-200;	(*Lower scaling of mimic bar*)
BMS_MinCellVolt.PV := CorvusRead[M].theArray.minCellVoltage; 	(*Process Value for mimic bar*)

Drive_Temp.LL := 0;
Drive_Temp.L := 0;
Drive_Temp.H := DriveSettings.UnitTempAlarmLevel;
Drive_Temp.HH := 70;
Drive_Temp.MaxScale := 100;
Drive_Temp.MinScale := 0;
Drive_Temp.PV := PRG_Drive.Data.UnitTempMax_eng;




BMS_SoH :=CorvusRead[M].theArray.systemOnlineSOH;
BMS_nrOfPacksInArray := CorvusRead[M].theArray.nrOfPacksInArray;
BMS_nrOfPackInNetwork := CorvusRead[M].theArray.nrOfPackInNetwork;
BMS_nrOfPackConnected := CorvusRead[M].theArray.nrOfPackConnected;
BMS_nrOfPackFault := CorvusRead[M].theArray.nrOfPackFault;
BMS_maxUnconnectPackVoltage := CorvusRead[M].theArray.maxUnconnectPackVoltage;
BMS_minUnconnectPackVoltage := CorvusRead[M].theArray.minUnconnectPackVoltage;











(* 
 * ======================================================================================================================================= 
 * Info Screen
 * =======================================================================================================================================
*)

PrechargeStatus := PRG_BatteryComm.CorvusRead[1].theArray.packPreChargeStatus1;

StartInhibit := (PRG_StateMain.StartInhibit <> 0);
StartInhibit0 := NOT PRG_StateMain.StartInhibit.0;
StartInhibit1 := NOT PRG_StateMain.StartInhibit.1;
StartInhibit2 := NOT PRG_StateMain.StartInhibit.2;
StartInhibit3 := NOT PRG_StateMain.StartInhibit.3;
StartInhibit4 := NOT PRG_StateMain.StartInhibit.4 AND NOT PRG_StateMain.StartInhibit.5 ;
StartInhibit5 := NOT PRG_StateMain.StartInhibit.6;
StartingTimeRemaining := PRG_StateMain.StartingTON.PT - PRG_StateMain.StartingTON.ET;


(*Voltage Reference*)
Reference.HH := 		PRG_Operation.OverVoltageRefFiltered_eng;
Reference.H := 			0;	
Reference.L := 			0;
Reference.LL := 		PRG_Operation.UnderVoltageRefFiltered_eng;
Reference.MaxScale := 	PRG_Operation.VoltIncDec.RefMax_eng;
Reference.MinScale := 	PRG_Operation.VoltIncDec.RefMin_eng;
Reference.PV := 		PRG_Drive.Data.DcLinkVoltage_eng;

ReferenceActual := 		REAL_TO_INT(PRG_Operation.VoltIncDec.Ref_eng);

(*Current Limiter*)
Limiter.HH := 			PRG_Battery.DriveChargeLimit_eng;
Limiter.H := 			PRG_Battery.DriveChargeLimit_eng-10;	
Limiter.L := 			(PRG_Battery.DriveDischargeLimit_eng-10)*-1;
Limiter.LL := 			PRG_Battery.DriveDischargeLimit_eng*-1;
Limiter.MaxScale := 	DriveSettings.SourceNomCurrent;
Limiter.MinScale := 	DriveSettings.SourceNomCurrent*-1;
Limiter.PV := 			PRG_Drive.Data.SourceCurrentTotal_eng;

SystemRunning := (PRG_StateMain.State = e_Running);

ChargeLimitComped_eng := PRG_Battery.DriveChargeLimit_eng;
DischargeLimitComped_eng := PRG_Battery.DriveDischargeLimit_eng;

(* 
 * ======================================================================================================================================= 
 * Charge and Discharge Current Test
 * =======================================================================================================================================
*)	

(*Alter charge and discharge current limit from BMS to test limitation*)
IF (ChargeDischargeCurrentTestActive) THEN
	ChargeCurrentLimit_scale.PV := 		LIMIT (0,	ChargeCurrentLimit_scale.PV,		PRG_BatteryComm.CorvusRead[M].theArray.systemChargelimit); (*Prevent that user input limit is higher than actual limit from BMS*)
	DischargeCurrentLimit_scale.PV := 	LIMIT (0,	DischargeCurrentLimit_scale.PV,		PRG_BatteryComm.CorvusRead[M].theArray.systemDischargeLimit);
END_IF

(*Set timeout for altered charge/discharge limits*)
ChargeDischargeCurrent_TON (IN:=ChargeDischargeCurrentTestActive, PT:=T#3600s);

(*Display remaining time*)
ChargeDischargeCurrentTime := ChargeDischargeCurrent_TON.PT - ChargeDischargeCurrent_TON.ET;

(*Disable after timeout or when start bit has been deactivated*)
IF 	(ChargeDischargeCurrent_TON.Q) THEN
	ChargeDischargeCurrentTestActive := FALSE;
END_IF


(*Scaling Values for HMI Settings*)
DischargeCurrentLimit_scale.LL := -2;
DischargeCurrentLimit_scale.L := -1 ;
DischargeCurrentLimit_scale.H := 100;
DischargeCurrentLimit_scale.HH := 200;
DischargeCurrentLimit_scale.MinScale := 0;
DischargeCurrentLimit_scale.MaxScale := 384;

ChargeCurrentLimit_scale.LL := -2;
ChargeCurrentLimit_scale.L := -1 ;
ChargeCurrentLimit_scale.H := 100;
ChargeCurrentLimit_scale.HH := 200;
ChargeCurrentLimit_scale.MinScale := 0;
ChargeCurrentLimit_scale.MaxScale := 384;




(* 
 * ======================================================================================================================================= 
 * Override function to allow battery start and precharge of DC switchboard. Only for service engineers. 
 * Other converters on the board must be disconnected to prevent charging whole switchboard.
 * After start, each of the other converters can be individually precharged using button in switchboard door.
 * =======================================================================================================================================
*)	



(*Set timeout for altered charge/discharge limits*)
OverrideStartVoltageDcLink_TON (IN:=OverrideStartVoltageDcLink, PT:=T#120s);

(*Disable after timeout or when start bit has been deactivated*)
IF 	(OverrideStartVoltageDcLink_TON.Q) THEN
	OverrideStartVoltageDcLink := FALSE;
END_IF
(*Show time remaining on HMI*)
OverrideStartVoltageDcLinkTimeLeft := OverrideStartVoltageDcLink_TON.PT-OverrideStartVoltageDcLink_TON.ET;




(* 
 * ======================================================================================================================================= 
 * Faking starting and stopping timeouts to present alarms
 * =======================================================================================================================================
*)

(*Set timeout for testing starting timout*)
TestStartingTimeout_TON (IN:=TestStartingTimeout, PT:=REAL_TO_TIME((Delay_StartingTimeOut+10)*1000));

(*Disable after timeout or when start bit has been deactivated*)
IF 	(TestStartingTimeout_TON.Q) THEN
	TestStartingTimeout := FALSE;
END_IF
(*Show time remaining on HMI*)
TestStartingTimeoutTimeLeft := TestStartingTimeout_TON.PT - TestStartingTimeout_TON.ET;



(*Set timeout for testing stopping timeout*)
TestStoppingTimeout_TON (IN:=TestStoppingTimeout, PT:=REAL_TO_TIME((Delay_StoppingTimeOut+10)*1000));

(*Disable after timeout or when start bit has been deactivated*)
IF 	(TestStoppingTimeout_TON.Q) THEN
	TestStoppingTimeout := FALSE;
END_IF
(*Show time remaining on HMI*)
TestStoppingTimeoutTimeLeft := TestStoppingTimeout_TON.PT - TestStoppingTimeout_TON.ET;





(* 
 * ======================================================================================================================================= 
 * Reset button from HMI
 * =======================================================================================================================================
*)	



(*Reset button from HMI*)
ResetTON(
	IN := Reset,
	PT := T#1s,
	Q => ,
	ET => 
);

(*Turn of reset signal from HMI if left on*)
IF (ResetTON.Q) THEN
	Reset := FALSE;
END_IF


(* 
 * ======================================================================================================================================= 
 * Lamp Test
 * =======================================================================================================================================
*)

(*Activate Lamptest from HMI*)
LamptestTOF(
	IN := Lamptest,
	PT := T#10s,
	Q => ,
	ET => 
);

(*Turn of lamp test button in case it is left on*)
IF (LamptestTOF.Q) THEN 
	Lamptest := FALSE;
END_IF

(*Show HMI that lamp test is active*)
LamptestIndication := LamptestTOF.Q;	(*Show in HMI that lamp test is active*)

(*Lamp test blinking sequence*)
LamptestPulsetrain(
	ACTIVATE := LamptestTOF.Q,
	Half_Periode := T#500ms,
	CLK_Pulse => 
);








(* 
 * ======================================================================================================================================= 
 * Misc Values for Settings Page
 * =======================================================================================================================================
*)

CpuTemp := 			PRG_HW.HwAlarmCPU.CpuTemp;
CpuLoad := 			PRG_HW.HwAlarmCPU.CpuLoad;
MemFreeAppPart02 := PRG_HW.HwAlarmCPU.MemFreeAppPart02;
MemFreeGlobPart := 	PRG_HW.HwAlarmCPU.MemFreeGlobPart;
MemFreeSysPart := 	PRG_HW.HwAlarmCPU.MemFreeSysPart;
Eth0kbps:= 			PRG_HW.Eth0In.TrafficLastSecond/1000;	
Eth1kbps:= 			PRG_HW.Eth1In.TrafficLastSecond/1000;	
Em0kbps:=			PRG_HW.Em0In.TrafficLastSecond/1000;

VaconChargeCurrentLimit := PRG_Drive.PDI[1].PDI3_ChargeLimit;
VaconDischargeCurrentLimit := PRG_Drive.PDI[1].PDI4_DischargeLimit;
VaconOverVoltageRef := PRG_Drive.PDI[1].PDI2_OvervoltageRef;
VaconUnderVoltageRef := PRG_Drive.PDI[1].PDI1_UndervoltageRef;


(*Bits for the red and yellow indication lamps for protection settings in the HMI*)

Indicate_BattVolt_HH_Timer := 	PRG_BatteryProtection.TripBasket.in4;
Indicate_BattVolt_HH_Trip := 	PRG_BatteryProtection.ProtectionTrip_Overvoltage;
Indicate_BattVolt_LL_Timer :=	PRG_BatteryProtection.TripBasket.in5;
Indicate_BattVolt_LL_Trip :=	PRG_BatteryProtection.ProtectionTrip_Undervoltage;

Indicate_SoC_HH_Timer := 		PRG_BatteryProtection.TripBasket.in1;	
Indicate_SoC_HH_Trip := 		PRG_BatteryProtection.ProtectionTrip_SoC_HH;
Indicate_SoC_LL_Timer := 		PRG_BatteryProtection.TripBasket.in3;	
Indicate_SoC_LL_Trip :=			PRG_BatteryProtection.ProtectionTrip_SoC_LLL;
	
Indicate_CellVolt_HH_Timer := 	PRG_BatteryProtection.TripBasket.in6;
Indicate_CellVolt_HH_Trip :=	PRG_BatteryProtection.ProtectionTrip_CellVolt_HH;
Indicate_CellVolt_LL_Timer := 	PRG_BatteryProtection.TripBasket.in7;
Indicate_CellVolt_LL_Trip := 	PRG_BatteryProtection.ProtectionTrip_CellVolt_LL;

Indicate_CellTemp_HH_Timer := 	PRG_BatteryProtection.TripBasket.in8;
Indicate_CellTemp_HH_Trip :=	PRG_BatteryProtection.ProtectionTrip_CellTemp_HH;



(* 
 * ======================================================================================================================================= 
 * State of Health Verification Mode
 * =======================================================================================================================================
*)


(*Timer to automatically deactivate this mode after given timeout from HMI*)

SoHVerifModeActiveRT(CLK := SoHVerifModeActive);



SoHVerifTOF( 
	IN := SoHVerifModeActiveRT.Q,
	PT := DINT_TO_TIME(SoHVerifTimer)*3600000
);

IF (NOT SoHVerifTOF.Q) THEN
	SoHVerifModeActive := FALSE;
END_IF
	
(*Bit to reset SoC Limits to default values in HMI_Communication*)
SoHVerifModeActiveFT(CLK := SoHVerifModeActive);

(*Estimated time to HMI*)
SoHVerifCountdown := TIME_TO_DINT(SoHVerifTOF.PT - SoHVerifTOF.ET)/1000;









(* 
 * ======================================================================================================================================= 
 * Protection Settings for Battery Trip and Alarms
 * =======================================================================================================================================
*)


(*Set Limits from HMI - but within hard coded limits or neighboring ones*)
SetupBatLimits.SoCTripHH := 	LIMIT(SetupBatLimits.SoCAlarmH+1,	SetupBatLimits.SoCTripHH,	setup_SoC_HH_Trip); 		(* Must be between High Alarm and hard coded HH-trip *)
SetupBatLimits.SoCAlarmH := 	LIMIT(SetupBatLimits.SoCAlarmL+1,	SetupBatLimits.SoCAlarmH,	SetupBatLimits.SoCTripHH-1);(*Must be between low alarm and high alarm*)

(*Change lower SoC Alarm and Trip level if battery is alone or SoH Testing is ongoing*)
IF (PRG_HMI.SoHVerifModeActive) THEN
	SetupBatLimits.SoCAlarmL :=		LIMIT(setup_SoC_LLL_Trip+1,			SetupBatLimits.SoCTripLL+1,	SetupBatLimits.SoCAlarmH-1);(*Must be between hardcoded low alarm and high alarm *)	
ELSE
	SetupBatLimits.SoCAlarmL :=		LIMIT(setup_SoC_L_Alarm,			SetupBatLimits.SoCAlarmL,	SetupBatLimits.SoCAlarmH-1);(*Must be between hardcoded low alarm and high alarm *)
END_IF

IF (PRG_BatteryProtection.BatteryAlone OR PRG_HMI.SoHVerifModeActive) THEN	
	SetupBatLimits.SoCTripLL :=			LIMIT(setup_SoC_LLL_Trip,	setup_SoC_LLL_Trip+1,	SetupBatLimits.SoCAlarmL-1);(*If battery is alone, let lower limit go down further*)
ELSE 
	SetupBatLimits.SoCTripLL :=			LIMIT(setup_SoC_LL_Trip,	SetupBatLimits.SoCTripLL,	SetupBatLimits.SoCAlarmL-1);(*If not alone, the lower limit is higher than otherwise*)
END_IF


SetupBatLimits.VoltTripHH := 		LIMIT(SetupBatLimits.VoltAlarmH+1,		SetupBatLimits.VoltTripHH,		setup_Battery_Max_Voltage);
SetupBatLimits.VoltAlarmH := 		LIMIT(SetupBatLimits.VoltAlarmL+1, 		SetupBatLimits.VoltAlarmH,		SetupBatLimits.VoltTripHH-1);
SetupBatLimits.VoltAlarmL := 		LIMIT(SetupBatLimits.VoltTripLL+1,		SetupBatLimits.VoltAlarmL,		SetupBatLimits.VoltAlarmH-1);
SetupBatLimits.VoltTripLL :=		LIMIT(setup_Battery_Min_Voltage,		SetupBatLimits.VoltTripLL, 		SetupBatLimits.VoltAlarmL-1);

SetupBatLimits.CellVoltTripHH := 	LIMIT(SetupBatLimits.CellVoltAlarmH+1, 	SetupBatLimits.CellVoltTripHH,	setup_Battery_CellVolt_HH_Trip);
SetupBatLimits.CellVoltAlarmH :=	LIMIT(SetupBatLimits.CellVoltAlarmL+1,	SetupBatLimits.CellVoltAlarmH,	setup_Battery_CellVolt_H_Alarm);
SetupBatLimits.CellVoltAlarmL := 	LIMIT(setup_Battery_CellVolt_L_Alarm, 	SetupBatLimits.CellVoltAlarmL,	SetupBatLimits.CellVoltAlarmH-1);
SetupBatLimits.CellVoltTripLL :=	LIMIT(setup_Battery_CellVolt_LL_Trip,	SetupBatLimits.CellVoltTripLL, 	SetupBatLimits.CellVoltAlarmL-1);

SetupBatLimits.CellTempTripHH :=	LIMIT(SetupBatLimits.CellTempAlarmH+1,	SetupBatLimits.CellTempTripHH,	setup_Battery_CellTemp_HH_Trip);
SetupBatLimits.CellTempAlarmH := 	LIMIT(SetupBatLimits.CellTempAlarmL+1,	SetupBatLimits.CellTempAlarmH,	setup_Battery_CellTemp_H_Alarm);
SetupBatLimits.CellTempAlarmL :=  	LIMIT(setup_Battery_CellTemp_L_Alarm,	SetupBatLimits.CellTempAlarmL,	SetupBatLimits.CellTempAlarmH-1);
SetupBatLimits.CellTempAlarmLL := 	LIMIT(setup_Battery_CellTemp_LL_Alarm, 	SetupBatLimits.CellTempAlarmLL,	SetupBatLimits.CellTempAlarmL-1);

(*Offline limits*)
SetupBatLimits.CellVoltAlarmL_Offline 	:= 	LIMIT(setup_Battery_CellVolt_Offline_L_Alarm, 	SetupBatLimits.CellVoltAlarmL_Offline, 	SetupBatLimits.CellVoltAlarmH-1);
SetupBatLimits.CellVoltTripLL_Offline := 	LIMIT(setup_Battery_CellVolt_Offline_LL_Trip,	SetupBatLimits.CellVoltTripLL_Offline, 	SetupBatLimits.CellVoltAlarmL_Offline);
SetupBatLimits.SoCAlarmL_Offline 		:= 	LIMIT(setup_Battery_SoC_Offline_L_Alarm,		SetupBatLimits.SoCAlarmL_Offline,		SetupBatLimits.SoCAlarmH-1);
SetupBatLimits.SoCTripLL_Offline 		:= 	LIMIT(setup_Battery_SoC_Offline_LL_Trip,		SetupBatLimits.SoCTripLL_Offline,		SetupBatLimits.SoCAlarmL-1);



IF (PRG_BatteryProtection.ConfigError <> 0) THEN
	RestoreProtection := TRUE; (*If there is a problem with the protection settings, restore them.*)
END_IF


IF (RestoreProtection) THEN

	(*Set init values for limits and protection according to hardcoded min/max values*)
	SetupBatLimits.SoCTripHH := 	setup_SoC_HH_Trip;
	SetupBatLimits.SoCAlarmH := 	setup_SoC_H_Alarm;
	SetupBatLimits.SoCAlarmL := 	setup_SoC_L_Alarm;
	SetupBatLimits.SoCTripLL :=		setup_SoC_LL_Trip;
	
	SetupBatLimits.VoltTripHH := 	setup_Battery_Max_Voltage;
	SetupBatLimits.VoltAlarmH := 	setup_Battery_Max_Voltage-5;
	SetupBatLimits.VoltAlarmL :=	setup_Battery_Min_Voltage+5;
	SetupBatLimits.VoltTripLL :=	setup_Battery_Min_Voltage;
	
	SetupBatLimits.CellVoltTripHH := 	setup_Battery_CellVolt_HH_Trip;
	SetupBatLimits.CellVoltAlarmH := 	setup_Battery_CellVolt_H_Alarm;
	SetupBatLimits.CellVoltAlarmL :=	setup_Battery_CellVolt_L_Alarm;
	SetupBatLimits.CellVoltTripLL :=	setup_Battery_CellVolt_LL_Trip;
	
	SetupBatLimits.CellTempTripHH := 	setup_Battery_CellTemp_HH_Trip;
	SetupBatLimits.CellTempAlarmH := 	setup_Battery_CellTemp_H_Alarm;
	SetupBatLimits.CellTempAlarmL :=	setup_Battery_CellTemp_L_Alarm;
	SetupBatLimits.CellTempAlarmLL :=	setup_Battery_CellTemp_LL_Alarm;
	
	SetupBatLimits.CellVoltAlarmL_Offline := 	setup_Battery_CellVolt_Offline_L_Alarm;
	SetupBatLimits.CellVoltTripLL_Offline := 	setup_Battery_CellVolt_Offline_LL_Trip;
	
	SetupBatLimits.SoCAlarmL_Offline := 	setup_Battery_SoC_Offline_L_Alarm;
	SetupBatLimits.SoCTripLL_Offline := 	setup_Battery_SoC_Offline_LL_Trip;


END_IF



(* 
 * ======================================================================================================================================= 
 * Gather analog instrument values in engineering and percentage  plus lamp statuses
 * =======================================================================================================================================
*)

Instr_BatteryChargeDischargeCurrent_pc:= 	PRG_AO.BatteryChargeDischargeCurrent_pc;
Instr_BatteryVoltage_pc:= 					PRG_AO.BatteryVoltage_pc;
Instr_BatteryPower_pc:= 					PRG_AO.BatteryPower_pc;
Instr_BatteryCurrent_pc:= 					PRG_AO.BatteryCurrent_pc;
Instr_BatterySoC_pc:= 						PRG_AO.BatterySoC_pc;
Instr_BatteryChargeDischargeCurrent_eng:= 	PRG_AO.BatteryChargeDischargeCurrent_eng;
Instr_BatteryVoltage_eng:= 					PRG_AO.BatteryVoltage_eng;
Instr_BatteryPower_eng:= 					PRG_AO.BatteryPower_eng;
Instr_BatteryCurrent_eng:= 					PRG_AO.BatteryCurrent_eng;
Instr_BatterySoC_eng:= 						PRG_AO.BatterySoC_eng;

RunningLamp_Status := 	PRG_DO.do_RunningLamp.PV;
ReadyLamp_Status := 	PRG_DO.do_ReadyLamp.PV;
StoppedLampStatus := 	PRG_DO.do_StoppedLamp.PV;
LocalLampStatus := 		PRG_DO.do_LocalLamp.PV;
WarningLampStatus := 	PRG_DO.do_WarningLamp.PV;
FaultLampStatus := 		PRG_DO.do_FaultLamp.PV;
ChargingLampStatus := 	PRG_DO.do_ChargingLamp.PV;
EnergizedLamp_Status := PRG_DO.do_EnergizedLamp.PV;
















RestoreProtection := FALSE; (*Prevent that this is left on by sloppy HMI*)


END_PROGRAM

ACTIONS

END_ACTIONS