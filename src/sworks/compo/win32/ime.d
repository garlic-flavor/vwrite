module sworks.compo.win32.ime;

import sworks.compo.util.readz;
import sworks.compo.win32.util;
import sworks.compo.win32.windowhandle;
import win32.imm;
pragma( lib, "imm32.lib" );

debug import std.stdio;

/*############################################################################*\
|*#                                 Classes                                  #*|
\*############################################################################*/
/*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*\
|*|                         Wrapper of CANDIDATELIST                         |*|
\*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*/
/*
class CandidateList
{
	CANDIDATELIST* candidate;
	Readz[] list;
}
*/

/*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*\
|*|                               IMM handling                               |*|
\*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*/
class IMM
{
private: ///////////////////////////////////////////////////////////////////////
	HWND handle;
	HKL hkl;

public: ////////////////////////////////////////////////////////////////////////
    //----------------------------------------------------------------------
	this( HWND handle )
	{
		this.handle = handle;
		this.hkl = GetKeyboardLayout( 0 );
	}

    //----------------------------------------------------------------------
	void openConfigureDialog( uint mode, void* data = null )
	{
		ImmConfigureIME( hkl, handle, mode, data );
	}

    //----------------------------------------------------------------------
	void context( scope void delegate( HIMC ) prog )
	{
		static HIMC himc = 0;
		if( 0 == himc )
		{
			himc = enforceW( ImmGetContext( handle ), "failure @ IMM.context.ImmGetContext()." );
			scope( exit ){ enforceW( 0 != ImmReleaseContext( handle, himc )
			                      , "failure @ IMM.context.ImmReleaseContext()." ); himc = 0; }
			prog( himc );
		}
		else prog( himc );
	}

    //----------------------------------------------------------------------
	bool isOpen()
	{
		bool result;
		context( (h){ result = ( 0 != ImmGetOpenStatus(h) ); } );
		return result;
	}

    //----------------------------------------------------------------------
	void toggleIME()
	{
		context( (h){ enforceW( 0 != ImmSetOpenStatus( h, !ImmGetOpenStatus(h) )
		                      , "failure @ IMM.toggleIME.ImmSetOpenStatus()." ); } );
	}
    //
	void open()
	{
		context( (h){ if( !ImmGetOpenStatus(h) ) enforceW( 0 != ImmSetOpenStatus( h, true )
		                                                 , "failure @ IMM.toggleIME.ImmSetOpenStatus()." );} );
	}
    //
	void close()
	{
		context( (h){ if( ImmGetOpenStatus(h) ) enforceW( 0 != ImmSetOpenStatus( h, false )
		                                                , "failure @ IMM.toggleIME.ImmSetOpenStatus()." ); } );
	}

    //----------------------------------------------------------------------
	void setCompositionPos( in POINT p )
	{
		context( (h){
			COMPOSITIONFORM cf;
			with( cf )
			{
				dwStyle = CFS_POINT;
				ptCurrentPos = p;
			}
			ImmSetCompositionWindow( h, &cf );
		} );
	}

    //----------------------------------------------------------------------
	void registerword( in wchar* word, in wchar* read )
	{
		REGISTERWORD rw;
		rw.lpReading = cast(wchar*)read;
		rw.lpWord = cast(wchar*)word;
		ImmConfigureIME( hkl, handle, IME_CONFIG_REGISTERWORD, &rw );
	}

    //----------------------------------------------------------------------
	void getConversionStatus( ref uint c, ref uint s )
	{
		context( (himc){ enforceW( 0 != ImmGetConversionStatus( himc, &c, &s )
		                         , "failure @ IMM.getConversionStatus()" ); } );
	}

    //----------------------------------------------------------------------
	void setConversionStatus( uint c, uint s )
	{
		context( (himc){ enforceW( 0 != ImmSetConversionStatus( himc, c, s )
		                         , "failure @ ImmSetConversionStatus()" ); } );
	}

/+
    //----------------------------------------------------------------------
	Readz getCompositionString( uint index )
	{
		Readz result;
		context( (himc)
		{
			size_t length_in_bytes = ImmGetCompositionString( himc, index, null, 0 );
			wchar[] buf = new wchar[ length_in_bytes + 1 ];
			auto res =  ImmGetCompositionString( himc,index, buf.ptr, buf.length );
			if( IMM_ERROR_NODATA == res ) throw new WinException( "no data" );
			else if( IMM_ERROR_GENERAL == res ) throw new WinException( "error" );
			result = Readz( assumeUnique(buf).ptr, length_in_bytes + 1 );
		} );
		return result;
	}

    //----------------------------------------------------------------------
	CandidateList getCandidateList()
	{
		CandidateList result = new CandidateList();
		context( (himc)
		{
			byte[] buf = new byte[ ImmGetCandidateList( himc, 0, result.candidate, 0 ) ];
			if( 0 == buf.length ) return;
			result.candidate = cast(CANDIDATELIST*)buf.ptr;
			size_t r = ImmGetCandidateList( himc, 0, result.candidate, buf.length );

			result.list = new Readz[ result.candidate.dwCount ];
			for( size_t i = 0 ; i < result.candidate.dwCount ; i++ )
			{
				result.list[i] = Readz( cast(wchar*)( buf.ptr + result.candidate.dwOffset[i] ) );
			}
		});

		return result;
	}
+/
}
