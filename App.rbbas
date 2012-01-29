#tag Class
Protected Class App
Inherits Application
	#tag Event
		Sub Open()
		  Dim args() As String = System.CommandLine.Split(" ")
		  For Each arg As String In args
		    If arg = "--debug" Then
		      DebugMode = True
		      Exit For
		    End If
		  Next
		  Call registerMBSPlugin("Andrew Lambert", "MBS Win", 201105, 1462922781)
		  If Platform.EnablePrivilege("SeDebugPrivilege") Then
		    debug("SeDebugPrivilege Enabled")
		  Else
		    debug("SeDebugPrivilege NOT Enabled")
		  End If
		  
		  If Platform.EnablePrivilege(SE_BACKUP_NAME) Then
		    debug("SeBackupPrivilege Enabled")
		  Else
		    debug("SeBackupPrivilege NOT Enabled")
		  End If
		  
		  If Platform.EnablePrivilege(SE_AUDIT_NAME) Then
		    debug("SeAuditPrivilege Enabled")
		  Else
		    debug("SeAuditPrivilege NOT Enabled")
		  End If
		  
		  If Platform.EnablePrivilege(SE_CREATE_TOKEN_NAME) Then
		    debug(SE_CREATE_TOKEN_NAME + " Enabled")
		  Else
		    debug(SE_CREATE_TOKEN_NAME + " NOT Enabled")
		  End If
		  
		  If Platform.EnablePrivilege(SE_MANAGE_VOLUME_NAME) Then
		    debug(SE_MANAGE_VOLUME_NAME + " Enabled")
		  Else
		    debug(SE_MANAGE_VOLUME_NAME + " NOT Enabled")
		  End If
		  
		End Sub
	#tag EndEvent

	#tag Event
		Function UnhandledException(error As RuntimeException) As Boolean
		  #pragma Unused Error
		  debug(True, "Swallowed Exception: " + Introspection.GetType(error).Name)
		  Return True
		End Function
	#tag EndEvent


	#tag Constant, Name = kEditClear, Type = String, Dynamic = False, Default = \"&Delete", Scope = Public
		#Tag Instance, Platform = Windows, Language = Default, Definition  = \"&Delete"
		#Tag Instance, Platform = Linux, Language = Default, Definition  = \"&Delete"
	#tag EndConstant

	#tag Constant, Name = kFileQuit, Type = String, Dynamic = False, Default = \"&Quit", Scope = Public
		#Tag Instance, Platform = Windows, Language = Default, Definition  = \"E&xit"
	#tag EndConstant

	#tag Constant, Name = kFileQuitShortcut, Type = String, Dynamic = False, Default = \"", Scope = Public
		#Tag Instance, Platform = Mac OS, Language = Default, Definition  = \"Cmd+Q"
		#Tag Instance, Platform = Linux, Language = Default, Definition  = \"Ctrl+Q"
	#tag EndConstant


	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass
