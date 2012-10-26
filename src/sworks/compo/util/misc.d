module sworks.compo.util.misc;

T[U] merge(T,U)( T[U] a, in T[U] b )
{
	foreach( key, val ; b ){ a[key] = val; }
	return a;
}