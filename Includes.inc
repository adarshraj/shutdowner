; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; HEADERS
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

include windows.inc
include kernel32.inc
include user32.inc
include advapi32.inc
include comctl32.inc
include shell32.inc
include gdi32.inc
include ntdll.inc
include E:\masm32\macros\macros.asm
include powrprof.inc

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; LIBRARIES
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

includelib kernel32.lib
includelib user32.lib
includelib advapi32.lib
includelib comctl32.lib
includelib shell32.lib
includelib gdi32.lib
includelib ntdll.lib
includelib powrprof.lib
includelib str

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; FUNCTION protoTYPES
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

DlgProc					proto	:HWND, :UINT, :WPARAM, :LPARAM
DlgProc2				proto	:HWND, :UINT, :WPARAM, :LPARAM
DlgProc3				proto	:HWND, :UINT, :WPARAM, :LPARAM
AdjustPrivilege			proto
DoOperations 			proto	:HWND
TimerProc				proto
ThreadProc2 			proto
comment ~
Uncomment to show time in status bar
;CurrentTime				proto
~
Position				proto   :HWND
LoadBitmaps				proto
DeleteBitmaps			proto
KeyValueCreate			proto	:LPSTR, :LPSTR, :DWORD, :BYTE
KeyValueCreateString	proto	:LPSTR, :LPSTR, :LPSTR, :BYTE
KeyValueCheck			proto	:LPSTR, :LPSTR
KeyValueStringCheck		proto	:LPSTR, :LPSTR, :DWORD


