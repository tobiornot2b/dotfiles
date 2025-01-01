import XMonad

       -- Layout Modifieres
import XMonad.Layout.Spacing
import XMonad.Layout.LayoutModifier

       -- Hooks
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, wrap, xmobarPP, xmobarColor, shorten, PP(..))

       --- Utils
import XMonad.Hooks.ManageDocks -- docks, avoidStruts
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Util.Run -- spawnPipe

import qualified XMonad.StackSet as W

--- VARIABLES

myTerminal :: String
myTerminal = "alacritty"

myBrowser :: String
myBrowser = "firefox"

myModMask :: KeyMask
myModMask = mod4Mask

myBorderWidth :: Dimension
myBorderWidth = 1

myWorkspaces = ["dev", "web", "test", "tel", "chat"] ++ map show [6..9]

windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

--- KEYBINDINGS

myKeys :: [(String, X ())]
myKeys = 
       [ ("M-C-r", spawn "xmonad --recompile")
       , ("M-p", spawn "rofi -show drun")          
        --- Programs
       , ("M-<Return>", spawn myTerminal)          
       , ("M-w", spawn myBrowser)          
        --- Other
       , ("M-<Tab>", sendMessage NextLayout)           -- Switch to next layout
       ]

-- Status bars and logging
--
-- -- Perform an arbitrary action on each internal state change or X event.
-- -- See the 'XMonad.Hooks.DynamicLog' extension for examples.
-- --
myLogHook = return ()

-- Layouts:

mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True
--
-- -- You can specify and transform your layouts by modifying these values.
-- -- If you change layout bindings be sure to use 'mod-shift-space' after
-- -- restarting (with 'mod-q') to reset your layout state to the new
-- -- defaults, as xmonad preserves your old layout settings by default.
-- --
-- -- The available layouts.  Note that each layout is separated by |||,
-- -- which denotes layout choice.
-- --
myLayout = avoidStruts (tiled ||| Mirror tiled ||| Full)
  where
    -- default tiling algorithm partitions the screen into two panes
    tiled   = mySpacing 4 $ Tall nmaster delta ratio

    -- The default number of windows in the master pane
    nmaster = 1

    -- Default proportion of screen occupied by master pane
    ratio   = 1/2

    -- Percent of screen to increment by when resizing panes
    delta   = 3/100

main = do
  xmproc1 <- spawnPipe ("xmobar -x 1 $HOME/.dotfiles/modules/xmonad/xmobarrc")
  xmproc2 <- spawnPipe ("xmobar -x 2 $HOME/.dotfiles/modules/xmonad/xmobarrc")
  xmproc3 <- spawnPipe ("xmobar -x 3 $HOME/.dotfiles/modules/xmonad/xmobarrc")
  xmonad $ docks $ (defaults xmproc1 xmproc2 xmproc3) `additionalKeysP` myKeys

defaults xmproc xmproc1 xmproc2 = def
     { terminal = myTerminal
     , modMask  = myModMask
     , borderWidth = myBorderWidth
     , workspaces = myWorkspaces
     , layoutHook = myLayout
     , logHook  = myLogHook <+> dynamicLogWithPP xmobarPP
                 { ppOutput = \x -> hPutStrLn xmproc x >> hPutStrLn xmproc1 x >> hPutStrLn xmproc2 x 
                 , ppCurrent = xmobarColor "#98be65" "" . wrap "[" "]"           -- Current workspace in xmobar
                 , ppVisible = xmobarColor "#98be65" ""                          -- Visible but not current workspace
                 , ppHidden = xmobarColor "#82AAFF" "" . wrap "*" "" 		   -- Hidden workspaces in xmobar
                 , ppHiddenNoWindows = xmobarColor "#c792ea" ""                  -- Hidden workspaces (no windows)
		 , ppTitle = xmobarColor "#b3afc2" "" . shorten 60               -- Title of active window in xmobar
		 , ppSep =  "<fc=#666666> <fn=1>|</fn> </fc>"                    -- Separators in xmobar
		 , ppUrgent = xmobarColor "#C45500" "" . wrap "!" "!"            -- Urgent workspace
		 , ppExtras  = [windowCount]                                     -- # of windows current workspace
		 , ppOrder  = \(ws:l:t:ex) -> [ws,l]++ex++[t]
		 }
     }
