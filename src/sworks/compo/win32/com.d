module sworks.compo.win32.com;

public import std.conv, std.traits;
public import sworks.compo.win32.port;
public import win32.uuid;
pragma( lib, "uuid.lib" );

/*############################################################################*\
##                                 Constants                                  ##
\*############################################################################*/

/*############################################################################*\
##                                 Functions                                  ##
\*############################################################################*/
//------------------------------------------------------------------------------
// Header : WinBase.h
// Library : Kernel32.lib
// DLL : Kernel32.dll
extern(System)
{
	export LONG InterlockedIncrement( LPLONG );
	export LONG InterlockedDecrement( LPLONG );
}

/*############################################################################*\
##                                 Templates                                  ##
\*############################################################################*/
//------------------------------------------------------------------------------
// Forked from std.c.windows.com.ComObject;
template ComObjectMix( )
{
    //----------------------------------------------------------------------
	private alias InterfacesTuple!( typeof(this) ) _InterfacesList;

    //----------------------------------------------------------------------
	static private string _IIDListMix()
	{
		string mix;
		mix = "static private const(IID)[" ~ to!string(_InterfacesList.length) ~ "] _IIDList = [ ";
		foreach( i, I ; _InterfacesList )
		{
			mix ~= "IID_" ~ I.stringof ~ ",";
		}
		if( 0 < _InterfacesList.length ) mix = mix[ 0 .. $-1 ];
		mix ~= "];";

		return mix;
	}
	mixin( _IIDListMix() );

    //\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\

    //----------------------------------------------------------------------
	private LONG _refCount = 0;             // object reference count

    //----------------------------------------------------------------------
	public extern(System) HRESULT QueryInterface( const(IID)* riid, void** ppv)
	{
		size_t i;
		for( i = 0 ; i < _IIDList.length ; i++ ) if( _IIDList[i] == *riid ){ break; }

		foreach( j, I ; _InterfacesList )
		{
			if( j == i )
			{
				(*ppv) = cast(void*)cast( I )this;
				AddRef();
				return S_OK;
			}
		}

		(*ppv) = null;
		return E_NOINTERFACE;
	}

    //----------------------------------------------------------------------
	public extern(System) ULONG AddRef()
	{
		return InterlockedIncrement(&_refCount);
	}

    //----------------------------------------------------------------------
	public extern(System) ULONG Release()
	{
		LONG lRef = InterlockedDecrement(&_refCount);
		if (lRef == 0)
		{
			// free object

			// If we delete this object, then the postinvariant called upon
			// return from Release() will fail.
			// Just let the GC reap it.
			//delete this;

			return 0;
		}
		return cast(ULONG)lRef;
	}

}
