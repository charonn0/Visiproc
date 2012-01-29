#tag Class
Protected Class dragObject
	#tag Method, Flags = &h0
		Sub Constructor()
		  Dim rand As New Random
		  image = New Picture(250, 150, 24)
		  Dynamic = True
		  x = Rand.InRange(0, Window1.dragContainer1.Width)
		  y = Rand.InRange(0, Window1.dragContainer1.Height)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(proc As ProcessInformation)
		  Dim rand As New Random
		  Process = proc
		  CreateTile(HilightOn)
		  x = Rand.InRange(0, Window1.dragContainer1.Width)
		  y = Rand.InRange(0, Window1.dragContainer1.Height)
		  
		  flashTimer = New Timer
		  If FirstRun Then
		    flashTimer.Period = 100
		  Else
		    flashTimer.Period = 1000
		  End If
		  AddHandler flashTimer.Action, AddressOf TimerHandler
		  flashTimer.Mode = Timer.ModeSingle
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub CreateTile(NewProc As Boolean = True)
		  'If Process.Name = "notepad++.exe" Then Break
		  If Dynamic Then Return
		  Dim ico As New Picture(10, 10, 32)
		  drawText(ico, True, NewProc)
		  If NewProc And HilightOn Then
		    ico.Graphics.ForeColor = &c00FF00//&cFF0000
		    ico.Graphics.FillRect(0, 0, ico.width, ico.height)
		    drawText(ico, False, NewProc)
		  End If
		  If Process.Suspended Then
		    ico.Graphics.ForeColor = &c5C5FBC
		    ico.Graphics.FillRect(0, 0, ico.width, ico.height)
		    drawText(ico, False, NewProc)
		  End If
		  If ICOSize = 32 Then
		    ico.Graphics.DrawPicture(Process.largeIcon, 0, 0)
		  Else
		    ico.Graphics.DrawPicture(Process.smallIcon, 0, 0)
		  End If
		  image = ico
		  //width = image.Width
		  //height = image.Height
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub drawText(ByRef buffer As Picture, clear As Boolean = True, newproc As Boolean = False)
		  #pragma BreakOnExceptions Off
		  buffer.Graphics.TextFont = "System"
		  buffer.Graphics.TextSize = 12
		  Dim nm As String
		  If Dynamic Then
		    nm = "Resource Monitor"
		  Else
		    nm = Process.Name
		  End If
		  Dim strWidth, strHeight As Integer
		  strWidth = buffer.Graphics.StringWidth(nm)
		  strHeight = buffer.Graphics.StringHeight(nm, buffer.Width)
		  If clear Then 
		    buffer = New Picture(strWidth + 64, ICOSize, 32)
		  End If
		  Try
		    If newproc And HilightOn And Not Dynamic Then
		      buffer.Graphics.ForeColor = &cFF0000
		    ElseIf Process.isCritical And HilightOn Then
		      If Process.path <> Nil Then
		        Dim d As FolderItem = Process.path.Parent
		        For i As Integer = 0 To 9
		          If d.Name = "WINDOWS" Or d.Name = "WinNt" Then
		            Dim e As FolderItem = SpecialFolder.Windows.Parent
		            If d.Parent.Name = e.Name Then
		              buffer.Graphics.ForeColor = &c00A8F9
		              Exit For i
		            ElseIf Process.path.SystemFile Then
		              buffer.Graphics.ForeColor = &c00FFFF
		              Exit For i
		            Else
		              buffer.Graphics.ForeColor = &cF5772C
		              Exit For i
		            End If
		          End If
		          d = d.Parent
		        Next
		      Else
		        buffer.Graphics.ForeColor = &cFFFFFE
		      End If
		      
		    Else
		      buffer.Graphics.ForeColor = &cFFFFFE
		    End If
		  Catch NilObjectException
		    buffer.Graphics.ForeColor = &cFFFFFE
		  End Try
		  If clear Then buffer.Graphics.FillRect(0, 0, buffer.Width, buffer.Height)
		  buffer.Graphics.ForeColor = &c000000
		  buffer.Graphics.DrawString(nm, buffer.Width - strWidth - 10, ((buffer.Height/2) + (strHeight/4)))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Paint()
		  CreateTile(False)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub TimerHandler(Sender As Timer)
		  #pragma Unused Sender
		  Paint()
		End Sub
	#tag EndMethod


	#tag Note, Name = About This Class
		The dragObject is the fundamental container of the data being displayed in a dragContainer.
		
		At the moment, only the absolutely necessary properties are defined. You may wish to add more properties that seem
		logical with what you intend to accomplish. For example, if the dragObject is going to represent a file or a folder, then
		perhaps adding a File As FolderItem property.
		
		The basic Constructor for this class will create a rectanglular picture object of random size, shape, position, 
		and color (within certain bounds.) The alternate Constructor(the one that accepts a Picture) will use the passed 
		picture instead of generating one. In either case, the picture object is assigned to the image property.
		
		All drawing is handled by the parent dragContainer.
	#tag EndNote


	#tag Property, Flags = &h0
		Dynamic As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		DynType As Integer = 0
	#tag EndProperty

	#tag Property, Flags = &h21
		Private flashTimer As Timer
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mimage.Height
			End Get
		#tag EndGetter
		height As Integer
	#tag EndComputedProperty

	#tag Property, Flags = &h0
		history() As Integer
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  If Not Dynamic Then
			    return mimage
			  Else
			    If DynType = 0 Then
			      Return CPUBuffer
			    ElseIf DynType = 1 Then
			      Return diskBuffer
			    End If
			  End If
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mimage = value
			End Set
		#tag EndSetter
		image As Picture
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private mimage As Picture
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mwidth As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		Process As ProcessInformation
	#tag EndProperty

	#tag Property, Flags = &h21
		Private time As Integer = 0
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mimage.Width
			End Get
		#tag EndGetter
		width As Integer
	#tag EndComputedProperty

	#tag Property, Flags = &h0
		x As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		y As Integer
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Dynamic"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="DynType"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="height"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="image"
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
		#tag ViewProperty
			Name="width"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="x"
			Group="Behavior"
			InitialValue="75"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="y"
			Group="Behavior"
			InitialValue="75"
			Type="Integer"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
