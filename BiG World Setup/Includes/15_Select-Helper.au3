#include-once

; ---------------------------------------------------------------------------------------------
; Add a pause to the $g_CentralArray[$p_Num][15] or jump to the next component
; ---------------------------------------------------------------------------------------------
Func _Selection_ContextMenu()
	Local $FirstModItem, $NextModItem, $MenuItem[5]
	$p_Num = GUICtrlRead($g_UI_Interact[4][1])
	If $p_Num >= $g_CentralArray[0][1] And $p_Num <= $g_CentralArray[0][0] Then; prevent crashes if $g_CentralArray is undefined
		GUISetState(@SW_DISABLE); disable the GUI itself while selection is pending to avoid unwanted treeview-changes
		$OldMode=AutoItSetOption('GUIOnEventMode')
		If $OldMode Then AutoItSetOption('GUIOnEventMode', 0)
		$Tree = GUICtrlRead($p_Num, 1)
		$MenuString = $Tree
		If $g_CentralArray[$p_Num][2] = '-' Then $MenuString = $g_CentralArray[$p_Num][4]
		$IsPaused =  StringRegExp($Tree, '\s\x5bP\x5d\z')
		$g_UI_Menu[0][4] = GUICtrlCreateContextMenu($p_Num); create a context-menu on the clicked item
		$MenuLabel = GUICtrlCreateMenuItem($MenuString, $g_UI_Menu[0][4])
		GUICtrlSetState(-1, $GUI_DISABLE)
		GUICtrlCreateMenuItem('', $g_UI_Menu[0][4]); separator
; ---------------------------------------------------------------------------------------------
; Create the pause-menu items
; ---------------------------------------------------------------------------------------------
		If $g_CentralArray[$p_Num][2] = '-' Then
			$MenuItem[1] = GUICtrlCreateMenuItem(_GetTR($g_UI_Message, '4-L8'), $g_UI_Menu[0][4]); => pause before mod
			$MenuItem[2] = GUICtrlCreateMenuItem(_GetTR($g_UI_Message, '4-L9'), $g_UI_Menu[0][4]); => don't pause before mod
			$FirstModItem = $p_Num+1
			While StringRegExp($g_CentralArray[$FirstModItem][2], '\A\D')
				If $FirstModItem <= $g_CentralArray[0][0] Then ExitLoop
				$FirstModItem+=1
			WEnd
		Else
			$MenuItem[1] = GUICtrlCreateMenuItem(_GetTR($g_UI_Message, '4-L10'), $g_UI_Menu[0][4]); => pause before component
			$MenuItem[2] = GUICtrlCreateMenuItem(_GetTR($g_UI_Message, '4-L11'), $g_UI_Menu[0][4]); => don't pause before component
		EndIf
; ---------------------------------------------------------------------------------------------
; See if the mod was splitted and enable to jump to the next chapter
; ---------------------------------------------------------------------------------------------
		$Headline=_AI_GetStart($p_Num, '-')
		If $g_CentralArray[$Headline][13] <> '' Then
			$Splitted=StringSplit($g_CentralArray[$Headline][13], ',')
			$NextModItem=$Splitted[1]
		EndIf
		GUICtrlCreateMenuItem('', $g_UI_Menu[0][4]); separator
		$MenuItem[0] = GUICtrlCreateMenuItem(_GetTR($g_UI_Message, '4-L6'), $g_UI_Menu[0][4]); => visit homepage
		GUICtrlCreateMenuItem('', $g_UI_Menu[0][4]); separator
		If $g_CentralArray[$p_Num][2] <> '-' Then ; hide or expand the components
			$MenuItem[4] = GUICtrlCreateMenuItem(_GetTR($g_UI_Message, '4-M1'), $g_UI_Menu[0][4]); => hide components
		Else
			$State = _GUICtrlTreeView_GetExpanded($g_UI_Handle[0], $g_CentralArray[$p_Num][5])
			If $State = True Then
				$MenuItem[4] = GUICtrlCreateMenuItem(_GetTR($g_UI_Message, '4-M1'), $g_UI_Menu[0][4]); => hide components
			Else
				$MenuItem[4] = GUICtrlCreateMenuItem(_GetTR($g_UI_Message, '4-M2'), $g_UI_Menu[0][4]); => show components
			EndIf
		EndIf
		If $NextModItem <> '' Then; there is a next part of the mod >> create a menu-item
			GUICtrlCreateMenuItem('', $g_UI_Menu[0][4]); separator
			$MenuItem[3] = GUICtrlCreateMenuItem(_GetTR($g_UI_Message, '4-L12'), $g_UI_Menu[0][4]); => jump to next part of mod
		EndIf
		__ShowContextMenu($g_UI[0], $p_Num, $g_UI_Menu[0][4])
; ---------------------------------------------------------------------------------------------
; Create another Msg-loop, since the GUI is disabled and only the menuitems should be available
; ---------------------------------------------------------------------------------------------
		While 1
			$Msg = GUIGetMsg()
			Switch $Msg
			Case $MenuItem[0]; homepage
				_Selection_OpenPage()
				ExitLoop
			Case $MenuItem[1]; pause
				If Not $IsPaused Then GUICtrlSetData($p_Num, $Tree & ' [P]')
				If $g_CentralArray[$p_Num][2] = '-' Then
					$g_CentralArray[$FirstModItem][15]=1
				Else
					$g_CentralArray[$p_Num][15]=1
				EndIf
				ExitLoop
			Case $MenuItem[2]; not pause
				If $IsPaused Then GUICtrlSetData($p_Num, StringRegExpReplace($Tree, '\s\x5bP\x5d\z', ''))
				If $g_CentralArray[$p_Num][2] = '-' Then
					$g_CentralArray[$FirstModItem][15]=0
				Else
					$g_CentralArray[$p_Num][15]=0
				EndIf
				ExitLoop
			Case $MenuItem[3]; jump to next item
				If $MenuItem[3] = '' Then ExitLoop
				If $NextModItem = '' Then ExitLoop; no next item to jump to
				_GUICtrlTreeView_SelectItem($g_UI_Handle[0], $g_CentralArray[$NextModItem][5], $TVGN_FIRSTVISIBLE); select and view the first item
				_GUICtrlTreeView_SelectItem($g_UI_Handle[0], $g_CentralArray[$NextModItem][5], $TVGN_CARET)
				_GUICtrlTreeView_SetSelected($g_UI_Handle[0], $g_CentralArray[$NextModItem][5])
				ExitLoop
			Case $MenuItem[4]; (do not) expand components
				If $g_CentralArray[$p_Num][2] <> '-' Then
					_GUICtrlTreeView_Expand($g_UI_Handle[0], _AI_GetStart($p_Num, '-'), False)
				Else
					If $State = True Then
						_GUICtrlTreeView_Expand($g_UI_Handle[0], $p_Num, False)
					Else
						_GUICtrlTreeView_Expand($g_UI_Handle[0], $p_Num, True)
					EndIf
				EndIf
				ExitLoop
			Case Else
				If _IsPressed('01', $g_UDll) Then; react to a left mouseclick outside of the menu
					While  _IsPressed('01', $g_UDll)
						Sleep(10)
					WEnd
					ExitLoop
				ElseIf _IsPressed('02', $g_UDll) Then; react to a right mouseclick outside of the menu
					While  _IsPressed('02', $g_UDll)
						Sleep(10)
					WEnd
					ExitLoop
				EndIf
			EndSwitch
			Sleep(10)
		WEnd
		If $OldMode Then AutoItSetOption('GUIOnEventMode', 0)
		GUISetState(@SW_ENABLE); enable the GUI again
		GUICtrlDelete($g_UI_Menu[0][4])
	EndIf
	$g_Flags[16] = 0
EndFunc    ;==>_Selection_ContextMenu

; ---------------------------------------------------------------------------------------------
; Warn i expert mods are going to be installed
; ---------------------------------------------------------------------------------------------
Func _Selection_ExpertWarning()
	_PrintDebug('+' & @ScriptLineNumber & ' Calling _Selection_ExpertWarning')
	Local $Warning
	For $w = $g_CentralArray[0][1] To $g_CentralArray[0][0]
		If $g_CentralArray[$w][2] <> '-' Then ContinueLoop; only got interest in headlines
		If GUICtrlRead($w) = 0 Then ContinueLoop
		If $g_CentralArray[$w][9] <> 0 And $g_CentralArray[$w][11] = 'E' Then $Warning&=@CRLF&$g_CentralArray[$w][4]
	Next
	If $Warning = '' Then Return 2
	$Test=_Misc_MsgGUI(3, _GetTR($g_UI_Message, '0-T1'), _GetTR($g_UI_Message, '8-L1')&$Warning, 2); => expert-warning
	Return $Test
EndFunc    ;==>_Selection_ExpertWarning

; ---------------------------------------------------------------------------------------------
; Get the current install-version
; ---------------------------------------------------------------------------------------------
Func _Selection_GetCurrentInstallType()
	_PrintDebug('+' & @ScriptLineNumber & ' Calling _Selection_GetCurrentInstallType')
	$Array = StringSplit(_GetTR($g_UI_Message, '2-I1'), '|'); => versions
	$Num = StringSplit($g_Flags[25], '|')
	$String = GUICtrlRead($g_UI_Interact[2][4])
	$Found=0
	For $a = 1 To $Array[0]
		If $Array[$a] = $String Then
			$Found=1
			ExitLoop; the result is the number of the compilation type
		EndIf
	Next
	If $Found = 0 Then; prevent crash if language has changed
		If $g_Flags[14] = 'BWS' Then
			$a=1; total happiness
		Else
			$a=2; recommended
		EndIf
	EndIf
	ConsoleWrite($a & ' ' &  $Array[$a] & ' ' & $Num[$a]&@CRLF)
	$Compilation = StringSplit(IniRead($g_BWSIni, 'Options', 'Type', 'M,R,S,T,E'), ',')
	If StringLen($Num[$a]) = 2 Then; if custom selection set selection to tactics
		$g_Compilation='T'
	Else
		$g_Compilation=$Compilation[$Num[$a]]
	EndIf
	IniWrite($g_UsrIni, 'Options', 'InstallType', $Num[$a])
	Return $Num[$a]
EndFunc    ;==>_Selection_GetCurrentInstallType

; ---------------------------------------------------------------------------------------------
; Open the homepage of the currently selected mod
; ---------------------------------------------------------------------------------------------
Func _Selection_OpenPage($p_String='Link')
	$i = GUICtrlRead($g_UI_Interact[4][1]); get the current selection
	$HP=IniRead($g_ModIni, $g_CentralArray[$i][0], $p_String, '')
	If $HP <> '' And $HP <> '-' Then
		If $p_String = 'Wiki' Then $HP='http://kerzenburg.baldurs-gate.eu/wiki/'&$HP
		ShellExecute($HP); open the homepage if it is nursed
	EndIf
EndFunc    ;==>_Selection_OpenHomePage

; ---------------------------------------------------------------------------------------------
; Convert the WeiDU.log into a two-dimensional array
; Sample: ~BG2FIXPACK/SETUP-BG2FIXPACK.TP2~ #3 #0 // BG2 Fixpack - Hauptteil reparieren
; ---------------------------------------------------------------------------------------------
Func _Selection_ReadWeidu($p_File)
	If StringRegExp($p_File, '\A\D:') Then
		If Not FileExists($p_File) Then Return -1
		$p_File=FileRead($p_File)
	Else
		If $p_File = '' Then $p_File = ClipGet()
		If Not StringRegExp($p_File, '\A(//|~)') Then Return -1
	EndIf
	Local $Section[1000][2]
	$Array=StringSplit(StringStripCR($p_File), @LF)
	For $a=1 to $Array[0]
		If Not StringRegExp($Array[$a], '\A~') Then ContinueLoop
		$Name = StringRegExpReplace(StringRegExpReplace($Array[$a], '\A~|~.*\z', ''), '(?i)-{0,1}(setup)-{0,1}|\x2etp2\z|\A.*/', '')
		$Num = StringRegExp($Array[$a], '\d{1,}\s//', 3)
		If IsArray($Num) Then _IniWrite($Section, $Name, StringTrimRight($Num[0], 3))
	Next
	ReDim $Section[$Section[0][0]+1][2]
	Return $Section
EndFunc    ;==>_Selection_ReadWeidu

; ---------------------------------------------------------------------------------------------
; (Re)Color an item
; 0x1a8c14 lime = recommanded / 0x000070 dark = standard / 0xe8901a = tactics / 0xad1414 light = expert, 0xad1414
; ---------------------------------------------------------------------------------------------
Func _Selection_SearchColorItem($p_Num, $p_Color)
	If $p_Color Then
		GUICtrlSetColor($p_Num, 0xff0000); paint the hit red
	Else
		If $g_CentralArray[$p_Num][6] <> '' Then
			If $g_CentralArray[$p_Num][2] = '-' And StringInStr($g_CentralArray[$p_Num][11], 'R') Then
				GUICtrlSetColor($p_Num, 0x1a8c14); repaint the item lime, since it's recommanded
			ElseIf $g_CentralArray[$p_Num][2] = '-' And StringInStr($g_CentralArray[$p_Num][11], 'S') Then
				GUICtrlSetColor($p_Num, 0x000070); repaint the item darkblue, since it's standard
			ElseIf $g_CentralArray[$p_Num][2] = '-' And StringInStr($g_CentralArray[$p_Num][11], 'T') Then
				GUICtrlSetColor($p_Num, 0xe8901a); repaint the item rust, since it's tactics
			Else
				GUICtrlSetColor($p_Num, 0xad1414); repaint the item blue, since it's expert mod or a description
			EndIf
		Else
			GUICtrlSetColor($p_Num, 0x000000); repaint the item black, it's just a component without infos
		EndIf
	EndIf
EndFunc   ;==>_Selection_SearchColorItem

; ---------------------------------------------------------------------------------------------
; Set the treeviews mod-selection (from contextmenu)
; ---------------------------------------------------------------------------------------------
Func _Selection_SearchMulti($p_Type, $p_Last)
	_PrintDebug('+' & @ScriptLineNumber & ' Calling _Selection_Multi')
	_GUICtrlTreeView_BeginUpdate($g_UI_Handle[0])
	_Tree_ShowComponents('0')
	_Selection_SearchColorItem($g_Search[2], 0); reset the color of the last found single-search-item
	If $p_Last > $g_UI_Menu[0][2]-2 Then; reset the last found mass-search-items
		_Selection_SearchMultiSpecial($p_Last, 0)
	Else
		If IsNumber($p_Last) Then _Selection_SearchMultiGroup($p_Last, 0)
	EndIf
	If $p_Type > $g_UI_Menu[0][2]-2 Then
		_Selection_SearchMultiSpecial($p_Type, 1)
	Else
		If IsNumber($p_Type) Then _Selection_SearchMultiGroup($p_Type, 1)
	EndIf
	_GUICtrlTreeView_EndUpdate($g_UI_Handle[0])
EndFunc   ;==>_Selection_SearchMulti

; ---------------------------------------------------------------------------------------------
; Search for mods that belong to one chapter
; ---------------------------------------------------------------------------------------------
Func _Selection_SearchMultiGroup($p_Type, $p_Color)
	_PrintDebug('+' & @ScriptLineNumber & ' Calling _Selection_SearchMultiGroup')
	Local $FirstModItem
	For $m = $g_CentralArray[0][1] To $g_CentralArray[0][0]
		If $g_CentralArray[$m][2] <> '-' Then ContinueLoop; no interrest in components
		If StringRegExp($g_CentralArray[$m][1], '(\A|,)'&$p_Type&'(\z|,)') Then
			If $FirstModItem = '' Then $FirstModItem = $g_CentralArray[$m][5]
			If $p_Color Then _GUICtrlTreeView_SetState($g_UI_Handle[0], $g_CentralArray[$m][5], $TVIS_EXPANDED); expand the theme-tree
			_Selection_SearchColorItem($m, $p_Color)
		EndIf
	Next
	If $p_Color Then _GUICtrlTreeView_SelectItem($g_UI_Handle[0], $FirstModItem, $TVGN_FIRSTVISIBLE)
EndFunc   ;==>_Selection_SearchMultiGroup

; ---------------------------------------------------------------------------------------------
; Search for special groups defined in the Game.ini
; ---------------------------------------------------------------------------------------------
Func _Selection_SearchMultiSpecial($p_Type, $p_Color)
	_PrintDebug('+' & @ScriptLineNumber & ' Calling _Selection_SearchMultiSpecial')
	Local $FirstModItem
	$Num=$p_Type - ($g_UI_Menu[0][2]-2)
	For $c = $g_CentralArray[0][1] To $g_CentralArray[0][0]; loop through all mod-headlines and components
		If $g_CentralArray[$c][2] = '' Then ContinueLoop
		If $g_CentralArray[$c][2] <> '-' Then ContinueLoop
		If StringRegExp($g_Groups[$Num][1], '(?i)(\A|,)'&$g_CentralArray[$c][0]&'\x28') Then; is element selected?
			$Mod=StringRegExp($g_Groups[$Num][1], '(?i)'&$g_CentralArray[$c][0]&'[^\x29]*\x29', 3)
			If Not IsArray($Mod) Then ContinueLoop
			$Comp=StringRegExpReplace($Mod[0], '\A[^\x28]*', '')
			If $Comp = '(-)' Then
				If $FirstModItem = '' Then $FirstModItem = $g_CentralArray[$c][5]
				If $p_Color Then _GUICtrlTreeView_SetState($g_UI_Handle[0], $g_CentralArray[$g_CHTreeviewItem[$g_CentralArray[$c][1]]][5], $TVIS_EXPANDED); expand the theme-tree
				_Selection_SearchColorItem($c, $p_Color)
			Else
				Local $Current=$c
				$c+=1
				While $g_CentralArray[$c][2] <> '-'
					If StringRegExp($g_CentralArray[$c][2], '(?i)\A' & $Comp & '\z') Then
						If $FirstModItem = '' Then $FirstModItem = $g_CentralArray[$c][5]
						If $p_Color Then _GUICtrlTreeView_Expand($g_UI_Handle[0], $Current, True)
						_Selection_SearchColorItem($c, $p_Color)
					EndIf
					$c+=1
					If $c > $g_CentralArray[0][0] Then ExitLoop
				WEnd
				$c-=1
			EndIf
		EndIf
	Next
	If $p_Color Then _GUICtrlTreeView_SelectItem($g_UI_Handle[0], $FirstModItem, $TVGN_FIRSTVISIBLE)
EndFunc   ;==>_Selection_SearchMultiSpecial

; ---------------------------------------------------------------------------------------------
; Searches through the items in the treeview from Au3Select
; ---------------------------------------------------------------------------------------------
Func _Selection_SearchSingle($p_String, $p_Text)
	_PrintDebug('+' & @ScriptLineNumber & ' Calling _Selection_SearchSingle')
	If $p_String = $p_Text Then Return; don't do anything on the search-hint
	If $g_Search[0] = 'T' Then
		_Selection_SearchMulti('', $g_Search[3])
		$g_Search[0] = 'S'
	EndIf
	If $g_Search[1] <> $p_String Then; if the last search is diffrent from the new one
		$Mod = 1; search from first entry
	Else
		$Mod = $g_Search[2] + 1; search from the next entry
	EndIf
	If $g_Search[2] <> '' Then; if an item was found before
		If $g_CentralArray[$g_Search[2]][2] = '-' Then; if it's a headline continue to the next mod (saves you some clicks, since both the >>mods name<< and the component are search. Think about it. ;) )
			While $g_CentralArray[$Mod][2] <> '-'
				$Mod = $Mod + 1
			WEnd
		EndIf
		_Selection_SearchColorItem($g_Search[2], 0); reset the color of the last search
	EndIf
	$Last = $g_CentralArray[0][0]
	$Run = 1
; ---------------------------------------------------------------------------------------------
; loop through the elemets of the main-array. We make heavy usage of the main-array here. Now you know why it's that important. :)
; ---------------------------------------------------------------------------------------------
	For $m = $Mod To $Last; loop through the main-array
		If StringInStr($g_CentralArray[$m][3], $p_String) Or (StringInStr($g_CentralArray[$m][4], $p_String) And $g_CentralArray[$m][2] = '-') Or ($g_CentralArray[$m][0] = $p_String And $g_CentralArray[$m][2] = '-') Then
			If GUICtrlRead($m) = 0 Then ContinueLoop
			_GUICtrlTreeView_SelectItem($g_UI_Handle[0], $g_CentralArray[$m][5], $TVGN_FIRSTVISIBLE); focus the item
			_Selection_TipSetData($m)
			GUICtrlSetColor($m, 0xff0000); paint the item red
			$g_Search[2] = $m; remember the number of the element
			$g_Search[1] = $p_String; remember string searched for
			ExitLoop
		EndIf
		If $m = $g_CentralArray[0][0] And $Mod <> 1 Then; search from top to the current item if search hit the bottom and the current element is not the first one.
			$m = 1
			$Last = $Mod
			$Run = 2
		EndIf
		If $Run = 2 And $m = $Last Then ExitLoop
	Next
EndFunc   ;==>_Selection_SearchSingle

; ---------------------------------------------------------------------------------------------
; Switch help on / off on advanced tab
; ---------------------------------------------------------------------------------------------
Func _Selection_SetSize()
	_PrintDebug('+' & @ScriptLineNumber & ' Calling _Selection_SetSize')
	$Pos=ControlGetPos($g_UI[0], '', $g_UI_Interact[4][1])
	$State=GUICtrlGetState($g_UI_Interact[4][4])
	If BitAND($State, $GUI_HIDE) Then
		GUICtrlSetPos($g_UI_Interact[4][1], 15, 85, $Pos[2]-305, $Pos[3])
		GUICtrlSetPos($g_UI_Button[4][2], $Pos[2]-290, 85, 15, $Pos[3])
		GUICtrlSetState($g_UI_Interact[4][4], $GUI_SHOW)
		GUICtrlSetData($g_UI_Button[4][2], '>')
	Else
		GUICtrlSetPos($g_UI_Interact[4][1], 15, 85, $Pos[2]+305, $Pos[3])
		GUICtrlSetPos($g_UI_Button[4][2], $Pos[2]+320, 85, 15, $Pos[3])
		GUICtrlSetState($g_UI_Interact[4][4], $GUI_HIDE)
		GUICtrlSetData($g_UI_Button[4][2], '<')
	EndIf
EndFunc   ;==>_Selection_SetSize

; ---------------------------------------------------------------------------------------------
; Set the custom tooltip
; ---------------------------------------------------------------------------------------------
Func _Selection_TipSetData($p_Num)
	Local $Dsc
	If $p_Num < $g_CentralArray[0][1] Then Return; make sure this does not crash the script after some tree-rebuilding
	If $p_Num > $g_CentralArray[0][0] Then Return
	$Num=StringSplit($g_CentralArray[$p_Num][1], ','); Translate numbers into something readable
	For $n=1 to $Num[0]
		$Dsc&=','&$g_Tags[$Num[$n]+3][1]
	Next
	$Dsc=StringTrimLeft($Dsc, 1)
	If $g_CentralArray[$p_Num][2] = '-' Then
		$Headline=$Dsc & ' (v'& $g_CentralArray[$p_Num][15] & ' , ' & Round($g_CentralArray[$p_Num][7] / (1024 * 1024), 1) & ' MB, ' & $g_CentralArray[$p_Num][8] & ')'
	Else
		$Headline=$Dsc
	EndIf
	GUICtrlSetData($g_UI_Static[4][1], $Headline)
	GUICtrlSetData($g_UI_Interact[4][2], $g_CentralArray[$p_Num][6])
EndFunc   ;==>_Selection_TipSetData

; ---------------------------------------------------------------------------------------------
; Sets the tip-data for Au3Select
; ---------------------------------------------------------------------------------------------
Func _Selection_TipUpdate()
	$hItem = __TreeItemFromPoint($g_UI_Handle[0])
	If Not WinActive($g_UI[0]) Then; the mouse is not over the treeview
		$g_Flags[7] = ''; reset the old item to spawn again
		Return
	EndIf
	If $g_Flags[17] = 1 Then; label of a treeitem has been clicked
		$i=GUICtrlRead($g_UI_Interact[4][1])
		_Selection_TipSetData($i)
		$g_Flags[17] = 0
		$g_Flags[7] = $g_CentralArray[$i][5]
	Else; check for keyboard movement
		$i = GUICtrlRead($g_UI_Interact[4][1]); get the current selection
		If $g_CentralArray[$i][5] <> $g_Flags[7] Then; the itemhandle has changed
			_GUICtrlTreeView_DisplayRect($g_UI_Handle[0], $g_CentralArray[$i][5], True)
			_Selection_TipSetData($i)
			$g_Flags[7] = $g_CentralArray[$i][5]
		EndIf
	EndIf
EndFunc   ;==>_Selection_TipUpdate