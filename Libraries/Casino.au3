#include-once
#include <Date.au3>
#include "Common.au3"
#include "Log.au3"

Func PlayCasinoGame()
    If Not IsInVillage() Then
        WriteInLogs("Village not found")
        Return
    EndIf

    FindCasino()
    cSend(0, 2000)
    If Not IsInCasino() Then
        WriteInLogs("Casino not found")
        ExitVillage()
        Return
    EndIF

    FindCroupier()
    RunFreeDailyRoll()

    ExitCasino()
    ExitVillage()
EndFunc   ;==>PlayCasinoGame

Func IsInVillage()
    PixelSearch(280, 31, 280, 31, 0x1CC9FF)
    If Not @error Then Return True
    Return False
EndFunc   ;==>IsInVillage

Func IsInCasino()
    PixelSearch(200, 250, 200, 250, 0xAA3C43)
    If Not @error Then Return True
    Return False
EndFunc   ;==>IsInCasino

Func FindCasino()
    Local $hTimer = TimerInit()
    Local $iMaxTimeout = 17000, $aPos, $bFound = False
    Do
        cSend(200, 0, "RIGHT")
		$aPos = PixelSearch(770, 499, 815, 499, 0x891F91)

        If IsArray($aPos) Then
            $bFound = FindActionIconAboveCharacter()
        EndIf
	Until $bFound Or $iMaxTimeout < TimerDiff($hTimer)
EndFunc   ;==>FindCasino

Func FindCroupier()
    Local $hTimer = TimerInit()
    Local $iMaxTimeout = 10000, $bFound = False
    Do
        cSend(200, 0, "RIGHT")
        $bFound = FindActionIconAboveCharacter()
	Until $bFound Or $iMaxTimeout < TimerDiff($hTimer)
EndFunc   ;==>FindCroupier

Func ExitCasino()
    Local $hTimer = TimerInit()
    Local $iMaxTimeout = 10000, $bFound = False
    Do
        cSend(200, 0, "LEFT")
        $bFound = FindActionIconAboveCharacter()
	Until $bFound Or $iMaxTimeout < TimerDiff($hTimer)

    cSend(0, 2000)
EndFunc   ;==>ExitCasino

Func ExitVillage()
    cSend(17000, 0, "LEFT")
    cSend(80, 200, "RIGHT")
    cSend(0)
EndFunc   ;==>ExitVillage

Func FindActionIconAboveCharacter()
    Sleep(300)
    $aPlayerPos = FindPlayer()
    If $aPlayerPos == False Then Return False

    PixelSearch($aPlayerPos[0] - 50, 360, $aPlayerPos[0] + 50, 440, 0xFFFFFF)
    If Not @error Then Return True
    Return False
EndFunc   ;==>FindActionIconAboveCharacter

Func FindPlayer()
    Local $aPos = PixelSearch(100, 440, 1100, 600, 0x633E75)
    If IsArray($aPos) Then Return $aPos
    Return False
EndFunc   ;==>FindPlayer

Func RunFreeDailyRoll()
    ; Open interface
    cSend(0, 2500)
    MouseClick("left", 385, 200 + 32, 1, 0)
    Sleep(400)
    MouseClick("left")
    Sleep(400)
    MouseClick("left")
    Sleep(400)

    ; Do rolls
    Local $bLost = False
    Local $bSpinned = False
    Do
        Sleep(200)
        MouseClick("left", 475, 460 + 32, 1, 0)
        Sleep(600)
        MouseClick("left", 475, 550 + 32, 1, 0)
        Sleep(1000)

        If Not IsInCasino() Then
            $bSpinned = True
            Sleep(9000)
        Else
            WriteInLogs("Free daily roll has already been used. No spins used")
            Sleep(1000)
        EndIf

        ; Find if next spin available
        If IsInCasino() Or Not IsSpinWinner() Then
            $bLost = True
            ; Close dialog
            Sleep(300)
            MouseClick("left", 475, 550 + 32, 1, 0)
            Sleep(300)
            MouseClick("left")
            Sleep(300)
            MouseClick("left")
        Else
            MouseClick("left", 475, 550 + 32, 1, 0)
            Sleep(300)
        EndIf
    Until $bLost

    If $bSpinned Then WriteInLogs("Free daily roll used")

EndFunc   ;==>RunFreeDailyRoll

Func IsSpinWinner()
    PixelSearch(400, 564, 400, 564, 0x00A100)
    If Not @error Then Return True

    PixelSearch(400, 564, 400, 564, 0x00A800)
    If Not @error Then Return True

    Return False
EndFunc   ;==>IsSpinWinner

Func IsCasinoReady()
	$sLastRollDateTime = FindLastDateTimeEntryInlogs("Free daily roll used")
    If $sLastRollDateTime == "" Then
	    $sLastRollDateTime = FindLastDateTimeEntryInlogs("Free daily roll has already been used. No spins used")
    EndIf
    If $sLastRollDateTime == "" Then Return True

	$sCasinoResetsTime = GetDateTimeOfCasinoReset()

	$bIsCasinoReady = _DateDiff("n", $sLastRollDateTime, $sCasinoResetsTime) > 0

	Return $bIsCasinoReady
EndFunc   ;==>IsCasinoReady

Func GetDateTimeOfCasinoReset()
	Local $sToday = @YEAR & "/" & @MON & "/" & @MDAY & " 00:00:00"

	$iLocaleDiff = GetLocaleDiff()
	$sCasinoResets = _DateAdd("n", $iLocaleDiff, $sToday)

	Return $sCasinoResets
EndFunc   ;==>GetDateTimeOfCasinoReset
