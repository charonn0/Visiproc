#tag Module
Protected Module Globals
	#tag Method, Flags = &h21
		Private Sub drawBack(ByRef Buffer As Picture)
		  Buffer.Graphics.ForeColor = &c000000
		  Buffer.Graphics.FillRect(0, 0, Buffer.Width, Buffer.Height)
		  Buffer.Graphics.ForeColor = &c008000
		  For i As Integer = 0 To Buffer.Width Step 10
		    Buffer.Graphics.DrawLine(i, 0, i, Buffer.Height)
		  Next
		  For i As Integer = 0 To Buffer.Height Step 10
		    Buffer.Graphics.DrawLine(0, i, Buffer.Width, i)
		  Next
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DrawBar(ByRef p As Picture, width As Integer, therow As Integer = - 1)
		  Dim myHeight, myWidth As Integer
		  myHeight = p.Height
		  myWidth = p.Width
		  Dim barcolor, gradientEnd As Color
		  Dim perc As Integer = width * 100 / p.Width
		  
		  If therow <> -1 Then
		    barcolor = &c00FF00
		    gradientEnd = &c009B4E
		  ElseIf perc > 85 Then
		    barcolor = &cFF0000  //Red
		    gradientEnd = &c800000
		  ElseIf perc > 70 And perc < 85 Then
		    //>= 85 And perc < 95 Then
		    barcolor = &cFFFF00  //Yellow
		    gradientEnd = &c808000
		  Else
		    barcolor = &c00FF00
		    gradientEnd = &c009B4E
		  End If
		  
		  Dim ratio, endratio as Double
		  For i As Integer = 0 To p.Height
		    ratio = ((p.Graphics.Height - i) / p.Graphics.Height)
		    endratio = (i / p.Graphics.Height)
		    p.Graphics.ForeColor = RGB(gradientEnd.Red * endratio + barColor.Red * ratio, gradientEnd.Green * endratio + barColor.Green * ratio, _
		    gradientEnd.Blue * endratio + barColor.Blue * ratio)
		    p.Graphics.DrawLine(0, i, width, i)
		  next
		  p.Graphics.ForeColor = barColor
		  p.Graphics.DrawLine(0, 0, Width, 0)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetWindowsIcon() As Picture
		  Static p As Picture
		  If p = Nil Then
		    Dim f As FolderItem = SpecialFolder.System.Child("winver.exe")
		    If f <> Nil Then
		      If f.Exists And f.AbsolutePath <> App.ExecutableFile.AbsolutePath Then
		        p = GetIco(f, 32)
		      End If
		    End If
		  End If
		  
		  Return p
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PollCPU()
		  #pragma BreakOnExceptions Off
		  Dim times() As Double = CPUUsage
		  Dim lines() As Integer
		  lines.Append(times(0) * 150 / 100)
		  lines.Append((times(1) * 150 / 100))
		  //lines.Append(0)
		  lastCPU(0) = times(0)
		  lastCPU(1) = times(1)
		  lines.Append(LastMem)
		  Static history(), history1(), history2() As Integer
		  
		  
		  CPUBuffer = New Picture(250, 150, 24)
		  drawBack(CPUBuffer)
		  CPUBuffer.Graphics.ForeColor = &c00FF00
		  If UBound(history) * 10 >= 250 Then
		    history.Remove(0)
		    history1.Remove(0)
		    history2.Remove(0)
		  End If
		  
		  CPUBuffer.Graphics.ForeColor = &c00FF00
		  if lines(0) = 0 Then lines(0) = 1
		  history.Append(lines(0))
		  lastCPU = times
		  For i As Integer = 0 To UBound(history)
		    Try
		      CPUBuffer.Graphics.DrawLine(i * 10, 150 - history(i - 1), i * 10 + 10, 150 - history(i))
		    Catch OutOfBoundsException
		      CPUBuffer.Graphics.DrawLine(0, 150 - history(i), 10, 150 - history(i))
		    End Try
		  Next
		  
		  CPUBuffer.Graphics.ForeColor = &cF47A00
		  if lines(1) = 0 Then lines(1) = 1
		  history1.Append(lines(1))
		  
		  For i As Integer = 0 To UBound(history1)
		    Try
		      CPUBuffer.Graphics.DrawLine(i * 10, 150 - history1(i - 1), i * 10 + 10, 150 - history1(i))
		    Catch OutOfBoundsException
		      CPUBuffer.Graphics.DrawLine(0, 150 - history1(i), 10, 150 - history1(i))
		    End Try
		  Next
		  
		  CPUBuffer.Graphics.ForeColor = &cFFFF80
		  if lines(2) = 0 Then lines(2) = 1
		  history2.Append(lines(2))
		  
		  For i As Integer = 0 To UBound(history2)
		    Try
		      CPUBuffer.Graphics.DrawLine(i * 10, 150 - history2(i - 1), i * 10 + 10, 150 - history2(i))
		    Catch OutOfBoundsException
		      CPUBuffer.Graphics.DrawLine(0, 150 - history2(i), 10, 150 - history2(i))
		    End Try
		  Next
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PollDebug()
		  Dim drvs() As Picture
		  Dim requiredHeight, requiredWidth As Integer
		  Dim startat As Integer
		  If UBound(DebugLog) <= 10 Then
		    startat = 0
		  Else
		    startat = DebugLog.Ubound - 10
		  End If
		  For i As Integer = startat To DebugLog.Ubound
		    Try
		      Dim p As New Picture(250, 15, 24)
		      p.Graphics.ForeColor = &ccccccc
		      p.Graphics.FillRect(0, 0, p.Width, p.Height)
		      p.Graphics.ForeColor = &c0000FF00//&cFF0000
		      p.Graphics.TextFont = "System"
		      p.Graphics.TextSize = 10
		      Dim nm As String = Str(i) + ": " + DebugLog(i)
		      Dim strWidth, strHeight As Integer
		      strWidth = p.Graphics.StringWidth(nm)
		      strHeight = p.Graphics.StringHeight(nm, p.Width)
		      p.Graphics.DrawString(nm, 10, ((p.Height/2) + (strHeight/4)))
		      p.Graphics.ForeColor = &cFFFFFF
		      p.Graphics.DrawRect(1, 1, p.Width - 1, p.Height - 1)
		      drvs.Append(p)
		      requiredHeight = requiredHeight + p.Height
		      If p.Width > requiredWidth Then requiredWidth = p.Width
		    Catch NilObjectException
		      Continue
		    End Try
		  Next
		  
		  debugBuffer = New Picture(requiredWidth, requiredHeight, 24)
		  Dim x, y As Integer
		  For i As Integer = 0 To UBound(drvs)
		    debugBuffer.Graphics.DrawPicture(drvs(i), x, y)
		    y = y + drvs(i).Height
		  Next
		  debugBuffer.Graphics.ForeColor = &cFFFFFF
		  debugBuffer.Graphics.DrawRect(0, 0, debugBuffer.Width - 1, debugBuffer.Height - 1)
		  
		  If DebugLog.Ubound >= 1500 Then
		    ReDim DebugLog(-1)
		    DebugLog.Append("Recycle Debug Log")
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PollDisks()
		  Dim drvs() As Picture
		  Dim requiredHeight, requiredWidth As Integer
		  ReDim Drives(-1)
		  For i As Integer = 0 To VolumeCount - 1
		    Try
		      Dim f As New VolumeInformation(Volume(i).AbsolutePath)
		      Dim total, free As UInt64
		      total = f.Totalbytes \ 1000
		      free = f.FreeBytes \ 1000
		      Dim perc As Double = f.FreeBytes * 100 / f.Totalbytes
		      Dim p As New Picture(250, 15, 24)
		      p.Graphics.ForeColor = &ccccccc
		      p.Graphics.FillRect(0, 0, p.Width, p.Height)
		      If f.Filesystem = "CDFS" Then
		        DrawBar(p, (100 - perc) * p.Width / 100, 1)
		      Else
		        DrawBar(p, (100 - perc) * p.Width / 100)
		      End If
		      //p.Graphics.FillRect(0, 0, ((100 - perc) * p.Width / 100), p.Height)
		      p.Graphics.ForeColor = &c0000FF00//&cFF0000
		      p.Graphics.TextFont = "System"
		      p.Graphics.TextSize = 10
		      Dim nm As String = Volume(i).AbsolutePath
		      Dim strWidth, strHeight As Integer
		      strWidth = p.Graphics.StringWidth(nm)
		      strHeight = p.Graphics.StringHeight(nm, p.Width)
		      p.Graphics.DrawString(nm, p.Width - strWidth - 10, ((p.Height/2) + (strHeight/4)))
		      nm = f.Name
		      If nm = "" Then 
		        nm = "(No Name)"
		      End If
		      strWidth = p.Graphics.StringWidth(nm)
		      strHeight = p.Graphics.StringHeight(nm, p.Width)
		      p.Graphics.DrawString(nm, 10, ((p.Height/2) + (strHeight/4)))
		      
		      p.Graphics.ForeColor = &cFFFFFF
		      p.Graphics.DrawRect(1, 1, p.Width - 1, p.Height - 1)
		      drvs.Append(p)
		      f.PercentFull = perc
		      Drives.Append(f)
		      
		      requiredHeight = requiredHeight + p.Height
		      If p.Width > requiredWidth Then requiredWidth = p.Width
		    Catch NilObjectException
		      Continue
		    End Try
		  Next
		  
		  diskBuffer = New Picture(requiredWidth, requiredHeight, 24)
		  Dim x, y As Integer
		  For i As Integer = 0 To UBound(drvs)
		    diskBuffer.Graphics.DrawPicture(drvs(i), x, y)
		    y = y + drvs(i).Height
		  Next
		  diskBuffer.Graphics.ForeColor = &cFFFFFF
		  diskBuffer.Graphics.DrawRect(0, 0, diskBuffer.Width - 1, diskBuffer.Height - 1)
		  'Dim percent As Integer = free * 100 / total
		  'diskBuffer = New Picture(250, 150, 24)
		  'drawBack(DiskBuffer)
		  'DiskBuffer.Graphics.ForeColor = &c00FF00
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Volumes() As String
		  Declare Function FindFirstVolumeW Lib "Kernel32" (guid As Ptr, guidsize As Integer) As Integer
		  Declare Function FindNextVolumeW Lib "Kernel32" (fHandle As Integer, guid As Ptr, guidsize As Integer) As Boolean
		  Declare Function FindVolumeClose Lib "Kernel32" (fhandle As Integer) As Boolean
		  Declare Function GetVolumePathNamesForVolumeNameW Lib "Kernel32" (guid As Ptr, driveletter As Ptr, drivelettersize As Integer, ByRef retlen As Integer) As Boolean
		  Dim mb As New MemoryBlock(255)
		  Dim fHandle As Integer = FindFirstVolumeW(mb, mb.Size)
		  Dim s() As String
		  If fHandle > 0 Then
		    Dim bm As New MemoryBlock(255)
		    Dim retlen As Integer
		    If GetVolumePathNamesForVolumeNameW(mb, bm, bm.Size, retlen) Then
		      s.Append(bm.WString(0))
		    End If
		    While FindNextVolumeW(fHandle, mb, mb.size)
		      If GetVolumePathNamesForVolumeNameW(mb, bm, bm.Size, retlen) Then
		        s.Append(bm.WString(0))
		      End If
		    Wend
		  End If
		  Call FindVolumeClose(fHandle)
		  'Return s()
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		CPUBuffer As Picture
	#tag EndProperty

	#tag Property, Flags = &h0
		debugBuffer As Picture
	#tag EndProperty

	#tag Property, Flags = &h0
		debugcount As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		DebugLog() As String
	#tag EndProperty

	#tag Property, Flags = &h0
		DebugMode As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h0
		diskBuffer As Picture
	#tag EndProperty

	#tag Property, Flags = &h0
		Drives() As VolumeInformation
	#tag EndProperty

	#tag Property, Flags = &h0
		FirstRun As Boolean = True
	#tag EndProperty

	#tag Property, Flags = &h0
		HideSystemProcs As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		HilightOn As Boolean = True
	#tag EndProperty

	#tag Property, Flags = &h0
		lastCPU(3) As Double
	#tag EndProperty

	#tag Property, Flags = &h0
		lastFPS As Integer
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Dim x, y As UInt64
			  x = Platform.TotalPhysicalRAM
			  y = Platform.AvailablePhysicalRAM
			  Return 100 - (y * 100 / x)
			End Get
		#tag EndGetter
		LastMem As Double
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  If mmagImage = Nil Then
			    magImage = New Picture(250, 150, 24)
			    Dim runner As New Magnifyer
			    runner.Run
			  End If
			  Return mmagImage
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mmagImage = value
			End Set
		#tag EndSetter
		magImage As Picture
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private mmagImage As Picture
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mVersionTile As Picture
	#tag EndProperty

	#tag Property, Flags = &h0
		ProcessCount As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		Throttle As Boolean = True
	#tag EndProperty

	#tag Property, Flags = &h0
		Version As Double = 0.02
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  If mVersionTile = Nil Then
			    Dim drvs() As Picture
			    Dim requiredHeight, requiredWidth As Integer
			    Dim startat As Integer
			    Dim msgs() As String
			    msgs.Append("Visiproc " + Format(Version, "#0.0##"))
			    msgs.Append("Copyright " + Chr(169) + "2012 Boredom Software")
			    Dim rand As New Random
			    If rand.InRange(45, 51) = 50 Then msgs.Append("Now Deleting: C:\Windows... Please Wait")
			    For i As Integer = startat To msgs.Ubound
			      Dim p As New Picture(250, 150, 32)
			      p.Graphics.TextFont = "System"
			      p.Graphics.TextSize = 12
			      p.Graphics.Bold = True
			      Dim nm As String = msgs(i)
			      Dim strWidth, strHeight As Integer
			      strWidth = p.Graphics.StringWidth(nm)
			      strHeight = p.Graphics.StringHeight(nm, p.Width)
			      p = New Picture(strWidth, strHeight, 32)
			      p.Graphics.TextFont = "System"
			      p.Graphics.TextSize = 12
			      p.Graphics.Bold = True
			      p.Graphics.ForeColor = &c808080
			      p.Graphics.FillRect(0, 0, p.Width, p.Height)
			      p.Graphics.ForeColor = &c000000
			      p.Graphics.DrawString(nm, 0, ((p.Height/2) + (strHeight/4)))
			      drvs.Append(p)
			      requiredHeight = requiredHeight + p.Height
			      If p.Width > requiredWidth Then requiredWidth = p.Width
			    Next
			    
			    mVersionTile = New Picture(requiredWidth, requiredHeight, 32)
			    'mVersionTile.Transparent = 1
			    mVersionTile.Graphics.ForeColor = &c808080
			    mVersionTile.Graphics.FillRect(0, 0, mVersionTile.Width, mVersionTile.Height)
			    Dim x, y As Integer
			    For i As Integer = 0 To UBound(drvs)
			      mVersionTile.Graphics.DrawPicture(drvs(i), x, y)
			      y = y + drvs(i).Height
			    Next
			  End If
			  Return mVersionTile
			End Get
		#tag EndGetter
		VersionTile As Picture
	#tag EndComputedProperty

	#tag Property, Flags = &h0
		WindowThread As WindowGetter
	#tag EndProperty

	#tag Property, Flags = &h0
		WMIobj As WindowsWMIMBS
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="CPUBuffer"
			Group="Behavior"
			Type="Picture"
		#tag EndViewProperty
		#tag ViewProperty
			Name="debugBuffer"
			Group="Behavior"
			Type="Picture"
		#tag EndViewProperty
		#tag ViewProperty
			Name="debugcount"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="DebugMode"
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="diskBuffer"
			Group="Behavior"
			Type="Picture"
		#tag EndViewProperty
		#tag ViewProperty
			Name="FirstRun"
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="HideSystemProcs"
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="HilightOn"
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="lastFPS"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LastMem"
			Group="Behavior"
			Type="Double"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="magImage"
			Group="Behavior"
			Type="Picture"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ProcessCount"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Throttle"
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Version"
			Group="Behavior"
			InitialValue="0.02"
			Type="Double"
		#tag EndViewProperty
		#tag ViewProperty
			Name="VersionTile"
			Group="Behavior"
			Type="Picture"
		#tag EndViewProperty
	#tag EndViewBehavior
End Module
#tag EndModule
