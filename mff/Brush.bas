﻿'################################################################################
'#  Brush.bi                                                                    #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov, Liu XiaLin                      #
'#  Based on:                                                                   #
'#   TBrush.bi                                                                  #
'#   FreeBasic Windows GUI ToolKit                                              #
'#   Copyright (c) 2007-2008 Nastase Eodor                                      #
'#   Version 1.0.0                                                              #
'#  Modified by Xusinboy Bekchanov (2018-2019), Liu XiaLin (2020)               #
'################################################################################

#include once "Brush.bi"

#ifdef __USE_WINAPI__
	' ugly colors for illustration purposes
	g_brItemBackground = CreateSolidBrush(BGR(&hC0, &hC0, &hFF))
	g_brItemBackgroundHot = CreateSolidBrush(BGR(&hD0, &hD0, &hFF))
	g_brItemBackgroundSelected = CreateSolidBrush(BGR(&hE0, &hE0, &hFF))
	g_menuTheme = 0
	hbrBkgnd = CreateSolidBrush(darkBkColor)
	hbrHlBkgnd = CreateSolidBrush(darkHlBkColor)
	hbrBkgndMenu = CreateSolidBrush(darkBkColorMenu)
#endif

Namespace My.Sys.Drawing
	#ifndef ReadProperty_Off
		Private Function Brush.ReadProperty(ByRef PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "color": Return @FColor
			Case "style": Return @FStyle
			Case "hatchstyle": Return @FHatchStyle
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function Brush.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			Select Case LCase(PropertyName)
			Case "color": This.Color = QInteger(Value)
			Case "style": This.Style = *Cast(BrushStyles Ptr, Value)
			Case "hatchstyle": This.HatchStyle = *Cast(HatchStyles Ptr, Value)
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
			Return True
		End Function
	#endif
	
	#ifndef Brush_Color_Get_Off
		Private Property Brush.Color As Integer
			Return FColor
		End Property
	#endif
	
	Private Property Brush.Color(Value As Integer)
		FColor = Value
		Create
	End Property
	
	Private Property Brush.Style As BrushStyles
		Return FStyle
	End Property
	
	Private Property Brush.Style(Value As BrushStyles)
		FStyle = Value
		Create
	End Property
	
	Private Property Brush.HatchStyle As HatchStyles
		Return FHatchStyle
	End Property
	
	Private Property Brush.HatchStyle(Value As HatchStyles)
		FHatchStyle = Value
		Create
	End Property
	
	Private Sub Brush.Create
		#ifdef __USE_WINAPI__
			Dim As LOGBRUSH LB
			LB.lbColor = FColor
			LB.lbHatch = FHatchStyle
			Select Case FStyle
			Case bsClear
				LB.lbStyle = BS_NULL
			Case bsSolid
				LB.lbStyle = BS_SOLID
			Case bsHatch
				LB.lbStyle = BS_HATCHED
				LB.lbHatch = FHatchStyle
			End Select
			If (Handle <> 0) AndAlso (Handle <> hbrBkgnd) Then DeleteObject(Handle)
			Handle = CreateBrushIndirect(@LB)
			If Handle Then If OnCreate Then OnCreate(*Designer, This)
		#endif
	End Sub
	
	#ifdef __USE_WINAPI__
		Private Operator Brush.Let(Value As HBRUSH)
			If (Handle <> 0) AndAlso (Handle <> hbrBkgnd) Then DeleteObject(Handle)
			Handle = Value
		End Operator
	#endif
	
	Private Operator Brush.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Constructor Brush
		FColor = &HFFFFFF
		FStyle = bsSolid
		'Create
		WLet(FClassName, "Brush")
	End Constructor
	
	Private Destructor Brush
		#ifdef __USE_WINAPI__
			If Handle AndAlso Handle <> hbrBkgnd Then DeleteObject Handle
		#endif
	End Destructor
End Namespace
