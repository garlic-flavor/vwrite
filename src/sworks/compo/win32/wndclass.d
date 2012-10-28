/** wndclass.d for padm.exe
 * \version      0.0005 dmd2.055
 * \date         2011-Sep-21 02:47:54
 * \author       KUMA
 * \par license:
 * CC0
 */
module sworks.compo.win32.wndclass;
public import std.traits;
private import sworks.compo.win32.util;
private import sworks.compo.util.strutil;
alias sworks.compo.util.strutil.toUTF16 toUTF16;
/**
 * WNDCLASSEX の suger
 */

void ready( ref WNDCLASSEX wc, const(wchar)* class_name, WNDPROC proc, HINSTANCE h = null)
{
	with( wc )
	{
		cbSize = WNDCLASSEX.sizeof;
		style = CS_HREDRAW | CS_VREDRAW | CS_OWNDC;
		lpfnWndProc = proc;
		hInstance = null !is h ? h : GetModuleHandle( null ) ;
		hIcon = LoadIcon(null,IDI_WINLOGO);
		hCursor = LoadCursor(null,IDC_ARROW);
		hbrBackground = GetSysColorBrush(COLOR_APPWORKSPACE);
		lpszClassName =  class_name;
	}
}

public void checkSingle( ref WNDCLASSEX wc )
{
	enforceW( null is FindWindowEx( null, null, wc.lpszClassName, null )
					, "WndClass : "w ~ toUTF16( wc.lpszClassName ) ~ " is already exist." );
}

public void regist( ref WNDCLASSEX wc )
{
	enforceW(RegisterClassEx(&wc), "fail to regist window class: "w ~ toUTF16( wc.lpszClassName ) );
}

public HWND create( ref WNDCLASSEX wc, uint exStyle, const(wchar)* title, uint style
                  , int x = CW_USEDEFAULT, int y = CW_USEDEFAULT, int w = CW_USEDEFAULT, int h = CW_USEDEFAULT
                  , HWND parent = null, HMENU menu = null, HMODULE hInst = null, void* param = null)
{
	if( hInst is null ) hInst = cast(HANDLE)wc.hInstance;
	return enforceW( CreateWindowEx( exStyle, wc.lpszClassName, title, style
	                               , x, y, w, h, parent, menu, hInst, param )
	               , "fail at CreateWindowEx( "w ~ toUTF16(wc.lpszClassName) ~ " )."w );
}

void unregist( ref WNDCLASSEX wc ) { UnregisterClass( wc.lpszClassName, wc.hInstance ); }
