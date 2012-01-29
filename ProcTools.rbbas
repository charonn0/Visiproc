#tag Module
Protected Module ProcTools
	#tag Method, Flags = &h0
		Function closeProcHandle(pHandle As Integer) As Integer
		  Declare Function CloseHandle Lib "Kernel32.dll" (ByVal Handle As Integer) As Integer
		  Return CloseHandle(pHandle)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CPUTimes() As Pair
		  Declare Function GetSystemTimes Lib "Kernel32" (ByRef idle As FILETIME, ByRef kernel As FILETIME, ByRef user As FILETIME) As Boolean
		  Dim k, u, i As FILETIME
		  Call GetSystemTimes(i, k, u)
		  Dim totaltime As Integer = i.LowDateTime + k.LowDateTime + u.LowDateTime
		  Dim user As Integer = u.LowDateTime * 100 / totaltime
		  Dim idle As Integer = i.LowDateTime * 100 / totaltime
		  Dim kernel As Integer = (k.LowDateTime * 100 / totaltime) * user / 100
		  
		  Return user:kernel
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CPUUsage() As Double()
		  Dim s() As Double = kernelTime()
		  //s.Append(0)
		  Return s
		  
		  
		  
		  Soft Declare Sub NtQuerySystemInformation Lib "ntdll" (infoClass As Integer, data As Ptr, length As Integer, ByRef retLength As Integer)
		  Dim ret() As Double
		  If Not System.IsFunctionAvailable("NtQuerySystemInformation", "ntdll") Then
		    ret.Append(-1.0)
		    ret.Append(-1.0)
		     Return ret
		  End If
		  
		  Dim retStructSize As Integer
		  // First, get the system time information
		  Dim sysTimeInfo As New MemoryBlock(32)
		  NtQuerySystemInformation(SYSTEM_TIMEINFORMATION, sysTimeInfo, sysTimeInfo.Size, retStructSize)
		  
		  // Then get the system's idle time information
		  Dim sysIdleTimeInfo As New MemoryBlock(312)
		  NtQuerySystemInformation(SYSTEM_PERFORMANCEINFORMATION, sysIdleTimeInfo, sysIdleTimeInfo.Size, retStructSize)
		  
		  // Current value = New value - Old value
		  Static sOldIdleTime, sOldSystemTime As Double
		  
		  // Note, we can just pass this MemoryBlock in because the
		  // LongLongToDouble API assumes that the long long is the
		  // first 8 bytes of the block, which it just so happens to be
		  // in the sysIdleTimeInfo structure.
		  Dim dbIdleTime As Double
		  #If RBVersion < 2006.01 then
		    dbIdleTime = LongLongToDouble(sysIdleTimeInfo) - sOldIdleTime
		  #Else
		    dbIdleTime = sysIdleTimeInfo.UInt64Value(0) - sOldIdleTime
		  #endif
		  
		  // We're not so lucky here -- we need to get the long long into
		  // a new memory block
		  Dim tempMb As New MemoryBlock(8)
		  tempMb.Long(0) = sysTimeInfo.Long(8)
		  tempMb.Long(4) = sysTimeInfo.Long(12)
		  Dim dbSystemTime As Double
		  #If RBVersion < 2006.01 then
		    dbSystemTime = LongLongToDouble(tempMb) - sOldSystemTime
		  #Else
		    dbSystemTime = tempMb.UInt64Value(0) - sOldSystemTime
		  #endif
		  
		  Dim retVal As Double
		  
		  // Divide the idle by the system time
		  If dbSystemTime <> 0 then
		    retVal = dbIdleTime / dbSystemTime
		  Else
		    retVal = dbIdleTime
		  End If
		  
		  // Get the number of processors, but cache the information
		  // since it's not going to change while the application is running.
		  Static sNumProcessors As Integer
		  If sNumProcessors = 0 Then sNumProcessors = NumberOfProcessors
		  
		  // Now get the True CPU usage time
		  retVal = 100 - retVal * 100 / sNumProcessors + .5
		  
		  // Then store the values For the next query
		  #If RBVersion < 2006.001 then
		    sOldIdleTime = LongLongToDouble(sysIdleTimeInfo)
		    sOldSystemTime = LongLongToDouble(tempMb)
		  #Else
		    sOldIdleTime = sysIdleTimeInfo.UInt64Value(0)
		    sOldSystemTime = tempMb.UInt64Value(0)
		  #endif
		  
		  
		  ret.Append(retVal)
		  ret.Append(0)
		  //ret.Append(kernelTime(retVal))
		  
		  Return ret
		  
		  
		  
		  
		  
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function FormatErrorMessage(err As Integer) As String
		  Dim ret As Integer
		  Dim buffer As memoryBlock
		  Declare Function FormatMessageW Lib "kernel32" (dwFlags As Integer, lpSource As Integer, dwMessageId As Integer, dwLanguageId As Integer, lpBuffer As ptr, _
		  nSize As Integer, Arguments As Integer) As Integer
		  
		  Const FORMAT_MESSAGE_FROM_SYSTEM = &H1000
		  
		  buffer = New MemoryBlock(2048)
		  ret = FormatMessageW(FORMAT_MESSAGE_FROM_SYSTEM, 0, err, 0 , Buffer, Buffer.Size, 0)
		  If ret <> 0 then
		    Return Buffer.WString(0)
		  End If
		  
		  Return str(err)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetActiveProcesses() As ProcessInformation()
		  Declare Function CreateToolhelp32Snapshot Lib "Kernel32" (flags As Integer, id As Integer) As Integer
		  Declare Sub CloseHandle Lib "Kernel32" (handle As Integer)
		  Declare Sub Process32FirstW Lib "Kernel32" (handle As Integer, entry As Ptr)
		  Declare Function Process32NextW Lib "Kernel32" (handle As Integer, entry As Ptr) As Boolean
		  
		  Dim snapHandle As Integer
		  snapHandle = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0)
		  
		  Dim mb As MemoryBlock
		  mb = New MemoryBlock((260 * 2) + 36)
		  Dim entry, ret() As ProcessInformation
		  
		  mb.Long(0) = mb.Size
		  Process32FirstW(snapHandle, mb)
		  
		  Dim good As Boolean
		  do
		    entry = New ProcessInformation(mb)
		    ret.Append(entry)
		    good = Process32NextW(snapHandle, mb)
		  loop until Not good
		  CloseHandle(snapHandle)
		  
		  Return ret
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function getCmdLine(proc As ProcessInformation) As String
		  If WMIobj = Nil Then WMIobj = New WindowsWMIMBS
		  if WMIobj.ConnectServer("root\cimv2") then
		    if WMIobj.query("WQL","select CommandLine from Win32_Process where ProcessId='" + Str(proc.ProcessID) + "'") then
		      if WMIobj.NextItem then
		        Return WMIobj.GetPropertyString("CommandLine") // string
		      else
		        Return ""
		      end if
		    else
		      Return ""
		    end if
		  else
		    Return ""
		  end if
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function getDeadProcs() As ProcessInformation()
		  Dim ret() As ProcessInformation
		  
		  For i As Integer = 0 To activeProcessesOld.Ubound
		    For Each proc As ProcessInformation In activeProcesses
		      If activeProcessesOld(i).ProcessID = proc.ProcessID Then
		        Continue For i
		      End If
		    Next
		    ret.Append(activeProcessesOld(i))
		  Next
		  
		  Return ret
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetIco(path As FolderItem, size As Integer) As Picture
		  Declare Function ExtractIconExW Lib "Shell32" ( lpszFile As WString, ByVal nIconIndex As Integer, phiconLarge As ptr, phiconSmall As ptr, ByVal nIcons As Integer ) As Integer
		  Declare Function DrawIconEx Lib "user32" ( hDC As Integer, xLeft As Integer, yTop As Integer, hIcon As Integer, cxWidth As Integer, cyWidth As Integer, istepIfAniCur As Integer, _
		  hbrFlickerFreeDraw As Integer, diFlags As Integer ) As Integer
		  Declare Function DestroyIcon Lib "user32" ( hIcon As Integer ) As Integer
		  
		  Dim theIcon As Picture
		  
		  If size = 16 Then
		    theIcon = New Picture(16, 16, 32)
		    //theMask = New Picture(16, 16, 8)
		  Else
		    theIcon = New Picture(32, 32, 32)
		    //theMask = New Picture(32, 32, 8)
		  End If
		  theIcon.Transparent = 1
		  If path = Nil Then
		    If size = 16 Then
		      theIcon.Graphics.DrawPicture(noicon_16, 0, 0)
		    ElseIf size = 32 Then
		      theIcon.Graphics.DrawPicture(noicon_32, 0, 0)
		    End If
		    Return theIcon
		  End If
		  
		  Dim small As New MemoryBlock(4)
		  Dim large As New MemoryBlock(4)
		  'Dim largeMask As New MemoryBlock(4)
		  'Dim smallMask As New MemoryBlock(4)
		  Try
		    Call ExtractIconExW(path.AbsolutePath, 0, large, small, 1)
		    //Call ExtractIconExW(path.AbsolutePath, 0, largeMask, smallMask, 1)
		    
		    If size = 16 Then
		      If small.Long(0) = 0 Then
		        theIcon.Graphics.DrawPicture(noicon_16, 0, 0)
		      Else
		        Call DrawIconEx(theIcon.Graphics.Handle(1), 0, 0, small.Long(0), 16, 16, 0, 0, &H3)
		        //Call DrawIconEx(theMask.Graphics.Handle(1), 0, 0, small.Long(0), 16, 16, 0, 0, &H1)
		        //theIcon.Mask = theMask
		      End If
		    ElseIf size = 32 Then
		      If large.Long(0) = 0 Then
		        theIcon.Graphics.DrawPicture(noicon_32, 0, 0)
		      Else
		        Call DrawIconEx(theIcon.Graphics.Handle(1), 0, 0, large.Long(0), 32, 32, 0, 0, &H3)
		        //Call DrawIconEx(theMask.Graphics.Handle(1), 0, 0, small.Long(0), 32, 32, 0, 0, &H1)
		        //theIcon.Mask = theMask
		      End If
		    End If
		  Catch
		    //theIcon.Transparent = 1
		    If size = 16 Then
		      theIcon.Graphics.DrawPicture(noicon_16, 0, 0)
		    ElseIf size = 32 Then
		      theIcon.Graphics.DrawPicture(noicon_32, 0, 0)
		    End If
		  Finally
		    Call DestroyIcon(small.Long(0))
		    'Call DestroyIcon(smallMask.Long(0))
		    Call DestroyIcon(large.Long(0))
		    'Call DestroyIcon(largeMask.Long(0))
		    Return theIcon
		  End Try
		  
		  
		Exception
		  Return theIcon
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function getMemInfo() As UInt32
		  Dim mb as new MemoryBlock(64)
		  Declare function GlobalMemoryStatusEx lib "kernel32" (p as ptr) as integer
		  Dim perc As UInt64
		  mb.Int32Value(0) = 64
		  Call GlobalMemoryStatusEx(mb)
		  
		  perc =  mb.UInt32Value(4)
		  Return perc
		  //Int64Value(16) * 100 / mb.Int64Value(8)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function getNewProcs() As ProcessInformation()
		  Dim ret() As ProcessInformation
		  For n As Integer = 0 To UBound(activeProcesses)
		    For o As Integer = 0 to UBound(activeProcessesOld)
		      If activeProcessesOld(o).ProcessID = activeProcesses(n).ProcessID Then
		        Continue For n
		      End If
		    Next
		    ret.Append(activeProcesses(n))
		  Next
		  
		  Return ret
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetProcFromWindowHandle(handle As Integer) As ProcessInformation
		  Declare Sub GetWindowThreadProcessId  Lib "User32" ( hwnd as Integer, ByRef procId as Integer )
		  dim processID as Integer
		  GetWindowThreadProcessId( handle, processId )
		  
		  // Now we get a list of all the processes, and see if we can find
		  // one with a match.
		  //dim processes(-1) as ProcessInformation
		  //processes = GetActiveProcesses
		  
		  dim ret as ProcessInformation
		  for each ret in activeprocesses
		    if ret.ProcessID = processID then
		      return ret
		    end if
		  next
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function getProcHandle(procID As Integer, access As Integer) As Integer
		  Declare Function OpenProcess Lib "Kernel32.dll" (ByVal dwDesiredAccessAs As Integer, ByVal bInheritHandle As Integer, ByVal dwProcId As Integer) As Integer
		  Dim pHandle As Integer = OpenProcess(access, 0, procID)
		  if pHandle = 0 Then
		    Dim err As Integer = GetLastError()
		    pHandle = err * -1
		  end if
		  Return pHandle
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetWindowList() As Boolean
		  If WindowThread = Nil Then
		    WindowThread = New WindowGetter
		    WindowThread.Run
		  Else
		    If WindowThread.State = Thread.Running Then
		      Return True
		    Else
		      WindowThread.Run
		    End If
		  End If
		  
		  Return True
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function imageFromProcID(processID As Integer) As FolderItem
		  Declare Function CloseHandle Lib "Kernel32.dll" (ByVal Handle As Integer) As Integer
		  Declare Function OpenProcess Lib "Kernel32.dll" (ByVal dwDesiredAccessAs As Integer, ByVal bInheritHandle As Integer, ByVal dwProcId As Integer) _
		  As Integer
		  
		  If Not System.IsFunctionAvailable("QueryFullProcessImageNameW", "Kernel32") Then
		    Soft Declare Function GetModuleFileNameExW Lib "psapi.dll" (ByVal hProcess As Integer, ByVal hModule As Integer, ModuleName As Ptr, ByVal nSize _
		    As Integer) As Integer
		    
		    
		    Dim Modules As New MemoryBlock(1024)  // 1024 = SIZE_MINIMUM * sizeof(HMODULE)
		    Dim ModuleName As New MemoryBlock(1024)
		    Dim nSize As Integer
		    
		    Dim hProcess As Integer = OpenProcess(PROCESS_QUERY_INFORMATION Or PROCESS_VM_READ, 0, processID)
		    Dim Result As String
		    If hProcess <> 0 Then
		      ModuleName =New MemoryBlock(1024)
		      nSize = 1024
		      Call GetModuleFileNameExW(hProcess, Modules.Int32Value(0), ModuleName, 1024)
		      Result=Result+ModuleName.WString(0)
		    End If
		    Call CloseHandle(hProcess)
		    Result = Replace(Result, "\??\", "")
		    Result = Replace(Result, "\SystemRoot\", SpecialFolder.Windows.AbsolutePath)
		    Dim ret As FolderItem
		    
		    If Result <> "" Then
		      ret = GetFolderItem(Result)
		    End If
		    Return ret
		  Else
		    Soft Declare Function QueryFullProcessImageNameW Lib "Kernel32" (pHandle As Integer, flags As Integer, path As Ptr, ByRef pathSize As Integer) As Boolean
		    Const PROCESS_QUERY_LIMITED_INFORMATION = &h1000
		    Dim mb As New MemoryBlock(1024)
		    Dim ssize As Integer = 1024
		    Dim hProcess As Integer = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, 0, processID)
		    If hProcess <> 0 Then
		      If QueryFullProcessImageNameW(hProcess, 0, mb, ssize) Then
		        Return GetFolderItem(mb.WString(0))
		      Else
		        Return Nil
		      End If
		    End If
		  End If
		  
		  
		  
		  
		  
		  
		  
		Exception
		  Return Nil
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function isRunning(Extends s As String) As Boolean
		  For Each proc As ProcessInformation In activeProcesses
		    If proc.Name = s Then
		      Return True
		    End If
		  Next
		  Return False
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsSuspended(proc As ProcessInformation) As Boolean
		  Declare Function ResumeThread Lib "Kernel32" (hThread As Integer) As Integer
		  Declare Function SuspendThread Lib "Kernel32" (hThread As Integer) As Integer
		  Declare Function OpenThread Lib "Kernel32" (access As Integer, inherit As Boolean, threadID As Integer) As Integer
		  Declare Function CloseHandle Lib "Kernel32" (tHandle As Integer) As Boolean
		  
		  If proc.isCritical Then Return False
		  If proc.Name = "Explorer.exe" Then Return False
		  If proc.Name = App.ExecutableFile.Name Then Return False
		  Dim ret As Integer
		  For i As Integer = 0 To proc.Threads.Ubound
		    Const THREAD_SUSPEND_RESUME = &h0002
		    Dim thandle As Integer = OpenThread(THREAD_SUSPEND_RESUME, False, proc.Threads(i).ThreadID)
		    If thandle > 0 Then
		      Dim suscount As Integer = SuspendThread(thandle)
		      If suscount > 0 Then
		        ret = ret + 1
		      End If
		      Call ResumeThread(thandle)
		      Call CloseHandle(thandle)
		      
		    End If
		  Next
		  If ret = proc.Threads.Ubound + 1 Then 
		    'Break
		    Return True
		  Else
		    Return False
		  End If
		  
		  
		  
		  'If proc.Name = "notepad++.exe" Then Break
		  'If WMIobj = Nil Then WMIobj = New WindowsWMIMBS
		  'if WMIobj.ConnectServer("root\cimv2") then
		  'Declare Function GetThreadSuspendCount Lib "ntdll" (hThread As Integer) As Integer
		  'Declare Function OpenThread Lib "Kernel32" (access As Integer, inherit As Boolean, threadID As Integer) As Integer
		  '
		  'For i As Integer = 0 To proc.Threads.Ubound
		  'Const THREAD_QUERY_INFORMATION = &h0040
		  'Const THREAD_QUERY_LIMITED_INFORMATION = &h0800
		  'Dim access As Integer
		  'If Platform.IsAtLeast(Platform.WinVista) Then
		  'access = THREAD_QUERY_LIMITED_INFORMATION
		  'Else
		  'access = THREAD_QUERY_INFORMATION
		  'End If
		  '
		  'Dim thandle As Integer = OpenThread(access, False, proc.Threads(i).ThreadID)
		  'Dim x As Integer = GetThreadSuspendCount(thandle)
		  'If thandle > 0 Then Break
		  'Next
		  'end if
		  ''
		  ''
		  ''if WMIobj.query("WQL","select ThreadWaitReason from Win32_Threads where Name='" + proc.Name + "'") then
		  ''if WMIobj.NextItem then
		  ''Dim i As Integer = WMIobj.GetPropertyInteger("ThreadWaitReason")
		  ''If i >= 5 Then
		  ''Return True
		  ''Else
		  ''Return False
		  ''End If
		  ''//String("CommandLine") // string
		  ''else
		  ''Return False
		  ''end if
		  ''else
		  ''Return False
		  ''end if
		  ''else
		  ''Return False
		  ''end if
		  ''
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function kernelTime() As Double()
		  Declare Function GetSystemTimes Lib "kernel32.dll" (idleTime As Ptr, kernelTime As Ptr, userTime As Ptr) As Boolean
		  Declare Function FileTimeToSystemTime Lib "kernel32.dll" (fileTime As Ptr, systemTime As Ptr) As Boolean
		  Dim user, kernel, idle As MemoryBlock
		  user = New MemoryBlock(8)
		  kernel = New MemoryBlock(8)
		  idle = New MemoryBlock(8)
		  Call GetSystemTimes(idle, kernel, user)
		  
		  Dim k, i, u As UInt64
		  Static oldK, oldI, oldU As UInt64
		  k = kernel.UInt64Value(0) - oldK
		  i = idle.UInt64Value(0) - oldI
		  u = user.UInt64Value(0) - oldU
		  oldK = kernel.UInt64Value(0)
		  oldI = idle.UInt64Value(0)
		  oldU = user.UInt64Value(0)
		  
		  'Dim total As Double = (k + u) - i * 100 / (k + u)
		  'Dim kern As Double = 
		  
		  '
		  'Dim kP, iP, uP As Int64
		  'Dim totalTime As UInt64 = k + u
		  'kP = (k * 100 / totalTime) //* 0.5
		  'uP = (u * 100 / totalTime) //* 0.5
		  'iP = (i * 100 / totalTime) //* 0.5
		  'Static sNumProcessors As Integer
		  'If sNumProcessors = 0 Then sNumProcessors = NumberOfProcessors
		  'kP = 100 - kP * 100 / sNumProcessors + .5
		  
		  Dim ret() As Double
		  Dim sys As Double = k + u
		  ret.Append((sys - i) * 100 / sys)
		  
		  ret.Append((sys - i - u) * 100 / sys)
		  ret.Append(100 - ret(0) - ret(1))
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  Return ret
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function NumberOfProcessors() As Integer
		  Declare Sub GetSystemInfo Lib "Kernel32" (info As Ptr)
		  
		  Dim info As New MemoryBlock(9 * 4)
		  GetSystemInfo(info)
		  
		  Return info.Long(20)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function pad(Extends theMask As Byte) As String
		  Dim strMask As String  = Bin(theMask)
		  For i As Integer = strMask.Len To 7
		    strMask = "0" + strMask
		  next
		  
		  Return strMask
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ProcInfoFromID(Extends procID As Integer) As ProcessInformation
		  For Each proc As ProcessInformation In activeProcesses
		    If proc.ProcessID = procID Then
		      Return proc
		    End If
		  Next
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function str2bin(Extends theMask As String) As Byte
		  Return Val("&b" + theMask)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub terminate(Extends process As ProcessInformation, exitCode As Integer = 0)
		  Declare Function TerminateProcess Lib "Kernel32" (handle As Integer, exitCode As Integer) As Integer
		  Declare Function OpenProcess Lib "Kernel32" (access As Integer, inheritHandle As Boolean, processId As Integer) As Integer
		  Declare Sub CloseHandle Lib "Kernel32" (handle As Integer)
		  
		  Dim processHandle As Integer = OpenProcess(PROCESS_TERMINATE, False, process.ProcessID)
		  If processHandle <> 0 then
		    If TerminateProcess(processHandle, exitCode) = 0 Then
		      debug(True, "Try to terminate process ID " + Str(process.ProcessID))
		    Else
		      //If notify Then nullwin.showNotify(process.name + " has been killed")
		    End If
		    CloseHandle(processHandle)
		  Else
		    Dim x As Integer = GetLastError
		    #pragma BreakOnExceptions Off
		    Raise New AccessDenied(process, x)
		    #pragma BreakOnExceptions On
		  End If
		  
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		activeProcesses() As ProcessInformation
	#tag EndProperty

	#tag Property, Flags = &h0
		activeProcessesOld() As ProcessInformation
	#tag EndProperty

	#tag Property, Flags = &h0
		DebugLog() As String
	#tag EndProperty

	#tag Property, Flags = &h0
		DebugMode As Boolean = True
	#tag EndProperty

	#tag Property, Flags = &h0
		Drives() As Pair
	#tag EndProperty

	#tag Property, Flags = &h0
		FirstRun As Boolean = True
	#tag EndProperty

	#tag Property, Flags = &h0
		HideSystemProcs As Boolean = True
	#tag EndProperty

	#tag Property, Flags = &h0
		HilightOn As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		ICOSize As Integer = 32
	#tag EndProperty

	#tag Property, Flags = &h0
		ignoredProcs() As String
	#tag EndProperty

	#tag Property, Flags = &h0
		lastCPU(3) As Double
	#tag EndProperty

	#tag Property, Flags = &h0
		LastMem As Double
	#tag EndProperty

	#tag Property, Flags = &h0
		WindowThread As WindowGetter
	#tag EndProperty

	#tag Property, Flags = &h0
		WMIobj As WindowsWMIMBS
	#tag EndProperty


	#tag Constant, Name = priorityAboveNormal, Type = Double, Dynamic = False, Default = \"&h8000", Scope = Public
	#tag EndConstant

	#tag Constant, Name = priorityBelowNormal, Type = Double, Dynamic = False, Default = \"&h4000", Scope = Public
	#tag EndConstant

	#tag Constant, Name = PriorityHigh, Type = Double, Dynamic = False, Default = \"&h80", Scope = Public
	#tag EndConstant

	#tag Constant, Name = PriorityIdle, Type = Double, Dynamic = False, Default = \"&h40", Scope = Public
	#tag EndConstant

	#tag Constant, Name = PriorityNormal, Type = Double, Dynamic = False, Default = \"&h20", Scope = Public
	#tag EndConstant

	#tag Constant, Name = PriorityRealTime, Type = Double, Dynamic = False, Default = \"&h100", Scope = Public
	#tag EndConstant

	#tag Constant, Name = PROCESS_ALL_ACCESS, Type = Double, Dynamic = False, Default = \"&h1F0FFF", Scope = Public
	#tag EndConstant

	#tag Constant, Name = PROCESS_QUERY_INFORMATION, Type = Double, Dynamic = False, Default = \"&h400", Scope = Public
	#tag EndConstant

	#tag Constant, Name = PROCESS_SET_INFORMATION, Type = Double, Dynamic = False, Default = \"&h200", Scope = Public
	#tag EndConstant

	#tag Constant, Name = PROCESS_TERMINATE, Type = Double, Dynamic = False, Default = \"&h1", Scope = Public
	#tag EndConstant

	#tag Constant, Name = PROCESS_VM_READ, Type = Double, Dynamic = False, Default = \"&h10", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SYSTEM_PERFORMANCEINFORMATION, Type = Double, Dynamic = False, Default = \"2", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SYSTEM_TIMEINFORMATION, Type = Double, Dynamic = False, Default = \"3", Scope = Public
	#tag EndConstant

	#tag Constant, Name = TH32CS_SNAPPROCESS, Type = Double, Dynamic = False, Default = \"&h2", Scope = Public
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="DebugMode"
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="FirstRun"
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="HideSystemProcs"
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="HilightOn"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ICOSize"
			Group="Behavior"
			InitialValue="32"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LastMem"
			Group="Behavior"
			Type="Double"
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
