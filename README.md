# SmartBGM

## 功能

有其他程序播放声音时，自动将 BGM 程序的声音关闭，播放结束后自动恢复 BGM 音量。

* 只是调整 BGM 音量至 0% 或 100%，不会停止 BGM 播放。

* 调节的是 Windows 系统“音量合成器”中 BGM 程序对应的音量设置，而不是 BGM 程序自身提供的音量设置。

## 使用说明

* 【注意】由于 SmartBGM 通过系统的音频会话来调节音量，BGM 程序必须在音频会话中存在才能调节，因此最好 **先关闭 SmartBGM 再关闭 BGM 程序**，或者 **保持 SmartBGM 始终运行**。

* 参数设置说明

  - `BMG 程序`

    有两种方式设置：

    1. 直接在“BGM 程序”输入框中输入 BGM 程序 exe 文件名

    2. 先启动 BGM 程序并播放，然后点击“BGM 程序”输入框右侧的“…”，会列出当前所有音频会话进程，双击选择 BGM 程序

  - `音量调节方式`

    调节 BGM 程序音量的方式。

    `瞬` - 直接调节音量至 0% 或者 100%

    `渐` - 以 20% 的幅度逐渐调节音量至 0% 或者 100%

  - `自动开始监控`

    勾选后，SmartBGM 启动后会自动按照设置参数开始监控。

* `应用设置`

  使设置参数生效，并保存到配置文件。

* `开始监控`

  开始监控系统播放声音的程序，自动调节 BGM 程序音量。

* `停止监控`

  停止监控，并恢复 BGM 程序音量。

* `恢复音量`

  恢复 BGM 程序音量。一般用不到，SmartBGM 会控制 BGM 程序音量，当 BGM 音量异常时才会用到。

* 最小化窗口或按 `Esc` 键会将 SmartBGM 缩小到系统托盘，双击系统托盘图标恢复。

## FAQ

### 只有 BGM 程序在播放，却没有声音

可能有多种原因：

1. 有其他程序在播放声音，但是它的音量比较低甚至为 0，或者就是在播放一段无声的音频，SmartBGM 还是会认为它在播放，因此会关闭 BGM 音量

    【解决方法】停止其他程序播放。

2. 其他程序已停止播放声音，但是未正常设置自己的音频会话状态，SmartBGM 还是会认为它在播放，因此会关闭 BGM 音量

    【解决方法】点击“BGM 程序”输入框右侧的“…”，会列出当前所有音频会话进程，看是否有其他程序的状态是“A”且音量大于 0%，如果有，关闭该程序。

3. BGM 程序被静音，或者音量设为 0%

   可能导致这种情况的操作：BGM 程序声音被 SmartBGM 关闭时（有其他程序在播放），先直接关闭 BGM 程序，然后“停止监控”或者关闭 SmartBGM，再次运行 BGM 程序时音量不会恢复。

    【解决方法】BGM 程序保持播放，运行 SmartBGM，点击“恢复音量”。

【终极解决方法】

0. BGM 程序保持播放；
1. 关闭 SmartBGM；
2. 右键点击 Windows 右下托盘里的“音量”小喇叭，选择弹出菜单中的“打开音量合成器”；
3. 在音量合成器中调整 BGM 程序对应的静音状态和音量。
