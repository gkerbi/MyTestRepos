PROGRAM PRG_Functions
VAR
	(*Reset Function*)
	ResetTOF :	TOF;
	Reset: BOOL;
	
	(*Breaker position*)
	Breaker : fb_DiDiVerif;
	Version: 				fb_VersionRead;
	ProjectVersion: 		STRING(60);
	
	(*Time synch*)
	TimeSynch : fb_remoteTime;
	
	(*Export Retain Data*)
	RetainExport : 			Smi_RetainExport;	(*Function block for saving retain data to XML*)
	RetainExportRT :		R_TRIG;				(*Trigger export of retain data*)
	DateTime :				TIMESPEC;			(*The PLCs real time clock and date*)
	Filename :				STRING(100);		(*File name, including full path, for retain export*)
	Filedate :				STRING(30);			(*File date for automatic file name when saving retain memory*)
	RetainState:			DINT;				(*State of retain saving process*)
	RetainError:			BOOL;				(*If retain can not be saved*)
	ModuleData :			TCS_ARGINFO;		(*Get some information about the plc*)
	InstanceName :			STRING(15);			(*Instance name in software module list - used for filename*)

	
	FirstRun: 				BOOL := 0;
	LastCommit: 			fb_LastCommit;
END_VAR

(* 
 * ======================================================================================================================================= 
 * Reset Function
 * =======================================================================================================================================
*)
ResetTOF(
	IN := (PRG_DI.di_LocalReset.PV 
	 OR PRG_IAS.IAS_CTRL_Commands.5 
	 OR PRG_HMI.Reset 
	 OR PRG_StateMain.State = e_Init
	),
	PT := T#5000ms
);

Reset := ResetTOF.Q AND PRG_StateMain.LedBlink;



(* 
 * ======================================================================================================================================= 
 * Breaker Position
 * =======================================================================================================================================
*)

Breaker(
	Reset := Reset,
	DI_1_NC := PRG_DI.di_DcBreakerClosed.PV,
	DI_2_NO := PRG_DI.di_DcBreakerOpen.PV,
	Inhibit_alarm := FALSE,
	Alarm_delay := T#1s,
	Verif_delay := T#0.5s,
	Alarm_inst => ,
	Alarm_delayed => ,
	DI_Verif_delay => ,
	DI_Verif => 
);


(* 
 * ======================================================================================================================================= 
 * Project Version
 * =======================================================================================================================================
*)
Version(
	VersionRead :=  PRG_StateMain.State = e_Init OR Reset,
	CommitHash := LastCommit.LastCommitShort
);	
	

(* 
 * ======================================================================================================================================= 
 * Read git repository commit hash 
 * =======================================================================================================================================
*)
LastCommit;


(* 
 * ======================================================================================================================================= 
 * Time Synch from IAS
 * =======================================================================================================================================
*)	

TimeSynch(
	EN := NOT PRG_IAS.IasCommunication.Alarm,
	Hour := PRG_IAS.IAS_CTRL_Hours,
	Minute := PRG_IAS.IAS_CTRL_Minutes,
	Second := PRG_IAS.IAS_CTRL_Seconds,
	dtTime => ,
	plcTime => 
);


(* 
 * ======================================================================================================================================= 
 * Export retain memory into file
 * =======================================================================================================================================
*)

(*Manual export command from HMI*)
RetainExportRT(CLK := PRG_HMI.RetainExportCmd, Q => );

(*Find date and create file name*)
IF RetainExportRT.Q OR NOT FirstRun THEN
	ModuleData := Tcs_ARG_GetConfig(Dummy := 0);
	InstanceName := ModuleData.Name;	(*Same as module instance name in Software-section in Solution center tree*)
	DateTime :=  RTC_GetClock(dummy := FALSE);
	Filedate := LEFT(RIGHT(STR:=DT_TO_STRING(DateTime.DateAndTime),SIZE:=19 ),10);	(*Format: 2018-12-24*)
	
	(*Build full path and file name for saving the XML file*)
	Filename := '/cfc0/RetainExport/';				(*Save folder*)
	Filename := CONCAT(Filename, InstanceName);		(*Add file name, it starts with the software module instance name*)
	IF RetainExportRT.Q THEN 						(*If manual creation - Add today's date*)
		Filename := CONCAT(Filename, '-');			(*Add a dash before date*)
		Filename := CONCAT(Filename, Filedate);		(*Add date*)
	ELSE 											(*If autosaved on first run, then postfix that the file is autosaved.*)
		Filename := CONCAT(Filename, '-Autosaved');	(* No date as we want the file to be overwritten at each firstrun*)
	END_IF
	Filename := CONCAT(Filename, '.xml');			(*add file format*)
END_IF

(*Do the actual export*)
RetainExport(
	Request := RetainExportRT.Q OR NOT FirstRun,
	FileName := Filename,
	State => RetainState,
	Error => RetainError
);


(*Set flag so that firstrun is not same as secondrun :) *)
FirstRun := TRUE;

END_PROGRAM