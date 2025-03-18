; CodePage=GB2312
#SingleInstance

#Include VA.ahk

DetectHiddenWindows, On

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
    IniWrite, `; BGM �����ļ�����ʾ����BGMExe=MusicPlayer.exe`nBGMExe=`n`; BGM �����л�ģʽ: ˲ - �����л��������� - ������������`nSwitchMode=˲`n; �Զ���ʼ��� [0|1]`nAutoStart=0, %IniFile%, %AppName%
}

; ��ȡ�����ļ�
IniRead, BGMExe, %IniFile%, %AppName%, BGMExe, %A_Space%  ; ��Ҫ���������� BGM ����
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
    Gosub, OnBtnStart
}

Return

InitGUI()
{
    Global
    Gui, Margin, 10, 10
    Gui, Add, Text, xm ym h20, BGM ����
    Gui, Add, Edit, x+10 yp-3 h20 w300 vEdtBGMWin, %BGMExe%
	Gui, Add, Button, x+ yp h20 gOnBtnPlaying, ��
    Gui, Add, Text, xm y+m h20, �������ڷ�ʽ
    Gui, Add, Radio, x+10 yp-3 h20 Group vRadBGMMode1, ˲
    Gui, Add, Radio, x+10 yp h20 vRadBGMMode2, ��
    Gui, Add, CheckBox, xm y+m h20 vChkAutoStart, �Զ���ʼ���
	Gui, Add, Button, xm y+m h20 vBtnApplyCfg gOnBtnApplyCfg, Ӧ������
	Gui, Add, Button, x+10 yp h20 vBtnStart gOnBtnStart, ��ʼ���
	Gui, Add, Button, x+10 yp h20 Disabled vBtnStop gOnBtnStop, ֹͣ���
	Gui, Add, Button, x+10 yp h20 vBtnReset gOnBtnReset, �ָ�����
	Gui, Add, Button, x+20 yp h20 gOnBtnAbout, ����
    Gui, Add, StatusBar, ,
    SB_SetParts(300)
    Tip("δ���", 2)
    Gui, Show, , %AppName% v%AppVer%
	Gui, +OwnDialogs
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
    If (A_EventInfo == 1) ; ��С����ϵͳ����
        Gosub, GuiEscape
    Return
}
GuiEscape: ; ��С����ϵͳ����
{
    TrayTip, %AppName%, �����ص�ϵͳ���̣�˫���ָ�
    Gui, Hide
    Return
}
GuiClose:
{
    Gosub, OnBtnStop
    ExitApp
    Return
}
OnBtnApplyCfg:
{
    Gui, 1:Submit, NoHide
    BGMExe := EdtBGMWin
    SwitchMode := RadBGMMode1 ? "˲" : "��"
    AutoStart := ChkAutoStart
    IniWrite, %BGMExe%, %IniFile%, %AppName%, BGMExe
    IniWrite, %SwitchMode%, %IniFile%, %AppName%, SwitchMode
    IniWrite, %AutoStart%, %IniFile%, %AppName%, AutoStart
    Tip("��������Ч", 2)
    Return
}    
OnBtnStart:
{
    SetTimer, CheckAudioState, 500
    GuiControl, Disable, BtnStart
    GuiControl, Enable, BtnStop
    Tip("��ʼ��� ...", 2)
    Return
}
OnBtnStop:
{
    Tip("����ֹͣ ...", 2)
    SetTimer, CheckAudioState, Off
    GuiControl, Disable, BtnStop
    Sleep, 1000
    GuiControl, Enable, BtnStart
    Tip("δ���", 2)
    Gosub, OnBtnReset
    Return
}
OnBtnReset:  ; �ָ�BGM������״̬������
{
    ResetVol(BGMExe)
    Return
}

;------------------------------------------------------------------------------
; ���ڲ��Ŵ���
OnBtnPlaying:
{
    Gui, Playing:+Owner1 +ToolWindow
    Gui, Playing:Add, Text, xm ym, * ˫��ѡ�� BGM ����`n* ���ױ�־���壺1: A - active; 2: M - muted; 3: ����`%; 4: PID���̺�
    Gui, Playing:Add, ListBox, xm y+m r10 w500 Sort 0x100 vLstPlaying gOnLstPlaying
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
                pn := GetProcNameByPID(SPID)
                if (pn)
                {
                    ; ��ȡ ISimpleAudioVolume obj
                    ISAV := ComObjQuery(IASC2, IID_ISAV)
                    ; ��ȡ�Ự״̬
                    VA_IAudioSessionControl_GetState(IASC, state) ; 0=Inactive, 1=Active, 2=Expired
                    ; ��ȡ����״̬
                    VA_ISimpleAudioVolume_GetMute(ISAV, muted)
                    VA_ISimpleAudioVolume_GetMasterVolume(ISAV, vol)
                    ObjRelease(ISAV)
                    a := state==1 ? "A" : " "
                    m := muted ? "M" : " "
                    v := Round(vol*100)
                    GuiControl, Playing:, LstPlaying, %a% %m% %v%`% PID=%SPID% : %pn%
                }
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
OnLstPlaying:
{
    If (A_GuiEvent == "DoubleClick")
    {
        Gui, Playing:Submit
        arr := StrSplit(LstPlaying, ":", " `t")
        n := arr.Length()
        If (n)
        {
            exe := arr[n]
            GuiControl, 1:, EdtBGMWin, %exe%
        }
        Gosub, PlayingGuiClose
    }
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

Tip(msg, sb_part:=1)
{
    Global AppName
    Static OldMsg := ""
    if !msg
        return
    if (msg != OldMsg)
    {
        ; TrayTip, %AppName%, %msg%
        SB_SetText(msg, sb_part)
        OldMsg := msg
    }
}

CheckAudioState()
{
    Global IID_IASM2, IID_IASC2, IID_ISAV
    Global BGMExe, SwitchMode

    Tip("����� ...", 2)

    if (!WinExist("ahk_exe " . BGMExe))
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
            VA_ISimpleAudioVolume_GetMute(ISAV, muted)
            VA_ISimpleAudioVolume_GetMasterVolume(ISAV, vol)
            ; if (WinExist(BGMExe . " ahk_pid " . SPID)) ; ��� BGM ����
            if (GetProcNameByPID(SPID) = BGMExe)  ; ���Դ�Сд
            {
                BGM_Active := (state == 1)
                BGM_ISAV := ISAV ; ���� BGM ���� ISAV
            }
            else ; �����������
            {
                ; ��ȡ����״̬
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
        delta := SwitchMode=="˲" ? 1 : 0.2
        ; ��ȡ����
        VA_ISimpleAudioVolume_GetMasterVolume(BGM_ISAV, vol)
        if (OtherPlaying && vol>0)
        {
            vol := (vol-delta<0) ? 0 : (vol-delta)
            VA_ISimpleAudioVolume_SetMasterVolume(BGM_ISAV, vol)
        }
        else if (!OtherPlaying && vol<1)
        {
            vol := (vol+delta>1) ? 1 : (vol+delta)
            VA_ISimpleAudioVolume_SetMasterVolume(BGM_ISAV, vol)
        }
        ; ��ʾ״̬
        Tip("BGM ������" . Round(vol*100) . "%")
    }
    else
    {
        Tip("BGM δ����")
    }

    ; ������Դ
    ObjRelease(BGM_ISAV)
    ObjRelease(IASE)
    ObjRelease(IASM2)
    ObjRelease(DAE)
}

SwitchBGM(ISAV, otherPlaying)
{
    Global SwitchMode
}

; ���ó�����״̬������
ResetVol(exe = "")
{
    Global IID_IASM2, IID_IASC2, IID_ISAV

    ; ��ȡĬ�ϲ����豸�ĻỰ������ GetDefaultAudioEndpoint
    DAE := VA_GetDevice()
    If !DAE
    {
        Tip("�޷���ȡ��Ƶ�豸")
        Return
    }
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
            ; ��ȡ����״̬
            VA_ISimpleAudioVolume_GetMute(ISAV, muted)
            VA_ISimpleAudioVolume_GetMasterVolume(ISAV, vol)
            if (muted || vol != 1)  ; ״̬����
            {
                if (!exe || GetProcNameByPID(SPID) = exe)  ; ���Դ�Сд
                {
                    VA_ISimpleAudioVolume_SetMute(ISAV, 0)
                    VA_ISimpleAudioVolume_SetMasterVolume(ISAV, 1)
                }
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

    Return
}

GetProcNameByPID(pid)
{
    procName := ""
    WMI := ComObjGet("winmgmts:")
    queryEnum := WMI.ExecQuery("Select * from Win32_Process where ProcessId=" . pid)._NewEnum()
    if queryEnum[proc]
    {
        procName := proc.Name
    }
    WMI := queryEnum := proc := ""
    Return procName
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

