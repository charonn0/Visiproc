#tag Class
Protected Class WindowGetter
Inherits Thread
	#tag Event
		Sub Run()
		  
		  Declare Function FindWindowW Lib "user32.dll" ( lpClassName As integer, lpWindowName As integer ) as integer
		  Declare Function GetWindow Lib "user32" ( hWnd As integer, wCmd As integer ) As integer
		  
		  #pragma BreakOnExceptions On
		  Const GW_HWNDNEXT = 2
		  For i As Integer = 0 To ActiveProcesses.Ubound
		    Debug(False, "Get Windows For: " + activeProcesses(i).Name)
		    Dim ret as integer
		    ret = FindWindowW( 0, 0 )
		    while ret > 0
		      If ActiveProcesses(i).ProcessID = GetProcFromWindowHandle(ret).ProcessID Then
		        Dim pw As New ProcWindow(ret)
		        If pw.Title <> "" Then ActiveProcesses(i).Windows.Append(pw)
		      End If
		      
		      ret = GetWindow( ret, GW_HWNDNEXT )
		    wend
		    
		  Next
		End Sub
	#tag EndEvent


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
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
