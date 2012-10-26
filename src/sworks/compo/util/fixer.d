module sworks.compo.util.fixer;

/**
 * 1回入力したら、以降もう変更できないようにする。
 * どうしても変更する場合は、bareValue を使う。
 *
 * bareValue が U の場合には変更できる。
 * それ以外の場合は変更できない。
 */
struct Fixer(T, T U = T.init)
{
	public T bareValue;
	alias bareValue this;

	this( T value = U )
	{
		this.bareValue = value;
	}

	@property
	{
		bool isFixed() { return this.bareValue !is U; }
	}

	T opAssign( T value )
	{
		if( this.bareValue is U ) return (this.bareValue = value);
		else throw new Exception("Fixer : this value can't be overwritten.");
	}

	@disable void opUnary(string OP)(){}
	@disable void opOpAssign(string OP)(T){}
	@disable void opIndexUnary(string OP)(size_t){}
	@disable void opSliceUnary(string OP)(size_t,size_t){}
	@disable void opSliceUnary(string OP)(){}
	@disable void opIndexAssign(T,size_t){}
	@disable void opSliceAssign(T,size_t, size_t){}
	@disable void opSliceAssign(T){}
}


debug(fixer)
{
	import std.stdio;
	extern(Windows)
	{
		void print(int i)
		{
			writeln( i );
		}
	}
	void main()
	{
		Fixer!(int) i;
		writeln(i.isFixed);
		i = 10;
		writeln( i.isFixed );
		i = 100;
		print(i);
		i.bareValue = 1000;
		print( i );
		print( i + (10) );
	}
}