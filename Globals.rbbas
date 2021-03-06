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
		Sub PollCPU()
		  #pragma BreakOnExceptions Off
		  Dim times() As Double = CPUUsage
		  Dim lines() As Integer
		  lines.Append(times(0) * 150 / 100)
		  lines.Append((times(1) * 150 / 100))
		  //lines.Append(0)
		  lastCPU(0) = times(0)
		  lastCPU(1) = times(1)
		  Dim memInfo As Int64 = getMemInfo()
		  lines.Append(memInfo)
		  lastMem = lines(2)
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
		Sub PollDisks()
		  Dim drvs() As Picture
		  Dim requiredHeight, requiredWidth As Integer
		  ReDim Drives(-1)
		  For i As Integer = 0 To VolumeCount - 1
		    Try
		      Dim f As FolderItem = Volume(i)
		      Dim total, free As UInt64
		      total = f.GetDriveSize \ 1000
		      free = f.GetDriveFreeSize \ 1000
		      Dim perc As Double = f.GetDriveFreeSize * 100 / f.GetDriveSize
		      Dim p As New Picture(250, 15, 24)
		      p.Graphics.ForeColor = &ccccccc
		      p.Graphics.FillRect(0, 0, p.Width, p.Height)
		      If GetDriveFileSystem(Volume(i)) = "CDFS" Then
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
		      If total <= 0 Then
		        p.Graphics.DrawString("(No Disk)", 10, ((p.Height/2) + (strHeight/4)))
		      Else
		        nm = GetDriveName(Volume(i))
		        If nm = "" Then nm = "(No Name)"
		        strWidth = p.Graphics.StringWidth(nm)
		        strHeight = p.Graphics.StringHeight(nm, p.Width)
		        p.Graphics.DrawString(nm, 10, ((p.Height/2) + (strHeight/4)))
		      End If
		      p.Graphics.ForeColor = &cFFFFFF
		      p.Graphics.DrawRect(1, 1, p.Width - 1, p.Height - 1)
		      drvs.Append(p)
		      Drives.Append(f.AbsolutePath:perc)
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
		diskBuffer As Picture
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="CPUBuffer"
			Group="Behavior"
			Type="Picture"
		#tag EndViewProperty
		#tag ViewProperty
			Name="diskBuffer"
			Group="Behavior"
			Type="Picture"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			InheritedFrom="Object"
		#tag EndViewProperty
	#tag EndViewBehavior
End Module
#tag EndModule
