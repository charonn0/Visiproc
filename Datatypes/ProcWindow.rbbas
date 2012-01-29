#tag Class
Protected Class ProcWindow
	#tag Method, Flags = &h0
		Function Alpha() As Single
		  #if TargetWin32
		    Const LWA_ALPHA = 2
		    Soft Declare Sub GetLayeredWindowAttributes Lib "user32"(hwnd As Integer, thecolor As Integer, ByRef bAlpha As integer, flags As Integer)
		    
		    if not System.IsFunctionAvailable("GetLayeredWindowAttributes", "User32")then return 255.0
		    
		    Dim alpha as Integer = 0
		    GetLayeredWindowAttributes(Handle, 0 , alpha, LWA_ALPHA)
		    
		    return alpha / 255.0
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Alpha(assigns alpha as Single)
		  #if TargetWin32
		    // First, check to see if we've set this window up to be layered yet
		    Const WS_EX_LAYERED = &H80000
		    Const LWA_ALPHA = 2
		    
		    if not TestWindowStyleEx(WS_EX_LAYERED)then
		      // The window isn't layered, so make it so
		      ChangeWindowStyleEx(WS_EX_LAYERED, true)
		    end
		    
		    // Now we want to set the transparency of the window.  The values range from 0 (totally
		    // transparent) to 255 (totally opaque).
		    dim value as Integer = 255 * alpha
		    
		    Soft Declare Sub SetLayeredWindowAttributes Lib "user32"(hwnd As Integer, thecolor As Integer, bAlpha As integer, alpha As Integer)
		    
		    if System.IsFunctionAvailable("SetLayeredWindowAttributes", "User32")then
		      SetLayeredWindowAttributes(Handle, 0 , value, LWA_ALPHA)
		    end if
		    
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub BringToFront()
		  Const SW_SHOWNORMAL = 1
		  ChangeWindowState(SW_SHOWNORMAL)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ChangeWindowState(style As Integer)
		  #if TargetWin32
		    Declare Sub ShowWindow Lib "User32" (wnd As Integer, nCmdShow As Integer)
		    
		    ShowWindow(Handle, style)
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ChangeWindowStyleEx(flag As Integer, set As Boolean)
		  #if TargetWin32
		    Dim oldFlags As Integer
		    Dim newFlags As Integer
		    Dim styleFlags As Integer
		    
		    Const SWP_NOSIZE = &H1
		    Const SWP_NOMOVE = &H2
		    Const SWP_NOZORDER = &H4
		    Const SWP_FRAMECHANGED = &H20
		    
		    Const GWL_EXSTYLE = -20
		    
		    Declare Function GetWindowLong Lib "user32" Alias "GetWindowLongA" (hwnd As Integer,  _
		    nIndex As Integer) As Integer
		    Declare Function SetWindowLong Lib "user32" Alias "SetWindowLongA" (hwnd As Integer, _
		    nIndex As Integer, dwNewLong As Integer) As Integer
		    Declare Function SetWindowPos Lib "user32" (hwnd As Integer, hWndInstertAfter As Integer, _
		    x As Integer, y As Integer, cx As Integer, cy As Integer, flags As Integer) As Integer
		    
		    oldFlags = GetWindowLong(Handle, GWL_EXSTYLE)
		    
		    if not set then
		      newFlags = BitwiseAnd(oldFlags, Bitwise.OnesComplement(flag))
		    else
		      newFlags = BitwiseOr(oldFlags, flag)
		    end
		    
		    
		    styleFlags = SetWindowLong(Handle, GWL_EXSTYLE, newFlags)
		    styleFlags = SetWindowPos(Handle, 0, 0, 0, 0, 0, SWP_NOMOVE +_
		    SWP_NOSIZE + SWP_NOZORDER + SWP_FRAMECHANGED)
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(h As Integer)
		  Handle = h
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Destructor()
		  Call closeProcHandle(Handle)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Identify()
		  'Declare Function GetSystemMetrics Lib "user32"  (nIndex As integer) As integer
		  'Dim ret() As Integer
		  'ret.Append(GetSystemMetrics(0)) //width
		  'ret.Append(GetSystemMetrics(1)) //height
		  'if ret(0) = 0 Or ret(1) = 0 Then
		  'ret(0) = 800
		  'ret(1) = 600
		  'end if
		  'Window1.Timer1.Mode = Timer.ModeOff
		  Visible()
		  Declare Function FlashWindow Lib "user32" (hwnd As integer, bInvert As integer) As integer
		  Call FlashWindow(Handle, 1)
		  Return
		  
		  
		  'Declare Function DrawTextW Lib "user32" (hdc As Integer, lpStr As WString, nCount As Integer, ByRef lpRect As RECT, wFormat As Integer) As Integer
		  'Declare Function CreateDCA Lib "gdi32" (lpDriverName As CString, lpDeviceName As Integer, lpOutput As Integer, lpInitData As Integer) As Integer
		  Declare Function DeleteDC Lib "gdi32" (hdc As Integer) As Integer
		  'Declare Function GetTextColor Lib "gdi32" (hdc As Integer) As Color
		  'Declare Function SetTextColor Lib "gdi32" (hdc As Integer,  crColor As Color) As Integer
		  'Declare Function GetBkColor Lib "gdi32" (hdc As Integer) As Color
		  'Declare Function SetBkColor  Lib "gdi32" (hdc As Integer,  crColor As Color) As Integer
		  Declare Function GetWindowDC Lib "user32" (HWND As UInt32) As UInt32
		  Declare Function GetWindowRect Lib "User32" ( w as UInt32, ByRef r As RECT) As Boolean
		  Declare Function Rectangle Lib "Gdi32" (hdc As UInt32, Left As UInt32, top As UInt32, Right As UInt32, bottom As UInt32) As Boolean
		  Declare Function FrameRect Lib "User32" (hdc As UInt32, r As RECT, brush As Integer) As Boolean
		  Declare Function CreateSolidBrush Lib "Gdi32" (c As Integer) As Integer
		  
		  
		  Const LF_DEFAULT_CHARSET = 1
		  Const LF_BOLD = 700
		  Const LF_OUT_DEFAULT_PRECIS = 0
		  Const LF_CLIP_DEFAULT_PRECIS = 0
		  Const LF_ANTIALIASED_QUALITY = 4
		  Const DT_MULTILINE = &H00000001
		  Const DT_NOCLIP = &H100
		  Const DT_EDITCONTROL = &H00002000
		  Dim err As Integer
		  'Dim orient As Integer = DT_MULTILINE Or DT_NOCLIP Or DT_EDITCONTROL
		  Dim hdc As UInt32 = GetWindowDC(Handle)
		  Dim tR As RECT
		  'Dim textCol, backColor As Color
		  If GetWindowRect(Handle, tR) Then
		    tR.Left = tR.Left + 20
		    tR.Right = tR.Right - 20
		    tR.Top = tR.Top + 40
		    tR.Bottom = tR.Bottom - 20
		    //Call Rectangle(hdc, tR.Left + 5, tR.Top + 5, tR.Right - 5, tR.Bottom - 5)
		    Dim brush As UInt32 = CreateSolidBrush(&h000000FF)
		    If Not FrameRect(hdc, tR, brush) Then
		      err = GetLastError
		      Break
		    Else
		      Break
		    End If
		    'tR.Left = 75
		    'tR.Top = 35
		    'tR.Right = 150
		    'tR.Bottom = 150
		    'End If
		    'textCol = GetTextColor(hdc)
		    'backColor = GetBkColor(hdc)
		    '
		    'If SetBkColor(hdc, &cFFFFFF) = &hFFFFFFFF Then Break
		    'If SetTextColor(hdc, &cFF0000) = &hFFFFFFFF Then Break
		    'Call DrawTextW(hdc, Title, Len(Title), tR, orient)
		    'Call SetTextColor(hdc, textCol)
		    'Call SetBkColor(hdc, backColor)
		    
		    Call DeleteDC hdc
		  End If
		  
		  
		  
		  Window1.Timer1.Mode = Timer.ModeMultiple
		  
		  
		  
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Maximized()
		  Const SW_MAXIMIZE = 3
		  ChangeWindowState(SW_MAXIMIZE)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Minimized()
		  Const SW_SHOWMINIMIZED = 2
		  ChangeWindowState(SW_SHOWMINIMIZED)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function TestWindowStyleEx(flag As Integer) As Boolean
		  #if TargetWin32
		    Dim oldFlags As Integer
		    
		    Const GWL_EXSTYLE = -20
		    
		    Declare Function GetWindowLong Lib "user32" Alias "GetWindowLongA" (hwnd As Integer,  _
		    nIndex As Integer) As Integer
		    
		    oldFlags = GetWindowLong(Handle, GWL_EXSTYLE)
		    
		    if Bitwise.BitAnd(oldFlags, flag)= flag then
		      return true
		    else
		      return false
		    end
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Visible()
		  Const SW_SHOWNORMAL = 1
		  ChangeWindowState(SW_SHOWNORMAL)
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		Handle As UInt32
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return Platform.GetWindowText(Handle)
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  Call Platform.SetWindowText(Handle, value)
			End Set
		#tag EndSetter
		Title As String
	#tag EndComputedProperty


	#tag Structure, Name = LOGFONT, Flags = &h0
		Height As Integer
		  Width As Integer
		  Escapement As Integer
		  Orientation As Integer
		  Weight As Integer
		  Italic As Byte
		  Underline As Byte
		  StrikeOut As Byte
		  CharSet As Byte
		  OutPrecision As Byte
		  ClipPrecision As Byte
		  Quality As Byte
		  PitchAndFamily As Byte
		faceName As String*255
	#tag EndStructure

	#tag Structure, Name = RECT, Flags = &h0
		Left As Integer
		  Top As Integer
		  Right As Integer
		Bottom As Integer
	#tag EndStructure


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
			Name="Title"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			InheritedFrom="Object"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
