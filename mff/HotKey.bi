﻿'###############################################################################
'#  HotKey.bi                                                                  #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Xusinboy Bekchanov (2018-2019)                                    #
'###############################################################################

#include once "Control.bi"

Namespace My.Sys.Forms
	#define QHotKey(__Ptr__) (*Cast(HotKey Ptr, __Ptr__))
	
	'`HotKey` is a Control within the MyFbFramework, part of the freeBasic framework.
	'`HotKey` - A hot key control is a window that enables the user to enter a combination of keystrokes to be used as a hot key.
	Private Type HotKey Extends Control
	Private:
		#ifndef __USE_GTK__
			Declare Static Sub WndProc(ByRef Message As Message)
			Declare Static Sub HandleIsAllocated(ByRef Sender As My.Sys.Forms.Control)
		#else
			Declare Static Sub Entry_Activate(entry As GtkEntry Ptr, user_data As Any Ptr)
			Dim As Boolean bKeyPressed, bCtrl, bShift, bAlt, bMeta, bSuper, bHyper
		#endif
	Protected:
		Declare Virtual Sub ProcessMessage(ByRef Message As Message)
	Public:
		#ifndef ReadProperty_Off
			'Loads hotkey configuration from persistence stream
			Declare Function ReadProperty(PropertyName As String) As Any Ptr
		#endif
		#ifndef WriteProperty_Off
			'Saves hotkey configuration to persistence stream
			Declare Function WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
		#endif
		Declare Property TabIndex As Integer
		'Controls focus order in tab sequence
		Declare Property TabIndex(Value As Integer)
		Declare Property TabStop As Boolean
		'Enables/disables focus via Tab key
		Declare Property TabStop(Value As Boolean)
		Declare Property Text ByRef As WString
		'Current key combination (e.g., "Ctrl+Shift+A")
		Declare Property Text(ByRef Value As WString)
		Declare Operator Cast As My.Sys.Forms.Control Ptr
		Declare Constructor
		Declare Destructor
		'Triggered when key combination is modified
		OnChange As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As HotKey)
	End Type
End Namespace

#ifndef __USE_MAKE__
	#include once "HotKey.bas"
#endif
