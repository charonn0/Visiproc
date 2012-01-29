#tag Class
Protected Class UpdGUIThread
Inherits Thread
	#tag Event
		Sub Run()
		  While True
		    //App.YieldToNextThread
		    doit()
		    If CPUThread.State = 4 Then 
		      CPUThread.Run
		      Break
		    End If
		    Me.Sleep(1000)
		  Wend
		  
		Exception err
		  If err IsA ThreadEndException Or err IsA EndException Then Raise Err
		  Break
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h21
		Private Sub doit()
		  '#If DebugBuild Then Debug(CurrentMethodName)
		  'If GLOBALPAUSE Then Break
		  If Window1.count Mod 25 = 0 Then PollDisks()
		  Window1.dragContainer1.DynUpdate()
		  If DebugMode Then PollDebug()
		  Window1.dragContainer1.Update()
		  Window1.count = Window1.count + 1
		  FirstRun = False
		  lastFPS = Window1.dragContainer1.FPS
		  Window1.dragContainer1.FPS = 0
		  Dim d As New Date
		  Window1.Status1.Text = d.LongDate + " " + d.LongTime + "   "
		  Window1.Status.Text = "Showing: " + Str((UBound(activeProcesses) + 1) - (Window1.dragContainer1.sysProcs.Ubound + 1)) + " of " + Str(UBound(activeProcesses) + 1) + " running processes."
		  
		End Sub
	#tag EndMethod


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			Type="Integer"
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
