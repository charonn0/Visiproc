#tag Class
Protected Class HashGetter
Inherits Thread
	#tag Event
		Sub Run()
		  If Target <> Nil Then
		    If Not Target.Directory Then
		      Dim s As String
		      Dim bs As BinaryStream
		      bs = bs.Open(target)
		      Dim m5 As New MD5Digest
		      While Not bs.EOF
		        s = bs.Read(4096)
		        m5.Process(s)
		      Wend
		      bs.Close
		      s = StringToHex(m5.Value)
		      hashwin.Title = "MD5 - " + prettifyPath(Target.AbsolutePath)
		      hashwin.Label1.Text = s
		      hashwin.Show
		    Else
		      Call MsgBox("Can't hash a directory!", 6, "Need a file, please.")
		    End If
		  End If
		  Working = False
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h1000
		Sub Constructor(t As FolderItem)
		  // Calling the overridden superclass constructor.
		  Super.Constructor
		  Target = t
		  
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		Target As FolderItem
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InheritedFrom="Thread"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			Type="Integer"
			InheritedFrom="Thread"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InheritedFrom="Thread"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Priority"
			Visible=true
			Group="Behavior"
			InitialValue="5"
			Type="Integer"
			InheritedFrom="Thread"
		#tag EndViewProperty
		#tag ViewProperty
			Name="StackSize"
			Visible=true
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			InheritedFrom="Thread"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InheritedFrom="Thread"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			Type="Integer"
			InheritedFrom="Thread"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
