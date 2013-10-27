;Shutdowner 0.50 by Lahar
;Shutdowner is a small utility to combine all the windows power functions 
;Shutdowner is created in Win32Asm
;Shutdowner happened due to the support of various people including samael, Vortex and all WinAsm forum members

.686
.MODEL FLAT, STDCALL
OPTION CASEMAP: NONE

include includes.inc
include Variables.inc
include RegistryProc.asm
include ShutdownActions.asm


.CODE
start:

	;Checking for other instance of the progran
	invoke CreateMutex, NULL,TRUE,ADDR szProgramName
	.IF (eax)
        invoke GetLastError
        .IF (eax==ERROR_ALREADY_EXISTS)
        	;If found an instance, simply close the second instance
			invoke ExitProcess, NULL
		.ELSE	
			MOV osvi.OSVERSIONINFO.dwOSVersionInfoSize, sizeof osvi
			invoke GetVersionEx, addr osvi
			MOV EAX, osvi.OSVERSIONINFO.dwPlatformId	
			.if EAX == 2	;2 Means Windows NT
				invoke GetModuleHandle, NULL
				MOV hInstance, EAX
				mov icex.dwSize,sizeof INITCOMMONCONTROLSEX
    			mov icex.dwICC,ICC_DATE_CLASSES
    			;mov icex.dwICC,ICC_PROGRESS_CLASS
    			;mov icex.dwICC,ICC_BAR_CLASSES
    			;mov icex.dwICC,ICC_LISTVIEW_CLASSES
    			;mov icex.dwICC,ICC_STANDARD_CLASSES
    			;mov icex.dwICC,ICC_USEREX_CLASSES
    			;mov icex.dwICC,ICC_WIN95_CLASSES
    			;mov icex.dwICC,ICC_NATIVEFNTCTL_CLASS
    			invoke InitCommonControlsEx,ADDR icex 
    			invoke InitCommonControls
				invoke GetCommandLine
				;invoke MessageBox, 0, eax, addr szErrorCaption, MB_OK + MB_ICONINFORMATION
				invoke DialogBoxParam, hInstance, IDD_DLGBOX, NULL, ADDR DlgProc, NULL
				invoke ExitProcess, 0
			.else
				invoke MessageBox, 0, addr szNoNT, addr szErrorCaption, MB_OK + MB_ICONINFORMATION
				invoke ExitProcess, 0
			.endif	 	
		.ENDIF
	.ENDIF	

;Our Main Dialog Procedure.	
DlgProc PROC hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM	
LOCAL hIcon				:HICON
LOCAL hFont				:HFONT
LOCAL hbmIcon 			:HBITMAP
LOCAL clrBackground  	:COLORREF
LOCAL clrForeground 	:COLORREF
LOCAL pt				:POINT
LOCAL tm				:TEXTMETRIC
LOCAL x					:DWORD
LOCAL y					:DWORD
LOCAL hdc				:HDC
LOCAL szBuffers [200] 	:BYTE
LOCAL szRegHandle1		: DWORD
LOCAL szRegHandle2		: DWORD

;Local Strings using 'sas' macro
LOCAL szCompleted$ 		: DWORD
LOCAL szAboutCaption$ 	: DWORD
LOCAL szOnce$			: DWORD
LOCAL szNull$			: DWORD

sas szCompleted$,"Done!"
sas szAboutCaption$,"Shutdowner Info"
sas szOnce$,"One Time"
sas szNull$," "

m2m DlgHandle, hWnd
m2m DlgMessage, uMsg


	.IF	uMsg == WM_CREATE
		invoke ShowWindow, hWnd,SW_MINIMIZE 
		
	.ELSEIF uMsg == WM_INITDIALOG
		
  		;invoke KeyValueStringCheck, addr szKeyApplication,addr szHour

		;Setting Caption of the App
		invoke SetWindowText, hWnd, ADDR szProgramName
		
		;Set Icon
		invoke LoadIcon, hInstance, APP_ICON
		mov hIcon, eax
		invoke SendMessage, hWnd, WM_SETICON, 1, hIcon
		
		;Load custom fonts 
		invoke CreateFontIndirect,addr stButtonFont
		mov hFont, eax
		;For buttons
		invoke SendDlgItemMessage, hWnd, IDC_START, WM_SETFONT, hFont, TRUE
		invoke SendDlgItemMessage, hWnd, IDC_STOP, WM_SETFONT, hFont, TRUE
		invoke SendDlgItemMessage, hWnd, IDC_ABOUT, WM_SETFONT, hFont, TRUE
		invoke SendDlgItemMessage, hWnd, IDC_OPTION, WM_SETFONT, hFont, TRUE
		;For static cotrols
		invoke SendDlgItemMessage, hWnd, IDC_STATICACTION, WM_SETFONT, hFont, TRUE
		invoke SendDlgItemMessage, hWnd, IDC_STATICDURATION, WM_SETFONT, hFont, TRUE
		invoke SendDlgItemMessage, hWnd, IDC_STATICTIME, WM_SETFONT, hFont, TRUE
		;For Combobox
		invoke SendDlgItemMessage, hWnd, IDC_CB, WM_SETFONT, hFont, TRUE
		invoke SendDlgItemMessage, hWnd, IDC_DURCMBO, WM_SETFONT, hFont, TRUE		
		
		;Load Bitmaps
		invoke LoadBitmaps
		
		;Enter data into Action combobox
		invoke SendDlgItemMessage, hWnd, IDC_CB,CB_INSERTSTRING,ID_OPERATION_SHUTDOWN,ADDR szShutdown
		invoke SendDlgItemMessage, hWnd, IDC_CB,CB_INSERTSTRING,ID_OPERATION_RESTART,ADDR szRestart
		invoke SendDlgItemMessage, hWnd, IDC_CB,CB_INSERTSTRING,ID_OPERATION_STANDBY, ADDR szStandby
		invoke SendDlgItemMessage, hWnd, IDC_CB,CB_INSERTSTRING,ID_OPERATION_LOGOFF,ADDR szLogOff
		invoke SendDlgItemMessage, hWnd, IDC_CB,CB_INSERTSTRING,ID_OPERATION_HIBERNATE, ADDR szHibernate
		invoke SendDlgItemMessage, hWnd, IDC_CB,CB_INSERTSTRING,ID_OPERATION_LOCK, ADDR szLockSystem
		invoke SendDlgItemMessage, hWnd, IDC_CB,CB_INSERTSTRING,ID_OPERATION_SHUTMONITOR, ADDR szOffMonitor
		invoke SendDlgItemMessage, hWnd, IDC_CB,CB_INSERTSTRING,ID_OPERATION_STARTSCREENSAVER,ADDR szScreenSaver
		invoke SendDlgItemMessage, hWnd, IDC_CB,CB_INSERTSTRING,ID_OPERATION_LIGHTSHUTDOWN,ADDR szLightShutdown
		invoke SendDlgItemMessage, hWnd, IDC_CB,CB_INSERTSTRING,ID_OPERATION_LIGHTRESTART,ADDR szLightRestart
		invoke SendDlgItemMessage, hWnd, IDC_CB,CB_INSERTSTRING,ID_OPERATION_EXIT, ADDR szExitApp
		
		;Select Exit as Default option
		invoke SendDlgItemMessage, hWnd, IDC_CB,CB_SELECTSTRING,NULL, ADDR szExitApp
		MOV dwSelectedOperation,ID_OPERATION_EXIT
		
		;Enter data into Duration combobox
		invoke SendDlgItemMessage, hWnd, IDC_DURCMBO,CB_INSERTSTRING,ID_OPERATION_NOW,ADDR szNow
		invoke SendDlgItemMessage, hWnd, IDC_DURCMBO,CB_INSERTSTRING,ID_OPERATION_ONCE,ADDR szOnce
		invoke SendDlgItemMessage, hWnd, IDC_DURCMBO,CB_INSERTSTRING,ID_OPERATION_DAILY,ADDR szDaily
		invoke SendDlgItemMessage, hWnd, IDC_DURCMBO,CB_INSERTSTRING,ID_OPERATION_BATCHARGE,ADDR szBatCharge
		
		invoke SendDlgItemMessage, hWnd, IDC_DURCMBO,CB_SELECTSTRING,NULL, ADDR szNow
		MOV dwSelectedDuration,ID_OPERATION_ONCE
			
		;Obtaining the handle of DTP & diabling it
		invoke GetDlgItem, hWnd, IDC_DTP
		mov dtpID,eax
		invoke EnableWindow,eax,FALSE
		
		;Obtaining the handle of Start button & diabling it
		invoke GetDlgItem, hWnd, IDC_START
		mov hButtonID, eax
		invoke EnableWindow, eax,FALSE
		
		;Obtaining the handle of Stop button & diabling it
		invoke GetDlgItem, hWnd, IDC_STOP
		mov hButtonStopID, eax
		invoke EnableWindow, eax,FALSE
		
		;NOTIFYICONDATA Structure
		mov note.NOTIFYICONDATA.cbSize, sizeof NOTIFYICONDATA
		push hWnd 
        pop note.hwnd 
		mov note.NOTIFYICONDATA.uID, IDI_TRAY
		mov note.NOTIFYICONDATA.uFlags, NIF_ICON+NIF_MESSAGE+NIF_TIP
		mov note.NOTIFYICONDATA.uCallbackMessage, WM_SHELLNOTIFY
		push hIcon
		pop note.NOTIFYICONDATA.hIcon
		invoke lstrcpy,addr note.NOTIFYICONDATA.szTip,addr szProgramName
		
		
		;Create Tray Menu
		invoke CreatePopupMenu 
		mov hPopupMenu, eax
		invoke AppendMenu,hPopupMenu,MF_STRING,ID_RESTORE_TRAY, addr szRestoreString
		invoke AppendMenu,hPopupMenu,MF_STRING,ID_OPTIONS_TRAY, addr szOptionsString
		invoke AppendMenu,hPopupMenu,MF_SEPARATOR,ID_DASH_TRAY, addr szDash
		invoke AppendMenu,hPopupMenu,MF_STRING,ID_OPERATION_SHUTDOWN_TRAY, addr szShutdown
		invoke AppendMenu,hPopupMenu,MF_STRING,ID_OPERATION_RESTART_TRAY, addr szRestart
		invoke AppendMenu,hPopupMenu,MF_STRING,ID_OPERATION_STANDBY_TRAY, addr szStandby
		invoke AppendMenu,hPopupMenu,MF_STRING,ID_OPERATION_LOGOFF_TRAY, addr szLogOff
		invoke AppendMenu,hPopupMenu,MF_STRING,ID_OPERATION_HIBERNATE_TRAY, addr szHibernate
		invoke AppendMenu,hPopupMenu,MF_STRING,ID_OPERATION_LOCK_TRAY, addr szLockSystem
		invoke AppendMenu,hPopupMenu,MF_STRING,ID_OPERATION_SHUTMONITOR_TRAY, addr szOffMonitor
		invoke AppendMenu,hPopupMenu,MF_STRING,ID_OPERATION_STARTSCREENSAVER_TRAY, addr szScreenSaver
		invoke AppendMenu,hPopupMenu,MF_SEPARATOR,ID_RESTORE_TRAY, addr szDash
		invoke AppendMenu,hPopupMenu,MF_STRING,ID_OPERATION_LIGHTSHUTDOWN_TRAY, addr szLightShutdown
		invoke AppendMenu,hPopupMenu,MF_STRING,ID_OPERATION_LIGHTRESTART_TRAY, addr szLightRestart
		invoke AppendMenu,hPopupMenu,MF_SEPARATOR,ID_RESTORE_TRAY, addr szDash
		invoke AppendMenu,hPopupMenu,MF_STRING,ID_EXIT_TRAY, addr szExitString


		;Creating Icons for the menu items in Tray

		invoke SetMenuItemBitmaps, hPopupMenu, ID_RESTORE_TRAY, 0, hBmpRestore, NULL
		invoke SetMenuItemBitmaps, hPopupMenu, ID_OPTIONS_TRAY, 0, hBmpOptions, NULL
		invoke SetMenuItemBitmaps, hPopupMenu, ID_OPERATION_SHUTDOWN_TRAY, 0, hBmpShutdown, NULL
		invoke SetMenuItemBitmaps, hPopupMenu, ID_OPERATION_RESTART_TRAY, 0, hBmpRestart, NULL
		invoke SetMenuItemBitmaps, hPopupMenu, ID_OPERATION_STANDBY_TRAY, 0, hBmpStandby, NULL
		invoke SetMenuItemBitmaps, hPopupMenu, ID_OPERATION_LOGOFF_TRAY, 0, hBmpLogoff, NULL
		invoke SetMenuItemBitmaps, hPopupMenu, ID_OPERATION_HIBERNATE_TRAY, 0, hBmpHibernate, NULL
		invoke SetMenuItemBitmaps, hPopupMenu, ID_OPERATION_LOCK_TRAY, 0, hBmpLock, NULL
		invoke SetMenuItemBitmaps, hPopupMenu, ID_OPERATION_SHUTMONITOR_TRAY, 0, hBmpMonitor, NULL
		invoke SetMenuItemBitmaps, hPopupMenu, ID_OPERATION_STARTSCREENSAVER_TRAY, 0, hBmpScreensaver, NULL
		invoke SetMenuItemBitmaps, hPopupMenu, ID_OPERATION_LIGHTSHUTDOWN_TRAY, 0, hBmpLightShutdown, NULL
		invoke SetMenuItemBitmaps, hPopupMenu, ID_OPERATION_LIGHTRESTART_TRAY, 0, hBmpLightRestart, NULL
		invoke SetMenuItemBitmaps, hPopupMenu, ID_EXIT_TRAY, 0, hBmpExit, NULL
		
		
		;Setting format of Date Time Picker
		invoke SendDlgItemMessage, hWnd, dtpID, DTM_SETFORMAT,0,addr dtpFormat		
		
		;Set the Statusbar parts into 4
		invoke SendDlgItemMessage,hWnd, IDC_SB1,SB_SETPARTS,4, ADDR sbParts
		
		
		;Show Ready and Timer diabled in statusbar
		invoke SendDlgItemMessage,hWnd, IDC_SB1,SB_SETTEXT,1,addr szTimerDisabled
		invoke SendDlgItemMessage,hWnd, IDC_SB1,SB_SETTEXT,0,addr szReady
		
		;To show time in status bar
		comment ~
		Uncomment to show time in status bar
		invoke CreateThread, NULL, NULL, addr CurrentTime, NULL,NULL, addr ThreadID 
		mov hThread0, eax
		invoke SetThreadPriority, hThread0, THREAD_PRIORITY_LOWEST
		~
		;Registry checking on Minimise on startup
		invoke KeyValueCheck, addr szKeyApplication, addr szMinimise
		.if  nValue == TRUE	
			invoke ShowWindowAsync,hWnd,SW_HIDE
			invoke ShowWindowAsync,hWnd,SW_SHOW
			invoke ShowWindowAsync,hWnd,SW_MINIMIZE
			invoke ShowWindowAsync,hWnd,SW_HIDE
			invoke Shell_NotifyIcon,NIM_ADD,addr note 
		.endif	

	.ELSEIF uMsg == WM_MEASUREITEM
		MOV EAX, lParam
		.IF (([EAX][MEASUREITEMSTRUCT.itemHeight])<(BITMAP_HEIGHT+(2*BITMAP_MARGIN)))
			MOV [EAX][MEASUREITEMSTRUCT.itemHeight],(BITMAP_HEIGHT+(2*BITMAP_MARGIN))
		.ENDIF	
		
	.ELSEIF (uMsg ==WM_DRAWITEM)	
		MOV EDX, lParam	
		
		;ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
		;Determine the bitmaps used to draw the icon.
		;ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
		
		.if ([EDX][DRAWITEMSTRUCT.itemID]==-1)
			ret
		.elseif ([EDX][DRAWITEMSTRUCT.itemID] == ID_OPERATION_SHUTDOWN)
			m2m hbmIcon,hBmpShutdown
		.elseif ([EDX][DRAWITEMSTRUCT.itemID] == ID_OPERATION_RESTART)
			m2m hbmIcon,hBmpRestart
		.elseif ([EDX][DRAWITEMSTRUCT.itemID] == ID_OPERATION_STANDBY)
			m2m hbmIcon,hBmpStandby
		.elseif ([EDX][DRAWITEMSTRUCT.itemID] == ID_OPERATION_LOGOFF)
			m2m hbmIcon,hBmpLogoff
		.elseif ([EDX][DRAWITEMSTRUCT.itemID] == ID_OPERATION_HIBERNATE)
			m2m hbmIcon,hBmpHibernate
		.elseif ([EDX][DRAWITEMSTRUCT.itemID] == ID_OPERATION_LOCK)
			m2m hbmIcon,hBmpLock	
		.elseif ([EDX][DRAWITEMSTRUCT.itemID] == ID_OPERATION_SHUTMONITOR)
			m2m hbmIcon,hBmpMonitor
		.elseif ([EDX][DRAWITEMSTRUCT.itemID] == ID_OPERATION_STARTSCREENSAVER)
			m2m hbmIcon,hBmpScreensaver	
		.elseif ([EDX][DRAWITEMSTRUCT.itemID] == ID_OPERATION_LIGHTSHUTDOWN)
			m2m hbmIcon,hBmpLightShutdown
		.elseif ([EDX][DRAWITEMSTRUCT.itemID] == ID_OPERATION_LIGHTRESTART)
			m2m hbmIcon,hBmpLightRestart	
		.elseif ([EDX][DRAWITEMSTRUCT.itemID] == ID_OPERATION_EXIT)
			m2m hbmIcon,hBmpExit
		.endif	
		
		; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
		;The colors depend on whether the item is selected
		; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
		
		MOV EDX, lParam
		.IF ([EDX][DRAWITEMSTRUCT.itemState] &ODS_SELECTED)
			MOV clrForeground, COLOR_HIGHLIGHTTEXT
			MOV clrBackground, COLOR_HIGHLIGHT    
		.ELSE
			MOV clrForeground, COLOR_WINDOWTEXT
			MOV clrBackground, COLOR_WINDOW
		.ENDIF	
		
		invoke GetSysColor,clrForeground
		invoke SetTextColor,([EDX][DRAWITEMSTRUCT.hdc]), EAX
		MOV clrForeground,EAX
		invoke GetSysColor,clrBackground
		invoke SetBkColor,([EDX][DRAWITEMSTRUCT.hdc]), EAX
		MOV clrForeground,EAX	
		
		; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
		;Calculate the vertical position.
		; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл			
		LEA EAX, tm
		invoke GetTextMetrics,([EDX][DRAWITEMSTRUCT.hdc]),EAX		
		MOV EDX, lParam
		MOV EAX,([EDX][DRAWITEMSTRUCT.rcItem.bottom]) 
		ADD EAX,([EDX][DRAWITEMSTRUCT.rcItem.top])  
		SUB EAX,tm.tmHeight
		SHR EAX,1 ; Divide by 2
		MOV y,EAX

		; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
		;Calculate the horizontal position.
		; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
		invoke GetDialogBaseUnits
		MOVZX EAX, AX
		SHR EAX,2 ; Divide by 4
		MOV x,EAX
	
		; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
		;Get and display the text for the list item.
		; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
		MOV EDX, lParam
		LEA ESI, szBuffers
		invoke SendMessage, ([EDX][DRAWITEMSTRUCT.hwndItem]), CB_GETLBTEXT, \
			([EDX][DRAWITEMSTRUCT.itemID]),  ESI
		
		MOV EDI,x
		SHL EDI,1
		ADD EDI, BITMAP_WIDTH
		
		invoke lstrlen, ESI
		MOV ECX,EAX 
		MOV EDX, lParam
		LEA ESI, szBuffers
		invoke ExtTextOut,([EDX][DRAWITEMSTRUCT.hdc]),EDI,y,ETO_CLIPPED OR ETO_OPAQUE,\
		ADDR ([EDX][DRAWITEMSTRUCT.rcItem]),ESI,ECX,NULL
		
		; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
		;Restore the previous colors.
		; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл			
		MOV EDX, lParam
		invoke SetTextColor,([EDX][DRAWITEMSTRUCT.hdc]), clrForeground
        invoke SetBkColor,([EDX][DRAWITEMSTRUCT.hdc]), clrBackground

		; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
		;Show the icon.
		; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл			
		MOV EDX, lParam
		invoke CreateCompatibleDC, ([EDX][DRAWITEMSTRUCT.hdc])
        .IF (EAX == NULL) 
			ret
		.ELSE
			MOV hdc,EAX
		.ENDIF

		invoke SelectObject,hdc,hbmIcon
		MOV EDX, lParam
		MOV EAX, ([EDX][DRAWITEMSTRUCT.rcItem.top])
		ADD EAX, BITMAP_MARGIN
        invoke BitBlt, ([EDX][DRAWITEMSTRUCT.hdc]), x, EAX, BITMAP_WIDTH, BITMAP_HEIGHT, hdc, NULL, NULL, SRCCOPY	
        invoke DeleteDC,hdc

		;ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
		; If the item has the focus, draw focus rectangle.
		;ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
		MOV EDX, lParam
		.IF ([EDX][DRAWITEMSTRUCT.itemState] &ODS_FOCUS)
			invoke DrawFocusRect,([EDX][DRAWITEMSTRUCT.hdc]), ADDR ([EDX][DRAWITEMSTRUCT.rcItem]) 
		.ENDIF
	  	
	.ELSEIF uMsg == WM_COMMAND
		MOV EAX, wParam	
		.IF AX == IDC_CB
    		SHR EAX,16
    		.IF AX == CBN_SELCHANGE
    			;Selection changes in Combobox, Save ans select current selection & Enable OK button
    			invoke SendDlgItemMessage, hWnd,IDC_CB,CB_GETCURSEL,NULL,NULL
				MOV dwSelectedOperation,eax
				invoke SendDlgItemMessage, hWnd,IDC_DURCMBO,CB_GETCURSEL,NULL,NULL
				MOV dwSelectedDuration, eax
				invoke EnableWindow,hButtonID, TRUE
				.if dwSelectedDuration == 1
					invoke EnableWindow, dtpID, TRUE
				.endif	
    		.ENDIF
    	.ELSEIF AX == IDC_DURCMBO
    	    	SHR EAX,16
    			.IF AX == CBN_SELCHANGE
    				invoke SendDlgItemMessage, hWnd,IDC_DURCMBO,CB_GETCURSEL,NULL,NULL
					MOV dwSelectedDuration, eax
					invoke EnableWindow,hButtonID, TRUE
					.if dwSelectedDuration == ID_OPERATION_ONCE
						invoke SendDlgItemMessage, hWnd, IDC_STATICTIME,WM_SETTEXT,0,addr szTime
						invoke SendDlgItemMessage, hWnd, dtpID, DTM_SETFORMAT,0,addr dtpFormat	
						invoke EnableWindow, dtpID, TRUE
					.elseif dwSelectedDuration == ID_OPERATION_DAILY
						invoke SendDlgItemMessage, hWnd, dtpID,DTS_UPDOWN,1,addr dtpFormat
						invoke SendDlgItemMessage, hWnd, dtpID, DTM_SETFORMAT,0,addr dtpFormat	
						invoke EnableWindow, dtpID, TRUE
						invoke SendDlgItemMessage, hWnd, IDC_STATICTIME,WM_SETTEXT, 0, addr szDaily	
						;invoke SendDlgItemMessage, hWnd, dtpID, DTS_TIMEFORMAT+DTS_UPDOWN,0,addr dtpFormat	
						invoke SendDlgItemMessage, hWnd, dtpID, DTS_UPDOWN,1,1
					.elseif dwSelectedDuration ==  ID_OPERATION_BATCHARGE
						invoke SendDlgItemMessage, hWnd, IDC_STATICTIME,WM_SETTEXT, 0, addr szBatCharge
					.endif	
				.ENDIF	
		.ELSEIF (AX == IDC_START)
		comment ~
				;Checks Checkbox is ticked while pressing OK
			    invoke IsDlgButtonChecked, hWnd, IDC_CHK1
    			.IF EAX == BST_CHECKED
    				
    				
    				;Show confirmed message and diable button,DTP & enable stop Button    				
    				invoke SendDlgItemMessage, hWnd, IDC_SB1,SB_SETTEXT,1,szCompleted$
    				
    				invoke SendDlgItemMessage, hWnd, IDC_CHK1,BM_SETCHECK,BST_UNCHECKED	,0
    				invoke EnableWindow, dtpID, FALSE
    				invoke EnableWindow, hButtonID, FALSE  
    				invoke EnableWindow, hButtonStopID, TRUE 
    				
    			~
    				;Create an ICon in tray
    				invoke Shell_NotifyIcon,NIM_ADD,addr note 
    				
    				;If previous threads are active, Inactivate them
    				invoke GetExitCodeThread, hThread,addr lpExitCode1
					invoke TerminateThread,hThread, lpExitCode1	
					invoke GetExitCodeThread, hThread2,addr lpExitCode2
					invoke TerminateThread,hThread2, lpExitCode2

    			
    			;If chosen action is Exit, Exit the app immediately	
				.IF dwSelectedOperation == ID_OPERATION_EXIT 
					invoke DoOperations,hWnd
    			.ELSE
    				;if Checkbox is not checked, Directly do the operation
    				invoke ShowWindow, hWnd,SW_MINIMIZE
    				
    				.if dwSelectedDuration == ID_OPERATION_NOW
						;Code for Now			
    					invoke DialogBoxParam, hInstance, IDD_DLGBOX2,hWnd, addr DlgProc2, NULL
    				.elseif dwSelectedDuration ==  ID_OPERATION_ONCE
    					;Code for OneTime	
    				 	invoke EnableWindow, dtpID, TRUE
    					invoke CreateThread,0,0,addr TimerProc,0,0,addr ThreadID
    					mov hThread, eax
    					invoke SetThreadPriority, hThread, THREAD_PRIORITY_LOWEST	
    					invoke SendDlgItemMessage, hWnd, IDC_SB1,SB_SETTEXT,3,szOnce$
    					invoke EnableWindow, hButtonID, FALSE  
    					invoke EnableWindow, hButtonStopID, TRUE 
    				.elseif dwSelectedDuration ==  ID_OPERATION_DAILY
    				    ;Code for Daily
    				.elseif dwSelectedDuration ==  ID_OPERATION_BATCHARGE
    					;Battery Charge
    				.endif	
    				
    			.ENDIF	
    	
    	;Stop the Timer thread		
    	.ELSEIF EAX == IDC_STOP
    			invoke GetExitCodeThread, hThread,addr lpExitCode1
				invoke TerminateThread,hThread, lpExitCode1	
    			invoke SendDlgItemMessage,hWnd, IDC_SB1,SB_SETTEXT,1,addr szTimerDisabled
    			invoke SendDlgItemMessage,hWnd, IDC_SB1,SB_SETTEXT,3,szNull$
    	
    	;About Button
    	.ELSEIF	EAX == IDC_ABOUT
    		invoke MessageBox, hWnd,addr szAboutInfo,szAboutCaption$, MB_OK+ MB_ICONINFORMATION	
    	
    	;Options Button
    	.ELSEIF EAX == IDC_OPTION
    		invoke DialogBoxParam, hInstance, IDD_DLGBOX3, hWnd, addr DlgProc3, NULL
    	
    	;Restore From Tray			
    	.ELSEIF EAX == ID_RESTORE_TRAY
    		;If user select Restore from Tray
            invoke ShowWindow,hWnd,SW_RESTORE 
         
        .ELSEIF EAX == ID_OPTIONS_TRAY
         invoke DialogBoxParam, hInstance, IDD_DLGBOX3, hWnd, addr DlgProc3, NULL   
         
         ;Tray Shutdown   
        .ELSEIF EAX == ID_OPERATION_SHUTDOWN_TRAY
        	MOV dwSelectedOperation,ID_OPERATION_SHUTDOWN
        	invoke DoOperations,hWnd
        
        ;Tray Restart	
        .ELSEIF EAX == ID_OPERATION_RESTART_TRAY
        	MOV dwSelectedOperation,ID_OPERATION_RESTART
        	invoke DoOperations,hWnd	
        
        ;Tray Standby	
        .ELSEIF EAX == ID_OPERATION_STANDBY_TRAY
        	MOV dwSelectedOperation,ID_OPERATION_STANDBY
        	invoke DoOperations,hWnd
        
        ;Tray LogOff	
        .ELSEIF EAX == ID_OPERATION_LOGOFF_TRAY
        	MOV dwSelectedOperation,ID_OPERATION_LOGOFF
        	invoke DoOperations,hWnd
        
        ;Tray Hibernation	
        .ELSEIF EAX == ID_OPERATION_HIBERNATE_TRAY
        	MOV dwSelectedOperation,ID_OPERATION_HIBERNATE
        	invoke DoOperations,hWnd
        
        ;Lock Workstation
         .ELSEIF EAX == ID_OPERATION_LOCK_TRAY
            MOV dwSelectedOperation,ID_OPERATION_LOCK
        	invoke DoOperations,hWnd
        
        ;Tray Shutmonitor		
        .ELSEIF EAX == ID_OPERATION_SHUTMONITOR_TRAY
		    MOV dwSelectedOperation,ID_OPERATION_SHUTMONITOR
        	invoke DoOperations,hWnd
		      
        ;Tray Screensaver	
        .ELSEIF EAX == ID_OPERATION_STARTSCREENSAVER_TRAY
			MOV dwSelectedOperation,ID_OPERATION_STARTSCREENSAVER
        	invoke DoOperations,hWnd
			    
		;Lightning Shutdown	       
		.ELSEIF EAX == ID_OPERATION_LIGHTSHUTDOWN_TRAY
			MOV dwSelectedOperation,ID_OPERATION_LIGHTSHUTDOWN
        	invoke DoOperations,hWnd
		
		;Lightning Restart
		.ELSEIF EAX == ID_OPERATION_LIGHTRESTART_TRAY	
			MOV dwSelectedOperation,ID_OPERATION_LIGHTRESTART
        	invoke DoOperations,hWnd
			       
        ;Tray Exit			    
        .ELSEIF eax == ID_EXIT_TRAY
        ;Uncomment below statements to show messagebox when clicking Exit Shutdowner
        ;invoke MessageBox, hWnd, addr szExitInfo, addr szEnd,MB_YESNO + MB_ICONQUESTION
		;	.if EAX == IDYES
				invoke GetExitCodeThread, hThread0,addr lpExitCode3
				invoke TerminateThread,hThread0, lpExitCode3
				invoke Shell_NotifyIcon,NIM_DELETE,addr note 	
				invoke DestroyWindow,hWnd 	
		;	.elseif EAX == IDNO	
		;		invoke Shell_NotifyIcon,NIM_MODIFY,addr note 	
    	;		invoke ShowWindow,hWnd,SW_HIDE
    	;	.endif			
		.ENDIF
		
	;Move to Tray when minimise button pressed		
	 .ELSEIF uMsg==WM_SIZE 
        .if wParam == SIZE_MINIMIZED 
        	invoke ShowWindow,hWnd,SW_HIDE
        	invoke Shell_NotifyIcon,NIM_ADD,addr note 		
        .endif 
	
	;If mouse ia above Tray Icon	
	 .ELSEIF uMsg == WM_SHELLNOTIFY
		.IF wParam == IDI_TRAY
		    .IF lParam==WM_RBUTTONDOWN 
		    	;If Rightclicked
                invoke GetCursorPos,addr pt 
                invoke SetForegroundWindow,hWnd 
                invoke TrackPopupMenu,hPopupMenu,TPM_RIGHTALIGN,pt.x,pt.y,NULL,hWnd,NULL 
                invoke SendMessage,hWnd,WM_NULL,0,0 
            .ELSEIF lParam==WM_LBUTTONDBLCLK 
            	;If double clicked on the icon
                invoke SendMessage,hWnd,WM_COMMAND,ID_RESTORE_TRAY,0 
                invoke SetForegroundWindow,hWnd
            .ENDIF
		.ENDIF
			
	;Move the Main App window with Mousemove	
	.ELSEIF (uMsg == WM_MOUSEMOVE)
   		.IF (wParam == MK_LBUTTON) 
   			invoke ReleaseCapture
   			invoke SendMessage, hWnd,WM_SYSCOMMAND,SC_MOVE + 2,NULL;
   			invoke UpdateWindow,hWnd
   		.ENDIF	
   	
   	;Delete Bitmap handles
   	.ELSEIF uMsg == WM_DESTROY
   		invoke DeleteBitmaps 		
   		 	
   	;When user selects close in App, go to Tray instead on Actual App close		
	.ELSEIF (uMsg == WM_CLOSE)		
			invoke Shell_NotifyIcon,NIM_ADD,addr note 	
    		invoke ShowWindow,hWnd,SW_HIDE  	 
	.ENDIF
	XOR EAX, EAX			
	RET
DlgProc EndP

;Loading Bitmaps
LoadBitmaps proc
		invoke LoadBitmap, hInstance, IDB_RESTORE
		mov hBmpRestore, eax
		invoke LoadBitmap, hInstance, IDB_OPTIONS
		mov hBmpOptions, eax
		invoke LoadBitmap, hInstance, IDB_SHUTDOWN
		mov hBmpShutdown, eax
		invoke LoadBitmap, hInstance, IDB_RESTART
		mov hBmpRestart, eax
		invoke LoadBitmap, hInstance, IDB_STANDBY
		mov hBmpStandby, eax
		invoke LoadBitmap, hInstance, IDB_LOGOFF
		mov hBmpLogoff, eax
		invoke LoadBitmap, hInstance, IDB_HIBERNATE
		mov hBmpHibernate, eax
		invoke LoadBitmap, hInstance, IDB_LOCK
		mov hBmpLock, eax
		invoke LoadBitmap, hInstance, IDB_SHUTMONITOR
		mov hBmpMonitor, eax
		invoke LoadBitmap, hInstance, IDB_STARTSCREENSAVER
		mov hBmpScreensaver, eax
		invoke LoadBitmap, hInstance, IDB_LIGHTSHUTDOWN
		mov hBmpLightShutdown, eax	
		invoke LoadBitmap, hInstance, IDB_LIGHTRESTART
		mov hBmpLightRestart, eax	
		invoke LoadBitmap, hInstance, IDB_EXIT
		mov hBmpExit, eax		
	Ret
LoadBitmaps EndP

;Deleting Bitmaps
DeleteBitmaps PROC
	invoke DeleteObject,hBmpShutdown
	invoke DeleteObject,hBmpRestart
	invoke DeleteObject,hBmpStandby
	invoke DeleteObject,hBmpLogoff
	invoke DeleteObject,hBmpHibernate
	invoke DeleteObject,hBmpLock
	invoke DeleteObject,hBmpMonitor		
	invoke DeleteObject,hBmpScreensaver
	invoke DeleteObject,hBmpLightShutdown
	invoke DeleteObject,hBmpLightRestart
	invoke DeleteObject,hBmpExit	
	invoke DeleteObject,hBmpOptions
	RET
DeleteBitmaps ENDP

comment ~
Uncomment to show time in status bar

;To show Time in status bar
CurrentTime proc
LOCAL time	:	BYTE
LOCAL st1 :	SYSTEMTIME 	
LOCAL st2 : SYSTEMTIME 	
LOCAL ft1 : FILETIME	
LOCAL ft2 :	FILETIME

;;Daily check
			invoke KeyValueCheck, addr szKeyApplication, addr szDaily
			.if  nValue == TRUE
			mov esi, nValue
				invoke KeyValueCheck, addr szKeyApplication, addr szDailyDataHigh
				invoke wsprintf, addr nNew, addr nDword,  nValue
				m2m ft1.dwHighDateTime,  nNew

				invoke KeyValueCheck, addr szKeyApplication, addr szDailyDataLow
				invoke wsprintf, addr nNew, addr nDword,  nValue
				m2m ft1.dwLowDateTime,  nNew			
			.endif		

	LOOP1:
							
			invoke Sleep, 500
			invoke RtlZeroMemory, addr time,60
			invoke GetTimeFormat,LOCALE_USER_DEFAULT,NULL, NULL, NULL, addr time, 60
			invoke SendDlgItemMessage,DlgHandle, IDC_SB1,SB_SETTEXT,0,addr time 
			
			.if  esi == TRUE		

				invoke GetLocalTime, addr st2
				mov st2.wMilliseconds,0
				mov st2.wDay,0
				mov st2.wDayOfWeek,0
				mov st2.wMonth,0
				mov st2.wYear,0
				
				invoke SystemTimeToFileTime, addr st2, addr ft2		
				
				mov ax,st2.wSecond
				;invoke wsprintf, addr nNew, addr nDword, eax
				;invoke MessageBox,DlgHandle,addr nNew, 0,MB_OK
				;invoke wsprintf, addr nNew, addr nDword,  ft2.dwLowDateTime
				;invoke MessageBox,DlgHandle,addr nNew,0,MB_OK
				
				;invoke CompareFileTime, addr ft1, addr ft2
				;invoke lstrcmp, addr ft1.dwLowDateTime, addr ft2.dwLowDateTime
				;.IF eax == 0
				;	invoke MessageBox,DlgHandle,0,0,MB_OK
				;.ENDIF
			.endif		
				
			JMP LOOP1
	Ret
CurrentTime EndP
~
;Create a new Dialog box where the count down is actually seen
DlgProc2 proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
LOCAL hFont : HFONT
m2m DlgHandle2, hWnd
m2m DlgMessage2, uMsg

	.IF uMsg == WM_CLOSE
		invoke EndDialog, hWnd,0	
   	.ELSEIF uMsg == WM_INITDIALOG
   			;Start the countdown thread and change the font
			invoke EnableWindow, hButtonStopID,FALSE
   			invoke CreateThread,0,0,addr ThreadProc2,0,0,addr ThreadID 
   			MOV hThread2, eax
   			invoke CreateFontIndirect,addr stCountFont
			invoke SendDlgItemMessage, hWnd, IDC_STATICMESS, WM_SETFONT, eax, TRUE
			invoke CreateFontIndirect,addr stButtonFont
			mov hFont, eax
			invoke SendDlgItemMessage, hWnd, IDC_NOW, WM_SETFONT, hFont, TRUE
			invoke SendDlgItemMessage, hWnd, IDC_CANCEL, WM_SETFONT, hFont, TRUE
		
   	.ELSEIF uMsg == WM_COMMAND
   		MOV EAX, wParam
   		;Now button
   		.IF EAX == IDC_NOW
   			;Terminate threads
			invoke GetExitCodeThread, hThread2,addr lpExitCode2
			invoke TerminateThread,hThread2, lpExitCode2
			invoke Sleep,500
			invoke DoOperations, DlgHandle
			invoke GetExitCodeThread, hThread,addr lpExitCode1
			invoke TerminateThread,hThread, lpExitCode1
			invoke SendDlgItemMessage,DlgHandle, IDC_SB1,SB_SETTEXT,1,addr szTimerDisabled
			invoke EndDialog, DlgHandle2,0
		;Cancel button	
		.ELSEIF EAX == IDC_CANCEL
			;Terminate threads
			invoke GetExitCodeThread, hThread2,addr lpExitCode2
			invoke TerminateThread,hThread2, lpExitCode2
			invoke GetExitCodeThread, hThread,addr lpExitCode1
			invoke TerminateThread,hThread, lpExitCode1
			invoke SendDlgItemMessage,DlgHandle, IDC_SB1,SB_SETTEXT,1,addr szTimerDisabled
			invoke EndDialog, DlgHandle2,0
			ret
		.ENDIF	
			
	.endif	
	xor eax, eax
	Ret
DlgProc2 EndP

;Dialog used for options
DlgProc3 proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

;local dwValue 		: DWORD
LOCAL nSize1		: DWORD	
LOCAL hProcess		: DWORD	
LOCAL lpFileName[140] 	:BYTE	
LOCAL st1 :	SYSTEMTIME 	
LOCAL st2 : SYSTEMTIME 	
LOCAL ft1 : FILETIME	
LOCAL ft2 :	FILETIME

	.IF uMsg == WM_CLOSE
		invoke EndDialog, hWnd,0
	.ELSEIF uMsg == WM_INITDIALOG
		;Registry checking for Startup
			invoke KeyValueCheck, addr szKeyApplication, addr szStartup
			.if  nValue == TRUE					
				invoke SendDlgItemMessage,hWnd, IDC_CHKSTARTUP,BM_SETCHECK,BST_CHECKED,0
			.elseif nValue == TRUE	
				invoke SendDlgItemMessage,hWnd, IDC_CHKSTARTUP,BM_SETCHECK,BST_UNCHECKED,0
			.endif	
       	
       	;Registry checking for Minimise
			invoke KeyValueCheck, addr szKeyApplication, addr szMinimise
			.if  nValue == TRUE				
			invoke SendDlgItemMessage,hWnd, IDC_CHKMIN,BM_SETCHECK,BST_CHECKED,0
			.elseif nValue == TRUE	
				invoke SendDlgItemMessage,hWnd, IDC_CHKMIN,BM_SETCHECK,BST_UNCHECKED,0
			.endif	
		
		;Registry checking for Forced Shutdown
			invoke KeyValueCheck, addr szKeyApplication, addr szForce
			.if  nValue == TRUE
				invoke SendDlgItemMessage,hWnd, IDC_CHKFORCE,BM_SETCHECK,BST_CHECKED,0
			.elseif nValue == TRUE
				invoke SendDlgItemMessage,hWnd, IDC_CHKFORCE,BM_SETCHECK,BST_UNCHECKED,0
			.endif	
		
		;Registry checking for Sound
			invoke KeyValueCheck, addr szKeyApplication, addr szSound
			.if  nValue == TRUE
				invoke SendDlgItemMessage,hWnd, IDC_CHKSOUND,BM_SETCHECK,BST_CHECKED,0
			.elseif nValue == FALSE
				invoke SendDlgItemMessage,hWnd, IDC_CHKSOUND,BM_SETCHECK,BST_UNCHECKED,0
			.endif	
			
		;Registry checking for Daily
			invoke KeyValueCheck, addr szKeyApplication, addr szDaily
			.if  nValue == TRUE
				invoke SendDlgItemMessage,hWnd, IDC_CHKDAILY,BM_SETCHECK,BST_CHECKED,0
			.elseif nValue == FALSE
				invoke SendDlgItemMessage,hWnd, IDC_CHKDAILY,BM_SETCHECK,BST_UNCHECKED,0
			.endif	
		
	.ELSEIF uMsg == WM_COMMAND
		mov eax, wParam
		;Startup Checkbox
		.IF EAX == IDC_CHKSTARTUP
			mov eax, lParam
			invoke IsDlgButtonChecked, hWnd, IDC_CHKSTARTUP
			.IF EAX == BST_CHECKED
				invoke KeyValueCreate, addr szKeyApplication,addr szStartup,addr dwValue1,1
				invoke GetModuleFileName, hInstance, addr lpFileName, addr nSize1
				invoke KeyValueCreateString, addr szKeyPathStartup,addr szProgramName, addr lpFileName,1
			.ELSEIF EAX == BST_UNCHECKED		
				invoke KeyValueCreate, addr szKeyApplication,addr szStartup,addr dwValue1,0
				invoke KeyValueCreate, addr szKeyPathStartup,addr szProgramName,addr dwValue1,0
			.ENDIF
		
		;Minimise Checkbox
		.ELSEIF EAX == IDC_CHKMIN
			invoke IsDlgButtonChecked, hWnd, IDC_CHKMIN
			.IF EAX == BST_CHECKED
				invoke KeyValueCreate, addr szKeyApplication,addr szMinimise,addr dwValue1,1
			.ELSEIF EAX == BST_UNCHECKED
				invoke KeyValueCreate, addr szKeyApplication,addr szMinimise,addr dwValue1,0
			.ENDIF	
		
		;Force Checkbox	
		.ELSEIF EAX == IDC_CHKFORCE
			invoke IsDlgButtonChecked, hWnd, IDC_CHKFORCE
			.IF EAX == BST_CHECKED
				invoke KeyValueCreate, addr szKeyApplication,addr szForce,addr dwValue1, 1
			.ELSEIF EAX == BST_UNCHECKED
				invoke KeyValueCreate, addr szKeyApplication,addr szForce,addr dwValue1, 0
			.ENDIF
		
		;Sound Checkbox	
		.ELSEIF EAX == IDC_CHKSOUND
			invoke IsDlgButtonChecked, hWnd, IDC_CHKSOUND
			.IF EAX == BST_CHECKED
				invoke KeyValueCreate, addr szKeyApplication,addr szSound,addr dwValue1,1
			.ELSEIF EAX == BST_UNCHECKED
				invoke KeyValueCreate, addr szKeyApplication,addr szSound,addr dwValue1,0
			.ENDIF	
				
		;Daily
		.ELSEIF EAX == IDC_CHKDAILY
			invoke IsDlgButtonChecked, hWnd, IDC_CHKDAILY
			.IF EAX == BST_CHECKED
			;invoke SendDlgItemMessage,DlgHandle, IDC_SB1,SB_SETTEXT,1,addr szTimerEnabled	
			
				;Get time from DTP & convert it into Filetime, We don't need Millisecond accuracy so make that zero
				invoke SendDlgItemMessage, DlgHandle, IDC_DTP, DTM_GETSYSTEMTIME,0,addr st1		
				;mov st1.wMilliseconds,0
				;mov st1.wDay,0
				;mov st1.wDayOfWeek,0
				;mov st1.wMonth,0
				;mov st1.wYear,0
				;st1.
				;invoke SystemTimeToFileTime, addr st1, addr ft1
				;invoke KeyValueCreate, addr szKeyApplication,addr szDailyDataHigh,ft2.dwHighDateTime,1
				;invoke KeyValueCreate, addr szKeyApplication,addr szDailyDataLow,ft2.dwLowDateTime,1
				xor eax, eax
				mov ax, st1.wHour
				invoke wsprintf, addr nNew, addr nDword, eax
				;invoke KeyValueCreate, addr szKeyApplication,addr szHour,addr nNew ,1
				;invoke KeyValueCreate, addr szKeyApplication,addr szHour,addr nNew ,1
				;add esp, 10
				
				invoke KeyValueCreate, addr szKeyApplication,addr szDaily,addr dwValue1,1
				
				;invoke Sleep,800
				;invoke KeyValueCreate, addr szKeyApplication,addr szHour, addr nNew,1
				invoke KeyValueCreateString, addr szKeyApplication,addr szHour, addr nNew,1
				
			.ELSEIF EAX == BST_UNCHECKED
				invoke KeyValueCreate, addr szKeyApplication,addr szDaily,addr dwValue1,0
			.ENDIF		
		;OK	Button
		.ELSEIF EAX == IDC_OPTIONOK
			invoke EndDialog, hWnd, 0	
		.ELSEIF EAX == IDC_DELREGISTRY
			invoke RegDeleteKey, HKEY_LOCAL_MACHINE, addr szKeyApplication	
			invoke KeyValueCreate, addr szKeyPathStartup,addr szProgramName,addr dwValue1,0
		.ENDIF	
	.ENDIF	
	
	xor eax, eax 
	Ret
DlgProc3 EndP

END start

