#tag Module
Protected Module Globals
	#tag Method, Flags = &h0
		Function ColorToHex(Extends c As Color) As String
		  //Converts a Color to a hex string.
		  //This function should be cross-platform safe.
		  
		  Dim ret As String
		  
		  If Hex(c.red).len = 1 Then
		    ret = ret + "0" + Hex(c.red)
		  Else
		    ret = ret + Hex(c.red)
		  End If
		  
		  If Hex(c.green).len = 1 Then
		    ret = ret + "0" + Hex(c.green)
		  Else
		    ret = ret + Hex(c.green)
		  End If
		  
		  If Hex(c.blue).len = 1 Then
		    ret = ret + "0" + Hex(c.blue)
		  Else
		    ret = ret + Hex(c.blue)
		  End If
		  
		  Return ret
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub drawBack(ByRef Buffer As Picture)
		  Buffer.Graphics.ForeColor = RGB(0, 0, 0, Globals.Transparency)
		  Buffer.Graphics.FillRect(0, 0, Buffer.Width, Buffer.Height)
		  Buffer.Graphics.ForeColor = RGB(&h3F, &h3F, &h3F, Globals.Transparency)
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
		Function FileDropHandler(data As MemoryBlock) As Boolean
		  Dim f As FolderItem = GetFolderItem(data.StringValue(0, data.Size))
		  If f <> Nil Then
		    If f.Exists And Not f.Directory Then
		      Dim p As Picture = Picture.Open(f)
		      If p.Width > 500 Or p.Height > 500 Then
		        If p.Width > p.Height Then
		          Photo = New Picture((500 / p.Width) * p.Width, (500 / p.Width) * p.Height, p.Depth)
		        Else
		          Photo = New Picture((500 / p.Height) * p.Width, (500 / p.Height) * p.Height, p.Depth)
		        End If
		        Photo.Graphics.DrawPicture(p, 0, 0, Photo.Width, Photo.Height, 0, 0, p.Width, p.Height)
		      Else
		        Photo = p
		      End If
		      PhotoFile = f
		      App.WriteConf
		    End If
		  End If
		  
		  Return True
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FileToolHandler(data As MemoryBlock) As Boolean
		  If Working Then
		    Call MsgBox("One thing at a time, please.", 6, "Patience is a virtue.")
		    Return True
		  End If
		  Dim f As FolderItem = GetFolderItem(data.StringValue(0, data.Size))
		  Dim X, Y As Integer
		  X = Window1.dragContainer1.MouseX
		  Y = Window1.dragContainer1.MouseY
		  X = X - Window1.dragContainer1.Objects(Window1.dragContainer1.DropIndex).x
		  Y = Y - Window1.dragContainer1.Objects(Window1.dragContainer1.DropIndex).y
		  
		  Dim w, h As Integer
		  w = Window1.dragContainer1.Objects(Window1.dragContainer1.DropIndex).image.Width
		  h = Window1.dragContainer1.Objects(Window1.dragContainer1.DropIndex).image.Height
		  
		  If X < (w / 2) And Y < (h / 2) Then
		    If f <> Nil Then
		      Call MsgBox(Trid(f), 64, prettifyPath(f.AbsolutePath))
		    End If
		    Return True
		    //Upper left
		  ElseIf X < (w / 2) And Y > (h / 2) Then
		    fileDetail.showMeFile(f)
		    //Lower Left
		  ElseIf X > (w / 2) And Y < (h / 2) Then
		    If Not f.Directory Then f = f.Parent
		    Dim g As FolderItem = SpecialFolder.System.Child("cmd.exe")
		    Dim s As String = """" + g.AbsolutePath + """" + " /k cd """ + f.AbsolutePath + """"
		    g.Launch(s)
		    //Upper right
		  ElseIf X > (w / 2) And Y > (h / 2) Then
		    Call MD5Hash(f)
		    //Lower right
		  End If
		  
		  Return True
		End Function
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
		  lines.Append(times(0) * 100 / 100)
		  lines.Append((times(1) * 100 / 100))
		  //lines.Append(0)
		  lastCPU(0) = times(0)
		  lastCPU(1) = times(1)
		  lines.Append(LastMem)
		  lines.Append(LastPF)
		  Static history(), history1(), history2(), history3() As Integer
		  
		  
		  CPUBuffer = New Picture(250, 100)
		  drawBack(CPUBuffer)
		  CPUBuffer.Graphics.ForeColor = &c00FF0000
		  If UBound(history) * 10 >= 250 Then
		    history.Remove(0)
		    history1.Remove(0)
		    history2.Remove(0)
		    history3.Remove(0)
		  End If
		  
		  if lines(0) = 0 Then lines(0) = 1
		  history.Append(lines(0))
		  lastCPU = times
		  Dim x, y As Integer
		  For i As Integer = 0 To UBound(history)
		    Try
		      x = i * 10
		      y = 100 - history(i - 1)
		      CPUBuffer.Graphics.DrawLine(x, y, x + 10, 100 - history(i))
		    Catch OutOfBoundsException
		      CPUBuffer.Graphics.DrawLine(0, 100 - history(i), 10, 100 - history(i))
		    End Try
		  Next
		  
		  CPUBuffer.Graphics.ForeColor = &cFF000000 //&cF47A00
		  if lines(1) = 0 Then lines(1) = 1
		  history1.Append(lines(1))
		  
		  For i As Integer = 0 To UBound(history1)
		    Try
		      CPUBuffer.Graphics.DrawLine(i * 10, 100 - history1(i - 1), i * 10 + 10, 100 - history1(i))
		    Catch OutOfBoundsException
		      CPUBuffer.Graphics.DrawLine(0, 100 - history1(i), 10, 100 - history1(i))
		    End Try
		  Next
		  
		  CPUBuffer.Graphics.ForeColor = &cFFFF80
		  if lines(2) = 0 Then lines(2) = 1
		  history2.Append(lines(2))
		  
		  For i As Integer = 0 To UBound(history2)
		    Try
		      CPUBuffer.Graphics.DrawLine(i * 10, 100 - history2(i - 1), i * 10 + 10, 100 - history2(i))
		    Catch OutOfBoundsException
		      CPUBuffer.Graphics.DrawLine(0, 100 - history2(i), 10, 100 - history2(i))
		    End Try
		  Next
		  
		  
		  CPUBuffer.Graphics.ForeColor = &cFF8000
		  if lines(3) = 0 Then lines(3) = 1
		  history3.Append(lines(3))
		  
		  For i As Integer = 0 To UBound(history3)
		    Try
		      CPUBuffer.Graphics.DrawLine(i * 10, 100 - history3(i - 1), i * 10 + 10, 100 - history3(i))
		    Catch OutOfBoundsException
		      CPUBuffer.Graphics.DrawLine(0, 100 - history3(i), 10, 100 - history3(i))
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
		      Dim p As Picture = TextToPicture(Str(i) + ": " + DebugLog(i), RGB(0, 0, &hFF, _
		      Globals.Transparency), RGB(&hcc, &hcc, &hcc, Globals.Transparency), gTextFont, gTextSize)
		      drvs.Append(p)
		      requiredHeight = requiredHeight + p.Height
		      If p.Width > requiredWidth Then requiredWidth = p.Width
		    Catch NilObjectException
		      Continue
		    End Try
		  Next
		  
		  debugBuffer = New Picture(requiredWidth, requiredHeight)', 24)
		  debugBuffer.Graphics.ForeColor = RGB(&hcc, &hcc, &hcc, Globals.Transparency)
		  debugBuffer.Graphics.FillRect(0, 0, debugBuffer.Width, debugBuffer.Height)
		  Dim x, y As Integer
		  For i As Integer = 0 To UBound(drvs)
		    debugBuffer.Graphics.DrawPicture(drvs(i), x, y)
		    y = y + drvs(i).Height
		  Next
		  debugBuffer.Graphics.ForeColor = RGB(&hFF, &hFF, &hFF, Globals.Transparency)
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
		      Dim p As New Picture(250, 15)', 24)
		      p.Graphics.ForeColor = RGB(&hcc, &hcc, &hcc, Globals.Transparency)
		      p.Graphics.FillRect(0, 0, p.Width, p.Height)
		      If f.Filesystem = "CDFS" Or f.Filesystem = "UDF" Then
		        DrawBar(p, (100 - perc) * p.Width / 100, 1)
		      Else
		        DrawBar(p, (100 - perc) * p.Width / 100)
		      End If
		      //p.Graphics.FillRect(0, 0, ((100 - perc) * p.Width / 100), p.Height)
		      p.Graphics.ForeColor = RGB(0, 0, &hFF, Globals.Transparency)
		      p.Graphics.TextFont = gTextFont
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
		      
		      p.Graphics.ForeColor = RGB(&hFF, &hFF, &hFF, Globals.Transparency)
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
		  
		  diskBuffer = New Picture(requiredWidth, requiredHeight)', 24)
		  Dim x, y As Integer
		  For i As Integer = 0 To UBound(drvs)
		    diskBuffer.Graphics.DrawPicture(drvs(i), x, y)
		    y = y + drvs(i).Height
		  Next
		  diskBuffer.Graphics.ForeColor = RGB(&hFF, &hFF, &hFF, Globals.Transparency)
		  diskBuffer.Graphics.DrawRect(0, 0, diskBuffer.Width - 1, diskBuffer.Height - 1)
		  'Dim percent As Integer = free * 100 / total
		  'diskBuffer = New Picture(250, 150, 24)
		  'drawBack(DiskBuffer)
		  'DiskBuffer.Graphics.ForeColor = &c00FF00
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Scale(Source As Picture, Ratio As Double = 1.0) As Picture
		  Dim wRatio, hRatio As Double
		  wRatio = (Ratio * Source.width)
		  hRatio = (Ratio * Source.Height)
		  If wRatio = Source.Width And hRatio = Source.Height Then Return Source
		  Dim photo As New Picture(wRatio, hRatio, Source.Depth)
		  Photo.Graphics.DrawPicture(Source, 0, 0, Photo.Width, Photo.Height, 0, 0, Source.Width, Source.Height)
		  Return photo
		  
		Exception
		  Return Source
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function TextToPicture(Text As String, forecolor As Color = &c000000, BackColor As Color = &cFFFFFF, Font As String = "System", FontSize As Double = 11.5, Bold As Boolean = False, Underline As Boolean = False, Italic As Boolean = False) As Picture
		  //Given any String, returns a picture of that string. Line breaks are honored.
		  //The optional parameters ought to be self-explanitory.
		  
		  If Text = "" Then
		    Return New Picture(1, 1)', 32)
		  End If
		  Dim lines() As Picture
		  Dim requiredHeight, requiredWidth As Integer
		  Dim tlines() As String = Split(Text, EndOfLine)
		  
		  For i As Integer = 0 To UBound(tlines)
		    If tlines(i) = "" Then tlines(i) = " "
		    Dim p As New Picture(250, 250)', 32)
		    p.Graphics.TextFont = Font
		    p.Graphics.TextSize = FontSize
		    p.Graphics.Bold = Bold
		    p.Graphics.Italic = Italic
		    p.Graphics.Underline = Underline
		    Dim nm As String = tlines(i)
		    Dim strWidth, strHeight As Integer
		    strWidth = p.Graphics.StringWidth(nm) + 5
		    strHeight = p.Graphics.StringHeight(nm, strWidth)
		    p = New Picture(strWidth, strHeight)
		    p.Graphics.ForeColor = BackColor
		    p.Graphics.FillRect(0, 0, p.Width, p.Height)
		    p.Graphics.AntiAlias = True
		    p.Graphics.ForeColor = forecolor
		    p.Graphics.TextFont = Font
		    p.Graphics.TextSize = FontSize
		    p.Graphics.Bold = Bold
		    p.Graphics.Italic = Italic
		    p.Graphics.Underline = Underline
		    p.Graphics.DrawString(nm, 1, ((p.Height/2) + (strHeight/4)))
		    lines.Append(p)
		    requiredHeight = requiredHeight + p.Height
		    If p.Width > requiredWidth Then requiredWidth = p.Width
		  Next
		  Dim txtBuffer As Picture
		  txtBuffer = New Picture(requiredWidth, requiredHeight)', 32)
		  Dim x, y As Integer
		  txtbuffer.Graphics.AntiAlias = False
		  For i As Integer = 0 To UBound(lines)
		    txtBuffer.Graphics.DrawPicture(lines(i), x, y)
		    y = y + lines(i).Height
		  Next
		  'txtBuffer.Transparent = 1
		  Return txtBuffer
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Trid(f As FolderItem) As String
		  If f.Directory Then Return "That is a directory."
		  Dim g As FolderItem = SpecialFolder.Temporary.Child("trid.exe")
		  Dim d As FolderItem = SpecialFolder.Temporary.Child("triddefs.trd")
		  Dim tos As TextOutputStream
		  tos = tos.Create(g)
		  tos.Write(trid1)
		  tos.Close
		  tos = tos.Create(d)
		  tos.Write(triddefs)
		  tos.Close
		  
		  Dim sh As New Shell
		  Dim ret As String = "Filetype not known."
		  sh.Execute("""" + g.AbsolutePath + """" + " """ + f.AbsolutePath + """")
		  Dim search() As String = sh.Result.Split(EndOfLine)
		  Dim pattern As String = "([+-]?\d*\.\d+)(?![-+0-9\.])(%)(\s+)(.*)\((\d*)"
		  For i As Integer = 0 To UBound(search)
		    Dim res() As String = search(i).RegExFind(pattern)
		    If UBound(res) > -1 Then
		      ret = "Trid says: " + res(4)
		      Exit
		    End If
		  Next
		  
		  Return ret
		End Function
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
		BackDrop As FolderItem
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  If mBackPic = Nil And BackDrop <> Nil Then
			    mBackPic = mBackPic.Open(BackDrop)
			  End If
			  return mBackPic
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mBackPic = value
			End Set
		#tag EndSetter
		BackPic As Picture
	#tag EndComputedProperty

	#tag Property, Flags = &h0
		CPUBuffer As Picture
	#tag EndProperty

	#tag Property, Flags = &h0
		CPUThread As CPUGetter
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
		DropTarget As Picture
	#tag EndProperty

	#tag Property, Flags = &h0
		FrameCount As UInt64
	#tag EndProperty

	#tag Property, Flags = &h0
		GLOBALPAUSE As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		gTextFont As String = "MS Reference Sans Serif"
	#tag EndProperty

	#tag Property, Flags = &h0
		gTextSize As Double = 11.5
	#tag EndProperty

	#tag Property, Flags = &h0
		HelpColor As Color = &cFFFF80
	#tag EndProperty

	#tag Property, Flags = &h0
		HideDynamics As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		HideSystemProcs As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		HilightOn As Boolean = True
	#tag EndProperty

	#tag Property, Flags = &h0
		Init As Boolean = True
	#tag EndProperty

	#tag Property, Flags = &h0
		InvalidSystemProcColor As Color = &cF5772C
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
			  Dim x, y As UInt64
			  x = Platform.TotalPageFile
			  y = Platform.AvailablePageFile
			  Return 100 - (y * 100 / x)
			End Get
		#tag EndGetter
		LastPF As Double
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  If mmagImage = Nil Then
			    magImage = New Picture(250, 100, 24)
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
		Private mBackPic As Picture
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mmagImage As Picture
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mVersionTile As Picture
	#tag EndProperty

	#tag Property, Flags = &h0
		NewProcColor As Color = &c00FF00
	#tag EndProperty

	#tag Property, Flags = &h0
		NormalProcColor As Color = &cFFFFFE
	#tag EndProperty

	#tag Property, Flags = &h0
		Photo As Picture
	#tag EndProperty

	#tag Property, Flags = &h0
		PhotoFile As FolderItem
	#tag EndProperty

	#tag Property, Flags = &h0
		StringColor As Color
	#tag EndProperty

	#tag Property, Flags = &h0
		SystemProcColor As Color = &c00A8F9
	#tag EndProperty

	#tag Property, Flags = &h0
		Throttle As Boolean = True
	#tag EndProperty

	#tag Property, Flags = &h0
		Transparency As Integer = 70
	#tag EndProperty

	#tag Property, Flags = &h0
		Version As Double = 0.08
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
			      Dim p As New Picture(250, 100, 32)
			      p.Graphics.TextFont = gTextFont
			      p.Graphics.TextSize = gTextSize
			      p.Graphics.Bold = True
			      Dim nm As String = msgs(i)
			      Dim strWidth, strHeight As Integer
			      strWidth = p.Graphics.StringWidth(nm)
			      strHeight = p.Graphics.StringHeight(nm, p.Width)
			      p = New Picture(strWidth, strHeight, 32)
			      p.Graphics.TextFont = gTextFont
			      p.Graphics.TextSize = gTextSize
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

	#tag Property, Flags = &h0
		Working As Boolean
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="BackPic"
			Group="Behavior"
			Type="Picture"
		#tag EndViewProperty
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
			Name="DropTarget"
			Group="Behavior"
			Type="Picture"
		#tag EndViewProperty
		#tag ViewProperty
			Name="GLOBALPAUSE"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="gTextFont"
			Group="Behavior"
			InitialValue="System"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="gTextSize"
			Group="Behavior"
			InitialValue="12"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="HelpColor"
			Group="Behavior"
			InitialValue="&cFFFF80"
			Type="Color"
		#tag EndViewProperty
		#tag ViewProperty
			Name="HideDynamics"
			Group="Behavior"
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
			Name="Init"
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="InvalidSystemProcColor"
			Group="Behavior"
			InitialValue="&cF5772C"
			Type="Color"
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
			Name="LastPF"
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
			Name="NewProcColor"
			Group="Behavior"
			InitialValue="&c00FF00"
			Type="Color"
		#tag EndViewProperty
		#tag ViewProperty
			Name="NormalProcColor"
			Group="Behavior"
			InitialValue="&cFFFFFE"
			Type="Color"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Photo"
			Group="Behavior"
			Type="Picture"
		#tag EndViewProperty
		#tag ViewProperty
			Name="StringColor"
			Group="Behavior"
			InitialValue="&c000000"
			Type="Color"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="SystemProcColor"
			Group="Behavior"
			InitialValue="&c00A8F9"
			Type="Color"
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
			Name="Transparency"
			Group="Behavior"
			InitialValue="190"
			Type="Integer"
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
		#tag ViewProperty
			Name="Working"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
	#tag EndViewBehavior
End Module
#tag EndModule
