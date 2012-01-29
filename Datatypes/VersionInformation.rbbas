#tag Class
Protected Class VersionInformation
	#tag Method, Flags = &h0
		Sub Constructor(f As FolderItem)
		  Dim data As Dictionary = VersionInfo(f)
		  If data = Nil Then Return
		  
		  For i As Integer = 0 To data.Count - 1
		    Select Case data.Key(i)
		    Case "Comments"
		      Comments = data.Value(data.Key(i))
		    Case "InternalName"
		      InternalName = data.Value(data.Key(i))
		    Case "ProductName"
		      ProductName = data.Value(data.Key(i))
		    Case "CompanyName"
		      CompanyName = data.Value(data.Key(i))
		    Case "LegalCopyright"
		      LegalCopyright = data.Value(data.Key(i))
		    Case "ProductVersion"
		      ProductVersion = data.Value(data.Key(i))
		    Case "FileDescription"
		      FileDescription = data.Value(data.Key(i))
		    Case "LegalTrademarks"
		      LegalTrademarks = data.Value(data.Key(i))
		    Case "PrivateBuild"
		      PrivateBuild = data.Value(data.Key(i))
		    Case "FileVersion"
		      FileVersion = data.Value(data.Key(i))
		    Case "OriginalFilename"
		      OriginalFilename = data.Value(data.Key(i))
		    Case "SpecialBuild"
		      SpecialBuild = data.Value(data.Key(i))
		    End Select
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function VersionInfo(f As FolderItem) As Dictionary
		  //Returns the VersionInfo headers of a Windows executable in a Dictionary object.
		  //On error, or if the file does not have VersionInfo embedded or does not exist, Returns Nil
		  //Some fields may not be present.
		  
		  If f = Nil Then Return Nil
		  If Not f.Exists Then Return Nil
		  
		  Declare Function GetFileVersionInfoSizeW Lib "Version" (fileName As WString, ignored As Integer) As Integer
		  Declare Function GetFileVersionInfoW Lib "Version" (fileName As WString, ignored As Integer, bufferSize As Integer, buffer As Ptr) As Boolean
		  Declare Function VerQueryValueW Lib "Version" (inBuffer As Ptr, subBlock As WString, outBuffer As Ptr, ByRef outBufferLen As Integer) As Boolean
		  
		  Dim infoSize As Integer = GetFileVersionInfoSizeW(f.AbsolutePath, 0)
		  If infoSize <= 0 Then Return Nil
		  
		  Dim buff As New MemoryBlock(infoSize)
		  If GetFileVersionInfoW(f.AbsolutePath, 0, buff.Size, buff) Then
		    Dim mb As New MemoryBlock(4)
		    Dim retBuffLen As Integer
		    If VerQueryValueW(buff, "\VarFileInfo\Translation", mb, retBuffLen) Then
		      Dim fields() As String = Split("Comments;InternalName;ProductName;CompanyName;LegalCopyright;ProductVersion;FileDescription;LegalTrademarks;PrivateBuild;FileVersion;OriginalFilename;SpecialBuild", ";")
		      Dim j, k As String
		      j = Hex(mb.Ptr(0).Int16Value(0))
		      k = Hex(mb.Ptr(0).Int16Value(2))
		      Dim langCode As String = Left("0000", 4 - Len(j)) + j + Left("0000", 4 - Len(k)) + k
		      Dim ret As New Dictionary
		      For Each datum As String In fields
		        mb = New MemoryBlock(4)
		        If VerQueryValueW(buff, "\StringFileInfo\" + langCode + "\" + datum, mb, retBuffLen) Then
		          ret.Value(datum) = mb.Ptr(0).WString(0)
		        End If
		      Next
		      Return ret
		    Else
		      Return Nil
		    End If
		  Else
		    Return Nil
		  End If
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		Comments As String
	#tag EndProperty

	#tag Property, Flags = &h0
		CompanyName As String
	#tag EndProperty

	#tag Property, Flags = &h0
		FileDescription As String
	#tag EndProperty

	#tag Property, Flags = &h0
		FileVersion As String
	#tag EndProperty

	#tag Property, Flags = &h0
		InternalName As String
	#tag EndProperty

	#tag Property, Flags = &h0
		LegalCopyright As String
	#tag EndProperty

	#tag Property, Flags = &h0
		LegalTrademarks As String
	#tag EndProperty

	#tag Property, Flags = &h0
		OriginalFilename As String
	#tag EndProperty

	#tag Property, Flags = &h0
		PrivateBuild As String
	#tag EndProperty

	#tag Property, Flags = &h0
		ProductName As String
	#tag EndProperty

	#tag Property, Flags = &h0
		ProductVersion As String
	#tag EndProperty

	#tag Property, Flags = &h0
		SpecialBuild As String
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Comments"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="CompanyName"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="FileDescription"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="FileVersion"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="InternalName"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LegalCopyright"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LegalTrademarks"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="OriginalFilename"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="PrivateBuild"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ProductName"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ProductVersion"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="SpecialBuild"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
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
End Class
#tag EndClass
