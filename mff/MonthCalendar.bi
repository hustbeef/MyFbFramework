﻿'################################################################################
'#  MonthCalendar.bi                                                                  #
'#  This file is part of MyFBFramework                                            #
'#  Version 1.0.0                                                                  #
'################################################################################

#Include Once "Control.bi"

Namespace My.Sys.Forms
    #DEFINE QMonthCalendar(__Ptr__) *Cast(MonthCalendar Ptr, __Ptr__)
    
    Type MonthCalendar Extends Control
        Private:
            Declare Static Sub WndProc(ByRef Message As Message)
            Declare Sub ProcessMessage(ByRef Message As Message)
            Declare Static Sub HandleIsAllocated(ByRef Sender As My.Sys.Forms.Control)
        Public:
            Declare Operator Cast As My.Sys.Forms.Control Ptr
            Declare Constructor
            Declare Destructor
    End Type
    
    Sub MonthCalendar.HandleIsAllocated(ByRef Sender As My.Sys.Forms.Control)
        If Sender.Child Then
            With QMonthCalendar(Sender.Child)
                 
            End With
        End If
    End Sub

    Sub MonthCalendar.WndProc(ByRef Message As Message)
    End Sub

    Sub MonthCalendar.ProcessMessage(ByRef Message As Message)
    End Sub

    Operator MonthCalendar.Cast As My.Sys.Forms.Control Ptr
         Return Cast(My.Sys.Forms.Control Ptr, @This)
    End Operator

    Constructor MonthCalendar
        With This
            .RegisterClass "MonthCalendar","SysMonthCal32"
            .ClassName = "MonthCalendar"
            .ClassAncestor = "SysMonthCal32"
            .Style        = WS_CHILD
            .ExStyle      = 0
            .Width        = 175
            .Height       = 21
            .Child        = @This
            .ChildProc    = @WndProc
            .OnHandleIsAllocated = @HandleIsAllocated
        End With
    End Constructor

    Destructor MonthCalendar
        UnregisterClass "MonthCalendar",GetModuleHandle(NULL)
    End Destructor
End Namespace