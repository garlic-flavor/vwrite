/** windowhandle.d
 * \version      0.0005 dmd2.055
 * \date         2011-Sep-21 02:47:54
 * \author       KUMA
 * \par license:
 * CC0
 */
module sworks.compo.win32.windowhandle;
private import sworks.compo.util.strutil;
public import sworks.compo.util.readz;
private import sworks.compo.win32.util;
private import sworks.compo.win32.msg;
alias sworks.compo.util.strutil.toUTF16 toUTF16;

/**
 * HWND の suger
 */
struct WindowHandle
{
	public HWND _hWnd;
	alias _hWnd this;

    //----------------------------------------------------------------------
    // properties
	int text( const(wchar)* str) @property
	{
		return SendMessage( _hWnd, WM_SETTEXT, 0, cast(int)(cast(void*)str) );
	}

	Readz text() @property
	{
		scope wchar[] buf = new wchar[ SendMessage( _hWnd, WM_GETTEXTLENGTH, 0, 0 ) + 1 ];
		SendMessage( _hWnd, WM_GETTEXT, buf.length, cast(int)(cast(void*)(buf.ptr)) );
		return Readz( cast(immutable(wchar)*)buf.ptr, buf.length - 1 );
	}

    //
	int userdata() @property { return GetWindowLong( _hWnd, GWL_USERDATA ); }

	void userdata( int i ) @property { SetWindowLong( _hWnd, GWL_USERDATA, i ); }


    //----------------------------------------------------------------------
	int okbox( const(wchar)[] message, const(wchar)[] caption = "notice"w, uint type = MB_OK )
	{
		return MessageBoxW( _hWnd, message.toUTF16z, caption.toUTF16z, type );
	}

    //----------------------------------------------------------------------
	int send( uint msg,uint wp = 0,int lp=0) { return SendMessage( _hWnd, msg, wp, lp );}
	int send( Msg msg) { return SendMessage( _hWnd, msg.msg, msg.wp, msg.lp ); }
	int post( uint msg, uint wp = 0, int lp = 0 ) { return PostMessage( _hWnd, msg, wp, lp ); }
	int post( Msg msg) { return PostMessage( _hWnd, msg.msg, msg.wp, msg.lp ); }

    //----------------------------------------------------------------------
	int move( int x, int y, int w, int h, bool repaint = false )
	{
		return MoveWindow( _hWnd, x, y, w, h, repaint );
	}

	int move( int x, int y, bool repaint = false )
	{
		return SetWindowPos( _hWnd, null, x, y, 0, 0
											 ,(repaint?SWP_DEFERERASE:SWP_NOREDRAW) | SWP_NOSIZE | SWP_NOZORDER);
	}

	int resize( int w, int h, bool repaint = false )
	{
		return SetWindowPos( _hWnd, null, 0, 0, w, h
											 , (repaint?SWP_DEFERERASE:SWP_NOREDRAW) | SWP_NOMOVE | SWP_NOZORDER );
	}

	void setClientSize( int width,int height,bool repaint=true)
	{
		RECT crc;
		GetClientRect( _hWnd, &crc );
		int dx = width-crc.right;
		int dy = height-crc.bottom;
		RECT wrc;
		GetWindowRect( _hWnd, &wrc );
		MoveWindow( _hWnd, wrc.left, wrc.top, wrc.right-wrc.left+dx, wrc.bottom-wrc.top+dy, repaint );
	}

    //----------------------------------------------------------------------
	uint redraw( RECT* rect = null, bool IsErase = false)
	{
		return InvalidateRect( _hWnd, rect, IsErase );
	}


    //----------------------------------------------------------------------
	int close() { return PostMessage( _hWnd, WM_CLOSE, 0, 0 ); }

	int Release() { scope( exit ) _hWnd = null;  return DestroyWindow( _hWnd ); }
}

RECT getChildRect( HWND parent, HWND child )
{
	RECT rc;
	GetWindowRect( child, &rc );
	ScreenToClient( parent, cast(POINT*) &(rc.left) );
	ScreenToClient( parent, cast(POINT*) &(rc.right) );
	return rc;
}

/**
 * 単なるエジットボックスとか、ボタンとかプロシジャ使わないような簡易なウィンドウ用
 */
HWND Create( const(wchar)* class_name, uint style, uint exStyle, HWND parent = null, const(wchar)* title = null
           , int x = CW_USEDEFAULT, int y = CW_USEDEFAULT, int w = CW_USEDEFAULT, int h = CW_USEDEFAULT
           , HMENU menu = null, HINSTANCE hInst = null )
{
	if( hInst is null ) hInst = GetModuleHandle( null );
	return enforceW( CreateWindowEx(exStyle, class_name, title, style, x, y, w, h, parent, menu, hInst, null )
	               , "fail at CreateWindowEx( "w~ toUTF16(class_name) ~")."w );
}
