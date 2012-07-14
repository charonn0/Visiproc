#tag Module
Protected Module Clock
	#tag Method, Flags = &h21
		Private Sub DrawFace(g As Graphics, scale As Double = 1.0)
		  //Based on the "Cool Clock" example included with RealStudio by j-jim@geocities.com
		  g.ForeColor = &cFFFFFE
		  g.FillRect(0, 0, g.Width, g.Height)
		  g.ForeColor = &c000000
		  Dim xh, yh, xm, ym, xs, ys, s, m, h, xcenter, ycenter As Integer
		  Dim today As String
		  Dim d As New Date
		  If BackingDate <> Nil Then
		    d = BackingDate
		  Else
		    d.TotalSeconds = d.TotalSeconds + (OffsetFromLocalTime * 3600)
		  End If
		  If Title <> "" Then
		    Dim x, y As Integer
		    Dim p As Picture = DrawTitle(Scale)
		    x = (50 * Scale) - (0.5 * p.Width)
		    y = (50 * Scale) + (15 * scale)
		    g.DrawPicture(p, x, y)
		  End If
		  
		  //center
		  xcenter=50 * scale
		  ycenter=50 * scale
		  
		  //get date stuff
		  
		  s=d.second
		  m=d.minute
		  h=d.hour
		  today=d.shortdate+"  "+d.shorttime
		  
		  //get points for drawing hands
		  xs = Cos(s * 3.14/30 - 3.14/2) * (scale * 45) + xcenter
		  ys = Sin(s * 3.14/30 - 3.14/2) * (scale * 45) + ycenter
		  xm = Cos(m * 3.14/30 - 3.14/2) * (scale * 40) + xcenter
		  ym = Sin(m * 3.14/30 - 3.14/2) * (scale * 40) + ycenter
		  xh = Cos((h*30 + m/2) * 3.14/180 - 3.14/2) * (scale * 30) + xcenter
		  yh = Sin((h*30 + m/2) * 3.14/180 - 3.14/2) * (scale * 30) + ycenter
		  
		  //draw oval
		  g.PenHeight = 2
		  g.PenWidth = 2
		  g.drawoval(0, 0, 100 * scale, 100 * scale)
		  g.PenHeight = 1
		  g.PenWidth = 1
		  g.drawoval(4, 4, 100 * scale - 8, 100 * scale - 8)
		  
		  // label numbers
		  g.forecolor=RGB(60,60,60) 'change color to dark grey
		  g.TextSize = 11 * scale
		  g.drawString "9", xcenter - (45 * scale), ycenter + (3 * scale)
		  g.drawString "3", xcenter + (40 * scale), ycenter + (3 * scale)
		  g.drawString "12", xcenter - (5 * scale), ycenter - (37 * scale)
		  g.drawString "6", xcenter - (3 * scale), ycenter + (45 * scale)
		  
		  //draw date
		  'g.drawString today, 5, 125
		  
		  //draw hands
		  g.forecolor=RGB(0,0,0) 'change color to black
		  g.drawLine xcenter, ycenter-1, xm, ym   'minutes
		  g.drawLine xcenter-1, ycenter, xm, ym   'minutes
		  g.PenHeight = 2
		  g.PenWidth = 2
		  g.drawLine xcenter, ycenter-1, xh, yh   'hours
		  g.drawLine xcenter-1, ycenter, xh, yh   'hours
		  g.PenHeight = 1
		  g.PenWidth = 1
		  g.forecolor=RGB(0, 0, 255) 'change color to blue
		  g.drawLine xcenter, ycenter, xs, ys   'seconds
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DrawTitle(scale As Double = 1.0) As Picture
		  Dim p As New Picture(15 * Scale, 8 * Scale)
		  p.Graphics.TextSize = 5 * Scale
		  p.Graphics.TextFont = TitleFont
		  Dim strWidth, strHeight As Integer
		  strWidth = p.Graphics.StringWidth(Title)
		  strHeight = p.Graphics.StringHeight(Title, p.Width)
		  p = New Picture(strWidth, strHeight)
		  p.Graphics.ForeColor = &cFFFFFE
		  p.Graphics.FillRect(0, 0, p.Width, p.Height)
		  p.Graphics.TextSize = 5 * Scale
		  p.Graphics.TextFont = TitleFont
		  p.Graphics.ForeColor = &c000000
		  p.Graphics.DrawString(Title, 0, ((p.Height/2) + (strHeight/4)))
		  Return p
		  
		Exception err As OutOfBoundsException
		  //Someone made the clock too small
		  Return New Picture(1, 1)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function PaintClock() As Picture
		  If Buffer = Nil Then Buffer = New Picture(Height, Width, 32)
		  Buffer.Graphics.AntiAlias = False
		  App.UseGDIPlus = True
		  If Width <= Height Then
		    Dim scale As Double = Width / 100
		    Buffer = New Picture(Width, Height, 32)
		    DrawFace(Buffer.Graphics, scale)
		  Else
		    Dim scale As Double = Height / 100
		    Buffer = New Picture(Width, Height, 32)
		    DrawFace(Buffer.Graphics, scale)
		  End If
		  Buffer.RGBSurface.FloodFill(1, 1, &cFFFFFF)
		  Buffer.RGBSurface.FloodFill(1, Buffer.Height - 1, &cFFFFFF)
		  Buffer.RGBSurface.FloodFill(Buffer.Width - 1, Buffer.Height - 1, &cFFFFFF)
		  Buffer.RGBSurface.FloodFill(Buffer.Width - 1, 1, &cFFFFFF)
		  Buffer.Transparent = 1
		  Return Buffer
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function ShowTime(Time As Date) As Picture
		  BackingDate = Time
		  Return PaintClock()
		End Function
	#tag EndMethod


	#tag Property, Flags = &h1
		Protected BackingDate As Date
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Buffer As Picture
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Height As Integer = 200
	#tag EndProperty

	#tag Property, Flags = &h1
		#tag Note
			The offset, plus or minus in hours, which should be applied to the displayed time in relation to the local system time.
			
			For example, to show the time in Los Angeles on a computer in New York, you would set OffsetFromLocalTime to -3.0
		#tag EndNote
		Protected OffsetFromLocalTime As Double = 0.0
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Title As String = "Boredom Clockworks"
	#tag EndProperty

	#tag Property, Flags = &h21
		Private TitleFont As String = "Segoe Script"
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Width As Integer = 200
	#tag EndProperty


	#tag ViewBehavior
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
