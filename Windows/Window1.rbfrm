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
      Backdrop        =   ""
      DoubleBuffer    =   False
      Enabled         =   True
      EraseBackground =   True
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
      TabPanelIndex   =   0
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
      Width           =   1015
   End
End
#tag EndWindow

#tag WindowCode
	#tag Event
		Function KeyDown(Key As String) As Boolean
		  If Asc(key) = &hCC Then
		    Count = 0
		  End If
		End Function
	#tag EndEvent

	#tag Event
		Sub Open()
		  Me.Maximize
		  'Dim f As FolderItem = SpecialFolder.Pictures
		  'For i As Integer = 1 To 10
		  'Dim p As Picture
		  'Dim d As FolderItem = f.Item(i)
		  'If Not d.Directory Then
		  'If NthField(d.Name, ".", CountFields(d.Name, ".")) = "png" Or NthField(d.Name, ".", CountFields(d.Name, ".")) = "bmp" Or NthField(d.Name, ".", CountFields(d.Name, ".")) = "jpg" Then
		  'p = p.Open(d)
		  'Dim no As New dragObject(p)
		  'dragContainer1.addObject(no)
		  'End If
		  'End If
		  'Next
		  '
		  'Exception
		  'Return
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
		Function defaultSortMenu() As Boolean Handles defaultSortMenu.Action
			dragContainer1.Arrange(0)
			Return True
			
		End Function
	#tag EndMenuHandler

	#tag MenuHandler
		Function hideSystemMenu() As Boolean Handles hideSystemMenu.Action
			HideSystemProcs = Not HideSystemProcs
			dragContainer1.Empty
			FirstRun = True
			dragContainer1.Update(True)
			dragContainer1.Arrange(dragContainer1.lastSort)
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
		  dragContainer1.Update(count Mod 5 = 0)
		  count = count + 1
		  Status.Text = Str(UBound(activeProcesses) + 1) + " running processes."
		  FirstRun = False
		End Sub
	#tag EndEvent
#tag EndEvents
