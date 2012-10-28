module sworks.compo.win32.winfi;
import std.conv, std.path, std.string;
public import sworks.compo.win32.util;
public import sworks.compo.win32.gdi;
public import sworks.compo.fi.util;
alias object.string string;
alias win32.wingdi.BITMAPINFO BITMAPINFO;

FIBITMAP* BitmapSetToFIBITMAP( BitmapSet bs )
{
	BITMAP b;
	GetObject( bs.hbmp, BITMAP.sizeof, &b );
	auto fibmp = enforce( FreeImage_AllocateT( FREE_IMAGE_TYPE.FIT_BITMAP, b.bmWidth, b.bmHeight, 24
	                                         , 0xff0000, 0x00ff00, 0x0000ff )
	                    , "saveBitmapSet : failure in FreeImage_AllocateT." );

	enforce( b.bmHeight == GetDIBits( bs, bs.hbmp, 0, b.bmHeight, FreeImage_GetBits( fibmp )
	                                , cast(BITMAPINFO*)FreeImage_GetInfo( fibmp ), DIB_RGB_COLORS )
	       , "saveBitmapSet : failure in GetDIBits." );

	return fibmp;
}

BitmapSet FIBITMAPToBitmapSet( FIBITMAP* fibmp, HDC hdc )
{
	auto w = FreeImage_GetWidth( fibmp );
	auto h = FreeImage_GetHeight( fibmp );
	auto bmp = new BitmapSet( hdc, w, h );
	SetDIBits( bmp, bmp.hbmp, 0, h, FreeImage_GetBits( fibmp ), cast(BITMAPINFO*)FreeImage_GetInfo( fibmp ), 0 );
	return bmp;
}

BitmapSet loadBitmapSet( wstring filename, HDC hdc )
{
	FIBITMAP* fibmp;
	scope( exit ) if( null !is fibmp ) FreeImage_Unload( fibmp );

	auto ext = filename.extension.toLower;
	if( ".jpg" == ext || ".jpeg" == ext )
	{
		fibmp = enforce( FreeImage_LoadU( FREE_IMAGE_FORMAT.FIF_JPEG, filename.toUTFz!(wchar*)
		                                , JPEG_ACCURATE | JPEG_EXIFROTATE )
		               , "getBitmapSet : failure in FreeImage _LoadU." );
	}
	enforce( null !is fibmp, "failure to deduce file type from " ~ to!string(filename) );
	return FIBITMAPToBitmapSet( fibmp, hdc );
}

void saveBitmapSet( wstring filename, BitmapSet bs )
{
	auto fibmp = BitmapSetToFIBITMAP( bs );
	scope( exit ) FreeImage_Unload( fibmp );

	auto ext = filename.extension.toLower;
	if( 0 == ext.length ) { ext = ".jpg"; filename.setExtension( ext ); }

	if( ".jpg" == ext || ".jpeg" == ext )
	{
		enforce( FreeImage_SaveU( FREE_IMAGE_FORMAT.FIF_JPEG, fibmp, filename.toUTFz!(wchar*)
		                        , JPEG_QUALITYSUPERB | JPEG_OPTIMIZE )
		       , "saveBitmapSet : failure in FreeImage_SaveU( " ~ filename.to!string ~ " )." );
	}
	else throw new Exception( "saveBitmapSet : can't deduce file type from the extension of " ~ filename.to!string
	                          ~ " )." );
}

