#tag Module
Protected Module StdLib
	#tag Method, Flags = &h0
		Function DriveType(target As String) As Integer
		  //Returns an Integer corresponding to one of the Bus* constants (e.g. BusATA or BusUSB)
		  
		  Declare Function CreateFileW Lib "Kernel32"(name As WString, access As Integer, sharemode As Integer, SecAtrribs As Integer, CreateDisp As Integer, _
		  flags As Integer, template As Integer) As Integer
		  Declare Function DeviceIoControl Lib "kernel32"(hDevice As Integer, dwIoControlCode As Integer, lpInBuffer As Ptr, _
		  nInBufferSize As Integer, lpOutBuffer As Ptr, nOutBufferSize As Integer, lpBytesReturned As Ptr, lpOverlapped As Integer) As Integer
		  
		  Const GENERIC_READ = &h80000000
		  Const FILE_SHARE_READ = &h00000001
		  Const FILE_SHARE_WRITE = &h2
		  Const OPEN_EXISTING = 3
		  Const FILE_DEVICE_MASS_STORAGE = &h0000002d
		  Dim IO_CODE As Integer = Platform.CTL_CODE(FILE_DEVICE_MASS_STORAGE, &h0500, 0, 0)
		  
		  Dim drvRoot As String = "\\.\" + Left(target, 2)
		  
		  Dim drvHWND As Integer = CreateFileW(drvRoot, GENERIC_READ, FILE_SHARE_READ Or FILE_SHARE_WRITE, 0, OPEN_EXISTING, 0, 0)
		  Dim mb As New MemoryBlock(34)
		  Dim bRet As New MemoryBlock(4)
		  
		  If DeviceIoControl(drvHWND, IO_CODE, mb, mb.Size, mb, mb.Size, bRet, 0) <> 0 Then
		    Return mb.Byte(28)
		  Else
		    Return BusUnknown
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FileFromProcessID(processID As Integer) As FolderItem
		  //Given a processID number of an active process, tries to resolve the executable file for the program. Raises an exception with
		  //ErrorNumber = LastWin32Error if it cannot resolve the file. Most likely this would be due to insufficient access rights
		  
		  Declare Function GetModuleFileNameExW Lib "psapi.dll" (ByVal hProcess As Integer, ByVal hModule As Integer, ModuleName As Ptr, ByVal nSize _
		  As Integer) As Integer
		  Declare Function OpenProcess Lib "Kernel32.dll" (ByVal dwDesiredAccessAs As Integer, ByVal bInheritHandle As Integer, ByVal dwProcId As Integer) As Integer
		  Declare Function CloseHandle Lib "Kernel32.dll" (ByVal Handle As Integer) As Integer
		  
		  
		  Const PROCESS_VM_READ = &h10
		  Dim Modules As New MemoryBlock(255)  // 255 = SIZE_MINIMUM * sizeof(HMODULE)
		  Dim ModuleName As New MemoryBlock(255)
		  Dim nSize As Integer
		  
		  
		  Dim hProcess As Integer = OpenProcess(PROCESS_QUERY_INFORMATION Or PROCESS_VM_READ, 0, processID)
		  Dim Result As String
		  If hProcess <> 0 Then
		    ModuleName = New MemoryBlock(255)
		    nSize = 255
		    Call GetModuleFileNameExW(hProcess, Modules.Int32Value(0), ModuleName, 255)
		    Result=Result+ModuleName.WString(0)
		  Else
		    hProcess = Platform.LastErrorCode
		    Dim err As New RuntimeException
		    err.Message = "Unable to resolve file for process ID " + Str(processID) + ": " + Platform.ErrorMessageFromCode(hProcess)
		    err.ErrorNumber = hProcess
		    Raise err
		  End If
		  Call CloseHandle(hProcess)
		  
		  Result = Replace(Result, "\??\", "")
		  Result = Replace(Result, "\SystemRoot\", SpecialFolder.Windows.AbsolutePath)
		  Dim ret As FolderItem
		  
		  If Result <> "" Then
		    ret = GetFolderItem(Result)
		  End If
		  Return ret
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FormatBytes(bytes As UInt64, precision As Integer = 2) As String
		  //Converts raw byte counts into SI formatted strings. 1KB = 1024 bytes.
		  //Optionally pass an integer representing the number of decimal places to return. The default is two decimal places. You may specify
		  //between 0 and 16 decimal places. Specifying more than 16 will append extra zeros to make up the length. Passing 0
		  //shows no decimal places and no decimal point.
		  
		  Const kilo = 1024
		  Static mega As UInt64 = kilo * kilo
		  Static giga As UInt64 = kilo * mega
		  Static tera As UInt64 = kilo * giga
		  Static peta As UInt64 = kilo * tera
		  Static exab As UInt64 = kilo * peta
		  
		  Dim suffix, precisionZeros As String
		  Dim strBytes As Double
		  
		  
		  If bytes < kilo Then
		    strbytes = bytes
		    suffix = "bytes"
		  ElseIf bytes >= kilo And bytes < mega Then
		    strbytes = bytes / kilo
		    suffix = "KB"
		  ElseIf bytes >= mega And bytes < giga Then
		    strbytes = bytes / mega
		    suffix = "MB"
		  ElseIf bytes >= giga And bytes < tera Then
		    strbytes = bytes / giga
		    suffix = "GB"
		  ElseIf bytes >= tera And bytes < peta Then
		    strbytes = bytes / tera
		    suffix = "TB"
		  ElseIf bytes >= tera And bytes < exab Then
		    strbytes = bytes / peta
		    suffix = "PB"
		  ElseIf bytes >= exab Then
		    strbytes = bytes / exab
		    suffix = "EB"
		  End If
		  
		  
		  While precisionZeros.Len < precision
		    precisionZeros = precisionZeros + "0"
		  Wend
		  If precisionZeros.Trim <> "" Then precisionZeros = "." + precisionZeros
		  
		  Return Format(strBytes, "#,###0" + precisionZeros) + " " + suffix
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Icon(extends w as Window, assigns newIcon as Picture)
		  // We want to set the new icon for this window
		  Const WM_SETICON = &h80
		  Const ICON_SMALL = 0
		  
		  Declare Function SendMessageW Lib "User32" ( hwnd as Integer, msg as Integer, wParam as Integer, lParam as Ptr ) As Integer
		  
		  //dim ret as Integer =
		  Call  SendMessageW(w.Handle, WM_SETICON, ICON_SMALL, newIcon.CopyOSHandle(Picture.HandleType.WindowsICON))
		  Return
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsSystemDrive(Extends f As FolderItem) As Boolean
		  //Returns True if the specified FolderItem (probably) resides on the System drive.
		  
		  Dim sysDrive As FolderItem = SpecialFolder.Windows.Parent  //Assumes that Windows is installed in a first-level directory
		  Dim drive As String = NthField(f.AbsolutePath, "\", 1) + "\"
		  
		  
		  If sysDrive.AbsolutePath = drive Then
		    Return True
		  Else
		    Return False
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function RegExFind(Extends source As String, pattern As String) As String()
		  //Returns a string array of all match subexpressions
		  
		  Dim rg as New RegEx
		  Dim myMatch as RegExMatch
		  Dim ret() As String
		  rg.SearchPattern = pattern
		  myMatch=rg.search(source)
		  If myMatch <> Nil Then
		    For i As Integer = 0 To myMatch.SubExpressionCount - 1
		      ret.Append(myMatch.SubExpressionString(i))
		    Next
		  End If
		  
		  Return ret
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Shorten(data As String, maxLength As Integer = 45) As String
		  //Replaces characters from the middle of a string with a single ellipsis ("...") until data.Len is less than the specified length.
		  //Useful for showing long paths by omitting the middle part of the data, though not limited to this use.
		  
		  If data.Len <= maxLength then
		    Return data
		  Else
		    Dim shortdata, snip As String
		    Dim start As Integer
		    shortdata = data
		    
		    While shortdata.len > maxLength
		      start = shortdata.Len / 3
		      snip = mid(shortdata, start, 5)
		      shortdata = Replace(shortdata, snip, "...")
		    Wend
		    Return shortdata
		  End If
		  
		Exception err
		  Return data
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StringToHex(src as string) As string
		  //Hexify a string of binary data, e.g. from RB's built-in MD5 function
		  
		  Dim hexvalue As Integer
		  Dim hexedInt As String
		  
		  For i As Integer = 1 To LenB(src)
		    hexvalue = AscB(MidB(src, i, 1))
		    hexedInt = hexedInt + RightB("00" + Hex(hexvalue), 2)
		  next
		  
		  Return LeftB(hexedInt, LenB(hexedInt))
		End Function
	#tag EndMethod


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
