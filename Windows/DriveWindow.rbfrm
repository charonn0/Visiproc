#tag Window
Begin Window DriveWindow
   BackColor       =   9216
   Backdrop        =   ""
   CloseButton     =   True
   Composite       =   False
   Frame           =   3
   FullScreen      =   False
   HasBackColor    =   False
   Height          =   246
   ImplicitInstance=   True
   LiveResize      =   True
   MacProcID       =   0
   MaxHeight       =   32000
   MaximizeButton  =   False
   MaxWidth        =   32000
   MenuBar         =   ""
   MenuBarVisible  =   True
   MinHeight       =   163
   MinimizeButton  =   True
   MinWidth        =   64
   Placement       =   3
   Resizeable      =   False
   Title           =   "Disk Drives"
   Visible         =   True
   Width           =   377
   Begin Listbox Listbox1
      AutoDeactivate  =   True
      AutoHideScrollbars=   True
      Bold            =   ""
      Border          =   True
      ColumnCount     =   5
      ColumnsResizable=   False
      ColumnWidths    =   "10%, 25%, 10%, 27%, 28%"
      DataField       =   ""
      DataSource      =   ""
      DefaultRowHeight=   -1
      Enabled         =   True
      EnableDrag      =   ""
      EnableDragReorder=   ""
      GridLinesHorizontal=   1
      GridLinesVertical=   1
      HasHeading      =   True
      HeadingIndex    =   -1
      Height          =   246
      HelpTag         =   ""
      Hierarchical    =   ""
      Index           =   -2147483648
      InitialParent   =   ""
      InitialValue    =   "Path	Volume Name	FS	Bytes Total	 Bytes Free"
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
      TextSize        =   0
      TextUnit        =   0
      Top             =   0
      Underline       =   ""
      UseFocusRing    =   True
      Visible         =   True
      Width           =   377
      _ScrollWidth    =   -1
   End
   Begin PushButton PushButton1
      AutoDeactivate  =   True
      Bold            =   ""
      ButtonStyle     =   0
      Cancel          =   True
      Caption         =   "Untitled"
      Default         =   False
      Enabled         =   True
      Height          =   22
      HelpTag         =   ""
      Index           =   -2147483648
      InitialParent   =   ""
      Italic          =   ""
      Left            =   93
      LockBottom      =   ""
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   ""
      LockTop         =   True
      Scope           =   0
      TabIndex        =   1
      TabPanelIndex   =   0
      TabStop         =   True
      TextFont        =   "System"
      TextSize        =   0
      TextUnit        =   0
      Top             =   -56
      Underline       =   ""
      Visible         =   True
      Width           =   80
   End
End
#tag EndWindow

#tag WindowCode
	#tag Event
		Sub Open()
		  For i As Integer = 0 To VolumeCount - 1
		    Dim free, total As UInt64
		    Dim dr As New VolumeInformation(Volume(i).AbsolutePath)
		    Listbox1.AddRow(dr.Path, dr.Name, dr.Filesystem, prettifyBytes(dr.Totalbytes), prettifyBytes(dr.FreeBytes))
		    Listbox1.CellTag(Listbox1.LastIndex, 3) = dr.Totalbytes
		    Listbox1.CellTag(Listbox1.LastIndex, 4) = dr.FreeBytes
		    
		    total = dr.Totalbytes \ 1000
		    free = dr.FreeBytes \ 1000
		    'If total <= 0 Then Listbox1.Cell(Listbox1.LastIndex, 1) = "(No Disk)"
		    Listbox1.RowTag(Listbox1.LastIndex) = 100 - (free * 100 / total)
		  Next
		  
		  //debug("Rowheight: " + Str())
		  If Listbox1.RowHeight * (Listbox1.LastIndex * 2) > 70 Then
		    Self.Height = Listbox1.RowHeight * (Listbox1.LastIndex * 2)
		  End If
		  
		End Sub
	#tag EndEvent


#tag EndWindowCode

#tag Events Listbox1
	#tag Event
		Function CellBackgroundPaint(g As Graphics, row As Integer, column As Integer) As Boolean
		  If row Mod 2=0 then
		    g.foreColor= &cC0C0C0
		  else
		    g.foreColor= &c9E9E9E
		  end if
		  g.FillRect 0,0,g.width,g.height
		  
		  
		  Try
		    #pragma BreakOnExceptions Off
		    Dim perc As Integer = Me.RowTag(row)
		    g.ForeColor = &c808080
		    Select Case column
		    Case 0
		      perc = perc * 100 \ 10
		      Dim p As New Picture(g.Width, g.Height, 24)
		      If row Mod 2=0 then
		        p.Graphics.foreColor= &cC0C0C0
		      else
		        p.Graphics.foreColor= &c9E9E9E
		      end if
		      p.Graphics.FillRect(0, 0, p.Width, p.Height)
		      DrawBar(p, perc, row)
		      g.DrawPicture(p, 0, 0)
		      //g.FillRect(0, 0, perc, g.Height)
		    Case 1
		      If perc > 10 Then
		        perc = perc - 10
		        perc = perc * 100 \ 25
		        Dim p As New Picture(g.Width, g.Height, 24)
		        If row Mod 2=0 then
		          p.Graphics.foreColor= &cC0C0C0
		        else
		          p.Graphics.foreColor= &c9E9E9E
		        end if
		        p.Graphics.FillRect(0, 0, p.Width, p.Height)
		        DrawBar(p, perc, row)
		        g.DrawPicture(p, 0, 0)
		        //g.FillRect(0, 0, perc, g.Height)
		        
		      End If
		    Case 2
		      If perc > 35 Then
		        perc = perc - 35
		        perc = perc * 100 \ 10
		        Dim p As New Picture(g.Width, g.Height, 24)
		        If row Mod 2=0 then
		          p.Graphics.foreColor= &cC0C0C0
		        else
		          p.Graphics.foreColor= &c9E9E9E
		        end if
		        p.Graphics.FillRect(0, 0, p.Width, p.Height)
		        DrawBar(p, perc, row)
		        g.DrawPicture(p, 0, 0)
		        //g.FillRect(0, 0, perc, g.Height)
		      End If
		    Case 3
		      If perc > 45 Then
		        perc = perc - 45
		        perc = perc * 100 \ 27
		        Dim p As New Picture(g.Width, g.Height, 24)
		        If row Mod 2=0 then
		          p.Graphics.foreColor= &cC0C0C0
		        else
		          p.Graphics.foreColor= &c9E9E9E
		        end if
		        p.Graphics.FillRect(0, 0, p.Width, p.Height)
		        DrawBar(p, perc, row)
		        g.DrawPicture(p, 0, 0)
		        //g.FillRect(0, 0, perc, g.Height)
		      End If
		    Case 4
		      If perc > 72 Then
		        perc = perc - 72
		        perc = perc * 100 \28
		        Dim p As New Picture(g.Width, g.Height, 24)
		        If row Mod 2=0 then
		          p.Graphics.foreColor= &cC0C0C0
		        else
		          p.Graphics.foreColor= &c9E9E9E
		        end if
		        p.Graphics.FillRect(0, 0, p.Width, p.Height)
		        DrawBar(p, perc, row)
		        g.DrawPicture(p, 0, 0)
		        //g.FillRect(0, 0, perc, g.Height)
		      End If
		      
		    End Select
		  Catch OutOfBoundsException
		    Return False
		  End Try
		  Return True
		End Function
	#tag EndEvent
	#tag Event
		Sub DoubleClick()
		  DriveDetail.ShowMe(Me.Cell(Me.ListIndex, 0))
		  '
		  '
		  'Dim f As FolderItem = GetFolderItem()
		  'f.Launch
		End Sub
	#tag EndEvent
	#tag Event
		Sub KeyUp(Key As String)
		  If Asc(Key) = &h0D Then
		    Dim f As FolderItem = GetFolderItem(Me.Cell(Me.ListIndex, 0))
		    f.Launch
		  End If
		End Sub
	#tag EndEvent
	#tag Event
		Function CompareRows(row1 as Integer, row2 as Integer, column as Integer, ByRef result as Integer) As Boolean
		  If column = 3 Or column = 4 Then
		    Dim r1, r2 As UInt64
		    r1 = Me.CellTag(row1, column)
		    r2 = Me.CellTag(row2, column)
		    If r1 > r2 Then
		      result =  1
		    ElseIf r2 > r1 Then
		      result =  -1
		    Else
		      result =  0
		    End If
		    Return True
		  End If
		End Function
	#tag EndEvent
#tag EndEvents
#tag Events PushButton1
	#tag Event
		Sub Action()
		  Self.Close
		End Sub
	#tag EndEvent
#tag EndEvents
