; CodePage=GB2312
#SingleInstance

#Include VA.ahk

; ----------------------------
; ���ò���
; ----------------------------
AppName := "SmartBGM"
AppVer  := "1.0"
AppCopyRight := "Copyright (c) 2025 C.G."

IniFile := A_ScriptDir . "\" . A_ScriptName . ".ini"
IcoFile := A_ScriptDir . "\" . A_ScriptName . ".ico"

if !FileExist(IniFile)
{
    IniWrite, `; �� <BGM exe> �滻Ϊ BGM ���ֳ�����ļ�����ʾ����BGMWinTitle=ahk_exe MusicPlayer.exe`nBGMWinTitle=`n`; BGM �����л�ģʽ: ˲ - �����л��������� - ������������`nSwitchMode=˲`n; �Զ���ʼ`nAutoStart=0, %IniFile%, %AppName%
}

; ��ȡ�����ļ�
IniRead, BGMWinTitle, %IniFile%, %AppName%, BGMWinTitle, %A_Space%  ; ��Ҫ���������� BGM ����
IniRead, SwitchMode, %IniFile%, %AppName%, SwitchMode, ˲  ; �л����˲ | ������Ĭ�ϡ�˲��
IniRead, AutoStart, %IniFile%, %AppName%, AutoStart, 0  ; �Զ���ʼ

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
    Gui, Add, Text, xm ym h20, BGM ����
    Gui, Add, Edit, x+10 yp-3 h20 w300 vEdtBGMWin, %BGMWinTitle%
	Gui, Add, Button, x+ yp h20 gOnBtnSelBGM, ��
    Gui, Add, Text, xm y+m h20, �����л����
    ; Gui, Add, DropDownList, x+10 yp-3 w50 vDdlBGMMode, ˲|��
    Gui, Add, Radio, x+10 yp-3 h20 Group vRadBGMMode1, ˲
    Gui, Add, Radio, x+10 yp h20 vRadBGMMode2, ��
    Gui, Add, CheckBox, xm y+m h20 vChkAutoStart, �Զ���ʼ
	Gui, Add, Button, xm y+m h20 vBtnApplyCfg gOnBtnApplyCfg, Ӧ������
	Gui, Add, Button, x+10 yp h20 vBtnStart gOnBtnStart, ��ʼ���
	Gui, Add, Button, x+10 yp h20 Disabled vBtnStop gOnBtnStop, ֹͣ���
	Gui, Add, Button, x+10 yp h20 vBtnPlaying gOnBtnPlaying, ���ڲ���
	Gui, Add, Button, x+20 yp h20 gOnBtnAbout, ����
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
    SwitchMode := RadBGMMode1 ? "˲" : "��"
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
    Tip("��ʼ���")
    Return
}
OnBtnStop:
{
    SetTimer, CheckAudioState, Off
    RestoreBGM()
    GuiControl, Disable, BtnStop
    GuiControl, Enable, BtnStart
    Tip("ֹͣ���")
    Return
}
;------------------------------------------------------------------------------
; ����ѡ��
OnBtnSelBGM:
{
    Gui, SelBGM:+Owner1 +ToolWindow
    Gui, SelBGM:Add, Text, xm ym, * ˫��ѡ�� BGM ����
    Gui, SelBGM:Add, ListBox, xm y+m r10 w500 Sort 0x100 vLstWin gOnSelBGM
    Gui, SelBGM:Show, , %AppName% - ѡ�� BGM ����

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
; ���ڲ��Ŵ���
OnBtnPlaying:
{
    Gui, Playing:+Owner1 +ToolWindow
    Gui, Playing:Add, Text, xm ym, * ���ױ�־���壺1: A - active; 2: M - muted; 3: ����`%; 4: PID���̺�
    Gui, Playing:Add, ListBox, xm y+m r10 w500 ReadOnly Sort 0x100 vLstPlaying
    Gui, Playing:Show, , %AppName% - ���ڲ���

    Gui, 1:+Disabled

    GuiControl, Playing:-Redraw, LstPlaying

    ; ��ȡĬ�ϲ����豸�ĻỰ������ GetDefaultAudioEndpoint
    DAE := VA_GetDevice()
    If !DAE
    {
        Tip("�޷���ȡ��Ƶ�豸")
    }
    Else
    {
        ; ����Ự������2�ӿ� activate the session manager
        VA_IMMDevice_Activate(DAE, IID_IASM2, 0, 0, IASM2)
        ; ��ȡ�Ựö���� enumerate sessions for on this device
        VA_IAudioSessionManager2_GetSessionEnumerator(IASM2, IASE)
        ; ��ȡ�Ự����
        VA_IAudioSessionEnumerator_GetCount(IASE, Count)

        ; ����������Ƶ�Ự
        Loop % Count
        {
            ; ��ȡ�Ự���ƽӿ� Get the IAudioSessionControl object
            VA_IAudioSessionEnumerator_GetSession(IASE, A_Index-1, IASC)
            ; Query the IAudioSessionControl for an IAudioSessionControl2 object
            IASC2 := ComObjQuery(IASC, IID_IASC2)
            ; ��ȡ����ID Get the session's process ID
            VA_IAudioSessionControl2_GetProcessID(IASC2, SPID)
            if (SPID) ; ����û�� PID �� Session
            {
                ; ��ȡ ISimpleAudioVolume obj
                ISAV := ComObjQuery(IASC2, IID_ISAV)
                ; ��ȡ�Ự״̬
                VA_IAudioSessionControl_GetState(IASC, state) ; 0=Inactive, 1=Active, 2=Expired
                ; ��ȡ����״̬
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

        ; ������Դ
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
        Tip("BGM δ����")
        return
    }

    ; ��ȡĬ�ϲ����豸�ĻỰ������ GetDefaultAudioEndpoint
    if !DAE := VA_GetDevice()
    {
        Tip("�޷���ȡ��Ƶ�豸")
        return
    }

    ; ����Ự������2�ӿ� activate the session manager
    VA_IMMDevice_Activate(DAE, IID_IASM2, 0, 0, IASM2)
    ; ��ȡ�Ựö���� enumerate sessions for on this device
    VA_IAudioSessionManager2_GetSessionEnumerator(IASM2, IASE)
    ; ��ȡ�Ự����
    VA_IAudioSessionEnumerator_GetCount(IASE, Count)

    OtherPlaying := false
    BGM_Active := false
    BGM_ISAV := 0

    ; ����������Ƶ�Ự
    Loop % Count
    {
        ; ��ȡ�Ự���ƽӿ� Get the IAudioSessionControl object
        VA_IAudioSessionEnumerator_GetSession(IASE, A_Index-1, IASC)
        ; Query the IAudioSessionControl for an IAudioSessionControl2 object
        IASC2 := ComObjQuery(IASC, IID_IASC2)
        ; ��ȡ����ID Get the session's process ID
        VA_IAudioSessionControl2_GetProcessID(IASC2, SPID)
        if (SPID) ; ����û�� PID �� Session
        {
            ; ��ȡ ISimpleAudioVolume obj
            ISAV := ComObjQuery(IASC2, IID_ISAV)
            ; ��ȡ�Ự״̬
            VA_IAudioSessionControl_GetState(IASC, state) ; 0=Inactive, 1=Active, 2=Expired
            if (WinExist(BGMWinTitle . " ahk_pid " . SPID)) ; ��� BGM ����
            {
                BGM_Active := (state == 1)
                BGM_ISAV := ISAV ; ���� BGM ���� ISAV
            }
            else ; �����������
            {
                ; ��ȡ����״̬
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

    ; ������Դ
    ObjRelease(BGM_ISAV)
    ObjRelease(IASE)
    ObjRelease(IASM2)
    ObjRelease(DAE)
}

BGMDown(ISAV)
{
    Global SwitchMode
    ; ��ȡ����
    VA_ISimpleAudioVolume_GetMasterVolume(ISAV, vol)
    if (vol > 0)
    {
        delta := SwitchMode=="˲" ? 1 : 0.2
        vol := (vol-delta<0) ? 0 : (vol-delta)
        VA_ISimpleAudioVolume_SetMasterVolume(ISAV, vol)
        Msg := "BGM ������" . Round(vol*100) . "%"
    }
    ; ��ʾ״̬
    Tip(Msg)
}

BGMUp(ISAV)
{
    Global SwitchMode
    ; ��ȡ����
    VA_ISimpleAudioVolume_GetMasterVolume(ISAV, vol)
    if (vol < 1)
    {
        delta := SwitchMode=="˲" ? 1 : 0.2
        vol := (vol+delta>1) ? 1 : (vol+delta)
        VA_ISimpleAudioVolume_SetMasterVolume(ISAV, vol)
        Msg := "BGM ������" . Round(vol*100) . "%"
    }
    ; ��ʾ״̬
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

    ; ��ȡĬ�ϲ����豸�ĻỰ������ GetDefaultAudioEndpoint
    if !DAE := VA_GetDevice()
    {
        return
    }

    ; ����Ự������2�ӿ� activate the session manager
    VA_IMMDevice_Activate(DAE, IID_IASM2, 0, 0, IASM2)
    ; ��ȡ�Ựö���� enumerate sessions for on this device
    VA_IAudioSessionManager2_GetSessionEnumerator(IASM2, IASE)
    ; ��ȡ�Ự����
    VA_IAudioSessionEnumerator_GetCount(IASE, Count)

    BGM_ISAV := 0

    ; ����������Ƶ�Ự
    Loop % Count
    {
        ; ��ȡ�Ự���ƽӿ� Get the IAudioSessionControl object
        VA_IAudioSessionEnumerator_GetSession(IASE, A_Index-1, IASC)
        ; Query the IAudioSessionControl for an IAudioSessionControl2 object
        IASC2 := ComObjQuery(IASC, IID_IASC2)
        ; ��ȡ����ID Get the session's process ID
        VA_IAudioSessionControl2_GetProcessID(IASC2, SPID)
        if (SPID) ; ����û�� PID �� Session
        {
            ; ��ȡ ISimpleAudioVolume obj
            ISAV := ComObjQuery(IASC2, IID_ISAV)
            ; ��ȡ�Ự״̬
            VA_IAudioSessionControl_GetState(IASC, state) ; 0=Inactive, 1=Active, 2=Expired
            if (WinExist(BGMWinTitle . " ahk_pid " . SPID)) ; ��� BGM ����
            {
                BGM_Active := (state == 1)
                BGM_ISAV := ISAV ; ���� BGM ���� ISAV
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

    ; ������Դ
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

