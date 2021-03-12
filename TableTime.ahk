﻿#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.
#SingleInstance

; Starting page for basic tabs
BasicTabs:
  Gui, Destroy
  Loop, Files, %A_WorkingDir%\tabs\*, F
  {
    Hold := RegExReplace(A_LoopFileName, "\.txt")
    If (Mod(A_Index-1, 5) == 0)
      Gui, Add, Button, gButtonTest ym, %Hold%
    Else
      Gui, Add, Button, gButtonTest, %Hold%
  }
  Gui, Add, StatusBar,,
  Gui, Font, S15 cRed Bold Italic, Verdana
  Gui, Add, Button, w130 h60 xm gAdvancedTabs, Advanced Tab
  Gui, +MaximizeBox MinimizeBox +Resize +MinSize300x200
  Gui, show, , test
Return

ButtonTest:
  GuiControlGet, filename, focusv ; Get filename of button
  filename := filename ".txt"
  file := fileopen(A_WorkingDir "\tabs\" filename, "r`n") ; open the file
  filelength := 0
  loop, read, %A_WorkingDir%\tabs\%filename%
  {
    if (A_LoopReadLine == "")
      Break
    filelength += 1
    index%filelength% := A_LoopReadLine
  }
  Random, rng, 1, %filelength%
  output := 0
  FileReadLine, output, %a_workingdir%\tabs\%filename%, %rng%
  SB_SetText(output, , 2) ; statusbar update
  file.Close()
return

; create new gui for 
AdvancedTabs:
  Gui, Destroy
  Loop, Files, %A_WorkingDir%\advtabs\*, F
  {
    Hold := RegExReplace(a_Loopfilename, "\.txt")
    if (mod((a_Index-1), 5) == 0)
      Gui, Add, Button, gButtonAdv ym, %Hold%
    Else
      Gui, Add, Button, gButtonAdv, %Hold%
  }
  Gui, Add, StatusBar, ,
  Gui, Font, S15 cRed Bold Italic, Verdana
  Gui, Add, Button, w130 h60 xm gBasicTabs, Basic Tabs
  Gui, +MaximizeBox MinimizeBox +Resize +MinSize300x200
  Gui, Show, , test
Return

ButtonAdv:
  GuiControlGet, filename, FocusV ; get filename of button
  filename := filename ".txt"
  file := fileopen(A_WorkingDir "\advtabs\" filename, "r`n")
  sentence := file.ReadLine()
  keylist := [] ; stores keywords
  addtolist := False
  Loop, 50 ; probably no need for max loop but whatever
  { ; finds all keywords in sentence
    if (mod(a_index, 2) == 0) ; Only check odd hashes to get start of word
      Continue
    if (posstart := instr(sentence, "#", , , A_Index))
    {
      posend := instr(sentence, "#", , , a_index+1)
      keyword := substr(sentence, posstart, (posend-posstart+1))
      keyword := strreplace(keyword, "`r") ; get rid of LF and CR
      keyword := StrReplace(keyword, "`n")
      keylist.Push(keyword) ; assemble list of keywords
    }
    Else
    {
      file.Close()
      Break ; Stop looking when you stop finding hashes
    }
  }

  for ind,key in keylist
  {
    keynum := A_Index
    keytab%keynum% := [] ; make a table for each keyword
    loop, read, %A_WorkingDir%\advtabs\%filename%
    {
      if (A_Index == 1)
        Continue ; not adding first line to table
      if (addtolist == true and A_LoopReadLine != "{" and A_LoopReadLine != "}")
        keytab%keynum%.Push(A_LoopReadLine) ; If we found the start of the table inside the brackets, start adding words line by line
      if (instr(A_LoopReadLine, "}") and addtolist == true)
      {
        addtolist := False
        Break ; stop adding after coming to end of list
      }
      if (addtolist == false and InStr(a_loopreadline, key)) ; found keyword signifying start of table
        addtolist := true 
    }
    sentence := StrReplace(sentence, key, pickrandom(keytab%a_index%)) ; pick a random word for each keyword and modify the sentence
  }

  pickrandom(array)
  {
    Random, randind, 1, array.Length()
    return array[randind]
  }
  SB_SetText(sentence, , 2)
Return

GuiClose:
ExitApp
