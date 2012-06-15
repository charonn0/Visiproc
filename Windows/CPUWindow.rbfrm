#tag Window
Begin Window CPUWindow
   BackColor       =   16711680
   Backdrop        =   ""
   CloseButton     =   True
   Composite       =   False
   Frame           =   3
   FullScreen      =   False
   HasBackColor    =   False
   Height          =   292
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
   Title           =   "CPU"
   Visible         =   True
   Width           =   366
   Begin Canvas Canvas2
      AcceptFocus     =   ""
      AcceptTabs      =   ""
      AutoDeactivate  =   True
      Backdrop        =   ""
      DoubleBuffer    =   False
      Enabled         =   True
      EraseBackground =   True
      Height          =   32
      HelpTag         =   ""
      Index           =   -2147483648
      InitialParent   =   ""
      Left            =   0
      LockBottom      =   ""
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   ""
      LockTop         =   True
      Scope           =   0
      TabIndex        =   2
      TabPanelIndex   =   0
      TabStop         =   True
      Top             =   0
      UseFocusRing    =   True
      Visible         =   True
      Width           =   32
   End
   Begin Listbox Listbox1
      AutoDeactivate  =   True
      AutoHideScrollbars=   True
      Bold            =   ""
      Border          =   True
      ColumnCount     =   1
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
      HasHeading      =   ""
      HeadingIndex    =   -1
      Height          =   170
      HelpTag         =   ""
      Hierarchical    =   ""
      Index           =   -2147483648
      InitialParent   =   ""
      InitialValue    =   ""
      Italic          =   ""
      Left            =   36
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
      TabIndex        =   3
      TabPanelIndex   =   0
      TabStop         =   True
      TextFont        =   "System"
      TextSize        =   0
      TextUnit        =   0
      Top             =   0
      Underline       =   ""
      UseFocusRing    =   True
      Visible         =   True
      Width           =   330
      _ScrollWidth    =   -1
   End
   Begin ProgBar PageFile
      AcceptFocus     =   ""
      AcceptTabs      =   ""
      AutoDeactivate  =   True
      barColor        =   16776960
      barWell         =   12632256
      bold            =   True
      boxColor        =   0
      DoubleBuffer    =   ""
      Enabled         =   True
      EraseBackground =   ""
      gradientEnd     =   8421376
      hasBox          =   True
      hasGradient     =   True
      hasText         =   True
      Height          =   25
      HelpTag         =   ""
      Index           =   -2147483648
      InitialParent   =   ""
      italic          =   False
      Left            =   6
      LockBottom      =   ""
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   ""
      LockTop         =   True
      maximum         =   100
      PreText         =   "Page File:"
      Scope           =   0
      TabIndex        =   4
      TabPanelIndex   =   0
      TabStop         =   True
      textColor       =   0
      textFont        =   "System"
      textFormat      =   "###.00\\%"
      textSize        =   0
      Top             =   182
      underline       =   False
      UseFocusRing    =   True
      value           =   0
      value1          =   ""
      Visible         =   True
      Width           =   354
   End
   Begin ProgBar ram
      AcceptFocus     =   ""
      AcceptTabs      =   ""
      AutoDeactivate  =   True
      barColor        =   16776960
      barWell         =   12632256
      bold            =   True
      boxColor        =   0
      DoubleBuffer    =   ""
      Enabled         =   True
      EraseBackground =   ""
      gradientEnd     =   16384
      hasBox          =   True
      hasGradient     =   True
      hasText         =   True
      Height          =   25
      HelpTag         =   ""
      Index           =   -2147483648
      InitialParent   =   ""
      italic          =   False
      Left            =   6
      LockBottom      =   ""
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   ""
      LockTop         =   True
      maximum         =   100
      PreText         =   "Physical Memory: "
      Scope           =   0
      TabIndex        =   5
      TabPanelIndex   =   0
      TabStop         =   True
      textColor       =   0
      textFont        =   "System"
      textFormat      =   "###.00\\%"
      textSize        =   0
      Top             =   219
      underline       =   False
      UseFocusRing    =   True
      value           =   0
      value1          =   ""
      Visible         =   True
      Width           =   354
   End
   Begin ProgBar cpu
      AcceptFocus     =   ""
      AcceptTabs      =   ""
      AutoDeactivate  =   True
      barColor        =   65280
      barWell         =   12632256
      bold            =   True
      boxColor        =   0
      DoubleBuffer    =   ""
      Enabled         =   True
      EraseBackground =   ""
      gradientEnd     =   0
      hasBox          =   True
      hasGradient     =   True
      hasText         =   True
      Height          =   25
      HelpTag         =   ""
      Index           =   -2147483648
      InitialParent   =   ""
      italic          =   False
      Left            =   6
      LockBottom      =   ""
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   ""
      LockTop         =   True
      maximum         =   100
      PreText         =   "CPU: "
      Scope           =   0
      TabIndex        =   6
      TabPanelIndex   =   0
      TabStop         =   True
      textColor       =   0
      textFont        =   "System"
      textFormat      =   "###.00\\%"
      textSize        =   0
      Top             =   256
      underline       =   False
      UseFocusRing    =   True
      value           =   0
      value1          =   ""
      Visible         =   True
      Width           =   354
   End
   Begin Timer Timer1
      Enabled         =   True
      Height          =   32
      Index           =   -2147483648
      Left            =   486
      LockedInPosition=   False
      Mode            =   2
      Period          =   1250
      Scope           =   0
      TabIndex        =   5
      TabPanelIndex   =   0
      TabStop         =   True
      Top             =   85
      Visible         =   True
      Width           =   32
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
      Left            =   517
      LockBottom      =   ""
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   ""
      LockTop         =   True
      Scope           =   0
      TabIndex        =   7
      TabPanelIndex   =   0
      TabStop         =   True
      TextFont        =   "System"
      TextSize        =   0
      TextUnit        =   0
      Top             =   -48
      Underline       =   ""
      Visible         =   True
      Width           =   80
   End
End
#tag EndWindow

#tag WindowCode
	#tag Event
		Sub Open()
		  UpdateCPU
		  UpdatePF
		  UpdateRAM
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h21
		Private Sub UpdateCPU()
		  Dim x() As Double
		  x = CPUUsage
		  cpu.value = x(0)
		  cpu.value1 = x(1)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub UpdatePF()
		  Dim x, y As UInt64
		  x = Platform.TotalPageFile
		  y = Platform.AvailablePageFile
		  Dim d As Double
		  d = 100 - (y * 100 / x)
		  
		  If d > 85 Then
		    PageFile.barColor = &cFF0000  //Red
		    PageFile.gradientEnd = &c800000
		  ElseIf d > 70 And d < 85 Then
		    //>= 85 And perc < 95 Then
		    PageFile.barcolor = &cFFFF00  //Yellow
		    PageFile.gradientEnd = &c808000
		  Else
		    PageFile.barcolor = &c00FF00
		    PageFile.gradientEnd = &c00240000
		  End If
		  
		  
		  
		  PageFile.value = d
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub UpdateRAM()
		  Dim x, y As UInt64
		  x = Platform.TotalPhysicalRAM
		  y = Platform.AvailablePhysicalRAM
		  Dim d As Double
		  d = 100 - (y * 100 / x)
		  
		  If d > 85 Then
		    ram.barColor = &cFF0000  //Red
		    ram.gradientEnd = &c800000
		  ElseIf d > 70 And d < 85 Then
		    //>= 85 And perc < 95 Then
		    ram.barcolor = &cFFFF00  //Yellow
		    ram.gradientEnd = &c808000
		  Else
		    ram.barcolor = &c00FF00
		    ram.gradientEnd = &c00240000//&c009B4E
		  End If
		  
		  
		  
		  ram.value = d
		End Sub
	#tag EndMethod


#tag EndWindowCode

#tag Events Canvas2
	#tag Event
		Sub Paint(g As Graphics)
		  Dim p As Picture = GetWindowsIcon()
		  If p <> Nil Then
		    g.DrawPicture(p, 0, 0)
		  End If
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events Listbox1
	#tag Event
		Sub Open()
		  Me.AddRow(Platform.VersionString)
		  Me.AddRow(Platform.ProcessorName + " (x" + Str(Platform.NumberOfProcessors) + ")")
		  Me.AddRow(prettifyBytes(Platform.TotalPhysicalRAM) + " of Physical Memory")
		  Dim mb As String = Platform.MotherboardManufacturer + " " + Platform.MotherboardModel + " " + Platform.MotherboardModelRevision
		  Me.AddRow("Motherboard: " + mb)
		  Me.AddRow("BIOS: " + Platform.BIOSVendor + " " + Platform.BIOSVersion + " (" + Platform.BIOSDate + ")")
		  Me.AddRow("Total Pagefile: " + prettifyBytes(Platform.TotalPageFile) + "; Available Pagefile: "+ prettifyBytes(Platform.AvailablePageFile))
		  Me.AddRow("Total Address Space For This Program: " + prettifyBytes(Platform.TotalProcessAddressSpace))
		  Me.AddRow("Available Address Space For This Program: " + prettifyBytes(Platform.AvailableProcessAddressSpace))
		  Me.AddRow("Public IP Address:" + Platform.PublicIP)
		  'Me.AddRow(Platform.OEM)
		End Sub
	#tag EndEvent
	#tag Event
		Function CellBackgroundPaint(g As Graphics, row As Integer, column As Integer) As Boolean
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
		  Static ne As Boolean
		  UpdateCPU
		  UpdatePF
		  UpdateRAM
		  
		  If Not ne Then
		    cpu.textFormat = "###.00\%"
		    ram.textFormat = "###.00\%"
		    PageFile.textFormat = "###.00\%"
		    cpu.Refresh
		    ram.Refresh
		    PageFile.Refresh
		    ne = True
		  End If
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events PushButton1
	#tag Event
		Sub Action()
		  Self.Close
		End Sub
	#tag EndEvent
#tag EndEvents
