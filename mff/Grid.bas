﻿'################################################################################
'#  Grid.bas                                                                    #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Xusinboy Bekchanov,  Liu XiaLin                                    #
'################################################################################

#include once "Grid.bi"
#ifdef __USE_WINAPI__
	#include once "win\tmschema.bi"
#endif

Namespace My.Sys.Forms
	Private Function GridRow.Index As Integer
		If Parent Then
			Dim As Integer tIndex = Cast(Grid Ptr, Parent)->Rows.IndexOf(@This)
			If tIndex = -1 Then Print "Out of bound of Rows " & Cast(Grid Ptr, Parent)->Rows.Count
			Return tIndex
		Else
			Return -1
		End If
	End Function
	
	Private Sub GridCell.SelectItem
		With *Cast(Grid Ptr, Parent)
			.SelectedColumn = Column
			.SelectedRow = Row
		End With
	End Sub
	
	Private Sub GridRow.SelectItem
		#ifdef __USE_GTK__
			If Parent Then
				If gtk_tree_view_get_selection(GTK_TREE_VIEW(Parent->Handle)) Then
					gtk_tree_selection_select_iter(gtk_tree_view_get_selection(GTK_TREE_VIEW(Parent->Handle)), @TreeIter)
				End If
			End If
		#elseif defined(__USE_WINAPI__)
			If Parent AndAlso Parent->Handle Then
				Dim lvi As LVITEM
				lvi.iItem = Index
				lvi.iSubItem   = 0
				lvi.state    = LVIS_SELECTED Or LVIS_FOCUSED
				lvi.stateMask = LVIF_STATE
				ListView_SetItem(Parent->Handle, @lvi)
			End If
		#endif
	End Sub
	
	#ifndef GridRow_Item_Off
		Private Function GridRow.Item(ColumnIndex As Integer) As GridCell Ptr
			Dim ic As Integer = FCells.Count
			Dim cc As Integer = Cast(Grid Ptr, Parent)->Columns.Count
			If ic < cc Then
				For i As Integer = ic To cc -1
					Dim As GridCell Ptr Cell : Cell = _New(GridCell)
					Cell->Column = Cast(Grid Ptr, Parent)->Columns.Column(i)
					Cell->Row = Cast(Grid Ptr, Parent)->Rows.Item(Index)
					Cell->Parent = Parent
					FCells.Add "", Cell
				Next
			End If
			If ColumnIndex < FCells.Count AndAlso ColumnIndex >= 0 Then
				Dim As GridCell Ptr Cell = FCells.Object(ColumnIndex)
				If Cell = 0 Then
					Cell = _New(GridCell)
					FCells.Object(ColumnIndex) = Cell
					Cell->Column = Cast(Grid Ptr, Parent)->Columns.Column(ColumnIndex)
					Cell->Row = Cast(Grid Ptr, Parent)->Rows.Item(Index)
					Cell->Parent = Parent
				End If
				Return Cell
			Else
				Return 0
			End If
		End Function
	#endif
	
	Private Property GridCell.Text ByRef As WString
		If Row > 0 Then Return Row->Text(Column->Index) Else Return ""
	End Property
	
	Private Property GridCell.Text(ByRef Value As WString)
		If Row > 0 Then Row->Text(Column->Index) = Value
	End Property
	
	Private Property GridCell.Editable As Boolean
		Return FEditable
	End Property
	
	Private Property GridCell.Editable(Value As Boolean)
		FEditable = Value
	End Property
	
	Private Property GridCell.BackColor As Integer
		Return FBackColor
	End Property
	
	Private Property GridCell.BackColor(Value As Integer)
		FBackColor = Value
	End Property
	
	Private Property GridCell.ForeColor As Integer
		Return FForeColor
	End Property
	
	Private Property GridCell.ForeColor(Value As Integer)
		FForeColor = Value
	End Property
	
	Private Sub GridRow.ColumnEvents(ColumnIndex As Integer, ColumnDelete As Boolean = False)
		If ColumnDelete AndAlso FCells.Count > 0 AndAlso FCells.Count > ColumnIndex AndAlso ColumnIndex >= 0 Then
			FCells.Remove ColumnIndex
		Else
			Dim As GridCell Ptr Cell : Cell = _New(GridCell)
			Cell->Column = Cast(Grid Ptr, Parent)->Columns.Column(ColumnIndex)
			Cell->Row = @This
			Cell->Parent = Parent
			FCells.Insert(ColumnIndex, "", Cell)
		End If
	End Sub
	
	Private Property GridRow.Text(ColumnIndex As Integer) ByRef As WString
		If FCells.Count > ColumnIndex AndAlso ColumnIndex >= 0 Then
			Return FCells.Item(ColumnIndex)
		Else
			Return WStr("")
		End If
	End Property
	
	#ifdef __USE_GTK__
		Private Function GridGetModel(widget As GtkWidget Ptr) As GtkTreeModel Ptr
			If GTK_IS_WIDGET(widget) Then
				Return gtk_tree_view_get_model(GTK_TREE_VIEW(widget))
			End If
		End Function
	#endif
	
	Private Property GridRow.Text(ColumnIndex As Integer, ByRef Value As WString)
		WLet(FText, Value)
		If Parent <= 0 Then Return
		Dim ic As Integer = FCells.Count
		Dim cc As Integer = Cast(Grid Ptr, Parent)->Columns.Count
		If ic < cc Then
			For i As Integer = ic To cc - 1
				Dim As GridCell Ptr Cell : Cell = _New(GridCell)
				Cell->Column = Cast(Grid Ptr, Parent)->Columns.Column(i)
				Cell->Row = @This
				Cell->Parent = Parent
				FCells.Add "", Cell
			Next
		End If
		If ColumnIndex < FCells.Count AndAlso ColumnIndex >= 0 Then FCells.Item(ColumnIndex) = Value
		#ifdef __USE_GTK__
			If Parent AndAlso Parent->Handle AndAlso GridGetModel(Parent->Handle) Then
				gtk_list_store_set(GTK_LIST_STORE(GridGetModel(Parent->Handle)), @TreeIter, ColumnIndex + 3, ToUtf8(Value), -1)
			End If
		#endif
	End Property
	
	Private Property GridRow.Editable As Boolean
		Return FEditable
	End Property
	
	Private Property GridRow.Editable(Value As Boolean)
		FEditable = Value
	End Property
	
	Private Property GridRow.BackColor As Integer
		Return FBackColor
	End Property
	
	Private Property GridRow.BackColor(Value As Integer)
		FBackColor = Value
	End Property
	
	Private Property GridRow.ForeColor As Integer
		Return FForeColor
	End Property
	
	Private Property GridRow.ForeColor(Value As Integer)
		FForeColor = Value
	End Property
	
	Private Property GridRow.State As Integer
		Return FState
	End Property
	
		Private Property GridRow.State(Value As Integer)
			FState = Value
		End Property
	
	Private Property GridRow.Hint ByRef As WString
		Return WGet(FHint)
	End Property
	
	Private Property GridRow.Hint(ByRef Value As WString)
		WLet(FHint, Value)
	End Property
	
	
	Private Property GridRow.ImageIndex As Integer
		Return FImageIndex
	End Property
	
	#ifndef GridRow_ImageIndex_Set_Off
		Private Property GridRow.ImageIndex(Value As Integer)
			If Value <> FImageIndex Then
				FImageIndex = Value
				#ifdef __USE_WINAPI__
					If Parent AndAlso Parent->Handle Then
						lvi.mask = LVIF_IMAGE
						lvi.iItem = Index
						lvi.iSubItem   = 0
						lvi.iImage     = Value
						ListView_SetItem(Parent->Handle, @lvi)
					End If
				#endif
			End If
		End Property
	#endif
	
	Private Property GridRow.Indent As Integer
		#ifdef __USE_WINAPI__
			If Parent AndAlso Parent->Handle Then
				lvi.mask = LVIF_INDENT
				lvi.iItem = Index
				lvi.iSubItem   = 0
				ListView_GetItem(Parent->Handle, @lvi)
				FIndent = lvi.iIndent
			End If
		#endif
		Return FIndent
	End Property
	
	#ifndef GridRow_Indent_Set_Off
		Private Property GridRow.Indent(Value As Integer)
			FIndent = Value
			#ifdef __USE_WINAPI__
				If Parent AndAlso Parent->Handle Then
					lvi.mask = LVIF_INDENT
					lvi.iItem = Index
					lvi.iSubItem   = 0
					lvi.iIndent    = Value
					ListView_SetItem(Parent->Handle, @lvi)
				End If
			#endif
		End Property
	#endif
	
	Private Property GridRow.SelectedImageIndex As Integer
		Return FImageIndex
	End Property
	
	Private Property GridRow.SelectedImageIndex(Value As Integer)
		If Value <> FSelectedImageIndex Then
			FSelectedImageIndex = Value
			If Parent Then
				With QControl(Parent)
					'.Perform(TB_CHANGEBITMAP, FCommandID, MAKELONG(FImageIndex, 0))
				End With
			End If
		End If
	End Property
	
	Private Property GridRow.ImageKey ByRef As WString
		Return WGet(FImageKey)
	End Property
	
	#ifndef GridRow_ImageKey_Set_Off
		Private Property GridRow.ImageKey(ByRef Value As WString)
			If FImageKey = 0 OrElse Value <> *FImageKey Then
				WLet(FImageKey, Value)
				#ifdef __USE_GTK__
					If Parent AndAlso Parent->Handle Then
						Dim As GError Ptr gerr
						If Value <> "" Then
							gtk_list_store_set(GTK_LIST_STORE(GridGetModel(Parent->Handle)), @TreeIter, 1, gtk_icon_theme_load_icon(gtk_icon_theme_get_default(), ToUtf8(Value), 16, GTK_ICON_LOOKUP_USE_BUILTIN, @gerr), -1)
							gtk_list_store_set(GTK_LIST_STORE(GridGetModel(Parent->Handle)), @TreeIter, 2, ToUtf8(Value), -1)
						End If
					End If
				#elseif defined(__USE_WINAPI__)
					If Parent AndAlso Parent->Handle AndAlso Cast(Grid Ptr, Parent)->Images Then
						FImageIndex = Cast(Grid Ptr, Parent)->Images->IndexOf(Value)
						lvi.mask = LVIF_IMAGE
						lvi.iItem = Index
						lvi.iSubItem   = 0
						lvi.iImage     = FImageIndex
						ListView_SetItem(Parent->Handle, @lvi)
					End If
				#endif
			End If
		End Property
	#endif
	
	Private Property GridRow.SelectedImageKey ByRef As WString
		If FImageKey > 0 Then Return *FImageKey Else Return ""
	End Property
	
	Private Property GridRow.SelectedImageKey(ByRef Value As WString)
		If FSelectedImageKey = 0 OrElse Value <> *FSelectedImageKey Then
			WLet(FSelectedImageKey, Value)
			If Parent Then
				With QControl(Parent)
					'.Perform(TB_CHANGEBITMAP, FCommandID, MAKELONG(FImageIndex, 0))
				End With
			End If
		End If
	End Property
	
	Private Property GridRow.Visible As Boolean
		Return FVisible
	End Property
	
	Private Property GridRow.Visible(Value As Boolean)
		If Value <> FVisible Then
			FVisible = Value
			If Parent Then
				With QControl(Parent)
					'.Perform(TB_HIDEBUTTON, FCommandID, MAKELONG(Not FVisible, 0))
				End With
			End If
		End If
	End Property
	
	Private Operator GridRow.[](ColumnIndex As Integer) ByRef As GridCell
		Return *Item(ColumnIndex)
	End Operator
	
	Private Operator GridRow.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Constructor GridRow
		FVisible            = 1
		Text(0)             = ""
		Hint                = ""
		FImageIndex         = -1
		FSelectedImageIndex = -1
		FSmallImageIndex    = -1
	End Constructor
	
	Private Destructor GridRow
		For i As Integer = 0 To FCells.Count - 1
			If FCells.Object(i) <> 0 Then _Delete(Cast(GridCell Ptr, FCells.Object(i)))
		Next
		FCells.Clear
		If FHint Then _Deallocate( FHint)
		If FText Then _Deallocate( FText)
	End Destructor
	
	Private Sub GridColumn.SelectItem
		#ifdef __USE_WINAPI__
			If Parent AndAlso Parent->Handle Then ListView_SetSelectedColumn(Parent->Handle, Index)
		#endif
	End Sub
	
	Private Property GridColumn.Text ByRef As WString
		If FText > 0 Then Return *FText Else Return ""
	End Property
	
	Private Property GridColumn.Text(ByRef Value As WString)
		WLet(FText, Value)
		#ifdef __USE_WINAPI__
			If Parent AndAlso Parent->Handle Then
				Dim lvc As LVCOLUMN
				lvc.mask = TVIF_TEXT
				lvc.iSubItem = Index
				lvc.pszText = FText
				lvc.cchTextMax = Len(*FText)
				ListView_SetColumn(Parent->Handle, Index, @lvc)
			End If
		#endif
	End Property
	
	Private Property GridColumn.Width As Integer
		#ifdef __USE_GTK__
			If This.Column Then FWidth = gtk_tree_view_column_get_width(This.Column)
		#elseif defined(__USE_WINAPI__)
			Dim lvc As LVCOLUMN
			lvc.mask = LVCF_WIDTH Or LVCF_SUBITEM
			lvc.iSubItem = Index
			If Parent AndAlso Parent->Handle AndAlso ListView_GetColumn(Parent->Handle, Index, @lvc) Then
				FWidth = UnScaleX(lvc.cx)
			End If
		#endif
		Return FWidth
	End Property
	
	#ifndef GridColumn_Width_Set_Off
		Private Property GridColumn.Width(Value As Integer)
			FWidth = Value
			Update
		End Property
	#endif
	
	#ifndef GridColumn_Update_Off
		Private Sub GridColumn.Update()
			#ifdef __USE_GTK__
				#ifdef __USE_GTK3__
					If This.Column Then gtk_tree_view_column_set_fixed_width(This.Column, Max(-1, FWidth))
				#else
					If This.Column Then gtk_tree_view_column_set_fixed_width(This.Column, Max(1, FWidth))
				#endif
			#elseif defined(__USE_WINAPI__)
				If Parent AndAlso Parent->Handle Then
					Dim lvc As LVCOLUMN
					lvc.mask = LVCF_WIDTH Or LVCF_SUBITEM
					lvc.iSubItem = Index
					lvc.cx = ScaleX(FWidth)
					ListView_SetColumn(Parent->Handle, Index, @lvc)
				End If
			#endif
		End Sub
	#endif
	
	Private Property GridColumn.Format As ColumnFormat
		Return FFormat
	End Property
	
	#ifndef GridColumn_Format_Set_Off
		Private Property GridColumn.Format(Value As ColumnFormat)
			FFormat = Value
			#ifdef __USE_WINAPI__
				If Parent AndAlso Parent->Handle Then
					Dim lvc As LVCOLUMN
					lvc.mask = LVCF_FMT Or LVCF_SUBITEM
					lvc.iSubItem = Index
					lvc.fmt = Value
					ListView_SetColumn(Parent->Handle, Index, @lvc)
				End If
			#endif
		End Property
	#endif
	
	Private Property GridColumn.Editable As Boolean
		Return FEditable
	End Property
	
	Private Property GridColumn.Editable(Value As Boolean)
		FEditable = Value
	End Property
	
	Private Property GridColumn.BackColor As Integer
		Return FBackColor
	End Property
	
	Private Property GridColumn.BackColor(Value As Integer)
		FBackColor = Value
	End Property
	
	Private Property GridColumn.ForeColor As Integer
		Return FForeColor
	End Property
	
	Private Property GridColumn.ForeColor(Value As Integer)
		FForeColor = Value
	End Property
	
	Private Property GridColumn.Hint ByRef As WString
		Return WGet(FHint)
	End Property
	
	Private Property GridColumn.Hint(ByRef Value As WString)
		WLet(FHint, Value)
	End Property
	
	Private Property GridColumn.ImageIndex As Integer
		Return FImageIndex
	End Property
	
	#ifndef GridColumn_ImageIndex_Set_Off
		Private Property GridColumn.ImageIndex(Value As Integer)
			If Value <> FImageIndex Then
				FImageIndex = Value
				If Parent Then
					With QControl(Parent)
						'.Perform(TB_CHANGEBITMAP, FCommandID, MakeLong(FImageIndex, 0))
					End With
				End If
			End If
		End Property
	#endif
	
	Private Property GridColumn.Visible As Boolean
		Return FVisible
	End Property
	
	Private Property GridColumn.Visible(Value As Boolean)
		If Value <> FVisible Then
			FVisible = Value
			If Parent Then
				With QControl(Parent)
					'.Perform(TB_HIDEBUTTON, FCommandID, MakeLong(NOT FVisible, 0))
				End With
			End If
		End If
	End Property
	
	Private Operator GridColumn.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Constructor GridColumn
		FVisible     = 1
		Text         = ""
		Hint         = ""
		FEditable    = False
		#ifdef __USE_WINAPI__
			FBackColor   = IIf(g_darkModeEnabled, darkBkColor, GetSysColor(COLOR_WINDOW))
			FForeColor   = IIf(g_darkModeEnabled, darkTextColor, GetSysColor(COLOR_WINDOWTEXT))
		#endif
		FImageIndex = -1
	End Constructor
	
	Private Destructor GridColumn
		If FHint Then _Deallocate( FHint)
		If FText Then _Deallocate( FText)
	End Destructor
	
	Private Property GridRows.Count As Integer
		Return FItems.Count
	End Property
	
	Private Property GridRows.Count(Value As Integer)
		If Parent Then
			With *Cast(Grid Ptr, Parent)
				If Value >= .Rows.Count Then
					For i As Integer = .Rows.Count To Value - 1
						.Rows.Add
					Next
				Else
					For i As Integer = .Rows.Count - 1 To Value Step -1
						.Rows.Remove i
					Next
				End If
			End With
			If Parent->Handle Then
				#ifdef __USE_WINAPI__
					SendMessage(Parent->Handle, LVM_SETITEMCOUNT, FItems.Count, LVSICF_NOINVALIDATEALL)
				#endif
			End If
		End If
	End Property
	
	Private Property GridRows.Item(Index As Integer) As GridRow Ptr
		If Index >= 0 AndAlso Index < FItems.Count Then
			Return FItems.Items[Index]
		End If
		Return 0
	End Property
	
	Private Property GridRows.Item(Index As Integer, Value As GridRow Ptr)
		If Index >= 0 AndAlso Index < FItems.Count Then
			FItems.Items[Index] = Value
		End If
	End Property
	
	#ifdef __USE_GTK__
		Private Function GridRows.FindByIterUser_Data(User_Data As Any Ptr) As GridRow Ptr
			For i As Integer = 0 To Count - 1
				If Item(i)->TreeIter.user_data = User_Data Then Return Item(i)
			Next i
			Return 0
		End Function
	#endif
	
	Sub GridRows.Sort(ColumnIndex As Integer = 0, Direction As SortStyle = SortStyle.ssSortAscending, MatchCase As Boolean = False, iLeft As Integer = 0, iRight As Integer = 0)
		If Cast(Grid Ptr, Parent)->OwnerData Then Exit Sub
		Dim bStarted As Boolean
		Cast(Grid Ptr, Parent)->SortIndex = ColumnIndex
		Cast(Grid Ptr, Parent)->SortOrder = Direction
		If iLeft = 0 AndAlso iRight = 0 Then
			#ifdef __USE_WINAPI__
				bStarted = True
				'BUG: ListView_GetHeader() has a "hwnd" macro parameter, but also wants to use the HWND type in the macro body.
				'Dim As HWND Header = ListView_GetHeader(Parent->Handle)
				Dim As HWND Header = Cast(HWND, SendMessageW(Parent->Handle, LVM_GETHEADER, 0, 0))
				Dim As HDITEM hd
				Var newflag = IIf(Direction = SortStyle.ssSortAscending, HDF_SORTUP, HDF_SORTDOWN)
				hd.mask = HDI_FORMAT
				For i As Integer = 0 To Cast(Grid Ptr, Parent)->Columns.Count - 1
					Header_GetItem(Header, ColumnIndex, @hd)
					If i = ColumnIndex Then
						If (hd.fmt And newflag) <> newflag Then
							hd.fmt = hd.fmt And Not (HDF_SORTUP Or HDF_SORTDOWN)
							hd.fmt = hd.fmt Or newflag
							Header_SetItem(Header, ColumnIndex, @hd)
						End If
					Else
						hd.fmt = hd.fmt And Not (HDF_SORTUP Or HDF_SORTDOWN)
						Header_SetItem(Header, i, @hd)
					End If
				Next
			#endif
		End If
		If FItems.Count <= 1 Then Return
		If iRight = 0 Then iRight = FItems.Count - 1
		If iLeft < 0 Then iLeft = 0
		If (iRight <> 0 AndAlso (iLeft >= iRight)) Then Return
		Dim As Integer i = iLeft, j = iRight
		'QuickSort
		Dim As WString Ptr iKey = @(Item(i)->Text(ColumnIndex))
		If Direction = SortStyle.ssSortAscending Then
			If MatchCase Then
				While (i < FItems.Count And j >= 0 And i <= j)
					While (*iKey < Item(j)->Text(ColumnIndex) AndAlso i < j)
						j -= 1
					Wend
					If i <= j Then FItems.Exchange i, j: i += 1
					While (*iKey >= Item(i)->Text(ColumnIndex) AndAlso i < j)
						i += 1
					Wend
					If i <= j Then FItems.Exchange i, j:  j -= 1
				Wend
			Else
				While (i < FItems.Count And j >= 0 And i <= j)
					While (LCase(*iKey) < LCase(Item(j)->Text(ColumnIndex)) AndAlso i < j)
						j -= 1
					Wend
					If i <= j Then FItems.Exchange i, j: i += 1
					While (LCase(*iKey) >= LCase(Item(i)->Text(ColumnIndex)) AndAlso i < j)
						i += 1
					Wend
					If i <= j Then FItems.Exchange i, j: j -= 1
				Wend
			End If
		Else
			If MatchCase Then
				While (i < FItems.Count And j >= 0 And i <= j)
					While (*iKey > Item(j)->Text(ColumnIndex) AndAlso i < j)
						j -= 1
					Wend
					If i <= j Then FItems.Exchange i, j: i += 1
					While (*iKey <= Item(i)->Text(ColumnIndex) AndAlso i < j)
						i += 1
					Wend
					If i <= j Then FItems.Exchange i, j:  j -= 1
				Wend
			Else
				While (i < FItems.Count And j >= 0 And i <= j)
					While (LCase(*iKey) > LCase(Item(j)->Text(ColumnIndex)) AndAlso i < j)
						j -= 1
					Wend
					If i <= j Then FItems.Exchange i, j: i += 1
					While (LCase(*iKey) <= LCase(Item(i)->Text(ColumnIndex)) AndAlso i < j)
						i += 1
					Wend
					If i <= j Then FItems.Exchange i, j: j -= 1
				Wend
			End If
		End If
		If j > iLeft Then This.Sort(ColumnIndex, Direction, MatchCase, iLeft, j)
		If i < iRight Then This.Sort(ColumnIndex, Direction, MatchCase, i, iRight)
		If bStarted Then
			Parent->Repaint
		End If
	End Sub
	
	#ifndef GridRows_Add_Integer_Off
		Private Function GridRows.Add(ByRef FCaption As WString = "", FImageIndex As Integer = -1, State As Integer = 0, Indent As Integer = 0, Index As Integer = -1, RowEditable As Boolean = False, ColorBK As Integer = -1, ColorText As Integer = -1) As GridRow Ptr
			If Parent <= 0 Then Return 0
			Dim As Integer i = Index, n = 1
			PItem = _New(GridRow)
			PItem->Parent = Parent
			If Index = -1  Then
				FItems.Add PItem
				If FCaption = "" Then Return PItem  'For fast add at the beginning while set RowsCount
				i = FItems.Count - 1
			Else
				FItems.Insert i, PItem
			End If
			With *PItem
				.ImageIndex     = FImageIndex
				#ifdef __USE_GTK__
					Dim As GtkWidget Ptr ParentTemp = Parent->Handle
					Parent->Handle = 0
				#endif
				If InStr(FCaption, Chr(9)) > 0 Then
					Dim As Integer ii = 1, tLen = Len(Chr(9)), ls = Len(FCaption), p = 1
					Do While ii <= ls
						If Mid(FCaption, ii, tLen) = Chr(9) Then
							n = n + 1
							.Text(n - 1) = Mid(FCaption, p, ii - p)
							.Item(n - 1)->BackColor = IIf(ColorBK = -1, Cast(Grid Ptr, Parent)->Columns.Column(n - 1)->BackColor, ColorBK)
							.Item(n - 1)->ForeColor = IIf(ColorText = -1, Cast(Grid Ptr, Parent)->Columns.Column(n - 1)->ForeColor, ColorText)
							p = ii + tLen
							ii = p
							Continue Do
						End If
						ii = ii + 1
					Loop
					n = n + 1
					.Text(n - 1) = Mid(FCaption, p, ii - p)
					'.Item(n - 1)->Editable  = IIf(RowEditableMode = -1, Cast(Grid Ptr, Parent)->Columns.Column(n - 1)->Editable, IIf(RowEditableMode = 0, False, True))
					.Item(n - 1)->BackColor = IIf(ColorBK = -1, Cast(Grid Ptr, Parent)->Columns.Column(n - 1)->BackColor, ColorBK)
					.Item(n - 1)->ForeColor = IIf(ColorText = -1, Cast(Grid Ptr, Parent)->Columns.Column(n - 1)->ForeColor, ColorText)
				Else
					.Text(0)    = FCaption
				End If
				#ifdef __USE_GTK__
					Parent->Handle = ParentTemp
				#endif
				' For entir row： if the value is -1 or false then flowing the Column property
				.Editable       = RowEditable
				.BackColor      = ColorBK
				.ForeColor      = ColorText
				.State          = State
				.Indent         = Indent
			End With
			#ifdef __USE_GTK__
				Cast(Grid Ptr, Parent)->Clear
				If Index <> -1 Then 'iSortStyle <> SortStyle.ssNone OrElse
					gtk_list_store_insert(GTK_LIST_STORE(GridGetModel(Parent->Handle)), @PItem->TreeIter, i)
				Else
					gtk_list_store_append(GTK_LIST_STORE(GridGetModel(Parent->Handle)), @PItem->TreeIter)
				End If
				gtk_list_store_set (GTK_LIST_STORE(GridGetModel(Parent->Handle)), @PItem->TreeIter, 3, ToUtf8(PItem->Text(0)), -1)
				If InStr(FCaption, Chr(9)) > 0 Then
					For j As Integer = 1 To n - 1
						gtk_list_store_set (GTK_LIST_STORE(GridGetModel(Parent->Handle)), @PItem->TreeIter, j + 1, ToUtf8(PItem->Text(j)), -1)
					Next j
				End If
			#elseif defined(__USE_WINAPI__)
				SendMessage(Parent->Handle, LVM_SETITEMCOUNT, FItems.Count, LVSICF_NOINVALIDATEALL)
			#elseif defined(__USE_WASM__)
				Dim As UString strRow = ""
				For i As Integer = 0 To Cast(Grid Ptr, Parent)->Columns.Count - 1
					strRow &= "<td>" & ToUtf8(PItem->Text(i)) & !"</td>\r"
				Next
				AddRow(Parent->Handle, strRow)
			#endif
			Return PItem
		End Function
	#endif
	
	Private Function GridRows.Add(ByRef FCaption As WString = "", ByRef FImageKey As WString, State As Integer = 0, Indent As Integer = 0, Index As Integer = -1, RowEditable As Boolean = False, ColorBK As Integer = -1, ColorText As Integer = -1) As GridRow Ptr
		If Parent AndAlso Cast(Grid Ptr, Parent)->Images Then
			PItem = Add(FCaption, Cast(Grid Ptr, Parent)->Images->IndexOf(FImageKey), State, Indent, Index, RowEditable, ColorBK, ColorText)
		Else
			PItem = Add(FCaption, -1, State, Indent, Index, RowEditable, ColorBK, ColorText)
		End If
		If PItem Then PItem->ImageKey = FImageKey
		Return PItem
	End Function
	
	Private Function GridRows.Insert(Index As Integer, ByRef FCaption As WString = "", FImageIndex As Integer = -1, State As Integer = 0, Indent As Integer = 0, InsertBefore As Boolean = True, RowEditable As Boolean = False, ColorBK As Integer = -1, ColorText As Integer = -1, DuplicateIndex As Integer = -1) As GridRow Ptr
		If Not InsertBefore Then Index += 1
		If Index > FItems.Count - 1 Then Return Add(FCaption, FImageIndex, State, Indent, Index, RowEditable, ColorBK, ColorText)
		Dim As GridRow Ptr PItem, tGridRow, tGridRowD
		PItem = _New(GridRow)
		FItems.Insert Index, PItem
		With *PItem
			.Parent         = Parent
			.ImageIndex     = FImageIndex
			#ifdef __USE_GTK__
				Dim As GtkWidget Ptr ParentTemp = Parent->Handle
				Parent->Handle = 0
			#endif
			.Text(0)        = FCaption
			If DuplicateIndex >= 0 Then tGridRowD = Cast(Grid Ptr, Parent)->Rows.Item(DuplicateIndex)
			.Editable = IIf(DuplicateIndex >= 0, tGridRowD->Editable, RowEditable)
			.BackColor = IIf(DuplicateIndex >= 0, tGridRowD->BackColor, ColorBK)
			.ForeColor = IIf(DuplicateIndex >= 0, tGridRowD->ForeColor, ColorText)
			.State          = State
			.Indent         = Indent
			#ifdef __USE_GTK__
				Parent->Handle = ParentTemp
			#endif
		End With
		#ifdef __USE_GTK__
			Cast(Grid Ptr, Parent)->Clear
			If Index <> -1 Then 'iSortStyle <> SortStyle.ssNone OrElse
				gtk_list_store_insert(GTK_LIST_STORE(GridGetModel(Parent->Handle)), @PItem->TreeIter, Index)
			Else
				gtk_list_store_append(GTK_LIST_STORE(GridGetModel(Parent->Handle)), @PItem->TreeIter)
			End If
			gtk_list_store_set (GTK_LIST_STORE(GridGetModel(Parent->Handle)), @PItem->TreeIter, 3, ToUtf8(IIf(FCaption = "", !"\0", FCaption)), -1)
		#elseif defined(__USE_WINAPI__)
			If Parent->Handle Then
				SendMessage(Parent->Handle, LVM_SETITEMCOUNT, Cast(Grid Ptr, Parent)->Rows.Count, LVSICF_NOINVALIDATEALL)
				Cast(Grid Ptr, Parent)->Repaint
			End If
		#endif
		If Parent > 0 AndAlso Index > 0 Then
			Dim As GridCell Ptr tGridCell, tGridCellD
			For j As Integer = 0 To Cast(Grid Ptr, Parent)->Columns.Count - 1
				tGridRow = Cast(Grid Ptr, Parent)->Rows.Item(Index)
				tGridCell = tGridRow->Item(j)
				If DuplicateIndex >= 0 Then tGridCellD = tGridRow->Item(DuplicateIndex)
				tGridCell->Editable = IIf(DuplicateIndex >= 0, tGridCellD->Editable, RowEditable)
				tGridCell->BackColor = IIf(DuplicateIndex >= 0, tGridCellD->BackColor, ColorBK)
				tGridCell->ForeColor = IIf(DuplicateIndex >= 0, tGridCellD->ForeColor, ColorText)
			Next
		End If
		Return PItem
	End Function
	
	Private Sub GridRows.Remove(Index As Integer)
		If FItems.Count < 1 OrElse Index < 0 OrElse Index > FItems.Count - 1 Then Exit Sub
		#ifdef __USE_GTK__
			If Parent AndAlso Parent->Handle Then
				gtk_list_store_remove(GTK_LIST_STORE(GridGetModel(Parent->Handle)), @This.Item(Index)->TreeIter)
			End If
		#elseif defined(__USE_WINAPI__)
			If Parent AndAlso Parent->Handle Then
				ListView_DeleteItem(Parent->Handle, Index)
			End If
			Cast(Grid Ptr, Parent)->Repaint
		#endif
		FItems.Remove Index
	End Sub
	
	Private Function GridRows.IndexOf(ByRef FItem As GridRow Ptr) As Integer
		Return FItems.IndexOf(FItem)
	End Function
	
	Private Sub GridRows.Clear
		#ifdef __USE_GTK__
			If Parent AndAlso GTK_LIST_STORE(GridGetModel(Parent->Handle)) Then gtk_list_store_clear(GTK_LIST_STORE(GridGetModel(Parent->Handle)))
		#elseif defined(__USE_WINAPI__)
			If Parent AndAlso Parent->Handle Then SendMessage Parent->Handle, LVM_DELETEALLITEMS, 0, 0
		#endif
		For i As Integer = Count -1 To 0 Step -1
			_Delete( @QGridRow(FItems.Items[i]))
		Next i
		FItems.Clear
	End Sub
	
	Private Operator GridRows.[](Index As Integer) ByRef As GridRow
		Return *Item(Index)
	End Operator
	
	Private Operator GridRows.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Constructor GridRows
		This.Clear
		
	End Constructor
	
	Private Destructor GridRows
		This.Clear
	End Destructor
	
	Private Property GridColumns.Count As Integer
		Return FColumns.Count
	End Property
	
	Private Property GridColumns.Count(Value As Integer)
	End Property
	
	Private Property GridColumns.Column(Index As Integer) As GridColumn Ptr
		Return FColumns.Items[Index]
	End Property
	
	Private Property GridColumns.Column(Index As Integer, Value As GridColumn Ptr)
		FColumns.Items[Index] = Value
	End Property
	
	#ifdef __USE_GTK__
		Private Sub GridColumns.Cell_Edited(renderer As GtkCellRendererText Ptr, path As gchar Ptr, new_text As gchar Ptr, user_data As Any Ptr)
			Dim As GridColumn Ptr PColumn = user_data
			If PColumn = 0 Then Exit Sub
			Dim As Grid Ptr lv = Cast(Grid Ptr, PColumn->Parent)
			If lv = 0 Then Exit Sub
			If lv->OnCellEdited Then lv->OnCellEdited(*lv->Designer, *lv, Val(*path), PColumn->Index, *new_text)
		End Sub
		
		Private Sub GridColumns.Check(cell As GtkCellRendererToggle Ptr, path As gchar Ptr, user_data As Any Ptr)
			Dim As Grid Ptr lv = user_data
			Dim As GtkListStore Ptr model = GTK_LIST_STORE(GridGetModel(lv->Handle))
			Dim As GtkTreeIter iter
			Dim As gboolean active
			
			active = gtk_cell_renderer_toggle_get_active (cell)
			
			gtk_tree_model_get_iter_from_string (GTK_TREE_MODEL (model), @iter, path)
			
			If (active) Then
				'gtk_cell_renderer_set_alignment(GTK_CELL_RENDERER(cell), 0, 0)
				gtk_list_store_set (GTK_LIST_STORE (model), @iter, 0, False, -1)
			Else
				'gtk_cell_renderer_set_alignment(GTK_CELL_RENDERER(cell), 0.5, 0.5)
				gtk_list_store_set (GTK_LIST_STORE (model), @iter, 0, True, -1)
			End If
		End Sub
	#endif
	
	Private Function GridColumns.Add(ByRef FCaption As WString = "", FImageIndex As Integer = -1, iWidth As Integer = 100, Format As ColumnFormat = cfLeft, ColEditable As Boolean = False, ColBackColor As Integer = -1, ColForeColor As Integer = -1) As GridColumn Ptr
		Dim As GridColumn Ptr PColumn
		Dim As Integer Index
		#ifdef __USE_WINAPI__
			Dim As LVCOLUMN lvc
		#endif
		PColumn = _New(GridColumn)
		FColumns.Add PColumn
		Index = FColumns.Count - 1
		With *PColumn
			.ImageIndex     = FImageIndex
			.Text           = FCaption
			.Index          = Index
			.Width          = iWidth
			.Format         = Format
			.Editable       = ColEditable
			.BackColor      = ColBackColor
			.ForeColor      = ColForeColor
			If Parent > 0 Then
				Dim As GridRow Ptr tGridRow
				Dim As GridCell Ptr tGridCell
				For j As Integer = 0 To Cast(Grid Ptr, Parent)->Rows.Count - 1
					tGridRow = Cast(Grid Ptr, Parent)->Rows.Item(j)
					tGridRow->ColumnEvents(Index)
					tGridRow->State = 0
					tGridCell = tGridRow->Item(Index)
					tGridCell->Editable = ColEditable
					tGridCell->BackColor = ColBackColor
					tGridCell->ForeColor = ColForeColor
				Next
			End If
		End With
		
		#ifdef __USE_GTK__
			If Parent Then
				PColumn->Column = gtk_tree_view_column_new()
				gtk_tree_view_column_set_reorderable(PColumn->Column, Cast(Grid Ptr, Parent)->AllowColumnReorder)
				Dim As GtkCellRenderer Ptr rendertext = gtk_cell_renderer_text_new()
				If ColEditable Then
					Dim As GValue bValue '= G_VALUE_INIT
					g_value_init_(@bValue, G_TYPE_BOOLEAN)
					g_value_set_boolean(@bValue, True)
					g_object_set_property(G_OBJECT(rendertext), "editable", @bValue)
					g_value_unset(@bValue)
					'Dim bTrue As gboolean = True
					'g_object_set(rendertext, "mode", GTK_CELL_RENDERER_MODE_EDITABLE, NULL)
					'g_object_set(gtk_cell_renderer_text(rendertext), "editable-set", true, NULL)
					'g_object_set(rendertext, "editable", bTrue, NULL)
				End If
				If Index = 0 Then
					Dim As GtkCellRenderer Ptr renderpixbuf = gtk_cell_renderer_pixbuf_new()
					gtk_tree_view_column_pack_start(PColumn->Column, renderpixbuf, False)
					gtk_tree_view_column_add_attribute(PColumn->Column, renderpixbuf, ToUtf8("icon_name"), 2)
				End If
				g_signal_connect(G_OBJECT(rendertext), "edited", G_CALLBACK (@Cell_Edited), PColumn)
				gtk_tree_view_column_pack_start(PColumn->Column, rendertext, True)
				gtk_tree_view_column_add_attribute(PColumn->Column, rendertext, ToUtf8("text"), Index + 3)
				gtk_tree_view_column_set_resizable(PColumn->Column, True)
				gtk_tree_view_column_set_title(PColumn->Column, ToUtf8(FCaption))
				If GTK_IS_TREE_VIEW(Parent->Handle) Then
					gtk_tree_view_append_column(GTK_TREE_VIEW(Parent->Handle), PColumn->Column)
				Else
					gtk_tree_view_append_column(GTK_TREE_VIEW(g_object_get_data(G_OBJECT(Parent->Handle), "@@@TreeView")), PColumn->Column)
				End If
				#ifdef __USE_GTK3__
					gtk_tree_view_column_set_fixed_width(PColumn->Column, Max(-1, iWidth))
				#else
					gtk_tree_view_column_set_fixed_width(PColumn->Column, Max(1, iWidth))
				#endif
			End If
		#elseif defined(__USE_WINAPI__)
			lvc.mask      =  LVCF_FMT Or LVCF_WIDTH Or LVCF_TEXT Or LVCF_SUBITEM
			lvc.fmt       =  Format
			lvc.cx		  = ScaleX(IIf(iWidth = -1, 50, iWidth))
			lvc.iImage   = PColumn->ImageIndex
			lvc.iSubItem = PColumn->Index
			lvc.pszText  = @FCaption
			lvc.cchTextMax = Len(FCaption)
		#endif
		If Parent Then
			PColumn->Parent = Parent
			If Parent->Handle Then
				#ifdef __USE_GTK__
					
				#elseif defined(__USE_WINAPI__)
					ListView_InsertColumn(Parent->Handle, PColumn->Index, @lvc)
				#elseif defined(__USE_WASM__)
					AddColumn(Parent->Handle, ToUtf8(FCaption))
				#endif
			End If
		End If
		Return PColumn
	End Function
	
	Private Sub GridColumns.Insert(Index As Integer, ByRef FCaption As WString = "", FImageIndex As Integer = -1, iWidth As Integer = -1, Format As ColumnFormat = cfLeft, InsertBefore As Boolean = True, ColEditable As Boolean = False, ColBackColor As Integer = -1, ColForeColor As Integer = -1, DuplicateIndex As Integer = -1)
		If Not InsertBefore Then
			Index += 1
		ElseIf Index = 0 Then
			Exit Sub
		End If
		If Index > FColumns.Count - 1 Then Add(FCaption, FImageIndex, iWidth, Format, ColEditable, ColBackColor, ColForeColor) : Exit Sub
		Dim As GridColumn Ptr PColumn, tColumn
		#ifdef __USE_WINAPI__
			Dim As LVCOLUMN lvc
			PColumn = _New(GridColumn)
			FColumns.Insert Index, PColumn
			With *PColumn
				.ImageIndex  = FImageIndex
				.Text        = FCaption
				.Index       = Index
				.Width       = iWidth
				.Format      = Format
				If DuplicateIndex >= 0 Then tColumn = FColumns.Items[DuplicateIndex]
				.Editable    = IIf(DuplicateIndex >= 0, tColumn ->Editable, ColEditable)
				.BackColor   = IIf(DuplicateIndex >= 0, tColumn ->BackColor, ColBackColor)
				.ForeColor   = IIf(DuplicateIndex >= 0, tColumn ->ForeColor, ColForeColor)
				If Parent > 0 Then
					Dim As GridRow Ptr tGridRow
					Dim As GridCell Ptr tGridCell, tGridCellD
					For j As Integer = 0 To Cast(Grid Ptr, Parent)->Rows.Count - 1
						tGridRow = Cast(Grid Ptr, Parent)->Rows.Item(j)
						tGridRow->ColumnEvents(Index)
						tGridRow->State = 0
						tGridCell = tGridRow->Item(Index)
						If DuplicateIndex >= 0 Then tGridCellD = tGridRow->Item(DuplicateIndex)
						tGridCell->Editable = IIf(DuplicateIndex >= 0, tGridCellD ->Editable, ColEditable)
						tGridCell->BackColor = IIf(DuplicateIndex >= 0, tGridCellD ->BackColor, ColBackColor)
						tGridCell->ForeColor = IIf(DuplicateIndex >= 0, tGridCellD ->ForeColor, ColForeColor)
					Next
				End If
			End With
			lvc.mask         = LVCF_FMT Or LVCF_WIDTH Or LVCF_TEXT Or LVCF_SUBITEM
			lvc.fmt          = Format
			lvc.cx           = 0
			lvc.iImage       = PColumn->ImageIndex
			lvc.iSubItem     = PColumn->Index
			lvc.pszText      = @FCaption
			lvc.cchTextMax   = Len(FCaption)
			If Parent Then
				PColumn->Parent = Parent
				If Parent->Handle Then
					ListView_InsertColumn(Parent->Handle, Index, @lvc)
					ListView_SetColumnWidth(Parent->Handle, Index, iWidth)
				End If
			End If
			For i As Integer = FColumns.Count - 1 To Index Step -1
				Cast(Grid Ptr, Parent)->Columns.Column(i)->Index = i
			Next
			SendMessage Parent->Handle, LVM_INSERTCOLUMN, Cast(WPARAM, Index), 0
		#endif
	End Sub
	
	Private Sub GridColumns.Remove(Index As Integer)
		FColumns.Remove Index
		#ifdef __USE_WINAPI__
			If Parent AndAlso Parent->Handle Then
				For j As Integer = 0 To Cast(Grid Ptr, Parent)->Rows.Count - 1
					Cast(Grid Ptr, Parent)->Rows.Item(j)->ColumnEvents(Index, True)
				Next
				SendMessage Parent->Handle, LVM_DELETECOLUMN, Cast(WPARAM, Index), 0
			End If
		#endif
	End Sub
	
	Private Function GridColumns.IndexOf(ByRef FColumn As GridColumn Ptr) As Integer
		Return FColumns.IndexOf(FColumn)
	End Function
	
	Private Sub GridColumns.Clear
		For i As Integer = Count -1 To 0 Step -1
			_Delete( @QGridColumn(FColumns.Items[i]))
			FColumns.Remove i
			#ifdef __USE_WINAPI__
				If Parent AndAlso Parent->Handle Then
					SendMessage Parent->Handle, LVM_DELETECOLUMN, Cast(WPARAM, i), 0
				End If
			#endif
		Next i
		FColumns.Clear
	End Sub
	
	Private Operator GridColumns.[](Index As Integer) ByRef As GridColumn
		Return *Column(Index)
	End Operator
	
	Private Operator GridColumns.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Constructor GridColumns
		This.Clear
	End Constructor
	
	Private Destructor GridColumns
		This.Clear
	End Destructor
	
	#ifndef ReadProperty_Off
		Private Function Grid.ReadProperty(PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "allowcolumnreorder": Return @FAllowColumnReorder
			Case "columnheaderhidden": Return @FColumnHeaderHidden
			Case "fullrowselect": Return @FFullRowSelect
			Case "ownerdata": Return @FOwnerData
			Case "colorselected" : Return @FGridColorSelected
			Case "ColorEditBack" : Return @FGridColorEditBack
			Case "coloreditfore" : Return @FGridColorEditFore
			Case "colorline" : Return @FGridColorLine
			Case "hovertime": Return @FHoverTime
			Case "gridlines": Return @FGridLines
			Case "images": Return Images
			Case "stateimages": Return StateImages
			Case "smallimages": Return SmallImages
			Case "singleclickactivate": Return @FSingleClickActivate
			Case "sortindex": Return @FSortIndex
			Case "tabindex": Return @FTabIndex
			Case "hoverselection": Return @FHoverSelection
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function Grid.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
			If Value = 0 Then
				Select Case LCase(PropertyName)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			Else
				Select Case LCase(PropertyName)
				Case "allowcolumnreorder": AllowColumnReorder = QBoolean(Value)
				Case "columnheaderhidden": ColumnHeaderHidden = QBoolean(Value)
				Case "fullrowselect": FullRowSelect = QBoolean(Value)
				Case "ownerdata": OwnerData = QBoolean(Value)
				Case "colorselected" : FGridColorSelected = QInteger(Value)
				Case "coloreditback" : FGridColorEditBack = QInteger(Value)
				Case "coloreditfore" : FGridColorEditFore = QInteger(Value)
				Case "colorline" : FGridColorLine = QInteger(Value)
				Case "hovertime": HoverTime = QInteger(Value)
				Case "gridlines": GridLines = QBoolean(Value)
				Case "images": Images = Cast(ImageList Ptr, Value)
				Case "stateimages": StateImages = Cast(ImageList Ptr, Value)
				Case "smallimages": SmallImages = Cast(ImageList Ptr, Value)
				Case "singleclickactivate": SingleClickActivate = QBoolean(Value)
				Case "sortindex": FSortIndex = QInteger(Value)
				Case "tabindex": TabIndex = QInteger(Value)
				Case "hoverselection": HoverSelection = QBoolean(Value)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			End If
			Return True
		End Function
	#endif
	
	Private Property Grid.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property Grid.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property Grid.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property Grid.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
	Private Sub Grid.Clear()
		#ifdef __USE_GTK__
			If gtk_tree_view_get_model(GTK_TREE_VIEW(widget)) = NULL Then
				With This
					If .ColumnTypes Then _DeleteSquareBrackets( .ColumnTypes)
					.ColumnTypes = _New(GType[Columns.Count + 4])
					.ColumnTypes[0] = G_TYPE_BOOLEAN
					.ColumnTypes[1] = GDK_TYPE_PIXBUF
					.ColumnTypes[2] = G_TYPE_STRING
					For i As Integer = 3 To Columns.Count + 3
						.ColumnTypes[i] = G_TYPE_STRING
					Next i
				End With
				gtk_list_store_set_column_types(ListStore, Columns.Count + 3, ColumnTypes)
				gtk_tree_view_set_model(GTK_TREE_VIEW(widget), GTK_TREE_MODEL(ListStore))
				gtk_tree_view_set_enable_tree_lines(GTK_TREE_VIEW(widget), True)
			End If
		#else
			FCol = 1: FRow = 0
			Rows.Clear
			Columns.Clear
			GridEditText.Visible= False
		#endif
	End Sub
	
	Private Property Grid.ColumnHeaderHidden As Boolean
		Return FColumnHeaderHidden
	End Property
	
	Private Property Grid.ColumnHeaderHidden(Value As Boolean)
		FColumnHeaderHidden = Value
		#ifdef __USE_GTK__
			gtk_tree_view_set_headers_visible(GTK_TREE_VIEW(widget), Not Value)
		#elseif defined(__USE_WINAPI__)
			ChangeStyle LVS_NOCOLUMNHEADER, Value
		#endif
	End Property
	
	Private Function Grid.Cells(RowIndex As Integer, ColumnIndex As Integer) As GridCell Ptr
		Return Rows.Item(RowIndex)->Item(ColumnIndex)
	End Function
	
	#ifndef Grid_ChangeLVExStyle_Off
		Private Sub Grid.ChangeLVExStyle(iStyle As Integer, Value As Boolean)
			#ifdef __USE_WINAPI__
				If FHandle Then FLVExStyle = SendMessage(FHandle, LVM_GETEXTENDEDLISTVIEWSTYLE, 0, 0)
				If Value Then
					If ((FLVExStyle And iStyle) <> iStyle) Then FLVExStyle = FLVExStyle Or iStyle
				ElseIf ((FLVExStyle And iStyle) = iStyle) Then
					FLVExStyle = FLVExStyle And Not iStyle
				End If
				If FHandle Then SendMessage(FHandle, LVM_SETEXTENDEDLISTVIEWSTYLE, 0, ByVal FLVExStyle)
			#endif
		End Sub
	#endif
	
	Private Property Grid.SingleClickActivate As Boolean
		Return FSingleClickActivate
	End Property
	
	Private Property Grid.SingleClickActivate(Value As Boolean)
		If FSingleClickActivate = Value Then Return
		FSingleClickActivate = Value
		#ifdef __USE_GTK__
			#ifdef __USE_GTK3__
				gtk_tree_view_set_activate_on_single_click(GTK_TREE_VIEW(widget), Value)
			#else
				
			#endif
		#elseif defined(__USE_WINAPI__)
			ChangeLVExStyle LVS_EX_ONECLICKACTIVATE, Value
		#endif
	End Property
	
	Private Property Grid.HoverSelection As Boolean
		Return FHoverSelection
	End Property
	
	Private Property Grid.HoverSelection(Value As Boolean)
		If FHoverSelection = Value Then Return
		FHoverSelection = Value
		#ifdef __USE_GTK__
			gtk_tree_view_set_hover_selection(GTK_TREE_VIEW(widget), Value)
		#elseif defined(__USE_WINAPI__)
			ChangeLVExStyle LVS_EX_TRACKSELECT, Value
		#endif
	End Property
	
	Private Property Grid.HoverTime As Integer
		Return FHoverTime
	End Property
	
	Private Property Grid.HoverTime(Value As Integer)
		FHoverTime = Value
		#ifdef __USE_WINAPI__
			If Handle Then Perform(LVM_SETHOVERTIME, 0, Value)
		#endif
	End Property
	
	Private Property Grid.AllowEdit As Boolean
		Return FAllowEdit
	End Property
	
	Private Property Grid.AllowEdit(Value As Boolean)
		FAllowEdit = Value
	End Property
	Private Property Grid.AllowColumnReorder As Boolean
		Return FAllowColumnReorder
	End Property
	
	Private Property Grid.AllowColumnReorder(Value As Boolean)
		If FAllowColumnReorder = Value Then Return
		FAllowColumnReorder = Value
		#ifdef __USE_GTK__
			For i As Integer = 0 To Columns.Count - 1
				gtk_tree_view_column_set_reorderable(Columns.Column(i)->Column, Value)
			Next
		#elseif defined(__USE_WINAPI__)
			ChangeLVExStyle LVS_EX_HEADERDRAGDROP, Value
		#endif
	End Property
	
	Private Property Grid.GridLines As Boolean
		Return FGridLines
	End Property
	
	Private Property Grid.GridLines(Value As Boolean)
		If FGridLines = Value Then Return
		FGridLines = Value
		#ifdef __USE_GTK__
			gtk_tree_view_set_grid_lines(GTK_TREE_VIEW(widget), IIf(Value, GTK_TREE_VIEW_GRID_LINES_BOTH, GTK_TREE_VIEW_GRID_LINES_NONE))
		#elseif defined(__USE_WINAPI__)
			ChangeLVExStyle LVS_EX_GRIDLINES, Value
		#endif
	End Property
	
	Private Property Grid.FullRowSelect As Boolean
		Return FFullRowSelect
	End Property
	
	Private Property Grid.FullRowSelect(Value As Boolean)
		If FFullRowSelect = Value Then Return
		FFullRowSelect = Value
		#ifdef __USE_WINAPI__
			ChangeLVExStyle LVS_EX_FULLROWSELECT, Value
		#endif
	End Property
	
	Private Property Grid.OwnerData As Boolean
		Return FOwnerData
	End Property
	
	Private Property Grid.OwnerData(Value As Boolean)
		FOwnerData = Value
	End Property
	
	Private Property Grid.ColorSelected As Integer
		Return FGridColorSelected
	End Property
	
	Private Property Grid.ColorSelected(Value As Integer)
		FGridColorSelected = Value
	End Property
	
	
	Private Property Grid.ColorEditBack(Value As Integer)
		FGridColorEditBack = Value
	End Property
	
	Private Property Grid.ColorEditBack As Integer
		Return FGridColorEditBack
	End Property
	
	Private Property Grid.ColorEditFore(Value As Integer)
		FGridColorEditFore = Value
	End Property
	
	Private Property Grid.ColorEditFore As Integer
		Return FGridColorEditFore
	End Property
	
	Private Property Grid.ColorLine(Value As Integer)
		FGridColorEditFore = Value
	End Property
	
	Private Property Grid.ColorLine As Integer
		Return FGridColorLine
	End Property
	
	Private Property Grid.SelectedRowIndex As Integer
		#ifdef __USE_GTK__
			Dim As GtkTreeIter iter
			If gtk_tree_selection_get_selected(TreeSelection, NULL, @iter) Then
				Dim As Integer i
				Dim As GtkTreePath Ptr path
				
				path = gtk_tree_model_get_path(GTK_TREE_MODEL(ListStore), @iter)
				i = gtk_tree_path_get_indices(path)[0]
				gtk_tree_path_free(path)
				'				Dim As ListViewItem Ptr lvi = ListItems.FindByIterUser_Data(iter.User_Data)
				'				If lvi <> 0 Then Return lvi->Index
				Return i
			End If
		#elseif defined(__USE_WINAPI__)
			If Handle Then
				Return ListView_GetNextItem(Handle, -1, LVNI_SELECTED)
			End If
		#endif
		Return -1
	End Property
	
	Private Property Grid.SelectedRowIndex(Value As Integer)
		#ifdef __USE_GTK__
			If TreeSelection Then
				If Value = -1 Then
					gtk_tree_selection_unselect_all(TreeSelection)
				ElseIf Value > -1 AndAlso Value < Rows.Count Then
					Dim As GtkTreeIter iter
					gtk_tree_model_get_iter_from_string(GTK_TREE_MODEL(ListStore), @iter, Trim(Str(Value)))
					gtk_tree_selection_select_iter(TreeSelection, @iter)
					gtk_tree_view_scroll_to_cell(GTK_TREE_VIEW(widget), gtk_tree_model_get_path(GTK_TREE_MODEL(ListStore), @iter), NULL, False, 0, 0)
				End If
			End If
		#elseif defined(__USE_WINAPI__)
			If Handle Then
				ListView_SetItemState(Handle, Value, LVIS_FOCUSED Or LVIS_SELECTED, LVNI_SELECTED Or LVNI_FOCUSED)
				ListView_EnsureVisible(Handle, Value, True)
			End If
		#endif
	End Property
	
	Private Property Grid.SelectedRow As GridRow Ptr
		#ifdef __USE_GTK__
			Dim As GtkTreeIter iter
			If gtk_tree_selection_get_selected(TreeSelection, NULL, @iter) Then
				Return Rows.FindByIterUser_Data(iter.user_data)
			End If
		#elseif defined(__USE_WINAPI__)
			If Handle Then
				Dim As Integer item = ListView_GetNextItem(Handle, -1, LVNI_SELECTED)
				If item <> -1 Then Return Rows.Item(item)
			End If
		#endif
		Return 0
	End Property
	
	#ifndef Grid_SelectedRow_Off
		Private Property Grid.SelectedRow(Value As GridRow Ptr)
			Value->SelectItem
		End Property
	#endif
	
	Private Property Grid.SelectedColumn As GridColumn Ptr
		Return Columns.Column(FCol)
	End Property
	
	#ifndef Grid_SelectedColumn_Off
		Private Property Grid.SelectedColumn(Value As GridColumn Ptr)
			FCol = Value->Index
		End Property
	#endif
	
	Private Property Grid.SelectedColumnIndex As Integer
		Return FCol
	End Property
	
	Private Property Grid.SelectedColumnIndex(Value As Integer)
		FCol = Value
	End Property
	
	Private Property Grid.SortIndex As Integer
		Return FSortIndex
	End Property
	
	Private Property Grid.SortIndex(Value As Integer)
		FSortIndex = Value
		'#ifndef __USE_GTK__
		'	Select Case FSortStyle
		'	Case SortStyle.ssNone
		'		ChangeStyle LVS_SORTASCENDING, False
		'		ChangeStyle LVS_SORTDESCENDING, False
		'	Case SortStyle.ssSortAscending
		'		ChangeStyle LVS_SORTDESCENDING, False
		'		ChangeStyle LVS_SORTASCENDING, True
		'	Case SortStyle.ssSortDescending
		'		ChangeStyle LVS_SORTASCENDING, False
		'		ChangeStyle LVS_SORTDESCENDING, True
		'	End Select
		'#endif
	End Property
	
	Private Property Grid.SortOrder As SortStyle
		Return FSortOrder
	End Property
	
	Private Property Grid.SortOrder(Value As SortStyle)
		FSortOrder = Value
		'#ifndef __USE_GTK__
		'	Select Case FSortStyle
		'	Case SortStyle.ssNone
		'		ChangeStyle LVS_SORTASCENDING, False
		'		ChangeStyle LVS_SORTDESCENDING, False
		'	Case SortStyle.ssSortAscending
		'		ChangeStyle LVS_SORTDESCENDING, False
		'		ChangeStyle LVS_SORTASCENDING, True
		'	Case SortStyle.ssSortDescending
		'		ChangeStyle LVS_SORTASCENDING, False
		'		ChangeStyle LVS_SORTDESCENDING, True
		'	End Select
		'#endif
	End Property
	Private Property Grid.ShowHint As Boolean
		Return FShowHint
	End Property
	
	Private Property Grid.ShowHint(Value As Boolean)
		FShowHint = Value
	End Property
	
	#ifdef __USE_WINAPI__
		Private Sub Grid.SetDark(Value As Boolean)
			Base.SetDark Value
			If Value Then
				hHeader = ListView_GetHeader(FHandle)
				SetWindowTheme(hHeader, "DarkMode_ItemsView", nullptr) ' DarkMode
				SetWindowTheme(FHandle, "DarkMode_Explorer", nullptr) ' DarkMode
				AllowDarkModeForWindow(FHandle, g_darkModeEnabled)
				AllowDarkModeForWindow(hHeader, g_darkModeEnabled)
			Else
				hHeader = ListView_GetHeader(FHandle)
				SetWindowTheme(hHeader, NULL, NULL) ' DarkMode
				SetWindowTheme(FHandle, NULL, NULL) ' DarkMode
				AllowDarkModeForWindow(FHandle, g_darkModeEnabled)
				AllowDarkModeForWindow(hHeader, g_darkModeEnabled)
			End If
			'SendMessage FHandle, WM_THEMECHANGED, 0, 0
		End Sub
	#endif
	
	Private Sub Grid.ProcessMessage(ByRef Message As Message)
		#ifdef __USE_GTK__
			Dim As GdkEvent Ptr e = Message.Event
			Select Case Message.Event->type
			Case GDK_MAP
				Clear
			Case GDK_BUTTON_RELEASE
				If SelectedRowIndex <> -1 Then
					If OnRowClick Then OnRowClick(*Designer, This, SelectedRowIndex)
				End If
				#ifdef __USE_GTK3__
				Case GDK_2BUTTON_PRESS, GDK_DOUBLE_BUTTON_PRESS
				#else
				Case GDK_2BUTTON_PRESS
				#endif
				If SelectedRowIndex <> -1 Then
					If OnRowDblClick Then OnRowDblClick(*Designer, This, SelectedRowIndex)
				End If
			Case GDK_KEY_PRESS
				If SelectedRowIndex <> -1 Then
					If OnRowKeyDown Then OnRowKeyDown(*Designer, This, SelectedRowIndex, Message.Event->key.keyval, Message.Event->key.state)
				End If
			End Select
		#elseif defined(__USE_WINAPI__)
			Dim As Rect R, Rc, Rc_
			Select Case Message.Msg
			Case LVM_DELETECOLUMN
				'Message.wParam
			Case LVM_INSERTCOLUMN
				'Print " ROOT=INSERTCOLUMN  " & Message.wParam
			Case WM_ERASEBKGND, WM_PAINT
				Message.Result = 0
			Case WM_DPICHANGED
				FItemHeight = 0
				Base.ProcessMessage(Message)
				If Images Then Images->SetImageSize Images->ImageWidth, Images->ImageHeight, xdpi, ydpi
				If StateImages Then StateImages->SetImageSize StateImages->ImageWidth, StateImages->ImageHeight, xdpi, ydpi
				If Images AndAlso Images->Handle Then ListView_SetImageList(FHandle, CInt(Images->Handle), LVSIL_SMALL)
				For i As Integer = 0 To Columns.Count - 1
					Columns.Column(i)->xdpi = xdpi
					Columns.Column(i)->ydpi = ydpi
					Columns.Column(i)->Update
				Next
				Return
			Case WM_DESTROY
				If Images Then ListView_SetImageList(FHandle, 0, LVSIL_NORMAL)
				If StateImages Then ListView_SetImageList(FHandle, 0, LVSIL_STATE)
				If SmallImages Then ListView_SetImageList(FHandle, 0, LVSIL_SMALL)
				If GroupHeaderImages Then ListView_SetImageList(FHandle, 0, LVSIL_GROUPHEADER)
			Case WM_NOTIFY
				If (Cast(LPNMHDR, Message.lParam)->code = NM_CUSTOMDRAW) Then
					Dim As LPNMCUSTOMDRAW nmcd = Cast(LPNMCUSTOMDRAW, Message.lParam)
					Select Case nmcd->dwDrawStage
					Case CDDS_PREPAINT
						Message.Result = CDRF_NOTIFYITEMDRAW
						Return
					Case CDDS_ITEMPREPAINT
						'Var info = Cast(SubclassInfo Ptr, dwRefData)
						If g_darkModeEnabled Then SetTextColor(nmcd->hdc, headerTextColor)
						Message.Result = CDRF_DODEFAULT
						Return
					End Select
				End If
			Case WM_SIZE, 78 '78 is Adjust the width of columns
				GridEditText.Visible= False
				'GetClientRect Handle, @FClientRect
				Message.Result = 0
			Case WM_KEYUP
				Select Case Message.wParam
				Case VK_DOWN
					FRow += 1
					If FRow > Rows.Count - 1 Then FRow = Rows.Count - 1
					GridEditText.Visible= False
					Repaint
				Case VK_UP
					FRow -= 1
					If FRow < 0 Then FRow = 0
					GridEditText.Visible= False
					Repaint
				Case VK_HOME, VK_END, VK_NEXT, VK_PRIOR
					Dim As Integer tItemSelel = ListView_GetNextItem(Handle, -1, LVNI_SELECTED)
					If tItemSelel <> -1 Then GridEditText.Visible= False
					GridEditText.Visible= False
					Repaint
				Case VK_SPACE
					If FSorting = False Then EditControlShow(FRow, FCol)
				Case VK_LEFT
					Dim As Integer i, flag
					For i = FCol To 1 Step -1
						If Columns.Column(i - 1)->Width > 1 Then FCol = i - 1 : flag = 1 : Exit For
					Next
					If i < 1 AndAlso flag = 0 Then
						For i = Columns.Count - 1 To 0 Step -1
							If Columns.Column(i)->Width > 1 Then FCol = i : Exit For
						Next
					End If
					GridEditText.Visible= False
					Repaint
				Case VK_RIGHT, VK_RETURN
					Dim As Integer i, flag
					For i = FCol To Columns.Count - 2
						If Columns.Column(i + 1)->Width > 1 Then FCol = i + 1 :  flag = 1 :  Exit For
					Next
					If i > Columns.Count - 2 AndAlso flag = 0 Then
						For i = 0 To Columns.Count - 1
							If Columns.Column(i)->Width > 1 Then FCol = i : Exit For
						Next
					End If
					GridEditText.Visible= False
					Repaint
					
				Case VK_ESCAPE
					GridEditText.Visible= False
					Repaint
				End Select
			Case WM_THEMECHANGED
				If (g_darkModeSupported) Then
					Dim As HWND hHeader = ListView_GetHeader(Message.hWnd)
					AllowDarkModeForWindow(Message.hWnd, g_darkModeEnabled)
					AllowDarkModeForWindow(hHeader, g_darkModeEnabled)
					Dim As HTHEME hTheme '= OpenThemeData(nullptr, "ItemsView")
					'If (hTheme) Then
					'	Dim As COLORREF Color1
					'	If (SUCCEEDED(GetThemeColor(hTheme, 0, 0, TMT_TEXTCOLOR, @Color1))) Then
					If g_darkModeEnabled Then
						ListView_SetTextColor(Message.hWnd, darkTextColor) 'Color1)
						ForeColor = darkTextColor
					Else
						ListView_SetTextColor(Message.hWnd, GetSysColor(COLOR_WINDOWTEXT)) 'Color1)
						ForeColor = GetSysColor(COLOR_WINDOWTEXT)
					End If
					'	End If
					'	If (SUCCEEDED(GetThemeColor(hTheme, 0, 0, TMT_FILLCOLOR, @Color1))) Then
					If g_darkModeEnabled Then
						ListView_SetTextBkColor(Message.hWnd, darkBkColor) 'Color1)
						ListView_SetBkColor(Message.hWnd, darkBkColor) 'Color1)
						BackColor = darkBkColor
					Else
						ListView_SetTextBkColor(Message.hWnd, GetSysColor(COLOR_WINDOW)) 'Color1)
						ListView_SetBkColor(Message.hWnd, GetSysColor(COLOR_WINDOW)) 'Color1)
						BackColor = GetSysColor(COLOR_WINDOW)
					End If
					hTheme = OpenThemeData(hHeader, "Header")
					If (hTheme) Then
						'Var info = reinterpret_cast<SubclassInfo*>(dwRefData);
						GetThemeColor(hTheme, HP_HEADERITEM, 0, TMT_TEXTCOLOR, @headerTextColor)
						CloseThemeData(hTheme)
					End If
					SendMessageW(hHeader, WM_THEMECHANGED, Message.wParam, Message.lParam)
					RedrawWindow(Message.hWnd, nullptr, nullptr, RDW_FRAME Or RDW_INVALIDATE)
				End If
			Case CM_NOTIFY
				Dim lvp As NMLISTVIEW Ptr = Cast(NMLISTVIEW Ptr, Message.lParam)
				Select Case lvp->hdr.code
				Case NM_CLICK
					If lvp->iItem >= 0 Then
						FCol = lvp->iSubItem
						FRow = lvp->iItem
						If FRow >= 0 AndAlso FCol > 0 AndAlso FRow < Rows.Count Then
							Dim As Rect RectCell
							ListView_GetSubItemRect(Handle, FRow, FCol, LVIR_BOUNDS, @RectCell)
							GridEditText.Text = Rows.Item(FRow)->Text(FCol)
							GridEditText.Visible= False
							GridEditText.SetBounds UnScaleX(RectCell.Left), UnScaleY(RectCell.Top), UnScaleX(RectCell.Right - RectCell.Left) - 1, UnScaleY(RectCell.Bottom - RectCell.Top) - 1
							If OnRowClick Then OnRowClick(*Designer, This, lvp->iItem)
						End If
						Repaint
					Else
						GridEditText.Visible= False
						Message.Result = 0
					End If
				Case NM_DBLCLK
					If FSorting = False AndAlso lvp->iItem >= 0 Then
						FCol = lvp->iSubItem
						FRow = lvp->iItem
						If FRow >= 0 AndAlso FCol > 0 AndAlso FRow < Rows.Count Then
							If OnRowDblClick Then OnRowDblClick(*Designer, This, lvp->iItem)
							EditControlShow(lvp->iItem, lvp->iSubItem)
						End If
					Else
						GridEditText.Visible= False
						Message.Result = 0
					End If
				Case NM_KEYDOWN:
					Dim As LPNMKEY lpnmk = Cast(LPNMKEY, Message.lParam)
					If OnRowKeyDown Then OnRowKeyDown(*Designer, This, lvp->iItem, lpnmk->nVKey, lpnmk->uFlags And &HFFFF)
				Case LVN_GETDISPINFO
					If FOwnerData Then
						Dim lpdi As NMLVDISPINFO Ptr = Cast(NMLVDISPINFO Ptr, Message.lParam)
						If lpdi->item.iItem > 0 Then
							Dim As Integer tCol = lpdi->item.iSubItem
							Dim As Integer tRow = lpdi->item.iItem
							Dim As WString * 255 NewText
							If OnGetDispInfo Then OnGetDispInfo(*Designer, This, NewText, tRow, tCol, lpdi->item.mask)
							If tRow >= 0 AndAlso tCol >= 0 AndAlso tRow < Rows.Count Then
								'Select Case lpdi->item.mask
								'Case LVIF_TEXT
								'	'lpdi->item.pszText = @NewText
								'Case LVIF_IMAGE
								'	'lpdi->item.iImage = Val(NewText)
								'Case LVIF_INDENT
								'	'lpdi->item.iIndent =  Val(NewText)
								'Case LVIF_PARAM
								'Case LVIF_STATE
								'
								'End Select
							End If
						End If
					End If
				Case LVN_ODCACHEHINT
					If FOwnerData Then
						Dim pCacheHint As NMLVCACHEHINT Ptr = Cast(NMLVCACHEHINT  Ptr, Message.lParam)
						' Load the cache With the recommended range if OwnerData is true.
						If OnCacheHint Then OnCacheHint(*Designer, This, pCacheHint->iFrom, pCacheHint->iTo)
					End If
				Case LVN_ODFINDITEM
					
				Case LVN_ITEMACTIVATE
					If lvp->iItem > 0 AndAlso OnRowActivate Then OnRowActivate(*Designer, This, lvp->iItem)
				Case LVN_BEGINSCROLL
					GridEditText.Visible= False
					If OnBeginScroll Then OnBeginScroll(*Designer, This)
				Case LVN_ENDSCROLL
					If OnEndScroll Then OnEndScroll(*Designer, This)
				Case LVN_COLUMNCLICK
					GridEditText.Visible= False
					If lvp->iSubItem > 0 AndAlso OnColumnClick Then OnColumnClick(*Designer, This, lvp->iSubItem)
				Case LVN_ITEMCHANGING
					GridEditText.Visible= False
					Dim bCancel As Boolean
					If lvp->iItem > 0 AndAlso OnSelectedRowChanging Then OnSelectedRowChanging(*Designer, This, lvp->iItem, bCancel)
					If bCancel Then Message.Result = 0
				Case LVN_ITEMCHANGED: If OnSelectedRowChanged Then OnSelectedRowChanged(*Designer, This, lvp->iItem)
				Case HDN_BEGINTRACK
					GridEditText.Visible = False ' Force refesh windows
				Case HDN_ITEMCHANGED
					GridEditText.Visible = False
				Case NM_CUSTOMDRAW
					Dim As LPNMCUSTOMDRAW nmcd = Cast(LPNMCUSTOMDRAW, Message.lParam)
					Select Case nmcd->dwDrawStage
					Case CDDS_PREPAINT
						Message.Result = CDRF_NOTIFYPOSTPAINT
						Return
					Case CDDS_ITEMPREPAINT
						
					Case CDDS_POSTPAINT
						Dim As HPEN GridLinesPen = CreatePen(PS_SOLID, 1, IIf(FGridColorLine = -1, IIf(g_darkModeEnabled, darkHlBkColor, GetSysColor(COLOR_BTNFACE)), FGridColorLine))
						Dim As HPEN PrevPen = SelectObject(nmcd->hdc, GridLinesPen)
						Dim As Integer frmt, Widths, Heights, ScrollLeft, WidthCol0, TextColor, TextColorSave, TextColorCol, TextColorRow
						Dim As Integer iRowsCount = Rows.Count, RowsCountPerPage = ListView_GetCountPerPage(FHandle)
						Dim As Integer ColumnsCount = Columns.Count, RowsTopIndex = ListView_GetTopIndex(FHandle)
						If RowsTopIndex < 0 Then RowsTopIndex = FRow
						Dim As Integer SelectedItem = RowsTopIndex
						Dim As Boolean DrawingOrderVert = IIf(Rows.Count > 0 AndAlso Rows.Item(0)->BackColor = -1, True, False)
						Dim As SCROLLINFO sif
						sif.cbSize = SizeOf(sif)
						sif.fMask  = SIF_POS
						GetScrollInfo(FHandle, SB_HORZ, @sif)
						ScrollLeft = sif.nPos
						Dim As HWND hHeader = ListView_GetHeader(FHandle)
						GetWindowRect(hHeader, @R)
						Heights = R.Bottom - R.Top - 1
						If ListView_GetItemCount(FHandle) = 0 Then
							If FItemHeight = 0 Then
								Dim As LVITEM lvi
								lvi.mask = LVIF_PARAM
								lvi.lParam = 0
								ListView_InsertItem(FHandle, @lvi)
								ListView_GetItemRect FHandle, 0, @Rc, LVIR_BOUNDS
								ListView_DeleteItem(FHandle, 0)
								FItemHeight = Rc.Bottom - Rc.Top
							End If
						Else
							ListView_GetSubItemRect(FHandle, SelectedItem, 1, LVIR_BOUNDS, @R)
							FItemHeight = R.Bottom - R.Top
							WidthCol0 = R.Left - 2
						End If
						'Widths = 0
						MoveToEx nmcd->hdc, 0, R.Top, 0
						LineTo nmcd->hdc, ScaleX(This.Width), R.Top
						If DrawingOrderVert Then
							For iCol As Integer = 0 To ColumnsCount - 1
								SelectedItem = RowsTopIndex
								ListView_GetSubItemRect(FHandle, SelectedItem, iCol, LVIR_BOUNDS, @R)
								If R.Right < 0 Then Continue For
								If ScrollLeft + ScaleX(This.Width) < R.Left Then Exit For
								Select Case Columns.Column(iCol)->Format
								Case ColumnFormat.cfLeft: frmt = DT_LEFT
								Case ColumnFormat.cfCenter: frmt = DT_CENTER
								Case ColumnFormat.cfRight: frmt = DT_RIGHT
								End Select
								TextColorCol = Columns.Column(iCol)->ForeColor
								For i As Integer = 0 To RowsCountPerPage
									If iCol = 0 Then
										MoveToEx nmcd->hdc, 0, Heights, 0
										LineTo nmcd->hdc, ScaleX(This.Width), Heights
									End If
									Heights += FItemHeight
									If SelectedItem < iRowsCount Then
										ListView_GetSubItemRect(FHandle, SelectedItem, iCol, LVIR_BOUNDS, @R)
										Rc.Left = R.Left + FGridLineWidth : Rc.Right = R.Right:  Rc.Top = IIf(SelectedItem = RowsTopIndex, R.Top + 1, R.Top)  : Rc.Bottom = R.Bottom - FGridLineWidth
										If SelectedItem < iRowsCount Then
											DrawRect(nmcd->hdc, Rc, Rows.Item(SelectedItem)->Item(iCol)->BackColor, SelectedItem, iCol)
											If SelectedItem = FRow AndAlso iCol = FCol Then
												TextColorSave = Rows.Item(SelectedItem)->Item(iCol)->ForeColor
												SetTextColor nmcd->hdc, TextColorSave
												DrawFocusRect nmcd->hdc, @Rc
											End If
										End If
										'If iCol = FCol Then DrawFocusRect nmcd->hdc, @R 'draw focus rectangle
										Rc.Left = R.Left + 3 : Rc.Right = R.Right - 3 : Rc.Top = R.Top + 2 : Rc.Bottom = R.Bottom - 2
										If iCol = 0 Then
											Rows.Item(SelectedItem)->Text(iCol) = Str(SelectedItem + 1)
											If WidthCol0 > 0 Then Rc.Right = WidthCol0
										End If
										TextColor = Rows.Item(SelectedItem)->Item(iCol)->ForeColor
										TextColor = IIf(TextColor <> -1, TextColor, IIf(TextColorCol = -1, This.ForeColor, TextColorCol))
										If SelectedItem = FRow AndAlso iCol = FCol Then TextColor = FGridColorEditFore
										If TextColor <>  TextColorSave  Then SetTextColor nmcd->hdc, TextColor : TextColorSave = TextColor
										DrawText nmcd->hdc, @Rows.Item(SelectedItem)->Text(iCol), Len(Rows.Item(SelectedItem)->Text(iCol)), @Rc, DT_END_ELLIPSIS Or frmt 'Draw text
									End If
									SelectedItem += 1
								Next
								MoveToEx nmcd->hdc, R.Left, 0, 0
								LineTo nmcd->hdc, R.Left, ScaleY(This.Height)
							Next
							MoveToEx nmcd->hdc, R.Right, 0, 0
							LineTo nmcd->hdc, R.Right, ScaleY(This.Height)
						Else
							For i As Integer = 0 To RowsCountPerPage
								MoveToEx nmcd->hdc, 0, Heights, 0
								LineTo nmcd->hdc, ScaleX(This.Width), Heights
								Heights += FItemHeight
								If SelectedItem < iRowsCount Then
									For iCol As Integer = 0 To ColumnsCount - 1
										ListView_GetSubItemRect(FHandle, SelectedItem, iCol, LVIR_BOUNDS, @R)
										If R.Right < 0 Then Continue For
										If ScrollLeft + ScaleX(This.Width) < R.Left Then Exit For
										Rc.Left = R.Left + FGridLineWidth : Rc.Right = R.Right:  Rc.Top = IIf(SelectedItem = RowsTopIndex, R.Top + 1, R.Top)  : Rc.Bottom = R.Bottom - FGridLineWidth
										If SelectedItem < iRowsCount Then
											DrawRect(nmcd->hdc, Rc, Rows.Item(SelectedItem)->Item(iCol)->BackColor, SelectedItem, iCol)
											If SelectedItem = FRow AndAlso iCol = FCol Then
												TextColorSave = Rows.Item(SelectedItem)->Item(iCol)->ForeColor
												SetTextColor nmcd->hdc, TextColorSave
												DrawFocusRect nmcd->hdc, @Rc
											End If
										End If
										'If iCol = FCol Then DrawFocusRect nmcd->hdc, @R 'draw focus rectangle
										Rc.Left = R.Left + 3 : Rc.Right = R.Right - 3 : Rc.Top = R.Top + 2 : Rc.Bottom = R.Bottom - 2
										Select Case Columns.Column(iCol)->Format
										Case ColumnFormat.cfLeft: frmt = DT_LEFT
										Case ColumnFormat.cfCenter: frmt = DT_CENTER
										Case ColumnFormat.cfRight: frmt = DT_RIGHT
										End Select
										TextColorCol = Columns.Column(iCol)->ForeColor
										If SelectedItem < iRowsCount Then
											If iCol = 0 Then
												Rows.Item(SelectedItem)->Text(iCol) = Str(SelectedItem + 1)
												If WidthCol0 > 0 Then Rc.Right = WidthCol0
											End If
											TextColor = Rows.Item(SelectedItem)->Item(iCol)->ForeColor
											TextColor = IIf(TextColor <> -1, TextColor, IIf(TextColorCol = -1, This.ForeColor, TextColorCol))
											If SelectedItem = FRow AndAlso iCol = FCol Then TextColor = FGridColorEditFore
											If TextColor <>  TextColorSave  Then SetTextColor nmcd->hdc, TextColor : TextColorSave = TextColor
											DrawText nmcd->hdc, @Rows.Item(SelectedItem)->Text(iCol), Len(Rows.Item(SelectedItem)->Text(iCol)), @Rc, DT_END_ELLIPSIS Or frmt 'Draw text
										End If
										MoveToEx nmcd->hdc, R.Left, 0, 0
										LineTo nmcd->hdc, R.Left, ScaleY(This.Height)
									Next
									SelectedItem += 1
								End If
							Next
							MoveToEx nmcd->hdc, R.Right, 0, 0
							LineTo nmcd->hdc, R.Right, ScaleY(This.Height)
						End If
						SelectObject(nmcd->hdc, PrevPen)
						DeleteObject GridLinesPen
						Message.Result = CDRF_SKIPPOSTPAINT Or CDRF_SKIPDEFAULT
						Return
					End Select
				End Select
			Case WM_NOTIFY
				If (Cast(LPNMHDR, Message.lParam)->code = NM_CUSTOMDRAW) Then
					Dim As LPNMCUSTOMDRAW nmcd = Cast(LPNMCUSTOMDRAW, Message.lParam)
					Select Case nmcd->dwDrawStage
					Case CDDS_PREPAINT
						Message.Result = CDRF_NOTIFYITEMDRAW
						Return
					Case CDDS_ITEMPREPAINT
						Message.Result = CDRF_DODEFAULT
						Return
					End Select
				End If
				Select Case Message.wParam
				Case LVN_BEGINSCROLL
				Case LVN_ENDSCROLL
				End Select
			Case CM_COMMAND
				Select Case Message.wParam
				Case LVN_ITEMACTIVATE
				Case LVN_KEYDOWN
				Case LVN_ITEMCHANGING
				Case LVN_ITEMCHANGED
				Case LVN_INSERTITEM
				Case LVN_DELETEITEM
				Case LVN_DELETEALLITEMS
				Case LVN_BEGINLABELEDIT
				Case LVN_ENDLABELEDIT
				Case LVN_BEGINDRAG
				Case LVN_BEGINRDRAG
				Case LVN_ODCACHEHINT
				Case LVN_ODFINDITEM
				Case LVN_ODSTATECHANGED
				Case LVN_HOTTRACK
				Case LVN_GETDISPINFO
				Case LVN_SETDISPINFO
					'Case LVN_COLUMNDROPDOWN
				Case LVN_GETINFOTIP
					'Case LVN_COLUMNOVERFLOWCLICK
				Case LVN_INCREMENTALSEARCH
				Case LVN_BEGINSCROLL
				Case LVN_ENDSCROLL
					'Case LVN_LINKCLICK
					'Case LVN_GETEMPTYMARKUP
				Case VK_DOWN
					GridEditText.Visible= False
				Case VK_UP
					GridEditText.Visible= False
				Case VK_ESCAPE
					GridEditText.Visible= False
				Case VK_RETURN, VK_TAB
					' "Now you can input RETURN Keycode"
					'If GridEditText.Multiline = False Then
					Rows.Item(FRow)->Text(FCol) = GridEditText.Text
					GridEditText.Visible= False ' Force refesh windows
					If OnCellEdited Then OnCellEdited(*Designer, This, FRow, FCol, GridEditText.Text)
					'End If
					
				End Select
				'            Dim As TBNOTIFY PTR Tbn
				'            Dim As TBBUTTON TB
				'            Dim As RECT R
				'            Dim As Integer i
				'            Tbn = Cast(TBNOTIFY PTR,Message.lParam)
				'            Select Case Tbn->hdr.Code
				'            Case TBN_DROPDOWN
				'                 If Tbn->iItem <> -1 Then
				'                     SendMessage(Tbn->hdr.hwndFrom,TB_GETRECT,Tbn->iItem,CInt(@R))
				'                     MapWindowPoints(Tbn->hdr.hwndFrom,0,Cast(Point Ptr,@R),2)
				'                     i = SendMessage(Tbn->hdr.hwndFrom,TB_COMMANDTOINDEX,Tbn->iItem,0)
				'                     If SendMessage(Tbn->hdr.hwndFrom,TB_GETBUTTON,i,CInt(@TB)) Then
				'                         TrackPopupMenu(Buttons.Button(i)->DropDownMenu.Handle,0,R.Left,R.Bottom,0,Tbn->hdr.hwndFrom,NULL)
				'                     End If
				'                 End If
				'            End Select
			Case CM_NEEDTEXT
				'            Dim As LPTOOLTIPTEXT TTX
				'            TTX = Cast(LPTOOLTIPTEXT,Message.lParam)
				'            TTX->hInst = GetModuleHandle(NULL)
				'            If TTX->hdr.idFrom Then
				'                Dim As TBButton TB
				'                Dim As Integer Index
				'                Index = Perform(TB_COMMANDTOINDEX,TTX->hdr.idFrom,0)
				'                If Perform(TB_GETBUTTON,Index,CInt(@TB)) Then
				'                   If Buttons.Button(Index)->ShowHint Then
				'                      If Buttons.Button(Index)->Hint <> "" Then
				'                          'Dim As UString s
				'                          's = Buttons.Button(Index).Hint
				'                          TTX->lpszText = @(Buttons.Button(Index)->Hint)
				'                      End If
				'                   End If
				'                End If
				'            End If
			End Select
		#endif
		Base.ProcessMessage(Message)
	End Sub
	
	#ifdef __USE_WASM__
		Private Function Grid.GetContent() As UString
			Return "<thead><tr></tr></thead><tbody></tbody>"
		End Function
	#endif
	
	#ifndef __USE_GTK__
		Private Sub Grid.HandleIsAllocated(ByRef Sender As Control)
			If Sender.Child Then
				With QGrid(Sender.Child)
					If .Images Then
						.Images->ParentWindow = @Sender
						#ifdef __USE_WINAPI__
							If .Images->Handle Then ListView_SetImageList(.FHandle, CInt(.Images->Handle), LVSIL_NORMAL)
						#endif
					End If
					If .SelectedImages Then .SelectedImages->ParentWindow = @Sender
					If .SmallImages Then .SmallImages->ParentWindow = @Sender
					If .GroupHeaderImages Then .GroupHeaderImages->ParentWindow = @Sender
					#ifdef __USE_WINAPI__
						If .Images AndAlso .Images->Handle Then ListView_SetImageList(.FHandle, CInt(.Images->Handle), LVSIL_NORMAL)
						If .SelectedImages AndAlso .SelectedImages->Handle Then ListView_SetImageList(.FHandle, CInt(.SelectedImages->Handle), LVSIL_STATE)
						If .SmallImages AndAlso .SmallImages->Handle Then ListView_SetImageList(.FHandle, CInt(.SmallImages->Handle), LVSIL_SMALL)
						If .GroupHeaderImages AndAlso .GroupHeaderImages->Handle Then ListView_SetImageList(.FHandle, CInt(.GroupHeaderImages->Handle), LVSIL_GROUPHEADER)
						Dim lvStyle As Integer
						lvStyle = SendMessage(.FHandle, LVM_GETEXTENDEDLISTVIEWSTYLE, 0, 0)
						lvStyle = lvStyle Or .FLVExStyle
						SendMessage(.FHandle, LVM_SETEXTENDEDLISTVIEWSTYLE, 0, ByVal lvStyle)
						.GridEditText.ParentHandle = .Handle
					#endif
					.GridEditText.Visible = False
					For i As Integer = 0 To .Columns.Count - 1
						#ifdef __USE_WINAPI__
							Dim lvc As LVCOLUMN
							lvc.mask            = LVCF_FMT Or LVCF_WIDTH Or LVCF_TEXT Or LVCF_SUBITEM
							lvc.fmt             = .Columns.Column(i)->Format
							lvc.cx              = 0
							lvc.pszText         = @.Columns.Column(i)->Text
							lvc.cchTextMax      = Len(.Columns.Column(i)->Text)
							lvc.iImage          = .Columns.Column(i)->ImageIndex
							lvc.iSubItem        = i
							Var iWidth = .Columns.Column(i)->Width
							ListView_InsertColumn(.FHandle, i, @lvc)
							ListView_SetColumnWidth(.FHandle, i, .ScaleX(iWidth))
						#elseif defined(__USE_WASM__)
							AddColumn(.FHandle, ToUtf8(.Columns.Column(i)->Text))
						#endif
					Next i
					Var TempHandle = .FHandle
					For i As Integer = 0 To .Rows.Count - 1
						#ifdef __USE_WASM__
							Dim As UString strRow = ""
						#endif
						For j As Integer = 0 To .Columns.Count - 1
							.FHandle = 0
							#ifdef __USE_WINAPI__
								Dim lvi As LVITEM
								lvi.pszText         = @.Rows.Item(i)->Text(j)
								lvi.cchTextMax      = Len(.Rows.Item(i)->Text(j))
								lvi.iItem           = i
								lvi.iSubItem        = j
								If j = 0 Then
									lvi.mask = LVIF_TEXT Or LVIF_IMAGE Or LVIF_STATE Or LVIF_INDENT Or LVIF_PARAM
									lvi.iImage          = .Rows.Item(i)->ImageIndex
									lvi.state   = INDEXTOSTATEIMAGEMASK(.Rows.Item(i)->State)
									lvi.stateMask = LVIS_STATEIMAGEMASK
									lvi.iIndent   = .Rows.Item(i)->Indent
									lvi.lParam   =  Cast(LPARAM, .Rows.Item(i))
									.FHandle = TempHandle
									ListView_InsertItem(.FHandle, @lvi)
								Else
									.FHandle = TempHandle
									lvi.mask = LVIF_TEXT
									ListView_SetItem(.FHandle, @lvi)
								End If
							#elseif defined(__USE_WASM__)
								strRow &= "<td style=""border: 1px solid;"">" & ToUtf8(.Rows.Item(i)->Text(j)) & "</td>"
							#endif
						Next j
						#ifdef __USE_WASM__
							AddRow(TempHandle, strRow)
						#endif
					Next i
					.SelectedRowIndex = 0
				End With
			End If
		End Sub
	#endif
	
	#ifdef __USE_WINAPI__
		Private Sub Grid.EditControlShow(ByVal tRow As Integer, ByVal tCol As Integer)
			If FAllowEdit = False OrElse CBool(tCol = 0) OrElse (IIf(Rows.Item(tRow)->Editable= False, Not Columns.Column(tCol)->Editable, Not Rows.Item(tRow)->Item(tCol)->Editable)) Then Exit Sub
			If tRow < 0 OrElse tCol <= 0 OrElse tRow > Rows.Count - 1 OrElse tCol > Columns.Count - 1 Then Exit Sub
			Dim As Rect RectCell
			'Move to new position
			If tRow >= 0 AndAlso tCol >= 0 Then
				ListView_GetSubItemRect(Handle, tRow, tCol, LVIR_BOUNDS, @RectCell)
				'GridEditText.BackColor = FGridColorEditBack
				'GridEditText.SetBounds UnScaleX(RectCell.Left), UnScaleY(RectCell.Top), UnScaleX(RectCell.Right - RectCell.Left) - 1, UnScaleY(RectCell.Bottom - RectCell.Top) - 1
				'GridEditText.Text = Rows.Item(tRow)->Text(tCol)
				GridEditText.SetFocus
				GridEditText.SetSel Len(Rows.Item(tRow)->Text(tCol)), Len(Rows.Item(tRow)->Text(tCol))
				GridEditText.Visible = True
			Else
				GridEditText.Visible= False
			End If
			'InvalidateRect(Handle,@RectCell,False)
			'UpdateWindow Handle
		End Sub
		
		Private Sub Grid.WndProc(ByRef Message As Message)
		End Sub
		
		Private Sub Grid.DrawRect(tDc As HDC, R As Rect, FillColor As Integer = -1, tSelctionRow As Integer = -1, tSelctionCol As Integer = -1)
			Static As HBRUSH BSelction
			Static As HBRUSH BCellBack
			Static As Integer FillColorSave
			If tSelctionRow = FRow AndAlso (FFullRowSelect OrElse (tSelctionCol = FCol)) Then
				If BSelction Then DeleteObject BSelction
				BSelction = CreateSolidBrush(IIf(tSelctionCol = FCol, FGridColorEditBack, FGridColorSelected))
				FillRect tDc, @R, BSelction
			Else
				Dim As Integer TextColorBK, TextColorCol = Columns.Column(tSelctionCol)->BackColor
				TextColorBK = IIf(FillColor <> -1, FillColor, IIf(TextColorCol = -1, This.BackColor, TextColorCol))
				If TextColorBK  <> FillColorSave  Then
					If BCellBack Then DeleteObject BCellBack
					BCellBack = CreateSolidBrush(TextColorBK)
					FillColorSave = TextColorBK
				End If
				'DrawEdge tDc,@R,BDR_RAISEDINNER,BF_FLAT'BF_BOTTOM
				'If FGridLineDrawMode = GridLineNone  Then  ' GRIDLINE_None Both GRIDLINE_Vertical GRIDLINE_Horizontal Then
				'	DrawEdge tDc, @R, BDR_SUNKENOUTER, BF_FLAT
				'	'InflateRect(@R, -1, -1)
				'	FillRect tDc, @R, BCellBack
				'Else
				FillRect tDc, @R, BCellBack
				'End If
			End If
		End Sub
		Private Sub Grid.HandleIsDestroyed(ByRef Sender As Control)
		End Sub
	#elseif defined(__USE_GTK__)
		Private Sub Grid.Grid_RowActivated(tree_view As GtkTreeView Ptr, path As GtkTreePath Ptr, column As GtkTreeViewColumn Ptr, user_data As Any Ptr)
			Dim As Grid Ptr lv = Cast(Any Ptr, user_data)
			If lv Then
				Dim As GtkTreeModel Ptr model
				Dim As GtkTreeIter iter
				model = gtk_tree_view_get_model(tree_view)
				If gtk_tree_model_get_iter(model, @iter, path) Then
					If lv->OnRowActivate Then lv->OnRowActivate(*lv->Designer, *lv, Val(*gtk_tree_model_get_string_from_iter(model, @iter)))
				End If
			End If
		End Sub
		
		Private Sub Grid.Grid_SelectionChanged(selection As GtkTreeSelection Ptr, user_data As Any Ptr)
			Dim As Grid Ptr lv = Cast(Any Ptr, user_data)
			If lv Then
				Dim As GtkTreeIter iter
				Dim As GtkTreeModel Ptr model
				If gtk_tree_selection_get_selected(selection, @model, @iter) Then
					Dim As Integer SelectedIndex = Val(*gtk_tree_model_get_string_from_iter(model, @iter))
					If lv->PrevIndex <> SelectedIndex AndAlso lv->PrevIndex <> -1 Then
						Dim bCancel As Boolean
						If lv->OnSelectedRowChanging Then lv->OnSelectedRowChanging(*lv->Designer, *lv, lv->PrevIndex, bCancel)
						If bCancel Then
							lv->SelectedRowIndex = lv->PrevIndex
							Exit Sub
						End If
					End If
					If lv->OnSelectedRowChanged Then lv->OnSelectedRowChanged(*lv->Designer, *lv, SelectedIndex)
					lv->PrevIndex = SelectedIndex
				End If
			End If
		End Sub
		
		Private Sub Grid.Grid_Map(widget As GtkWidget Ptr, user_data As Any Ptr)
			Dim As Grid Ptr lv = user_data
			lv->Clear
		End Sub
		
		Private Function Grid.Grid_Scroll(self As GtkAdjustment Ptr, user_data As Any Ptr) As Boolean
			Dim As Grid Ptr lv = user_data
			If lv->OnEndScroll Then lv->OnEndScroll(*lv->Designer, *lv)
			Return True
		End Function
	#endif
	
	Private Operator Grid.[](RowIndex As Integer) ByRef As GridRow
		Return *Rows.Item(RowIndex)
	End Operator
	
	Private Operator Grid.Cast As Control Ptr
		Return @This
	End Operator
	
	Private Sub Grid.EnsureVisible(Index As Integer)
		#ifdef __USE_GTK__
			If GTK_IS_ICON_VIEW(widget) Then
				gtk_icon_view_select_path(GTK_ICON_VIEW(widget), gtk_tree_path_new_from_string(Trim(Str(Index))))
			Else
				If TreeSelection Then
					If Index > -1 AndAlso Index < Rows.Count Then
						Dim As GtkTreeIter iter
						gtk_tree_model_get_iter_from_string(GTK_TREE_MODEL(ListStore), @iter, Trim(Str(Index)))
						gtk_tree_view_scroll_to_cell(GTK_TREE_VIEW(widget), gtk_tree_model_get_path(GTK_TREE_MODEL(ListStore), @iter), NULL, False, 0, 0)
					End If
				End If
			End If
		#elseif defined(__USE_WINAPI__)
			ListView_EnsureVisible(FHandle, Index, True)
		#endif
	End Sub
	
	Private Sub Grid.SaveToFile(ByRef FileName As WString)
		Dim As Integer Fn
		Fn = FreeFile_
		If Open(FileName For Output Encoding "utf-8" As #Fn) = 0 Then
			Dim As WString Ptr tmpStr
			WLet(tmpStr, Columns.Column(1)->Text)
			For iCol As Integer = 2 To Columns.Count - 1
				WAdd tmpStr, Chr(9) & Columns.Column(iCol)->Text
			Next
			Print #Fn, *tmpStr
			For iRow As Integer = 0 To Rows.Count - 1
				WLet(tmpStr, Rows.Item(iRow)->Text(1))
				For iCol As Integer = 2 To Columns.Count - 1
					WAdd tmpStr, Chr(9) & Rows.Item(iRow)->Text(iCol)
				Next
				Print #Fn, *tmpStr
			Next
			_Deallocate(tmpStr)
		End If
		CloseFile_(Fn)
	End Sub
	
	Private Sub Grid.LoadFromFile(ByRef FileName As WString)
		Dim As Integer Fn
		Fn = FreeFile_
		This.Clear
		If Open(FileName For Input Encoding "utf-8" As #Fn) = 0 Then
			Dim As WString * 4096 tmpStr
			Dim As WString Ptr ColTitle(Any)
			Dim As Integer iRowsCount
			Line Input #Fn, tmpStr
			Split(tmpStr, Chr(9), ColTitle())
			OwnerData = False
			Columns.Add "NO.", , 30 , cfRight
			For i As Integer = 0 To UBound(ColTitle)
				Columns.Add *ColTitle(i)
			Next
			While Not EOF(Fn)
				Line Input #Fn, tmpStr
				iRowsCount += 1
				'RowsCount = iRowsCount
				Rows.Add tmpStr
			Wend
		End If
		CloseFile_(Fn)
	End Sub
	Private Constructor Grid
		#ifdef __USE_GTK__
			ListStore = gtk_list_store_new(3, G_TYPE_BOOLEAN, GDK_TYPE_PIXBUF, G_TYPE_STRING)
			scrolledwidget = gtk_scrolled_window_new(NULL, NULL)
			gtk_scrolled_window_set_policy(GTK_SCROLLED_WINDOW(scrolledwidget), GTK_POLICY_AUTOMATIC, GTK_POLICY_AUTOMATIC)
			'widget = gtk_tree_view_new_with_model(gtk_tree_model(ListStore))
			widget = gtk_tree_view_new()
			gtk_container_add(GTK_CONTAINER(scrolledwidget), widget)
			TreeSelection = gtk_tree_view_get_selection(GTK_TREE_VIEW(widget))
			#ifdef __USE_GTK3__
				g_signal_connect(gtk_scrollable_get_hadjustment(GTK_SCROLLABLE(widget)), "value-changed", G_CALLBACK(@Grid_Scroll), @This)
				g_signal_connect(gtk_scrollable_get_vadjustment(GTK_SCROLLABLE(widget)), "value-changed", G_CALLBACK(@Grid_Scroll), @This)
			#else
				g_signal_connect(gtk_tree_view_get_hadjustment(GTK_TREE_VIEW(widget)), "value-changed", G_CALLBACK(@Grid_Scroll), @This)
				g_signal_connect(gtk_tree_view_get_vadjustment(GTK_TREE_VIEW(widget)), "value-changed", G_CALLBACK(@Grid_Scroll), @This)
			#endif
			g_signal_connect(GTK_TREE_VIEW(widget), "map", G_CALLBACK(@Grid_Map), @This)
			g_signal_connect(GTK_TREE_VIEW(widget), "row-activated", G_CALLBACK(@Grid_RowActivated), @This)
			g_signal_connect(G_OBJECT(TreeSelection), "changed", G_CALLBACK (@Grid_SelectionChanged), @This)
			gtk_tree_view_set_enable_tree_lines(GTK_TREE_VIEW(widget), True)
			gtk_tree_view_set_grid_lines(GTK_TREE_VIEW(widget), GTK_TREE_VIEW_GRID_LINES_BOTH)
			ColumnTypes = _New( GType[3])
			ColumnTypes[0] = G_TYPE_BOOLEAN
			ColumnTypes[1] = GDK_TYPE_PIXBUF
			ColumnTypes[2] = G_TYPE_STRING
			This.RegisterClass "Grid", @This
		#endif
		BorderStyle = BorderStyles.bsClient
		FOwnerData = False
		Rows.Parent = @This
		Columns.Parent = @This
		DoubleBuffered = True
		FEnabled = True
		FGridLines = True
		FFullRowSelect = True
		FVisible = True
		FTabIndex          = -1
		FTabStop           = True
		With GridEditText
			.Parent = @This
			.Multiline= False
			.BackColor = FGridColorEditBack
			.ForeColor = FGridColorEditFore
			.BringToFront
		End With
		With This
			#ifdef __USE_WINAPI__
				.OnHandleIsAllocated = @HandleIsAllocated
				.OnHandleIsDestroyed = @HandleIsDestroyed
				.ChildProc         = @WndProc
				.ExStyle           = WS_EX_CLIENTEDGE
				.FLVExStyle        = LVS_EX_FULLROWSELECT Or LVS_EX_GRIDLINES Or LVS_EX_DOUBLEBUFFER
				'Dynamically switching to and from the LVS_OWNERDATA style is not supported.
				.Style             = WS_CHILD Or WS_TABSTOP Or WS_VISIBLE Or LVS_REPORT Or LVS_SINGLESEL Or LVS_SHOWSELALWAYS Or LVS_OWNERDATA
				.DoubleBuffered = True
				.BackColor = IIf(g_darkModeEnabled, darkBkColor, GetSysColor(COLOR_WINDOW))
				.ForeColor = IIf(g_darkModeEnabled, darkTextColor, Font.Color)
				.RegisterClass "Grid", WC_LISTVIEW
				WLet(FClassAncestor, WC_LISTVIEW)
			#elseif defined(__USE_WASM__)
				WLet(FClassAncestor, "table")
				FElementStyle = "border-collapse: collapse;"
				.OnHandleIsAllocated = @HandleIsAllocated
			#endif
			.Child             = @This
			WLet(FClassName, "Grid")
			.Width             = 121
			.Height            = 121
		End With
	End Constructor
	
	Private Destructor Grid
		Rows.Clear
		Columns.Clear
		#ifdef __USE_WINAPI__
			UnregisterClass "Grid", GetModuleHandle(NULL)
		#elseif defined(__USE_GTK__)
			If ColumnTypes Then _DeleteSquareBrackets( ColumnTypes)
		#endif
	End Destructor
End Namespace
