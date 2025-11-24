import XMonad

       -- Layout Modifieres
import XMonad.Layout.Spacing
import XMonad.Layout.LayoutModifier

       -- Hooks
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, wrap, xmobarPP, xmobarColor, shorten, PP(..))
import XMonad.Hooks.ManageHelpers (isDialog)

       -- Navigation
import XMonad.Actions.CycleWS (nextScreen, prevScreen)

       --- Utils
import XMonad.Hooks.ManageDocks -- docks, avoidStruts
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Util.Run -- spawnPipe
import XMonad.Util.SpawnOnce -- spawnOnce

	--- Scratchpad
import XMonad.Util.NamedScratchpad
import XMonad.ManageHook

import qualified XMonad.StackSet as W
import qualified Data.Map as M
import qualified Data.List as L


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
       --- Rofi
       , ("M-p", spawn "rofi -show drun")
       , ("M-c", spawn "clipcat-menu")
       , ("M-S-s", spawn "maim -s | xclip -selection clipboard -t image/png")
       --- Join Zoom Meeting
       --- TODO: Move to secret
       , ("M-S-z", spawn "xdg-open 'zoommtg://dwpbank.zoom.us/join?action=join&confno=67460921564&pwd=h5L6UQQ8Ppbcf2uH0VHafmDIbhApQG.1'")
        --- Programs
       , ("M-<Return>", spawn myTerminal)
       , ("M-w", spawn myBrowser)
       , ("M-e", spawn "ranger")
       , ("M-<Esc>", spawn "i3lock -t -i /home/dwp7953/Downloads/florian1.png")
        --- Programs
       , ("M-,", nextScreen)
       , ("M-.", prevScreen)
        --- Other
       , ("M-<Tab>", sendMessage NextLayout)           -- Switch to next layout
       , ("M-a", namedScratchpadAction myScratchpads "ExxetaAI")
       , ("M-o", namedScratchpadAction myScratchpads "Logseq")
       , ("M-z", namedScratchpadAction myScratchpads "Zoom")
       , ("M-d", namedScratchpadAction myScratchpads "DrawIO")
       ]

--- Scrachpad Definition
myScratchpads :: [NamedScratchpad]
myScratchpads =
  [ NS "ExxetaAI" "google-chrome --app=http://chat.exxeta.com --profile-directory='Default'" (resource =? "chat.exxeta.com") (customFloating $ W.RationalRect (1/6) (1/6) (2/3) (2/3)) 
  , NS "Logseq" "logseq --no-sandbox" (className =? "logseq") (customFloating $ W.RationalRect (1/6) (1/6) (2/3) (2/3))
  , NS "Zoom" "flatpak run us.zoom.Zoom" (className =? "zoom") (customFloating $ W.RationalRect (1/6) (1/6) (2/3) (2/3))
  , NS "DrawIO" "google-chrome --app=https://app.diagrams.net --profile-directory='Default'" (resource =? "app.diagrams.net") (customFloating $ W.RationalRect (1/6) (1/6) (2/3) (2/3)) 
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

-- Manage Hook
-- resource => first part of WM_CLASS (primary)
-- className => second part of WM_CLASS (secondary)
myManageHook = composeAll
    [ resource =? "chat.exxeta.com" --> (customFloating $ W.RationalRect (1/6) (1/6) (2/3) (2/3))
    , resource =? "app.diagrams.net" --> (customFloating $ W.RationalRect (1/6) (1/6) (2/3) (2/3))
    , className =? "logseq" --> (customFloating $ W.RationalRect (1/6) (1/6) (2/3) (2/3))
    , isDialog --> doFloat
    ]

myMouseBindings (XConfig {XMonad.modMask = mod4Mask}) = M.fromList $
  [ ((mod4Mask, button1), \w -> focus w >> mouseMoveWindow w)  -- Fenster mit der linken Maustaste bewegen
  , ((mod4Mask, button2), \w -> focus w >> windows W.swapMaster)  -- Mit der mittleren Maustaste das Fenster wechseln
  , ((mod4Mask, button3), \w -> focus w >> mouseResizeWindow w)  -- Fenster mit der rechten Maustaste resize
  ]

myStartupHook :: X ()
myStartupHook = do
  spawnOnce "dunst &"
  spawnOnce "clipcatd"
  spawnOnce "picom --backend xrender &"

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
     , mouseBindings = myMouseBindings
     , manageHook = myManageHook <+> manageHook def
     , layoutHook = myLayout
     , startupHook = myStartupHook
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
