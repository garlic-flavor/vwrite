module sworks.compo.util.cached_buffer;

version(Windows) import std.windows.charset;



interface IPeekableBuffer
{
	void open();
	void close();
	bool isOpen() @property const;
	size_t position() @property const;
	size_t line() @property const;
	bool eof() @property const;
	immutable(byte)[] read( size_t size );

	IPeekableBuffer dup() @property;

	byte peek() @property const;
	byte discard( size_t s = 1 );

	byte push( size_t s = 1 );
	immutable(byte)[] buffer() @property;
	void flush;

	bool startsWith( immutable(byte)[] str );
}

struct UFile
{
	File _file;
	alias _file this;
}

class CirclicCachedFile
{
	enum CACHE_SIZE = 1024;
}

class TCachedFile(CHAR) : TICachedBuffer!CHAR
{
	enum CACHE_SIZE = 255;

	private string _filename; // ファイル名
	private File _file;       // 本体
	private byte[ CACHE_SIZE ] _cache; // 一時キャッシュ
	private size_t _position;   // ファイル内での位置
	private size_t _line; // ファイル内の行数
	private size_t _head, _tail; // 一時キャッシュのどこを使っているか。
	private Appender!(CHAR[]) _buffer; // 二次キャッシュ。

	/*
	 * Params:
	 *   filename    = 対象のファイル名
	 *   cursor      = 対象ファイル先頭からのオフセットを指定するとそこから読み込む。
	 *   line_number = cursor 位置でのファイル内での行数。cursor を指定した時は、ここも指定しないと行数がずれる。
	 *   open_flag  = false の時はファイルをを開かずにおく。
	 */
	this( string filename, size_t position = 0, size_t line = 0, bool open_flag = true )
	{
		this._filename = filename;
		this._position = position;
		this._line = line;
		if( open_flag ) open();
	}

	size_t position() @property const { return _position; }
	size_t line() @property const { return _line; }
	bool isOpen() @property const{ return _file.isOpen && _head < _tail; }
	bool eof() @property { return _file.eof && _tail <= _head; }
	ICachedFile dup() @property { return new CachedFile( _filename, _position, _line, false ); }
	const(byte)[] cache() @property { return _cache[ head .. tail ]; }
	immutable(byte)[] buffer() @property { return _buffer.data.idup; }
	

	void open()
	{
		if( _file.isOpen ) return;
		version( Windows ) // なぜか UTF-8 に対応していない。
		{
			auto fnz = filename.toMBSz
			size_t
		}
	}
}