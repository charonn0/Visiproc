#tag Class
Protected Class Magnifyer
Inherits Thread
	#tag Event
		Sub Run()
		  While True
		    magImage = GetZoomedPic
		    App.YieldToNextThread
		    //Me.Sleep(200)
		  Wend
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Function GetZoomedPic() As Picture
		  #If Not TargetWin32 Then Return Nil
		  Declare Function GetDesktopWindow Lib "User32" () As Integer
		  Declare Function GetDC Lib "User32" (HWND As Integer) As Integer
		  Declare Function StretchBlt Lib "GDI32" (destDC As Integer, destX As Integer, destY As Integer, destWidth As Integer, destHeight As Integer, _
		  sourceDC As Integer, sourceX As Integer, sourceY As Integer, sourceWidth As Integer, sourceHeight As Integer, rasterOp As Integer) As Boolean
		  
		  Declare Function ReleaseDC Lib "User32" (HWND As Integer, DC As Integer) As Integer
		  Declare Function GetCursorInfo Lib "user32.dll" (lpCursor as ptr) As Integer
		  Declare Function DrawIcon Lib "user32" Alias "DrawIcon" (hdc As integer, x As integer, y As integer, hIcon As integer) As integer
		  Declare Function DrawIconEx Lib "user32" Alias "DrawIconEx" (hdc As integer, xLeft As integer, yTop As integer, hIcon As integer, cxWidth As integer, cyWidth As integer, istepIfAniCur As integer, hbrFlickerFreeDraw As integer, diFlags As integer) As integer
		  
		  Const CAPTUREBLT = &h40000000
		  Const SRCCOPY = &HCC0020
		  Dim coordx, coordy As Integer
		  'coordx = System.MouseX
		  'coordy = System.Mousey
		  Dim magnifyLvl As Integer = 2
		  coordx = System.MouseX - (magImage.Width \ (magnifyLvl * 2))
		  coordy = System.Mousey - (magImage.Height \ (magnifyLvl * 2))
		  Dim rectWidth, rectHeight As Integer
		  rectWidth = magImage.Width \ magnifyLvl
		  rectHeight = magImage.Height \ magnifyLvl
		  Dim screenCap As New Picture(magImage.Width, magImage.Height, 32)
		  Dim deskHWND As Integer = GetDesktopWindow()
		  Dim deskHDC As Integer = GetDC(deskHWND)
		  Call StretchBlt(screenCap.Graphics.Handle(1), 0, 0, magImage.Width, magImage.Height, DeskHDC, coordx, coordy, rectWidth, _
		  rectHeight, SRCCOPY Or CAPTUREBLT)
		  Call ReleaseDC(DeskHWND, deskHDC)
		  
		  Dim mbCursor as new MemoryBlock(20)
		  mbCursor.Long(0) = mbCursor.Size
		  If GetCursorInfo(mbCursor) <> 0 Then
		    Dim cursPict as New Picture(32, 32, 32)
		    Dim desthdc2 as Integer = cursPict.Graphics.Handle(Graphics.HandleTypeHDC)
		    If DrawIcon(desthdc2, 0, 0, mbCursor.Long(8)) <> 0 Then
		      Const DI_MASK = &H1
		      Dim desthdc3 as Integer = cursPict.Mask.Graphics.Handle(Graphics.HandleTypeHDC)
		      If DrawIconEx(desthdc3, 0, 0, mbCursor.Long(8), 0, 0, 0, 0, DI_MASK) <> 0 Then
		        screenCap.Graphics.DrawPicture(cursPict, screenCap.Width \ 2, screenCap.Height \ 2, 32, 32, 0, 0, 32, 32)
		      End If
		    End If
		  End If
		  Return screenCap
		End Function
	#tag EndMethod


	#tag Structure, Name = RECT, Flags = &h0
		left As Integer
		  top As Integer
		  right As Integer
		bottom As Integer
	#tag EndStructure


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			Type="Integer"
			InheritedFrom="Thread"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			Type="Integer"
			InheritedFrom="Thread"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InheritedFrom="Thread"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Priority"
			Visible=true
			Group="Behavior"
			InitialValue="5"
			Type="Integer"
			InheritedFrom="Thread"
		#tag EndViewProperty
		#tag ViewProperty
			Name="StackSize"
			Visible=true
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			InheritedFrom="Thread"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InheritedFrom="Thread"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			Type="Integer"
			InheritedFrom="Thread"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
