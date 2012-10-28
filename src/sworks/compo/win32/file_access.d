module sworks.compo.win32.file_access;

import std.exception, std.file, std.conv, std.array, std.path;
import sworks.compo.util.strutil;
import sworks.compo.win32.util;
pragma(lib,"comdlg32");
alias sworks.compo.util.strutil.toUTF16 toUTF16;

/*
 * ファイル操作関連のラッパ
 */
class FileAccess
{
	OPENFILENAME ofn;
	alias ofn this;

	HWND hWnd;
	wstring[] filter;

	this( HWND hWnd, wstring[] filter... )
	{
		this.hWnd = hWnd;
		filter ~= [ ""w, ""w ];
		this.filter = filter;
		with( ofn )
		{
			lStructSize = OPENFILENAME.sizeof;
			hwndOwner = hWnd;
			lpstrFilter = join( filter, "\0"w ).ptr;
			lpstrFile = null;
			nMaxFile = 0;
			nFilterIndex = 1;
			lpstrFileTitle = null;
			nMaxFileTitle = 0;
			lpstrInitialDir = null;
			Flags = 0;
			lpstrTitle = null;
		}
	}

	wstring[] getOpenFilename( const(wchar)* title, uint flag )
	{
		wchar[ MAX_PATH * 16 ] szFile;
		szFile[] = '\0';

		with( ofn )
		{
			lpstrFile = szFile.ptr;
			nMaxFile = szFile.length;
			Flags = flag;
			lpstrTitle = title;
		}
		enforce( SUCCEEDED( GetOpenFileName(&ofn) ), "failure in GetOpenFileName().");
		wstring[] result;
		size_t count = 0;
		for( size_t i=0 ; ; ++i )
		{
			if( szFile[i] == '\0' )
			{
				++count;
				if( szFile[i+1] == '\0' ) break;
			}
		}
		result = new wstring[count];
		for( size_t i=0, j=0, c=0 ; ; ++i )
		{
			if( szFile[i] == '\0' )
			{
				if( j < i )
				{
					if( 0 < c ) result[c] = result[0] ~ "\\" ~ to!wstring( szFile[ j .. i ] );
					else result[c] = to!wstring(szFile[ j .. i ]);
				}
				++c;
				j = i+1;
				if( szFile[j] == '\0' ) break;
			}
		}
		if( 1 < result.length ) result = result[ 1 .. $ ];

		return result;
	}

	wstring getSaveFilename( const(wchar)* title, uint flag )
	{
		wchar[MAX_PATH] szFile;
		szFile[] = '\0';

		with( ofn )
		{
			lpstrFile = szFile.ptr;
			nMaxFile = szFile.length;
			Flags = flag;
			lpstrTitle = title;
		}
		enforce( SUCCEEDED( GetSaveFileName(&ofn) ), "failure in GetOpenFileName().");
		wstring result = toUTF16( ofn.lpstrFile );
		if( 0 < result.length && extension( result ).empty && (ofn.nFilterIndex - 1) * 2 + 1 < filter.length )
		{
			wstring ext = extension( filter[ ( ofn.nFilterIndex - 1 ) * 2 + 1 ] );
			if( ext != ".*" ) result = setExtension( result, ext );
		}

		return result;
	}

/*
	wstring readFile( string filename )
	{
		string str = readText(filename);
		return to!wstring(str);
	}

	void writeFile( string filename, cost(wchar)[] contents )
	{
		write( filename, to!string(contents) );
	}
*/
}

debug(file_access)
{
	import sworks.compo.win32.static_window;
	class Test
	{ static:
		mixin StaticWindowMix!();

		void start()
		{
			wndclass.regist;
			create(0, "Test"w, WS_OVERLAPPEDWINDOW | WS_VISIBLE );

			FileAccess.ready(handle);
			wstring str = FileAccess.getSaveFilename();
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
