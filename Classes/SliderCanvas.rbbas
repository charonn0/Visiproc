#tag Class
Protected Class SliderCanvas
Inherits Canvas
	#tag Event
		Function KeyDown(Key As String) As Boolean
		  //up = &h1E
		  //down = &h1F
		  If Asc(key) = &h1E Then
		    If Me.Value >= Me.Maximum Then
		      Beep()
		    Else
		      Me.value = Me.value + 1
		    End If
		    Return True
		  ElseIf Asc(key) = &h1F Then
		    If Me.Value <= 0 Then
		      Beep()
		    Else
		      Me.value = Me.value - 1
		    End If
		    Return True
		  End If
		  
		  Return False
		End Function
	#tag EndEvent

	#tag Event
		Function MouseDown(X As Integer, Y As Integer) As Boolean
		  #pragma Unused X
		  #pragma Unused Y
		  
		  Return True
		End Function
	#tag EndEvent

	#tag Event
		Sub MouseDrag(X As Integer, Y As Integer)
		  #pragma Unused Y
		  If Not EnableSlider Then
		    Refresh()
		    Return
		  End If
		  Me.value = (x * Me.maximum \ Me.Width)
		End Sub
	#tag EndEvent

	#tag Event
		Sub MouseEnter()
		  Me.MouseCursor = System.Cursors.FingerPointer
		End Sub
	#tag EndEvent

	#tag Event
		Sub MouseExit()
		  Me.MouseCursor = System.Cursors.FingerPointer
		End Sub
	#tag EndEvent

	#tag Event
		Sub Paint(g As Graphics)
		  //Repaints the canvas
		  //This event fires whenever the control has been painted by something other than itself
		  //calculates and draws a new buffer with val=0 or recalculates the old buffer and paints it, or simply repaints the old buffer
		  
		  Static myHeight As Integer
		  Static mywidth As Integer
		  
		  If mywidth <> Me.Width Or myHeight <> Me.Height Then
		    drawingBuffer = New Picture(Me.Width, Me.Height, 32)
		    drawingBuffer.Transparent = 1
		    Me.Value = mvalue
		  Else
		    If drawingBuffer <> Nil Then
		      g.DrawPicture(drawingBuffer, 0, 0)
		    Else
		      Me.value = 0
		    End If
		  End If
		  mywidth = Me.Width
		  myHeight = Me.Height
		  'Me.Enabled = EnableSlider
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h21
		Private Sub drawBar(filledWidth As Integer)
		  //Draws the actual progress bar part of the control
		  
		  Dim myHeight, myWidth As Integer
		  myHeight = Me.Height
		  myWidth = Me.Width
		  
		  Dim ratio, endratio as Double
		  For i As Integer = 5 To drawingBuffer.Height - 5
		    If Gradient Then
		      ratio = ((drawingBuffer.Height - i) / drawingBuffer.Height)
		      endratio = (i / drawingBuffer.Height)
		      drawingBuffer.Graphics.ForeColor = RGB(gradientEnd.Red * endratio + barColor.Red * ratio, gradientEnd.Green * endratio + barColor.Green * ratio, _
		      gradientEnd.Blue * endratio + barColor.Blue * ratio)
		    Else
		      drawingBuffer.Graphics.ForeColor = barColor
		    End If
		    drawingBuffer.Graphics.DrawLine(0, i, filledWidth, i)
		  next
		  If Not EnableSlider Then GreyScale(drawingBuffer)  //FIXME?
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub drawBarwell()
		  //Draws the background of the control
		  
		  Dim myHeight, myWidth As Integer
		  myHeight = Me.Height
		  myWidth = Me.Width
		  
		  If barWell = &cFFFFFF Then
		    drawingBuffer.Graphics.ForeColor = &cFFFFFE
		  Else
		    drawingBuffer.Graphics.ForeColor = barWell
		  End If
		  
		  
		  drawingBuffer.Graphics.FillRect(0, 0, myWidth, myHeight)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub drawBox()
		  //Draws the outline of the control if Border = True
		  Dim myHeight, myWidth As Integer
		  myHeight = Me.Height
		  myWidth = Me.Width
		  drawingBuffer.Graphics.ForeColor = boxColor
		  drawingBuffer.Graphics.DrawRect(0, 0, myWidth, myHeight)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub drawThumb(point As Integer)
		  
		  Dim thumb As New Picture(Me.Height \ 3, Me.Height, 32)
		  thumb.Transparent = 1
		  thumb.Graphics.ForeColor = ThumbColor
		  thumb.Graphics.FillRect(0, 0, thumb.Width, thumb.Height)
		  thumb.Graphics.ForeColor = ThumbColor
		  thumb.Graphics.FillRoundRect(0, 0, thumb.Width, thumb.Height, 5, 5)
		  If point <= 0 Then
		    drawingBuffer.Graphics.DrawPicture(thumb, 0 - thumb.Width \ 2, 0)
		  ElseIf point >= Me.Width Then
		    drawingBuffer.Graphics.DrawPicture(thumb, Me.Width - (thumb.Width \ 2), 0)
		  Else
		    drawingBuffer.Graphics.DrawPicture(thumb, point - (thumb.Width \ 2), 0)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub drawTicks()
		  If Not Ticks Then Return
		  Dim markStep As Integer = Me.Width \ 20
		  For i As Integer = 0 To Me.Width Step markStep
		    drawingBuffer.Graphics.ForeColor = TickColor
		    drawingBuffer.Graphics.DrawLine(i, Me.Height - Me.Height \ 4, i, Me.Height)
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub GreyScale(p As Picture)
		  //Converts the passed Picture to greyscale.
		  //Can take a few seconds on very large Pictures
		  //This function was *greatly* optimized by user 'doofus' on the RealSoftware forums:
		  //http://forums.realsoftware.com/viewtopic.php?f=1&t=42327&sid=4e724091fc9dd70fd5705110098adf67
		  
		  If p = Nil Then Raise New NilObjectException
		  Dim w As Integer = p.Width
		  Dim h As Integer = p.Height
		  Dim surf As RGBSurface = p.RGBSurface
		  
		  If surf = Nil Then Raise New NilObjectException
		  
		  Dim greyColor(255) As Color //precompute the 256 grey colors
		  For i As Integer = 0 To 255
		    greyColor(i) = RGB(i, i, i)
		  Next
		  
		  Dim X, Y, intensity As Integer, c As Color
		  For X = 0 To w
		    For Y = 0 To h
		      c = surf.Pixel(X, Y)
		      intensity = c.Red * 0.30 + c.Green * 0.59 + c.Blue * 0.11
		      surf.Pixel(X, Y) = greyColor(intensity) //lookup grey
		    Next
		  Next
		  'Break
		End Sub
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event ValueChanged()
	#tag EndHook


	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mbarColor
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mbarColor = value
			  Me.Value = Me.Value
			End Set
		#tag EndSetter
		BarColor As Color
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mbarWell
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mbarWell = value
			  Me.Value = Me.Value
			End Set
		#tag EndSetter
		BarWell As Color
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mBorder
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mBorder = value
			  Me.Value = Me.Value
			End Set
		#tag EndSetter
		Border As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mboxColor
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mboxColor = value
			  Me.Value = Me.Value
			End Set
		#tag EndSetter
		BoxColor As Color
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private drawingBuffer As Picture
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mEnableSlider
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  If drawingBuffer <> Nil Then
			    mEnableSlider = value
			    Refresh()
			  End If
			End Set
		#tag EndSetter
		EnableSlider As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mhasGradient
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mhasGradient = value
			  Me.Value = Me.Value
			End Set
		#tag EndSetter
		Gradient As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mgradientEnd
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mgradientEnd = value
			  Me.Value = Me.Value
			End Set
		#tag EndSetter
		GradientEnd As Color
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mmaximum
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mmaximum = value
			  Me.Value = Me.Value
			End Set
		#tag EndSetter
		Maximum As Integer
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private mbarColor As Color = &c808080
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mbarWell As Color
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mBorder As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mboxColor As Color = &c808080
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mEnableSlider As Boolean = True
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mgradientEnd As Color
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mhasGradient As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mHasTicks As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mMaximum As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mtextColor As Color
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mThumbColor As Color
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTickColor As Color
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mvalue As Integer
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mThumbColor
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mThumbColor = value
			  Me.Value = Me.Value
			End Set
		#tag EndSetter
		ThumbColor As Color
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mTickColor
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mTickColor = value
			  Me.Value = Me.Value
			End Set
		#tag EndSetter
		TickColor As Color
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mHasTicks
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mHasTicks = value
			  Me.Value = Me.Value
			End Set
		#tag EndSetter
		Ticks As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mvalue
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  //Calculates x, where x/Control.Width = val/maximum
			  //Invokes the drawing methods
			  mvalue = value
			  If Me.Width <= 0 Or Me.Height <= 0 Then Return
			  If mvalue > maximum Then mvalue = maximum
			  If mvalue < 0 Then mvalue = 0
			  Dim filledWidth As Integer = (((value * 100) / maximum) * (Me.Width / 100))
			  
			  If drawingBuffer = Nil Then
			    drawingBuffer = New Picture(Me.Width, Me.Height, 32)
			    drawingBuffer.Transparent = 1
			    drawingBuffer.Graphics.ForeColor = &cFFFFFF
			    drawingBuffer.Graphics.FillRect(0, 0, drawingBuffer.Width, drawingBuffer.Height)
			  End If
			  drawBarwell()
			  drawTicks()
			  drawBar(filledWidth)
			  If Border Then drawBox()
			  drawThumb(FilledWidth)
			  'If Me.Graphics <> Nil Then
			  'Me.Graphics.DrawPicture(drawingBuffer, 0, 0)
			  'End If
			  
			  Refresh(False)
			  ValueChanged()
			  
			End Set
		#tag EndSetter
		Value As Integer
	#tag EndComputedProperty


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
			Group="Appearance"
			Type="Picture"
			EditorType="Picture"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="barColor"
			Visible=true
			Group="Behavior"
			InitialValue="&c000000"
			Type="Color"
		#tag EndViewProperty
		#tag ViewProperty
			Name="barWell"
			Visible=true
			Group="Behavior"
			InitialValue="&cC0C0C0"
			Type="Color"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Border"
			Visible=true
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="boxColor"
			Visible=true
			Group="Behavior"
			InitialValue="&c000000"
			Type="Color"
		#tag EndViewProperty
		#tag ViewProperty
			Name="DoubleBuffer"
			Group="Behavior"
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
			Name="EnableSlider"
			Visible=true
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="EraseBackground"
			Group="Behavior"
			Type="Boolean"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Gradient"
			Visible=true
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="gradientEnd"
			Visible=true
			Group="Behavior"
			InitialValue="&c009B4E"
			Type="Color"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Height"
			Visible=true
			Group="Position"
			InitialValue="25"
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
			Group="Initial State"
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
			Name="maximum"
			Visible=true
			Group="Behavior"
			InitialValue="100"
			Type="Integer"
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
			Group="Position"
			Type="Boolean"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ThumbColor"
			Visible=true
			Group="Behavior"
			InitialValue="&c000000"
			Type="Color"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TickColor"
			Visible=true
			Group="Behavior"
			InitialValue="&c000000"
			Type="Color"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Ticks"
			Visible=true
			Group="Behavior"
			Type="Boolean"
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
			Name="value"
			Visible=true
			Group="Behavior"
			Type="Integer"
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
