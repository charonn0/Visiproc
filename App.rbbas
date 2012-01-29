#tag Class
Protected Class App
Inherits Application
	#tag Event
		Function CancelClose() As Boolean
		  Dim g As FolderItem = SpecialFolder.Temporary.Child("trid.exe")
		  Dim d As FolderItem = SpecialFolder.Temporary.Child("triddefs.trd")
		  If g.Exists Then g.Delete
		  If d.Exists Then d.Delete
		  'GUIThread.Kill
		  CPUThread.Kill
		  Return False
		End Function
	#tag EndEvent

	#tag Event
		Sub Open()
		  LoadConf()
		  Dim args() As String = System.CommandLine.Split(" ")
		  For Each arg As String In args
		    If arg = "--debug" Then
		      DebugMode = True
		      Exit For
		    End If
		  Next
		  Call registerMBSPlugin("Andrew Lambert", "MBS Win", 201105, 1462922781)
		  
		  If Not Platform.IsAdmin Then
		    MsgBox("This application works best with Administrator rights.")
		    debug(True, "User is NOT admin!")
		  Else
		    debug("User is Admin. A-OK")
		  End If
		  
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
		  
		  If Platform.EnablePrivilege(SE_PROF_SINGLE_PROCESS_NAME) Then
		    debug(SE_PROF_SINGLE_PROCESS_NAME + " Enabled")
		  Else
		    debug(SE_PROF_SINGLE_PROCESS_NAME + " NOT Enabled")
		  End If
		  PollCPU
		  'GUIThread = New UpdGUIThread
		  'GUIThread.Run
		  CPUThread = New CPUGetter
		  CPUThread.Run
		  
		End Sub
	#tag EndEvent

	#tag Event
		Function UnhandledException(error As RuntimeException) As Boolean
		  debug(True, "Swallowed Exception: " + Introspection.GetType(error).Name)
		  If error IsA StackOverflowException Then Quit(0)
		  Return True
		End Function
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub LoadConf()
		  Dim tis As TextInputStream
		  Dim f As FolderItem = App.ExecutableFile.Parent.Child("visiproc.conf")
		  If f.Exists Then
		    tis = tis.Open(f)
		    Dim js As New JSONItem(tis.ReadAll)
		    
		    tis.Close
		    NewProcColor = Val("&h" + js.Value("NewProcColor").StringValue).IntToColor
		    SystemProcColor = Val("&h" + js.Value("SystemProcColor").StringValue).IntToColor
		    InvalidSystemProcColor = Val("&h" + js.Value("InvalidSystemProcColor").StringValue).IntToColor
		    StringColor = Val("&h" + js.Value("StringColor").StringValue).IntToColor
		    Globals.gTextFont = js.Value("TextFont").StringValue
		    If js.HasName("Backdrop") Then Globals.BackDrop = GetFolderItem(js.Value("Backdrop").StringValue)
		  End If
		  'js.Value("NormalProcColor") = Hex(NormalProcColor)
		  'js.Value("SystemProcColor") = Hex(SystemProcColor)
		  'js.Value("InvalidSystemProcColor") = Hex(InvalidSystemProcColor)
		  'js.Value("StringColor") = Hex(StringColor)
		  'js.Value("TextFont") = Globals.gTextFont
		End Sub
	#tag EndMethod


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
