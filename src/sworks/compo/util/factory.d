module sworks.compo.util.factory;


interface ISlist( BASE, string PF = "" )
{
	mixin( "BASE next" ~ PF ~ "() @property;" );
	mixin( "void next" ~ PF ~ "( BASE ) @property;" );
	mixin( "void insert" ~ PF ~ "( BASE );" );
	mixin( "void concat" ~ PF ~ "( BASE );" );
	mixin( "void remove_all" ~ PF ~ "();" );
	mixin( "void remove" ~ PF ~ "();" );
}

interface IBlist( BASE, string PF = "") : ISlist!( BASE, PF )
{
	mixin( "BASE prev" ~ PF ~ "() @property;" );
	mixin( "void prev" ~ PF ~ "( BASE ) @property;" );
}

/*
 * mixin でクラスにフィールドを追加する。
 * -- new の代わりに getInstance を使うことで new の回数を減らす。
 * -- 双方向リンクリストの実装
 */
template Factory(BASE, string PF = "")
{
	static assert( is( typeof(this) : BASE)
	  , "Factory: " ~ typeof(this).stringof ~ " and " ~ BASE.stringof ~ " are not compatible." );
	static assert( __traits( hasMember, typeof(this), "onReset" ~ PF )
	  , "Factory: a function named 'onReset" ~ PF ~ "' is needed for " ~ typeof(this).stringof ~ " class." );
	static assert( __traits( hasMember, typeof(this), "onRemove" ~ PF )
	  , "Factory: a function named 'onRemove" ~ PF ~ "' is needed for " ~ typeof(this).stringof ~ " class." );

	static
	{
		private typeof(this) free_stack; // next の値しか使わない逐次型スタック

		typeof(this) opCall(T...)(T arg)
		{
			typeof(this) ret;
			if( null !is free_stack )
			{
				ret = free_stack;
				free_stack = mixin( "cast(typeof(this))ret.next" ~ PF );
				mixin( "ret.next" ~ PF ) = null;
			}
			else ret = new typeof(this);
			mixin( "ret.onReset" ~ PF )( arg );
			return ret;
		}

		void cleanup()
		{
			for( BASE mortal, fs = free_stack ; null !is fs ; )
			{
				mortal = fs;
				fs = mixin( "fs.next" ~ PF );
				delete mortal;
			}
			free_stack = null;
		}

	}

	private BASE _next;
	private BASE _prev;

	mixin( "BASE next" ~ PF ~ "() @property nothrow { return _next; }" );
	mixin( "BASE prev" ~ PF ~ "() @property nothrow { return _prev; }" );
	mixin( "void next" ~ PF ~ "(BASE b) @property nothrow { _next = b; }" );
	mixin( "void prev" ~ PF ~ "(BASE b) @property nothrow { _prev = b; }" );

	// this の直後に挿入
	mixin( "void insert" ~ PF ~ "( BASE t )
	{
		if( null is t ) return;
		if( null !is t.next" ~ PF ~ " ) t.next" ~ PF ~ ".prev" ~ PF ~ " = null;
		if( null !is t.prev" ~ PF ~ " ) t.prev" ~ PF ~ ".next" ~ PF ~ " = null;
		if( null !is _next ) _next.prev" ~ PF ~ " = t;
		t.next" ~ PF ~ " = _next;
		t.prev" ~ PF ~ " = this;
		_next = t;
	}" );

	mixin( "void concat" ~ PF ~ "( BASE t )
	{
		if( null !is _next ) _next.prev" ~ PF ~ " = null;
		if( null !is t )
		{
			if( null !is t.prev" ~ PF ~ " ) t.prev" ~ PF ~ ".next" ~ PF ~ " = null;
			t.prev" ~ PF ~ " = this;
		}
		_next = t;
	}" );

	// 自身を取り除く。これを実行した後は参照が残っていないか注意すべき。
	mixin( "void remove" ~ PF ~ "()
	{
		onRemove" ~ PF ~ "();

		if( null !is _prev ) _prev.next" ~ PF ~ " = _next;
		if( null !is _next ) _next.prev" ~ PF ~ " = _prev;

		_prev = null;
		_next = free_stack;
		free_stack = this;
	}" );

	mixin( "void noStackRemove" ~ PF ~ "()
	{
		onRemove" ~ PF ~ "();
		if( null !is _prev ) _prev.next" ~ PF ~ " = _next;
		if( null !is _next ) _next.prev" ~ PF ~ " = _prev;

		_prev = null;
		_next = null;
	}" );

	mixin( "void remove_all" ~ PF ~ "()
	{
		for( BASE prev = null ; null !is _next && prev !is _next ; )
		{
			prev = _next;
			_next.remove" ~ PF ~ "();
		}
		remove" ~ PF ~ "();
	}" );

	size_t calc_distance( BASE to )
	{
		size_t i;
		BASE ite = this;
		for( i = 0 ; ite !is to ; ite = mixin( "ite.next" ~ PF ), i++ )
		{
			if( null is mixin( "ite.next" ~ PF ) ) throw new Exception( "Factory.calc_distance : not found" );
		}
		return i;
	}

	mixin( "void onReset" ~ PF ~ "( T ... )( T args ){}" );
	mixin( "void onRemvoe" ~ PF ~ "(){}" );
}


// IBlist を連結
// コピーは起きない。
struct BlistAppender( LIST ) if( is( LIST : IBlist!(LIST) ) )
{
protected:
	LIST _front;
	LIST _back;

public:
    //----------------------------------------------------------------------
    // input range
	bool empty() @property const nothrow { return _front is null; }
	LIST front() @property nothrow { return _front; }
	void front( LIST l ) @property
	{
		if( _front is _back ) _front = _back = l;
		else
		{
			l.concat( _front );
			_front = l;
			_front.next.remove();
		}
		for( ; null !is _front.prev ; _front = _front.prev ){}
	}
	void popFront()
	{
		if( _front is _back ) _front = _back = null;
		else
		{
			_front = _front.next;
			_front.prev.remove();
		}
	}


    //----------------------------------------------------------------------
    // output range
	void put( LIST new_one )
	{
		if( null is new_one ) return;
		else if( null is _front || null is _back ) _front = _back = new_one;
		else _back.concat( new_one );

		for( ; null !is _back.next ; _back = _back.next ){}
	}

	void put( ref BlistAppender new_one )
	{
		if( new_one.empty ) return;
		else if( null is _front || null is _back )
		{
			_front = new_one._front;
			_back = new_one._back;
		}
		else
		{
			_back.concat( new_one._front );
			_back = new_one._back;
			new_one._front = _front;
		}
	}

    //----------------------------------------------------------------------
    // bidirectional range
	LIST back() @property nothrow { return _back; }
	void popBack()
	{
		if( _front is _back ) _front = _back = null;
		else
		{
			_back = _back.prev;
			_back.next.remove();
		}
	}

	void reset() { if( null !is front ) _front.remove_all(); _front = null; _back = null; }
	LIST flush() { LIST ret = _front; _front = _back = null; return ret; }


	void addFront( LIST new_one )
	{
		if( null is new_one ) return;
		else if( null is _front || null is _back ) _front = _back = new_one;
		else new_one.concat( _front );
		for( ; null !is _front.prev ; _front = _front.prev ){}
	}

	void addFront( BlistAppender new_one )
	{
		if( null is new_one || new_one.empty ) return;
		else if( null is _front || null is _back )
		{
			_front = new_one._front;
			_back = new_one._back;
		}
		else
		{
			new_one._back.concat( _front );
			_front = new_one._front;
			new_one._back = _back;
		}
	}
}

template SFactory(BASE, string PF = "")
{
	static assert( is( typeof(this) : BASE)
	  , "Factory: " ~ typeof(this).stringof ~ " and " ~ BASE.stringof ~ " are not compatible." );
	static assert( __traits( hasMember, typeof(this), "onReset" ~ PF )
	  , "Factory: a function named 'onReset" ~ PF ~ "' is needed for " ~ typeof(this).stringof ~ " class." );
	static assert( __traits( hasMember, typeof(this), "onRemove" ~ PF )
	  , "Factory: a function named 'onRemove" ~ PF ~ "' is needed for " ~ typeof(this).stringof ~ " class." );

	static
	{
		private typeof(this) free_stack;

		typeof(this) opCall(T...)(T arg)
		{
			typeof(this) ret;
			if( null !is free_stack )
			{
				ret = free_stack;
				free_stack = mixin( "cast(typeof(this))ret.next" ~ PF );
				mixin( "ret.next" ~ PF ) = null;
			}
			else ret = new typeof(this);
			mixin( "ret.onReset" ~ PF )( arg );
			return ret;
		}

		void cleanup()
		{
			for( BASE mortal, fs = free_stack ; null !is fs ; )
			{
				mortal = fs;
				fs = mixin( "fs.next" ~ PF );
				delete mortal;
			}
			free_stack = null;
		}
	}

	private BASE _next;

	mixin( "BASE next" ~ PF ~ "() @property nothrow { return _next; }" );
	mixin( "void next" ~ PF ~ "(BASE b) @property nothrow { _next = b; }" );

	// this の直後に挿入
	mixin( "void insert" ~ PF ~ "( BASE t )
	{
		t.next" ~ PF ~ " = _next;
		_next = t;
	}" );

	mixin( "void concat" ~ PF ~ "( BASE t )
	{
		_next = t;
	}" );

	// 自身を取り除く。これを実行した後は参照が残っていないか注意すべき。
	mixin( "void remove_all" ~ PF ~ "()
	{
		BASE ite = this;
		for( ; null !is ite" ~ PF ~ " ; )
		{
			auto c = ite.next" ~ PF ~ ";
			ite.remove" ~ PF ~ "();
			ite = c;
		}
	}" );

	mixin( "void remove" ~ PF ~ "()
	{
		onRemove" ~ PF ~ "();
		_next = free_stack;
		free_stack = this;
	}");

	size_t calc_distance( BASE to )
	{
		size_t i;
		BASE ite = this;
		for( i = 0 ; ite !is to ; ite = mixin( "ite.next" ~ PF ), i++ )
		{
			if( null is mixin( "ite.next" ~ PF ) ) throw new Exception( "Factory.calc_distance : not found" );
		}
		return i;
	}

	mixin( "void onReset" ~ PF ~ "( T ... )( T args ){}" );
	mixin( "void onRemvoe" ~ PF ~ "(){}" );
}


template Slist(BASE, string PF = "")
{
	static assert( is( typeof(this) : BASE)
	  , "Factory: " ~ typeof(this).stringof ~ " and " ~ BASE.stringof ~ " are not compatible." );

	private BASE _next;

	mixin( "BASE next" ~ PF ~ "() @property nothrow { return _next; }" );
	mixin( "void next" ~ PF ~ "(BASE b) @property nothrow { _next = b; }" );

	// this の直後に挿入
	mixin( "void insert" ~ PF ~ "( BASE t )
	{
		t.next" ~ PF ~ " = _next;
		_next = t;
	}" );

	mixin( "void concat" ~ PF ~ "( BASE t )
	{
		_next = t;
	}" );

	size_t calc_distance( BASE to )
	{
		size_t i;
		BASE ite = this;
		for( i = 0 ; ite !is to ; ite = mixin( "ite.next" ~ PF ), i++ )
		{
			if( null is mixin( "ite.next" ~ PF ) ) throw new Exception( "Factory.calc_distance : not found" );
		}
		return i;
	}
}


// ISlist を連結
// コピーは起きない。
struct SlistAppender( LIST ) //if( is( LIST : ISlist!(LIST) ) )
{
protected:
	LIST _front;
	LIST _back;

public:
    //----------------------------------------------------------------------
    // input range
	bool empty() @property const nothrow { return _front is null; }
	ref LIST front() @property nothrow { return _front; }
	ref LIST back() @property nothrow { return _back; }
    //----------------------------------------------------------------------
    // output range
	void put( LIST new_one )
	{
		if( null is new_one ) return;
		else if( null is _front || null is _back ) _front = _back = new_one;
		else _back.concat( new_one );

		for( ; null !is _back.next ; _back = _back.next ){}
	}

	void put( ref SlistAppender new_one )
	{
		if( new_one.empty ) return;
		else if( null is _front || null is _back )
		{
			_front = new_one._front;
			_back = new_one._back;
		}
		else
		{
			_back.concat( new_one._front );
			_back = new_one._back;
			new_one._front = _front;
		}
	}

	void reset() { if( null !is front ) _front.remove_all(); _front = null; _back = null; }
	LIST flush() { LIST ret = _front; _front = _back = null; return ret; }
}


debug( factory )
{
	import std.stdio;

	class Test
	{ mixin Factory!( Test ) T;
	  mixin Factory!( Test, "IT" ) IT;

		alias T.opCall opCall;


		this(){ writeln("ctor" ); }

		int x, y;

		void onReset( int x )
		{
			this.x = x;
		}

		void onRemove(){writeln("destroy");}

		void onResetIT(){}
		void onRemoveIT(){}
	}


	void main()
	{
		auto t = Test( 5 );
		t.y = 10;
		writeln( t.x );
		writeln( t.y );
		t.remove;
		t = Test( 6 );
		writeln( t.x );
		writeln( t.y );
	}
}