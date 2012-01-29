#tag Module
Protected Module Platform
	#tag Method, Flags = &h21
		Private Function AdjustPrivilegeToken(PrivilegeName As String, mode As Integer) As Integer
		  //Modifies the calling process' security token
		  //See the SE_* Constants in Win32Constants for privilege names.
		  
		  Declare Function GetCurrentProcess Lib "Kernel32" () As Integer
		  Declare Function OpenProcessToken Lib "AdvApi32" (handle As Integer, access As Integer, ByRef tHandle As Integer) As Boolean
		  Declare Function LookupPrivilegeValueW Lib "AdvApi32" (sysName As WString, privName As WString, Luid As Ptr) As Boolean
		  Declare Function AdjustTokenPrivileges Lib "AdvApi32" (tHandle As Integer, disableAllPrivs As Boolean, newState As Ptr, buffLength As Integer, prevPrivs As Ptr, ByRef retLen As Integer) As Boolean
		  
		  Const TOKEN_QUERY = &h00000008
		  Const TOKEN_ADJUST_PRIVILEGES = &h00000020
		  
		  Dim thisProc As Integer = GetCurrentProcess()
		  Dim tHandle As Integer
		  If OpenProcessToken(thisProc, TOKEN_ADJUST_PRIVILEGES Or TOKEN_QUERY, tHandle) Then
		    Dim luid As New MemoryBlock(8)
		    If LookupPrivilegeValueW(Nil, PrivilegeName, luid) Then
		      Dim newState As New MemoryBlock(16)
		      newState.UInt32Value(0) = 1
		      newState.UInt32Value(4) = luid.UInt32Value(0)
		      newState.UInt32Value(8) = luid.UInt32Value(4)
		      newState.UInt32Value(12) = mode  //mode can be enable, disable, or remove. See: EnablePrivilege, DisablePrivilege, and DropPrivilege.
		      Dim retLen As Integer
		      Dim prevPrivs As Ptr
		      If AdjustTokenPrivileges(tHandle, False, newState, newState.Size, prevPrivs, retLen) Then
		        Return 0
		      Else
		        Return LastErrorCode
		      End If
		    Else
		      Return LastErrorCode
		    End If
		  Else
		    Return LastErrorCode
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub Beep(freq As Integer, duration As Integer)
		  //This function differs from the built-in Beep method in that both the frequency and duration of the beep can (must) be specified. 
		  //Windows Vista and XP64 omit this function.
		  
		  If System.IsFunctionAvailable("Beep", "Kernel32") Then
		    Soft Declare Function WinBeep Lib "Kernel32" Alias "Beep" (freq As Integer, duration As Integer) As Boolean
		    Call WinBeep(freq, duration)
		  Else
		    #If TargetHasGUI Then Realbasic.Beep  //Built-in beep not available in ConsoleApplications? Weird.
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function CPUArchitecture() As Integer
		  //Returns the CPU architecture of the installed operating system. See the PROCESSOR_ARCHITECTURE_* constants for possible return values
		  //This may differ from the information provided by OSArchitecture since a 32 bit OS can run on a 64 bit capable processor (see below)
		  
		  Dim info As SYSTEM_INFO
		  
		  If OSArchitecture = 64 Then
		    //The RB compiler, as of the time this function is being written, is incapable of creating 64 bit Windows executables.
		    //As a result, all RB applications under 64 bit Windows are executed within the Win32 subsystem of Win64 (WoW64)
		    //WoW64 accomplishes its task by, primarily, lying to the application about its environment. We have to
		    //specifically ask not to be lied to in these cases. Hence, this function call:
		    Soft Declare Sub GetNativeSystemInfo Lib "Kernel32" (ByRef info As SYSTEM_INFO)
		    GetNativeSystemInfo(info)
		  Else
		    Soft Declare Sub GetSystemInfo Lib "Kernel32" (ByRef info As SYSTEM_INFO)
		    GetSystemInfo(info)
		  End If
		  
		  Return info.OEMID
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function CPUUsage() As Double
		  //Returns the percent of CPU resources currently in use system-wide.
		  
		  Declare Function GetSystemTimes Lib "Kernel32" (idleTime As Ptr, kernelTime As Ptr, userTime As Ptr) As Boolean
		  
		  Dim user, kernel, idle As MemoryBlock
		  user = New MemoryBlock(8)
		  kernel = New MemoryBlock(8)
		  idle = New MemoryBlock(8)
		  Call GetSystemTimes(idle, kernel, user)
		  
		  Dim k, i, u As UInt64
		  Static oldK, oldI, oldU As UInt64
		  If oldk = 0 Or oldI = 0 Or oldU = 0 Then
		    k = kernel.UInt64Value(0)
		    I = idle.UInt64Value(0)
		    U = user.UInt64Value(0)
		  End If
		  
		  k = kernel.UInt64Value(0) - oldK
		  i = idle.UInt64Value(0) - oldI
		  u = user.UInt64Value(0) - oldU
		  oldK = kernel.UInt64Value(0)
		  oldI = idle.UInt64Value(0)
		  oldU = user.UInt64Value(0)
		  
		  Return (k + u - i) * 100 / (k + u)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function CTL_CODE(lngDevFileSys As Integer, lngFunction As Integer, lngMethod As Integer, lngAccess As Integer) As Integer
		  lngDevFileSys = lngDevFileSys * (2^16)
		  lngAccess = lngAccess * (2^14)
		  lngFunction = lngFunction * (2^2)
		  Return lngDevFileSys Or lngAccess Or lngFunction Or lngMethod
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function CurrentUser() As String
		  //Returns the username of the account under which the application is running.
		  //On Error, returns an empty string
		  //Do not use this function to determine if the user is the Administrator. Use IsAdmin instead.
		  
		  Declare Function GetUserNameW Lib "AdvApi32" (buffer As Ptr, ByRef buffSize As Integer) As Boolean
		  
		  Dim mb As New MemoryBlock(0)
		  Dim nmLen As Integer = mb.Size
		  Call GetUserNameW(mb, nmLen)
		  mb = New MemoryBlock(nmLen * 2)
		  nmLen = mb.Size
		  If GetUserNameW(mb, nmLen) Then
		    Return mb.WString(0)
		  Else
		    Return ""
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function DisablePrivilege(PrivilegeName As String) As Boolean
		  //This function attempts to disable the privilege designated by PrivilegeName in the process' security token.
		  //Privilege names are documented here: http://msdn.microsoft.com/en-us/library/windows/desktop/bb530716%28v=vs.85%29.aspx
		  //This function will fail and return False if the processes security token did not already posess the requested privilege, if the privilege
		  //requested does not exist, if the process does not have TOKEN_ADJUST_PRIVILEGES and TOKEN_QUERY access to itself, or if the Privilege was not 
		  //already enabled.
		  
		  If AdjustPrivilegeToken(PrivilegeName, 0) = 0 Then
		    Return True
		  Else
		    Return False
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function DropPrivilege(PrivilegeName As String) As Boolean
		  //This function attempts remove the privilege designated by PrivilegeName in the process' security token. This is different
		  //from merely disabling the Privilege since future attempts to enable it will fail with ERROR_PRIVILEGE_NOT_HELD.
		  //Once a privilege is dropped, it cannot be reacquired.
		  //On Windows XP SP1 and earlier, privileges cannot be dropped.
		  //Privilege names are documented here: http://msdn.microsoft.com/en-us/library/windows/desktop/bb530716%28v=vs.85%29.aspx
		  //This function will fail and return False if the processes security token did not already posess the requested privilege, if the privilege
		  //requested does not exist, or if the process does not have TOKEN_ADJUST_PRIVILEGES and TOKEN_QUERY access to itself.
		  
		  Const SE_PRIVILEGE_REMOVED = &h00000004
		  
		  If AdjustPrivilegeToken(PrivilegeName, SE_PRIVILEGE_REMOVED) = 0 Then
		    Return True
		  Else
		    Return False
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function DumpRawKey(Extends RegPath As RegistryItem, SaveTo As FolderItem) As Boolean
		  //Saves the specified registry key and all subkeys to the specified file. The format of the dumped data is in the native binary format.
		  //To export a key, use ExportKey.
		  //This function will fail if the key does not exist, if the application does not have the neccessary access rights, or if the SaveTo FolderItem is Nil or
		  //inaccessible.
		  
		  If Platform.IsAtLeast(Platform.WinXP) Then
		    Soft Declare Function RegSaveKeyExW Lib "AdvApi32" (regHandle As Integer, file As WString, secAttribs As Ptr, flags As Integer) As Integer
		    Declare Function RegOpenKeyExW Lib "AdvApi32" (hKey As Integer, subkey As WString, reserved As Integer, accessRights As Integer, ByRef result As Integer) As Integer
		    Declare Function RegCloseKey Lib "AdvApi32" (rHandle As Integer) As Integer
		    
		    Const HKEY_CLASSES_ROOT = &h80000000
		    Const HKEY_CURRENT_USER = &h80000001
		    Const HKEY_LOCAL_MACHINE = &h80000002
		    Const HKEY_USERS  = &h80000003
		    Const HKEY_PERFORMANCE_DATA = &h80000004
		    Const HKEY_PERFORMANCE_TEXT = &h80000050
		    Const HKEY_PERFORMANCE_NLSTEXT = &h80000060
		    Const HKEY_CURRENT_CONFIG = &h80000005
		    Const HKEY_DYN_DATA = &h80000006
		    Const HKEY_CURRENT_USER_LOCAL_SETTINGS = &h80000007
		    Const KEY_QUERY_VALUE = &h0001
		    Const KEY_READ = &h20019
		    Const KEY_ENUMERATE_SUB_KEYS = &h0008
		    Const SE_BACKUP_NAME = "SeBackupPrivilege"
		    
		    If RegPath = Nil Then Raise New NilObjectException
		    If AdjustPrivilegeToken(SE_BACKUP_NAME, &h00000002) = 0 Then
		      Dim hive As UInt64
		      Dim subkey As String = Replace(RegPath.Path, NthField(RegPath.Path, "\", 1), "")
		      subkey = Right(subkey, subkey.Len - 1)
		      Dim rHandle As Integer
		      Select Case NthField(RegPath.Path, "\", 1)
		      Case "HKEY_CURRENT_USER"
		        hive = HKEY_CURRENT_USER
		      Case "HKEY_CLASSES_ROOT"
		        hive = HKEY_CLASSES_ROOT
		      Case "HKEY_LOCAL_MACHINE"
		        hive = HKEY_LOCAL_MACHINE
		      Case "HKEY_USERS"
		        hive = HKEY_USERS
		      Case "HKEY_PERFORMANCE_DATA"
		        hive = HKEY_PERFORMANCE_DATA
		      Case "HKEY_PERFORMANCE_TEXT"
		        hive = HKEY_PERFORMANCE_TEXT
		      Case "HKEY_PERFORMANCE_NLSTEXT"
		        hive = HKEY_PERFORMANCE_NLSTEXT
		      Case "HKEY_CURRENT_CONFIG"
		        hive = HKEY_CURRENT_CONFIG
		      Case "HKEY_DYN_DATA"
		        hive = HKEY_DYN_DATA
		      Case "HKEY_CURRENT_USER_LOCAL_SETTINGS"
		        hive = HKEY_CURRENT_USER_LOCAL_SETTINGS
		      Else
		        Raise New RegistryAccessErrorException
		      End Select
		      Dim i As Integer = RegOpenKeyExW(hive, subkey, 0, KEY_READ Or KEY_ENUMERATE_SUB_KEYS Or KEY_QUERY_VALUE, rHandle)
		      If i = 0 Then
		        i = RegSaveKeyExW(rHandle, SaveTo.AbsolutePath, Nil, 1)
		        If i = 0 Then
		          Call RegCloseKey(rHandle)
		          Call DisablePrivilege(SE_BACKUP_NAME)
		          Return True
		        Else
		          Call RegCloseKey(rHandle)
		          Call DisablePrivilege(SE_BACKUP_NAME)
		          Return False
		        End If
		      Else
		        Call DisablePrivilege(SE_BACKUP_NAME)
		        Raise New RegistryAccessErrorException
		      End If
		    Else
		      Raise New RegistryAccessErrorException
		    End If
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function EnablePrivilege(PrivilegeName As String) As Boolean
		  //This function attempts to enable the privilege designated by PrivilegeName in the process' security token.
		  //Privilege names are documented here: http://msdn.microsoft.com/en-us/library/windows/desktop/bb530716%28v=vs.85%29.aspx
		  //This function will fail and return False if the processes security token did not already posess the requested privilege, if the privilege
		  //requested does not exist, or if the process does not have TOKEN_ADJUST_PRIVILEGES and TOKEN_QUERY access to itself.
		  
		  Const SE_PRIVILEGE_ENABLED = &h00000002
		  
		  If AdjustPrivilegeToken(PrivilegeName, SE_PRIVILEGE_ENABLED) = 0 Then
		    Return True
		  Else
		    Return False
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function ErrorMessageFromCode(err As Integer) As String
		  //Returns the error message corresponding to a given windows error number. If no message is available, returns the error number as a string.
		  //To get the last error code call LastErrorCode immediately.
		  
		  Declare Function FormatMessageW Lib "kernel32" (dwFlags As Integer, lpSource As Integer, dwMessageId As Integer, dwLanguageId As Integer, lpBuffer As ptr, _
		  nSize As Integer, Arguments As Integer) As Integer
		  
		  Const FORMAT_MESSAGE_FROM_SYSTEM = &H1000
		  
		  Dim buffer As New MemoryBlock(2048)
		  If FormatMessageW(FORMAT_MESSAGE_FROM_SYSTEM, 0, err, 0 , Buffer, Buffer.Size, 0) <> 0 Then
		    Return Buffer.WString(0)
		  Else
		    Return str(err)
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ExitWindows(mode As Integer) As Integer
		  //Shuts down, reboots, or logs off the computer. Returns 0 on success, or a Win32 error code on error.
		  
		  Declare Function ExitWindowsEx Lib "User32" (flags As Integer, reason As Integer) As Boolean
		  If EnablePrivilege("SeShutdownPrivilege") Then
		    Call ExitWindowsEx(mode, 0)
		  End If
		  Return LastErrorCode()
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ExportKey(Extends RegPath As RegistryItem, SaveTo As FolderItem) As Boolean
		  #pragma Unused RegPath
		  #pragma Unused SaveTo
		  //TODO
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function IsAdmin() As Boolean
		  //Returns true if the application is running with administrative privileges
		  //Note that even if this Returns True, that not all privileges many be enabled. See: EnablePrivilege
		  Declare Function IsUserAnAdmin Lib "Shell32" () As Boolean
		  Return IsUserAnAdmin()
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function IsAtLeast(OSVersion As Double) As Boolean
		  //Returns True if the current OS is OLDER than the specified OSVersion
		  //For example on a computer running Windows XP, Platform.IsOlderThan(WinVista) Will Return True but Platform.IsOlderThan(WinXP) will Return False.
		  //See also: Platform.IsAtLeast and Platform.IsExactly
		  
		  Declare Function GetVersionExA Lib "Kernel32" (ByRef info As OSVERSIONINFOEX)As Boolean
		  Dim info As OSVERSIONINFOEX
		  info.StructSize = Info.Size
		  
		  If GetVersionExA(info) Then
		    If info.MajorVersion + (info.MinorVersion / 10) >= OSVersion Then
		      Return True
		    Else
		      Return False
		    End If
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function IsComputerOn() As Boolean
		  //Returns True if the local machine is receiving electrical power and is operating properly, otherwise the return value is undefined.
		  Return True
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function IsExactly(OSVersion As Double) As Boolean
		  //Returns True if the current OS kernel version is exactly the same as the OSVersion specified.
		  //For example on a computer running Windows XP, Platform.IsExactly(Win2000) Will Return False
		  //Server versions of consumer Windows will generally match the kernel version of the consumer version.
		  //For example, Windows Server 2008 and Windows Vista are both 6.0 but Windows XP and Windows Server 2003 are 5.1 and 5.2 respectively.
		  //See also: Platform.IsAtLeast and Platform.IsOlderThan
		  
		  Declare Function GetVersionExA Lib "Kernel32" (ByRef info As OSVERSIONINFOEx)As Boolean
		  Dim info As OSVERSIONINFOEX
		  info.StructSize = Info.Size
		  
		  If GetVersionExA(info) Then
		    If info.MajorVersion + (info.MinorVersion / 10) = OSVersion Then
		      Return True
		    Else
		      Return False
		    End If
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function IsOlderThan(OSVersion As Double) As Boolean
		  //Returns True if the current OS kernel version is older than the OSVersion specified.
		  //For example on a computer running Windows XP, Platform.IsOlderThan(Win2000) and Platform.IsOlderThan(WinXP) will both Return False
		  //See also: Platform.IsAtLeast and Platform.IsExactly
		  
		  Declare Function GetVersionExA Lib "Kernel32" (ByRef info As OSVERSIONINFOEx)As Boolean
		  Dim info As OSVERSIONINFOEX
		  info.StructSize = Info.Size
		  
		  If GetVersionExA(info) Then
		    If info.MajorVersion + (info.MinorVersion / 10) < OSVersion Then
		      Return True
		    Else
		      Return False
		    End If
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function LastErrorCode() As Integer
		  //Returns the last error for the current process. Error codes are documented here: http://msdn.microsoft.com/en-us/library/ms681381%28v=VS.85%29.aspx
		  
		  Declare Function GetLastError Lib "Kernel32" () As Integer
		  Return GetLastError()
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub LogOff()
		  //Logs off the current user
		  
		  Const EWX_LOGOFF = 0
		  Call ExitWindows(EWX_LOGOFF)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function MemoryUse() As Integer
		  //Returns an Integer representing the percent of system memory currently in use.
		   
		  Declare Function GlobalMemoryStatusEx Lib "Kernel32" (ByRef MemStatus As MEMORYSTATUSEX) As Boolean
		  
		  Dim MemStatus As MEMORYSTATUSEX
		  MemStatus.sSize = MemStatus.Size
		  Call GlobalMemoryStatusEx(MemStatus)
		  Return MemStatus.MemLoad
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function NumberOfProcessors() As Integer
		  //Returns the number of LOGICAL processor cores.
		  
		  Declare Sub GetSystemInfo Lib "Kernel32" (ByRef info As SYSTEM_INFO)
		  
		  Dim info As SYSTEM_INFO
		  GetSystemInfo(info)
		  
		  Return info.numberOfProcessors
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function OSArchitecture() As Integer
		  //Returns 64 if the current operating system is a 64 bit build, 32 for 32 bit build, -1 on error or unknown architecture.
		  //This function assumes that the application itself is a 32 bit executable. Therefore, if REALSoftware one day releases a 64 bit
		  //cabable compiler then the results of this function will become unreliable and I will be immensely pleased.
		  
		  Declare Function MyGetCurrentProcessId Lib "Kernel32" Alias "GetCurrentProcessId" () As Integer
		  Declare Function OpenProcess Lib "Kernel32" (ByVal dwDesiredAccessAs As Integer, ByVal bInheritHandle As Integer, _
		  ByVal dwProcId As Integer) As Integer
		  Declare Function IsWow64Process Lib "Kernel32" (handle As Integer, ByRef is64 As Boolean) As Boolean
		  Dim pHandle As Integer = OpenProcess(PROCESS_QUERY_INFORMATION, 0, MyGetCurrentProcessId)
		  
		  Dim is64 As Boolean
		  If IsWow64Process(pHandle, is64) Then
		    If is64 Then
		      Return 64
		    Else
		      Return 32
		    End If
		  Else
		    Return -1
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub Reboot()
		  //Reboots the computer
		  
		  Const EWX_REBOOT = &h00000002
		  Call ExitWindows(EWX_REBOOT)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub ShutDown()
		  //Shuts the computer down.
		  
		  Const EWX_SHUTDOWN = &h00000001
		  Call ExitWindows(EWX_SHUTDOWN)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function Timezone() As String
		  //This function returns a string representing the name of the current time zone. e.g. "EST" or "Pacific Daylight Time." This name
		  //is localized and may be up to 32 characters long.
		  //On error, returns an empty string.
		  
		  Declare Function GetTimeZoneInformation Lib "Kernel32" (ByRef TZInfo As TIME_ZONE_INFORMATION) As Integer
		  
		  Const daylightSavingsOn = 2
		  Const daylightSavingsOff = 1
		  Const daylightSavingsUnknown = 0
		  Const invalidTimeZone = &hFFFFFFFF
		  
		  Dim TZInfo As TIME_ZONE_INFORMATION
		  Dim dlsStatus As Integer = GetTimeZoneInformation(TZInfo)
		  
		  If dlsStatus = daylightSavingsOn Or dlsStatus = daylightSavingsOff Or dlsStatus = daylightSavingsUnknown Then
		    Return TZInfo.StandardName
		  Else
		    Return ""
		  End If
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function TotalPhysicalRAM() As UInt64
		  //Returns an Unsigned 64 bit Integer representing the number of bytes of physical RAM installed.
		  
		  Declare Function GlobalMemoryStatusEx Lib "Kernel32" (ByRef MemStatus As MEMORYSTATUSEX) As Boolean
		  
		  Dim MemStatus As MEMORYSTATUSEX
		  MemStatus.sSize = MemStatus.Size
		  Call GlobalMemoryStatusEx(MemStatus)
		  Return MemStatus.TotalPhysicalMemory
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function UTCOffset() As Double
		  //This function returns a double representing the number of hours the computer's set timezone is offset from UTC.
		  //Postive Return values indicate timezones ahead of UTC, negative indicates a time zone behind UTC.
		  //On error, returns an impossible offset (-48)
		  
		  Declare Function GetTimeZoneInformation Lib "Kernel32" (ByRef TZInfo As TIME_ZONE_INFORMATION) As Integer
		  
		  Const daylightSavingsOn = 2
		  Const daylightSavingsOff = 1
		  Const daylightSavingsUnknown = 0
		  Const invalidTimeZone = &hFFFFFFFF
		  
		  Dim TZInfo As TIME_ZONE_INFORMATION
		  Dim dlsStatus As Integer = GetTimeZoneInformation(TZInfo)
		  
		  If dlsStatus = daylightSavingsOn Or dlsStatus = daylightSavingsOff Or dlsStatus = daylightSavingsUnknown Then
		    Return TZInfo.Bias / 60
		  Else
		    Return -48
		  End If
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function VersionString() As String
		  //Returns a string similar to "Windows 7 Ultimate x64 Service Pack 1"
		  
		  Declare Function GetVersionExA Lib "Kernel32" (ByRef info As OSVERSIONINFOEx)As Boolean
		  Dim info As OSVERSIONINFOEX
		  info.StructSize = Info.Size
		  
		  If GetVersionExA(info) Then
		    Dim ret As String
		    Select Case info.MajorVersion
		      
		    Case 6
		      If info.MinorVersion = 1 Then
		        If info.ProductType = &h0000003 Then
		          ret = "Windows Server 2008 R2"
		        ElseIf info.ProductType = &h0000001 Then
		          If (BitwiseOr(info.SuiteMask, &h00000200) > 0) Then
		            ret = "Windows 7 Home Premium"
		          ElseIf (BitwiseOr(info.SuiteMask, 1) > 0) Then
		            ret = "Windows 7 Ultimate"
		          ElseIf (BitwiseOr(info.SuiteMask, 6) > 0) Then
		            ret = "Windows 7 Business"
		          ElseIf (BitwiseOr(info.SuiteMask, 4) > 0) Then
		            ret = "Windows 7 Enterprise"
		          ElseIf (BitwiseOr(info.SuiteMask, 2) > 0) Then
		            ret = "Windows 7 Home Basic"
		          ElseIf (BitwiseOr(info.SuiteMask, 11) > 0) Then
		            ret = "Windows 7 Starter"
		          End If
		        End If
		      Else
		        If info.ProductType = &h0000003 Then
		          If (BitwiseOr(info.SuiteMask, 7) > 0) Or (BitwiseOr(info.SuiteMask, 13) > 0) Then
		            ret = "Windows Server 2008"
		          ElseIf (BitwiseOr(info.SuiteMask, 8) > 0) Or (BitwiseOr(info.SuiteMask, 12) > 0) Then
		            ret = "Windows Server 2008 Datacenter"
		          ElseIf (BitwiseOr(info.SuiteMask, 10) > 0) Or (BitwiseOr(info.SuiteMask, 14) > 0) Then
		            ret = "Windows Server 2008 Enterprise"
		          ElseIf (BitwiseOr(info.SuiteMask, 15) > 0) Then
		            ret = "Windows Server 2008 Webserver"
		          ElseIf (BitwiseOr(info.SuiteMask, 8) > 0) Then
		            ret = "Windows Server 2008 Enterprise IA64"
		          ElseIf (BitwiseOr(info.SuiteMask, 1) > 0) Then
		            ret = "Windows Server 2008 Datacenter"
		          ElseIf info.ProductType = &h0000003 Then
		            ret = "Windows Server 2008 R2"
		          ElseIf (BitwiseOr(info.SuiteMask, &h00000200) > 0) Then
		            ret = "Windows Vista Home Premium"
		          ElseIf (BitwiseOr(info.SuiteMask, 1) > 0) Then
		            ret = "Windows Vista Ultimate"
		          ElseIf (BitwiseOr(info.SuiteMask, 6) > 0) Then
		            ret = "Windows Vista Business"
		          ElseIf (BitwiseOr(info.SuiteMask, 4) > 0) Then
		            ret = "Windows Vista Enterprise"
		          ElseIf (BitwiseOr(info.SuiteMask, 2) > 0) Then
		            ret = "Windows Vista Home Basic"
		          ElseIf (BitwiseOr(info.SuiteMask, 11) > 0) Then
		            ret = "Windows Vista Starter"
		          End If
		        End If
		      End If
		      
		    Case 5
		      Select Case info.MinorVersion
		      Case 2
		        If info.ProductType = &h0000001 Then
		          ret = "Windows XP Professional x64 Edition"
		        Else
		          ret = "Windows Server 2003"
		        End If
		      Case 1
		        If info.SuiteMask = &h00000200 Then
		          ret = "Windows XP Home Edition"
		        Else
		          ret = "Windows XP Professional Edition"
		        End If
		      End Select
		      
		    Case 4
		      If info.MinorVersion = 0 Then
		        ret = "Windows 95 or Windows NT 4.0"
		      ElseIf info.MinorVersion = 10 Then
		        ret = "Windows 98"
		      ElseIf info.MinorVersion = 90 Then
		        ret = "Windows ME"
		      End If
		    Else
		      ret = "Unknown Windows"
		    End Select
		    
		    Select Case CPUArchitecture
		    Case PROCESSOR_ARCHITECTURE_AMD64
		      ret = ret + " x64"
		    Case PROCESSOR_ARCHITECTURE_IA64
		      ret = ret + " Itanium"
		    Case PROCESSOR_ARCHITECTURE_INTEL
		      ret = ret + " x86"
		    Else
		      ret = ret + " Unknown CPU Architecture"
		    End Select
		    
		    
		    ret = ret + " " + info.ServicePackName
		    Return ret
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function VolumeInfo(volume As FolderItem) As Dictionary
		  //Given a FolderItem, returns a Dictionary containing the properties of the containing volume. On error, returns Nil.
		  
		  Declare Function GetVolumeInformationW Lib "Kernel32" (path As WString, volumeName As Ptr, volnameSize As Integer, _
		  volumeSerialNumber As Ptr, ByRef maximumNameLength As Integer, ByRef FSFlags As Integer, filesystem As Ptr, fsNameSize As Integer) As Boolean
		  
		  Dim volumeName As New MemoryBlock(255)
		  Dim fsName As New MemoryBlock(255)
		  Dim drive As String = NthField(volume.AbsolutePath, "\", 1) + "\"
		  Dim serialNumber As New MemoryBlock(255)
		  Dim maxLen, flags As Integer
		  
		  If GetVolumeInformationW(drive, volumeName, volumeName.Size, serialNumber, maxLen, flags, fsName, fsName.Size) Then
		    Dim ret As New Dictionary
		    ret.Value("Filesystem") = fsName.WString(0)
		    ret.Value("Label") = volumeName.WString(0)
		    ret.Value("MaxNameLen") = maxLen
		    ret.Value("Root") = drive
		    ret.Value("Flags") = flags
		    ret.Value("StreamSupport") = BitwiseAnd(flags, &h00040000) = &h00040000
		    ret.Value("ReadOnly") = BitwiseAnd(flags, &h00080000) = &h00080000
		    ret.Value("EFSSupport") = BitwiseAnd(flags, &h00020000) = &h00020000
		    ret.Value("HardLinkSupport") = BitwiseAnd(flags, &h00400000) = &h00400000
		    ret.Value("ReparsePointSupport") = BitwiseAnd(flags, &h00000080) = &h00000080
		    Return ret
		  Else
		    Return Nil
		  End If
		End Function
	#tag EndMethod


	#tag Constant, Name = PROCESSOR_ARCHITECTURE_AMD64, Type = Double, Dynamic = False, Default = \"9", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = PROCESSOR_ARCHITECTURE_IA64, Type = Double, Dynamic = False, Default = \"6", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = PROCESSOR_ARCHITECTURE_INTEL, Type = Double, Dynamic = False, Default = \"0", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = PROCESSOR_ARCHITECTURE_UNKNOWN, Type = Double, Dynamic = False, Default = \"&hffff", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = Win2000, Type = Double, Dynamic = False, Default = \"5.0", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = Win7, Type = Double, Dynamic = False, Default = \"6.1", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = Win8, Type = Double, Dynamic = False, Default = \"6.2", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = WinVista, Type = Double, Dynamic = False, Default = \"6.0", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = WinXP, Type = Double, Dynamic = False, Default = \"5.1", Scope = Protected
	#tag EndConstant


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
