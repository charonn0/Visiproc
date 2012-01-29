#tag Module
Protected Module Win32Structs
	#tag Note, Name = Move Along
		
		Just various Structures needed for some API calls.
	#tag EndNote


	#tag Structure, Name = CONSOLE_CURSOR_INFO, Flags = &h0
		height As Integer
		visible As Boolean
	#tag EndStructure

	#tag Structure, Name = CONSOLE_SCREEN_BUFFER_INFO, Flags = &h0
		dwSize As COORD
		  CursorPosition As COORD
		  Attribute As UInt16
		  sdWindow As SMALL_RECT
		MaxWindowSize As COORD
	#tag EndStructure

	#tag Structure, Name = COORD, Flags = &h0
		X As UInt16
		Y As UInt16
	#tag EndStructure

	#tag Structure, Name = DRAWTEXTPARAMS, Flags = &h0
		sSize As UInt32
		  TabLen As Int32
		  LeftMargin As Int32
		  RightMargin As Int32
		UILengthDrawn As UInt32
	#tag EndStructure

	#tag Structure, Name = FILE_STREAM_INFO, Flags = &h0
		NextEntryOffset As Integer
		  SteamNameLength As Integer
		  StreamSize As UInt64
		  StreamAllocationSize As Uint64
		streamName As string*255
	#tag EndStructure

	#tag Structure, Name = GUID, Flags = &h0
		data1 As UInt32
		  data2 As Short
		  data3 As Short
		data4 As String*8
	#tag EndStructure

	#tag Structure, Name = IO_STATUS_BLOCK, Flags = &h0
		Status As Int32
		Info As Int32
	#tag EndStructure

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

	#tag Structure, Name = MEMORYSTATUSEX, Flags = &h0
		sSize As Integer
		  MemLoad As Integer
		  TotalPhysicalMemory As UInt64
		  AvailablePhysicalMemory As UInt64
		  TotalPageFile As UInt64
		  AvailablePageFile As UInt64
		  PerProcessAddressSpace As UInt64
		  CurrentProcessAvailableAddressSpace As UInt64
		reserved As UInt64
	#tag EndStructure

	#tag Structure, Name = OFSTRUCT, Flags = &h0
		cbytes As Byte
		  fFixedSize As Byte
		  nErrCode As Integer
		  res1 As Integer
		  res2 As Integer
		szPathName(128) As Byte
	#tag EndStructure

	#tag Structure, Name = OSVERSIONINFOEX, Flags = &h0
		StructSize As UInt32
		  MajorVersion As Integer
		  MinorVersion As Integer
		  BuildNumber As Integer
		  PlatformID As Integer
		  ServicePackName As String*128
		  ServicePackMajor As UInt16
		  ServicePackMinor As UInt16
		  SuiteMask As UInt16
		  ProductType As Byte
		Reserved As Byte
	#tag EndStructure

	#tag Structure, Name = PROCESS_INFORMATION, Flags = &h0
		Process As Integer
		  Thread As Integer
		  ProcessID As Integer
		ThreadID As Integer
	#tag EndStructure

	#tag Structure, Name = QOCINFO, Flags = &h0
		sSize As Integer
		  flags As Integer
		  inSpeed As Integer
		outSpeed As Integer
	#tag EndStructure

	#tag Structure, Name = RECT, Flags = &h0
		left As Integer
		  top As Integer
		  right As Integer
		bottom As Integer
	#tag EndStructure

	#tag Structure, Name = SECURITY_ATTRIBUTES, Flags = &h0
		Length As Integer
		  secDescriptor As Ptr
		InheritHandle As Boolean
	#tag EndStructure

	#tag Structure, Name = SMALL_RECT, Flags = &h0
		Left As UInt16
		  Top As UInt16
		  Right As UInt16
		Bottom As UInt16
	#tag EndStructure

	#tag Structure, Name = SP_DEVINFO_DATA, Flags = &h0
		cbSize As Integer
		  UUID As String*16
		  DevList As Integer
		reserved As Integer
	#tag EndStructure

	#tag Structure, Name = STARTUPINFO, Flags = &h0
		sSize As Integer
		  Reserved1 As Ptr
		  Desktop As Ptr
		  Title As Ptr
		  WM_X As Integer
		  WM_Y As Integer
		  WM_Width As Integer
		  WM_Height As Integer
		  CON_Buffer_Width As Integer
		  CON_Buffer_Height As Integer
		  CON_FillAttribute As Integer
		  Flags As Integer
		  ShowWindow As UInt16
		  Reserved2 As UInt16
		  Reserved3 As Byte
		  StdInput As Integer
		  StdOutput As Integer
		StdError As Integer
	#tag EndStructure

	#tag Structure, Name = SYSTEMTIME, Flags = &h0
		Year As UInt16
		  Month As UInt16
		  DOW As UInt16
		  Day As UInt16
		  Hour As UInt16
		  Minute As UInt16
		  Second As UInt16
		MS As UInt16
	#tag EndStructure

	#tag Structure, Name = SYSTEM_INFO, Flags = &h0
		OEMID As Integer
		  pageSize As Integer
		  minApplicationAddress As Ptr
		  maxApplicationAddress As Ptr
		  activeProcessorMask As Integer
		  numberOfProcessors As Integer
		  processorType As Integer
		  allocationGranularity As Integer
		  processorLevel As Int16
		processorRevision As Int16
	#tag EndStructure

	#tag Structure, Name = SYSTEM_INFO_EX, Flags = &h0
		StructSize As Integer
		  MajorVersion As Integer
		  MinorVersion As Integer
		  buildNumber As Integer
		  platformID As Integer
		  serivePackString As String*256
		  servicePackMajor As Int16
		  servicePackMinor As Int16
		  suiteMask As Int16
		  productType As Byte
		reserved As Byte
	#tag EndStructure

	#tag Structure, Name = TIME_ZONE_INFORMATION, Flags = &h0
		Bias As Integer
		  StandardName As Wstring*32
		  StandardDate As SYSTEMTIME
		  StandardBias As Integer
		  DaylightName As WString*32
		  DaylightDate As SYSTEMTIME
		DaylightBias As Integer
	#tag EndStructure

	#tag Structure, Name = VS_FIXEDFILEINFO, Flags = &h0
		Signature As Integer
		  StrucVersion As Integer
		  FileVersionMS As Integer
		  FileVersionLS As Integer
		  FileFlagMasks As Integer
		  FileFlags As Integer
		  FileOS As Integer
		  FileType As Integer
		  FileSubType As Integer
		  FileDateMS As Integer
		FileDateLS As Integer
	#tag EndStructure

	#tag Structure, Name = WIN32_FIND_STREAM_DATA, Flags = &h0
		StreamSize As Int64
		StreamName As String*1024
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
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			InheritedFrom="Object"
		#tag EndViewProperty
	#tag EndViewBehavior
End Module
#tag EndModule
