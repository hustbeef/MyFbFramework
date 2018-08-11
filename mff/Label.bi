﻿'###############################################################################
'#  Label.bi                                                                   #
'#  This file is part of MyFBFramework                                               #
'#  Version 1.0.0                                                              #
'###############################################################################

#Include Once "Graphic.bi"

Namespace My.Sys.Forms
    #DEFINE QLabel(__Ptr__) *Cast(Label Ptr,__Ptr__)

    Enum LabelStyle
        ssText, ssBitmap, ssIcon, ssCursor, ssEmf, ssOwnerDraw
    End Enum

    Enum LabelBorder
        sbNone, sbSimple, sbSunken
    End Enum

    Enum Alignment
        taLeft, taCenter, taRight
    End Enum

    Type Label Extends Control
        Private:
            FBorder           As Integer
            FStyle            As Integer
            FAlignment        As Integer
            FRealSizeImage    As Boolean
            FCenterImage      As Boolean
            AStyle(6)         As Integer
            ABorder(3)        As Integer
            AAlignment(3)     As Integer
            ARealSizeImage(2) As Integer
            ACenterImage(2)   As Integer
            Declare Static Sub WndProc(BYREF Message As Message)
            Declare Sub ProcessMessage(BYREF Message As Message)
            Declare Static Sub GraphicChange(BYREF Sender As My.Sys.Drawing.GraphicType, Image As Any Ptr, ImageType As Integer)
            Declare Static Sub HandleIsAllocated(BYREF Sender As Control)
        Public:
            Graphic            As My.Sys.Drawing.GraphicType
            Declare Function ReadProperty(PropertyName As String) As Any Ptr
            Declare Function WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
            Declare Property Caption ByRef As WString
            Declare Property Caption(ByRef Value As WString)
            Declare Property Border As Integer
            Declare Property Border(Value As Integer)
            Declare Property Style As Integer
            Declare Property Style(Value As Integer)
            Declare Property RealSizeImage As Boolean
            Declare Property RealSizeImage(Value As Boolean)
            Declare Property CenterImage As Boolean
            Declare Property CenterImage(Value As Boolean)
            Declare Property Alignment As Integer
            Declare Property Alignment(Value As Integer)
            Declare Operator Cast As Control Ptr
            Declare Constructor
            Declare Destructor
            OnClick    As Sub(BYREF Sender As Label)
            OnDblClick As Sub(BYREF Sender As Label)
            OnDraw     As Sub(BYREF Sender As Label,BYREF R As Rect,DC As HDC = 0)
    End Type

    Function Label.ReadProperty(PropertyName As String) As Any Ptr
        Select Case LCase(PropertyName)
        Case "caption": Return Cast(Any Ptr, This.FText)
        Case Else: Return Base.ReadProperty(PropertyName)
        End Select
        Return 0
    End Function
    
    Function Label.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
        Select Case LCase(PropertyName)
        Case "caption": If Value <> 0 Then This.Caption = *Cast(WString Ptr, Value)
        Case Else: Return Base.WriteProperty(PropertyName, Value)
        End Select
        Return True
    End Function
    
    Property Label.Caption ByRef As WString
        Return Text
    End Property

    Property Label.Caption(ByRef Value As WString)
        Text = Value
    End Property

    Property Label.Border As Integer
        Return FBorder
    End Property

    Property Label.Border(Value As Integer)
        If Value <> FBorder Then
            FBorder = Value
            If Style <> ssText Then
                Base.Style = WS_CHILD OR SS_NOTIFY OR ABorder(Abs_(FBorder)) OR AStyle(Abs_(FStyle)) OR ARealSizeImage(Abs_(FRealSizeImage)) OR ACenterImage(Abs_(FCenterImage)) 
            Else
                Base.Style = WS_CHILD OR SS_NOTIFY OR ABorder(Abs_(FBorder)) OR AStyle(Abs_(FStyle)) OR AAlignment(Abs_(FAlignment))
            End If
            RecreateWnd
        End If
    End Property

    Property Label.Style As Integer
        Return FStyle 
    End Property

    Property Label.Style(Value As Integer)
        If Value <> FStyle Then
            FStyle = Value
            If FStyle <> ssText Then
                Base.Style = WS_CHILD OR SS_NOTIFY OR ABorder(Abs_(FBorder)) OR AStyle(Abs_(FStyle)) OR ARealSizeImage(Abs_(FRealSizeImage)) OR ACenterImage(Abs_(FCenterImage)) 
            Else
                Base.Style = WS_CHILD OR SS_NOTIFY OR ABorder(Abs_(FBorder)) OR AStyle(Abs_(FStyle)) OR AAlignment(Abs_(FAlignment))
            End If
            RecreateWnd
        End If
    End Property

    Property Label.RealSizeImage As Boolean
        Return FRealSizeImage
    End Property

    Property Label.RealSizeImage(Value As Boolean)
        If Value <> FRealSizeImage Then
            FRealSizeImage = Value
            If Style <> ssText Then
                Base.Style = WS_CHILD OR SS_NOTIFY OR ABorder(Abs_(FBorder)) OR AStyle(Abs_(FStyle)) OR ARealSizeImage(Abs_(FRealSizeImage)) OR ACenterImage(Abs_(FCenterImage)) 
            Else
                Base.Style = WS_CHILD OR SS_NOTIFY OR ABorder(Abs_(FBorder)) OR AStyle(Abs_(FStyle)) OR AAlignment(Abs_(FAlignment))
            End If
            RecreateWnd
        End If
    End Property

    Property Label.CenterImage As Boolean
        Return FCenterImage
    End Property

    Property Label.CenterImage(Value As Boolean)
        If Value <> FCenterImage Then
            FCenterImage = Value
            If Style <> ssText Then
                Base.Style = WS_CHILD OR SS_NOTIFY OR ABorder(Abs_(FBorder)) OR AStyle(Abs_(FStyle)) OR ARealSizeImage(Abs_(FRealSizeImage)) OR ACenterImage(Abs_(FCenterImage)) 
            Else
                Base.Style = WS_CHILD OR SS_NOTIFY OR ABorder(Abs_(FBorder)) OR AStyle(Abs_(FStyle)) OR AAlignment(Abs_(FAlignment))
            End If
            RecreateWnd
        End If
    End Property

    Property Label.Alignment As Integer
        Return FAlignment
    End Property

    Property Label.Alignment(Value As Integer)
        If Value <> FAlignment Then
           FAlignment = Value
           If Style <> ssText Then
                Base.Style = WS_CHILD OR SS_NOTIFY OR ABorder(Abs_(FBorder)) OR AStyle(Abs_(FStyle)) OR ARealSizeImage(Abs_(FRealSizeImage)) OR ACenterImage(Abs_(FCenterImage)) 
            Else
                Base.Style = WS_CHILD OR SS_NOTIFY OR ABorder(Abs_(FBorder)) OR AStyle(Abs_(FStyle)) OR AAlignment(Abs_(FAlignment))
            End If
           RecreateWnd
        End If
    End Property

    Sub Label.GraphicChange(BYREF Sender As My.Sys.Drawing.GraphicType, Image As Any Ptr, ImageType As Integer)
        With Sender
            If .Ctrl->Child Then
                Select Case ImageType
                Case IMAGE_BITMAP
                    QLabel(.Ctrl->Child).Style = ssBitmap
                    QLabel(.Ctrl->Child).Perform(BM_SETIMAGE,ImageType,CInt(Sender.Bitmap.Handle))
                Case IMAGE_ICON
                    QLabel(.Ctrl->Child).Style = ssIcon
                    QLabel(.Ctrl->Child).Perform(BM_SETIMAGE,ImageType,CInt(Sender.Icon.Handle))
                Case IMAGE_CURSOR
                    QLabel(.Ctrl->Child).Style = ssCursor
                    QLabel(.Ctrl->Child).Perform(BM_SETIMAGE,ImageType,CInt(Sender.Icon.Handle))
                Case IMAGE_ENHMETAFILE
                    QLabel(.Ctrl->Child).Style = ssEmf
                    QLabel(.Ctrl->Child).Perform(BM_SETIMAGE,ImageType,CInt(0))
                End Select
            End If
        End With
    End Sub

    Sub Label.HandleIsAllocated(BYREF Sender As Control)
        If Sender.Child Then
            With QLabel(Sender.Child)
                 .Perform(STM_SETIMAGE,.Graphic.ImageType,CInt(.Graphic.Image))
            End With
        End If
    End Sub

    Sub Label.WndProc(BYREF Message As Message)
    End Sub

    Sub Label.ProcessMessage(BYREF Message As Message)
        Select Case Message.Msg
        Case CM_CTLCOLOR
            Static As HDC Dc
            Dc = Cast(HDC,Message.wParam)
            SetBKMode Dc, TRANSPARENT
            SetTextColor Dc,Font.Color
            SetBKColor Dc, This.Color
            SetBKMode Dc, OPAQUE    
        Case CM_COMMAND
            If Message.wParamHi = STN_CLICKED Then
                If OnClick Then OnClick(This)
            End If
            If Message.wParamHi = STN_DBLCLK Then
                If OnDblClick Then OnDblClick(This)
            End If
        Case CM_DRAWITEM
            Dim As DRAWITEMSTRUCT Ptr diStruct
            Dim As Rect R
            Dim As HDC Dc
            diStruct = Cast(DRAWITEMSTRUCT Ptr,Message.lParam)
            R = Cast(Rect,diStruct->rcItem)
            Dc = diStruct->hDC
            If OnDraw Then 
                OnDraw(This,R,Dc)
            Else
            End If    
        End Select
        Base.ProcessMessage(Message)
    End Sub

    Operator Label.Cast As Control Ptr 
        Return Cast(Control Ptr, @This)
    End Operator

    Constructor Label
        AStyle(0)        = 0
        AStyle(1)        = SS_BITMAP
        AStyle(2)        = SS_ICON 
        AStyle(3)        = SS_ICON
        AStyle(4)        = SS_ENHMETAFILE    
        AStyle(5)        = SS_OWNERDRAW
        AAlignment(0)    = SS_LEFT
        AAlignment(1)    = SS_CENTER
        AAlignment(2)    = SS_RIGHT
        ABorder(0)       = 0
        ABorder(1)       = SS_SIMPLE
        ABorder(2)       = SS_SUNKEN 
        ACenterImage(0)  = SS_RIGHTJUST
        ACenterImage(1)  = SS_CENTERIMAGE
        ARealSizeImage(0)= 0
        ARealSizeImage(1)= SS_REALSIZEIMAGE
        Graphic.Ctrl = This
        Graphic.OnChange = @GraphicChange
        FRealSizeImage   = 1
        With This
            .RegisterClass "Label", "Static"
            .Child       = @This
            .ChildProc   = @WndProc
            .ClassName   = "Label"
            .ClassAncestor   = "Static"
            Base.ExStyle     = 0
            If FStyle <> ssText Then
               Base.Style = WS_CHILD OR SS_NOTIFY OR ABorder(Abs_(FBorder)) OR AStyle(Abs_(FStyle)) OR ARealSizeImage(Abs_(FRealSizeImage)) OR ACenterImage(Abs_(FCenterImage)) 
            Else
               Base.Style = WS_CHILD OR SS_NOTIFY OR ABorder(Abs_(FBorder)) OR AStyle(Abs_(FStyle)) OR AAlignment(Abs_(FAlignment))
            End If
            .Color       = GetSysColor(COLOR_BTNFACE)
            .Width       = 90
            .Height      = 17
            .OnHandleIsAllocated = @HandleIsAllocated
        End With  
    End Constructor

    Destructor Label
    End Destructor
End Namespace