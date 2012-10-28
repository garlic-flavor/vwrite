module sworks.compo.win32.dragdrop;
import sworks.compo.util.readz;
import sworks.compo.win32.util;
import sworks.compo.win32.msg;

class DragDropFiles
{
	POINT pos;
	Readz*[] files;
}

// for mixin
class DragDrop
{
	private DragDropFiles ddf;
	private HWND handle;

	this( HWND handle )
	{
		this.handle = handle;
		ddf = new DragDropFiles;
		DragAcceptFiles( handle, true );
	}

	void dragAcceptStart( ) { DragAcceptFiles( handle, true ); }

	void dragAcceptEnd(){ DragAcceptFiles( handle, false ); }

	DragDropFiles opCall( Msg msg )
	{
		auto hDrop = cast(HDROP) msg.wp;
		scope( exit ) DragFinish( hDrop );

		DragQueryPoint( hDrop, &(ddf.pos) );

		auto file_num = DragQueryFile( hDrop, uint.max, null, 0 );
		ddf.files.length = file_num;
		for( uint i = 0 ; i < file_num ; ++i )
		{
			uint filename_l = DragQueryFile( hDrop, i, null, 0 );
			wchar[] buf = new wchar[ filename_l+1 ];
			DragQueryFile( hDrop, i, buf.ptr, buf.length );
			ddf.files[i] = new Readz( assumeUnique(buf[ 0 .. filename_l]) );
		}

		return ddf;
	}
}