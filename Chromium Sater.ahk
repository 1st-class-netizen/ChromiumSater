;
; Chromium Sater - Copyright (C) 2023 by 1st-class-netizen on Github under the terms of the GNU General Public License as published by the Free Software Foundation, version 3
; first published 06/20/2023 
;

#SingleInstance
Persistent
tray := A_TrayMenu ; For convenience.
tray.delete ; Delete the standard items.
tray.add "Enable/Disenable Macro", EnDisMacro
tray.add "Configure Macro", ConfigureMacro
tray.add "Exit", Exit


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


EnFlagReadVal()
{
	try
	EnFlag := RegRead("HKLM\Software\ChromiumSater","EnFlag",)
	catch OSError as err
	EnFlag := 0
	return EnFlag
}
GetsName()
{
	try
	sName := RegRead("HKLM\Software\ChromiumSater","Name",)
	catch OSError as err
	sName := 0
	return sName
}
GetsPath()
{
	sPath := RegRead("HKLM\Software\ChromiumSater","Path",)
	return sPath
}

EnDisMacro(*)
{
	EnFlag := !EnFlagReadVal()
	RegWrite EnFlag, "REG_SZ", "HKLM\SOFTWARE\ChromiumSater", "EnFlag"
	tray.ToggleCheck "Enable/Disenable Macro"
	Exit	
}
ConfigureMacro(*)
{
TextGui := Gui()
	HelpMenu := Menu()
	HelpMenu.Add "&Chromium Sater Help", (*) => MsgBox("• If macro is enabled, the program will expire in 5 seconds`n• The Enable/Disenable Macro tray menu item was programmed assuming the macro, only able to run on initialization, has finished. It applies the effect and closes the program.")
	HelpMenu.Add "&About Chromium Sater...", (*) => TextGui.Show()
	if (A_PtrSize = 8)
		script_is := "64-bit"
	else ; if (A_PtrSize = 4)
		script_is := "32-bit"
	Link := TextGui.Add("Link",
    , 'Chromium Sater 1.1 - ' . script_is . '`nCopyright (C) 2023 by 1st-class-netizen on Github under the terms of the GNU General Public License as published by the Free Software`nFoundation, version 3. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;`nwithout even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.`nIf Chromium Sater is very useful to you or if it plays the role of a laborsaving device, you can also show your appreciation by '
    . '<a id="help" href="https://www.autohotkey.com/docs/">buying me a coffee</a>.')
	Btn3 := TextGui.Add("Button", "x350", "Close") 
	Btn3.Focus()
	Btn3.OnEvent("Click", Hide)
	Link.OnEvent("Click", Link_Click)
	Link_Click(Ctrl, ID, HREF)
	{
		Run(HREF)
	}	
	Menus := MenuBar()
	Menus.Add "&Help", HelpMenu	; Attach the one submenu that was created above.
	MyGui := Gui()
	MyGui.MenuBar := Menus
	
	Tab := MyGui.Add("Tab2","r4 w350", ["Target","Working Directory"])
	MyGui.Add("Text",, "Enter the name of the Chromium launching file including its extension")
	MyGui.AddEdit("vMyEdit1 r1 w314")
	Tab.UseTab(2)
	MyGui.Add("Text",, "Enter the name of the Chromium launching file's working directory")
	MyGui.AddEdit("vMyEdit2 r3 w330")
	Tab.UseTab()  ; i.e. subsequently-added controls will not belong to the tab control.
	Btn := MyGui.Add("Button", "default xm", "OK")  ; leftmost margin
	Btn2 := MyGui.Add("Button", "default xp+108", "Delete Saved Macro Data") ; previous control's upper left corner
	Btn4 := MyGui.Add("Button", "default xp+210", "Exit")  ; previous control's upper left corner
	Btn.OnEvent("Click", ProcessUserInput)
	MyGui.OnEvent("Close", Exit)
	MyGui.OnEvent("Escape", Exit)
	Btn2.OnEvent("Click", DelUserInput)
	Btn4.Onevent("Click", Exit)
	MyGui.Show()
	ProcessUserInput(*)
	{
		Saved := MyGui.Submit()  ; Save the contents of named controls into an object.
		if(FileExist(Saved.MyEdit2 . "\" . Saved.MyEdit1)){
			RegCreateKey "HKLM\SOFTWARE\ChromiumSater"
			RegWrite Saved.MyEdit1, "REG_SZ", "HKLM\SOFTWARE\ChromiumSater", "Name"
			RegWrite Saved.MyEdit2, "REG_SZ", "HKLM\SOFTWARE\ChromiumSater", "Path"
			MsgBox("Extant launching file, values entered in registry:`n" Saved.MyEdit1 "`n" Saved.MyEdit2)
		}
		else
			MsgBox("Launching file does not exist, no values entered in registry")    
	}
	DelUserInput(*)
	{
		try
		RegDeleteKey "HKLM\SOFTWARE\ChromiumSater"
		catch OSError as err
		MsgBox("No ChromiumSater registry key to delete")
		else MsgBox("You deleted the ChromiumSater registry key")
		MyGui.Destroy()
	}	
	Hide(*)
	{
		TextGui.Hide()
	}
}
Exit(*)
{
    ExitApp
}

sName := GetsName()

if(!sName)
	MsgBox("Please fill out the Name and Path fields using the Configure Macro tray menu item")
else
{
	sPath := GetsPath()
	Run sName, sPath
	if WinWait("ahk_class Chrome_WidgetWin_1",,0.3)
		ResponsiveDelay := 250
	else
	{
		ResponsiveDelay := 0
		SetWinDelay 150
	}
}

EnFlagReadVal()

if (EnFlagReadVal()==1)
{
	tray.ToggleCheck "Enable/Disenable Macro"	
	if(ResponsiveDelay)
		Sleep ResponsiveDelay
	else
		WinWait("ahk_class Chrome_WidgetWin_1")
	Send "^{l}"
	Send "{Tab 4}"
	Send "{Enter}"
	Sleep 200
	Send "^{l}"
	Sleep 5000
	Exit
}
