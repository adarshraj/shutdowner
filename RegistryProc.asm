;Registry Procedures

.code
;Create and Delete Dword values  in Registry
KeyValueCreate proc szKeyApp:LPSTR, szOperation:LPSTR, szValues:DWORD, szMode:BYTE
LOCAL szRegHandle1 :DWORD
LOCAL szRegHandle2 :DWORD
DW_SIZE equ 4
	
	.if szMode == 1
		invoke RegCreateKeyEx,HKEY_LOCAL_MACHINE, szKeyApp,0,0,REG_OPTION_NON_VOLATILE,KEY_CREATE_SUB_KEY + KEY_SET_VALUE ,NULL,addr szRegHandle1, addr szRegHandle2
		invoke RegSetValueEx, szRegHandle1,szOperation,NULL,REG_DWORD_LITTLE_ENDIAN, szValues,  DW_SIZE
		invoke RegCloseKey, szRegHandle1
	.elseif szMode == 0	
		invoke RegOpenKeyEx,HKEY_LOCAL_MACHINE, szKeyApp,0,KEY_ALL_ACCESS, addr szRegHandle1
		invoke RegDeleteValue,szRegHandle1, szOperation
		invoke RegCloseKey, szRegHandle1
	.endif	
	Ret
KeyValueCreate EndP	

;Create and Delete strings in registry
KeyValueCreateString proc szKeyApp:LPSTR, szOperation:LPSTR, szValues:LPSTR, szMode:BYTE
LOCAL szRegHandle1 :DWORD
LOCAL szRegHandle2 :DWORD
DW_SIZE_STRING	EQU	260
	.if szMode == 1
		invoke RegCreateKeyEx,HKEY_LOCAL_MACHINE, szKeyApp,0,0,REG_OPTION_NON_VOLATILE,KEY_CREATE_SUB_KEY + KEY_SET_VALUE ,NULL,addr szRegHandle1, addr szRegHandle2
		invoke RegSetValueEx, szRegHandle1,szOperation,NULL,REG_SZ, szValues,  DW_SIZE_STRING
		invoke RegCloseKey, szRegHandle1
	.elseif szMode == 0	
		invoke RegOpenKeyEx,HKEY_LOCAL_MACHINE, szKeyApp,0,KEY_ALL_ACCESS, addr szRegHandle1
		invoke RegDeleteValue,szRegHandle1, szOperation
		invoke RegCloseKey, szRegHandle1
	.endif	
	Ret
KeyValueCreateString EndP


;For checking values other than strings in the registry 
KeyValueCheck proc szKeyApp:LPSTR, szOperation:LPSTR
LOCAL szRegHandle1: DWORD
LOCAL Temp1:DWORD
LOCAL TType1:DWORD
		invoke RtlZeroMemory,addr TType1,sizeof TType1
		invoke RegOpenKeyEx,HKEY_LOCAL_MACHINE,szKeyApp,0,KEY_READ, addr szRegHandle1
		.if eax == ERROR_SUCCESS
        	mov Temp1, REG_DWORD
			invoke RegQueryValueEx, szRegHandle1,szOperation, NULL, addr Temp1,addr TType1,offset szStringLength1
			.if TType1 == 1
				mov nValue, TRUE
			.elseif TType1 == 0
				mov nValue, FALSE
			.else
				mov eax, TType1
				mov nValue,eax	
			.endif
		.endif	
		invoke RegCloseKey, szRegHandle1
		ret	
KeyValueCheck EndP

;Checking/Retrieving Strings in/from Registry
KeyValueStringCheck	proc szKeyString:LPSTR, szValueName:LPSTR, szStoreString:DWORD
LOCAL szRegHandle1:DWORD
LOCAL TType: dword
LOCAL dwSize: dword
		invoke RegOpenKeyEx,HKEY_LOCAL_MACHINE,szKeyString,0,KEY_READ, addr szRegHandle1
		.if eax == ERROR_SUCCESS
			mov TType, REG_SZ
			invoke RegQueryValueEx,szRegHandle1,szValueName ,NULL, addr TType,szStoreString,addr dwSize
			invoke RegCloseKey, szRegHandle1
		.endif	
	Ret
KeyValueStringCheck EndP