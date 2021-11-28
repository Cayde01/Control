Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
& {$P = $env:TEMP + '\chromeremotedesktophost.msi'; Invoke-WebRequest 'https://dl.google.com/edgedl/chrome-remote-desktop/chromeremotedesktophost.msi' -OutFile $P; Start-Process $P -Wait; Remove-Item $P}

New-Item -ItemType "directory" -Force -Path "c:\down"
New-Item -ItemType "directory" -Force -Path "c:\rclone"
New-Item -ItemType "directory" -Force -Path "c:\TOOLS2"
New-Item -ItemType "directory" -Force -Path "C:\TOOLS2\RUN\"
New-Item -ItemType "directory" -Force -Path "C:\install\"
New-Item -ItemType "directory" -Force -Path "C:\qbit\"


$Url = 'https://35393-59932.77.prepaid-webspace.de/BOXER/Controller.zip' 
$ZipFile = 'C:\down\' + $(Split-Path -Path $Url -Leaf) 
$Destination= 'C:\TOOLS2\' 
 
Invoke-WebRequest -Uri $Url -OutFile $ZipFile 
 
$ExtractShell = New-Object -ComObject Shell.Application 
$Files = $ExtractShell.Namespace($ZipFile).Items() 
$ExtractShell.NameSpace($Destination).CopyHere($Files) 


New-Item -ItemType "directory" -Force -Path "C:\Users\runneradmin\AppData\Roaming\GHISLER"
Copy-Item "C:\TOOLS2\WINCMD.INI" -Destination "C:\Users\runneradmin\AppData\Roaming\GHISLER"
Copy-Item "C:\TOOLS2\wcx_ftp.ini" -Destination "C:\Users\runneradmin\AppData\Roaming\GHISLER"
<# Copy-Item -Path "C:\TOOLS2\rclone\*" -Destination "C:\rclone\" -Recurse  #>

Invoke-WebRequest -Uri "https://35393-59932.77.prepaid-webspace.de/BOXER/boxer.zip" -OutFile C:\TOOLS2\boxer.zip
Expand-Archive -LiteralPath 'C:\TOOLS2\boxer.zip' -DestinationPath C:\TOOLS2\RUN\
Invoke-WebRequest -Uri "https://35393-59932.77.prepaid-webspace.de/BOXER/RDP-OPS/rclone/qBit.zip" -OutFile C:\TOOLS2\qbit.zip
Expand-Archive -LiteralPath 'C:\TOOLS2\qbit.zip' -DestinationPath C:\qbit\

Invoke-WebRequest -Uri "https://35393-59932.77.prepaid-webspace.de/BOXER/RDP-OPS/rclone/rclone.exe" -OutFile C:\rclone\rclone.exe
Invoke-WebRequest -Uri "https://35393-59932.77.prepaid-webspace.de/BOXER/RDP-OPS/rclone/rclone.conf" -OutFile C:\rclone\rclone.conf
Invoke-WebRequest -Uri "https://35393-59932.77.prepaid-webspace.de/BOXER/RDP-OPS/rclone/mount.bat" -OutFile C:\rclone\mount.bat
invoke-WebRequest -Uri "https://35393-59932.77.prepaid-webspace.de/BOXER/RDP-OPS/rclone/winfsp.msi" -OutFile C:\install\winfsp.msi



Function Set-ScreenResolution { 

<# 
    .Synopsis 
        Sets the Screen Resolution of the primary monitor 
    .Description 
        Uses Pinvoke and ChangeDisplaySettings Win32API to make the change 
    .Example 
        Set-ScreenResolution -Width 1024 -Height 768         
    #> 
param ( 
[Parameter(Mandatory=$true, 
           Position = 0)] 
[int] 
$Width, 

[Parameter(Mandatory=$true, 
           Position = 1)] 
[int] 
$Height 
) 

$pinvokeCode = @" 
using System; 
using System.Runtime.InteropServices; 
namespace Resolution 
{ 
    [StructLayout(LayoutKind.Sequential)] 
    public struct DEVMODE1 
    { 
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)] 
        public string dmDeviceName; 
        public short dmSpecVersion; 
        public short dmDriverVersion; 
        public short dmSize; 
        public short dmDriverExtra; 
        public int dmFields; 
        public short dmOrientation; 
        public short dmPaperSize; 
        public short dmPaperLength; 
        public short dmPaperWidth; 
        public short dmScale; 
        public short dmCopies; 
        public short dmDefaultSource; 
        public short dmPrintQuality; 
        public short dmColor; 
        public short dmDuplex; 
        public short dmYResolution; 
        public short dmTTOption; 
        public short dmCollate; 
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)] 
        public string dmFormName; 
        public short dmLogPixels; 
        public short dmBitsPerPel; 
        public int dmPelsWidth; 
        public int dmPelsHeight; 
        public int dmDisplayFlags; 
        public int dmDisplayFrequency; 
        public int dmICMMethod; 
        public int dmICMIntent; 
        public int dmMediaType; 
        public int dmDitherType; 
        public int dmReserved1; 
        public int dmReserved2; 
        public int dmPanningWidth; 
        public int dmPanningHeight; 
    }; 
    class User_32 
    { 
        [DllImport("user32.dll")] 
        public static extern int EnumDisplaySettings(string deviceName, int modeNum, ref DEVMODE1 devMode); 
        [DllImport("user32.dll")] 
        public static extern int ChangeDisplaySettings(ref DEVMODE1 devMode, int flags); 
        public const int ENUM_CURRENT_SETTINGS = -1; 
        public const int CDS_UPDATEREGISTRY = 0x01; 
        public const int CDS_TEST = 0x02; 
        public const int DISP_CHANGE_SUCCESSFUL = 0; 
        public const int DISP_CHANGE_RESTART = 1; 
        public const int DISP_CHANGE_FAILED = -1; 
    } 
    public class PrmaryScreenResolution 
    { 
        static public string ChangeResolution(int width, int height) 
        { 
            DEVMODE1 dm = GetDevMode1(); 
            if (0 != User_32.EnumDisplaySettings(null, User_32.ENUM_CURRENT_SETTINGS, ref dm)) 
            { 
                dm.dmPelsWidth = width; 
                dm.dmPelsHeight = height; 
                int iRet = User_32.ChangeDisplaySettings(ref dm, User_32.CDS_TEST); 
                if (iRet == User_32.DISP_CHANGE_FAILED) 
                { 
                    return "Unable To Process Your Request. Sorry For This Inconvenience."; 
                } 
                else 
                { 
                    iRet = User_32.ChangeDisplaySettings(ref dm, User_32.CDS_UPDATEREGISTRY); 
                    switch (iRet) 
                    { 
                        case User_32.DISP_CHANGE_SUCCESSFUL: 
                            { 
                                return "Success"; 
                            } 
                        case User_32.DISP_CHANGE_RESTART: 
                            { 
                                return "You Need To Reboot For The Change To Happen.\n If You Feel Any Problem After Rebooting Your Machine\nThen Try To Change Resolution In Safe Mode."; 
                            } 
                        default: 
                            { 
                                return "Failed To Change The Resolution"; 
                            } 
                    } 
                } 
            } 
            else 
            { 
                return "Failed To Change The Resolution."; 
            } 
        } 
        private static DEVMODE1 GetDevMode1() 
        { 
            DEVMODE1 dm = new DEVMODE1(); 
            dm.dmDeviceName = new String(new char[32]); 
            dm.dmFormName = new String(new char[32]); 
            dm.dmSize = (short)Marshal.SizeOf(dm); 
            return dm; 
        } 
    } 
} 
"@ 

Add-Type $pinvokeCode -ErrorAction SilentlyContinue 
[Resolution.PrmaryScreenResolution]::ChangeResolution($width,$height) 
} 

Set-ScreenResolution -Width 1920 -Height 1080

Start-Process -FilePath "C:\TOOLS2\Total CMA Pack\TOTALCMD.exe"
Start-Process C:\rclone\mount.bat
Start-Process -FilePath "C:\qbit\qBittorrentPortable.exe"
