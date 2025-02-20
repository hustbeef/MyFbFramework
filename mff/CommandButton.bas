﻿'###############################################################################
'#  CommandButton.bi                                                           #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov                                 #
'#  Based on:                                                                  #
'#   TButton.bi                                                                #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#   Version 1.0.0                                                             #
'#  Updated and added cross-platform                                           #
'#  by Xusinboy Bekchanov (2018-2019)                                          #
'###############################################################################

#include once "CommandButton.bi"

Namespace My.Sys.Forms
	#ifndef ReadProperty_Off
		Private Function CommandButton.ReadProperty(PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "cancel": Return Cast(Any Ptr, @FCancel)
			Case "caption": Return Cast(Any Ptr, This.FText.vptr)
			Case "default": Return Cast(Any Ptr, @FDefault)
			Case "style": Return @FStyle
			Case "tabindex": Return @FTabIndex
			Case "text": Return Cast(Any Ptr, This.FText.vptr)
			Case "graphic": Return @Graphic
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function CommandButton.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
			Select Case LCase(PropertyName)
			Case "cancel": If Value <> 0 Then This.Cancel = QBoolean(Value)
			Case "caption": If Value <> 0 Then This.Text = QWString(Value)
			Case "default": If Value <> 0 Then This.Default = QBoolean(Value)
			Case "style": If Value <> 0 Then This.Style = *Cast(ButtonStyle Ptr, Value)
			Case "tabindex": If Value <> 0 Then This.TabIndex = QInteger(Value)
			Case "text": If Value <> 0 Then This.Text = QWString(Value)
			Case "graphic": If Value <> 0 Then This.Graphic = QWString(Value)
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
			Return True
		End Function
	#endif
	
	Private Property CommandButton.Caption ByRef As WString
		Return This.Text
	End Property
	
	Private Property CommandButton.Caption(ByRef Value As WString)
		This.Text = Value
	End Property
	
	Private Property CommandButton.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property CommandButton.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property CommandButton.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property CommandButton.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
	Private Property CommandButton.Text ByRef As WString
		Return Base.Text
	End Property
	
	Private Property CommandButton.Text(ByRef Value As WString)
		Base.Text = Value
		#ifdef __USE_GTK__
			gtk_label_set_text_with_mnemonic(GTK_LABEL(gtk_bin_get_child(GTK_BIN(widget))), ToUtf8(Replace(Value, "&", "_")))
		#elseif defined(__USE_JNI__)
			If FHandle Then
				(*env)->CallVoidMethod(env, FHandle, GetMethodID(*FClassAncestor, "setText", "(Ljava/lang/CharSequence;)V"), (*env)->NewStringUTF(env, ToUtf8(FText)))
			End If
		#endif
	End Property
	
	Private Property CommandButton.Cancel As Boolean
		Return FCancel
	End Property
	
	Private Property CommandButton.Cancel(Value As Boolean)
		If Value <> FCancel Then
			FCancel = Value
			Dim As Control Ptr frm = This.GetForm
			If frm Then
				If Value Then
					frm->FCancelButton = @This
				ElseIf frm->FCancelButton = @This Then
					frm->FCancelButton = 0
				End If
			End If
		End If
	End Property
	
	Private Property CommandButton.Default As Boolean
		#ifdef __USE_WINAPI__
			If Handle Then
				FDefault = (Style And BS_DEFPUSHBUTTON)
			End If
		#endif
		Return FDefault
	End Property
	
	Private Property CommandButton.Default(Value As Boolean)
		If Value <> FDefault Then
			FDefault = Value
			#ifdef __USE_GTK__
				gtk_widget_set_can_default(widget, Value)
			#elseif defined(__USE_WINAPI__)
				ChangeStyle BS_PUSHLIKE, False
				ChangeStyle BS_DEFPUSHBUTTON, Value
			#endif
			Dim As Control Ptr frm = This.GetForm
			If frm Then
				If Value Then
					frm->FDefaultButton = @This
				ElseIf frm->FDefaultButton = @This Then
					frm->FDefaultButton = 0
				End If
			End If
		End If
	End Property
	
	#ifndef CommandButton_Style_Get_Off
		Private Property CommandButton.Style As ButtonStyle
			Return FStyle
		End Property
	#endif
	
	Private Property CommandButton.Style(Value As ButtonStyle)
		If Value <> FStyle Then
			FStyle = Value
			#ifdef __USE_WINAPI__
				Base.Style = WS_CHILD Or AStyle(abs_(FStyle)) Or ADefault(abs_(FDefault))
				RecreateWnd
			#endif
		End If
	End Property
	
	Private Sub CommandButton.GraphicChange(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Drawing.GraphicType, Image As Any Ptr, ImageType As Integer)
		With Sender
			If .Ctrl->Child Then
				#ifdef __USE_WINAPI__
					Select Case ImageType
					Case IMAGE_BITMAP
						'QCommandButton(.Ctrl->Child).Style = bsBitmap
						QCommandButton(.Ctrl->Child).Perform(BM_SETIMAGE,ImageType,CInt(Sender.Bitmap.Handle))
					Case IMAGE_ICON
						'QCommandButton(.Ctrl->Child).Style = bsIcon
						QCommandButton(.Ctrl->Child).Perform(BM_SETIMAGE,ImageType,CInt(Sender.Icon.Handle))
					Case IMAGE_CURSOR
						'QCommandButton(.Ctrl->Child).Style = bsCursor
						QCommandButton(.Ctrl->Child).Perform(BM_SETIMAGE,ImageType,CInt(Sender.Icon.Handle))
					End Select
				#endif
			End If
		End With
	End Sub
	
	#ifdef __USE_WINAPI__
		Private Sub CommandButton.HandleIsAllocated(ByRef Sender As Control)
			If Sender.Child Then
				With QCommandButton(Sender.Child)
					.Perform(BM_SETIMAGE, .Graphic.ImageType, CInt(.Graphic.Image))
					If .FDefault OrElse .FCancel Then
						Dim As Control Ptr frm = .GetForm
						If frm Then
							If .FDefault Then
								frm->FDefaultButton = @Sender
							End If
							If .FCancel Then
								frm->FCancelButton = @Sender
							End If
						End If
					End If
				End With
			End If
		End Sub
		
		Private Sub CommandButton.WndProc(ByRef Message As Message)
			'        If Message.Sender Then
			'            If Cast(TControl Ptr,Message.Sender)->Child Then
			'               Cast(CommandButton Ptr,Cast(TControl Ptr,Message.Sender)->Child)->ProcessMessage(Message)
			'            End If
			'        End If
		End Sub
	#endif
	
	#ifndef CommandButton_EnumMenuItems_Off
		Private Function CommandButton.EnumMenuItems(Item As MenuItem, ByRef List As List) As Boolean
			For i As Integer = 0 To Item.Count -1
				List.Add Item.Item(i)
				EnumMenuItems *Item.Item(i),List
			Next i
			Return True
		End Function
	#endif
	
	Private Sub CommandButton.ProcessMessage(ByRef msg As Message)
		#ifdef __USE_WINAPI__
			Select Case msg.Msg
			Case WM_PAINT
				'If g_darkModeSupported AndAlso g_darkModeEnabled Then
				'	SetWindowTheme(.FHandle, "DarkMode_Explorer", nullptr)
				'	.Brush.Handle = hbrBkgnd
				'	SendMessageW(.FHandle, WM_THEMECHANGED, 0, 0)
				'End If
			'Case BM_CLICK
				'If OnClick Then OnClick(This)
			Case CM_COMMAND
				'If Message.wParamHi = BN_CLICKED Then
				'    If OnClick Then OnClick(This)
				'End If
			Case CM_NOTIFY
				If FDefaultForeColor <> FForeColor Then
					Dim As NMHDR Ptr nmhdr_ = Cast(NMHDR Ptr, msg.lParam)
					Select Case nmhdr_->code
					Case NM_CUSTOMDRAW
						Dim As LPNMCUSTOMDRAW nmcd = Cast(LPNMCUSTOMDRAW, msg.lParam)
						Select Case nmcd->dwDrawStage
						Case CDDS_PREPAINT
							If GetFocus() = nmcd->hdr.hwndFrom Then
								Dim innerRect As Rect
								innerRect = nmcd->rc
								InflateRect(@innerRect, -3, -3)
								DrawFocusRect(nmcd->hdc, @innerRect)
							End If
							SetBkMode nmcd->hdc, TRANSPARENT
							SetTextColor nmcd->hdc, FForeColor
							DrawText nmcd->hdc, FText.vptr, -1, @nmcd->rc, DT_CENTER Or DT_VCENTER Or DT_SINGLELINE
							msg.Result = CDRF_SKIPDEFAULT
						End Select
					End Select
				End If
			Case WM_GETDLGCODE: msg.Result = DLGC_BUTTON Or DLGC_WANTTAB Or IIf(FDefault, DLGC_DEFPUSHBUTTON, 0)
			Case CM_DRAWITEM
				Dim As DRAWITEMSTRUCT Ptr diStruct
				Dim As Rect R
				Dim As HDC Dc
				diStruct = Cast(DRAWITEMSTRUCT Ptr, msg.lParam)
				R = *Cast(Rect Ptr, @diStruct->rcItem)
				Dc = diStruct->hDC
				If OnDraw Then
					OnDraw(*Designer, This, R, Dc)
				Else
				End If
			Case WM_KEYUP
				If LoWord(msg.wParam) = VK_SPACE Or LoWord(msg.wParam) = VK_RETURN Then
					If OnClick Then OnClick(*Designer, This)
					msg.Result = -1
					Return
				End If
			End Select
		#endif
		Base.ProcessMessage(msg)
	End Sub
	
	Private Operator CommandButton.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
	#ifdef __USE_GTK__
		Private Sub CommandButton.Clicked(widget As GtkButton Ptr, user_data As Any Ptr)
			Dim As CommandButton Ptr but = user_data
			If but->OnClick Then but->OnClick(*but->Designer, *but)
		End Sub
	#endif
	
	Private Constructor CommandButton
		#ifdef __USE_GTK__
			widget = gtk_button_new_with_label("")
			g_signal_connect(widget, "clicked", G_CALLBACK(@Clicked), @This)
		#elseif defined(__USE_WINAPI__)
			AStyle(0)        = BS_TEXT
			AStyle(1)        = BS_BITMAP
			AStyle(2)        = BS_ICON
			AStyle(3)        = BS_ICON
			ADefault(0)      = 0 'BS_PUSHLIKE
			ADefault(1)      = BS_DEFPUSHBUTTON
		#endif
		Graphic.Ctrl  = @This
		Graphic.OnChange = @GraphicChange
		FTabIndex            = -1
		FTabStop = True
		With This
			.Child       = @This
			WLet(FClassName, "CommandButton")
			#ifdef __USE_WINAPI__
				WLet(FClassAncestor, "Button")
				.RegisterClass "CommandButton", "Button"
				.ChildProc   = @WndProc
				'.BackColor       = GetSysColor(COLOR_BTNFACE)
				.OnHandleIsAllocated = @HandleIsAllocated
			#elseif defined(__USE_GTK__)
				.RegisterClass "CommandButton", @This
			#elseif defined(__USE_JNI__)
				WLet(FClassAncestor, "android/widget/Button")
			#elseif defined(__USE_WASM__)
				FElementStyle = "overflow: hidden;"
				WLet(FClassAncestor, "button")
			#endif
			#ifdef __USE_WINAPI__
				.ExStyle     = 0
				Base.Style       = WS_CHILD Or WS_TABSTOP Or AStyle(abs_(FStyle)) Or ADefault(abs_(FDefault))
			#endif
			.Width       = 75
			.Height      = 25
		End With
	End Constructor
	
	Private Destructor CommandButton
	End Destructor
End Namespace
