#tag Class
Protected Class VolumeInformation
	#tag Method, Flags = &h0
		Sub Constructor(s As String)
		  Type = GetDriveType(s)
		  Select Case Me.Type
		  Case Fixed
		    Filesystem = GetDriveFileSystem(s)
		    FreeBytes = GetDriveFreeSize(s)
		    Totalbytes = GetDriveSize(s)
		    Mounted = True
		    Name = GetDriveName(s)
		    Path = s
		  Case CDROM
		    If GetDriveFileSystem(s) <> "" Then
		      Filesystem = GetDriveFileSystem(s)
		      FreeBytes = GetDriveFreeSize(s)
		      Totalbytes = GetDriveSize(s)
		      Mounted = True
		      Name = GetDriveName(s)
		      Path = s
		    Else
		      Filesystem = "None"//"(No Disk)"
		      FreeBytes = 0
		      Totalbytes = 0
		      Mounted = False
		      Name = "(Optical Drive)"
		      Path = s
		    End If
		  Case Removable
		    If GetDriveFileSystem(s) <> "" Then
		      If DriveType(s) = BusUSB Then
		        Filesystem = GetDriveFileSystem(s)
		        FreeBytes = GetDriveFreeSize(s)
		        Totalbytes = GetDriveSize(s)
		        Mounted = True
		        Name = GetDriveName(s)
		        Name = Name + "(USB)"
		        Path = s
		        Icon = USB_Icon
		      Else
		        Filesystem = GetDriveFileSystem(s)
		        FreeBytes = GetDriveFreeSize(s)
		        Totalbytes = GetDriveSize(s)
		        Mounted = True
		        Name = GetDriveName(s)
		        Path = s
		      End If
		    Else
		      Filesystem = "None"//"(No Disk)"
		      FreeBytes = 0
		      Totalbytes = 0
		      Mounted = False
		      Name = "(Card Reader)"
		      Path = s
		    End If
		    
		  Case Network
		    Filesystem = "SMB"
		    FreeBytes = 0
		    Totalbytes = 0
		    Mounted = True
		    Name = "Network Volume"
		    Path = s
		    
		  Case NotMounted
		    Filesystem = "No Disk"
		    FreeBytes = 0
		    Totalbytes = 0
		    Mounted = False
		    Name = "No Disk"
		    Path = s
		  End Select
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		Filesystem As String
	#tag EndProperty

	#tag Property, Flags = &h0
		FreeBytes As UInt64
	#tag EndProperty

	#tag Property, Flags = &h0
		Icon As Picture
	#tag EndProperty

	#tag Property, Flags = &h0
		Mounted As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		Name As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Path As String
	#tag EndProperty

	#tag Property, Flags = &h0
		PercentFull As Double
	#tag EndProperty

	#tag Property, Flags = &h0
		Totalbytes As UInt64
	#tag EndProperty

	#tag Property, Flags = &h0
		Type As Integer
	#tag EndProperty


	#tag Constant, Name = CDROM, Type = Double, Dynamic = False, Default = \"5", Scope = Public
	#tag EndConstant

	#tag Constant, Name = Fixed, Type = Double, Dynamic = False, Default = \"3", Scope = Public
	#tag EndConstant

	#tag Constant, Name = Network, Type = Double, Dynamic = False, Default = \"4", Scope = Public
	#tag EndConstant

	#tag Constant, Name = NotMounted, Type = Double, Dynamic = False, Default = \"1", Scope = Public
	#tag EndConstant

	#tag Constant, Name = Removable, Type = Double, Dynamic = False, Default = \"2", Scope = Public
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="Filesystem"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Icon"
			Group="Behavior"
			Type="Picture"
		#tag EndViewProperty
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
			Name="Mounted"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Path"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="PercentFull"
			Group="Behavior"
			Type="Double"
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
		#tag ViewProperty
			Name="Type"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
