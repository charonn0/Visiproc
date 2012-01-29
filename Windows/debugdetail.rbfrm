#tag Window
Begin Window debugdetail
   BackColor       =   255
   Backdrop        =   ""
   CloseButton     =   True
   Composite       =   False
   Frame           =   3
   FullScreen      =   False
   HasBackColor    =   False
   Height          =   294
   ImplicitInstance=   True
   LiveResize      =   True
   MacProcID       =   0
   MaxHeight       =   32000
   MaximizeButton  =   False
   MaxWidth        =   32000
   MenuBar         =   ""
   MenuBarVisible  =   True
   MinHeight       =   64
   MinimizeButton  =   True
   MinWidth        =   64
   Placement       =   3
   Resizeable      =   False
   Title           =   "Debug Messages"
   Visible         =   True
   Width           =   377
   Begin Listbox Listbox1
      AutoDeactivate  =   True
      AutoHideScrollbars=   True
      Bold            =   ""
      Border          =   True
      ColumnCount     =   2
      ColumnsResizable=   ""
      ColumnWidths    =   "10%, *"
      DataField       =   ""
      DataSource      =   ""
      DefaultRowHeight=   -1
      Enabled         =   True
      EnableDrag      =   ""
      EnableDragReorder=   ""
      GridLinesHorizontal=   0
      GridLinesVertical=   0
      HasHeading      =   True
      HeadingIndex    =   -1
      Height          =   294
      HelpTag         =   ""
      Hierarchical    =   ""
      Index           =   -2147483648
      InitialParent   =   ""
      InitialValue    =   "#	Message"
      Italic          =   ""
      Left            =   0
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   True
      RequiresSelection=   ""
      Scope           =   0
      ScrollbarHorizontal=   ""
      ScrollBarVertical=   True
      SelectionType   =   0
      TabIndex        =   0
      TabPanelIndex   =   0
      TabStop         =   True
      TextFont        =   "System"
      TextSize        =   12
      TextUnit        =   0
      Top             =   0
      Underline       =   ""
      UseFocusRing    =   True
      Visible         =   True
      Width           =   377
      _ScrollWidth    =   -1
   End
   Begin Timer Timer1
      Height          =   32
      Index           =   -2147483648
      Left            =   468
      LockedInPosition=   False
      Mode            =   2
      Period          =   1000
      Scope           =   0
      TabPanelIndex   =   0
      Top             =   0
      Width           =   32
   End
End
#tag EndWindow

#tag WindowCode
#tag EndWindowCode

#tag Events Listbox1
	#tag Event
		Function CellBackgroundPaint(g As Graphics, row As Integer, column As Integer) As Boolean
		  'If row Mod 2=0 then
		  'g.foreColor= &cC0C0C0
		  'else
		  'g.foreColor= &c9E9E9E
		  'end if
		  'g.FillRect 0,0,g.width,g.height
		  
		  #pragma Unused row
		  #pragma Unused column
		  g.ForeColor = &cF0F0F0
		  g.FillRect(0, 0, g.Width, g.Height)
		End Function
	#tag EndEvent
#tag EndEvents
#tag Events Timer1
	#tag Event
		Sub Action()
		  Static lastnum As Integer
		  If debugcount > lastnum Then
		    For i As Integer = lastNum To UBound(DebugLog)
		      Dim x As Integer = UBound(DebugLog) - i
		      Listbox1.AddRow(Str(debugcount - x), DebugLog(i))
		    Next
		    'Self.Height = (Listbox1.RowHeight + 2) * (Listbox1.LastIndex)// + 20
		    Listbox1.ScrollPosition = Listbox1.LastIndex
		  End If
		  lastnum = debugcount
		End Sub
	#tag EndEvent
#tag EndEvents
