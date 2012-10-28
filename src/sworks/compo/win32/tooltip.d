module sworks.compo.win32.tooltip;

import win32.commctrl;
pragma( lib, "comctl32.lib" );

import sworks.compo.util.readz;
import sworks.compo.win32.util;
import sworks.compo.win32.windowhandle;

/+

struct TOOLINFOW {
	UINT      cbSize = TOOLINFOW.sizeof;
	UINT      uFlags;
	HWND      hwnd;
	UINT      uId;
	RECT      rect;
	HINSTANCE hinst;
	LPWSTR    lpszText;
//	LPARAM    lParam;
//	void*     lpReserved;
}
alias TOOLINFOW TOOLINFO;
enum TTS_BALLOON = 0x40;
enum TTI_INFO = 1;
enum TTF_CENTERTIP = 0x0002;

class ToolInfo
{
	public TOOLINFO ti;
	alias ti this;

	this( HWND owner, uint id, const(Readz) text, RECT rc = RECT() )
	{
		with( ti )
		{
			cbSize = TOOLINFO.sizeof;
			hwnd = owner;
			uFlags = TTF_SUBCLASS | TTF_CENTERTIP ;
			hinst = cast(HMODULE)GetWindowLong( owner, GWL_HINSTANCE );
			uId = id;
			rect = rc;
			lpszText = cast(wchar*)text.ptr;
		}
	}

	TOOLINFO* ptr() @property { return &ti; }
}


class ToolTip : WindowHandle
{
	static ready()
	{
		INITCOMMONCONTROLSEX icc;
		icc.dwSize = INITCOMMONCONTROLSEX.sizeof;
		icc.dwICC = ICC_BAR_CLASSES;
		enforceW( TRUE == InitCommonControlsEx(&icc), "failure in InitCommonControlsEx");
	}

	this( HWND owner )
	{
		super( createWindowHandle( WS_EX_TOPMOST | WS_EX_TOOLWINDOW
		     , Readz(TOOLTIPS_CLASS), Readz(""w.ptr)
		     , WS_POPUP | TTS_ALWAYSTIP /*| TTS_BALLOON*/
		     , CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT
		     , owner, null, cast(HMODULE)GetWindowLong( owner, GWL_HINSTANCE ) ) );
	}

	void active( bool flag ) @property { send( TTM_ACTIVATE, flag ); }
	void width( int w ) @property { send( TTM_SETMAXTIPWIDTH, 0, w ); }

	void add( ToolInfo ti )
	{
		enforceW( TRUE == send( TTM_ADDTOOL, 0, cast(int)ti.ptr )
		        , "ToolTip.add : failure in TTM_ADDTOOL" );
	}

}
+/
