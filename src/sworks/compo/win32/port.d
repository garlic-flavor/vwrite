/** port.d for padm.exe
 * \version      0.0005 dmd2.055
 * \date         2011-Sep-21 02:47:54
 * \author       KUMA
 * \par license:
 * CC0
 */
module sworks.compo.win32.port;
/// Win32api porting by http://www.dsource.org/projects/bindings/wiki/WindowsApi
/// win32.lib をリンクして使う。
public import win32.windows;
pragma(lib,"lib\\win32.lib");
pragma(lib,"gdi32.lib");

version(Unicode){}
else {pragma(msg,"port : support only Unicode version."); }

// 定義の追加
enum MOUSEEVENTF_XDOWN = 128;
enum MOUSEEVENTF_XUP = 256;
enum MOUSEEVENTF_HWHEEL = 4096;
enum LLMHF_INJECTED = 0x00000001;
enum XBUTTON1 = 1;
enum XBUTTON2 = 2;
enum WM_MOUSEHWHEEL = 0x020e;

void ZeroMemory( void* Destination, size_t Length )
{
	(cast(byte*)Destination)[0..Length] = 0;
}
