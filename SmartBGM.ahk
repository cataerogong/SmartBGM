; CodePage=GB2312
#SingleInstance

#Include VA.ahk

; ----------------------------
; 配置部分
; ----------------------------
AppName := "SmartBGM"
AppVer  := "1.0"
AppCopyRight := "Copyright (c) 2025 C.G."

IniFile := A_ScriptDir . "\" . A_ScriptName . ".ini"
IcoFile := A_ScriptDir . "\" . A_ScriptName . ".ico"

if !FileExist(IniFile)
{
    IniWrite, `; 将 <BGM exe> 替换为 BGM 音乐程序的文件名。示例：BGMWinTitle=ahk_exe MusicPlayer.exe`nBGMWinTitle=`n`; BGM 音量切换模式: 瞬 - 立刻切换静音，渐 - 慢慢调整音量`nSwitchMode=瞬`n; 自动开始`nAutoStart=0, %IniFile%, %AppName%
}

; 读取配置文件
IniRead, BGMWinTitle, %IniFile%, %AppName%, BGMWinTitle, %A_Space%  ; 需要调节音量的 BGM 程序
IniRead, SwitchMode, %IniFile%, %AppName%, SwitchMode, 瞬  ; 切换风格（瞬 | 渐），默认“瞬”
IniRead, AutoStart, %IniFile%, %AppName%, AutoStart, 0  ; 自动开始

If ((Not A_IsCompiled) And FileExist(IcoFile))
{
    Menu, Tray, Icon, %IcoFile%
}
Menu, Tray, NoStandard
Menu, Tray, Add, Open %AppName%, ShowGui
Menu, Tray, Add, Exit, GuiClose
Menu, Tray, Default, 1&

IID_IASM2 := "{77AA99A0-1BD6-484F-8BC7-2C654C9A9B6F}"
IID_IASC2 := "{bfb7ff88-7239-4fc9-8fa2-07c950be9c6d}"
IID_ISAV := "{87CE5498-68D6-44E5-9215-6DA47EF883D8}"

InitGUI()

If AutoStart
{
    Goto OnBtnStart
}

Return

InitGUI()
{
    Global
    ;Gui, +Border
    Gui, Margin, 10, 10
    Gui, Add, Text, xm ym h20, BGM 程序
    Gui, Add, Edit, x+10 yp-3 h20 w300 vEdtBGMWin, %BGMWinTitle%
	Gui, Add, Button, x+ yp h20 gOnBtnSelBGM, …
    Gui, Add, Text, xm y+m h20, 音量切换风格
    ; Gui, Add, DropDownList, x+10 yp-3 w50 vDdlBGMMode, 瞬|渐
    Gui, Add, Radio, x+10 yp-3 h20 Group vRadBGMMode1, 瞬
    Gui, Add, Radio, x+10 yp h20 vRadBGMMode2, 渐
    Gui, Add, CheckBox, xm y+m h20 vChkAutoStart, 自动开始
	Gui, Add, Button, xm y+m h20 vBtnApplyCfg gOnBtnApplyCfg, 应用设置
	Gui, Add, Button, x+10 yp h20 vBtnStart gOnBtnStart, 开始监控
	Gui, Add, Button, x+10 yp h20 Disabled vBtnStop gOnBtnStop, 停止监控
	Gui, Add, Button, x+10 yp h20 vBtnPlaying gOnBtnPlaying, 正在播放
	Gui, Add, Button, x+20 yp h20 gOnBtnAbout, 关于
    Gui, Add, StatusBar, ,
    Gui, Show, , %AppName% v%AppVer%
	Gui, +OwnDialogs
    ; GuiControl, ChooseString, DdlBGMMode, %SwitchMode%
    GuiControl, , %SwitchMode%, 1
    GuiControl, , ChkAutoStart, %AutoStart%
}

ShowGui:
{
    Gui, Show
    Return
}

GuiSize:
{
    If (A_EventInfo == 1)
    {
        Gui, Hide
    }
    Return
}

GuiEscape:
{
    Gui, Hide
    Return
}

GuiClose:
{
    RestoreBGM()
    ExitApp
    Return
}
OnBtnApplyCfg:
{
    Gui, 1:Submit, NoHide
    BGMWinTitle := EdtBGMWin
    SwitchMode := RadBGMMode1 ? "瞬" : "渐"
    AutoStart := ChkAutoStart
    IniWrite, %BGMWinTitle%, %IniFile%, %AppName%, BGMWinTitle
    IniWrite, %SwitchMode%, %IniFile%, %AppName%, SwitchMode
    IniWrite, %AutoStart%, %IniFile%, %AppName%, AutoStart
    Return
}    
OnBtnStart:
{
    SetTimer, CheckAudioState, 500
    GuiControl, Disable, BtnStart
    GuiControl, Enable, BtnStop
    Tip("开始监控")
    Return
}
OnBtnStop:
{
    SetTimer, CheckAudioState, Off
    RestoreBGM()
    GuiControl, Disable, BtnStop
    GuiControl, Enable, BtnStart
    Tip("停止监控")
    Return
}
;------------------------------------------------------------------------------
; 窗口选择
OnBtnSelBGM:
{
    Gui, SelBGM:+Owner1 +ToolWindow
    Gui, SelBGM:Add, Text, xm ym, * 双击选择 BGM 程序
    Gui, SelBGM:Add, ListBox, xm y+m r10 w500 Sort 0x100 vLstWin gOnSelBGM
    Gui, SelBGM:Show, , %AppName% - 选择 BGM 程序

	Gui, 1:+Disabled

    GuiControl, SelBGM:-Redraw, LstWin
    WinGet, AllWins, List
    Loop % AllWins
    {
        id := AllWins%A_Index%
        WinGet, pn, ProcessName, ahk_id %id%
        If (pn)
            GuiControl, SelBGM:, LstWin, %pn%
    }
    ; GuiControl, SelBGM:, LstWin, END|BB
    GuiControl, SelBGM:+Redraw, LstWin

    Return
}
OnSelBGM:
{
    If (A_GuiEvent == "DoubleClick")
    {
        Gui, SelBGM:Submit
        BGMWinTitle := "ahk_exe " . LstWin
        GuiControl, 1:, EdtBGMWin, %BGMWinTitle%
        Goto SelBGMGuiClose
    }
    Return
}
SelBGMGuiClose:
SelBGMGuiEscape:
{
	Gui, SelBGM:Destroy
    Gui, 1:-Disabled
    Gui, 1:Show
	Return
}

;------------------------------------------------------------------------------
; 正在播放窗口
OnBtnPlaying:
{
    Gui, Playing:+Owner1 +ToolWindow
    Gui, Playing:Add, Text, xm ym, * 行首标志含义：1: A - active; 2: M - muted; 3: 音量`%; 4: PID进程号
    Gui, Playing:Add, ListBox, xm y+m r10 w500 ReadOnly Sort 0x100 vLstPlaying
    Gui, Playing:Show, , %AppName% - 正在播放

    Gui, 1:+Disabled

    GuiControl, Playing:-Redraw, LstPlaying

    ; 获取默认播放设备的会话管理器 GetDefaultAudioEndpoint
    DAE := VA_GetDevice()
    If !DAE
    {
        Tip("无法获取音频设备")
    }
    Else
    {
        ; 激活会话管理器2接口 activate the session manager
        VA_IMMDevice_Activate(DAE, IID_IASM2, 0, 0, IASM2)
        ; 获取会话枚举器 enumerate sessions for on this device
        VA_IAudioSessionManager2_GetSessionEnumerator(IASM2, IASE)
        ; 获取会话数量
        VA_IAudioSessionEnumerator_GetCount(IASE, Count)

        ; 遍历所有音频会话
        Loop % Count
        {
            ; 获取会话控制接口 Get the IAudioSessionControl object
            VA_IAudioSessionEnumerator_GetSession(IASE, A_Index-1, IASC)
            ; Query the IAudioSessionControl for an IAudioSessionControl2 object
            IASC2 := ComObjQuery(IASC, IID_IASC2)
            ; 获取进程ID Get the session's process ID
            VA_IAudioSessionControl2_GetProcessID(IASC2, SPID)
            if (SPID) ; 跳过没有 PID 的 Session
            {
                ; 获取 ISimpleAudioVolume obj
                ISAV := ComObjQuery(IASC2, IID_ISAV)
                ; 获取会话状态
                VA_IAudioSessionControl_GetState(IASC, state) ; 0=Inactive, 1=Active, 2=Expired
                ; 获取静音状态
                VA_ISimpleAudioVolume_GetMute(ISAV, muted)
                VA_ISimpleAudioVolume_GetMasterVolume(ISAV, vol)
                a := state==1 ? "A" : " "
                m := muted ? "M" : " "
                v := Round(vol*100)
                ; if (state == 1 && !muted)
                {
                    WinGetTitle, playingWin, ahk_pid %SPID%
                    If !playingWin
                        WinGet, playingWin, ProcessName, ahk_pid %SPID%
                    GuiControl, Playing:, LstPlaying, %a% %m% %v%`% PID=%SPID% : %playingWin%
                }
                ObjRelease(ISAV)
            }

            ObjRelease(IASC)
            ObjRelease(IASC2)
        }

        ; 清理资源
        ObjRelease(IASE)
        ObjRelease(IASM2)
        ObjRelease(DAE)
    }
    GuiControl, Playing:+Redraw, LstPlaying

    Return
}
PlayingGuiClose:
PlayingGuiEscape:
{
    Gui, Playing:Destroy
    Gui, 1:-Disabled
    Gui, 1:Show
    Return
}

;------------------------------------------------------------------------------
; About
OnBtnAbout:
{
	Gui, 1:+OwnDialogs
	Gui, 2:+Owner1 +ToolWindow
	Gui, 2:Add, Picture, xm ym Icon1, %A_ScriptName%
	Gui, 2:Font, Bold
	Gui, 2:Add, Text, xm+40 yp+20, %AppName% v%AppVer%
	Gui, 2:Font
	Gui, 2:Add, Text, , %AppCopyRight%
	Gui, 2:Add, Button, y+20 gABOUTOK Default w75, &OK

	Gui, 2:Show, , %AppName% - About

	Gui, 1:+Disabled

	return
}

2GuiClose:
2GuiEscape:
ABOUTOK:
{
	Gui, 2:Destroy
	Gui, 1:-Disabled
    Gui, 1:Show
	return
}

Tip(msg)
{
    Global AppName
    Static OldMsg := ""
    if !msg
        return
    if (msg != OldMsg)
    {
        ; TrayTip, %AppName%, %msg%
        SB_SetText(msg)
        OldMsg := msg
    }
}

CheckAudioState()
{
    Global IID_IASM2, IID_IASC2, IID_ISAV
    Global BGMWinTitle

    if (!WinExist(BGMWinTitle))
    {
        Tip("BGM 未运行")
        return
    }

    ; 获取默认播放设备的会话管理器 GetDefaultAudioEndpoint
    if !DAE := VA_GetDevice()
    {
        Tip("无法获取音频设备")
        return
    }

    ; 激活会话管理器2接口 activate the session manager
    VA_IMMDevice_Activate(DAE, IID_IASM2, 0, 0, IASM2)
    ; 获取会话枚举器 enumerate sessions for on this device
    VA_IAudioSessionManager2_GetSessionEnumerator(IASM2, IASE)
    ; 获取会话数量
    VA_IAudioSessionEnumerator_GetCount(IASE, Count)

    OtherPlaying := false
    BGM_Active := false
    BGM_ISAV := 0

    ; 遍历所有音频会话
    Loop % Count
    {
        ; 获取会话控制接口 Get the IAudioSessionControl object
        VA_IAudioSessionEnumerator_GetSession(IASE, A_Index-1, IASC)
        ; Query the IAudioSessionControl for an IAudioSessionControl2 object
        IASC2 := ComObjQuery(IASC, IID_IASC2)
        ; 获取进程ID Get the session's process ID
        VA_IAudioSessionControl2_GetProcessID(IASC2, SPID)
        if (SPID) ; 跳过没有 PID 的 Session
        {
            ; 获取 ISimpleAudioVolume obj
            ISAV := ComObjQuery(IASC2, IID_ISAV)
            ; 获取会话状态
            VA_IAudioSessionControl_GetState(IASC, state) ; 0=Inactive, 1=Active, 2=Expired
            if (WinExist(BGMWinTitle . " ahk_pid " . SPID)) ; 检测 BGM 程序
            {
                BGM_Active := (state == 1)
                BGM_ISAV := ISAV ; 保留 BGM 程序 ISAV
            }
            else ; 检测其他程序
            {
                ; 获取静音状态
                VA_ISimpleAudioVolume_GetMute(ISAV, muted)
                VA_ISimpleAudioVolume_GetMasterVolume(ISAV, vol)
                if (state == 1 && !muted && vol > 0)
                {
                    OtherPlaying := true
                }
                ObjRelease(ISAV)
            }
        }

        ObjRelease(IASC)
        ObjRelease(IASC2)
    }

    if (BGM_Active)
    {
        if (OtherPlaying)
        {
            BGMDown(BGM_ISAV)
        }
        else
        {
            BGMUp(BGM_ISAV)
        }
    }

    ; 清理资源
    ObjRelease(BGM_ISAV)
    ObjRelease(IASE)
    ObjRelease(IASM2)
    ObjRelease(DAE)
}

BGMDown(ISAV)
{
    Global SwitchMode
    ; 获取音量
    VA_ISimpleAudioVolume_GetMasterVolume(ISAV, vol)
    if (vol > 0)
    {
        delta := SwitchMode=="瞬" ? 1 : 0.2
        vol := (vol-delta<0) ? 0 : (vol-delta)
        VA_ISimpleAudioVolume_SetMasterVolume(ISAV, vol)
        Msg := "BGM 音量：" . Round(vol*100) . "%"
    }
    ; 显示状态
    Tip(Msg)
}

BGMUp(ISAV)
{
    Global SwitchMode
    ; 获取音量
    VA_ISimpleAudioVolume_GetMasterVolume(ISAV, vol)
    if (vol < 1)
    {
        delta := SwitchMode=="瞬" ? 1 : 0.2
        vol := (vol+delta>1) ? 1 : (vol+delta)
        VA_ISimpleAudioVolume_SetMasterVolume(ISAV, vol)
        Msg := "BGM 音量：" . Round(vol*100) . "%"
    }
    ; 显示状态
    Tip(Msg)
}

RestoreBGM()
{
    Global IID_IASM2, IID_IASC2, IID_ISAV
    Global BGMWinTitle

    if (!WinExist(BGMWinTitle))
    {
        return
    }

    ; 获取默认播放设备的会话管理器 GetDefaultAudioEndpoint
    if !DAE := VA_GetDevice()
    {
        return
    }

    ; 激活会话管理器2接口 activate the session manager
    VA_IMMDevice_Activate(DAE, IID_IASM2, 0, 0, IASM2)
    ; 获取会话枚举器 enumerate sessions for on this device
    VA_IAudioSessionManager2_GetSessionEnumerator(IASM2, IASE)
    ; 获取会话数量
    VA_IAudioSessionEnumerator_GetCount(IASE, Count)

    BGM_ISAV := 0

    ; 遍历所有音频会话
    Loop % Count
    {
        ; 获取会话控制接口 Get the IAudioSessionControl object
        VA_IAudioSessionEnumerator_GetSession(IASE, A_Index-1, IASC)
        ; Query the IAudioSessionControl for an IAudioSessionControl2 object
        IASC2 := ComObjQuery(IASC, IID_IASC2)
        ; 获取进程ID Get the session's process ID
        VA_IAudioSessionControl2_GetProcessID(IASC2, SPID)
        if (SPID) ; 跳过没有 PID 的 Session
        {
            ; 获取 ISimpleAudioVolume obj
            ISAV := ComObjQuery(IASC2, IID_ISAV)
            ; 获取会话状态
            VA_IAudioSessionControl_GetState(IASC, state) ; 0=Inactive, 1=Active, 2=Expired
            if (WinExist(BGMWinTitle . " ahk_pid " . SPID)) ; 检测 BGM 程序
            {
                BGM_Active := (state == 1)
                BGM_ISAV := ISAV ; 保留 BGM 程序 ISAV
                Break
            }
        }

        ObjRelease(IASC)
        ObjRelease(IASC2)
    }
    if (BGM_Active)
    {
        ; VA_ISimpleAudioVolume_SetMute(BGM_ISAV, 0)
        VA_ISimpleAudioVolume_SetMasterVolume(BGM_ISAV, 1)
    }

    ; 清理资源
    ObjRelease(BGM_ISAV)
    ObjRelease(IASE)
    ObjRelease(IASM2)
    ObjRelease(DAE)
}



;
; ISimpleAudioVolume : {87CE5498-68D6-44E5-9215-6DA47EF883D8}
;
VA_ISimpleAudioVolume_SetMasterVolume(this, ByRef fLevel, GuidEventContext="") {
    return DllCall(NumGet(NumGet(this+0)+3*A_PtrSize), "ptr", this, "float", fLevel, "ptr", VA_GUID(GuidEventContext))
}
VA_ISimpleAudioVolume_GetMasterVolume(this, ByRef fLevel) {
    return DllCall(NumGet(NumGet(this+0)+4*A_PtrSize), "ptr", this, "float*", fLevel)
}
VA_ISimpleAudioVolume_SetMute(this, ByRef Muted, GuidEventContext="") {
    return DllCall(NumGet(NumGet(this+0)+5*A_PtrSize), "ptr", this, "int", Muted, "ptr", VA_GUID(GuidEventContext))
}
VA_ISimpleAudioVolume_GetMute(this, ByRef Muted) {
    return DllCall(NumGet(NumGet(this+0)+6*A_PtrSize), "ptr", this, "int*", Muted)
}

