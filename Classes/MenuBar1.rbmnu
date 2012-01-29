#tag Menu
Begin Menu MenuBar1
   Begin MenuItem WinControl
      SpecialMenu = 0
      Text = "Menu"
      Index = -2147483648
      AutoEnable = True
      Begin MenuItem arrangeMenu
         SpecialMenu = 0
         Text = "Arrange"
         Index = -2147483648
         ShortcutKey = "A"
         Shortcut = "Cmd+A"
         MenuModifier = True
         AutoEnable = True
         SubMenu = True
         Begin MenuItem alphaSortMenu
            SpecialMenu = 0
            Text = "Alphabetic"
            Index = -2147483648
            ShortcutKey = "A"
            Shortcut = "Cmd+A"
            MenuModifier = True
            AutoEnable = True
         End
         Begin MenuItem procIDSortMenu
            SpecialMenu = 0
            Text = "Process ID"
            Index = -2147483648
            ShortcutKey = "P"
            Shortcut = "Cmd+P"
            MenuModifier = True
            AutoEnable = True
         End
         Begin MenuItem dissarrayMenu
            SpecialMenu = 0
            Text = "General Disarray"
            Index = -2147483648
            ShortcutKey = "D"
            Shortcut = "Cmd+D"
            MenuModifier = True
            AutoEnable = True
         End
         Begin MenuItem ToggleAutoArrange
            SpecialMenu = 0
            Text = "Toggle Auto Arrange"
            Index = -2147483648
            ShortcutKey = "T"
            Shortcut = "Cmd+T"
            MenuModifier = True
            AutoEnable = True
         End
      End
      Begin MenuItem unhidemenu
         SpecialMenu = 0
         Text = "Unhide All Hidden Tiles"
         Index = -2147483648
         ShortcutKey = "U"
         Shortcut = "Cmd+U"
         MenuModifier = True
         AutoEnable = True
      End
      Begin MenuItem hilightingmenu
         SpecialMenu = 0
         Text = "Toggle Hilighting"
         Index = -2147483648
         ShortcutKey = "H"
         Shortcut = "Cmd+H"
         MenuModifier = True
         AutoEnable = True
      End
      Begin MenuItem hideSystemMenu
         SpecialMenu = 0
         Text = "Toggle System Processes"
         Index = -2147483648
         ShortcutKey = "S"
         Shortcut = "Cmd+S"
         MenuModifier = True
         AutoEnable = True
      End
      Begin MenuItem ToggleDebugMenu
         SpecialMenu = 0
         Text = "Toggle Debug Messages"
         Index = -2147483648
         ShortcutKey = "M"
         Shortcut = "Cmd+M"
         MenuModifier = True
         AutoEnable = True
      End
      Begin MenuItem hideDynamic
         SpecialMenu = 0
         Text = "Toggle Dynamic Tiles"
         Index = -2147483648
         ShortcutKey = "O"
         Shortcut = "Cmd+O"
         MenuModifier = True
         AutoEnable = True
      End
      Begin MenuItem wildmode
         SpecialMenu = 0
         Text = "Toggle Wild Mode"
         Index = -2147483648
         ShortcutKey = "Z"
         Shortcut = "Cmd+Z"
         MenuModifier = True
         AutoEnable = True
      End
      Begin MenuItem setts
         SpecialMenu = 0
         Text = "Settings"
         Index = -2147483648
         ShortcutKey = "W"
         Shortcut = "Cmd+W"
         MenuModifier = True
         AutoEnable = True
      End
   End
End
#tag EndMenu
