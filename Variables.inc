
.const

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; Action Combobox items Index
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
ID_OPERATION_SHUTDOWN					EQU	0
ID_OPERATION_RESTART					EQU	1
ID_OPERATION_STANDBY					EQU	2
ID_OPERATION_LOGOFF						EQU	3
ID_OPERATION_HIBERNATE					EQU	4
ID_OPERATION_LOCK						EQU	5
ID_OPERATION_SHUTMONITOR				EQU	6
ID_OPERATION_STARTSCREENSAVER			EQU 7
ID_OPERATION_LIGHTSHUTDOWN				EQU	8
ID_OPERATION_LIGHTRESTART				EQU	9
ID_OPERATION_EXIT						EQU 10

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; Duration Combobox items Index
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
ID_OPERATION_NOW						EQU 0
ID_OPERATION_ONCE						EQU	1
ID_OPERATION_DAILY						EQU	2
ID_OPERATION_BATCHARGE					EQU	3

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; Tray Menu Item Index
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
ID_RESTORE_TRAY							EQU	150
ID_OPTIONS_TRAY							EQU	151
ID_DASH_TRAY							EQU	152
ID_OPERATION_SHUTDOWN_TRAY				EQU	153
ID_OPERATION_RESTART_TRAY				EQU	154
ID_OPERATION_LOGOFF_TRAY				EQU	155
ID_OPERATION_STANDBY_TRAY				EQU	156
ID_OPERATION_HIBERNATE_TRAY				EQU	157
ID_OPERATION_LOCK_TRAY					EQU	158
ID_OPERATION_SHUTMONITOR_TRAY			EQU	159
ID_OPERATION_STARTSCREENSAVER_TRAY		EQU	160
ID_OPERATION_LIGHTSHUTDOWN_TRAY			EQU	161
ID_OPERATION_LIGHTRESTART_TRAY			EQU	162
ID_DASH_TRAY							EQU	152
ID_EXIT_TRAY							EQU	163

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; Bitmap Index
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
IDB_RESTORE				EQU	5000
IDB_OPTIONS				EQU	5001
IDB_SHUTDOWN			EQU	5002
IDB_RESTART				EQU	5003
IDB_STANDBY				EQU	5004
IDB_LOGOFF				EQU	5005
IDB_HIBERNATE			EQU	5006
IDB_LOCK				EQU	5007
IDB_SHUTMONITOR			EQU	5008
IDB_STARTSCREENSAVER	EQU	5009
IDB_LIGHTSHUTDOWN		EQU	5010
IDB_LIGHTRESTART		EQU	5011
IDB_EXIT				EQU	5012

;Dialog Boxes
IDD_DLGBOX 			equ	1001
IDD_DLGBOX2 		equ 1016
IDD_DLGBOX3			equ 1025

;ComboBox
IDC_CB 				equ	1003
IDC_DURCMBO			EQU	1036

;DateTimePicker
IDC_DTP 			equ	1004

;StatusBar
IDC_SB1 			equ	1011

;Progressbar
IDC_PB1 			equ	1018

;Others
APP_ICON 			equ 2000

;Static Control
IDC_STATICACTION	equ	1014
IDC_STATICMESS 		equ 1023	;Countdown 
IDC_STATICDURATION	equ	1037
IDC_STATICTIME		equ	1040

;Buttons
IDC_START 			equ 1002
IDC_STOP 			equ 1007
IDC_ABOUT 			equ	1015
IDC_NOW 			equ 1020
IDC_CANCEL 			equ	1021
IDC_OPTION 			equ	1024
IDC_OPTIONOK 		equ	1030
IDC_DELREGISTRY		equ	1034


;CheckBoxes
IDC_CHKSTARTUP		equ 1027
IDC_CHKMIN 			equ	1029
IDC_CHKFORCE 		equ	1031
IDC_CHKSOUND 		equ	1032
IDC_CHKDAILY 		equ	1033
IDC_CHKONTOP		equ	1041
IDC_CHKLINK			equ	1042

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; Bitmap Constants
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
BITMAP_HEIGHT				EQU 16
BITMAP_WIDTH				EQU BITMAP_HEIGHT
BITMAP_MARGIN				EQU 2

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; Other constants
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
CRLF				EQU	0Dh,0Ah
WM_SHELLNOTIFY 		equ WM_USER+5
IDI_TRAY 			equ 0

IDC_IMAGEBOX		equ	1043
APP_IMAGE			equ	6000


.data
;Program Name
szProgramName		db	"Shutdowner",0
szVersion			db	"0.50 alpha 1",0

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; Shutdown Strings in the Action Combobox
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
szShutdown			db	"Shutdown",0
szRestart			db	"Restart",0
szLogOff			db	"LogOff",0
szStandby			db	"StandBy",0
szHibernate			db	"Hibernate",0
szLockSystem		db	"Lock WorkStation",0
szOffMonitor		db	"TurnOff Monitor",0
szScreenSaver		db	"TurnOn Screensaver",0
szLightShutdown		db	"Lightning Shutdown",0
szLightRestart		db	"Lightning Restart",0
szExitApp			db	"Exit",0

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; Strings in the Duration Combobox
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
szNow				db	"Now",0
szOnce				db	"One Time",0
szDaily				db	"Daily",0
szCountdown			db	"Countdown",0
szBatCharge			db	"Battery Charge",0

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; Shutdown Strings in Tray
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
szRestoreString		db	"Restore",0
szOptionsString		db	"Options",0
szDash				db	"-",0
szExitString		db	"Exit Shutdowner",0

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; StatusBar Strings
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
szReady				db	"Ready",0
szTimerEnabled		db	"Timer Enabled",0
szTimerDisabled		db	"Timer Disabled",0

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; Registry Strings
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
szKeyPathStartup		db	"Software\Microsoft\Windows\CurrentVersion\Run",0
szKeyApplication		db	"Software\Shutdowner",0
lpszBuffer1				db	120 dup(0)
szStringLength1			dd	SIZEOF lpszBuffer1
szMinimise				db	"Minimise",0
szForce					db	"Force Quit",0
szStartup				db	"Startup",0
szSound					db	"Sound",0
;szDaily					db	"Daily",0
szDailyDataHigh			db	"DailyDataHigh",0
szDailyDataLow			db	"DailyDataLow",0
szHour					db	"Hour",0
szMinute				db	"Minute",0
szSeconds				db	"Seconds",0
szSelection				db	"SelectedAction",0
dwValue1				dd	1
szTime					db	"Time",0
szTimer					db	"Timer",0
szOpen					db	"open",0
szFileName				db	"logon.scr",0


; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; Information Strings
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
szNoNT				db	"Program will work only in NT based systems!",0
szExitInfo			db	"Are you sure you want to quit shutdowner ?",0
szEnd				db	"Exit Shutdowner ?." ,0
szErrorCaption		db	"Error",0
;About MessageBox
szAboutInfo							db	" ",CRLF
									db	" Shutdowner 0.30  ",CRLF
									db	" Creator	:  Lahar ",CRLF
									db	" Contact : Laharrush@yahoo.com",CRLF	
									db	" =====================================",CRLF	
									db	" ", CRLF
									db	" Shutdowner is a small app created in Win32Asm to do ",CRLF
									db	" operations such as Shutdown, Restart, Hibernate etc.",CRLF
									db	" =====================================",CRLF
									db	" ", CRLF
									db  " I am extremly thankful to WinAsm forum and members.", CRLF
									db	" Especially samael, without his Help and Codes, this app ",CRLF
									db  " may rested still in its birth. ",CRLF  
									db	" =====================================",CRLF
									db	" ", CRLF
									db  " Comments, Suggestions and Bug reports are all welcome",CRLF
									db  " _________________________________________________     ",0

;Others
stCountFont LOGFONT <18,0,0,0,FW_ULTRABOLD,0,0,0,DEFAULT_CHARSET,OUT_TT_PRECIS,0,0,0,"Tahoma">
stButtonFont LOGFONT <13,0,0,0,FW_SEMIBOLD,0,0,0,DEFAULT_CHARSET,OUT_TT_PRECIS,0,0,0,"Tahoma">

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; Formats
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
dtpFormat			db	"   h:mm:ss ",0
szCountFormat		db	"%d",0
sbParts				dd	75,160,210,-1
nDword				db	"%d",0
	
	
.data?
hPopupMenu		HMENU		?
hInstance		HINSTANCE	?
DlgHandle		dword		?
DlgHandle2		dword		?
hThread0		dword		?
hThread2		dword		?
hThread			dword		?
ThreadID		dword		?
lpExitCode1		dword		?
lpExitCode2		dword		?
lpExitCode3		dword		?

DlgMessage		dword		?
DlgMessage2		dword		?

nValue			dword		?
nNew			dword		?
hButtonID		DWORD		?
hButtonStopID	dword		?
dtpID			DWORD		?
CheckID			DWORD ?
dwSelectedOperation	DWORD	?
dwSelectedDuration	DWORD	?
szRegBuffer			db	150	dup(?)

hBmpRestore			HBITMAP ?
hBmpOptions			HBITMAP ?
hBmpShutdown		HBITMAP ?	
hBmpRestart			HBITMAP ?
hBmpStandby			HBITMAP ?
hBmpLogoff			HBITMAP ?
hBmpHibernate		HBITMAP ?
hBmpLock			HBITMAP ?
hBmpMonitor			HBITMAP ?
hBmpScreensaver		HBITMAP ?
hBmpLightShutdown	HBITMAP ?
hBmpLightRestart	HBITMAP	?
hBmpExit			HBITMAP ?	

osvi	OSVERSIONINFO <>
note	NOTIFYICONDATA <>
icex 	INITCOMMONCONTROLSEX <>



