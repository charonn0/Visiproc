#tag Class
Protected Class ProcessInformation
	#tag Method, Flags = &h0
		Sub Constructor()
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(mb As MemoryBlock)
		  // Four bytes of process id
		  ProcessID = mb.Long(8)
		  
		  // Number of threads
		  NumberOfThreads = mb.Long(20)
		  
		  // Parent id
		  ParentProcessID = mb.Long(24)
		  
		  // The base priority For threads
		  BaseThreadPriority = mb.Long(28)
		  
		  // Ignore the next four bytes, they're
		  // reserved.
		  
		  // And finally, the name
		  Name = mb.WString(36)
		  If Name = "[System Process]" Then Name = "System Idle Process"
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub LoadModules()
		  // Because we know things like this process' ID number, we can load
		  // all the thread information for the process as well
		  
		  #if TargetWin32
		    Soft Declare Function CreateToolhelp32Snapshot Lib "Kernel32" (flags as Integer, id as Integer ) as Integer
		    Declare Sub CloseHandle Lib "Kernel32" ( handle as Integer )
		    Soft Declare Function Module32First Lib "Kernel32" ( handle as Integer, ByRef entry as MODULEENTRY32) as Boolean
		    Soft Declare Function Module32Next Lib "Kernel32" ( handle as Integer, ByRef entry as MODULEENTRY32) as Boolean
		    
		    Const TH32CS_SNAPMODULE = &h00000008
		    
		    dim snapHandle as Integer
		    snapHandle = CreateToolhelp32Snapshot(TH32CS_SNAPMODULE, ProcessID)
		    
		    Dim data As MODULEENTRY32
		    data.sSize = data.Size
		    data.ProcessID = ProcessID
		    Dim entry as ModuleInformation
		    Dim err As Integer = 24
		    While err = 24
		      If Module32First(snapHandle, data) Then
		        Exit While
		      Else
		        err = GetLastError
		      End If
		    Wend
		    
		    dim good as Boolean
		    
		    do
		      entry = new ModuleInformation(data)
		      
		      // For whatever reason, the system will tell us about every thread running
		      // in the entire OS even though we specify the process ID.  This is documented
		      // behavior even though it makes no sense to me.  So we check the thread entry's
		      // process ID to see if it's the same as ours.  If it is, then we keep the thread around.
		      //if entry.OwnerProcessID = ProcessID then
		      Modules.Append( entry )
		      //end if
		      
		      good = Module32Next( snapHandle, data )
		    loop until not good
		    CloseHandle( snapHandle )
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub LoadThreads()
		  // Because we know things like this process' ID number, we can load
		  // all the thread information for the process as well
		  
		  #if TargetWin32
		    Soft Declare Function CreateToolhelp32Snapshot Lib "Kernel32" (flags as Integer, id as Integer ) as Integer
		    Declare Sub CloseHandle Lib "Kernel32" ( handle as Integer )
		    Soft Declare Function Thread32First Lib "Kernel32" ( handle as Integer, entry as Ptr ) as Boolean
		    Soft Declare Function Thread32Next Lib "Kernel32" ( handle as Integer, entry as Ptr ) as Boolean
		    
		    Const TH32CS_SNAPTHREAD = &h4
		    
		    dim snapHandle as Integer
		    snapHandle = CreateToolhelp32Snapshot( TH32CS_SNAPTHREAD, ProcessID )
		    
		    dim mb as new MemoryBlock( 28 )
		    
		    dim entry as ThreadInformation
		    
		    mb.Long( 0 ) = mb.Size
		    if not Thread32First( snapHandle, mb ) then return
		    
		    dim good as Boolean
		    
		    do
		      entry = new ThreadInformation( mb )
		      
		      // For whatever reason, the system will tell us about every thread running
		      // in the entire OS even though we specify the process ID.  This is documented
		      // behavior even though it makes no sense to me.  So we check the thread entry's
		      // process ID to see if it's the same as ours.  If it is, then we keep the thread around.
		      if entry.OwnerProcessID = ProcessID then
		        Threads.Append( entry )
		      end if
		      
		      good = Thread32Next( snapHandle, mb )
		    loop until not good
		    CloseHandle( snapHandle )
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Resume() As Boolean
		  Declare Function NtResumeProcess Lib "ntdll"(pHandle As Integer) As Integer
		  Dim pHandle As Integer = getProcHandle(ProcessID, PROCESS_ALL_ACCESS)
		  Dim ret As Integer = ntResumeProcess(pHandle)
		  Call closeProcHandle(pHandle)
		  If ret > -1 Then
		    debug("Resumed " + Name)
		    Return True
		  Else
		    debug("Could Not Resume " + Name)
		    Return False
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Suspend() As Boolean
		  Declare Function NtSuspendProcess Lib "ntdll"(pHandle As Integer) As Integer
		  Dim pHandle As Integer = getProcHandle(ProcessID, PROCESS_ALL_ACCESS)
		  Dim Ret As Integer = NtSuspendProcess(pHandle)
		  Call closeProcHandle(pHandle)
		  
		  If ret > -1 Then
		    debug("Suspended " + Name)
		    Return True
		  Else
		    debug("Could Not Suspend " + Name)
		    Return False
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Terminate(exitCode As Integer = 0) As Boolean
		  Declare Function TerminateProcess Lib "Kernel32" (handle As Integer, exitCode As Integer) As Boolean
		  Declare Function OpenProcess Lib "Kernel32" (access As Integer, inheritHandle As Boolean, processId As Integer) As Integer
		  Declare Sub CloseHandle Lib "Kernel32" (handle As Integer)
		  
		  Dim processHandle As Integer = OpenProcess(PROCESS_TERMINATE, False, ProcessID)
		  If processHandle <> 0 then
		    If TerminateProcess(processHandle, exitCode) Then
		      debug("Terminated " + Name)
		      Return True
		    Else
		      processHandle = GetLastError()
		      debug("Could Not Terminate " + Name)
		      debug("Last error: " + Platform.ErrorMessageFromCode(processHandle))
		      Return False
		    End If
		    CloseHandle(processHandle)
		  Else
		    processHandle = GetLastError()
		    debug("Could Not Terminate " + Name)
		    debug("Last error: " + Platform.ErrorMessageFromCode(processHandle))
		    Return False
		  End If
		End Function
	#tag EndMethod


	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Declare Function OpenProcess Lib "Kernel32" (access As Integer, inherit As Boolean, procID As Integer) As Integer
			  Declare Function GetProcessAffinityMask Lib "kernel32" (hProcess As Integer, lpProcessAffinityMask As Ptr, SystemAffinityMask As Ptr) As Boolean
			  Declare Sub CloseHandle Lib "Kernel32" (handle As Integer)
			  
			  Dim lpProc As MemoryBlock
			  lpProc = New MemoryBlock(4)
			  
			  Dim sysProc As MemoryBlock
			  sysProc = New MemoryBlock(4)
			  
			  ' Get a handle to the current process
			  Dim processHandle As Integer
			  Dim success As Boolean
			  
			  processHandle = OpenProcess(PROCESS_QUERY_INFORMATION, False, processID)
			  If processHandle <> 0 Then
			    success = GetProcessAffinityMask(processHandle, lpProc, sysProc)
			  Else
			    Debug(True, "Try to get the handle For process ID " + Str(processId))
			  End If
			  CloseHandle(processHandle)
			  Dim ret As Byte
			  ret = lpProc.Byte(0)
			  If success then
			    Debug("Get CPU Affinity For ProcID: " + Str(ProcessID))
			    Return ret
			  Else
			    Debug("Couldn't Get CPU Affinity For ProcID: " + Str(ProcessID))
			    Return &b00000000
			  End If
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  Declare Function OpenProcess Lib "Kernel32" (access As Integer, inherit As Boolean, procID As Integer) As Integer
			  Declare Function SetProcessAffinityMask Lib "Kernel32" (handle As Integer, ByVal cpuID As Integer) As Boolean
			  Declare Sub CloseHandle Lib "Kernel32" (handle As Integer)
			  
			  Dim processHandle As Integer
			  
			  processHandle = OpenProcess(PROCESS_SET_INFORMATION, False, ProcessID)
			  If processHandle <> 0 Then
			    Dim theMask As String = value.pad
			    If Not SetProcessAffinityMask(processHandle, theMask.str2bin) Then
			      Debug(True, "Try to change affinity on process ID " + Str(ProcessID) + " to " + Str(value))
			    End If
			  Else
			    If GetLastError = 5 Then
			      #pragma BreakOnExceptions off
			      Raise New AccessDenied(Me)
			      #pragma BreakOnExceptions on
			    End If
			  End If
			  CloseHandle(processHandle)
			  Debug("Set CPU Affinity For ProcID: " + Str(ProcessID))
			End Set
		#tag EndSetter
		Affinity As Byte
	#tag EndComputedProperty

	#tag Property, Flags = &h0
		BaseThreadPriority As Integer
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  If mCommandLine = "" Then
			    Debug("Get Command Line For ProcID: " + Str(ProcessID))
			    If WMIobj = Nil Then WMIobj = New WindowsWMIMBS
			    if WMIobj.ConnectServer("root\cimv2") then
			      if WMIobj.query("WQL","select CommandLine from Win32_Process where ProcessId='" + Str(ProcessID) + "'") then
			        if WMIobj.NextItem then
			          mCommandLine = WMIobj.GetPropertyString("CommandLine") // string
			          If mCommandLine = "" Then mCommandLine = Name
			        else
			          mCommandLine =  ""
			        end if
			      else
			        mCommandLine =  ""
			      end if
			    else
			      mCommandLine =  ""
			    end if
			  Else
			    'Debug("Use Cached Command Line For ProcID: " + Str(ProcessID))
			  End If
			   Return mCommandLine
			End Get
		#tag EndGetter
		CommandLine As String
	#tag EndComputedProperty

	#tag Property, Flags = &h0
		Hidden As Boolean
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Dim protectedProcs() As String = Split("System:svchost.exe:lsm.exe:taskeng.exe:SearchFilterHost.exe:SearchIndexer.exe:SearchProtocolHost.exe:sidebar.exe:WUDFHost.exe:spoolsv.exe:alg.exe:lsass.exe:winlogon.exe:TrustedInstaller.exe:services.exe:mdm.exe:csrss.exe:smss.exe:System Idle Process:locator.exe:dwm.exe:taskhost.exe:wininit.exe:wisptis.exe:wuauclt.exe:wmiprvse.exe:dllhost.exe:dfsr.exe:msdtc.exe:mscorsvw.exe:SMSvcHost.exe:slsvc.exe:vssvc.exe:wmpnetwk.exe", ":")
			  If protectedProcs.IndexOf(name) > -1 Then
			    Return True
			  Else
			    Return False
			  End If
			End Get
		#tag EndGetter
		isCritical As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  if mlargeIcon = Nil Then
			    largeIcon = GetIco(path, 32)
			  end if
			  return mlargeIcon
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mlargeIcon = value
			End Set
		#tag EndSetter
		largeIcon As Picture
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private mCommandLine As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mlargeIcon As Picture
	#tag EndProperty

	#tag Property, Flags = &h0
		Modules() As ModuleInformation
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mPath As FolderItem
	#tag EndProperty

	#tag Property, Flags = &h21
		Private msmallIcon As Picture
	#tag EndProperty

	#tag Property, Flags = &h0
		Name As String
	#tag EndProperty

	#tag Property, Flags = &h0
		NumberOfThreads As Integer
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Debug("Get Parent Image For ProcID: " + Str(ProcessID))
			  Return imageFromProcID(ParentProcessID)
			End Get
		#tag EndGetter
		parentImage As FolderItem
	#tag EndComputedProperty

	#tag Property, Flags = &h0
		ParentProcessID As Integer
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  If mPath = Nil Then
			    If ProcessID = 0 Or ProcessID = 4 Then Return Nil
			    mPath = imageFromProcID(ProcessID)
			  End If
			  Return mPath
			  
			End Get
		#tag EndGetter
		path As FolderItem
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Declare Function OpenProcess Lib "Kernel32" (access As Integer, inherit As Boolean, procID As Integer) As Integer
			  Declare Function GetPriorityClass Lib "Kernel32" (handle As Integer) As Integer
			  Declare Sub CloseHandle Lib "Kernel32" (handle As Integer)
			  
			  Dim processHandle As Integer = OpenProcess(PROCESS_QUERY_INFORMATION, False, ProcessID)
			  Dim ret As Integer
			  
			  If processHandle <> 0 Then
			    ret = GetPriorityClass(processHandle)
			    CloseHandle(processHandle)
			    Debug("Get Scheduler Priority For ProcID: " + Str(ProcessID))
			  Else
			    Debug(True, "Tried To Get Scheduler Priority For process ID " + Str(ProcessID))
			    CloseHandle(processHandle)
			  End If
			  
			  Return ret
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  Declare Function OpenProcess Lib "Kernel32" (access As Integer, inherit As Boolean, procID As Integer) As Integer
			  Declare Function SetPriorityClass Lib "Kernel32" (handle As Integer, priority As Integer) As Integer
			  Declare Sub CloseHandle Lib "Kernel32" (handle As Integer)
			  
			  Dim processHandle As Integer = OpenProcess(PROCESS_SET_INFORMATION, False, processID)
			  
			  If processHandle <> 0 Then
			    Dim ret As Integer = SetPriorityClass(processHandle, value)
			    If ret = 0 Then
			      Debug(True, "Try to change priority on process ID " + Str(processId) + " to " + Str(value))
			    End If
			  Else
			    If GetLastError = 5 Then
			      #pragma BreakOnExceptions off
			      Raise New AccessDenied(Me)
			      #pragma BreakOnExceptions on
			    End If
			  End If
			  CloseHandle(processHandle)
			End Set
		#tag EndSetter
		Priority As Integer
	#tag EndComputedProperty

	#tag Property, Flags = &h0
		ProcessID As Integer
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  if msmallIcon = Nil Then
			    smallIcon = GetIco(path, 16)
			  end if
			  return msmallIcon
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  msmallIcon = value
			End Set
		#tag EndSetter
		smallIcon As Picture
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  If Not tloaded Then LoadThreads()
			  tloaded = True
			  
			  Return IsSuspended(Me)
			End Get
		#tag EndGetter
		Suspended As Boolean
	#tag EndComputedProperty

	#tag Property, Flags = &h0
		Threads() As ThreadInformation
	#tag EndProperty

	#tag Property, Flags = &h21
		Private tloaded As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		Windows() As ProcWindow
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="BaseThreadPriority"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="CommandLine"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Hidden"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="isCritical"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="largeIcon"
			Group="Behavior"
			Type="Picture"
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
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="NumberOfThreads"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ParentProcessID"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Priority"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ProcessID"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="smallIcon"
			Group="Behavior"
			Type="Picture"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Suspended"
			Group="Behavior"
			Type="Boolean"
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
