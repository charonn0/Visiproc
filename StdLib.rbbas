#tag Module
Protected Module StdLib
	#tag Method, Flags = &h0
		Function CaptureScreen() As Picture
		  //Calls GetPartialScreenShot with a rectangle comprising all of the main screen (screen 0). Returns a Picture
		   
		  Declare Function GetSystemMetrics Lib "User32"  (nIndex As Integer) As integer
		  Return GetPartialScreenShot(0, GetSystemMetrics(0), 0, GetSystemMetrics(1))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub CloseDrive(Extends f As FolderItem)
		  //Given a FolderItem, this function commands the drive containing the FolderItem to close. If the drive is not an ejectable drive, or if
		  //the drive is already closed then this does nothing
		  
		  Declare Function CreateFileW Lib "Kernel32"(name As WString, access As Integer, sharemode As Integer, SecAtrribs As Integer, CreateDisp As Integer, _
		  flags As Integer, template As Integer) As Integer
		  Declare Function GetVolumeNameForVolumeMountPointW Lib "Kernel32" (mountPoint As WString, volumeName As Ptr, bufferSize As Integer) As Boolean
		  Declare Function CloseHandle Lib "Kernel32"(HWND As Integer) As Boolean
		  Declare Function DeviceIoControl Lib "kernel32"(hDevice As Integer, dwIoControlCode As Integer, lpInBuffer As Ptr, _
		  nInBufferSize As Integer, lpOutBuffer As Ptr, nOutBufferSize As Integer, lpBytesReturned As Ptr, lpOverlapped As Integer) As Integer
		  
		  Const GENERIC_READ = &h80000000
		  Const OPEN_EXISTING = 0
		  Const FILE_SHARE_READ = &h00000001
		  Const FILE_READ_ACCESS = &h0001
		  Const FILE_SHARE_WRITE = &h2
		  Const IOCTL_STORAGE_BASE = &h0000002d
		  Const METHOD_BUFFERED = 0
		  
		  Dim dhandle As Integer
		  Dim mb As New MemoryBlock(55)
		  Dim nilBuffer As New MemoryBlock(0)
		  
		  If GetVolumeNameForVolumeMountPointW(f.AbsolutePath, mb, mb.Size) Then
		    Dim drvRoot As String = "\\.\" + mb.StringValue(0, 55)
		    dhandle = CreateFileW(drvRoot, GENERIC_READ, FILE_SHARE_READ Or FILE_SHARE_WRITE, 0, OPEN_EXISTING, 0, 0)
		  Else
		    Return
		  End If
		  
		  Dim IOCTL_STORAGE_LOAD_MEDIA As Integer = Platform.CTL_CODE(IOCTL_STORAGE_BASE, &h0203, METHOD_BUFFERED, FILE_READ_ACCESS)
		  Call DeviceIoControl(dhandle, IOCTL_STORAGE_LOAD_MEDIA, nilBuffer, 0, nilBuffer, 0, nilBuffer, 0)
		  Call CloseHandle(dhandle)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function DetectEncoding(s As String) As Integer
		  //Very naive, detects ASCII or Unicode
		  
		  Const ASCII = 0
		  Const Unicode = 1
		  
		  If MidB(s, 2, 1) = Chr(0) And MidB(s, 4, 1) = Chr(0) Then
		    Return Unicode
		  Else
		    Return ASCII
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function DriveType(target As FolderItem) As Integer
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
		  
		  Dim drvRoot As String = "\\.\" + Left(target.AbsolutePath, 2)
		  Dim drvHWND As Integer = CreateFileW(drvRoot, GENERIC_READ, FILE_SHARE_READ Or FILE_SHARE_WRITE, 0, OPEN_EXISTING, 0, 0)
		  Dim mb As New MemoryBlock(34)
		  Dim bRet As New MemoryBlock(4)
		  
		  If DeviceIoControl(drvHWND, IO_CODE, mb, mb.Size, mb, mb.Size, bRet, 0) <> 0 Then
		    Return mb.Byte(8)
		  Else
		    Return BusUnknown
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub EjectDrive(Extends f As FolderItem)
		  //Given a FolderItem, this function commands the drive containing the FolderItem to eject. If the drive is not an ejectable drive
		  //then this does nothing
		  Declare Function CreateFileW Lib "Kernel32"(name As WString, access As Integer, sharemode As Integer, SecAtrribs As Integer, CreateDisp As Integer, _
		  flags As Integer, template As Integer) As Integer
		  Declare Function GetVolumeNameForVolumeMountPointW Lib "Kernel32" (mountPoint As WString, volumeName As Ptr, bufferSize As Integer) As Boolean
		  Declare Function CloseHandle Lib "Kernel32"(HWND As Integer) As Boolean
		  Declare Function DeviceIoControl Lib "kernel32"(hDevice As Integer, dwIoControlCode As Integer, lpInBuffer As Ptr, _
		  nInBufferSize As Integer, lpOutBuffer As Ptr, nOutBufferSize As Integer, lpBytesReturned As Ptr, lpOverlapped As Integer) As Integer
		  
		  Const GENERIC_READ = &h80000000
		  Const OPEN_EXISTING = 0
		  Const FILE_SHARE_READ = &h00000001
		  Const FILE_READ_ACCESS = &h0001
		  Const FILE_SHARE_WRITE = &h2
		  Const IOCTL_STORAGE_BASE = &h0000002d
		  Const METHOD_BUFFERED = 0
		  
		  Dim dhandle As Integer
		  Dim mb As New MemoryBlock(55)
		  Dim nilBuffer As New MemoryBlock(0)
		  
		  If GetVolumeNameForVolumeMountPointW(f.AbsolutePath, mb, mb.Size) Then
		    Dim drvRoot As String = "\\.\" + mb.StringValue(0, 55)
		    dhandle = CreateFileW(drvRoot, GENERIC_READ, FILE_SHARE_READ Or FILE_SHARE_WRITE, 0, OPEN_EXISTING, 0, 0)
		  Else
		    Return
		  End If
		  
		  Dim IOCTL_STORAGE_EJECT_MEDIA As Integer = Platform.CTL_CODE(IOCTL_STORAGE_BASE, &h0202, METHOD_BUFFERED, FILE_READ_ACCESS)
		  Call DeviceIoControl(dhandle, IOCTL_STORAGE_EJECT_MEDIA, nilBuffer, 0, nilBuffer, 0, nilBuffer, 0)
		  Call CloseHandle(dhandle)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FileFromProcessID(processID As Integer) As FolderItem
		  //Given a processID number of an active process, tries to resolve the executable file for the program. Raises an exception with 
		  //ErrorNumber = LastWin32Error if it cannot resolve the file. Most likely this would be due to insufficient access rights
		  
		  Declare Function GetModuleFileNameExW Lib "psapi.dll" (ByVal hProcess As Integer, ByVal hModule As Integer, ModuleName As Ptr, ByVal nSize _
		  As Integer) As Integer
		  Declare Function OpenProcess Lib "Kernel32.dll" (ByVal dwDesiredAccessAs As Integer, ByVal bInheritHandle As Integer, ByVal dwProcId As Integer) As Integer
		  Declare Function CloseHandle Lib "Kernel32.dll" (ByVal Handle As Integer) As Integer
		  
		  Const PROCESS_QUERY_INFORMATION = &h400
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
		Function GetPartialScreenShot(left As Integer, right As Integer, top As Integer, bottom As Integer) As Picture
		  //Returns a Picture of the rectangle defined from current desktop.
		  //Rectangle coordinates are relative to the upper left corner of the user's leftmost screen, in pixels
		  
		  Declare Function GetDesktopWindow Lib "User32" () As Integer
		  Declare Function GetDC Lib "User32" (HWND As Integer) As Integer
		  Declare Function BitBlt Lib "GDI32" (DCdest As Integer, xDest As Integer, yDest As Integer, nWidth As Integer, nHeight As Integer, _
		  DCdource As Integer, xSource As Integer, ySource As Integer, rasterOp As Integer) As Boolean
		  Declare Function ReleaseDC Lib "User32" (HWND As Integer, DC As Integer) As Integer
		  
		  Const CAPTUREBLT = &h40000000
		  Const SRCCOPY = &hCC0020
		  
		  Dim screenWidth, screenHeight As Integer
		  screenWidth = right - left
		  screenHeight = bottom - top
		  Dim screenCap As New Picture(screenWidth, screenHeight, 24)
		  Dim deskHWND As Integer = GetDesktopWindow()
		  Dim deskHDC As Integer = GetDC(deskHWND)
		  Call BitBlt(screenCap.Graphics.Handle(Graphics.HandleTypeHDC), 0, 0, ScreenWidth, ScreenHeight, DeskHDC, left, top, SRCCOPY Or CAPTUREBLT)
		  Call ReleaseDC(DeskHWND, deskHDC)
		  
		  Return screenCap
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IntToColor(extends c as Integer) As Color
		  //From WFS, converts an Integer to a Color
		  Dim mb as new MemoryBlock(4)
		  mb.Long(0) = c
		  Return RGB(mb.Byte(0), mb.Byte(1), mb.Byte(2))
		End Function
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
		Function prettifyBytes(bytes As UInt64) As String
		  //Converts raw byte amounts into SI formatted strings. 1KB = 1024 bytes
		  
		  Dim prettyString As String
		  Dim prettyDouble As Double
		  
		  If bytes <= 512000 Then
		    prettyDouble = bytes / 1024
		    prettyString = "KB"
		  ElseIf bytes > 512000 And bytes < 786432000 Then  //786432000 bytes = 750 MB
		    prettyDouble = bytes / 1048576
		    prettyString = "MB"
		  ElseIf bytes >= 786432000 And bytes < 824633720832 Then
		    prettyDouble = bytes / 1073741824
		    prettyString = "GB"
		  ElseIf bytes > 824633720832 Then
		    prettyDouble = bytes / 1099511627776
		    prettyString = "TB"
		  End If
		  
		  Return Format(prettyDouble, "#,###0.##") + prettyString
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function prettifyPath(path As String, maxLength As Integer = 45) As String
		  //Trims characters from the middle of a string until path.Len is less than the specified length.
		  //Useful for showing long paths by omitting the middle part of the path, though not limited to this use.
		  
		  If path.Len <= maxLength then
		    Return path
		  Else
		    Dim shortPath, snip As String
		    Dim start As Integer
		    shortPath = path
		    
		    While shortPath.len > maxLength
		      start = shortPath.Len / 3
		      snip = mid(shortPath, start, 5)
		      shortPath = Replace(shortPath, snip, "...")
		    Wend
		    Return shortPath
		  End If
		  
		Exception err
		  Return path
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


	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  //From the WFS. Gets the current volume level (0-65535). Note: on Vista and newer, this method is deprecated and may not
			  //work at all if the sound card implements Protected Path.
			  
			  If Platform.IsAtLeast(Platform.WinVista) Then Return 0   //Vista and newer MAY work, but often not.
			  
			  Declare Function mixerOpen Lib "winmm" ( ByRef handle As Integer, id As Integer, _
			  callback As Integer, instance As Integer, open As Integer ) As Integer
			  Declare Function mixerGetNumDevs Lib "winmm" () As Integer
			  Declare Function mixerGetControlDetailsA Lib "winmm" ( handle As Integer, details As Ptr, flags As Integer ) As Integer
			  Declare Sub mixerGetLineInfoA Lib "winmm" ( handle As Integer, line As Ptr, flags As Integer )
			  Declare Sub mixerGetLineControlsA Lib "winmm" ( handle As Integer, lineCtl As Ptr, flags As Integer )
			  
			  Dim i, count As Integer
			  count = mixerGetNumDevs - 1
			  
			  Dim device As Integer
			  for i = 0 to count
			    if mixerOpen( device, i, 0, 0, 0 ) = 0 then
			      exit
			    end
			  next
			  
			  Dim lineThinger As new MemoryBlock( 80 + 40 + 32 + 16 )
			  lineThinger.Long( 0 ) = lineThinger.Size
			  lineThinger.Long( 24 ) = 4
			  mixerGetLineInfoA( device, lineThinger, 3 )
			  Dim otherLineThinger As new MemoryBlock( 24 )
			  Dim mixerControl As new MemoryBlock( 80 + (18 * 4))
			  otherLineThinger.Long( 0 ) = otherLineThinger.Size
			  otherLineThinger.Long( 4 ) = lineThinger.Long( 12 )
			  otherLineThinger.Long( 8 ) = &h50000000 + &h30000 + 1
			  otherLineThinger.Long( 12 ) = 1
			  otherLineThinger.Long( 16 ) = mixerControl.Size
			  otherLineThinger.Ptr( 20 ) = mixerControl
			  mixerGetLineControlsA( device, otherLineThinger, 2 )
			  
			  Dim details As new MemoryBlock( 24 )
			  Dim vals As new MemoryBlock( 4 )
			  
			  details.Long( 0 ) = details.Size
			  details.Long( 4 ) = mixerControl.Long( 4 )
			  details.Long( 8 ) = 1
			  details.Long( 16 ) = 4
			  details.Ptr( 20 ) = vals
			  
			  If mixerGetControlDetailsA( device, details, 0 ) <> 0 Then
			    //Couldn't read the volume
			  End If
			  
			  return vals.Long( 0 )
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  //From the WFS. Sets the current volume level (0-65535). Note: on Vista and newer, this method is deprecated and may not
			  //work at all if the sound card implements Protected Path.
			  
			  If Platform.IsAtLeast(Platform.WinVista) Then Return   //Vista and newer MAY work, but often not.
			  
			  Declare Function mixerOpen Lib "winmm" ( ByRef handle As Integer, id As Integer, _
			  callback As Integer, instance As Integer, open As Integer ) As Integer
			  Declare Function mixerGetNumDevs Lib "winmm" () As Integer
			  Declare Function mixerSetControlDetails Lib "winmm" ( handle As Integer, details As Ptr, flags As Integer ) As Integer
			  Declare Sub mixerGetLineInfoA Lib "winmm" ( handle As Integer, line As Ptr, flags As Integer )
			  Declare Sub mixerGetLineControlsA Lib "winmm" ( handle As Integer, lineCtl As Ptr, flags As Integer )
			  
			  Dim i, count As Integer
			  count = mixerGetNumDevs - 1
			  
			  Dim device As Integer
			  for i = 0 to count
			    if mixerOpen( device, i, 0, 0, 0 ) = 0 then
			      exit
			    end
			  next
			  
			  ' Get the line information for the Speakers
			  Dim lineThinger As new MemoryBlock( 80 + 40 + 32 + 16 )
			  lineThinger.Long( 0 ) = lineThinger.Size
			  lineThinger.Long( 24 ) = 4
			  mixerGetLineInfoA( device, lineThinger, 3 )
			  
			  ' Get the volume control for the speakers
			  Dim otherLineThinger As new MemoryBlock( 24 )
			  Dim mixerControl As new MemoryBlock( 80 + (18 * 4))
			  otherLineThinger.Long( 0 ) = otherLineThinger.Size
			  otherLineThinger.Long( 4 ) = lineThinger.Long( 12 )
			  otherLineThinger.Long( 8 ) = &h50000000 + &h30000 + 1
			  otherLineThinger.Long( 12 ) = 1
			  otherLineThinger.Long( 16 ) = mixerControl.Size
			  otherLineThinger.Ptr( 20 ) = mixerControl
			  mixerGetLineControlsA( device, otherLineThinger, 2 )
			  
			  Dim details As new MemoryBlock( 24 )
			  Dim vals As new MemoryBlock( 4 )
			  vals.Long( 0 ) = value
			  
			  details.Long( 0 ) = details.Size
			  details.Long( 4 ) = mixerControl.Long( 4 )
			  details.Long( 8 ) = 1
			  details.Long( 16 ) = 4
			  details.Ptr( 20 ) = vals
			  
			  If mixerSetControlDetails( device, details, 0 ) <> 0 Then
			    //Couldn't set the volume
			  End If
			End Set
		#tag EndSetter
		SoundVolume As Integer
	#tag EndComputedProperty


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
			Name="SoundVolume"
			Group="Behavior"
			Type="Integer"
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
