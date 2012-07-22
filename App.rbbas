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
		  #If RBVersion < 2011.043 Then
		    #pragma Error "This project requires REALStudio 2011r4.3 or newer"
		  #endif
		  
		  LoadConf()
		  Dim args() As String = System.CommandLine.Split(" ")
		  For Each arg As String In args
		    If arg = "--debug" Then
		      DebugMode = True
		      Exit For
		    End If
		  Next
		  //Requires the Monkeybread Win plugin for WMI
		  
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
		  Dim f As FolderItem = App.ExecutableFile.Parent.Child("visiproc.conf")
		  If f.Exists Then
		    Dim linesFromFile() As String
		    Dim tis As TextInputStream
		    tis = tis.Open(f)
		    While Not tis.EOF
		      linesFromFile.Append(tis.ReadLine)
		    Wend
		    tis.Close
		    For i As Integer = 0 To UBound(linesFromFile)
		      Dim settName As String = NthField(linesFromFile(i), "=", 1).Uppercase
		      Dim settVal As Variant = NthField(linesFromFile(i), "=", 2)
		      
		      Select Case settName
		      Case "NewProcColor"
		        NewProcColor = settVal
		      Case "SystemProcColor"
		        SystemProcColor = settVal
		      Case "InvalidSystemProcColor"
		        InvalidSystemProcColor = settVal
		      Case "StringColor"
		        StringColor = settVal
		      Case "TextFont"
		        Globals.gTextFont = settVal
		      Case "Backdrop"
		        Globals.BackDrop = GetFolderItem(settVal)
		      Case "HelpColor"
		        Globals.HelpColor = settVal
		      Case "NormalProcColor"
		        Globals.NormalProcColor = settVal
		      Case "TextSize"
		        Globals.gTextSize = settVal.IntegerValue
		      Case "Photo"
		        Globals.PhotoFile = GetFolderItem(settVal)
		        
		      Case "Translucency"
		        Globals.Transparency = settVal.IntegerValue
		      End Select
		    Next
		    
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub WriteConf()
		  Dim f As FolderItem = App.ExecutableFile.Parent.Child("visiproc.conf")
		  Dim tos As TextOutputStream
		  tos = tos.Create(f)
		  
		  If Globals.BackDrop <> Nil Then tos.WriteLine("Backdrop=" + Globals.BackDrop.AbsolutePath)
		  tos.WriteLine("NewProcColor=" + Str(NewProcColor))
		  tos.WriteLine("NormalProcColor=" + Str(NormalProcColor))
		  tos.WriteLine("SystemProcColor=" + Str(SystemProcColor))
		  tos.WriteLine("InvalidSystemProcColor=" + Str(InvalidSystemProcColor))
		  tos.WriteLine("StringColor=" + Str(StringColor))
		  tos.WriteLine("TextFont=" + Globals.gTextFont)
		  tos.WriteLine("HelpColor=" + Str(Globals.HelpColor))
		  tos.WriteLine("TextSize=" + Str(Globals.gTextSize))
		  tos.WriteLine("Translucency=" + Str(Globals.Transparency))
		  If PhotoFile <> Nil Then tos.WriteLine("Photo=" + Globals.PhotoFile.AbsolutePath)
		  tos.Close
		  
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
