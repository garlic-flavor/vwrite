module sworks.compo.win32.single_dialog;

public import std.string, std.traits, std.algorithm, std.conv;
public import sworks.compo.win32.util;
public import sworks.compo.win32.wndclass;
public import sworks.compo.win32.windowhandle;
public import sworks.compo.win32.msg;
debug public import std.stdio;

/**
 * ダイアログボックスでのメッセージの取り回しに。
 */
class DialogMsg : Msg
{
	this( WindowHandle handle, uint msg, uint wp, int lp)
	{
		super( handle, msg, wp, lp );
	}
	override int defProc() { return false; }
}

template SingleDialogMix( uint id, alias MEMBER, CASES ... )
{
	alias typeof(this) THIS;
	static const uint ID = id;

	static if( is( MEMBER == enum ) )
	{
		static private string FieldMixStr()
		{
			string[] result;
			foreach( one ; __traits( allMembers, MEMBER ) ) { result ~= one.toLower; }
			if( 0 < result.length )
				return "static WindowHandle " ~ to!string( joiner( result, ", " ) ) ~ ";" ;
			else return "";
		}
		mixin( FieldMixStr() );
	}

	private struct _CP
	{
		THIS instance;
		void* lparam;
	}

	// case WM_PAINT: return typeof(this).wm_paint( msg ); みたいなのを生成
	static private string ProcMixStr()
	{
		string result =
		" assert( _instance !is null || WM_INITDIALOG == msg.msg || WM_SETFONT == msg.msg );
		  switch( uMsg )
		  {
		    case WM_INITDIALOG:
		      assert( _instance is null, \"an instance of \" ~ THIS.stringof
		                                 ~ \" can be made only once.\" );
		      _instance = msg.plp!_CP.instance;
		      assert( _instance !is null );
		      handle = hWnd;
		      msg.lp = cast(int)( msg.plp!_CP.lparam );";

		static if( is( MEMBER == enum ) )
		{
			foreach( one ; __traits( allMembers, MEMBER ) )
			{
				result ~= "_instance." ~ one.toLower ~ " = GetDlgItem( hWnd, "
									~ to!string( cast(int)__traits(getMember, MEMBER, one ) ) ~ ");";
			}
		}
		result ~=
		"      return _instance.wm_initdialog(msg);
		    case WM_NCDESTROY:
		      scope(exit)
		      {";
		static if( is( MEMBER == enum ) )
		{
			foreach( one ; __traits( allMembers, MEMBER ) )
			{
				result ~= "_instance." ~ one.toLower ~ " = null;";
			}
		}
		result ~=
		"       handle = null;
		        _instance = null;
		      }
		      return _instance.wm_ncdestroy( msg );";

		foreach( one ; CASES)
		{
			static if     ( is( typeof(one) : uint ) )
				result ~= "case " ~ to!string(one) ~ " : ";
			else static if( is( typeof(one) : string) && "wm_initdialog"!=one && "wm_ncdestroy"!=one )
			{
				result ~= "return _instance." ~ one ~ "(msg);";
			}
			else static assert(0, to!string(one) ~ " is not correct argument for SingleDialogMix." );
		}

		foreach( one ; __traits(derivedMembers, typeof(this)) )
		{
			static if( one.startsWith( "wm_" ) && "wm_initdialog"!=one && "wm_ncdestroy"!=one )
			{
				static assert( IsMsgHandler!( typeof( __traits(getMember, THIS, one ) ) ) );
				result ~= "case " ~ one.toUpper ~ " : return _instance." ~ one ~"(msg);";
			}
		}
		result ~= "default: }";
		return result;
	}

	static public WindowHandle handle;
	alias handle this;

	extern(Windows) static public int MsgCracker( HWND hWnd, uint uMsg, uint wp, int lp)
	{
		scope auto msg = new DialogMsg( WindowHandle( hWnd ), uMsg, wp, lp );
		static THIS _instance;
		try{ mixin(ProcMixStr); }
		catch( WinException we ) .okbox( we.error[] );
		catch( Throwable t ) .okbox( (new WinException(t.toString)).error[] );
		return false;
	}

	/// when wm_create is called, the handle is ready.
	int wm_initdialog(Msg)  { return false; }
	int wm_ncdestroy(Msg) { return false; }
	/// when wm_destroy is end, the handle is disable.
}

/**
 * モーダルダイアログボックスを作成
 * ID はリソース上でのダイアログボックスのID
 * MEMBER は
 * enum { ID = 1000, BUTTON_1 = 1001, COMBO_1 = 1002, ... }
 * 見たいな感じのもの。
 * これで、
 * WindowHandle button_1, combo_1, ...
 * などのメンバが利用可能になる。
 */
template SingleModalDialogMix( uint id, alias MEMBER, CASES ... )
{ mixin SingleDialogMix!( id, MEMBER, CASES );

	int create( HWND hParent, void* param = null, HINSTANCE hInst = null )
	{
		auto cp = _CP( this, param );
		if( hInst is null ) hInst = GetModuleHandle( null );
		return DialogBoxParam( hInst, MAKEINTRESOURCE( ID ), hParent
		               , cast( DLGPROC ) &MsgCracker, cast(int)&cp );
	}
	void end( size_t nResult = IDOK ) { EndDialog( handle, nResult ); }
}


/**
 * モードレスダイアログボックスを作成
 * ID はリソース上でのダイアログボックスのID
 * MEMBER は
 * enum { ID = 1000, BUTTON_1 = 1001, COMBO_1 = 1002, ... }
 * 見たいな感じのもの。
 * これで、
 * WindowHandle button_1, combo_1, ...
 * などのメンバが利用可能になる。
 */
template SingleModelessDialogMix( uint id, alias MEMBER, CASES ... )
{ mixin SingleDialogMix!( id, MEMBER, CASES );

	HWND create( HWND hParent, void* param = null, HINSTANCE hInst = null )
	{
		auto cp = _CP( this, param );
		if( hInst is null ) hInst = GetModuleHandle( null );
		return CreateDialogParam( hInst, MAKEINTRESOURCE( ID ), hParent, &MsgCracker, cast(int)&cp );
	}
}