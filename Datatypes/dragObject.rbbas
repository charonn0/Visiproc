#tag Class
Protected Class dragObject
	#tag Method, Flags = &h0
		Sub Constructor()
		  Dim rand As New Random
		  //image = New Picture(250, 150, 24)
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
		  flashTimer.Period = 1000
		  
		  AddHandler flashTimer.Action, AddressOf TimerHandler
		  flashTimer.Mode = Timer.ModeSingle
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub CreateTile(NewProc As Boolean = True)
		  If Dynamic Then Return
		  Dim ico As New Picture(10, 10)', 32)
		  drawText(ico, NewProc)
		  ico.Graphics.DrawPicture(Process.largeIcon, 0, 0)
		  mimage = ico
		  
		Exception OutOfBoundsException
		  mimage = noicon_32
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub drawText(ByRef buffer As Picture, newproc As Boolean = False)
		  #pragma BreakOnExceptions Off
		  Dim nm As Picture = TextToPicture(Process.Name, StringColor)
		  buffer = New Picture(nm.Width + 64, 32)', 32)
		  Try
		    If newproc And HilightOn And Not Dynamic Then
		      buffer.Graphics.ForeColor = RGB(NewProcColor.Red, NewProcColor.Green, NewProcColor.Blue, 0)
		    ElseIf Process.isCritical And HilightOn Then
		      If Process.path <> Nil Then
		        Dim d As FolderItem = Process.path.Parent
		        For i As Integer = 0 To 9
		          If d.Name = "WINDOWS" Or d.Name = "WinNt" Then
		            Dim e As FolderItem = SpecialFolder.Windows.Parent
		            If d.Parent.Name = e.Name Then
		              buffer.Graphics.ForeColor = RGB(SystemProcColor.Red, SystemProcColor.Green, SystemProcColor.Blue, Globals.Transparency)
		              Exit For i
		            ElseIf Process.path.SystemFile Then
		              buffer.Graphics.ForeColor = RGB(SystemProcColor.Red, SystemProcColor.Green, SystemProcColor.Blue, Globals.Transparency)
		              Exit For i
		            Else
		              buffer.Graphics.ForeColor = RGB(InvalidSystemProcColor.Red, InvalidSystemProcColor.Green, InvalidSystemProcColor.Blue, Globals.Transparency)
		              Exit For i
		            End If
		          End If
		          d = d.Parent
		        Next
		      Else
		        If Process.ProcessID = 0 Or Process.ProcessID = 4 Then
		          buffer.Graphics.ForeColor = RGB(SystemProcColor.Red, SystemProcColor.Green, SystemProcColor.Blue, Globals.Transparency)
		        Else //?? not sure why I put this here...
		          buffer.Graphics.ForeColor = RGB(SystemProcColor.Red, SystemProcColor.Green, SystemProcColor.Blue, Globals.Transparency)
		        End If
		      End If
		      
		    Else
		      buffer.Graphics.ForeColor = RGB(NormalProcColor.Red, NormalProcColor.Green, NormalProcColor.Blue, Globals.Transparency)
		    End If
		  Catch NilObjectException
		    buffer.Graphics.ForeColor = RGB(NormalProcColor.Red, NormalProcColor.Green, NormalProcColor.Blue, Globals.Transparency)
		  End Try
		  'buffer.Graphics.FillRect(0, 0, buffer.Width, buffer.Height)
		  nm = TextToPicture(Process.Name, StringColor, buffer.Graphics.ForeColor, gTextFont, gTextSize)
		  buffer.Graphics.DrawPicture(nm, 32, 0)
		  buffer.RGBSurface.FloodFill(buffer.Width - 1, buffer.Height - 1, buffer.Graphics.ForeColor)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Paint()
		  CreateTile(False)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Resize(p As Picture) As Picture
		  Dim wRatio, hRatio As Double
		  If ResizeTo > 150 Then ResizeTo = 150
		  If ResizeTo < 10 Then ResizeTo = 10
		  'If p = Nil Then p = mimage
		  If p = Nil Then
		    Dim dynpic As Picture
		    Select Case DynType
		    Case 0
		      dynpic = CPUBuffer
		      p = dynpic
		    Case 1
		      If diskBuffer = Nil Then PollDisks()
		      dynpic = diskBuffer
		      p = dynpic
		    Case 2
		      dynpic = debugBuffer
		      p = dynpic
		    Case 3
		      dynpic = magImage
		      p = dynpic
		    Case 4
		      dynpic = photo
		      p = dynpic
		    Case 6
		      dynpic = Clock.ShowTime(New Date)
		      p = dynpic
		    End Select
		  End If
		  wRatio = (ResizeTo * p.width) / 100
		  hRatio = (ResizeTo * p.Height) / 100
		  If wRatio = p.Width And hRatio = p.Height Then Return p
		  Static photo As Picture
		  If photo = Nil Then photo = New Picture(1, 1, 1)
		  If photo.Width <> wRatio Or photo.Height <> hRatio Then
		    If p.Width > p.Height Then
		      Photo = New Picture(wRatio, hRatio, 32)
		    Else
		      Photo = New Picture(wRatio, hRatio, p.Depth)
		    End If
		    Photo.Graphics.DrawPicture(p, 0, 0, Photo.Width, Photo.Height, 0, 0, p.Width, p.Height)
		  End If
		  
		  
		  Return photo
		  
		Exception
		  Return p
		End Function
	#tag EndMethod

	#tag DelegateDeclaration, Flags = &h0
		Delegate Function SpecialFuntion(Data As MemoryBlock) As Boolean
	#tag EndDelegateDeclaration

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
		Alert As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		Dynamic As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		DynType As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private flashTimer As Timer
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return image.Height
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
			  //If Hidden Then Return New Picture(1, 1, 1)
			  
			  Dim ret As Picture
			  If Not Dynamic Then
			    ret = mimage
			  Else
			    Select Case DynType
			    Case 0
			      Ret = CPUBuffer
			    Case 1
			      Ret = diskBuffer
			    Case 2
			      PollDebug()
			      Ret = debugBuffer
			    Case 3
			      Ret = magImage
			    Case 4  //Photo tile
			      If PhotoFile <> Nil Then
			        If PhotoFile.Exists Then
			          Photo = Photo.Open(PhotoFile)
			          ret = Photo
			          Me.Name = PhotoFile.Name
			        Else
			          If Photo = Nil Then
			            Dim p As New Picture (250, 150)', 24)
			            p.Graphics.ForeColor = &c00000000
			            p.Graphics.TextFont = gTextFont
			            p.Graphics.TextSize = 15
			            Dim nm As String = "Drop a photo here."
			            Dim strWidth, strHeight As Integer
			            strWidth = p.Graphics.StringWidth(nm)
			            strHeight = p.Graphics.StringHeight(nm, p.Width)
			            p.Graphics.DrawString(nm, ((p.Width/2) - (strWidth/2)), ((p.Height/2) + (strHeight/4)))
			            Photo = p
			          End If
			        End If
			      Else
			        If Photo = Nil Then
			          Dim p As New Picture (250, 150, 24)
			          p.Graphics.ForeColor = &c000000
			          p.Graphics.TextFont = gTextFont
			          p.Graphics.TextSize = 15
			          Dim nm As String = "Drop a photo here."
			          Dim strWidth, strHeight As Integer
			          strWidth = p.Graphics.StringWidth(nm)
			          strHeight = p.Graphics.StringHeight(nm, p.Width)
			          p.Graphics.DrawString(nm, ((p.Width/2) - (strWidth/2)), ((p.Height/2) + (strHeight/4)))
			          Photo = p
			        End If
			      End If
			      ret = Photo
			      
			    Case 5  //File tool target
			      If DropTarget = Nil Then
			        DropTarget = New Picture(target1751.Width, target1751.Height)
			        DropTarget.Graphics.ForeColor = &cFFFFFF99
			        DropTarget.Graphics.FillRect(0, 0, DropTarget.Width, DropTarget.Height)
			        DropTarget.Graphics.DrawPicture(target1751, 0, 0)
			      End If
			      
			      If Working Then
			        Dim p As New Picture(DropTarget.Width, DropTarget.Height)', DropTarget.Depth)
			        p.Graphics.ForeColor = &cFFFFFF99
			        p.Graphics.FillRect(0, 0, p.Width, p.Height)
			        p.Graphics.DrawPicture(DropTarget, 0, 0)
			        p.Graphics.ForeColor = &cFF0000//&cFF0000
			        p.Graphics.TextFont = gTextFont
			        p.Graphics.TextSize = 20
			        Dim nm As String = "Working..."
			        Dim strWidth, strHeight As Integer
			        strWidth = p.Graphics.StringWidth(nm)
			        strHeight = p.Graphics.StringHeight(nm, p.Width)
			        p.Graphics.DrawString(nm, (p.Width / 2) - (strWidth / 2), ((p.Height/2) + (strHeight/3)))
			        //p.Graphics.DrawString(nm, 10, ((p.Height/2) + (strHeight/4)))
			        Ret = p
			      Else
			        Ret = DropTarget
			      End If
			    Case 6  //Clock
			      Return Clock.ShowTime(New Date)
			    End Select
			    
			  End If
			  
			  If ResizeTo <> 100 Then
			    Return Resize(ret)
			  Else
			    Return ret
			  End If
			  
			  
			End Get
		#tag EndGetter
		image As Picture
	#tag EndComputedProperty

	#tag Property, Flags = &h0
		mimage As Picture
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mwidth As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		Name As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Process As ProcessInformation
	#tag EndProperty

	#tag Property, Flags = &h0
		ResizeTo As Integer = 100
	#tag EndProperty

	#tag Property, Flags = &h0
		Selected As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		SpecialHandler As SpecialFuntion
	#tag EndProperty

	#tag Property, Flags = &h21
		Private time As Integer = 0
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return image.Width
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
			Name="Alert"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
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
			Name="mimage"
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
			Name="ResizeTo"
			Group="Behavior"
			InitialValue="100"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Selected"
			Group="Behavior"
			Type="Boolean"
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
