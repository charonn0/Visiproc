#tag Module
Protected Module Win32Constants
	#tag ExternalMethod, Flags = &h0
		Soft Declare Function GetVersionEx Lib "Kernel32" Alias "GetVersionExW" (ByRef info As OSVERSIONINFOEX) As Boolean
	#tag EndExternalMethod


	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  #If TargetWin32 Then
			    Dim info As OSVERSIONINFOEX
			    info.StructSize = Info.Size
			    
			    Call GetVersionEx(info)
			    If info.MajorVersion >= 6 Then
			      Return &h1000  //PROCESS_QUERY_LIMITED_INFORMATION
			    Else
			      Return &h400  //PROCESS_QUERY_INFORMATION
			    End If
			  #endif
			End Get
		#tag EndGetter
		PROCESS_QUERY_INFORMATION As Integer
	#tag EndComputedProperty


	#tag Constant, Name = BLACKNESS, Type = Double, Dynamic = False, Default = \"&h00000042", Scope = Public
	#tag EndConstant

	#tag Constant, Name = BusATA, Type = Double, Dynamic = False, Default = \"&h3", Scope = Public
	#tag EndConstant

	#tag Constant, Name = BusATAPI, Type = Double, Dynamic = False, Default = \"&h2", Scope = Public
	#tag EndConstant

	#tag Constant, Name = BusFibre, Type = Double, Dynamic = False, Default = \"&h6", Scope = Public
	#tag EndConstant

	#tag Constant, Name = BusFileBackedVirtual, Type = Double, Dynamic = False, Default = \"&hF", Scope = Public
	#tag EndConstant

	#tag Constant, Name = BusFirewire, Type = Double, Dynamic = False, Default = \"&h4", Scope = Public
	#tag EndConstant

	#tag Constant, Name = BusiSCSI, Type = Double, Dynamic = False, Default = \"&h9", Scope = Public
	#tag EndConstant

	#tag Constant, Name = BusMax, Type = Double, Dynamic = False, Default = \"&h10", Scope = Public
	#tag EndConstant

	#tag Constant, Name = BusMaxReserved, Type = Double, Dynamic = False, Default = \"&h7F", Scope = Public
	#tag EndConstant

	#tag Constant, Name = BusMMC, Type = Double, Dynamic = False, Default = \"&hD", Scope = Public
	#tag EndConstant

	#tag Constant, Name = BusRAID, Type = Double, Dynamic = False, Default = \"&h8", Scope = Public
	#tag EndConstant

	#tag Constant, Name = BusSAS, Type = Double, Dynamic = False, Default = \"&hA", Scope = Public
	#tag EndConstant

	#tag Constant, Name = BusSATA, Type = Double, Dynamic = False, Default = \"&hB", Scope = Public
	#tag EndConstant

	#tag Constant, Name = BusSCSI, Type = Double, Dynamic = False, Default = \"&h1", Scope = Public
	#tag EndConstant

	#tag Constant, Name = BusSD, Type = Double, Dynamic = False, Default = \"&hC", Scope = Public
	#tag EndConstant

	#tag Constant, Name = BusSSA, Type = Double, Dynamic = False, Default = \"&h5", Scope = Public
	#tag EndConstant

	#tag Constant, Name = BusUnknown, Type = Double, Dynamic = False, Default = \"&h0", Scope = Public
	#tag EndConstant

	#tag Constant, Name = BusUSB, Type = Double, Dynamic = False, Default = \"&h7", Scope = Public
	#tag EndConstant

	#tag Constant, Name = BusVirtual, Type = Double, Dynamic = False, Default = \"&hE", Scope = Public
	#tag EndConstant

	#tag Constant, Name = CAPTUREBLT, Type = Double, Dynamic = False, Default = \"&h40000000\r", Scope = Public
	#tag EndConstant

	#tag Constant, Name = DSTINVERT, Type = Double, Dynamic = False, Default = \"&h00550009", Scope = Public
	#tag EndConstant

	#tag Constant, Name = IDABORT, Type = Double, Dynamic = False, Default = \"3", Scope = Public
	#tag EndConstant

	#tag Constant, Name = IDCANCEL, Type = Double, Dynamic = False, Default = \"2", Scope = Public
	#tag EndConstant

	#tag Constant, Name = IDCONTINUE, Type = Double, Dynamic = False, Default = \"11", Scope = Public
	#tag EndConstant

	#tag Constant, Name = IDIGNORE, Type = Double, Dynamic = False, Default = \"5", Scope = Public
	#tag EndConstant

	#tag Constant, Name = IDNO, Type = Double, Dynamic = False, Default = \"7", Scope = Public
	#tag EndConstant

	#tag Constant, Name = IDOK, Type = Double, Dynamic = False, Default = \"1", Scope = Public
	#tag EndConstant

	#tag Constant, Name = IDRETRY, Type = Double, Dynamic = False, Default = \"4", Scope = Public
	#tag EndConstant

	#tag Constant, Name = IDTRYAGAIN, Type = Double, Dynamic = False, Default = \"10", Scope = Public
	#tag EndConstant

	#tag Constant, Name = IDYES, Type = Double, Dynamic = False, Default = \"6", Scope = Public
	#tag EndConstant

	#tag Constant, Name = MB_ABORTRETRYIGNORE, Type = Double, Dynamic = False, Default = \"&h00000002", Scope = Public
	#tag EndConstant

	#tag Constant, Name = MB_APPLMODAL, Type = Double, Dynamic = False, Default = \"&h00000000", Scope = Public
	#tag EndConstant

	#tag Constant, Name = MB_CANCELTRYCONTINUE, Type = Double, Dynamic = False, Default = \"&h00000006", Scope = Public
	#tag EndConstant

	#tag Constant, Name = MB_DEFAULT_DESKTOP_ONLY, Type = Double, Dynamic = False, Default = \"&h00020000", Scope = Public
	#tag EndConstant

	#tag Constant, Name = MB_DEFBUTTON1, Type = Double, Dynamic = False, Default = \"&h00000000", Scope = Public
	#tag EndConstant

	#tag Constant, Name = MB_DEFBUTTON2, Type = Double, Dynamic = False, Default = \"&h00000100", Scope = Public
	#tag EndConstant

	#tag Constant, Name = MB_DEFBUTTON3, Type = Double, Dynamic = False, Default = \"&h00000200", Scope = Public
	#tag EndConstant

	#tag Constant, Name = MB_DEFBUTTON4, Type = Double, Dynamic = False, Default = \"&h00000300", Scope = Public
	#tag EndConstant

	#tag Constant, Name = MB_HELP, Type = Double, Dynamic = False, Default = \"&h00004000", Scope = Public
	#tag EndConstant

	#tag Constant, Name = MB_ICONASTERISK, Type = Double, Dynamic = False, Default = \"&h00000040", Scope = Public
	#tag EndConstant

	#tag Constant, Name = MB_ICONERROR, Type = Double, Dynamic = False, Default = \"&h00000010", Scope = Public
	#tag EndConstant

	#tag Constant, Name = MB_ICONEXCLAMATION, Type = Double, Dynamic = False, Default = \"&h00000030", Scope = Public
	#tag EndConstant

	#tag Constant, Name = MB_ICONHAND, Type = Double, Dynamic = False, Default = \"&h00000010", Scope = Public
	#tag EndConstant

	#tag Constant, Name = MB_ICONINFORMATION, Type = Double, Dynamic = False, Default = \"&h00000040", Scope = Public
	#tag EndConstant

	#tag Constant, Name = MB_ICONQUESTION, Type = Double, Dynamic = False, Default = \"&h00000020", Scope = Public
	#tag EndConstant

	#tag Constant, Name = MB_ICONSTOP, Type = Double, Dynamic = False, Default = \"&h00000010", Scope = Public
	#tag EndConstant

	#tag Constant, Name = MB_ICONWARNING, Type = Double, Dynamic = False, Default = \"&h00000030", Scope = Public
	#tag EndConstant

	#tag Constant, Name = MB_OK, Type = Double, Dynamic = False, Default = \"&h00000000", Scope = Public
	#tag EndConstant

	#tag Constant, Name = MB_OKCANCEL, Type = Double, Dynamic = False, Default = \"&h00000001", Scope = Public
	#tag EndConstant

	#tag Constant, Name = MB_RETRYCANCEL, Type = Double, Dynamic = False, Default = \"&h00000005", Scope = Public
	#tag EndConstant

	#tag Constant, Name = MB_RIGHT, Type = Double, Dynamic = False, Default = \"&h00080000", Scope = Public
	#tag EndConstant

	#tag Constant, Name = MB_RTLREADING, Type = Double, Dynamic = False, Default = \"&h00100000", Scope = Public
	#tag EndConstant

	#tag Constant, Name = MB_SERVICE_NOTIFICATION, Type = Double, Dynamic = False, Default = \"&h00200000", Scope = Public
	#tag EndConstant

	#tag Constant, Name = MB_SETFOREGROUND, Type = Double, Dynamic = False, Default = \"&h00010000", Scope = Public
	#tag EndConstant

	#tag Constant, Name = MB_SYSTEMMODAL, Type = Double, Dynamic = False, Default = \"&h00001000", Scope = Public
	#tag EndConstant

	#tag Constant, Name = MB_TASKMODAL, Type = Double, Dynamic = False, Default = \"&h00002000", Scope = Public
	#tag EndConstant

	#tag Constant, Name = MB_TOPMOST, Type = Double, Dynamic = False, Default = \"&h00040000", Scope = Public
	#tag EndConstant

	#tag Constant, Name = MB_YESNO, Type = Double, Dynamic = False, Default = \"&h00000004", Scope = Public
	#tag EndConstant

	#tag Constant, Name = MB_YESNOCANCEL, Type = Double, Dynamic = False, Default = \"&h00000003", Scope = Public
	#tag EndConstant

	#tag Constant, Name = MERGECOPY, Type = Double, Dynamic = False, Default = \"&h00C000CA", Scope = Public
	#tag EndConstant

	#tag Constant, Name = MERGEPAINT, Type = Double, Dynamic = False, Default = \"&h00BB0226", Scope = Public
	#tag EndConstant

	#tag Constant, Name = NOTSRCCOPY, Type = Double, Dynamic = False, Default = \"&h00330008", Scope = Public
	#tag EndConstant

	#tag Constant, Name = NOTSRCERASE, Type = Double, Dynamic = False, Default = \"&h001100A6", Scope = Public
	#tag EndConstant

	#tag Constant, Name = PATCOPY, Type = Double, Dynamic = False, Default = \"&h00F00021", Scope = Public
	#tag EndConstant

	#tag Constant, Name = PATINVERT, Type = Double, Dynamic = False, Default = \"&h005A0049", Scope = Public
	#tag EndConstant

	#tag Constant, Name = PATPAINT, Type = Double, Dynamic = False, Default = \"&h00FB0A09", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SE_ASSIGNPRIMARYTOKEN_NAME, Type = String, Dynamic = False, Default = \"SeAssignPrimaryTokenPrivilege", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SE_AUDIT_NAME, Type = String, Dynamic = False, Default = \"SeAuditPrivilege", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SE_BACKUP_NAME, Type = String, Dynamic = False, Default = \"SeBackupPrivilege", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SE_CHANGE_NOTIFY_NAME, Type = String, Dynamic = False, Default = \"SeChangeNotifyPrivilege", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SE_CREATE_GLOBAL_PRIVILEGE_NAME, Type = String, Dynamic = False, Default = \"SeCreateGlobalPrivilege", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SE_CREATE_PAGEFILE_NAME, Type = String, Dynamic = False, Default = \"SeCreatePagefilePrivilege", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SE_CREATE_PERMANENT_NAME, Type = String, Dynamic = False, Default = \"SeCreatePermanentPrivilege", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SE_CREATE_SYMBOLIC_LINK_NAME, Type = String, Dynamic = False, Default = \"SeCreateSymbolicLinkPrivilege", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SE_CREATE_TOKEN_NAME, Type = String, Dynamic = False, Default = \"SeCreateTokenPrivilege", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SE_DEBUG_PRIVILEGE, Type = String, Dynamic = False, Default = \"SeDebugPrivilege", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SE_ENABLE_DELEGATAION_NAME, Type = String, Dynamic = False, Default = \"SeEnableDelegationPrivilege", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SE_IMPERSONATE_NAME, Type = String, Dynamic = False, Default = \"SeImpersonatePrivilege", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SE_INCREASE_QUOTA_NAME, Type = String, Dynamic = False, Default = \"SeIncreaseQuotaPrivilege", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SE_INC_BASE_PRIORITY_NAME, Type = String, Dynamic = False, Default = \"SeIncreaseBasePriorityPrivilege", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SE_INC_WORKING_SET_NAME, Type = String, Dynamic = False, Default = \"SeIncreaseWorkingSetPrivilege", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SE_LOAD_DRIVER_NAME, Type = String, Dynamic = False, Default = \"SeLoadDriverPrivilege", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SE_LOCK_MEMORY_NAME, Type = String, Dynamic = False, Default = \"SeLockMemoryPrivilege", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SE_MACHINE_ACCOUNT_NAME, Type = String, Dynamic = False, Default = \"SeMachineAccountPrivilege", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SE_MANAGE_VOLUME_NAME, Type = String, Dynamic = False, Default = \"SeManageVolumePrivilege", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SE_PROF_SINGLE_PROCESS_NAME, Type = String, Dynamic = False, Default = \"SeProfileSingleProcessPrivilege", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SE_RELABLE_NAME, Type = String, Dynamic = False, Default = \"SeRelabelPrivilege", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SE_REMOTE_SHUTDOWN_NAME, Type = String, Dynamic = False, Default = \"SeRemoteShutdownPrivilege", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SE_RESTORE_NAME, Type = String, Dynamic = False, Default = \"SeRestorePrivilege", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SE_SECURITY_NAME, Type = String, Dynamic = False, Default = \"SeSecurityPrivilege", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SE_SHUTDOWN_NAME, Type = String, Dynamic = False, Default = \"SeShutdownPrivilege", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SE_SYNC_AGENT_NAME, Type = String, Dynamic = False, Default = \"SeSyncAgentPrivilege", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SE_SYSTEMTIME_NAME, Type = String, Dynamic = False, Default = \"SeSystemtimePrivilege", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SE_SYSTEM_ENVIRONMENT_NAME, Type = String, Dynamic = False, Default = \"SeSystemEnvironmentPrivilege", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SE_SYSTEM_PROFILE_NAME, Type = String, Dynamic = False, Default = \"SeSystemProfilePrivilege", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SE_TAKE_OWNERSHIP_NAME, Type = String, Dynamic = False, Default = \"SeTakeOwnershipPrivilege", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SE_TCB_NAME, Type = String, Dynamic = False, Default = \"SeTcbPrivilege", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SE_TIME_ZONE_NAME, Type = String, Dynamic = False, Default = \"SeTimeZonePrivilege", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SE_TRUSTED_CREDMAN_ACCESS_NAME, Type = String, Dynamic = False, Default = \"SeTrustedCredManAccessPrivilege", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SE_UNDOCK_NAME, Type = String, Dynamic = False, Default = \"SeUndockPrivilege", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SE_UNSOLICITED_INPUT_NAME, Type = String, Dynamic = False, Default = \"SeUnsolicitedInputPrivilege", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SRCAND, Type = Double, Dynamic = False, Default = \"&h008800C6", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SRCCOPY, Type = Double, Dynamic = False, Default = \"&h00CC0020", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SRCCOPY1, Type = Double, Dynamic = False, Default = \"&h00CC0020", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SRCERASE, Type = Double, Dynamic = False, Default = \"&h00440328", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SRCINVERT, Type = Double, Dynamic = False, Default = \"&h00660046", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SRCPAINT, Type = Double, Dynamic = False, Default = \"&h00EE0086", Scope = Public
	#tag EndConstant

	#tag Constant, Name = WHITENESS, Type = Double, Dynamic = False, Default = \"&h00FF0062", Scope = Public
	#tag EndConstant


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


	#tag Enum, Name = TOKEN_INFORMATION_CLASS, Type = Integer, Flags = &h0
		TokenUser
		  TokenGroups
		  TokenPrivileges
		  TokenOwner
		  TokenPrimaryGroup
		  TokenDefaultDacl
		  TokenSource
		  TokenType
		  TokenImpersonationLevel
		  TokenStatistics
		  TokenRestrictedSids
		  TokenSessionId
		  TokenGroupsAndPrivileges
		  TokenSessionReference
		  TokenSandboxInert
		  TokenAuditPolicy
		  TokenOrigin
		  TokenElevationType
		  TokenLinkedToken
		  TokenElevation
		  TokenHasRestrictions
		  TokenAccessInformation
		  TokenVirtualizationAllowed
		  TokenVirtualizationEnabled
		  TokenIntegrityLevel
		  TokenUIAccess
		  TokenMandatoryPolicy
		  TokenLogonSid
		  TokenIsAppContainer
		  TokenCapabilities
		  TokenAppContainerSid
		  TokenAppContainerNumber
		  TokenUserClaimAttributes
		  TokenDeviceClaimAttributes
		  TokenRestrictedUserClaimAttributes
		  TokenRestrictedDeviceClaimAttributes
		  TokenDeviceGroups
		  TokenRestrictedDeviceGroups
		  TokenSecurityAttributes
		  TokenIsRestricted
		MaxTokenInfoClass
	#tag EndEnum


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
			Name="PROCESS_QUERY_INFORMATION"
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
