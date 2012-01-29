#tag Class
Protected Class dragContainer
Inherits Canvas
	#tag Event
		Function ConstructContextualMenu(base as MenuItem, x as Integer, y as Integer) As Boolean
		  #pragma Unused x
		  #pragma Unused y
		  If currentObject = -1 Then Return False
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
		      procID.terminate()
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
		  Refresh(False)
		  
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
		    entryDetail.showMe(Objects(currentObject).Process)
		  End If
		End Sub
	#tag EndEvent

	#tag Event
		Function MouseDown(X As Integer, Y As Integer) As Boolean
		  //First, check whether an object was clicked on
		  currentObject = hitpointToObject(x, y)
		  If currentObject > -1 Then
		    //Then bring it to the foreground
		    bringToFront(currentObject)
		    If IsContextualClick Then
		      //The user wants a menu for the oject
		      menuUp = True
		    End If
		  End If
		  Refresh(False)
		  lastX = X
		  lastY = Y
		  Return True
		End Function
	#tag EndEvent

	#tag Event
		Sub MouseDrag(X As Integer, Y As Integer)
		  If currentObject > -1 Then
		    //Calculate the new position of the object, update the object, then refresh the control.
		    Dim objX As Integer = x - lastx
		    Dim objY As Integer = y - lasty
		    lastx = x
		    lasty = y
		    objects(currentObject).x = objects(currentObject).x + objX
		    objects(currentObject).y = objects(currentObject).y + objY
		    Refresh(False)
		  End If
		End Sub
	#tag EndEvent

	#tag Event
		Sub MouseMove(X As Integer, Y As Integer)
		  Dim i As Integer = hitpointToObject(X, Y)
		  
		  If i > -1 Then
		    Dim s As String
		    If Objects(i).Dynamic Then 
		      Dim d() As Double = lastCPU
		      s = "CPU: " + Format(d(0), "##0.00\%") + "; RAM: " + Format(LastMem, "##0.00\%")
		      If s.InStr("J") > 0 Then Break
		    Else
		      Try
		        s = getCmdLine(Objects(i).Process)
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
		    strWidth = helptext.Graphics.StringWidth(s)
		    strHeight = helptext.Graphics.StringHeight(s, strWidth + 5)
		    helptext = New Picture(strWidth + 4, strHeight + 4, 32)
		    helptext.Graphics.ForeColor = &cFFFF80
		    helptext.Graphics.FillRect(0, 0, helptext.Width, helptext.Height)
		    helptext.Graphics.ForeColor = &c000000
		    helptext.Graphics.DrawString(s, 2, ((helptext.Height/2) + (strHeight/4)))
		    Refresh(False)
		  Else
		    If helptext <> Nil Then
		      helptext = Nil
		      Refresh(False)
		    End If
		  End If
		End Sub
	#tag EndEvent

	#tag Event
		Sub MouseUp(X As Integer, Y As Integer)
		  #pragma Unused x
		  #pragma Unused y
		  'If Not menuUp Then currentObject = -1
		  
		End Sub
	#tag EndEvent

	#tag Event
		Sub Open()
		  buffer = New Picture(Me.Width, Me.Height, 24)
		  buffer.Graphics.ForeColor = &c808080
		  Dim cpuWin As New dragObject
		  cpuWin.DynType = 0
		  Dim memWin As New dragObject
		  memWin.DynType = 1
		  addObject(cpuWin)
		  'addObject(memWin)
		  'If DebugMode Then
		  'DebugTimer = New Timer
		  'DebugTimer.Period = 50000
		  'AddHandler DebugTimer.Action, AddressOf DebugTimerHander
		  'DebugTimer.Mode = Timer.ModeMultiple
		  'End If
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
		  buffer.Graphics.ForeColor = &c808080
		  buffer.Graphics.FillRect(0, 0, buffer.Width, buffer.Height)
		  
		  //Draw each dragObject one by one, starting with the bottom-most
		  For i As Integer = 0 To objects.Ubound
		    drawObject(i)
		  Next
		  
		  If helptext <> Nil Then
		    buffer.Graphics.DrawPicture(helptext, Me.MouseX + 10, Me.MouseY + 10)
		  End If
		  //Draw the buffer to the Canvas
		  g.DrawPicture(buffer, 0, 0)
		  
		  
		  
		  
		  
		  
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub addObject(no As dragObject)
		  //Adds a new dragObject to the objects array, then forces a refresh so that it gets drawn.
		  If no.x > Me.Width Or no.y > Me.Height Then
		    no.x = no.x - 200
		    no.y = no.y - 200
		  End If
		  objects.Append(no)
		  Refresh(False)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Arrange(Order As Integer = 0)
		  If Order = -1 Then Return
		  Dim x As Integer = 10
		  Dim y As Integer = 10
		  
		  If Order = 1 Then
		    Dim s() As String
		    Dim u() As Integer
		    For i As Integer = 0 To UBound(objects)
		      If objects(i).Dynamic Then
		        s.Append("ZZZZZZZ")
		      Else
		        s.Append(objects(i).Process.Name)
		      End If
		      u.Append(i)
		    Next
		    s.SortWith(u)
		    For i As Integer = 0 To UBound(u)
		      Objects(u(i)).x = x
		      Objects(u(i)).y = y
		      If y + 60 <= Self.Height Then
		        y = y + 50
		      Else
		        y = 10
		        x = x + 210
		      End If
		      
		    Next
		  ElseIf Order = 2 Then
		    Dim s() As Integer
		    Dim u() As Integer
		    For i As Integer = 0 To UBound(objects)
		      If objects(i).Dynamic Then
		        s.Append(999999)
		      Else
		        s.Append(objects(i).Process.ProcessID)
		      End If
		      u.Append(i)
		    Next
		    s.SortWith(u)
		    For i As Integer = 0 To UBound(u)
		      Objects(u(i)).x = x
		      Objects(u(i)).y = y
		      If y + 60 <= Self.Height Then
		        y = y + 50
		      Else
		        y = 10
		        x = x + 210
		      End If
		      
		    Next
		  Else
		    For i As Integer = UBound(Objects) DownTo 0
		      Objects(i).x = x
		      Objects(i).y = y
		      
		      If y + 60 <= Self.Height Then
		        y = y + 50
		      Else
		        y = 10
		        x = x + 210
		      End If
		      
		    Next
		  End If
		  lastSort = Order
		  //First, check whether an object was clicked on
		  If currentObject > -1 Then
		    //Then bring it to the foreground
		    bringToFront(currentObject)
		  End If
		  Refresh(False)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub bringToFront(index As Integer)
		  //Brings the object at Index to the "front" (i.e. moves it to the UBound of the objects array.
		  //Objects get drawn from the zeroth element in the objects array, so the "top" object gets drawn last.
		  If index = -1 Then Return
		  Dim obj As dragObject = objects(index)
		  objects.Remove(index)
		  objects.Append(obj)
		  currentObject = objects.Ubound
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub deleteObject(Index As Integer)
		  objects.Remove(Index)
		  Refresh()
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
		  buffer.Graphics.DrawRect(objects(index).x - 1, objects(index).y - 1, objects(index).width + 1, objects(index).height + 1)
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
		    pid = "Resource Monitor"
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
		  Dim memWin As New dragObject
		  memWin.DynType = 1
		  addObject(cpuWin)
		  Refresh()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function hitpointToObject(x As Integer, y As Integer) As Integer
		  //Given an (x,y) coordinate returns the index (in the objects array) of the topmost object occupying those coordinates, if any.
		  For i As Integer = objects.Ubound DownTo 0
		    If (objects(i).x < x) And (x < objects(i).x + objects(i).width) And (objects(i).y < y) And (y < objects(i).y + objects(i).height) Then
		      Return i
		    End If
		  Next
		  Return -1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Update(force As Boolean = False)
		  activeProcessesOld = activeProcesses
		  activeProcesses = GetActiveProcesses()
		  Dim newProcs() As ProcessInformation = getNewProcs()
		  Dim deadProcs() As ProcessInformation = getDeadProcs()
		  If UBound(newProcs) > -1 Or UBound(deadProcs) > -1 Or force = True Then
		    For x As Integer = UBound(deadProcs) DownTo 0
		      For i As Integer = UBound(Objects) DownTo 0
		        If objects(i).Process.ProcessID = deadProcs(x).ProcessID Then
		          Objects.Remove(i)
		          Exit For i
		        End If
		      Next
		    Next
		    If force Then
		      Call GetWindowList()
		      
		    End If
		    
		    For Each proc As ProcessInformation In newProcs
		      If proc.isCritical And HideSystemProcs Then
		        Continue
		      Else
		        Dim no As New dragObject(proc)
		        'If force Then Call IsSuspended(proc)
		        addObject(no)
		      End If
		    Next
		    If UBound(newProcs) > -1 Or UBound(activeProcessesOld) > -1 Then
		      Arrange(lastSort)
		    End If
		    'If force Then
		    'For i As Integer = 0 To UBound(Objects)
		    'Objects(i).Update(force)
		    'Next
		    'End If
		    Refresh(False)
		  End If
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private buffer As Picture
	#tag EndProperty

	#tag Property, Flags = &h21
		#tag Note
			Represents the index of the currently active object in the objects array
		#tag EndNote
		Private currentObject As Integer = -1
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
