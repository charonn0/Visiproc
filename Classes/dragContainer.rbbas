#tag Class
Protected Class dragContainer
Inherits Canvas
	#tag Event
		Function ConstructContextualMenu(base as MenuItem, x as Integer, y as Integer) As Boolean
		  #pragma Unused x
		  #pragma Unused y
		  If currentObject = -1 Then Return False
		  If objects(currentObject).Dynamic Then Return False
		  Dim priorityMnu, rt, hi, an, norm, bn, idle, term, affin, find As MenuItem
		  
		  priorityMnu = New MenuItem("Change Priority")
		  priorityMnu.Icon = prior
		  rt = New MenuItem("Real Time")
		  rt.Icon = warn
		  hi = New MenuItem("High")
		  hi.Icon = icon_exclaim
		  an = New MenuItem("Above Normal")
		  an.Icon = careful
		  norm = New MenuItem("Normal")
		  norm.Icon = Safe
		  bn = New MenuItem("Below Normal")
		  bn.Icon = meh
		  idle = New MenuItem("Idle")
		  idle.Icon = icon_alert
		  term = New MenuItem("Terminate Process")
		  term.Icon = terminate
		  affin = New MenuItem("Set Affinity")
		  affin.Icon = sched
		  find = New MenuItem("Find Executable")
		  find.Icon = target
		  priorityMnu.Append(rt)
		  priorityMnu.Append(hi)
		  priorityMnu.Append(an)
		  priorityMnu.Append(norm)
		  priorityMnu.Append(bn)
		  priorityMnu.Append(idle)
		  base.Append(priorityMnu)
		  base.Append(term)
		  base.Append(affin)
		  base.Append(find)
		End Function
	#tag EndEvent

	#tag Event
		Function ContextualMenuAction(hitItem as MenuItem) As Boolean
		  If currentObject = -1 Then Return True
		  
		  
		  Dim procID As ProcessInformation = Objects(currentObject).Process
		  
		  Select Case hitItem.Text
		  Case "Real Time"
		    procID.priority = PriorityRealTime
		  Case "High"
		    procID.priority = PriorityHigh
		  Case "Above Normal"
		    procID.priority = priorityAboveNormal
		  Case "Normal"
		    procID.priority = PriorityNormal
		  Case "Below Normal"
		    procID.priority = priorityBelowNormal
		  Case "Idle"
		    procID.priority = PriorityIdle
		  Case "Terminate Process"
		    Dim x As Integer = MsgBox("Are you absolutely sure about that?", 52, "Confirm Process Termination")
		    If x = 6 then
		      Call procID.terminate()
		    End If
		  Case "Find Executable"
		    Dim imagePath As FolderItem = procID.path
		    If imagePath = Nil Then
		      MsgBox("Unable to resolve image path For " + procID.Name)
		    Else
		      imagePath.ShowInExplorer()
		    End If
		  Case "Set Affinity"
		    cpuSelect.getAffinity(procID, 0)
		  End Select
		  Update
		  
		  menuUp = False
		  'Refresh(False)
		Exception Err
		  If Err IsA AccessDenied Then
		    Call MsgBox("Access Denied", 16, Err.Message)
		  Else
		    Raise err
		  End If
		End Function
	#tag EndEvent

	#tag Event
		Sub DoubleClick(X As Integer, Y As Integer)
		  //Double click on the background. Opens an "open..." dialog.
		  #pragma Unused x
		  #pragma Unused y
		  If currentObject > -1 Then
		    If Objects(currentObject).Dynamic Then
		      Select Case Objects(currentObject).DynType
		      Case 0
		        CPUWindow.Show
		      Case 1
		        DriveWindow.Show
		      Case 2
		        debugdetail.Show
		      End Select
		    Else
		      'Call GetWindowList
		      For i As Integer = 0 To UBound(activeProcesses)
		        If Objects(currentObject).Process.ProcessID = activeProcesses(i).ProcessID Then
		          entryDetail.showMe(activeProcesses(i))
		          Exit
		        End If
		      Next
		    End If
		  Else
		    createprocess.Show
		  End If
		End Sub
	#tag EndEvent

	#tag Event
		Sub DropObject(obj As DragItem, action As Integer)
		  If action = DragItem.DragActionCopy Then
		    Dim f As FolderItem = Obj.FolderItem
		    Dim p As Picture = Picture.Open(f)
		    If p <> Nil Then
		      Me.Background = p
		      Return
		    End If
		  End If
		  Dim droppedFile() As FolderItem
		  droppedFile.Append(obj.FolderItem)
		  While obj.NextItem = True
		    droppedFile.Append(obj.FolderItem)
		  Wend
		  For Each file As FolderItem In droppedFile
		    file.Launch
		  Next
		  
		End Sub
	#tag EndEvent

	#tag Event
		Function MouseDown(X As Integer, Y As Integer) As Boolean
		  //First, save the old currentObject
		  Dim refreshn As Integer = currentObject
		  
		  //Get the new currentobject
		  currentObject = hitpointToObject(x, y)
		  
		  If currentObject > -1 Then
		    bringToFront(currentObject)
		    If IsContextualClick Then
		      //The user wants a menu for the oject
		      If Not Objects(currentObject).Dynamic Then
		        menuUp = True
		      End If
		    End If
		    Refresh(False)
		  ElseIf refreshn > -1 Then
		    //Clean up the outline if a tile was outlined.
		    drawObject(refreshn)
		    Refresh(False)
		  End If
		  
		  lastX = X
		  lastY = Y
		  Return True
		End Function
	#tag EndEvent

	#tag Event
		Sub MouseDrag(X As Integer, Y As Integer)
		  Static doit As Integer
		  If doit = 5 Or Not Throttle Then  //Performance kludge. Only update every fifth time we're called
		    doit = 0
		    If currentObject > -1 Then
		      //Calculate the new position of the object, update the object, then refresh the control.
		      If lastX = X And lastY = Y Then Return
		      Dim objX As Integer = x - lastx
		      Dim objY As Integer = y - lasty
		      lastx = x
		      lasty = y
		      objects(currentObject).x = objects(currentObject).x + objX
		      objects(currentObject).y = objects(currentObject).y + objY
		      Refresh(False)
		    End If
		  End If
		  doit = doit + 1
		End Sub
	#tag EndEvent

	#tag Event
		Sub MouseMove(X As Integer, Y As Integer)
		  Static doit As Integer
		  If doit = 5 Or Not Throttle Then  //Performance kludge. Only update every fifth time we're called
		    drawHelp(X, Y)
		    doit = 0
		  End If
		  doit = doit + 1
		End Sub
	#tag EndEvent

	#tag Event
		Sub Open()
		  //Create the dynamic tiles
		  Me.AcceptFileDrop(FileTypes1.Any)
		  Dim cpuWin As New dragObject
		  cpuWin.DynType = 0
		  
		  Dim diskWin As New dragObject
		  diskWin.DynType = 1
		  
		  addObject(cpuWin)
		  addObject(diskWin)
		  
		  If DebugMode Then
		    Dim debugWin As New dragObject
		    debugWin.DynType = 2
		    addObject(debugWin)
		  End If
		  
		  UpdateMutex = New Mutex("BS.Lock")
		  
		  'Dim mag As New dragObject  //Very slow
		  'mag.DynType = 3
		  'addObject(mag)
		End Sub
	#tag EndEvent

	#tag Event
		Sub Paint(g As Graphics)
		  //First make sure we haven't been resized. If we have then we need to resize the buffer, too.
		  Static lastWidth, lastHeight As Integer
		  If lastWidth <> Me.Width Or lastHeight <> Me.Height Then
		    buffer = New Picture(Me.Width, Me.Height, 24)
		    lastWidth = Me.Width
		    lastHeight = Me.Height
		  End If
		  
		  //Then, clean up any prior states
		  If Background <> Nil Then
		    buffer.Graphics.DrawPicture(Background, 0, 0, buffer.Width, buffer.Height, 0, 0, Background.Width, Background.Height)
		  Else
		    buffer.Graphics.ForeColor = BackColor
		    buffer.Graphics.FillRect(0, 0, buffer.Width, buffer.Height)
		  End If
		  
		  If DebugMode Then 
		    DrawVersion()  //draw the version text
		    DrawFPS()      //Update the FPS text
		    FPS = FPS + 1
		  End If
		  
		  //Draw each dragObject one by one, starting with the bottom-most (Z-Ordering is reverse of the objects array's order)
		  For i As Integer = 0 To objects.Ubound
		    drawObject(i)
		  Next
		  
		  If helptext <> Nil Then
		    buffer.Graphics.DrawPicture(helptext, Me.MouseX + 10, Me.MouseY + 10)
		  End If
		  //Draw the buffer to the Canvas
		  'g.DrawPicture(buffer, 0, 0)
		  
		  
		  Declare Function BitBlt Lib "GDI32" (DCdest As Integer, xDest As Integer, yDest As Integer, nWidth As Integer, nHeight As Integer, _
		  DCdource As Integer, xSource As Integer, ySource As Integer, rasterOp As Integer) As Boolean
		  
		  Call BitBlt(g.Handle(1), 0, 0, g.Width, g.Height, buffer.Graphics.Handle(1), left, top, SRCCOPY Or CAPTUREBLT)
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub addObject(no As dragObject)
		  //Adds a new dragObject to the objects array
		  If no.x > Me.Width Or no.y > Me.Height Then
		    no.x = no.x - 200
		    no.y = no.y - 200
		  End If
		  objects.Append(no)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Arrange(Order As Integer = 0)
		  If UpdateMutex.TryEnter Then
		    lastSort = Order
		    If Order = -1 Then Return
		    
		    Dim x As Integer = 10
		    Dim y As Integer = 10
		    //Needs cleanup
		    Select Case Order
		    Case 1
		      Dim s() As String
		      Dim u() As Integer
		      For i As Integer = 0 To UBound(objects)
		        If objects(i).Dynamic Then
		          Select Case objects(i).DynType
		          Case 0
		            s.Append("ZZZZZZA")
		          Case 1
		            s.Append("ZZZZZZB")
		          Case 2
		            s.Append("ZZZZZZC")
		          Case 3
		            s.Append("ZZZZZZD")
		          End Select
		        Else
		          s.Append(objects(i).Process.Name + Str(objects(i).Process.ProcessID))
		        End If
		        u.Append(i)
		      Next
		      s.SortWith(u)
		      Dim widest As Integer
		      For i As Integer = 0 To UBound(u)
		        Objects(u(i)).x = x
		        Objects(u(i)).y = y
		        If Objects.Ubound = i Then Continue
		        If Objects(u(i)).Image.height + 10 + Objects(u(i + 1)).Image.height + 10 + y <= Me.Height Then
		          y = y + Objects(u(i)).Image.height +10
		          If Objects(u(i)).Image.Width > widest Then 
		            widest = Objects(u(i)).Image.Width
		          End If
		        Else
		          y =10
		          x = x + widest + 10
		          widest = 0
		        End If
		        
		      Next
		    Case 2
		      Dim s() As Integer
		      Dim u() As Integer
		      For i As Integer = 0 To UBound(objects)
		        If objects(i).Dynamic Then
		          Select Case objects(i).DynType
		          Case 0
		            s.Append(9999997)
		          Case 1
		            s.Append(9999998)
		          Case 2
		            s.Append(9999999)
		          End Select
		        Else
		          s.Append(objects(i).Process.ProcessID)
		        End If
		        u.Append(i)
		      Next
		      s.SortWith(u)
		      Dim widest As Integer
		      For i As Integer = 0 To UBound(u)
		        Objects(u(i)).x = x
		        Objects(u(i)).y = y
		        If Objects.Ubound = i Then Continue
		        If Objects(u(i)).Image.height + 10 + Objects(u(i + 1)).Image.height + 10 + y <= Me.Height Then
		          y = y + Objects(u(i)).Image.height +10
		          If Objects(u(i)).Image.Width > widest Then
		            widest = Objects(u(i)).Image.Width
		          End If
		        Else
		          y =10
		          x = x + widest + 10
		          widest = 0
		        End If
		        
		      Next
		    Case 3
		      Dim rand As New Random
		      For i As Integer = 0 To UBound(Objects)
		        x = Rand.InRange(0, Window1.dragContainer1.Width)
		        y = Rand.InRange(0, Window1.dragContainer1.Height)
		        
		        Objects(i).x = x
		        Objects(i).y = y
		        
		        If Objects(i).x > Me.Width Or Objects(i).y > Me.Height Then
		          Objects(i).x = Objects(i).x - 200
		          Objects(i).y = Objects(i).y - 200
		        End If
		      Next
		      lastSort = -1
		    End Select
		    
		    //First, check whether an object was clicked on
		    If currentObject > -1 Then
		      //Then bring it to the foreground
		      bringToFront(currentObject)
		    End If
		    Refresh(False)
		    UpdateMutex.Leave
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub bringToFront(index As Integer)
		  //Brings the object at Index to the "front" (i.e. moves it to the UBound of the objects array.)
		  //Objects get drawn from the zeroth element in the objects array, so the "top" object gets drawn last.
		  
		  If index = -1 Then Return
		  Dim obj As dragObject = objects(index)
		  objects.Remove(index)
		  objects.Append(obj)
		  currentObject = objects.Ubound
		  
		Exception err As OutOfBoundsException
		  debug("Whoops! Can't delete what doesn't exist!")
		  If index = currentObject Then currentObject = -1
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DrawFPS()
		  Dim percStr As String
		  Buffer.Graphics.TextSize = 20
		  Buffer.Graphics.Bold = True
		  percStr = Str(lastFPS) + " FPS"
		  Buffer.Graphics.ForeColor = &c000000
		  Dim strWidth, strHeight As Integer
		  strWidth = Buffer.Graphics.StringWidth(percStr)
		  strHeight = Buffer.Graphics.StringHeight(percStr, Buffer.Width)
		  Buffer.Graphics.DrawString(percStr, (Buffer.Width) - (strWidth) - 10, strHeight + 10)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub drawHelp(X As Integer, Y As Integer)
		  Dim i As Integer = hitpointToObject(X, Y)
		  
		  If i > -1 Then
		    Dim s As String
		    If Objects(i).Dynamic Then
		      If objects(i).DynType = 0 Then
		        Dim d() As Double = lastCPU
		        s = "u: " + Format(d(0), "##0.00\%") + ";   k:" + Format(d(1), "##0.00\%") + EndOfLine + "Memory: " + Format(LastMem, "##0.00\%")
		        If s.InStr("J") > 0 Then Break
		      ElseIf Objects(i).DynType = 1 Then
		        For Each pp As VolumeInformation In Drives
		          If Not pp.Mounted Then
		            s = s + "Drive " + pp.Path + " is not mounted.  " + EndOfLine
		          ElseIf pp.Type <> VolumeInformation.Network Then
		            s = s + "Drive " + pp.Path + " is " + Format(100 - pp.PercentFull, "##0.00\%") + " Full  " + EndOfLine
		          Else
		            s = s + "Drive " + pp.Path + " is a network volume.  " + EndOfLine
		          End If
		        Next
		      ElseIf Objects(i).DynType = 2 Then
		        s = "Debug Messages"
		      End If
		    Else
		      Try
		        s = Objects(i).Process.CommandLine
		        If s = "" Then s = objects(i).Process.Name
		        If Objects(i).Process.Suspended Then
		          s = s + " (Suspended)"
		        End If
		      Catch
		        s = "Image Not Resolved."
		      End Try
		    End If
		    helptext = New Picture(10, 10, 32)
		    helptext.Graphics.TextFont = "System"
		    helptext.Graphics.TextSize = 12
		    Dim strWidth, strHeight As Integer
		    If Instr(s, EndOfLine) > 0 Then
		      Dim drvs() As String = s.Split(EndOfLine)
		      Dim requiredHeight, requiredWidth As Integer
		      For z As Integer = 0 To UBound(drvs)
		        Dim drv As String = drvs(z).Trim
		        If drv = "" Then Continue
		        Dim a, b As Integer
		        a = helptext.Graphics.StringWidth(drv)
		        b = helptext.Graphics.StringHeight(drv, a)
		        If requiredWidth < a Then requiredWidth = a
		        requiredHeight = requiredHeight + b
		      Next
		      strWidth = requiredWidth
		      strHeight = requiredHeight
		      helptext = New Picture(strWidth + 8, strHeight + 8, 32)
		      helptext.Graphics.ForeColor = &cFFFF80
		      helptext.Graphics.FillRect(0, 0, helptext.Width, helptext.Height)
		      helptext.Graphics.ForeColor = &c000000
		      helptext.Graphics.DrawString(s, 2, 15)
		      
		    Else
		      strWidth = helptext.Graphics.StringWidth(s)
		      strHeight = helptext.Graphics.StringHeight(s, strWidth + 5)
		      helptext = New Picture(strWidth + 4, strHeight + 4, 32)
		      helptext.Graphics.ForeColor = &cFFFF80
		      helptext.Graphics.FillRect(0, 0, helptext.Width, helptext.Height)
		      helptext.Graphics.ForeColor = &c000000
		      helptext.Graphics.DrawString(s, 2, ((helptext.Height/2) + (strHeight/4)))
		    End If
		    helptext.Graphics.ForeColor = &c363636
		    helptext.Graphics.DrawRect(0, 0, helptext.Width, helptext.Height)
		    Refresh(False)
		  Else
		    If helptext <> Nil Then
		      helptext = Nil
		      Refresh(False)
		    End If
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub drawObject(index As Integer)
		  //Draws the object onto to buffer
		  //Objects(index).Update(False)
		  If index = currentObject Then
		    Dim p As Picture = DrawOutline(Index)
		    buffer.Graphics.DrawPicture(p, objects(index).x, objects(index).y - (p.Height - objects(index).image.Height))
		  End If
		  'If Objects(index).Process <> Nil Then
		  'If Objects(index).Process.Suspended Then
		  'buffer.Graphics.ForeColor = &c808080
		  'Else
		  'buffer.Graphics.ForeColor = &c000000
		  'End If
		  'Else
		  buffer.Graphics.ForeColor = &c000000
		  'End If
		  If Objects(index).Dynamic Then
		    If Objects(index).image <> Nil Then
		      buffer.Graphics.DrawRect(objects(index).x - 1, objects(index).y - 1, objects(index).image.width + 1, objects(index).image.height + 1)
		    End If
		  Else
		    buffer.Graphics.DrawRect(objects(index).x - 1, objects(index).y - 1, objects(index).width + 1, objects(index).height + 1)
		  End If
		  buffer.Graphics.ForeColor = &c808080
		  If Objects(index).image <> Nil Then buffer.Graphics.DrawPicture(objects(index).image, objects(index).x, objects(index).y)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DrawOutline(Index As Integer) As Picture
		  Dim p As Picture
		  Dim pid As String
		  If Objects(Index).Process <> Nil Then
		    pid = "PID: " + Str(Objects(Index).Process.ProcessID)
		  Else
		    If objects(Index).DynType = 0 Then
		      pid = "Resource Monitor"
		    ElseIf objects(Index).DynType = 1 Then
		      pid = "Drive Space"
		    ElseIf objects(Index).DynType = 2 Then
		      pid = "Debug Messages"
		    End If
		  End If
		  buffer.Graphics.TextFont = "System"
		  buffer.Graphics.TextSize = 12
		  Dim strWidth, strHeight As Integer
		  strWidth = buffer.Graphics.StringWidth(pid)
		  strHeight = buffer.Graphics.StringHeight(pid, strWidth)
		  
		  p = New Picture(Objects(Index).Image.Width, Objects(Index).Image.Height + strHeight, 32)
		  p.Graphics.ForeColor = &cCCCCCC
		  p.Graphics.FillRect(0, 0, p.Width, p.Height)
		  p.Graphics.ForeColor = &c000000
		  p.Graphics.DrawPicture(Objects(Index).Image, 0, p.Height - Objects(Index).Image.Height)
		  p.Graphics.DrawString(pid, 5, strHeight - 3)
		  
		  Return p
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DrawVersion()
		  Dim x, y As Integer
		  x = Me.Width - VersionTile.Width - 10
		  y = Me.Height - VersionTile.Height - 10
		  buffer.Graphics.DrawPicture(VersionTile, x, y)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DynUpdate()
		  For i As Integer = 0 To UBound(Objects)
		    If objects(i).Dynamic Then
		      drawObject(i)
		    End If
		  Next
		  Refresh(False)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Empty()
		  ReDim objects(-1)
		  ReDim activeProcesses(-1)
		  ReDim activeProcessesOld(-1)
		  Dim cpuWin As New dragObject
		  cpuWin.DynType = 0
		  Dim diskWin As New dragObject
		  diskWin.DynType = 1
		  addObject(cpuWin)
		  addObject(diskwin)
		  If DebugMode Then
		    Dim debugWin As New dragObject
		    debugWin.DynType = 2
		    addObject(debugWin)
		  End If
		  Refresh(False)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function hitpointToObject(x As Integer, y As Integer) As Integer
		  //Given an (x,y) coordinate returns the index (in the objects array) of the topmost object occupying those coordinates, if any.
		  #pragma BreakOnExceptions Off
		  For i As Integer = objects.Ubound DownTo 0
		    If (objects(i).x < x) And (x < objects(i).x + objects(i).image.Width) And (objects(i).y < y) And (y < objects(i).y + objects(i).image.height) Then
		      Return i
		    End If
		  Next
		  
		  Return -1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ToggleDebug()
		  If DebugMode Then
		    For i As Integer = 0 To UBound(objects)
		      If objects(i).DynType = 2 Then
		        Objects.Remove(i)
		        DebugMode = False
		        Exit For i
		      End If
		    Next
		  Else
		    Dim debugWin As New dragObject
		    debugWin.DynType = 2
		    addObject(debugWin)
		    DebugMode = True
		  End If
		  Refresh(False)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ToggleHilight()
		  HilightOn = Not HilightOn
		  For i As Integer = 0 To UBound(objects)
		    If Not objects(i).Dynamic Then
		      Objects(i).Paint
		    End If
		  Next
		  Refresh(False)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ToggleSystem()
		  'If HideSystemProcs Then
		  'For i As Integer = UBound(objects) DownTo 0
		  'If Objects(i).Dynamic Then Continue
		  'If objects(i).Process.IsCritical Then
		  'Objects.Remove(i)
		  'End If
		  'Next
		  'Else
		  If HideSystemProcs Then
		    For i As Integer = UBound(objects) DownTo 0
		      If Objects(i).Process = Nil Then Continue
		      If Objects(i).Process.Hidden Then
		        sysProcs.Append(Objects(i))
		        Objects.Remove(i)
		      End If
		    Next
		  Else
		    While sysProcs.Ubound > -1
		      addObject(sysProcs.Pop)
		    Wend
		  End If
		  
		  
		  
		  Update()
		  'End If
		  Arrange(lastSort)
		  Refresh(False)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Update()
		  //First, find which processes have died
		  activeProcessesOld = activeProcesses
		  activeProcesses = GetActiveProcesses()
		  Dim newProcs() As ProcessInformation = getNewProcs()
		  Dim deadProcs() As ProcessInformation = getDeadProcs()
		  For x As Integer = UBound(deadProcs) DownTo 0
		    For i As Integer = UBound(Objects) DownTo 0
		      If Objects(i).Dynamic Then Continue For i
		      If objects(i).Process.ProcessID = deadProcs(x).ProcessID Then
		        //And remove them from the objects array
		        debug("Process " + Str(Objects(i).Process.ProcessID) + " died")
		        Objects.Remove(i)
		        Exit For i
		      End If
		    Next
		  Next
		  
		  
		  //Then, add any new processes that we want to show
		  For Each proc As ProcessInformation In newProcs
		    If proc.isCritical And HideSystemProcs Then
		      Continue
		    Else
		      Dim no As New dragObject(proc)
		      addObject(no)
		    End If
		  Next
		  
		  //If we added or removed any objects, we should re-sort
		  If UBound(newProcs) > -1 Or UBound(activeProcessesOld) > -1 Then
		    If UpdateMutex.TryEnter Then
		      Arrange(lastSort)
		      UpdateMutex.Leave
		    End If
		  End If
		  
		  //Finally, draw the helptext, if any.
		  drawHelp(Me.MouseX, Me.MouseY)
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		BackColor As Color = &c808080
	#tag EndProperty

	#tag Property, Flags = &h0
		Background As Picture
	#tag EndProperty

	#tag Property, Flags = &h21
		Private buffer As Picture
	#tag EndProperty

	#tag Property, Flags = &h21
		#tag Note
			Represents the index of the currently active object in the objects array
		#tag EndNote
		Private currentObject As Integer = -1
	#tag EndProperty

	#tag Property, Flags = &h0
		Effects As Integer = 0
	#tag EndProperty

	#tag Property, Flags = &h0
		FPS As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private helptext As Picture
	#tag EndProperty

	#tag Property, Flags = &h0
		lastSort As Integer = -1
	#tag EndProperty

	#tag Property, Flags = &h21
		#tag Note
			Used in dragging
		#tag EndNote
		Private lastX As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		#tag Note
			Used in dragging
		#tag EndNote
		Private lastY As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private menuUp As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		#tag Note
			The heart of this whole operation: an array of dragObjects. Each dragObject corresponds to a "window" drawn on the Parent dragContainer
		#tag EndNote
		Private objects() As dragObject
	#tag EndProperty

	#tag Property, Flags = &h21
		Private sysProcs() As dragObject
	#tag EndProperty

	#tag Property, Flags = &h21
		Private UpdateMutex As Mutex
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="AcceptFocus"
			Visible=true
			Group="Behavior"
			Type="Boolean"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="AcceptTabs"
			Visible=true
			Group="Behavior"
			Type="Boolean"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="AutoDeactivate"
			Visible=true
			Group="Appearance"
			InitialValue="True"
			Type="Boolean"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="BackColor"
			Group="Behavior"
			InitialValue="&c808080"
			Type="Color"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Backdrop"
			Visible=true
			Group="Appearance"
			Type="Picture"
			EditorType="Picture"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Background"
			Group="Behavior"
			Type="Picture"
		#tag EndViewProperty
		#tag ViewProperty
			Name="DoubleBuffer"
			Visible=true
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Effects"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Enabled"
			Visible=true
			Group="Appearance"
			InitialValue="True"
			Type="Boolean"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="EraseBackground"
			Visible=true
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="FPS"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Height"
			Visible=true
			Group="Position"
			InitialValue="100"
			Type="Integer"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="HelpTag"
			Visible=true
			Group="Appearance"
			Type="String"
			EditorType="MultiLineEditor"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			Type="Integer"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="InitialParent"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="lastSort"
			Group="Behavior"
			InitialValue="-1"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			Type="Integer"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockBottom"
			Visible=true
			Group="Position"
			Type="Boolean"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockLeft"
			Visible=true
			Group="Position"
			Type="Boolean"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockRight"
			Visible=true
			Group="Position"
			Type="Boolean"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockTop"
			Visible=true
			Group="Position"
			Type="Boolean"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TabIndex"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TabPanelIndex"
			Group="Position"
			InitialValue="0"
			Type="Integer"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TabStop"
			Visible=true
			Group="Position"
			InitialValue="True"
			Type="Boolean"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			Type="Integer"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="UseFocusRing"
			Visible=true
			Group="Appearance"
			InitialValue="True"
			Type="Boolean"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Visible"
			Visible=true
			Group="Appearance"
			InitialValue="True"
			Type="Boolean"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Width"
			Visible=true
			Group="Position"
			InitialValue="100"
			Type="Integer"
			InheritedFrom="Canvas"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
