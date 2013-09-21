#tag Window
Begin Window Window1
   BackColor       =   16711680
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
      DoubleBuffer    =   True
      DropIndex       =   -1
      Enabled         =   True
      EraseBackground =   False
      FPS             =   0
      Height          =   589
      HelpTag         =   ""
      HiddenProcCount =   0
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
      ShowText        =   True
      TabIndex        =   0
      TabPanelIndex   =   0
      TabStop         =   True
      Top             =   0
      UseFocusRing    =   True
      Visible         =   True
      Width           =   1015
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
      Text            =   ""
      TextAlign       =   0
      TextColor       =   0
      TextFont        =   "System"
      TextSize        =   0
      TextUnit        =   0
      Top             =   589
      Transparent     =   True
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
      Text            =   ""
      TextAlign       =   2
      TextColor       =   0
      TextFont        =   "System"
      TextSize        =   0
      TextUnit        =   0
      Top             =   589
      Transparent     =   True
      Underline       =   ""
      Visible         =   True
      Width           =   507
   End
   Begin Timer Timer1
      Height          =   32
      Index           =   -2147483648
      Left            =   1054
      LockedInPosition=   False
      Mode            =   2
      Period          =   1
      Scope           =   0
      TabPanelIndex   =   0
      Top             =   -14
      Width           =   32
   End
   Begin Timer WildTimer
      Height          =   32
      Index           =   -2147483648
      Left            =   1054
      LockedInPosition=   False
      Mode            =   0
      Period          =   100
      Scope           =   0
      TabPanelIndex   =   0
      Top             =   30
      Width           =   32
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
		  ElseIf Key = "=" Then
		    For i As Integer = 0 To UBound(Window1.dragContainer1.objects)
		      Window1.dragContainer1.objects(i).ResizeTo = Window1.dragContainer1.objects(i).ResizeTo + 5
		    Next
		  ElseIf Key = "-" Then
		    For i As Integer = 0 To UBound(Window1.dragContainer1.objects)
		      Window1.dragContainer1.objects(i).ResizeTo = Window1.dragContainer1.objects(i).ResizeTo - 5
		    Next
		  End If
		End Function
	#tag EndEvent

	#tag Event
		Sub Open()
		  Me.Maximize
		  'Dim mi As New ThrottleMenu("Throttle Drawing")
		  'mi.Checked = True
		  'Me.MenuBar.Item(0).Append(mi)
		  
		  Dim perc As New MenuItem("Resize Tiles")
		  perc.Append(New PercentMenu("10%"))
		  perc.Append(New PercentMenu("20%"))
		  perc.Append(New PercentMenu("30%"))
		  perc.Append(New PercentMenu("40%"))
		  perc.Append(New PercentMenu("50%"))
		  perc.Append(New PercentMenu("60%"))
		  perc.Append(New PercentMenu("70%"))
		  perc.Append(New PercentMenu("80%"))
		  perc.Append(New PercentMenu("90%"))
		  Dim onehundred As New PercentMenu("100%")
		  onehundred.Checked = True
		  perc.Append(onehundred)
		  'perc.Append(New PercentMenu("110%"))
		  'perc.Append(New PercentMenu("120%"))
		  'perc.Append(New PercentMenu("130%"))
		  'perc.Append(New PercentMenu("140%"))
		  'perc.Append(New PercentMenu("150%"))
		  Me.MenuBar.Item(0).Insert(1,perc)
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
			dragContainer1.lastSort = 0
			dragContainer1.Arrange(3)
			Return True
			
		End Function
	#tag EndMenuHandler

	#tag MenuHandler
		Function hideDynamic() As Boolean Handles hideDynamic.Action
			hideDynamics = Not hideDynamics
			dragContainer1.Arrange(dragContainer1.lastSort)
			dragContainer1.Refresh(False)
			Return True
			
		End Function
	#tag EndMenuHandler

	#tag MenuHandler
		Function hideSystemMenu() As Boolean Handles hideSystemMenu.Action
			HideSystemProcs = Not HideSystemProcs
			dragContainer1.ToggleSystem
			Return True
			
		End Function
	#tag EndMenuHandler

	#tag MenuHandler
		Function hilightingmenu() As Boolean Handles hilightingmenu.Action
			dragContainer1.ToggleHilight()
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
		Function setts() As Boolean Handles setts.Action
			setswin.Show
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

	#tag MenuHandler
		Function unhidemenu() As Boolean Handles unhidemenu.Action
			dragContainer1.ToggleHidden()
			Return True
			
		End Function
	#tag EndMenuHandler

	#tag MenuHandler
		Function wildmode() As Boolean Handles wildmode.Action
			If WildTimer.Mode = Timer.ModeOff Then
			WildTimer.Mode = Timer.ModeMultiple
			Else
			WildTimer.Mode = Timer.ModeOff
			End If
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
		  If Window1.count Mod 25 = 0 Then PollDisks()
		  If DebugMode Then PollDebug()
		  Window1.dragContainer1.Update()
		  Window1.count = Window1.count + 1
		  lastFPS = Window1.dragContainer1.FPS
		  Window1.dragContainer1.FPS = 0
		  Dim d As New Date
		  Window1.Status1.Text = d.LongDate + " " + d.LongTime + "   "
		  Window1.Status.Text = "Showing: " + Str((UBound(activeProcesses) + 1) - (Window1.dragContainer1.HiddenProcCount)) + " of " + Str(UBound(activeProcesses) + 1) + " running processes."
		  Init = False
		  Me.Period = 500
		  If CPUThread.State = Thread.NotRunning Then CPUThread.Run
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events WildTimer
	#tag Event
		Sub Action()
		  dragContainer1.lastSort = 0
		  dragContainer1.Arrange(4)
		End Sub
	#tag EndEvent
#tag EndEvents
