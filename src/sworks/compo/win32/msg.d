/** msg.d for padm.exe
 * \version      0.0005 dmd2.055
 * \date         2011-Sep-21 02:47:54
 * \author       KUMA
 * \par license:
 * CC0
 */
module sworks.compo.win32.msg;
import std.traits;
public import sworks.compo.win32.port;
public import sworks.compo.win32.windowhandle;
/**
 * メッセージプロシジャでのメッセージの取り回しに。
 *
 * Notice:
 *   対応は32bit のみ。
 **/
class Msg
{
	WindowHandle hWnd;
	uint msg;

	union
	{
		uint wp;
		int swp;
		struct
		{
			ushort lwp;
			ushort hwp;
		}
		struct
		{
			short slwp;
			short shwp;
		}
	}

	union
	{
		int lp;
		uint ulp;
		struct
		{
			ushort llp;
			ushort hlp;
		}
		struct
		{
			short sllp;
			short shlp;
		}
	}

	this( HWND hWnd, uint msg, uint wp, int lp)
	{
		this.hWnd = hWnd;
		this.msg = msg;
		this.wp = wp;
		this.lp = lp;
	}

	int defProc(){return DefWindowProc( hWnd, msg, wp, lp );}

	T* pwp(T)() @property { return cast(T*)wp; }
	T* plp(T)() @property { return cast(T*)lp; }
}

template IsMsgHandler( T )
{
	static if( isCallable!T && is( ReturnType!(T) : int ) && (1==ParameterTypeTuple!T.length)
	         && is( ParameterTypeTuple!T[0] : Msg ) )
		const bool IsMsgHandler = true;
	else
		const bool IsMsgHandler = false;
}
