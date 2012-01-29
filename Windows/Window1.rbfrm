#tag Window
Begin Window Window1
   BackColor       =   255
   Backdrop        =   ""
   CloseButton     =   True
   Composite       =   False
   Frame           =   0
   FullScreen      =   False
   HasBackColor    =   False
   Height          =   609
   ImplicitInstance=   True
   LiveResize      =   True
   MacProcID       =   0
   MaxHeight       =   32000
   MaximizeButton  =   True
   MaxWidth        =   32000
   MenuBar         =   207276031
   MenuBarVisible  =   True
   MinHeight       =   64
   MinimizeButton  =   True
   MinWidth        =   64
   Placement       =   0
   Resizeable      =   True
   Title           =   "VisiProc"
   Visible         =   True
   Width           =   1015
   Begin dragContainer dragContainer1
      AcceptFocus     =   ""
      AcceptTabs      =   ""
      AutoDeactivate  =   True
      BackColor       =   8421504
      Backdrop        =   ""
      DoubleBuffer    =   False
      Enabled         =   True
      EraseBackground =   True
      FPS             =   0
      Height          =   589
      HelpTag         =   ""
      Index           =   -2147483648
      InitialParent   =   ""
      lastSort        =   -1
      Left            =   0
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   True
      Scope           =   0
      TabIndex        =   0
      TabPanelIndex   =   0
      TabStop         =   True
      Top             =   0
      UseFocusRing    =   True
      Visible         =   True
      Width           =   1015
   End
   Begin Timer Timer1
      Height          =   32
      Index           =   -2147483648
      Left            =   1086
      LockedInPosition=   False
      Mode            =   2
      Period          =   1000
      Scope           =   0
      TabIndex        =   1
      TabPanelIndex   =   0
      TabStop         =   True
      Top             =   -6
      Width           =   32
   End
   Begin Label Status
      AutoDeactivate  =   True
      Bold            =   ""
      DataField       =   ""
      DataSource      =   ""
      Enabled         =   True
      Height          =   20
      HelpTag         =   ""
      Index           =   -2147483648
      InitialParent   =   ""
      Italic          =   ""
      Left            =   0
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   False
      Multiline       =   ""
      Scope           =   0
      Selectable      =   False
      TabIndex        =   1
      TabPanelIndex   =   0
      TabStop         =   True
      Text            =   ""
      TextAlign       =   0
      TextColor       =   0
      TextFont        =   "System"
      TextSize        =   0
      TextUnit        =   0
      Top             =   589
      Transparent     =   False
      Underline       =   ""
      Visible         =   True
      Width           =   507
   End
   Begin Label Status1
      AutoDeactivate  =   True
      Bold            =   ""
      DataField       =   ""
      DataSource      =   ""
      Enabled         =   True
      Height          =   20
      HelpTag         =   ""
      Index           =   -2147483648
      InitialParent   =   ""
      Italic          =   ""
      Left            =   508
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   False
      Multiline       =   ""
      Scope           =   0
      Selectable      =   False
      TabIndex        =   2
      TabPanelIndex   =   0
      TabStop         =   True
      Text            =   ""
      TextAlign       =   2
      TextColor       =   0
      TextFont        =   "System"
      TextSize        =   0
      TextUnit        =   0
      Top             =   589
      Transparent     =   False
      Underline       =   ""
      Visible         =   True
      Width           =   507
   End
End
#tag EndWindow

#tag WindowCode
	#tag Event
		Function KeyDown(Key As String) As Boolean
		  If Asc(key) = &hCC Then
		    Count = 0
		  ElseIf Asc(key) = &hD2 Then
		    Self.FullScreen = Not Self.FullScreen
		  End If
		End Function
	#tag EndEvent

	#tag Event
		Sub Open()
		  Me.Maximize
		  Dim mi As New ThrottleMenu("Throttle Drawing")
		  mi.Checked = True
		  Me.MenuBar.Item(0).Append(mi)
		End Sub
	#tag EndEvent


	#tag MenuHandler
		Function alphaSortMenu() As Boolean Handles alphaSortMenu.Action
			dragContainer1.Arrange(1)
			Return True
			
		End Function
	#tag EndMenuHandler

	#tag MenuHandler
		Function arrangeMenu() As Boolean Handles arrangeMenu.Action
			dragContainer1.Arrange()
			Return True
			
		End Function
	#tag EndMenuHandler

	#tag MenuHandler
		Function dissarrayMenu() As Boolean Handles dissarrayMenu.Action
			dragContainer1.Arrange(3)
			Return True
			
		End Function
	#tag EndMenuHandler

	#tag MenuHandler
		Function hideSystemMenu() As Boolean Handles hideSystemMenu.Action
			
			HideSystemProcs = Not HideSystemProcs
			'dragContainer1.Empty
			'FirstRun = True
			'dragContainer1.Update(True)
			'dragContainer1.Arrange(dragContainer1.lastSort)
			dragContainer1.ToggleSystem
			Return True
			
		End Function
	#tag EndMenuHandler

	#tag MenuHandler
		Function hilightingmenu() As Boolean Handles hilightingmenu.Action
			'HilightOn = Not HilightOn
			'dragContainer1.Empty
			'FirstRun = True
			'dragContainer1.Update(True)
			'dragContainer1.Arrange(dragContainer1.lastSort)
			dragContainer1.ToggleHilight
			Return True
			
		End Function
	#tag EndMenuHandler

	#tag MenuHandler
		Function procIDSortMenu() As Boolean Handles procIDSortMenu.Action
			dragContainer1.Arrange(2)
			Return True
			
		End Function
	#tag EndMenuHandler

	#tag MenuHandler
		Function SetBackColor() As Boolean Handles SetBackColor.Action
			Dim c As Color
			If SelectColor(c, "Choose a Color") Then
			dragContainer1.BackColor = c
			dragContainer1.Refresh(False)
			End If
			Return True
			
		End Function
	#tag EndMenuHandler

	#tag MenuHandler
		Function SetBackdrop() As Boolean Handles SetBackdrop.Action
			Dim f As FolderItem = GetOpenFolderItem(FileTypes1.ImageFile)
			If f <> Nil Then
			dragContainer1.Background = Picture.Open(f)
			dragContainer1.Refresh(False)
			End If
			Return True
			
		End Function
	#tag EndMenuHandler

	#tag MenuHandler
		Function ToggleAutoArrange() As Boolean Handles ToggleAutoArrange.Action
			If dragContainer1.lastSort > -1 Then
			dragContainer1.lastSort = -1
			Else
			dragContainer1.lastSort = 0
			End If
			Return True
			
		End Function
	#tag EndMenuHandler

	#tag MenuHandler
		Function ToggleDebugMenu() As Boolean Handles ToggleDebugMenu.Action
			dragContainer1.ToggleDebug
			Return True
			
		End Function
	#tag EndMenuHandler


	#tag Property, Flags = &h0
		AutoArrange As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		Count As Integer
	#tag EndProperty


#tag EndWindowCode

#tag Events Timer1
	#tag Event
		Sub Action()
		  PollCPU()
		  If DebugMode Then PollDebug()
		  If count Mod 25 = 0 Then PollDisks()
		  dragContainer1.DynUpdate()
		  dragContainer1.Update()
		  count = count + 1
		  Status.Text = "Showing: " + Str((UBound(activeProcesses) + 1) - (dragContainer1.sysProcs.Ubound + 1)) + " of " + Str(UBound(activeProcesses) + 1) + " running processes."
		  FirstRun = False
		  lastFPS = dragContainer1.FPS
		  dragContainer1.FPS = 0
		  Dim d As New Date
		  Status1.Text = d.LongDate + " " + d.LongTime + "   "
		End Sub
	#tag EndEvent
#tag EndEvents
