module sworks.compo.util.pair_func;

import std.traits;

void PairFunc( alias BEGIN, alias END, T ... )( T args )
	if( isCallable!BEGIN && isCallable!END && 0 < T.length && isCallable!(T[$-1]) )
{
	BEGIN( args[ 0 .. ParameterTypeTuple!BEGIN.length ] );
	scope( exit ) END( args[ 0 .. ParameterTypeTuple!END.length ] );
	args[$-1]();
}
