module sworks.compo.win32.clipboard;

import std.exception;
import sworks.compo.win32.util;

/*
 * WindowsAPI クリップボードまわりのラッパ
 */
class Clipboard
{ static:
	HWND hWnd;

	void ready( HWND hWnd )
	{
		Clipboard.hWnd = hWnd;
	}
	
	void write( const(wchar)[] str )
	{
		HGLOBAL hGlobal;
		int iLength;
		wchar* lpstr;

		if( str.length > 1024 ) str.length = 1024;
		hGlobal = enforce( GlobalAlloc( GHND, wstring.sizeof*(str.length+1) )
		                 , "failed at GlobalAlloc()." );
		scope(failure) GlobalFree(hGlobal);
		lpstr = cast(wchar*)enforce(GlobalLock(hGlobal), "failed at GlobalLock()." );
		lpstr[0..str.length] = str;
		GlobalUnlock(hGlobal);

		enforce( OpenClipboard( hWnd ), "failed at OpenClipboard()." );
		scope(exit) CloseClipboard();
		EmptyClipboard();
		SetClipboardData( CF_UNICODETEXT, hGlobal );
	}

	wchar[] read()
	{
		HGLOBAL hGlobal;
		wchar* lpstr;
		
		if( !IsClipboardFormatAvailable( CF_UNICODETEXT ) ) return null;

		OpenClipboard( hWnd );
		scope(exit) CloseClipboard();
		hGlobal = cast( HGLOBAL )enforce( GetClipboardData( CF_UNICODETEXT )
		                                , "failed at GetClipboardData()." );
		lpstr = cast(wchar*) enforce( GlobalLock(hGlobal), "failed at GlobalLock()." );
		scope(exit)GlobalUnlock( hGlobal );
		EmptyClipboard();
		return cast(wchar[])toUTF16(lpstr);
	}

	bool isAvailable()
	{
		return IsClipboardFormatAvailable( CF_UNICODETEXT ) == TRUE ;
	}
}

debug(clipboard)
{
	import sworks.compo.win32.static_window;
	class Test
	{ static:
		mixin StaticWindowMix!();

		void start()
		{
			wndclass.regist;
			create(0, "Test"w, WS_OVERLAPPEDWINDOW | WS_VISIBLE );

			Clipboard.ready(handle );
//			Clipboard.write( "hello world\r\n日本語もOK");
			wstring str = Clipboard.read();
			okbox( str );
		}

		void end()
		{
			if(handle)handle.destroy;
			unregist;
		}

		int wm_destroy( Msg )
		{
			PostQuitMessage(0);
			return 0;
		}
	}

	void main()
	{
		try
		{
			Test.start;
			MSG msg;
			while( GetMessage( &msg, null, 0, 0 ) > 0 ) { DispatchMessage(&msg); }
		}
		catch( Throwable w) okbox(w.toString);
		finally Test.end;
	}
}