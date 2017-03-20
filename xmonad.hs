-- ~/.xmonad/xmonad.hs
-- XMonad Config File

import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run
import XMonad.Util.EZConfig

import XMonad.Hooks.SetWMName
import XMonad.Layout.Maximize
import XMonad.Layout.Minimize
import XMonad.Layout.NoBorders

import XMonad.Config.Desktop


-- デフォルトのTerminal
myTerminal = "lxterminal"


-- Modキーをcommandに設定
myModMask = mod4Mask


-- ワークスペースの設定
myWorkspaces = ["1:term","2:browser","3:dir","4:mail","5:code","6:music","7:dict","8:other","9:sys"]


-- 境界線の太さ
myBorderWidth = 5


-- 境界線の色
myNormalBorderColor = "#dddddd"
myFocusedBorderColor = "#ff0000"


-- キーバインディング
myRemoveKeys = [
    -- gmrun は使わないので外す
    "M-S-p"
    -- reloadするとxmobarが変な挙動をするので廃止する
    -- これ以降はそこまで頻繁に変更しないはず
    , "M-q"
    ]


myAdditionalKeys = [
    -- スクリーンショット
    ("M-a", spawn "sleep 0.2; scrot ~/Pictures/screenshots/%Y-%m-%d-%T-screenshot.png")

    -- ロック&スクリーンセーバ起動
    , ("M-z", spawn "xscreensaver-command -lock")

    -- dockを隠す/戻す
    , ("M-b", sendMessage ToggleStruts)

    -- 画面を最大化
    , ("M-\\", withFocused (sendMessage . maximizeRestore))

    -- 画面を最小化, 元に戻す
    , ("M-m", withFocused minimizeWindow)
    , ("M-S-m", sendMessage RestoreNextMinimizedWin)

    -- ウィンドウを閉じる
    -- defaultでは再読込だけど、Macのキーバインドに合わせる
    , ("M-q", kill)

    -- Brightness Keys
    , ("<XF86MonBrightnessUp>", spawn "light -A 5")
    , ("<XF86MonBrightnessDown>", spawn "light -U 5")

    -- Volume setting media keys
    , ("<XF86AudioRaiseVolume>", spawn "amixer set Master 5%+")
    , ("<XF86AudioLowerVolume>", spawn "amixer set Master 5%-")]


-- レイアウトに関する設定
myLayoutHook = (smartBorders $ avoidStruts $ maximize $ minimize (tiled ||| Mirror tiled)) ||| (noBorders Full)
    where
        tiled   = Tall nmaster delta ratio
        nmaster = 1
        ratio   = 1/2
        delta   = 3/100


-- windowのルール
myManageHook = manageDocks <+> manageHook desktopConfig <+> composeAll
    [ className =? "Gimp" --> doFloat
    , className =? "VLC" --> doFloat
    ]


-- ステータスバーとログ
myLogHook h = dynamicLogWithPP xmobarPP
    { ppOutput = hPutStrLn h
    , ppTitle = xmobarColor "green" "" . shorten 50
    }
 

-- スタートアップ
-- javaアプリケーションがグレイに塗りつぶされる不具合対策
myStartupHook = setWMName "LG3D"


-- XMonadの実行
main = do
    xmproc <- spawnPipe "/usr/bin/xmobar ~/.xmonad/.xmobarrc"
    xmonad $ desktopConfig
        { terminal = myTerminal
        , borderWidth = myBorderWidth
        , modMask = myModMask
        , workspaces = myWorkspaces
        , normalBorderColor = myNormalBorderColor
        , focusedBorderColor = myFocusedBorderColor

        -- hooks, layouts
        , layoutHook = myLayoutHook
        , manageHook = myManageHook
        , logHook = myLogHook xmproc
        , startupHook = myStartupHook
        }
        `removeKeysP` myRemoveKeys
        `additionalKeysP` myAdditionalKeys

