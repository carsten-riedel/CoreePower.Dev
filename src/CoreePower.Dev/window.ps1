Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    public class Window {

    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool AttachConsole(uint dwProcessId);

    [DllImport("kernel32.dll")]
    public static extern bool FreeConsole();

    [DllImport("user32.dll")]
    public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);

    [DllImport("user32.dll")]
    public static extern bool BringWindowToTop(IntPtr hWnd);

    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);

    [DllImport("user32.dll")]
    public static extern bool AllowSetForegroundWindow(int dwProcessId);

    [DllImport("user32.dll")]
    public static extern bool LockSetForegroundWindow(uint uLockCode);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern IntPtr GetStdHandle(int nStdHandle);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool GetCurrentConsoleFontEx(
        IntPtr hConsoleOutput,
        bool bMaximumWindow,
        ref CONSOLE_FONT_INFO_EX lpConsoleCurrentFontEx);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool SetCurrentConsoleFontEx(
        IntPtr hConsoleOutput,
        bool bMaximumWindow,
        ref CONSOLE_FONT_INFO_EX lpConsoleCurrentFontEx);
    
    }
  
    [StructLayout(LayoutKind.Sequential)]
    public struct COORD
    {
        public short X;
        public short Y;

        public COORD(short x, short y)
        {
            X = x;
            Y = y;
        }
    }

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    public struct CONSOLE_FONT_INFO_EX
    {
        public uint cbSize;
        public uint nFont;
        public COORD dwFontSize;
        public int FontFamily;
        public int FontWeight;

        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)]
        public string FaceName;
    }




    public struct RECT

    {

    public int Left;        // x position of upper-left corner

    public int Top;         // y position of upper-left corner

    public int Right;       // x position of lower-right corner

    public int Bottom;      // y position of lower-right corner

    }

"@

$app = Start-Process powershell.exe -passthru

Start-Sleep 4

#[Window]::AttachConsole($app.Id)

[Window]::LockSetForegroundWindow(2)

[Window]::AllowSetForegroundWindow(-1*$PID)

$Handle = (Get-Process -Name PowerShell).MainWindowHandle

$Rectangle = New-Object RECT

[Window]::GetWindowRect($Handle,[ref]$Rectangle)
$Rectangle

[Window]::MoveWindow($Handle, 100, 100, 300,300, $true)
[Window]::BringWindowToTop($Handle)
[Window]::SetForegroundWindow($Handle)

$cfi = New-Object CONSOLE_FONT_INFO_EX
$cfi.cbSize = [Runtime.InteropServices.Marshal]::SizeOf($cfi)
[Window]::GetCurrentConsoleFontEx([Window]::GetStdHandle(-11), $false, [ref]$cfi)
$cfi

$cfi.FaceName = "Courier New"
#$cfi.dwFontSize.Y = 8
[Window]::SetCurrentConsoleFontEx([Window]::GetStdHandle(-11), $false, [ref]$cfi)


#[Window]::FreeConsole()
$X=1