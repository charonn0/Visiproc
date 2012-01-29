#tag Window
Begin Window DriveDetail
   BackColor       =   9216
   Backdrop        =   ""
   CloseButton     =   True
   Composite       =   False
   Frame           =   3
   FullScreen      =   False
   HasBackColor    =   False
   Height          =   196
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
   Title           =   "Drive Detail"
   Visible         =   True
   Width           =   377
   Begin Listbox Listbox1
      AutoDeactivate  =   True
      AutoHideScrollbars=   True
      Bold            =   ""
      Border          =   True
      ColumnCount     =   2
      ColumnsResizable=   ""
      ColumnWidths    =   ""
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
      Height          =   196
      HelpTag         =   ""
      Hierarchical    =   ""
      Index           =   -2147483648
      InitialParent   =   ""
      InitialValue    =   "Key	Value"
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
End
#tag EndWindow

#tag WindowCode
	#tag Method, Flags = &h0
		Sub ShowMe(Drive As String)
		  Dim theVolume As Dictionary = Platform.VolumeInfo(Drive)
		  Me.Title = "Drive Detail - " + Drive
		  Listbox1.DeleteAllRows
		  If theVolume = Nil Then
		    Listbox1.AddRow("No Volume Mounted.")
		  Else
		    For i As Integer = 0 To theVolume.Count - 1
		      Listbox1.AddRow(theVolume.Key(i), theVolume.Value(theVolume.Key(i)))
		    Next
		    Self.Height = (Listbox1.RowHeight + 2) * (Listbox1.LastIndex)// + 20
		  End If
		End Sub
	#tag EndMethod


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
