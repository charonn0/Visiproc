#tag Class
Protected Class dragContainer
Inherits Canvas
	#tag Event
		Function ConstructContextualMenu(base as MenuItem, x as Integer, y as Integer) As Boolean
		  #pragma Unused x
		  #pragma Unused y
		  If currentObject = -1 Then Return False
		  'If objects(currentObject).Dynamic Then
		  base.Append(New MenuItem("Hide"))
		  Dim resize As New MenuItem("Resize")
		  resize.Append(New MenuItem("10%"))
		  resize.Append(New MenuItem("20%"))
		  resize.Append(New MenuItem("30%"))
		  resize.Append(New MenuItem("40%"))
		  resize.Append(New MenuItem("50%"))
		  resize.Append(New MenuItem("60%"))
		  resize.Append(New MenuItem("70%"))
		  resize.Append(New MenuItem("80%"))
		  resize.Append(New MenuItem("90%"))
		  resize.Append(New MenuItem("100%"))
		  'resize.Append(New MenuItem("110%"))
		  'resize.Append(New MenuItem("120%"))
		  'resize.Append(New MenuItem("130%"))
		  'resize.Append(New MenuItem("140%"))
		  'resize.Append(New MenuItem("150%"))
		  base.Append(resize)
		  'Return True
		  'Else
		  If Not objects(currentObject).Dynamic Then
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
		    Dim alertme As New MenuItem("Alert If Process Dies.")
		    If objects(currentObject).Alert Then
		      alertme.Checked = True
		    End If
		    base.Append(alertme)
		  End If
		  
		  
		End Function
	#tag EndEvent

	#tag Event
		Function ContextualMenuAction(hitItem as MenuItem) As Boolean
		  'If currentObject = -1 Then Return True
		  'Dim procID As ProcessInformation = Objects(currentObject).Process
		  Dim ret As Boolean
		  For i As Integer = 0 To UBound(Objects)
		    If Objects(i).Selected Then
		      ret = True
		      Select Case hitItem.Text
		      Case "Hide"
		        Hide(i)
		        'GLOBALPAUSE = True
		      Case "Real Time"
		        Objects(i).Process.priority = PriorityRealTime
		      Case "High"
		        Objects(i).Process.priority = PriorityHigh
		      Case "Above Normal"
		        Objects(i).Process.priority = priorityAboveNormal
		      Case "Normal"
		        Objects(i).Process.priority = PriorityNormal
		      Case "Below Normal"
		        Objects(i).Process.priority = priorityBelowNormal
		      Case "Idle"
		        Objects(i).Process.priority = PriorityIdle
		      Case "Terminate Process"
		        Dim x As Integer = MsgBox("Are you absolutely sure about that?", 52, "Confirm Process Termination")
		        If x = 6 then
		          Call Objects(i).Process.terminate()
		        End If
		      Case "Find Executable"
		        Dim imagePath As FolderItem = Objects(i).Process.path
		        If imagePath = Nil Then
		          MsgBox("Unable to resolve image path For " + Objects(i).Process.Name)
		        Else
		          imagePath.ShowInExplorer()
		        End If
		      Case "Set Affinity"
		        cpuSelect.getAffinity(Objects(i).Process, 0)
		      Case "10%", "20%", "30%", "40%", "50%", "60%", "70%", "80%", "90%", "100%", "110%", "120%", "130%", "140%", "150%"
		        Objects(i).ResizeTo = Val(hitItem.Text)
		      Case "Alert If Process Dies."
		        Objects(i).Alert = Not Objects(i).Alert
		      End Select
		    End If
		    //Update
		  Next
		  
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
		  DropIndex = hitpointToObject(Me.MouseX, Me.MouseY)
		  If DropIndex > -1 Then
		    If Objects(DropIndex).DynType = 4 Or Objects(DropIndex).DynType = 5 Then
		      If Obj.FolderItemAvailable Then
		        Dim mb As MemoryBlock = Obj.FolderItem.AbsolutePath
		        Call Objects(DropIndex).SpecialHandler.Invoke(mb)
		        Objects(DropIndex).Name = Obj.FolderItem.Name
		        Return
		      End If
		    End If
		  End If
		  If action = DragItem.DragActionCopy Then
		    Globals.BackPic = Nil
		    ScaledBackdrop = Nil
		    Me.Invalidate(False)
		    Dim f As FolderItem = Obj.FolderItem
		    Dim p As Picture = Picture.Open(f)
		    If p <> Nil Then
		      Globals.BackPic = p
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
		  If Not IsContextualClick Then 
		    Dim multi As Integer
		    For i As Integer = 0 To UBound(Objects)
		      If Objects(i).Selected Then
		        multi = multi + 1
		      End If
		    Next
		    If multi <= 1 Then 
		      ClearSelection
		    End If
		  End If
		  
		  Dim refreshn As Integer = currentObject
		  currentObject = hitpointToObject(x, y)
		  If currentObject > -1 Then
		    bringToFront(currentObject)
		    Objects(currentObject).Selected = True
		    If IsContextualClick Then
		      If Not Objects(currentObject).Dynamic Then
		        menuUp = True
		      End If
		    End If
		    Invalidate(False)
		  ElseIf refreshn > -1 Then
		    drawObject(refreshn)
		    Invalidate(False)
		  End If
		  
		  lastX = X
		  lastY = Y
		  
		  Return True
		End Function
	#tag EndEvent

	#tag Event
		Sub MouseDrag(X As Integer, Y As Integer)
		  FPS = FPS + 1
		  FrameCount = FrameCount + 1
		  lastSort = -1
		  If currentObject > -1 Then
		    If (lastX = X And lastY = Y) Or (NextX = 0 And NextY = 0) Then Return
		    //Calculate the new position of the object, update the object, then refresh the control.
		    Dim objX As Integer = x - lastx
		    Dim objY As Integer = y - lasty
		    lastx = x
		    lasty = y
		    
		    For i As Integer = 0 To UBound(Objects)
		      If Not Objects(i).Selected Then Continue For i
		      objects(i).x = objects(i).x + objX
		      objects(i).y = objects(i).y + objY
		    Next
		    
		    
		  Else
		    NextX = X
		    NextY = Y
		  End If
		  
		  Invalidate(False)
		End Sub
	#tag EndEvent

	#tag Event
		Sub MouseMove(X As Integer, Y As Integer)
		  drawHelp(X, Y)
		  helpfader.Reset()
		End Sub
	#tag EndEvent

	#tag Event
		Sub MouseUp(X As Integer, Y As Integer)
		  #pragma Unused X
		  #pragma Unused Y
		  NextX = -1
		  NextY = -1
		End Sub
	#tag EndEvent

	#tag Event
		Function MouseWheel(X As Integer, Y As Integer, deltaX as Integer, deltaY as Integer) As Boolean
		  #pragma Unused deltaX
		  ShowText = False
		  Dim obj As Integer = hitpointToObject(X, Y)
		  If obj > -1 Then
		    If Objects(obj).ResizeTo + deltaY > 25 And Objects(obj).ResizeTo + deltaY < 250 Then
		      Objects(obj).ResizeTo = Objects(obj).ResizeTo + deltaY
		      Invalidate(False)
		    End If
		  End If
		  ShowText = True
		  
		  Return True
		  
		End Function
	#tag EndEvent

	#tag Event
		Sub Open()
		  Me.AcceptFileDrop(FileTypes1.Any)
		  helpfader = New Timer
		  helpfader.Period = 500
		  AddHandler helpfader.Action, AddressOf helpfaderhandler
		  helpfader.Mode = Timer.ModeMultiple
		  Me.SelectionColor = &c0080FF00
		End Sub
	#tag EndEvent

	#tag Event
		Sub Paint(g As Graphics)
		  If Globals.Init Then
		    g.DrawPicture(InitImg, 0, 0)
		    buffer = New Picture(Me.Width, Me.Height, 24)
		    Return
		  End If
		  
		  //First make sure we haven't been resized. If we have then we need to resize the buffer, too.
		  Static lastWidth, lastHeight As Integer
		  If lastWidth <> Me.Width Or lastHeight <> Me.Height Then
		    buffer = New Picture(Me.Width, Me.Height)
		    lastWidth = Me.Width
		    lastHeight = Me.Height
		  End If
		  If buffer = Nil Then Return
		  //Then, clean up any prior states
		  If Globals.BackPic <> Nil Then
		    If scaledBackdrop = Nil Or scaledBackdrop.Width <> Me.Width Or scaledBackdrop.Height <> Me.Height Then
		      scaledBackdrop = New Picture(Me.Width, Me.Height, Globals.BackPic.Depth)
		      scaledBackdrop.Graphics.DrawPicture(Globals.BackPic, 0, 0, scaledBackdrop.Width, scaledBackdrop.Height, 0, 0, Globals.BackPic.Width, Globals.BackPic.Height)
		    End If
		    buffer.Graphics.DrawPicture(scaledBackdrop, 0, 0)
		  Else
		    buffer.Graphics.ForeColor = BackColor
		    buffer.Graphics.FillRect(0, 0, buffer.Width, buffer.Height)
		  End If
		  
		  If DebugMode Then
		    DrawVersion()  //draw the version text
		    DrawFPS()      //Update the FPS text
		    FPS = FPS + 1
		  End If
		  FrameCount = FrameCount + 1
		  //Draw each dragObject one by one, starting with the bottom-most (Z-Ordering is reverse of the objects array's order)
		  For i As Integer = 0 To objects.Ubound
		    drawObject(i)
		  Next
		  
		  If NextX > -1 And NextY > -1 Then
		    DrawSelectionRect(lastX, lastY, NextX, NextY)
		  End If
		  
		  If helptext <> Nil Then
		    buffer.Graphics.DrawPicture(helptext, Me.MouseX + 10, Me.MouseY + 10)
		  End If
		  //Draw the buffer to the Canvas
		  g.DrawPicture(buffer, 0, 0)
		  
		  
		Exception
		  Return
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
		  
		  
		  
		  Dim x As Integer = 14
		  Dim y As Integer = 14
		  
		  Select Case Order
		  Case 1
		    Dim s() As String
		    Dim u() As Integer
		    Dim ubOb As Integer = UBound(objects)
		    
		    For i As Integer = 0 To ubOb
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
		        Case 4
		          s.Append("ZZZZZZE")
		        Case 5
		          s.Append("ZZZZZZF")
		        Case 6
		          s.Append("ZZZZZZG")
		        End Select
		      Else
		        s.Append(objects(i).Process.Name + Str(objects(i).Process.ProcessID))
		      End If
		      u.Append(i)
		    Next
		    s.SortWith(u)
		    Dim widest As Integer
		    For i As Integer = 0 To UBound(u)
		      Dim theNum As Integer = u(i)
		      Objects(theNum).x = x
		      Objects(theNum).y = y
		      If Objects.Ubound = i Then Continue
		      If Objects(u(i + 1)).Image = Nil Then Continue
		      
		      If Objects(theNum).Image.height + 14 + Objects(u(i + 1)).Image.height + 14 + y <= Me.Height Then
		        y = y + Objects(theNum).Image.height + 14
		        If Objects(theNum).Image.Width > widest Then
		          widest = Objects(theNum).Image.Width
		        End If
		      Else
		        y = 14
		        x = x + widest + 14
		        widest = 0
		      End If
		      
		    Next
		    lastSort = 1
		  Case 2
		    Dim s() As Integer
		    Dim u() As Integer
		    For i As Integer = 0 To UBound(objects)
		      If objects(i).Dynamic Then
		        Select Case objects(i).DynType
		        Case 6
		          s.Append(9999993)
		        Case 3
		          s.Append(9999994)
		        Case 5
		          s.Append(9999995)
		        Case 0
		          s.Append(9999996)
		        Case 1
		          s.Append(9999997)
		        Case 2
		          s.Append(9999998)
		        Case 4
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
		      If Objects(u(i)).Image.height + 14 + Objects(u(i + 1)).Image.height + 14 + y <= Me.Height Then
		        y = y + Objects(u(i)).Image.height + 14
		        If Objects(u(i)).Image.Width > widest Then
		          widest = Objects(u(i)).Image.Width
		        End If
		      Else
		        If Objects(u(i)).Image.Width > widest Then
		          widest = Objects(u(i)).Image.Width
		        End If
		        y = 14
		        x = x + widest + 14
		        widest = 0
		      End If
		      
		    Next
		    lastSort = 2
		  Case 3
		    If lastSort = 3 Then Return
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
		    lastSort = 3
		  Case 4
		    Dim r As Integer = (0.015625 * Me.Width)
		    'Static up As Boolean
		    Objects.Insert(0, objects.Pop)
		    'If r > 1 And r <= 30 Then
		    'If up = False Then
		    'r = r - 1
		    'Else
		    'r = r + 1
		    'End If
		    'Else
		    'If r > 30 Then
		    'up = False
		    'r = r - 1
		    'Else
		    'up = True
		    'r = r + 1
		    'End If
		    'End If
		    For i As Integer = 0 To UBound(Objects)
		      x = (i * r) + 20
		      //Rand.InRange(0, Window1.dragContainer1.Width)
		      y = Cos(i / 20 * 2 * 3.14159265358979323846264338327950) * 100 + (0.33 * Me.Height)
		      //Rand.InRange(0, Window1.dragContainer1.Height)
		      
		      Objects(i).x = x
		      Objects(i).y = y
		    Next
		    lastSort = 4
		  End Select
		  
		  //First, check whether an object was clicked on
		  If currentObject > -1 Then
		    //Then bring it to the foreground
		    bringToFront(currentObject)
		  End If
		  Refresh(False)
		  //UpdateMutex.Leave
		  //End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub bringToFront(index As Integer)
		  
		  //Brings the object at Index to the "front" (i.e. moves it to the UBound of the objects array.)
		  //Objects get drawn from the zeroth element in the objects array, so the "top" object gets drawn last.
		  
		  If index = -1 Or index > Ubound(Objects) Then Return
		  Dim obj As dragObject = objects(index)
		  objects.Remove(index)
		  objects.Append(obj)
		  currentObject = objects.Ubound
		  
		Exception err As OutOfBoundsException
		  debug("Whoops! Can't delete what doesn't exist!")
		  If index = currentObject Then currentObject = -1
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ClearSelection()
		  For Each Item As dragObject In Objects
		    Item.Selected = False
		  Next
		  currentObject = -1
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DrawFPS()
		  Dim tmp1 As Picture = TextToPicture(Str(lastFPS) + " FPS", &c000000, &cCCCCCC, gTextFont, 20)
		  Dim tmp2 As Picture = TextToPicture(Format(FrameCount, "###,###,###,###,###,###,##0")+ " Frames So Far", &c000000, &cCCCCCC, gTextFont, 10)
		  buffer.Graphics.DrawPicture(tmp1, buffer.Width - tmp1.Width, 0)
		  buffer.Graphics.DrawPicture(tmp2, buffer.Width - tmp2.Width, tmp1.Height)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub drawHelp(X As Integer, Y As Integer)
		  
		  Dim i As Integer = hitpointToObject(X, Y)
		  
		  If i > -1 And ShowText Then
		    Dim s As String
		    If Objects(i).Dynamic Then
		      Select Case objects(i).DynType
		      Case 0
		        Dim d() As Double = lastCPU
		        s = "u: " + Format(d(0), "##0.00\%") + ";   k:" + Format(d(1), "##0.00\%") + EndOfLine + "RAM: " + Format(LastMem, "##0.00\%") + EndOfLine + "Page File: " + Format(LastPF, "##0.00\%")
		      Case 1
		        For Each pp As VolumeInformation In Drives
		          If Not pp.Mounted Then
		            s = s + "Drive " + pp.Path + " is not mounted.  "
		          ElseIf pp.Type <> VolumeInformation.Network Then
		            s = s + "Drive " + pp.Path + " is " + Format(100 - pp.PercentFull, "##0.00\%") + " Full  "
		          Else
		            s = s + "Drive " + pp.Path + " is a network volume.  "
		          End If
		          s = s + EndOfLine
		        Next
		      Case 2
		        s = "Debug Messages"
		      Case 4
		        s = "Photo Frame"
		      Case 5
		        s = "File Multi-Tool"
		      Case 6
		        s = Clock.BackingDate.LongDate + " " + Clock.BackingDate.LongTime
		      End Select
		    Else
		      Try
		        s = Objects(i).Process.CommandLine
		        If s = "" Then s = objects(i).Process.Name
		      Catch
		        s = "Image Not Resolved."
		      End Try
		    End If
		    
		    
		    helptext = TextToPicture(s.Trim, StringColor, RGB(HelpColor.Red, HelpColor.Green, HelpColor.Blue, Globals.Transparency), gTextFont, gTextSize)
		    helptext.RGBSurface.FloodFill(helptext.Width - 1, helptext.Height - 1, RGB(HelpColor.Red, HelpColor.Green, HelpColor.Blue, Globals.Transparency))
		    Invalidate(False)
		    Return
		  Else
		    If helptext <> Nil Then
		      helptext = Nil
		      Invalidate(False)
		    End If
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub drawObject(index As Integer)
		  //Draws the object onto the buffer
		  Dim theObject As dragObject = Objects(index)
		  If index > Objects.Ubound Or index < 0 Then Return
		  If (theObject.Dynamic And hideDynamics) Then Return
		  
		  If index = currentObject Or theObject.Selected Then
		    Dim p As Picture = DrawOutline(Index)
		    buffer.Graphics.DrawPicture(p, theObject.x, theObject.y - (p.Height - theObject.image.Height))
		  End If
		  
		  If theObject.DynType <> 6 Then
		    buffer.Graphics.ForeColor = &c00000088
		    buffer.Graphics.FillRect(theObject.X + theObject.width, theObject.Y + 2, 2, theObject.height)
		    buffer.Graphics.FillRect(theObject.X, theObject.height + theObject.Y, theObject.width, 2)
		  End If
		  buffer.Graphics.ForeColor = &c00000000
		  If theObject.Dynamic Then
		    If theObject.image <> Nil And theObject.DynType <> 4  And theObject.DynType <> 6 Then
		      buffer.Graphics.DrawRect(theObject.x - 1, theObject.y - 1, theObject.image.width + 1, theObject.image.height + 1)
		    End If
		  Else
		    buffer.Graphics.DrawRect(theObject.x - 1, theObject.y - 1, theObject.width + 1, theObject.height + 1)
		  End If
		  buffer.Graphics.ForeColor = &c808080
		  If theObject.image <> Nil Then buffer.Graphics.DrawPicture(theObject.image, theObject.x, theObject.y)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DrawOutline(Index As Integer) As Picture
		  
		  Dim p As Picture
		  Dim pid As String
		  If Objects(Index).Process <> Nil Then
		    pid = "Process ID: " + Str(Objects(Index).Process.ProcessID)
		  Else
		    Select Case objects(Index).DynType
		    Case 0
		      pid = "Resource Monitor"
		    Case 1
		      pid = "Disk Drive Monitor"
		    Case 2
		      pid = "Debug Message Monitor"
		    Case 4
		      pid = objects(Index).Name
		    Case 5
		      pid = "File Multi-Tool"
		    Case 6
		      pid = Clock.BackingDate.SQLDateTime
		    End Select
		  End If
		  Dim t As Picture = TextToPicture(pid, &c000000, &cCCCCCC, gTextFont, gTextSize)
		  p = New Picture(Objects(Index).Image.Width, Objects(Index).Image.Height + t.Height)
		  p.Graphics.DrawPicture(Objects(Index).Image, 0, p.Height - Objects(Index).Image.Height)
		  p.Graphics.DrawPicture(t, 0, 2)
		  
		  Return p
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DrawSelectionRect(X1 As Integer, Y1 As Integer, X2 As Integer, Y2 As Integer)
		  Dim w, h, X, Y As Integer
		  If X1 < X2 Then
		    X = X1
		    w = X2 - X1
		  Else
		    X = X2
		    w = X1 - X2
		    X2 = X1
		    X1 = X
		  End If
		  If Y1 < Y2 Then
		    Y = Y1
		    h = Y2 - Y1
		  Else
		    Y = Y2
		    h = Y1 - Y2
		    Y2 = Y1
		    Y1 = Y
		  End If
		  #If RBVersion >= 2011.04 Then
		    buffer.Graphics.ForeColor = RGB(SelectionColor.Red, SelectionColor.Green, SelectionColor.Blue, 190)
		    buffer.Graphics.FillRect(X, Y, w, h)
		  #endif
		  buffer.Graphics.ForeColor = SelectionColor
		  buffer.Graphics.DrawRect(X, Y, w, h)
		  ClearSelection()
		  Dim items() As Integer = SelectionRectToObjects(X, Y, X2, Y2)
		  If Ubound(items) > -1 Then
		    For Each item As Integer In items
		      Objects(item).Selected = True
		    Next
		  End If
		  'Refresh(False)
		End Sub
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
		Sub Empty()
		  ScaledBackdrop = Nil
		  ReDim objects(-1)
		  ReDim activeProcesses(-1)
		  ReDim activeProcessesOld(-1)
		  InitializeDynamics()
		  Refresh(False)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub helpfaderhandler(Sender As Timer)
		  #pragma Unused Sender
		  drawHelp(Me.MouseX, Me.MouseY)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Hide(i As Integer)
		  
		  If Not Objects(i).Dynamic Then HiddenProcCount = HiddenProcCount + 1
		  currentObject = -1
		  HiddenProcs.Append(Objects(i))
		  Objects.Remove(i)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function hitpointToObject(x As Integer, y As Integer) As Integer
		  
		  //Given an (x,y) coordinate returns the index (in the objects array) of the topmost object occupying those coordinates, if any.
		  #pragma BreakOnExceptions Off
		  For i As Integer = objects.Ubound DownTo 0
		    If (objects(i).x < x) And (x < objects(i).x + objects(i).image.Width) And (objects(i).y < y) And (y < objects(i).y + objects(i).image.height) Then
		      If (Objects(i).Dynamic And hideDynamics) Then Return -1
		      Return i
		    End If
		  Next
		  
		  Return -1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub InitializeDynamics()
		  Dim cpuWin As New dragObject
		  cpuWin.DynType = 0
		  addObject(cpuWin)
		  
		  Dim diskWin As New dragObject
		  diskWin.DynType = 1
		  addObject(diskWin)
		  
		  If DebugMode Then
		    Dim debugWin As New dragObject
		    debugWin.DynType = 2
		    addObject(debugWin)
		  End If
		  '
		  'Dim mag As New dragObject  //Very slow
		  'mag.DynType = 3
		  'addObject(mag)
		  
		  Dim picdrop As New dragObject  //drop target
		  picdrop.DynType = 4
		  picdrop.SpecialHandler = AddressOf FileDropHandler
		  picdrop.ResizeTo = 50
		  picdrop.Name = "Photo Frame"
		  addObject(picdrop)
		  
		  Dim tridDrop As New dragObject  //trid target
		  tridDrop.DynType = 5
		  tridDrop.SpecialHandler = AddressOf FileToolHandler
		  addObject(tridDrop)
		  
		  
		  Dim clocktile As New dragObject  //Clock
		  clocktile.DynType = 6
		  addObject(clocktile)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function SelectionRectToObjects(x1 As Integer, y1 As Integer, x2 As Integer, y2 As Integer) As Integer()
		  Dim ret() As Integer
		  For i As Integer = objects.Ubound DownTo 0
		    If (objects(i).X < x1) And (x2 < objects(i).X + objects(i).Image.width) And (objects(i).Y < y1) And (y2 < objects(i).Y + objects(i).Image.height) _
		      Or _
		      (objects(i).X < x2) And (x1 < objects(i).X + objects(i).Image.width) And (objects(i).Y < y2) And (y1 < objects(i).Y + objects(i).Image.height) Then
		      Ret.Append(i)
		    End If
		  Next
		  Return ret
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
		  Invalidate(False)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ToggleHidden()
		  For i As Integer = UBound(HiddenProcs) DownTo 0
		    addObject(HiddenProcs.Pop)
		  Next
		  
		  currentObject = -1
		  HiddenProcCount = 0
		  Update()
		  Arrange(lastSort)
		  Invalidate(False)
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
		  Invalidate(False)
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
		        HiddenProcCount = HiddenProcCount + 1
		      End If
		    Next
		  Else
		    While sysProcs.Ubound > -1
		      addObject(sysProcs.Pop)
		      HiddenProcCount = HiddenProcCount - 1
		    Wend
		  End If
		  
		  currentObject = -1
		  
		  Update()
		  'End If
		  Arrange(lastSort)
		  Invalidate(False)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Update()
		  
		  //First, find which processes have died
		  activeProcessesOld = activeProcesses
		  activeProcesses = GetActiveProcesses()
		  Dim newProcs() As ProcessInformation = getNewProcs()
		  Dim deadProcs() As ProcessInformation = getDeadProcs()
		  
		  Dim x1, i1 As Integer
		  x1 = UBound(deadProcs)
		  i1 = UBound(Objects)
		  
		  For x As Integer = x1 DownTo 0
		    Dim theDeadProc As ProcessInformation = deadProcs(x)
		    For i As Integer = i1 DownTo 0
		      If i > UBound(Objects) Then Exit For i
		      Dim theObject As dragObject = Objects(i)
		      If theObject.Dynamic Then Continue For i
		      If theObject.Process.ProcessID = theDeadProc.ProcessID Then
		        //And remove them from the objects array
		        debug("Process " + Str(theObject.Process.ProcessID) + " died")
		        If theObject.Alert Then
		          FlashWindow(Window1.Handle)
		          Call MsgBox(theObject.Process.Name + " died!", 16, "Process Termination Notice")
		        End If
		        Objects.Remove(i)
		        Exit For i
		      End If
		    Next
		  Next
		  
		  Static dynInited As Boolean
		  If Not dynInited Then
		    InitializeDynamics()
		    dynInited = True
		  End If
		  
		  //Then, add any new processes that we want to show
		  For Each proc As ProcessInformation In newProcs
		    Dim no As New dragObject(proc)
		    addObject(no)
		  Next
		  
		  //If we added or removed any objects, we should re-sort
		  If UBound(newProcs) > -1 Or UBound(activeProcessesOld) > -1 Then
		    Arrange(lastSort)
		  End If
		  
		Exception err
		  Break
		  Return
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		BackColor As Color = &c808080
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
		DropIndex As Integer = -1
	#tag EndProperty

	#tag Property, Flags = &h0
		Effects As Integer = 0
	#tag EndProperty

	#tag Property, Flags = &h0
		FPS As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private helpfader As Timer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private helptext As Picture
	#tag EndProperty

	#tag Property, Flags = &h0
		HiddenProcCount As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private HiddenProcs() As dragObject
	#tag EndProperty

	#tag ComputedProperty, Flags = &h21
		#tag Getter
			Get
			  Dim p As New Picture(Me.Width, Me.Height, 24)
			  p.Graphics.ForeColor = &ccccccc
			  p.Graphics.FillRect(0, 0, p.Width, p.Height)
			  p.Graphics.ForeColor = &c000000
			  p.Graphics.TextFont = "System"
			  p.Graphics.TextSize = 75
			  Dim nm As String = "One Moment Please..."
			  Dim strWidth, strHeight As Integer
			  strWidth = p.Graphics.StringWidth(nm)
			  strHeight = p.Graphics.StringHeight(nm, p.Width)
			  p.Graphics.DrawString(nm, ((p.Width/2) - (strWidth/2)), ((p.Height/2) + (strHeight/4)))
			  
			  
			  Return p
			End Get
		#tag EndGetter
		Private InitImg As Picture
	#tag EndComputedProperty

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
		Private mInitImg As Picture
	#tag EndProperty

	#tag Property, Flags = &h21
		Private NextX As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private NextY As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		#tag Note
			The heart of this whole operation: an array of dragObjects. Each dragObject corresponds to a "window" drawn on the Parent dragContainer
		#tag EndNote
		objects() As dragObject
	#tag EndProperty

	#tag Property, Flags = &h0
		ScaledBackdrop As Picture
	#tag EndProperty

	#tag Property, Flags = &h0
		SelectionColor As Color
	#tag EndProperty

	#tag Property, Flags = &h0
		ShowText As Boolean = True
	#tag EndProperty

	#tag Property, Flags = &h0
		sysProcs() As dragObject
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
			Name="DoubleBuffer"
			Visible=true
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="DropIndex"
			Group="Behavior"
			InitialValue="-1"
			Type="Integer"
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
			Name="HiddenProcCount"
			Group="Behavior"
			Type="Integer"
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
			Name="ScaledBackdrop"
			Group="Behavior"
			Type="Picture"
		#tag EndViewProperty
		#tag ViewProperty
			Name="SelectionColor"
			Group="Behavior"
			InitialValue="&c000000"
			Type="Color"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ShowText"
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
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
