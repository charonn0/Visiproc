#tag Class
Protected Class graph
Inherits Canvas
	#tag Event
		Sub MouseEnter()
		  If drawFinger Then
		    Me.MouseCursor = System.Cursors.FingerPointer
		  End If
		End Sub
	#tag EndEvent

	#tag Event
		Sub MouseExit()
		  If drawFinger Then
		    Me.MouseCursor = System.Cursors.StandardPointer
		  End If
		End Sub
	#tag EndEvent

	#tag Event
		Sub Open()
		  Me.myBuff = New Picture(Me.Width, Me.Height, 24)
		  drawBack(myBuff)
		  //ReDim history(Me.Width)
		  drawing = New CriticalSection
		End Sub
	#tag EndEvent

	#tag Event
		Sub Paint(g As Graphics)
		  If mybuff = Nil Then mybuff = New Picture(Me.Width, Me.Height, 24)
		  g.DrawPicture(mybuff, 0, 0)
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub addPoint(point() As Integer, mode As Integer, advance As Boolean = True)
		  If drawing.TryEnter Then
		    If Not advance Then 
		      time = time - 1
		    End If
		    myBuff = New Picture(Me.Width, Me.Height, 24)
		    drawBack(myBuff)
		    Dim buff As Picture = myBuff
		    buff.Graphics.ForeColor = &c00FF00
		    If advance Then
		      If UBound(history) * 10 >= Me.Width Then
		        history.Remove(0)
		      End If
		    Else
		      If UBound(history) > -1 Then history.Remove(history.Ubound)
		    End If
		    
		    If mode = 0 Then
		      buff.Graphics.ForeColor = &c00FF00
		      if point(0) = 0 Then point(0) = 1
		      history.Append(Point(0))
		    Else
		      buff.Graphics.ForeColor = &cF47A00
		      if point(2) = 0 Then point(2) = 1
		      history.Append(Point(2))
		    End If
		    For i As Integer = 0 To UBound(history)
		      Try
		        buff.Graphics.DrawLine(i * 10, Me.Height - history(i - 1), i * 10 + 10, Me.Height - history(i))
		      Catch OutOfBoundsException
		        buff.Graphics.DrawLine(0, Me.Height - history(i), 10, Me.Height - history(i))
		      End Try
		    Next
		    myBuff = buff
		    Refresh(False)
		    drawing.Leave
		  Else
		    Return
		  End If
		End Sub
	#tag EndMethod

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


	#tag Property, Flags = &h0
		drawFinger As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private drawing As CriticalSection
	#tag EndProperty

	#tag Property, Flags = &h0
		history() As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		myBuff As Picture
	#tag EndProperty

	#tag Property, Flags = &h0
		showPop As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private time As Integer = 0
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
			Name="drawFinger"
			Group="Behavior"
			Type="Boolean"
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
			Name="myBuff"
			Group="Behavior"
			Type="Picture"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="showPop"
			Group="Behavior"
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
