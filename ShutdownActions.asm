
;Main Actions such as Shutdown, Restart, LogOff, Hibernation etc are taking place here..

;.code

DoOperations proc hWnd:HWND
LOCAL szRegHandle1	: DWORD
LOCAL szRegHandle2	: DWORD
LOCAL FORCE : LPSTR
LOCAL nFlag	: BYTE
LOCAL szNoHibernation$ : DWORD	
LOCAL szNoSuspend$ : DWORD	
LOCAL szEnableHibernate$ :DWORD
LOCAL szInfo$	: DWORD
LOCAL lpCmdLine$	: DWORD
LOCAL szRedo$	: DWORD
sas szNoHibernation$,"System will not Hibernate."				
sas szNoSuspend$,"System will not Suspend/Sleep. Your system lacks this feature!.."	
sas szEnableHibernate$, "Hibernate not enabled in your system. Do you want to enable it now"	
sas szInfo$, "Info"
sas lpCmdLine$,"powercfg.exe /HIBERNATE on"
sas szRedo$, "Success!. Now do the action once again"
					
MOV FORCE,0
MOV nValue, FALSE
;Checking whether Force option is enabled
invoke KeyValueCheck, addr szKeyApplication, addr szForce
.if  nValue == TRUE
	MOV nFlag, 1
.elseif nValue == FALSE 
	MOV nFlag,0	
.endif	

	invoke EndDialog, DlgHandle2,0
	invoke ShowWindowAsync, DlgHandle,SW_HIDE

;Shutdown	
.IF (dwSelectedOperation==ID_OPERATION_SHUTDOWN)
		.if nFlag == 1
			mov FORCE, EWX_POWEROFF+EWX_FORCE
		.else	
			mov FORCE, EWX_POWEROFF
		.endif	
    	invoke AdjustPrivilege
		invoke ExitWindowsEx, FORCE , NULL
	
;Restart						
.ELSEIF (dwSelectedOperation==ID_OPERATION_RESTART)		
		.if nFlag == 1
			mov FORCE, EWX_REBOOT+EWX_FORCE
		.else	
			mov FORCE, EWX_REBOOT
		.endif	
		invoke AdjustPrivilege
		invoke ExitWindowsEx,FORCE,0

;StandBy								
.ELSEIF (dwSelectedOperation==ID_OPERATION_STANDBY)
	;Checking system capable of Allowing Suspend state 
    invoke IsPwrSuspendAllowed
    .IF (EAX == TRUE)	   		
    	.if nFlag == 1
			mov FORCE, TRUE
		.else
			mov FORCE, FALSE
		.endif	
		invoke SetSuspendState,FALSE,FORCE,TRUE
	.ELSE
		invoke MessageBox,hWnd,szNoSuspend$, ADDR szErrorCaption, MB_OK	
	.ENDIF

;LogOff				
.ELSEIF (dwSelectedOperation==ID_OPERATION_LOGOFF)  
		.if nFlag == 1
			mov FORCE, EWX_LOGOFF+EWX_FORCE
		.else	
			mov FORCE, EWX_LOGOFF
		.endif	  	      		   		
    	invoke ExitWindowsEx,FORCE,NULL			
 
;Hibernate    			   			  				
.ELSEIF (dwSelectedOperation==ID_OPERATION_HIBERNATE)   
	;Checking whether system can support Hibernation		
   	invoke IsPwrHibernateAllowed
	.IF (EAX == TRUE) 
		.if nFlag == 1
			mov FORCE, TRUE
		.else
			mov FORCE, FALSE
		.endif	
		invoke SetSuspendState,TRUE,FORCE,TRUE
	.ELSE
		;Asking for enabling Hibernation
		invoke MessageBox, hWnd, szEnableHibernate$,szInfo$, MB_OK or MB_ICONQUESTION or MB_YESNO
		.if eax == IDYES
			invoke WinExec,lpCmdLine$,SW_HIDE
			.if eax == ERROR_FILE_NOT_FOUND	
				invoke MessageBox, hWnd,  szNoHibernation$, ADDR szErrorCaption, MB_OK or MB_ICONERROR
			.elseif eax > 31
				invoke MessageBox, hWnd, szRedo$,szInfo$, MB_OK+MB_ICONINFORMATION
				invoke ShowWindow, hWnd,SW_SHOWDEFAULT
			.else
				invoke MessageBox, hWnd,  szNoHibernation$, ADDR szErrorCaption, MB_OK or MB_ICONERROR
			.endif	
		.elseif eax == IDNO
			invoke MessageBox, hWnd,  szNoHibernation$, ADDR szErrorCaption, MB_OK or MB_ICONERROR
		.endif	
	.ENDIF
	
;Lock System						 		
.ELSEIF (dwSelectedOperation==ID_OPERATION_LOCK)           	
    	invoke LockWorkStation		
	
;Shutdown Monitors						 		
.ELSEIF (dwSelectedOperation==ID_OPERATION_SHUTMONITOR)           	
     	;TurnOff Monitor. I am offing the monitor in the assumption that mousemove will wake it
    	invoke SendMessage, hWnd, WM_SYSCOMMAND, SC_MONITORPOWER, 2 ; 2 = MONITOR OFF
    	
;Start Screensavers    			
.ELSEIF (dwSelectedOperation==ID_OPERATION_STARTSCREENSAVER)      		    		    		
    	;invoke SendMessage, hWnd, WM_SYSCOMMAND, SC_SCREENSAVE, NULL	
    	;or		
		invoke ShellExecute,hWnd,addr szOpen,addr szFileName,NULL,NULL,SW_SHOW
		
;Superfast Shutdown 
.ELSEIF (dwSelectedOperation==ID_OPERATION_LIGHTSHUTDOWN)  
		invoke AdjustPrivilege
		invoke NtShutdownSystem,0 

;Superfast Reboot		
.ELSEIF (dwSelectedOperation==ID_OPERATION_LIGHTRESTART)   
		invoke AdjustPrivilege
		invoke NtShutdownSystem,1
 
;Exit Application    			
.ELSEIF (dwSelectedOperation==ID_OPERATION_EXIT)
    invoke Shell_NotifyIcon,NIM_DELETE,addr note 
	invoke GetExitCodeThread, hThread0,addr lpExitCode3
	invoke TerminateThread,hThread0, lpExitCode3	
	invoke EndDialog, hWnd,NULL							
.ENDIF

	;Terminate threads	
	invoke GetExitCodeThread, hThread,addr lpExitCode1
	invoke TerminateThread,hThread, lpExitCode1
	invoke GetExitCodeThread, hThread2,addr lpExitCode2
	invoke TerminateThread,hThread2, lpExitCode2
	
	Ret
DoOperations EndP

;This code is collected from several web resources and modified as i wanted. Greetz to all the authors
;This code is used to Adjust Privileges in NT system  so as to allow Shutdown & Restart
AdjustPrivilege PROC
	LOCAL hProcess	:DWORD
	LOCAL hToken	:DWORD
 	LOCAL RetLen	:DWORD
    LOCAL pRetLen	:DWORD
	LOCAL tkp		:TOKEN_PRIVILEGES
	LOCAL tkp_old	:TOKEN_PRIVILEGES
	LOCAL privName$	:DWORD						
	sas	privName$, "SeShutdownPrivilege"
	
	invoke GetCurrentProcess
	MOV hProcess, eax
	LEA EDI, hToken	
	invoke OpenProcessToken, hProcess,TOKEN_ADJUST_PRIVILEGES OR TOKEN_QUERY, EDI
	.IF (EAX != FALSE)
		LEA EDI, tkp.Privileges[0].Luid
		invoke LookupPrivilegeValue, NULL,privName$,EDI
		LEA EAX, RetLen
		MOV pRetLen, EAX
		MOV tkp.PrivilegeCount,1
		MOV tkp.Privileges[0].Attributes,SE_PRIVILEGE_ENABLED
		invoke AdjustTokenPrivileges,hToken,FALSE,ADDR tkp, SIZEOF tkp_old, ADDR tkp_old,pRetLen
	.ENDIF	
	RET
AdjustPrivilege ENDP

;This is the Thread Procedure called when user selects the timer option. And it will do the comparison of user 
;selected time and Current time. And when time are equal it will call the Countdown thread and finally it will 
;do the action user asked.....
TimerProc proc  
LOCAL st1 :	SYSTEMTIME 	
LOCAL st2 : SYSTEMTIME 	
LOCAL ft1 : FILETIME	
LOCAL ft2 :	FILETIME
LOCAL szBadTime$ : DWORD	
sas szBadTime$,"Please enter a valid/future time"

LOOP1:
		;Create a small delay
		invoke Sleep, 1000
		
		;Showing Timer Enabled
		invoke SendDlgItemMessage,DlgHandle, IDC_SB1,SB_SETTEXT,1,addr szTimerEnabled	
		
		;Get time from DTP & convert it into Filetime, We don't need Millisecond accuracy so make that zero
		invoke SendDlgItemMessage, DlgHandle, IDC_DTP, DTM_GETSYSTEMTIME,0,addr st1		
		mov st1.SYSTEMTIME.wMilliseconds,0
		invoke SystemTimeToFileTime, addr st1, addr ft1
		
		;Get our local time and convert it to Filetime
		invoke GetLocalTime, addr st2
		mov st2.SYSTEMTIME.wMilliseconds,0
		invoke SystemTimeToFileTime, addr st2, addr ft2		
							
		;Compare the two filetime and if same do the Action user selected
		invoke CompareFileTime, ADDR ft1, ADDR ft2		
		.IF eax == 0
			;Hides the main window
			invoke ShowWindow, DlgHandle,SW_HIDE

			;Calls the countdown dialog and shows Timer disabled and stops the comparison thread
			invoke DialogBoxParam, hInstance, IDD_DLGBOX2,0, addr DlgProc2, NULL
			invoke SendDlgItemMessage,DlgHandle, IDC_SB1,SB_SETTEXT,1,addr szTimerDisabled
			invoke GetExitCodeThread, hThread, addr lpExitCode1
			invoke TerminateThread,hThread, lpExitCode1
		.ELSEIF EAX == 0FFFFFFFFH
			;If user selected an old time warn him
			invoke MessageBox, DlgHandle,szBadTime$, addr szErrorCaption, MB_OK+ MB_ICONERROR
			invoke SendDlgItemMessage,DlgHandle, IDC_SB1,SB_SETTEXT,1,addr szTimerDisabled
			invoke GetExitCodeThread, hThread, addr lpExitCode1
			invoke TerminateThread,hThread, lpExitCode1
			RET
		.ENDIF	
		;Loop the procedure until time is equal
		jmp LOOP1	
	Ret
TimerProc EndP	


;This is a Thread Procedure called when the times are equal while using timers, and this will show a 
;10 second countdown.
ThreadProc2 PROC
LOCAL szRegHandle1		: DWORD
LOCAL szRegHandle2		: DWORD
LOCAL szStringLength2	: DWORD
LOCAL nFlag				: BYTE
LOCAL szBuffer [60] 	: BYTE
LOCAL szMessage	[50]	: BYTE	
LOCAL szFirst$ : DWORD
LOCAL szLast$ : DWORD
sas szFirst$," will happen in ";,0
sas szLast$," Seconds....";,0	
MOV nValue, FALSE


		;Registry checking on Sound
		invoke KeyValueCheck, addr szKeyApplication, addr szSound
		.if  nValue == TRUE		
			mov nFlag, 1
		.elseif nValue == FALSE
			mov nFlag, 0	
		.endif	
		
			push ebx
			push esi
			xor ebx, ebx
			xor esi, esi
			mov ebx,10
		
   	LOOP1:	
   			xor eax, eax
   			
   			.if nFlag == 1	
   				invoke MessageBeep,0FFFFFFFFh
   			.endif	
   						
   			invoke RtlZeroMemory, addr szBuffer, 50	
   			invoke wsprintf, addr szBuffer,addr szCountFormat, EBX
   			invoke Sleep,1000
   			invoke SetWindowText,DlgHandle2, addr szBuffer
   			
   			;Set Max and Min Ranges of progressbar
   			xor edx, edx
   			mov dl, 10
   			shl edx, 16
   			mov dl, 00
   			
   			invoke SendDlgItemMessage, DlgHandle2, IDC_PB1,PBM_SETRANGE,0,EDX
   			invoke SendDlgItemMessage, DlgHandle2, IDC_PB1,PBM_SETPOS,ESI,0
   			
   			;Showing selected action in countdown
   			.if dwSelectedOperation == ID_OPERATION_SHUTDOWN 
   				lea eax,[szShutdown]
   			.elseif dwSelectedOperation == ID_OPERATION_RESTART
   				lea eax,[szRestart]
   			.elseif dwSelectedOperation == ID_OPERATION_STANDBY
   				lea eax,[szStandby]
   			.elseif dwSelectedOperation == ID_OPERATION_LOGOFF
   				lea eax,[szLogOff]
   			.elseif dwSelectedOperation == ID_OPERATION_HIBERNATE
   				lea eax,[szHibernate]
   			.elseif dwSelectedOperation == ID_OPERATION_LOCK
   				lea eax,[szLockSystem]
   			.elseif dwSelectedOperation == ID_OPERATION_SHUTMONITOR
   				lea eax,[szOffMonitor]
   			.elseif dwSelectedOperation == ID_OPERATION_STARTSCREENSAVER
   				lea eax,[szScreenSaver]
   			.elseif dwSelectedOperation == ID_OPERATION_LIGHTSHUTDOWN
   				lea eax,[szLightShutdown]
   			.elseif dwSelectedOperation == ID_OPERATION_LIGHTRESTART
   				lea eax,[szLightRestart]	
   			.elseif dwSelectedOperation == ID_OPERATION_EXIT
   				lea eax,[szExitApp]
   			.endif
   				
   			invoke lstrcpy, addr szMessage,eax
   			;invoke StringCchCopy, addr szMessage, 50, eax
   			invoke lstrcat, addr szMessage,szFirst$
   			invoke lstrcat, addr szMessage, addr szBuffer
   			invoke lstrcat, addr szMessage,szLast$
   			invoke SendDlgItemMessage, DlgHandle2, IDC_STATICMESS, WM_SETTEXT, 0, addr szMessage
   			
   			inc esi
   			dec ebx	
   			cmp ebx,-1 	; To make count to zero than to one
   			jnz LOOP1
   			invoke SendMessage, DlgHandle2,WM_CLOSE,0,0
   			invoke DoOperations, DlgHandle
   			
   			pop esi
			pop ebx
			Ret
ThreadProc2 EndP

