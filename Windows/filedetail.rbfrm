#tag Window
Begin Window filedetail
   BackColor       =   &h003F3F3F
   Backdrop        =   ""
   CloseButton     =   True
   Composite       =   False
   Frame           =   0
   FullScreen      =   False
   HasBackColor    =   False
   Height          =   274
   ImplicitInstance=   True
   LiveResize      =   True
   MacProcID       =   0
   MaxHeight       =   32000
   MaximizeButton  =   False
   MaxWidth        =   32000
   MenuBar         =   ""
   MenuBarVisible  =   True
   MinHeight       =   64
   MinimizeButton  =   False
   MinWidth        =   64
   Placement       =   3
   Resizeable      =   False
   Title           =   "File"
   Visible         =   True
   Width           =   424
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
      Height          =   274
      HelpTag         =   ""
      Hierarchical    =   ""
      Index           =   -2147483648
      InitialParent   =   ""
      InitialValue    =   "Key	Value"
      Italic          =   ""
      Left            =   0
      LockBottom      =   ""
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   ""
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
      Width           =   424
      _ScrollWidth    =   -1
   End
   Begin PushButton PushButton1
      AutoDeactivate  =   True
      Bold            =   ""
      ButtonStyle     =   0
      Cancel          =   True
      Caption         =   "Untitled"
      Default         =   True
      Enabled         =   True
      Height          =   22
      HelpTag         =   ""
      Index           =   -2147483648
      InitialParent   =   ""
      Italic          =   ""
      Left            =   492
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
      Top             =   -57
      Underline       =   ""
      Visible         =   True
      Width           =   80
   End
End
#tag EndWindow

#tag WindowCode
	#tag Method, Flags = &h0
		Sub showMeFile(f As FolderItem)
		  Me.Title = "File Detail: " + prettifyPath(f.AbsolutePath)
		  Listbox1.DeleteAllRows
		  Listbox1.AddRow("Path", f.AbsolutePath)
		  Listbox1.AddRow("Size", prettifyBytes(f.Length))
		  
		  Dim verinfo As Dictionary = f.VersionInfo
		  If verinfo <> Nil Then
		    For i As Integer = 0 To verinfo.Count - 1
		      Listbox1.AddRow(verinfo.Key(i), verinfo.Value(verinfo.Key(i)))
		    Next
		  End If
		  Self.Icon = GetIco(f, 16)
		  
		  
		  If f.Archive Then
		    Listbox1.AddRow("Marked For Archiving", "Yes")
		  Else
		    Listbox1.AddRow("Marked For Archiving", "No")
		  End If
		  
		  
		  If f.Compressed Then
		    Listbox1.AddRow("Compressed", "Yes")
		  Else
		    Listbox1.AddRow("Compressed", "No")
		  End If
		  
		  If f.Encrypted Then
		    Listbox1.AddRow("Encrypted", "Yes")
		  Else
		    Listbox1.AddRow("Encrypted", "No")
		  End If
		  
		  Listbox1.AddRow("Shortpath", f.GetShortName)
		  
		  If f.Hidden Then
		    Listbox1.AddRow("Hidden", "Yes")
		  Else
		    Listbox1.AddRow("Hidden", "No")
		  End If
		  
		  If f.SystemFile Then
		    Listbox1.AddRow("System File", "Yes")
		  Else
		    Listbox1.AddRow("System File", "No")
		  End If
		  
		  If f.ReadOnly Then
		    Listbox1.AddRow("Readonly", "Yes")
		  Else
		    Listbox1.AddRow("Read Only", "No")
		  End If
		  
		  Listbox1.AddRow("Data Stream Count", Str(f.StreamCount))
		  
		  
		  
		  Self.Show
		  
		End Sub
	#tag EndMethod


#tag EndWindowCode

#tag Events PushButton1
	#tag Event
		Sub Action()
		  Self.Close
		End Sub
	#tag EndEvent
#tag EndEvents
