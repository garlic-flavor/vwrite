/** util.d for padm.exe
 * \version      0.0005 dmd2.055
 * \date         2011-Sep-21 02:47:54
 * \author       KUMA
 * \par license:
 * CC0
 */
module sworks.compo.win32.util;
public import std.conv, std.exception, std.traits, std.utf;
public import sworks.compo.util.strutil;
public import sworks.compo.util.strz;
public import sworks.compo.win32.port;
alias sworks.compo.util.strutil.toUTF16 toUTF16;

/*############################################################################*\
|*#                                Functions                                 #*|
\*############################################################################*/
//------------------------------------------------------------------------------
int okbox( const(wchar)[] message, const(wchar)[] caption = null, uint type = MB_OK)
{
  return MessageBox( null, message.toUTF16z, caption.toUTF16z, type);
}

//------------------------------------------------------------------------------
T enforceW(T, U = wstring )(T val, lazy U str = null)
{
  if(!val) { throw new WinException(str); }
  return val;
}

//------------------------------------------------------------------------------
int ensuccess( T = wstring ) (int val, lazy T str = null)
{
  if(FAILED(val)) { throw new WinException(str); }
  return val;
}

//----------------------------------------------------------------------
void release(T)(ref T obj)
{
	if( obj !is null )
	{
		obj.Release();
		obj = null;
	}
}

/*############################################################################*\
|*#                                 Classes                                  #*|
\*############################################################################*/
/*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*\
|*|                               WinException                               |*|
\*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*/
class WinException : Exception
{
    //----------------------------------------------------------------------
	static private wstring getError()
	{
		uint errorCode = GetLastError();
		wchar* msgBuf;
		scope(exit) LocalFree(cast(HANDLE)msgBuf);
		FormatMessage( FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM
		               | FORMAT_MESSAGE_IGNORE_INSERTS | 0xff
		             , null, errorCode, MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT)
		             , cast(LPTSTR)&msgBuf, 0, null);
		return toUTF16( msgBuf );
	}

    //\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\

	Strz error;

    //----------------------------------------------------------------------
	this( T = wstring )( T msg = T.init )
	{
		super("WinException");
		error = new Strz( "System : "w );
		error ~= getError;
		error ~= "\r\n"w;
		error ~= msg;
  }

	const(wchar)[] toStringW() @property { return error[]; }
}
