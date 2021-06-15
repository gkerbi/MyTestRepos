PROGRAM PRG_HW
VAR
	
	AioCardID1: DINT;
	AioCardError1: BOOL;
	AioCardInfo1: MIO_RETEXTCARDINF2;
		
	DioCardID1: DINT;
	DioCardError1: BOOL;
	DioCardInfo1: MIO_RETEXTCARDINF2;
	
	(*PLC Cards, used primarily for information to HMI*)
	hmi_plc_card_info: ARRAY[1..cnst_num_cards] OF MIO_RETEXTCARDINF; (*Contains all information about each PLC card*)
	hmi_plc_card_error: ARRAY[1..cnst_num_cards] OF MIO_RETSTATE; (*Contains all information about each PLC card*)
	
	setup_AioCard1_NumberOld: INT;
	setup_DioCard1_NumberOld: INT;
	
	HwAlarmCPU : fb_HwAlarmCPU;
	
	
	Eth0In:						fb_NetCount;
	Eth1In:						fb_NetCount;
	Em0In:						fb_NetCount;	
	Eth0kbps:					REAL;
	Eth1kbps:					REAL;
	Em0kbps:					REAL;
	
END_VAR

(*Check new ID when the card number has changed*)
IF ((PRG_HMI.setup_AioCard1_Number <> setup_AioCard1_NumberOld) OR (PRG_HMI.setup_DioCard1_Number <> setup_DioCard1_NumberOld)) THEN
	AioCardID1 := Mio_GetIdToCard(PRG_HMI.setup_AioCard1_Number);
	DioCardID1 := Mio_GetIdToCard(PRG_HMI.setup_DioCard1_Number);
END_IF


AioCardInfo1 := Mio_GetExtCardInf2(AioCardID1);
DioCardInfo1 := Mio_GetExtCardInf2(DioCardID1);

AioCardError1 := (AioCardInfo1.State = 2);
DioCardError1 := (DioCardInfo1.State = 2);

setup_AioCard1_NumberOld := PRG_HMI.setup_AioCard1_Number;
setup_DioCard1_NumberOld := PRG_HMI.setup_DioCard1_Number;

HwAlarmCPU(
	LevelCpuTemp := 80,
	DelayCpuTemp := T#5s,
	LevelCpuLoad := 80,
	DelayCpuLoad := T#5s,
	LevelHighEM0 := 18,
	LevelHighHighEM0 := 20,
	LevelHighEth1 := 18,
	LevelHighHighEth1 := 20,
	LevelHighEth2 := 18,
	LevelHighHighEth2 := 18,
	LevelFreeMem := 10000,
	AlarmCpuTemp => ,
	AlarmCpuLoad => ,
	AlarmFreeMem => ,
	AlarmHighEM0 => ,
	AlarmHighHighEm0 => ,
	AlarmHighEth1 => ,
	AlarmHighHighEth1 => ,
	AlarmHighEth2 => ,
	CpuLoad => ,
	CpuTemp => ,
	MemFreeAppPart02 => ,
	MemFreeGlobPart => ,
	MemFreeSysPart => 
);


Em0In( 	TrafficCurr100s := 		(HwAlarmCPU.Em0Curr100sIn*8),
		SampleRate := PRG_HMI.NetStormSetup.SampleInterval,
		AlarmLevel := PRG_HMI.NetStormSetup.AlarmLevel,
		EnableAlarm := PRG_HMI.NetStormSetup.EnableAlarm,
		AlarmDelay := PRG_HMI.NetStormSetup.AlarmDelay_ms,
		TrafficLastSecond => );

Eth0In(	TrafficCurr100s := 		(HwAlarmCPU.Eth0Curr100sIn*8),
		SampleRate := PRG_HMI.NetStormSetup.SampleInterval,
		AlarmLevel := PRG_HMI.NetStormSetup.AlarmLevel,
		EnableAlarm := PRG_HMI.NetStormSetup.EnableAlarm,
		AlarmDelay := PRG_HMI.NetStormSetup.AlarmDelay_ms,
		TrafficLastSecond => );	

Eth1In(	TrafficCurr100s := 		(HwAlarmCPU.Eth1Curr100sIn*8),
		SampleRate := PRG_HMI.NetStormSetup.SampleInterval,
		AlarmLevel := PRG_HMI.NetStormSetup.AlarmLevel,
		EnableAlarm := PRG_HMI.NetStormSetup.EnableAlarm,
		AlarmDelay := PRG_HMI.NetStormSetup.AlarmDelay_ms,
		TrafficLastSecond => );

END_PROGRAM