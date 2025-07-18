﻿'###############################################################################
'#  ToolPalette.bi                                                             #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov                                 #
'#  Based on:                                                                  #
'#   TToolBar.bi                                                               #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#   Version 1.0.0                                                             #
'#  Adapted to ToolPalette and added cross-platform                            #
'#  by Xusinboy Bekchanov (2018-2019)                                          #
'###############################################################################

#include once "ToolPalette.bi"

Namespace My.Sys.Forms
	#ifndef ReadProperty_Off
		Private Function ToolPalette.ReadProperty(ByRef PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "autosize": Return @FAutosize
			'Case "caption": Return FText.vptr
			Case "flat": Return @FFlat
			Case "list": Return @FList
			Case "wrapable": Return @FWrapable
			Case "transparency": Return @FTransparent
			Case "disabledimageslist": Return DisabledImagesList
			Case "hotimageslist": Return HotImagesList
			Case "imageslist": Return ImagesList
			Case "divider": Return @FDivider
			Case "bitmapwidth": FBitmapWidth = This.BitmapWidth: Return @FBitmapWidth
			Case "bitmapheight": FBitmapHeight = This.BitmapHeight: Return @FBitmapHeight
			Case "buttonwidth": FButtonWidth = This.ButtonWidth: Return @FButtonWidth
			Case "buttonheight": FButtonHeight = This.ButtonHeight: Return @FButtonHeight
			Case "buttonscount": FButtonsCount = 0: Return @FButtonsCount
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function ToolPalette.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			If Value = 0 Then
				Select Case LCase(PropertyName)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			Else
				Select Case LCase(PropertyName)
				Case "autosize": This.AutoSize = QBoolean(Value)
				Case "bitmapwidth": This.BitmapWidth = QInteger(Value)
				Case "bitmapheight": This.BitmapHeight = QInteger(Value)
				Case "buttonwidth": This.ButtonWidth = QInteger(Value)
				Case "buttonheight": This.ButtonHeight = QInteger(Value)
				'Case "caption": This.Caption = QWString(Value)
				Case "flat": This.Flat = QBoolean(Value)
				Case "list": This.List = QBoolean(Value)
				Case "disabledimageslist": This.DisabledImagesList = Value
				Case "hotimageslist": This.HotImagesList = Value
				Case "imageslist": This.ImagesList = Value
				Case "divider": This.Divider = QBoolean(Value)
				Case "transparency": This.Transparency = QBoolean(Value)
				Case "wrapable": This.Wrapable = QBoolean(Value)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			End If
			Return True
		End Function
	#endif
	
	Private Constructor ToolGroup
		#ifdef __USE_GTK__
			Widget = gtk_tool_item_group_new("")
		#endif
		FExpanded = True
		Buttons.Parent = @This
	End Constructor
	
	Private Destructor ToolGroup
		WDeAllocate(FCaption)
		WDeAllocate(FName)
	End Destructor
	
	Private Property ToolGroup.CommandID As Integer
		Return FCommandID
	End Property
	
	Private Property ToolGroup.CommandID(Value As Integer)
		Dim As Integer i
		If Value <> FCommandID Then
			FCommandID = Value
			If Ctrl Then
				With QControl(Ctrl)
					#ifndef __USE_GTK__
						i = SendMessage(.Handle, TB_COMMANDTOINDEX, FCommandID, 0)
						SendMessage(.Handle, TB_SETCMDID,i,FCommandID)
					#endif
				End With
			End If
		End If
	End Property
	
	Private Function ToolGroup.Index As Integer
		If Ctrl Then
			Return Cast(ToolPalette Ptr, Ctrl)->Groups.IndexOf(@This)
		End If
		Return -1
	End Function
	
	Private Property ToolGroup.Caption ByRef As WString
		Return WGet(FCaption)
	End Property
	
	Private Property ToolGroup.Caption(ByRef Value As WString)
		WLet(FCaption, Value)
		#ifdef __USE_GTK__
			gtk_tool_item_group_set_label(GTK_TOOL_ITEM_GROUP(Widget), ToUtf8(Value))
		#endif
	End Property
	
	Private Property ToolGroup.Name ByRef As WString
		Return WGet(FName)
	End Property
	
	Private Property ToolGroup.Name(ByRef Value As WString)
		WLet(FName, Value)
	End Property
	
	Private Property ToolGroup.Expanded As Boolean
		Return FExpanded
	End Property
	
	Private Property ToolGroup.Expanded(Value As Boolean)
		FExpanded = Value
		#ifdef __USE_GTK__
			gtk_tool_item_group_set_collapsed(GTK_TOOL_ITEM_GROUP(Widget), Not Value)
		#else
			If Ctrl Then
				With QControl(Ctrl)
					.UpdateLock
					SendMessage(.Handle, TB_CHECKBUTTON, FCommandID, MAKELONG(FExpanded, 0))
					SendMessage(.Handle, TB_CHANGEBITMAP, FCommandID, MAKELONG(IIf(Value, 0, 1), 0))
					SendMessage(.Handle, TB_HIDEBUTTON, FCommandID * 10 + 1, MAKELONG(Not FExpanded, 0))
					For i As Integer = 0 To Buttons.Count - 1
						Buttons.Item(i)->Visible = FExpanded
					Next
					.UpdateUnLock
				End With
			End If
		#endif
	End Property
	
	Private Operator ToolGroup.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Property ToolGroupButtons.Count As Integer
		Return FButtons.Count
	End Property
	
	Private Property ToolGroupButtons.Count(Value As Integer)
	End Property
	
	Private Property ToolGroupButtons.Item(Index As Integer) As ToolButton Ptr
		Return Cast(ToolButton Ptr, FButtons.Items[Index])
	End Property
	
	Private Property ToolGroupButtons.Item(ByRef Key As WString) As ToolButton Ptr
		If IndexOf(Key) <> -1 Then Return Cast(ToolButton Ptr, FButtons.Items[IndexOf(Key)])
		Return 0
	End Property
	
	Private Property ToolGroupButtons.Item(Index As Integer, Value As ToolButton Ptr)
		'QToolButton(FButtons.Items[Index]) = Value
	End Property
	
	#ifdef __USE_GTK__
		Private Sub ToolGroupButtons.ToolButtonClicked(gtoolbutton As GtkToolButton Ptr, user_data As Any Ptr)
			Dim As ToolButton Ptr tbut = user_data
			If tbut Then
				If tbut->OnClick Then tbut->OnClick(*tbut->Designer, *tbut)
				If tbut->Ctrl AndAlso *tbut->Ctrl Is ToolBar Then
					Dim As ToolBar Ptr tb = Cast(ToolBar Ptr, tbut->Ctrl)
					If tb->OnButtonClick Then tb->OnButtonClick(*tb->Designer, *tb, *tbut)
				End If
			End If
		End Sub
	#endif
	
	Private Function ToolGroupButtons.Add(FStyle As ToolButtonStyle = tbsAutosize, FImageIndex As Integer = -1, Index As Integer = -1, FClick As NotifyEvent = NULL, ByRef FKey As WString = "", ByRef FCaption As WString = "", ByRef FHint As WString = "", FShowHint As Boolean = False, FState As ToolButtonState = tstEnabled) As ToolButton Ptr
		Dim As ToolButton Ptr PButton
		PButton = _New( ToolButton)
		PButton->FDynamic = True 
		FButtons.Add PButton
		With *PButton
			.Style          = FStyle
			#ifdef __USE_GTK__
				Select Case FStyle
				Case tbsSeparator
					.Widget = GTK_WIDGET(gtk_separator_tool_item_new())
				Case Else
					Select Case FStyle
					Case tbsButton
						.Widget = GTK_WIDGET(gtk_tool_button_new(NULL, ToUtf8(FCaption)))
					Case tbsAutosize
						.Widget = GTK_WIDGET(gtk_tool_button_new(NULL, ToUtf8(FCaption)))
					Case tbsCheck
						.Widget = GTK_WIDGET(gtk_toggle_tool_button_new())
					Case tbsCheckGroup
						If FButtons.Count > 1 AndAlso GTK_IS_RADIO_TOOL_BUTTON(QToolButton(FButtons.Item(FButtons.Count - 2)).Widget) Then
							.Widget = GTK_WIDGET(gtk_radio_tool_button_new_from_widget(GTK_RADIO_TOOL_BUTTON(QToolButton(FButtons.Item(FButtons.Count - 2)).Widget)))
						Else
							.Widget = GTK_WIDGET(gtk_radio_tool_button_new(NULL))
						End If
					Case tbsGroup
						If FButtons.Count > 1 AndAlso GTK_IS_RADIO_TOOL_BUTTON(QToolButton(FButtons.Item(FButtons.Count - 2)).Widget) Then
							.Widget = GTK_WIDGET(gtk_radio_tool_button_new_from_widget(GTK_RADIO_TOOL_BUTTON(QToolButton(FButtons.Item(FButtons.Count - 2)).Widget)))
						Else
							.Widget = GTK_WIDGET(gtk_radio_tool_button_new(NULL))
						End If
					Case tbsDropDown
						.Widget = GTK_WIDGET(gtk_menu_tool_button_new(NULL, ToUtf8(FCaption)))
						gtk_menu_tool_button_set_menu(GTK_MENU_TOOL_BUTTON(.Widget), .DropDownMenu.Handle)
						gtk_widget_show_all(.Widget)
					Case tbsNoPrefix
						.Widget = GTK_WIDGET(gtk_tool_button_new(NULL, ToUtf8(FCaption)))
					Case tbsShowText
						.Widget = GTK_WIDGET(gtk_tool_button_new(NULL, ToUtf8(FCaption)))
					Case tbsWholeDropdown
						.Widget = GTK_WIDGET(gtk_menu_tool_button_new(NULL, ToUtf8(FCaption)))
						gtk_menu_tool_button_set_menu(GTK_MENU_TOOL_BUTTON(.Widget), .DropDownMenu.Handle)
					Case Else
						.Widget = GTK_WIDGET(gtk_tool_button_new(NULL, ToUtf8(FCaption)))
					End Select
					gtk_tool_item_set_tooltip_text(GTK_TOOL_ITEM(.Widget), ToUtf8(FHint))
					g_signal_connect(.Widget, "clicked", G_CALLBACK(@ToolButtonClicked), PButton)
				End Select
				gtk_widget_show_all(.Widget)
			#endif
			.State        = FState
			.ImageIndex     = FImageIndex
			.Hint           = FHint
			.ShowHint       = FShowHint
			.Name         = FKey
			.Caption        = FCaption
			.CommandID      = (Cast(ToolGroup Ptr, This.Parent)->Index + 1) * 100 + FButtons.Count
			.OnClick        = FClick
		End With
		PButton->Ctrl = @Cast(ToolGroup Ptr, Parent)->Ctrl
		#ifdef __USE_GTK__
			If Parent Then
				gtk_tool_item_group_insert(GTK_TOOL_ITEM_GROUP(Cast(ToolGroup Ptr, Parent)->Widget), GTK_TOOL_ITEM(PButton->Widget), Index)
			End If
		#else
			Dim As TBBUTTON TB
			TB.fsState   = FState
			TB.fsStyle   = FStyle
			TB.iBitmap   = PButton->ImageIndex
			TB.idCommand = PButton->CommandID
			If FCaption <> "" Then
				TB.iString = CInt(@FCaption)
			Else
				TB.iString = 0
			End If
			TB.dwData = Cast(DWORD_PTR, @PButton->DropDownMenu)
			If This.Parent AndAlso Cast(ToolGroup Ptr, This.Parent)->Ctrl Then
				With *Cast(ToolGroup Ptr, This.Parent)
					If Index = -1 Then
						SendMessage(.Ctrl->Handle, TB_INSERTBUTTON, SendMessage(.Ctrl->Handle, TB_COMMANDTOINDEX, .CommandID, 0) + FButtons.Count + 1, CInt(@TB))
					Else
						SendMessage(.Ctrl->Handle, TB_INSERTBUTTON, SendMessage(.Ctrl->Handle, TB_COMMANDTOINDEX, .CommandID, 0) + Index + 1, CInt(@TB))
					End If
				End With
			End If
		#endif
		Return PButton
	End Function
	
	Private Function ToolGroupButtons.Add(FStyle As ToolButtonStyle = tbsAutosize, ByRef ImageKey As WString, Index As Integer = -1, FClick As NotifyEvent = NULL, ByRef FKey As WString = "", ByRef FCaption As WString = "", ByRef FHint As WString = "", FShowHint As Boolean = False, FState As ToolButtonState = tstEnabled) As ToolButton Ptr
		Dim As ToolButton Ptr PButton
		#ifdef __USE_GTK__
			PButton = Add(FStyle, -1, Index, FClick, FKey, FCaption, FHint, FShowHint, FState)
			If PButton Then PButton->ImageKey         = ImageKey
		#else
			If Parent AndAlso Cast(ToolGroup Ptr, Parent)->Ctrl AndAlso Cast(ToolPalette Ptr, Cast(ToolGroup Ptr, Parent)->Ctrl)->ImagesList Then
				With *Cast(ToolPalette Ptr, Cast(ToolGroup Ptr, Parent)->Ctrl)->ImagesList
					PButton = Add(FStyle, .IndexOf(ImageKey), Index, FClick, FKey, FCaption, FHint, FShowHint, FState)
				End With
			Else
				PButton = Add(FStyle, -1, Index, FClick, FKey, FCaption, FHint, FShowHint, FState)
			End If
		#endif
		Return PButton
	End Function
	
	Private Sub ToolGroupButtons.Remove(Index As Integer)
		FButtons.Remove Index
		If Parent AndAlso Cast(ToolGroup Ptr, Parent)->Ctrl Then
			#ifndef __USE_GTK__
				With *Cast(ToolGroup Ptr, Parent)
					SendMessage(.Ctrl->Handle, TB_DELETEBUTTON, SendMessage(.Ctrl->Handle, TB_COMMANDTOINDEX, .CommandID, 0) + Index + 2, 0)
				End With
			#endif
		End If
	End Sub
	
	Private Function ToolGroupButtons.IndexOf(ByRef FButton As ToolButton Ptr) As Integer
		Return FButtons.IndexOf(FButton)
	End Function
	
	Private Function ToolGroupButtons.IndexOf(ByRef Key As WString) As Integer
		For i As Integer = 0 To Count - 1
			If QToolButton(FButtons.Items[i]).Name = Key Then Return i
		Next i
		Return -1
	End Function
	
	Private Sub ToolGroupButtons.Clear
		For i As Integer = Count -1 To 0 Step -1
			_Delete( @QToolButton(FButtons.Items[i]))
		Next i
		FButtons.Clear
	End Sub
	
	Private Operator ToolGroupButtons.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Constructor ToolGroupButtons
		This.Clear
	End Constructor
	
	Private Destructor ToolGroupButtons
		This.Clear
	End Destructor
	
	Private Property ToolGroups.Count As Integer
		Return FGroups.Count
	End Property
	
	Private Property ToolGroups.Count(Value As Integer)
	End Property
	
	Private Property ToolGroups.Item(Index As Integer) As ToolGroup Ptr
		Return Cast(ToolGroup Ptr, FGroups.Items[Index])
	End Property
	
	Private Property ToolGroups.Item(ByRef Key As WString) As ToolGroup Ptr
		If IndexOf(Key) <> -1 Then Return Cast(ToolGroup Ptr, FGroups.Items[IndexOf(Key)])
		Return 0
	End Property
	
	Private Property ToolGroups.Item(Index As Integer, Value As ToolGroup Ptr)
		'QToolButton(FButtons.Items[Index]) = Value
	End Property
	
	Private Function ToolGroups.Add(ByRef Caption As WString, ByRef Key As WString = "") As ToolGroup Ptr
		Dim As ToolGroup Ptr PGroup
		PGroup = _New( ToolGroup)
		FGroups.Add PGroup
		With *PGroup
			.Name         = Key
			.Caption        = Caption
			.CommandID		= (FGroups.Count) * 100
		End With
		PGroup->Ctrl = Parent
		#ifdef __USE_GTK__
			If Parent AndAlso Parent->Handle Then
				gtk_container_add(GTK_CONTAINER (Parent->Handle), PGroup->Widget)
			End If
		#else
			If Parent Then
				Dim As TBBUTTON TB
				If FGroups.Count > 1 Then
					TB.fsState   = TBSTATE_ENABLED Or TBSTATE_WRAP
					TB.fsStyle   = TBSTYLE_SEP
					TB.iBitmap   = -1
					TB.idCommand = 0
					TB.iString = 0
					TB.dwData = 0
					SendMessage(Parent->Handle, TB_ADDBUTTONS, 1, CInt(@TB))
				End If
				TB.fsState   = TBSTATE_ENABLED Or TBSTATE_CHECKED Or TBSTATE_WRAP
				TB.fsStyle   = TBSTYLE_CHECK
				TB.iBitmap   = 0
				TB.idCommand = PGroup->CommandID
				If Caption <> "" Then
					TB.iString = CInt(@Caption)
				Else
					TB.iString = 0
				End If
				TB.dwData = 0 'Cast(DWord_Ptr,@PButton->DropDownMenu)
				'If Index <> -1 Then
				'	Parent->Parent->Perform(TB_INSERTBUTTON,Index,CInt(@TB))
				'Else
				SendMessage(Parent->Handle, TB_ADDBUTTONS, 1, CInt(@TB))
				'End If
				TB.fsState   = 0
				TB.fsStyle   = TBSTYLE_SEP
				TB.iBitmap   = -1
				TB.idCommand = PGroup->CommandID * 10 + 1
				TB.iString = 0
				TB.dwData = 0
				SendMessage(Parent->Handle, TB_ADDBUTTONS, 1, CInt(@TB))
			End If
		#endif
		Return PGroup
	End Function
	
	Private Sub ToolGroups.Remove(Index As Integer)
		FGroups.Remove Index
		If Parent Then
			#ifndef __USE_GTK__
				SendMessage(Parent->Parent->Handle, TB_DELETEBUTTON, Index, 0)
			#endif
		End If
	End Sub
	
	Private Function ToolGroups.IndexOf(ByRef FGroup As ToolGroup Ptr) As Integer
		Return FGroups.IndexOf(FGroup)
	End Function
	
	Private Function ToolGroups.IndexOf(ByRef Key As WString) As Integer
		For i As Integer = 0 To Count - 1
			If QToolGroup(FGroups.Items[i]).Name = Key Then Return i
		Next i
		Return -1
	End Function
	
	Private Sub ToolGroups.Clear
		For i As Integer = Count - 1 To 0 Step -1
			_Delete( @QToolGroup(FGroups.Items[i]))
		Next i
		FGroups.Clear
	End Sub
	
	Private Operator ToolGroups.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Constructor ToolGroups
		This.Clear
	End Constructor
	
	Private Destructor ToolGroups
		This.Clear
	End Destructor
	
	Private Property ToolPalette.ImagesList As ImageList Ptr
		Return FImagesList
	End Property
	
	Private Property ToolPalette.ImagesList(Value As ImageList Ptr)
		FImagesList = Value
		#ifndef __USE_GTK__
			If FImagesList Then FImagesList->ParentWindow = @This: If FImagesList->Handle Then Perform(TB_SETIMAGELIST, 0, CInt(FImagesList->Handle))
		#endif
	End Property
	
	Private Property ToolPalette.HotImagesList As ImageList Ptr
		Return FHotImagesList
	End Property
	
	Private Property ToolPalette.HotImagesList(Value As ImageList Ptr)
		FHotImagesList = Value
		#ifndef __USE_GTK__
			If FHotImagesList Then FHotImagesList->ParentWindow = @This: If FHotImagesList->Handle Then Perform(TB_SETHOTIMAGELIST, 0, CInt(FHotImagesList->Handle))
		#endif
	End Property
	
	Private Property ToolPalette.DisabledImagesList As ImageList Ptr
		Return FDisabledImagesList
	End Property
	
	Private Property ToolPalette.DisabledImagesList(Value As ImageList Ptr)
		FDisabledImagesList = Value
		#ifndef __USE_GTK__
			If FDisabledImagesList Then FDisabledImagesList->ParentWindow = @This: If FDisabledImagesList->Handle Then Perform(TB_SETDISABLEDIMAGELIST, 0, CInt(FDisabledImagesList->Handle))
		#endif
	End Property
	
	Private Sub ToolPalette.GetDropDownMenuItems
		FPopupMenuItems.Clear
		'For j As Integer = 0 To Buttons.Count - 1
		'    For i As Integer = 0 To Buttons.Item(j)->DropDownMenu.Count -1
		'        EnumPopupMenuItems *Buttons.Item(j)->DropDownMenu.Item(i)
		'    Next i
		'Next j
	End Sub
	
	Private Property ToolPalette.AutoSize As Boolean
		#ifndef __USE_GTK__
			FAutosize = StyleExists(TBSTYLE_AUTOSIZE)
		#endif
		Return FAutosize
	End Property
	
	Private Property ToolPalette.AutoSize(Value As Boolean)
		FAutosize = Value
		#ifndef __USE_GTK__
			ChangeStyle TBSTYLE_AUTOSIZE, Value
			If FHandle Then If FAutosize Then Perform(TB_AUTOSIZE, 0, 0)
		#endif
	End Property
	
	Private Property ToolPalette.Style As Integer
		Return FStyle
	End Property
	
	Private Property ToolPalette.Style(Value As Integer)
		FStyle = Value
		#ifdef __USE_GTK__
			Dim As GtkToolbarStyle gStyle
			Select Case FStyle
			Case 0: gStyle = GTK_TOOLBAR_ICONS
			Case 1: gStyle = GTK_TOOLBAR_TEXT
			Case 2: gStyle = GTK_TOOLBAR_BOTH
			Case 3: gStyle = GTK_TOOLBAR_BOTH_HORIZ
			End Select
			gtk_tool_palette_set_style(GTK_TOOL_PALETTE(widget), gStyle)
			'For i As Integer = 0 To Groups.Count - 1
			'	For j As Integer = 0 To Groups.Item(i)->Buttons.Count - 1
			'		With *Groups.Item(i)->Buttons.Item(i)
			'			.ImageKey = .ImageKey
			'		End With
			'	Next j
			'Next i
			If GTK_IS_CONTAINER(widget) Then gtk_widget_queue_resize(widget)
			If GTK_IS_WIDGET(widget) Then gtk_widget_queue_draw(widget)
		#else
			For j As Integer = 0 To Groups.Count - 1
				For i As Integer = 0 To Groups.Item(j)->Buttons.Count - 1
					With *Cast(ToolButton Ptr, Groups.Item(j)->Buttons.Item(i))
						If Value = 0 Then
							
						End If
						If Value = 0 Then
							.Caption = ""
							.Style = Cast(ToolButtonStyle, tbsCheckGroup Or tbsAutosize)
						Else
							.Caption = .Name
							.Style = tbsCheckGroup
						End If
					End With
				Next i
			Next j
			ChangeStyle TBSTYLE_AUTOSIZE, Value
			If FHandle Then
				If FAutosize Then Perform(TB_AUTOSIZE, 0, 0)
				RecreateWnd
			End If
		#endif
	End Property
	
	Private Property ToolPalette.Flat As Boolean
		#ifndef __USE_GTK__
			FFlat = StyleExists(TBSTYLE_FLAT)
		#endif
		Return FFlat
	End Property
	
	Private Property ToolPalette.Flat(Value As Boolean)
		FFlat = Value
		#ifndef __USE_GTK__
			ChangeStyle TBSTYLE_FLAT, Value
		#endif
	End Property
	
	Private Property ToolPalette.List As Boolean
		#ifndef __USE_GTK__
			FList = StyleExists(TBSTYLE_LIST)
		#endif
		Return FList
	End Property
	
	Private Property ToolPalette.List(Value As Boolean)
		FList = Value
		#ifndef __USE_GTK__
			ChangeStyle TBSTYLE_LIST, Value
		#endif
	End Property
	
	
	Private Property ToolPalette.Divider As Boolean
		#ifndef __USE_GTK__
			FDivider = Not StyleExists(CCS_NODIVIDER)
		#endif
		Return FDivider
	End Property
	
	Private Property ToolPalette.Divider(Value As Boolean)
		FDivider = Value
		#ifndef __USE_GTK__
			ChangeStyle CCS_NODIVIDER, Not Value
		#endif
	End Property
	
	Private Property ToolPalette.Transparency As Boolean
		#ifndef __USE_GTK__
			FTransparent = StyleExists(TBSTYLE_TRANSPARENT)
		#endif
		Return FTransparent
	End Property
	
	Private Property ToolPalette.Transparency(Value As Boolean)
		FTransparent = Value
		#ifndef __USE_GTK__
			ChangeStyle TBSTYLE_TRANSPARENT, Value
		#endif
	End Property
	
	Private Property ToolPalette.BitmapWidth As Integer
		Return FBitmapWidth
	End Property
	
	Private Property ToolPalette.BitmapWidth(Value As Integer)
		FBitmapWidth = Value
		#ifndef __USE_GTK__
			If Handle Then Perform(TB_SETBITMAPSIZE, 0, MAKELONG(FBitmapWidth, FBitmapHeight))
		#endif
	End Property
	
	Private Property ToolPalette.BitmapHeight As Integer
		Return FBitmapHeight
	End Property
	
	Private Property ToolPalette.BitmapHeight(Value As Integer)
		FBitmapHeight = Value
		#ifndef __USE_GTK__
			If Handle Then Perform(TB_SETBITMAPSIZE, 0, MAKELONG(FBitmapWidth, FBitmapHeight))
		#endif
	End Property
	
	Private Property ToolPalette.ButtonWidth As Integer
		Return FButtonWidth
	End Property
	
	Private Property ToolPalette.ButtonWidth(Value As Integer)
		FButtonWidth = Value
		#ifndef __USE_GTK__
			If Handle Then Perform(TB_SETBUTTONSIZE,0,MAKELONG(ScaleX(FButtonWidth),ScaleY(FButtonHeight)))
		#endif
	End Property
	
	Private Property ToolPalette.ButtonHeight As Integer
		Return FButtonHeight
	End Property
	
	Private Property ToolPalette.ButtonHeight(Value As Integer)
		FButtonHeight = Value
		#ifndef __USE_GTK__
			If Handle Then Perform(TB_SETBUTTONSIZE,0,MAKELONG(ScaleX(FButtonWidth),ScaleY(FButtonHeight)))
		#endif
	End Property
	
	Private Property ToolPalette.Wrapable As Boolean
		#ifndef __USE_GTK__
			FWrapable = StyleExists(TBSTYLE_WRAPABLE)
		#endif
		Return FWrapable
	End Property
	
	Private Property ToolPalette.Wrapable(Value As Boolean)
		FWrapable = Value
		#ifndef __USE_GTK__
			ChangeStyle TBSTYLE_WRAPABLE, Value
		#endif
	End Property
	
	Private Sub ToolPalette.WndProc(ByRef Message As Message)
	End Sub
	
	#ifdef __USE_WINAPI__
		Private Sub ToolPalette.SetDark(Value As Boolean)
			Base.SetDark Value
			If Value Then
				SetWindowTheme(FHandle, "DarkMode_InfoPaneToolbar", nullptr) 'DarkMode_BBComposited
				Brush.Handle = hbrBkgnd
				'SendMessageW(FHandle, WM_THEMECHANGED, 0, 0)
			End If
			'SendMessage FHandle, WM_THEMECHANGED, 0, 0
		End Sub
	#endif
	
	Private Sub ToolPalette.ProcessMessage(ByRef Message As Message)
		#ifndef __USE_GTK__
			Select Case Message.Msg
			Case WM_PAINT
				If g_darkModeSupported AndAlso g_darkModeEnabled AndAlso FDefaultBackColor = FBackColor Then
					If Not FDarkMode Then
						SetDark True
'						FDarkMode = True
'						SetWindowTheme(FHandle, "DarkMode_InfoPaneToolbar", nullptr) 'DarkMode_BBComposited
'						Brush.Handle = hbrBkgnd
'						SendMessageW(FHandle, WM_THEMECHANGED, 0, 0)
					End If
				End If
				Message.Result = 0
			Case WM_DPICHANGED
				Base.ProcessMessage(Message)
				Perform(TB_SETBITMAPSIZE, 0, MAKELONG(ScaleX(FBitmapWidth), ScaleY(FBitmapHeight)))
				If ImagesList Then ImagesList->SetImageSize FBitmapWidth, FBitmapHeight, xdpi, ydpi
				If HotImagesList Then HotImagesList->SetImageSize FBitmapWidth, FBitmapHeight, xdpi, ydpi
				If DisabledImagesList Then DisabledImagesList->SetImageSize FBitmapWidth, FBitmapHeight, xdpi, ydpi
				If ImagesList AndAlso ImagesList->Handle Then SendMessage(FHandle, TB_SETIMAGELIST, 0, CInt(ImagesList->Handle))
				For i As Integer = 0 To Groups.Count - 1
					For j As Integer = 0 To Groups.Item(i)->Buttons.Count - 1
						Groups.Item(i)->Buttons.Item(j)->xdpi = xdpi
						Groups.Item(i)->Buttons.Item(j)->ydpi = ydpi
						Groups.Item(i)->Buttons.Item(j)->Update
						Groups.Item(i)->Buttons.Item(j)->Caption = Groups.Item(i)->Buttons.Item(j)->Caption
					Next
				Next
				SetBounds FLeft, FTop, FWidth, FHeight
				Return
			Case WM_DESTROY
				If ImagesList Then Perform(TB_SETIMAGELIST, 0, 0)
				If HotImagesList Then Perform(TB_SETHOTIMAGELIST, 0, 0)
				If DisabledImagesList Then Perform(TB_SETDISABLEDIMAGELIST, 0, 0)
			Case WM_SIZE
				If AutoSize Then
					Dim As ..Rect R
					GetWindowRect Handle, @R
					FHeight = R.Bottom - R.Top
				End If
			Case WM_LBUTTONDBLCLK
				Var nIndex = SendMessage(FHandle, TB_GETHOTITEM, 0, 0)
				If nIndex >= 0 Then
					Dim As TBBUTTONINFO tbinfo
					tbinfo.cbSize = SizeOf(TBBUTTONINFO)
					tbinfo.dwMask = TBIF_COMMAND Or TBIF_BYINDEX
					SendMessage(FHandle, TB_GETBUTTONINFO, nIndex, Cast(LPARAM, @tbinfo))
					Dim As UINT nCommand = tbinfo.idCommand
					Dim As Integer gi, bi
					Dim As String comm = Trim(Str(nCommand))
					gi = Val(..Left(comm, Len(comm) - 2)) - 1
					bi = Val(Mid(comm, Len(comm) - 1)) - 1
					If gi > -1 AndAlso gi < Groups.Count Then
						If bi = -1 Then
							'Groups.Item(gi)->Expanded = Not Groups.Item(gi)->Expanded
						ElseIf bi > -1 AndAlso bi < Groups.Item(gi)->Buttons.Count Then
							Dim As ToolButton Ptr but = Groups.Item(gi)->Buttons.Item(bi)
							If OnButtonActivate Then OnButtonActivate(*Designer, This, *but)
							Message.Result = -1
						End If
					End If
				End If
			Case WM_KEYDOWN
				If Message.wParam = VK_RETURN Then
					Var nIndex = SendMessage(FHandle, TB_GETHOTITEM, 0, 0)
					If nIndex >= 0 Then
						Dim As TBBUTTONINFO tbinfo
						tbinfo.cbSize = SizeOf(TBBUTTONINFO)
						tbinfo.dwMask = TBIF_COMMAND Or TBIF_BYINDEX
						SendMessage(FHandle, TB_GETBUTTONINFO, nIndex, Cast(LPARAM, @tbinfo))
						Dim As UINT nCommand = tbinfo.idCommand
						Dim As Integer gi, bi
						Dim As String comm = Trim(Str(nCommand))
						gi = Val(..Left(comm, Len(comm) - 2)) - 1
						bi = Val(Mid(comm, Len(comm) - 1)) - 1
						If gi > -1 AndAlso gi < Groups.Count Then
							If bi = -1 Then
								Groups.Item(gi)->Expanded = Not Groups.Item(gi)->Expanded
							ElseIf bi > -1 AndAlso bi < Groups.Item(gi)->Buttons.Count Then
								Dim As ToolButton Ptr but = Groups.Item(gi)->Buttons.Item(bi)
								but->Checked = True
								If OnButtonActivate Then OnButtonActivate(*Designer, This, *but)
							End If
						End If
					End If
				End If
			Case WM_COMMAND
				GetDropDownMenuItems
				For i As Integer = 0 To FPopupMenuItems.Count -1
					If QMenuItem(FPopupMenuItems.Items[i]).Command = Message.wParamLo Then
						If QMenuItem(FPopupMenuItems.Items[i]).OnClick Then QMenuItem(FPopupMenuItems.Items[i]).OnClick(*QMenuItem(FPopupMenuItems.Items[i]).Designer, QMenuItem(FPopupMenuItems.Items[i]))
						Exit For
					End If
				Next i
			Case CM_COMMAND
				Dim As Integer Index
				Dim As TBBUTTON TB
				If Message.wParam <> 0 Then
					'Index = Perform(TB_COMMANDTOINDEX, Message.wParam, 0)
					Dim As Integer gi, bi
					Dim As String comm = Trim(Str(Message.wParam))
					gi = Val(..Left(comm, Len(comm) - 2)) - 1
					bi = Val(Mid(comm, Len(comm) - 1)) - 1
					If gi > -1 AndAlso gi < Groups.Count Then
						If bi = -1 Then
							Groups.Item(gi)->Expanded = Not Groups.Item(gi)->Expanded
						ElseIf bi > -1 AndAlso bi < Groups.Item(gi)->Buttons.Count Then
							Dim As ToolButton Ptr but = Groups.Item(gi)->Buttons.Item(bi)
							If but->OnClick Then but->OnClick(*but->Designer, *but)
							If OnButtonClick Then OnButtonClick(*Designer, This, *but)
						End If
					End If
				End If
			Case CM_NOTIFY
				Dim As TBNOTIFY Ptr Tbn
				Dim As TBBUTTON TB
				Dim As Rect R
				Dim As Integer i
				Tbn = Cast(TBNOTIFY Ptr,Message.lParam)
				Select Case Tbn->hdr.code
				Case TBN_DROPDOWN
					If Tbn->iItem <> -1 Then
						SendMessage(Tbn->hdr.hwndFrom, TB_GETRECT, Tbn->iItem, CInt(@R))
						MapWindowPoints(Tbn->hdr.hwndFrom, 0, Cast(..Point Ptr, @R), 2)
						i = SendMessage(Tbn->hdr.hwndFrom, TB_COMMANDTOINDEX, Tbn->iItem, 0)
						If SendMessage(Tbn->hdr.hwndFrom, TB_GETBUTTON, i, CInt(@TB)) Then
							'TrackPopupMenu(Buttons.Item(i)->DropDownMenu.Handle,0,R.Left,R.Bottom,0,Tbn->hdr.hwndFrom,NULL)
						End If
					End If
				End Select
			Case CM_NEEDTEXT
				Dim As LPTOOLTIPTEXT TTX
				TTX = Cast(LPTOOLTIPTEXT,Message.lParam)
				TTX->hinst = GetModuleHandle(NULL)
				If TTX->hdr.idFrom Then
					Dim As TBBUTTON TB
					Dim As Integer Index
					Index = Perform(TB_COMMANDTOINDEX,TTX->hdr.idFrom,0)
					If Perform(TB_GETBUTTON,Index,CInt(@TB)) Then
						'					   If Buttons.Item(Index)->ShowHint Then
						'						  If Buttons.Item(Index)->Hint <> "" Then
						'							  'Dim As UString s
						'							  's = Buttons.Button(Index).Hint
						'							  TTX->lpszText = @(Buttons.Item(Index)->Hint)
						'						  End If
						'					   End If
					End If
				End If
			End Select
		#endif
		Base.ProcessMessage(Message)
	End Sub
	
	Private Sub ToolPalette.HandleIsDestroyed(ByRef Sender As Control)
	End Sub
	
	Private Sub ToolPalette.HandleIsAllocated(ByRef Sender As Control)
		#ifndef __USE_GTK__
			If Sender.Child Then
				With QToolPalette(Sender.Child)
					If .ImagesList Then .ImagesList->ParentWindow = @Sender: If .ImagesList->Handle Then .Perform(TB_SETIMAGELIST,0,CInt(.ImagesList->Handle))
					If .HotImagesList Then .HotImagesList->ParentWindow = @Sender: If .HotImagesList->Handle Then .Perform(TB_SETHOTIMAGELIST,0,CInt(.HotImagesList->Handle))
					If .DisabledImagesList Then .DisabledImagesList->ParentWindow = @Sender: If .DisabledImagesList->Handle Then .Perform(TB_SETDISABLEDIMAGELIST,0,CInt(.DisabledImagesList->Handle))
					.Perform(TB_BUTTONSTRUCTSIZE, SizeOf(TBBUTTON), 0)
					.Perform(TB_SETEXTENDEDSTYLE, 0, .Perform(TB_GETEXTENDEDSTYLE, 0, 0) Or TBSTYLE_EX_DRAWDDARROWS)
					.Perform(TB_SETBUTTONSIZE, 0, MAKELONG(.ScaleX(.FButtonWidth), .ScaleY(.FButtonHeight)))
					If .ScaleX(.FBitmapWidth) <> 16 AndAlso .ScaleY(.FBitmapHeight) <> 16 Then .Perform(TB_SETBITMAPSIZE, 0, MAKELONG(.ScaleX(.FBitmapWidth), .ScaleY(.FBitmapHeight)))
					Dim As TBBUTTON TB
					For j As Integer = 0 To .Groups.Count -1
						If j > 0 Then
							TB.fsState   = 0
							TB.fsStyle   = TBSTYLE_SEP
							TB.iBitmap   = -1
							TB.idCommand = 0
							TB.iString = 0
							TB.dwData = 0
							.Perform(TB_ADDBUTTONS, 1, CInt(@TB))
						End If
						TB.fsState   = TBSTATE_ENABLED Or TBSTATE_CHECKED Or TBSTATE_WRAP
						TB.fsStyle   = TBSTYLE_CHECK
						TB.iBitmap   = 0
						TB.idCommand = .Groups.Item(j)->CommandID
						If .Groups.Item(j)->Caption <> "" Then
							TB.iString = CInt(@.Groups.Item(j)->Caption)
						Else
							TB.iString = 0
						End If
						TB.dwData = 0 'Cast(DWord_Ptr,@PButton->DropDownMenu)
						.Perform(TB_ADDBUTTONS, 1, CInt(@TB))
						TB.fsState   = 0
						TB.fsStyle   = TBSTYLE_SEP
						TB.iBitmap   = -1
						TB.idCommand = .Groups.Item(j)->CommandID * 10 + 1
						TB.iString = 0
						TB.dwData = 0
						.Perform(TB_ADDBUTTONS, 1, CInt(@TB))
						Var FHandle = .FHandle
						For i As Integer = 0 To .Groups.Item(j)->Buttons.Count - 1
							.FHandle = 0
							.Groups.Item(j)->Buttons.Item(i)->Ctrl = @Sender
							'Dim As WString Ptr s = .Buttons.Button(i)->Caption
							If i = .Groups.Item(j)->Buttons.Count - 1 Then
								TB.fsState = .Groups.Item(j)->Buttons.Item(i)->State Or TBSTATE_WRAP
							Else
								TB.fsState = .Groups.Item(j)->Buttons.Item(i)->State
							End If
							TB.fsStyle   = .Groups.Item(j)->Buttons.Item(i)->Style
							TB.iBitmap   = .Groups.Item(j)->Buttons.Item(i)->ImageIndex
							TB.idCommand = .Groups.Item(j)->Buttons.Item(i)->CommandID
							If .Groups.Item(j)->Buttons.Item(i)->Caption <> "" Then
								TB.iString   = CInt(@.Groups.Item(j)->Buttons.Item(i)->Caption)
							Else
								TB.iString   = 0
							End If
							TB.dwData    = Cast(DWORD_PTR, @.Groups.Item(j)->Buttons.Item(i)->DropDownMenu)
							.FHandle = FHandle
							.Perform(TB_ADDBUTTONS, 1, CInt(@TB))
						Next i
					Next j
					If .AutoSize Then .Perform(TB_AUTOSIZE,0,0)
				End With
			End If
		#endif
	End Sub
	
	
	Private Operator ToolPalette.Cast As Control Ptr
		Return @This
	End Operator
	
	Private Constructor ToolPalette
		With This
			#ifdef __USE_GTK__
				widget = gtk_tool_palette_new()
				gtk_tool_palette_set_style(GTK_TOOL_PALETTE(widget), GTK_TOOLBAR_BOTH_HORIZ)
				scrolledwidget = gtk_scrolled_window_new(NULL, NULL)
				gtk_scrolled_window_set_policy(GTK_SCROLLED_WINDOW(scrolledwidget), GTK_POLICY_AUTOMATIC, GTK_POLICY_AUTOMATIC)
				gtk_container_add(GTK_CONTAINER(scrolledwidget), widget)
				.RegisterClass "ToolPalette", @This
			#else
				AFlat(0)        = 0
				AFlat(1)        = TBSTYLE_FLAT
				ADivider(0)     = CCS_NODIVIDER
				ADivider(1)     = 0
				AAutosize(0)    = 0
				AAutosize(1)    = TBSTYLE_AUTOSIZE
				AList(0)        = 0
				AList(1)        = TBSTYLE_LIST
				AState(0)       = TBSTATE_INDETERMINATE
				AState(1)       = TBSTATE_ENABLED
				AState(2)       = TBSTATE_HIDDEN
				AState(3)       = TBSTATE_CHECKED
				AState(4)       = TBSTATE_PRESSED
				AState(5)       = TBSTATE_WRAP
				AWrap(0)        = 0
				AWrap(1)        = TBSTYLE_WRAPABLE
				ATransparent(0) = 0
				ATransparent(1) = TBSTYLE_TRANSPARENT
			#endif
			FTransparent    = 1
			FAutosize       = 1
			FBitmapWidth    = 16
			FBitmapHeight   = 16
			FButtonWidth    = 16
			FButtonHeight   = 16
			Groups.Parent  = @This
			FEnabled = True
			#ifndef __USE_GTK__
				.OnHandleIsAllocated = @HandleIsAllocated
				.OnHandleIsDestroyed = @HandleIsDestroyed
				.ChildProc         = @WndProc
				.ExStyle           = 0
				Base.Style             = WS_CHILD Or TBSTYLE_TOOLTIPS Or CCS_NOPARENTALIGN Or CCS_NOMOVEY Or AList(FList) Or AAutosize(_Abs(FAutosize)) Or AFlat(_Abs(FFlat)) Or ADivider(_Abs(FDivider)) Or AWrap(_Abs(FWrapable)) Or ATransparent(_Abs(FTransparent))
				.RegisterClass "ToolPalette", "ToolBarWindow32"
			#endif
			.Child             = @This
			WLet(FClassName, "ToolPalette")
			WLet(FClassAncestor, "ToolBarWindow32")
			.Width             = 121
			.Height            = 26
			'.Font              = @Font
			'.Cursor            = @Cursor
		End With
	End Constructor
	
	Private Destructor ToolPalette
		Groups.Clear
		#ifndef __USE_GTK__
			'UnregisterClass "ToolPalette", GetmoduleHandle(NULL)
		#endif
	End Destructor
End Namespace
