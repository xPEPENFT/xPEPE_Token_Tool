; *** Start added by AutoIt3Wrapper ***
#include <MsgBoxConstants.au3>
; *** End added by AutoIt3Wrapper ***
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=SpaceManV2.ico
#AutoIt3Wrapper_Add_Constants=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include ".\libs\EzMySql.au3"
#include <Array.au3>
#include <file.au3>
#include <FileConstants.au3>
#include <Process.au3>
#include <WindowsConstants.au3>
#include <GUIConstantsEx.au3>
#include <EditConstants.au3>
#include <ColorConstants.au3>
#include <StaticConstants.au3>
#include <ButtonConstants.au3>
#include <Date.au3>

#include ".\libs\_UskinLibrary.au3"
;--
_Uskin_LoadDLL()
_USkin_Init(@ScriptDir & "\libs\Axis.msstyles"); <-- Put here your skin...

Opt("GUIOnEventMode", 1) ;0=disabled, 1=OnEvent mode enabled

Global $PythonFile, $OutputFile, $LoopFailedPython, $FoundWallet = False, $OrderBookFile
Global $WalletID, $FirstTimer = 0, $StatusBox, $SplitData, $iFileSize, $SplitBalance
Global $AddedWalletsCtrl, $TotalWalletsCtrl, $ChangedWalletsCtrl, $UnchangedWalletsCtrl
Global $AddedCount, $UnchangedCount, $ChangedCount, $TotalWalletCount, $WalletUnchanged = False
Global $_CompteArebour = 300000, $_Minutes, $_Seconds


Global $serverIP, $serverUser, $serverPass, $serverPort, $Database, $richlistTable

$sRead = IniRead(@ScriptDir & "\Settings.ini", "Settings", "ServerIP", "Default Value")
$serverIP = $sRead

$sRead = IniRead(@ScriptDir & "\Settings.ini", "Settings", "ServerUsername", "Default Value")
$serverUser = $sRead

$sRead = IniRead(@ScriptDir & "\Settings.ini", "Settings", "ServerPassword", "Default Value")
$serverPass = $sRead

$sRead = IniRead(@ScriptDir & "\Settings.ini", "Settings", "ServerPort", "Default Value")
$serverPort = $sRead

$sRead = IniRead(@ScriptDir & "\Settings.ini", "Database", "Database", "Default Value")
$Database = $sRead

$sRead = IniRead(@ScriptDir & "\Settings.ini", "Database", "RichlistTable", "Default Value")
$richlistTable = $sRead

Local $PythonFile = FileOpenDialog("Open Python Script..", @WorkingDir, "All (*.py*)", BitOR($FD_FILEMUSTEXIST, $FD_MULTISELECT))
If @error Then
	; Display the error message.
	MsgBox($MB_SYSTEMMODAL, "", "No file(s) were selected.")
	Exit
Else
	; Change the working directory (@WorkingDir) back to the location of the script directory as FileOpenDialog sets it to the last accessed folder.
	FileChangeDir(@ScriptDir)

	; Replace instances of "|" with @CRLF in the string returned by FileOpenDialog.

EndIf

Local $OutputFile = FileOpenDialog("Open Output File..", @WorkingDir, "All (*.txt*)", BitOR($FD_FILEMUSTEXIST, $FD_MULTISELECT))
If @error Then
	; Display the error message.
	MsgBox($MB_SYSTEMMODAL, "", "No file(s) were selected.")
	Exit
Else
	; Change the working directory (@WorkingDir) back to the location of the script directory as FileOpenDialog sets it to the last accessed folder.
	FileChangeDir(@ScriptDir)

	; Replace instances of "|" with @CRLF in the string returned by FileOpenDialog.

EndIf

Local $OrderBookFile = FileOpenDialog("Open Orderbook Script..", @WorkingDir, "All (*.js*)", BitOR($FD_FILEMUSTEXIST, $FD_MULTISELECT))
If @error Then
	; Display the error message.
	MsgBox($MB_SYSTEMMODAL, "", "No file(s) were selected.")
	Exit
Else
	; Change the working directory (@WorkingDir) back to the location of the script directory as FileOpenDialog sets it to the last accessed folder.
	FileChangeDir(@ScriptDir)

	; Replace instances of "|" with @CRLF in the string returned by FileOpenDialog.

EndIf

$_GuiCountDown = GUICreate("xPEPE Wallet Sync", 500, 300, @DesktopWidth / 2 - 250, @DesktopHeight / 2 - 100)
$TimeLabel = GUICtrlCreateLabel("", 25, -10, 480, 180)

GUICtrlSetFont(-1, 125, 800)
GUICtrlCreateLabel("Last Action", 175, 160, 200, 200)
GUICtrlSetFont(-1, 20)
$StatusBox = GUICtrlCreateInput("Loaded Required Files", 10, 190, 470, 35, $ES_CENTER)
GUICtrlSetColor(-1, $COLOR_RED)
GUICtrlSetFont(-1, 20)
GUICtrlCreateLabel("  Total" & @CR & "Wallets", 15, 233, 250, 100)
GUICtrlSetFont(-1, 13)
$TotalWalletsCtrl = GUICtrlCreateInput("0", 5, 270, 80, 25, $ES_CENTER)
GUICtrlSetColor(-1, $COLOR_GREEN)
GUICtrlSetFont(-1, 13)
GUICtrlCreateLabel("Added" & @CR & "Wallets", 148, 233, 200, 100)
GUICtrlSetFont(-1, 13)
$AddedWalletsCtrl = GUICtrlCreateInput("0", 135, 270, 80, 25, $ES_CENTER)
GUICtrlSetFont(-1, 13)
GUICtrlSetColor(-1, $COLOR_GREEN)
GUICtrlCreateLabel("Updated" & @CR & " Wallets", 285, 233, 200, 100)
GUICtrlSetFont(-1, 13)
$ChangedWalletsCtrl = GUICtrlCreateInput("0", 275, 270, 80, 25, $ES_CENTER)
GUICtrlSetColor(-1, $COLOR_GREEN)
GUICtrlSetFont(-1, 13)
GUICtrlCreateLabel("Unchanged" & @CR & "   Wallets", 413, 233, 200, 100)
GUICtrlSetFont(-1, 13)
$UnchangedWalletsCtrl = GUICtrlCreateInput("0", 415, 270, 80, 25, $ES_CENTER)
GUICtrlSetColor(-1, $COLOR_GREEN)
GUICtrlSetFont(-1, 13)

Global $idContextmenu = GUICtrlCreateContextMenu()
$idNewsubmenu = GUICtrlCreateMenu("Options...", $idContextmenu)
$idNewsubmenuText = GUICtrlCreateMenuItem("Update", $idNewsubmenu)
GUICtrlSetOnEvent(-1, "FireRun")

GUISetState()
GUISetOnEvent($GUI_EVENT_CLOSE, "SpecialEvents")
$TimeTicks = TimerInit()

Func FireRun()
	_RunTask()
	$FirstTimer = 0
	$_CompteArebour = 300000
EndFunc   ;==>FireRun


Func SpecialEvents()
	Exit
EndFunc   ;==>SpecialEvents

Func _RunTask()

	_RunDos("node " & $OrderBookFile)

	$AddedCount = 0
	$UnchangedCount = 0
	$ChangedCount = 0
	$TotalWalletCount = 0
	$WalletUnchanged = False

	While $LoopFailedPython = False
		GUICtrlSetData($StatusBox, "Compiling Rich List...")
		_RunDos("python " & $PythonFile)

		$iFileSize = FileGetSize($OutputFile)

		If $iFileSize > 25000 Then
			$LoopFailedPython = True
		Else
			GUICtrlSetData($StatusBox, "Rich List Failed... Retrying")
			Sleep(1000)
			$LoopFailedPython = False
		EndIf

	WEnd

	GUICtrlSetData($StatusBox, "Rich List Generated")

	If Not _EzMySql_Startup() Then
		MsgBox(0, "Error Starting MySql", "Error: " & @error & @CR & "Error string: " & _EzMySql_ErrMsg())
		Exit
	EndIf

	If Not _EzMySql_Open($serverIP, $serverUser, $serverPass, "", $serverPort) Then
		MsgBox(0, "Error opening Database", "Error: " & @error & @CR & "Error string: " & _EzMySql_ErrMsg())
		Exit
	EndIf


	If Not _EzMySql_SelectDB($Database) Then
		MsgBox(0, "Error setting Database to use", "Error: " & @error & @CR & "Error string: " & _EzMySql_ErrMsg())
		Exit
	EndIf

	Local $sMySqlStatement = ""
	If Not _EzMYSql_Query("TRUNCATE TABLE " & $richlistTable) Then
		MsgBox(0, "Query Error", "Error: " & @error & @CR & "Error string: " & _EzMySql_ErrMsg())
		Exit
	EndIf

	$file = FileOpen($OutputFile, 0)

	Local $line = FileReadToArray($file)
	For $i = 0 To UBound($line) - 1

		$TotalWalletCount += 1
		GUICtrlSetData($TotalWalletsCtrl, $TotalWalletCount)
		$WalletID = ""
		$SplitData = ""

		$SplitData = StringSplit($line[$i], ",")
		$SplitBalance = StringSplit($SplitData[2], ": ")
		$SplitData[2] = $SplitBalance[4]
		$SplitData[2] = StringStripWS($SplitData[2], 8)

		$AddedCount += 1
		GUICtrlSetData($AddedWalletsCtrl, $AddedCount)
		$sMySqlStatement &= "INSERT INTO " & $richlistTable & " (Wallet,Balance) VALUES (" & _
				"'" & $SplitData[1] & "'," & _
				"'" & $SplitData[2] & "');"


		GUICtrlSetData($StatusBox, "Wallet #: " & $i & " Handeled")



	Next

	If Not _EzMySql_Exec($sMySqlStatement) Then
		MsgBox(0, "Error inserting data to Table", "Error: " & @error & @CR & "Error string: " & _EzMySql_ErrMsg())
		Exit
	EndIf



	GUICtrlSetData($StatusBox, "MySQL Updated - " & _NowTime())
	_EzMySql_Close()
	_EzMySql_ShutDown()
	FileClose($file)



EndFunc   ;==>_RunTask


Func _Check()
	$_CompteArebour -= TimerDiff($TimeTicks)
	$TimeTicks = TimerInit()
	Local $_MinCalc = Int($_CompteArebour / (60 * 1000)), $_SecCalc = $_CompteArebour - ($_MinCalc * 60 * 1000)
	$_SecCalc = Int($_SecCalc / 1000)
	If $_MinCalc <= 0 And $_SecCalc <= 0 Then

		If $FirstTimer = 1 Then
			_RunTask()
			$FirstTimer = 0
			$_CompteArebour = 300000
		Else
			GUICtrlSetData($StatusBox, "Halfway Point Reached - " & _NowTime())
			$FirstTimer += 1
			$_CompteArebour = 300000
		EndIf


	Else
		If $_MinCalc <> $_Minutes Or $_SecCalc <> $_Seconds Then
			$_Minutes = $_MinCalc
			$_Seconds = $_SecCalc
			GUICtrlSetData($TimeLabel, StringFormat("%02u" & ":" & "%02u", $_Minutes, $_Seconds))
		EndIf
	EndIf
EndFunc   ;==>_Check



While 1
	_Check()
	Sleep(10)
WEnd
