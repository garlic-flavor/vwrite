module sworks.compo.util.matrix;

private import std.math;
version(unittest) import std.stdio;

enum real DOUBLE_PI = PI*2;
enum real TO_RADIAN = PI/180.0;
enum real TO_360 = 180.0/PI;

version(unittest)
{
	bool aEqual(T, U)( T a, U b ) { return approxEqual( a, b, 1e-5, 1e-5 ); }
	alias Vector2!float V2;
	alias Vector3!float V3;
	alias Polar3!float P3;
	alias Quaternion!float Q4;
	alias Matrix3!float M3;
	alias Matrix4!float M4;
}

/*SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS*\
|*|                                 Vector2                                  |*|
\*SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS*/
struct Vector2(PRECISION)
{
	union
	{
		PRECISION[2] v = 0;
		struct { PRECISION x, y; }
	}
	alias v this;

	this( PRECISION s ) { v[] = s; }
	this( in PRECISION[2] s ... ) { v[] = s[]; }

	PRECISION length() const nothrow @property{ return sqrt( x*x + y*y ); }
	PRECISION lengthSq() const nothrow @property { return x*x + y*y; }
	ref Vector2 normalize( PRECISION size = 1 ) { v[] *= size / length; return this; }
	Vector2 normalizedVector( PRECISION size = 1 ) const
	{
		PRECISION sl = size / length;
		return Vector2( x * sl, y * sl );
	}

	Vector2 opUnary( string OP : "-" )() const { return Vector2( -x, -y ); }

	Vector2 opBinary( string OP : "+" )( in PRECISION[2] s ... ) const { return Vector2( x+s[0], y+s[1] ); }
	Vector2 opBinary( string OP : "-" )( in PRECISION[2] s ... ) const { return Vector2( x-s[0], y-s[1] ); }
	Vector2 opBinary( string OP : "*" )( PRECISION s ) const { return Vector2( x*s, y*s ); }
	Vector2 opBinary( string OP : "/" )( PRECISION s ) const
	{
		auto s1 = 1 / s;
		return Vector2( x * s1, y * s1 );
	}

	ref Vector2 opOpAssign( string OP : "+" )( in PRECISION[2] s ... ) { v[] += s[]; return this; }
	ref Vector2 opOpAssign( string OP : "-" )( in PRECISION[2] s ... ) { v[] -= s[]; return this; }
	ref Vector2 opOpAssign( string OP : "*" )( PRECISION s ) { v[] *= s; return this; }
	ref Vector2 opOpAssign( string OP : "/" )( PRECISION s ) { v[] /= s; return this; }

	ref Vector2 opAssign( PRECISION s ) { v[] = s; return this; }
	ref Vector2 opAssign( in PRECISION[2] s ... ) { v[] = s[]; return this; }

	ref Vector2 rotate( PRECISION a )
	{
		creal cs = expi(a);
		PRECISION[2] n;
		n[0] = (x*cs.re) - (y*cs.im);
		n[1] = (x*cs.im) + (y*cs.re);
		v[] = n[];
		return this;
	}

	Vector2 rotateVector( PRECISION a )
	{
		creal cs = expi(a);
		Vector2 n;
		n[0] = (x*cs.re) - (y*cs.im);
		n[1] = (x*cs.im) + (y*cs.re);
		return n;
	}
}
alias Vector2!float Vector2f;

PRECISION length(PRECISION)( PRECISION x, PRECISION y )
{
	return sqrt( x*x + y*y );
}

PRECISION lengthSq(PRECISION)( PRECISION x, PRECISION y )
{
	return x*x + y*y;
}

Vector2!PRECISION normalizedVector(PRECISION)( PRECISION x, PRECISION y )
{
	PRECISION sl = size / sqrt( x*x + y*y );
	return Vector2!PRECISION( x * sl, y * sl );
}

PRECISION dot(PRECISION)( in PRECISION[2] v1, in PRECISION[2] v2 ... ) nothrow
{
	return v1[0]*v2[0] + v1[1]*v2[1];
}

PRECISION cross(PRECISION)( in PRECISION[2] v1, in PRECISION[2] v2 ... )
{
	return v1[0]*v2[1] - v1[1]*v2[0];
}

PRECISION distance(PRECISION)( in PRECISION[2] v1, in PRECISION[2] v2 )
{
	return sqrt( ((v1[0]-v2[0]) ^^ 2) + ((v1[1]-v2[1]) ^^ 2) );
}

PRECISION distanceSq(PRECISION)( in PRECISION[2] v1, in PRECISION[2] v2 )
{
	return ((v1[0]-v2[0]) ^^ 2 ) + ((v1[1]-v2[1]) ^^ 2 );
}

Vector2!PRECISION interpolateLinear(PRECISION)( ref const(Vector2!PRECISION) a, PRECISION r
                                              , ref const(Vector2!PRECISION) b )
{
	return ((b-a) * r) + a;
}

unittest
{
	V2 a = V2( 1, 2 );
	assert( aEqual( a.length, 2.2360679 ) );
	assert( aEqual( a.lengthSq, 5 ) );
	auto b = a.normalizedVector;
	assert( aEqual( a.cross(b), 0 ) );
	assert( aEqual( a.dot(b), a.length ) );
	a = V2( 1, 0 );
	a.rotate( PI_2 );
	assert( aEqual( a[], [ 0, 1 ]) );
	a = V2( 0, 0 );
	b = V2( 2, 0 );
	assert( aEqual( interpolateLinear( a, 0.5f, b )[], [ 1, 0 ] ) );
}

/*SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS*\
|*|                                 Vector3                                  |*|
\*SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS*/
/** 3 dimentional column-major Vector class. OpenGL style.
 * \htmlonly
 * <pre>
 *        | x |
 *    V = | y |
 *        | z |
 * </pre>
 * \endhtmlonly
 */
struct Vector3(PRECISION)
{
	union
	{
		PRECISION[3] v = 0;
		struct
		{
			PRECISION x,y,z;
		}
	}
	alias v this;

	// constructor
	this( PRECISION s ) { v[] = s; }
	this( in PRECISION[3] s ... ) { v[] = s[]; }

	// properties
	PRECISION length() const nothrow @property { return sqrt(x*x+y*y+z*z); }
	PRECISION lengthSq() const nothrow @property { return x*x + y*y + z*z; }
	ref Vector3 normalize(PRECISION size = 1) { v[] *= size / length; return this; }
	Vector3 normalizedVector( PRECISION size = 1 ) const
	{
		PRECISION sl = size / length;
		return Vector3( x * sl, y * sl, z * sl );
	}

	// operator overloading
	Vector3 opUnary( string OP : "-" )() const { return Vector3(-x,-y,-z); }

	//
	Vector3 opBinary( string OP : "+" )( in PRECISION[3] s ) const
	{
		return Vector3( x+s[0], y+s[1], z+s[2] );
	}

	//
	Vector3 opBinary( string OP : "-" )( in PRECISION[3] s ) const
	{
		return Vector3( x-s[0], y-s[1], z-s[2] );
	}

	//
	Vector3 opBinary( string OP : "*" )( PRECISION s ) const
	{
		return Vector3( x*s, y*s, z*s );
	}

	Vector3 opBinary( string OP : "/" )( PRECISION s ) const
	{
		auto s1 = 1 / s;
		return Vector3( x * s1, y * s1, z * s1 );
	}

	//
	ref Vector3 opOpAssign( string OP : "+" )( in PRECISION[3] s ... ) { v[] += s[]; return this; }
	ref Vector3 opOpAssign( string OP : "-" )( in PRECISION[3] s ... ) { v[] -= s[]; return this; }
	ref Vector3 opOpAssign( string OP : "*" )( PRECISION s ) { v[] *= s; return this; }
	ref Vector3 opOpAssign( string OP : "/" )( PRECISION s ) { s[] /= s; return this; }

	//
	ref Vector3 opAssign(PRECISION s){ v[] = s;  return this;}
	ref Vector3 opAssign(in PRECISION[3] s ... ){ v[] = s[]; return this; }


	//
	ref Vector3 rotate(PRECISION a, in PRECISION[3] r... )
	{
		creal cs = expi(a);
		PRECISION c = cs.re;
		PRECISION s = cs.im;
		PRECISION c1 = 1-c;
		PRECISION[3] n;
		n[0] = (x*((r[0]*r[0]*c1)+c))        + (y*((r[0]*r[1]*c1)-(r[2]*s))) + (z*((r[0]*r[2]*c1)+(r[1]*s)));
		n[1] = (x*((r[1]*r[0]*c1)+(r[2]*s))) + (y*((r[1]*r[1]*c1)+c))        + (z*((r[1]*r[2]*c1)-(r[0]*s)));
		n[2] = (x*((r[0]*r[2]*c1)-(r[1]*s))) + (y*((r[1]*r[2]*c1)+(r[0]*s))) + (z*((r[2]*r[2]*c1)+c));
		v[] = n[];
		return this;
	}

	ref Vector3 rotateYZ(PRECISION a)
	{
		creal cs = expi(a); // con(a)==cs.re; sin(a)==cs.im;
		PRECISION[3] n;
		n[0] = x;
		n[1] = (y*cs.re) - (z*cs.im);
		n[2] = (y*cs.im) + (z*cs.re);
		v[] = n[];
		return this;
	}
	ref Vector3 rotateZX(PRECISION a)
	{
		creal cs = expi(a); // con(a)==cs.re; sin(a)==cs.im;
		PRECISION[3] n;
		n[0] = (x*cs.re) + (z*cs.im);
		n[1] = y;
		n[2] = -(x*cs.im) + (z*cs.re);
		v[] = n[];
		return this;
	}
	ref Vector3 rotateXY(PRECISION a)
	{
		creal cs = expi(a); // con(a)==cs.re; sin(a)==cs.im;
		PRECISION[3] n;
		n[0] = (x*cs.re) - (y*cs.im);
		n[1] = (x*cs.im) + (y*cs.re);
		n[2] = z;
		v[] = n[];
		return this;
	}
}
alias Vector3!double Vector3d;
alias Vector3!float Vector3f;
unittest
{
	V3 v = V3( 3, 4, 5 );
	assert( -v == [ -3, -4, -5 ] );
	assert( aEqual( v.length, (-v).length ) );
	assert( 50 == v.lengthSq );
	assert( aEqual( 7.0711, v.length ) );
	auto v2 = v.normalizedVector;
	assert( aEqual( 1.0000, v2.length ) );
	v.normalize;
	assert( aEqual( 1.0000, v.length ) );

	v = [ 3, 4, 5 ];
	v2 = [ 1, 2, 3 ];
	assert( v + v2 == [ 4, 6, 8 ] );
	assert( v - v2 == [ 2, 2, 2 ] );
	assert( v * 2 == [ 6, 8, 10 ] );
	assert( (v += v2) == [ 4, 6, 8 ] );
	assert( (v2 -= v) == [ -3, -4, -5 ] );
	assert( ( v *= 2 ) == [ 8, 12, 16 ] );
	assert( ( v = 0 ) == [ 0, 0, 0 ] );
	assert( ( v = v2 ) == v2 );
	assert( aEqual( v.rotate( 2 * PI, 1, 0, 0 )[], v2[] ) );

	assert( aEqual( v.rotateYZ(1).length, v2.length ) );
	assert( aEqual( v.rotateZX(1).length, v2.length ) );
	assert( aEqual( v.rotateXY(1).length, v2.length ) );
}

/*SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS*\
|*|                                  Polar3                                  |*|
\*SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS*/
/// 3 component polar class
struct Polar3(PRECISION)
{
	PRECISION longitude = 0; // East <-> West
	PRECISION latitude = 0;  // South <-> North
	PRECISION radius = 1;

	//
	this( PRECISION lg, PRECISION lt, PRECISION r ) { longitude = lg; latitude = lt; radius = r; }

	// property
	ref Polar3 normalize()
	{
		latitude %= DOUBLE_PI;
		if( latitude < 0 ) latitude += DOUBLE_PI;

		if( PI_2 < latitude && latitude < PI+PI_2 )
		{
			longitude += PI;
			latitude = PI - latitude;
		}
		else if( PI+PI_2 <= latitude ) latitude -= DOUBLE_PI;

		if(longitude < -PI) longitude = DOUBLE_PI + ( longitude % DOUBLE_PI );
		longitude = ( ( longitude + PI ) % DOUBLE_PI ) - PI;
		return this;
	}
}
alias Polar3!double Polar3d;
alias Polar3!float Poler3f;

unittest
{
	alias Polar3!float P3;
	P3 p3 = P3( DOUBLE_PI + 2.5, DOUBLE_PI * 4 + 1, 3 );
	p3.normalize;
	assert( aEqual( p3.longitude, 2.5 ) );
	assert( aEqual( p3.latitude, 1 ) );
}

/*FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF*\
|*|                                Functions                                 |*|
\*FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF*/
PRECISION length(PRECISION)( PRECISION x, PRECISION y, PRECISION z )
{
	return sqrt( x*x + y*y + z*z );
}

PRECISION lengthSq(PRECISION)( PRECISION x, PRECISION y, PRECISION z )
{
	return x*x + y*y + z*z;
}

unittest
{
	assert( aEqual( length( 3.0, 4.0, 5.0 ), 7.071 ) );
	assert( aEqual( lengthSq( 3.0, 4.0, 5.0 ), 50.0 ) );
}

Vector3!PRECISION normalizedVector(PRECISION)( PRECISION x, PRECISION y, PRECISION z, PRECISION size = 1 )
{
	PRECISION sl = size / sqrt( x*x + y*y + z*z );
	return Vector3!PRECISION( x * sl, y * sl, z * sl );
}
unittest
{
	assert( aEqual( normalizedVector( 3.0, 4.0, 5.0 )[], [ 0.42426, 0.56569, 0.70711 ] ) );
}


PRECISION dot(PRECISION)( in PRECISION[3] v1, in PRECISION[3] v2 ... ) nothrow
{
	return v1[0]*v2[0] + v1[1]*v2[1] + v1[2]*v2[2];
}
unittest
{
	V3 a = V3( 3, 4, 0 );
	V3 b = a;
	b.rotateXY( PI_2 );
	assert( aEqual( a.dot( b ), 0 ) );
}


Vector3!PRECISION cross( PRECISION )( in PRECISION[3] v1, in PRECISION[3] v2)
{
	return Vector3!PRECISION(v1[1]*v2[2]-v1[2]*v2[1], v1[2]*v2[0]-v1[0]*v2[2], v1[0]*v2[1]-v1[1]*v2[0]);
}
unittest
{
	V3 a = V3( 1, 2, 3 );
	V3 b = V3( 3, 4, 5 );
	V3 c = a.cross( b );
	assert( aEqual( a.dot( c ), 0 ) );
}


PRECISION distance(PRECISION)( in PRECISION[3] v1, in PRECISION[3] v2) pure
{
	return sqrt( pow(v1[0]-v2[0],2) + pow(v1[1]-v2[1],2) + pow(v1[2]-v2[2],2) );
}
PRECISION distanceSq(PRECISION)( in PRECISION[3] v1, in PRECISION[3] v2) pure
{
	return pow(v1[0]-v2[0],2) + pow(v1[1]-v2[1],2) + pow(v1[2]-v2[2],2);
}
unittest
{
	V3 a = V3( 1, 2, 3 );
	V3 b = V3( 4, 5, 6 );
	V3 c = a - b;
	assert( aEqual( c.length, a.distance( b ) ) );
	assert( aEqual( c.lengthSq, a.distanceSq( b ) ) );
}


Polar3!(PRECISION) toPolar(PRECISION)( in PRECISION[3] v ... )
{
	Polar3!PRECISION p;
	p.radius = sqrt( v[0]*v[0] + v[1]*v[1] + v[2]*v[2] );
	if( 0 < p.radius )
	{
		p.latitude = asin( v[1] / p.radius );
		if( 0 == v[2] )
		{
			if( 0 < v[0] ) p.longitude = 0;
			else p.longitude = PI_2;
		}
		else
		{
			p.longitude = atan2 ( v[2] , v[0] );
		}
	}
	return p;
}

Vector3!(PRECISION) toVector(PRECISION)( ref const(Polar3!(PRECISION)) p )
{
	Vector3!PRECISION v;
	creal lati_sc = expi(p.latitude);
	creal long_sc = expi(p.longitude);
	v.y = p.radius * lati_sc.im;
	v.z = p.radius * lati_sc.re * long_sc.im;
	v.x = p.radius * lati_sc.re * long_sc.re;
	return v;
}
unittest
{
	V3 a = V3( 3, 4, 5 );
	P3 p = a.toPolar;
	assert( aEqual( a[], p.toVector[] ) );
}


Vector3!PRECISION interpolateLinear(PRECISION)( ref const(Vector3!PRECISION) a, PRECISION r
                                                , ref const(Vector3!PRECISION) b )
{
	return ((b - a) * r) + a;
}
unittest
{
	auto a = V3( 0, 0, 0 );
	auto b = V3( 1, 2, 3 );
	assert( aEqual( interpolateLinear( a, 0.5f, b )[], (b * 0.5)[] ) );
}

/*SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS*\
|*|                                Quaternion                                |*|
\*SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS*/
// Quaternion
struct Quaternion( PRECISION )
{
	union
	{
		PRECISION[4] v = [ 0, 0, 0, 1 ];
		struct
		{
			PRECISION x, y, z, w;
		}
	}
	alias v this;

	this( in PRECISION[4] s ... ) { v[] = s[ ]; }
	this( in PRECISION[3] s ... ) { v[0..3] = s[]; v[3] = 0; }

	PRECISION length() const @property { return sqrt( x*x + y*y + z*z + w*w ); }
	PRECISION lengthSq() const @property { return x*x + y*y + z*z + w*w; }

	Quaternion normalizedQuaternion() const @property
	{
		PRECISION l = 1/length;
		return Quaternion( x * l, y * l, z * l, w * l );
	}

	ref Quaternion normalize()
	{
		PRECISION l = 1/length;
		x *= l; y *= l; z *= l; w *= l;
		return this;
	}

	Quaternion opBinary( string OP : "+" )( ref const(Quaternion) q ) const
	{
		return Quaternion( x + q.x, y + q.y, z + q.z, w + q.w );
	}
	ref Quaternion opOpAssign( string OP : "+" )( ref const(Quaternion) q )
	{
		x += q.x; y += q.y; z += q.z; w += q.w;
		return this;
	}

	Quaternion opBinary( string OP : "-" )( ref const(Quaternion) q ) const
	{
		return Quaternion( x - q.x, y - q.y, z - q.z, w - q.w );
	}
	ref Quaternion opOpAssign( string OP : "-" )( ref const(Quaternion) q ) const
	{
		x -= q.x; y -= q.y; z -= q.z; w -= q.w;
		return this;
	}

	private PRECISION[4] m_mulArray( ref const(Quaternion) q ) pure const
	{
		return [   x*q.w + y*q.z - z*q.y + w*q.x
		       , - x*q.z + y*q.w + z*q.x + w*q.y
		       ,   x*q.y - y*q.x + z*q.w + w*q.z
		       , - x*q.x - y*q.y - z*q.z + w*q.w ];
	}

	Vector3!PRECISION opBinary( string OP : "*" )( in PRECISION[3] v ... ) const
	{
		auto qv = Quaternion(v);
		auto conj = conjugate;
		auto aqv = this * qv * conj;
		return Vector3!PRECISION( aqv.x, aqv.y, aqv.z );
	}

	Quaternion opBinary( string OP : "*" )( in Quaternion q ) const
	{
		return Quaternion( m_mulArray( q ) );
	}
	ref Quaternion opOpAssign( string OP : "*" )( in Quaternion q )
	{
		v[] = m_mulArray(q);
		return this;
	}

	Quaternion opBinary( string OP : "*" )( PRECISION a ) const { return Quaternion( x*a, y*a, z*a, w*a ); }

	Quaternion conjugate() const @property { return Quaternion( -x, -y, -z, w ); }

	private static PRECISION[4] m_rotateArray( PRECISION rad, ref const(PRECISION[3]) axis )
	{
		creal cs = expi( rad * 0.5 );
		return [ cs.im * axis[0], cs.im * axis[1], cs.im * axis[2], cs.re ];
	}

	static Quaternion rotateQuaternion( PRECISION rad, in PRECISION[3] axis ... )
	{
		return Quaternion( m_rotateArray( rad, axis ) );
	}

	ref Quaternion rotate( PRECISION rad, in PRECISION[3] axis ... )
	{
		auto q = rotateQuaternion( rad, axis );
		v[] = q * this;
		return this;
	}
}
alias Quaternion!float Quaternionf;

unittest
{
	V3 a = V3( 1, 0, 0 );
	Q4 q = Q4.rotateQuaternion( PI_2, 0, 0, 1 );
	a = q * a;
	assert( aEqual( a[], [ 0.0f, 1.0f, 0.0f ] ) );

	a = V3( 1, 0, 0 );
	q = Q4.rotateQuaternion( PI_2, 0, 0, 1  );
	Q4 q2 = Q4.rotateQuaternion( PI_2, 1, 0, 0 );
	q = q2 * q;
	a = q * a;
	assert( aEqual( a[], [ 0.0f, 0.0f, 1.0f ] ) );


	a = V3( 3, 4, 5 );
	V3 b = a;
	V3 c = V3( 1.0f, 2.0f, 3.0f );
	V3 d = a.cross( c ).normalizedVector;
	q = Q4.rotateQuaternion( PI_2, d );

	a = q * a;
	assert( aEqual( a.dot( b ), 0.0f ) );

	a = b;
	q = Q4.rotateQuaternion( PI_2, d );
	a = q * a;
	a = q * a;
	a = q * a;
	a = q * a;
	assert( aEqual( a[], b[] ) );

}


PRECISION dot(PRECISION)( in PRECISION[4] a, in PRECISION[4] b )
{
	return a[0]*b[0] + a[1]*b[1] + a[2]*b[2] + a[3]*b[3];
}

Quaternion!PRECISION interpolateLinear( PRECISION )( ref const(Quaternion!PRECISION) a, PRECISION t )
{
	PRECISION sSq = 1.0 - a.w * a.w;
	PRECISION s;
	if( sSq <= 0.0 || ( s = sqrt(sSq) ) == 0.0 ) return a;

	PRECISION delta = acos( a.w );
	PRECISION s1 = 1 / s;
	auto a2 = a * ( sin( ( 1 - t ) * delta ) * s1 );
	a2.w += ( sin( t * delta ) * s1 );
	return a2;
}


/**
 * \param a, b normalized quaternion.
 * \param t [ 0 .. 1 ]
 */
Quaternion!PRECISION interpolateLinear( PRECISION )( ref const(Quaternion!PRECISION) a, PRECISION t
                                                   , ref const(Quaternion!PRECISION) b )
{
	PRECISION adotb = dot( a, b );
	PRECISION sSq = 1.0 - adotb * adotb;
	PRECISION s;
	if( sSq <= 0.0 || ( s = sqrt(sSq) ) == 0.0 ) return a;

	PRECISION delta = acos( adotb );
	PRECISION s1 = 1 / s;
	auto a2 = a * ( sin( ( 1 - t ) * delta ) * s1 );
	auto b2 = b * ( sin( t * delta ) * s1 );
	return a2 + b2;
}
unittest
{
	V3 a = V3( 3, 4, 5 );
	V3 b = normalizedVector( 6.0f, 8.0f, -2.0f );
	Q4 q1;
	Q4 q2 = Q4.rotateQuaternion( PI, b );
	Q4 q3 = Q4.rotateQuaternion( PI_2, b );
	Q4 q4 = interpolateLinear( q1, 0.5f, q2 );
	assert( aEqual( q3[], q4[] ) );
}


Matrix4!PRECISION toMatrix(PRECISION)( in PRECISION[4] q )
{
	return Matrix4!PRECISION(
		1 - 2*q[1]*q[1] - 2*q[2]*q[2], 2*q[0]*q[1] + 2*q[3]*q[2],     2*q[0]*q[2] - 2*q[3]*q[1],     0,
		2*q[0]*q[1] - 2*q[3]*q[2],     1 - 2*q[0]*q[0] - 2*q[2]*q[2], 2*q[1]*q[2] + 2*q[3]*q[0],     0,
		2*q[0]*q[2] + 2*q[3]*q[1],     2*q[1]*q[2] - 2*q[3]*q[0],     1 - 2*q[0]*q[0] - 2*q[1]*q[1], 0,
		0,                             0,                             0,                             1 );
}

unittest
{
	auto q1 = Q4.rotateQuaternion( PI_2 * 0.5, normalizedVector( 3.0f, 4.0f, 5.0f ) );
	auto v1 = V3( 1, 2, 3 );
	auto v2 = q1 * v1;
	auto m1 = q1.toMatrix;
	auto v3 = m1 * v1;
	assert( aEqual( v2[], v3[] ) );
}

Quaternion!PRECISION toQuaternion(PRECISION)( ref const(Matrix4!PRECISION) m )
{
	PRECISION x =   m[0] - m[5] - m[10] + 1;
	PRECISION y = - m[0] + m[5] - m[10] + 1;
	PRECISION z = - m[0] - m[5] + m[10] + 1;
	PRECISION w =   m[0] + m[5] + m[10] + 1;
	PRECISION x2, y2, z2, w2;


	if     ( y <= x && z <= x && w <= x )
	{
		x2 = sqrt(x) * 0.5;
		PRECISION x4 = 0.25 / x2;
		y2 = ( m[1] + m[4] ) * x4;
		z2 = ( m[2] + m[8] ) * x4;
		w2 = ( m[6] - m[9] ) * x4;
	}
	else if( x <= y && z <= y && w <= y )
	{
		y2 = sqrt(y) * 0.5;
		PRECISION y4 = 0.25 / y2;
		x2 = ( m[1] + m[4] ) * y4;
		z2 = (  m[6] + m[9] ) * y4;
		w2 = ( -m[2] + m[8] ) * y4;
	}
	else if( x <= z && y <= z && w <= z )
	{
		z2 = sqrt(z) * 0.5;
		PRECISION z4 = 0.25 / z2;
		x2 = ( m[2] + m[8] ) * z4;
		y2 = ( m[6] + m[9] ) * z4;
		w2 = ( m[1] + m[4] ) * z4;
	}
	else
	{
		w2 = sqrt(w) * 0.5;
		PRECISION w4 = 0.25 / w2;
		x2 = ( m[6] - m[9] ) * w4;
		y2 = ( -m[2] + m[8] ) * w4;
		z2 = ( m[1] - m[4] ) * w4;
	}
	return Quaternion!PRECISION( x2, y2, z2, w2 );
}

unittest
{
	auto q1 = Q4.rotateQuaternion( PI_2, normalizedVector( 1.0f, 2.0f, 3.0f ) );
	auto m1 = q1.toMatrix;
	auto q2 = m1.toQuaternion;
	assert( aEqual( q1[], q2[] ) );
}


Quaternion!PRECISION getQuaternionTo(PRECISION)( in PRECISION[3] from, in PRECISION[3] to ... )
{
	auto fl = length( from[0], from[1], from[2] );
	auto tl = length( to[0], to[1], to[2] );
	auto fl1 = 1 / fl;
	auto tl1 = 1 / tl;
	auto c = from.cross( to );
	if( 0 < c.lengthSq ) c.normalize;
	auto d = from.dot( to ) * fl1 * tl1;
	auto k = sqrt( tl * fl1 );
	PRECISION cos2, sin2;
	if( -1 < d )
	{
		cos2 = sqrt( 0.5 * ( 1 + d ) );
		sin2 = sqrt( 0.5 * ( 1 - d ) );
	}
	else // gimbal lock
	{
		c = Vector3!PRECISION( from[2], from[0], from[1] );
		cos2 = 0;
		sin2 = 1;
	}
	return Quaternion!PRECISION( k * c.x * sin2, k * c.y * sin2, k * c.z * sin2, k * cos2 );
}

Quaternion!PRECISION getQuaternionTo(PRECISION)( in PRECISION[3] from, in PRECISION[3] to, in PRECISION[3] axis )
{
	auto fl = length( from[0], from[1], from[2] );
	auto tl = length( to[0], to[1], to[2] );
	auto fl1 = 1 / fl;
	auto tl1 = 1 / tl;
	auto d = from.dot( to ) * fl1 * tl1;
	auto k = sqrt( tl * fl1 );
	PRECISION cos2, sin2;
	cos2 = sqrt( 0.5 * ( 1 + d ) );
	sin2 = sqrt( 0.5 * ( 1 - d ) );

	return Quaternion!PRECISION( k * axis[0] * sin2, k * axis[1] * sin2, k * axis[2] * sin2, k * cos2 );
}


unittest
{
	auto v1 = V3( 1, 2, 3 );
	auto v2 = V3( 3, 4, 5 );
	auto q1 = v1.getQuaternionTo( v2 );
	auto v3 = q1 * v1;

	assert( aEqual( v2[], v3[] ) );

	v1 = V3( 1, 0, 0 );
	v2 = V3( 1, 0, 0 );
	assert( aEqual( v1.getQuaternionTo( v2 )[], [ 0.0f, 0.0f, 0.0f, 1.0f ] ) );
}
unittest
{
	auto v2 = V3( 0, -1.52, 16 );
	auto v1 = V3( 0, 66.726, 0 );
	auto v0 = V3( 0, -1.52, 0 );

	auto z = ( v1 - v0 ).normalizedVector;
	auto x = ( v2 - v0 ).cross( z ).normalizedVector;
//	writeln( z[] );
//	writeln( x[] );

	auto r1 = z.getQuaternionTo( 0.0f, 0.0f, 1.0f );
//	writeln( r1[] );
	x = r1 * x;
//	writeln( x[] );
	auto xaxis = V3( 1, 0, 0 );
	auto zaxis = V3( 0, 0, 1 );
	auto r2 = x.getQuaternionTo( xaxis, zaxis ) * r1;
//	writeln( r2[] );
}

/*SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS*\
|*|                                 Matrix3                                  |*|
\*SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS*/
struct Matrix3(PRECISION)
{
	union
	{
		PRECISION[9] v = m_IdentityArray;
		struct
		{
			PRECISION _11, _12, _13
			        , _21, _22, _23
			        , _31, _32, _33;
		}
	}
	alias v this;

	this( PRECISION s ){ v[] = s; }
	this( in PRECISION[] s ... ){ v[] = s[]; }

	PRECISION opIndex( size_t i ) const { return v[i]; }
	PRECISION opIndex( size_t column, size_t row ) const { return v[ row + (column*3) ]; }
	PRECISION opIndexAssign( PRECISION s, size_t column, size_t row ){ v[row+(column*4)] = s; return s; }

	private PRECISION[] m_MulArray( in PRECISION[] s ) const
	{
		return [ (_11*s[0]) + (_21*s[1]) + (_31*s[2])
		       , (_12*s[0]) + (_22*s[1]) + (_32*s[2])
		       , (_13*s[0]) + (_23*s[1]) + (_33*s[2])

		       , (_11*s[3]) + (_21*s[4]) + (_31*s[5])
		       , (_12*s[3]) + (_22*s[4]) + (_32*s[5])
		       , (_13*s[3]) + (_23*s[4]) + (_33*s[5])

		       , (_11*s[6]) + (_21*s[7]) + (_31*s[8])
		       , (_12*s[6]) + (_22*s[7]) + (_32*s[8])
		       , (_13*s[6]) + (_23*s[7]) + (_33*s[8]) ];
	}

	Vector2!PRECISION opBinary( string OP : "*" )( in PRECISION[2] s ... )
	{
		Vector2!PRECISION r;
		PRECISION w = 1 / ( v[2]*s[0] + v[5]*s[1] + v[8] );
		r[0] = ( v[0]*s[0] + v[3]*s[1] + v[6] ) * w;
		r[1] = ( v[1]*s[0] + v[4]*s[1] + v[7] ) * w;
		return r;
	}

	Matrix3 opBinary( string OP : "*" )( in PRECISION[] s ) { return Matrix3( m_MulArray(s) ); }
	ref Matrix3 opOpAssign( string OP : "*" )( in PRECISION[] s ){ v[] = m_MulArray(s); return this; }

	static private PRECISION[] m_IdentityArray() pure nothrow
	{
		return [ 1.0, 0.0, 0.0
		       , 0.0, 1.0, 0.0
		       , 0.0, 0.0, 1.0 ];
	}
	static Matrix3 identityMatrix() { return Matrix3(m_IdentityArray); }
	ref Matrix3 loadIdentity() { v[] = m_IdentityArray; return this; }

	static private PRECISION[] m_translateArray( ref const(PRECISION[2]) s ) pure nothrow
	{
		return [ 1.0,  0.0,  0.0
		       , 0.0,  1.0,  0.0
		       , s[0], s[1], 1.0 ];
	}
	static Matrix3 translateMatrix( in PRECISION[2] s ... ) { return Matrix3(m_translateArray(s)); }
	ref Matrix3 translate( in PRECISION[2] s ... ){ return opOpAssign!"*"(m_translateArray(s)); }

	static private PRECISION[] m_rotateArray( PRECISION a ) pure
	{
		creal cs = expi( a );
		return [ cs.re,  cs.im, 0.0
		       , -cs.im, cs.re, 0.0
		       , 0.0,    0.0,   1.0 ];
	}
	static Matrix3 rotateMatrix( PRECISION a ) { return Matrix3( m_rotateArray(a)); }
	ref Matrix3 rotate( PRECISION a ) { return opOpAssign!"*"(m_rotateArray(a)); }

	static private PRECISION[] m_scaleArray( PRECISION x, PRECISION y ) pure nothrow
	{
		return [ x,   0.0, 0.0
		       , 0.0, y,   0.0
		       , 0.0, 0.0, 1.0 ];
	}
	static Matrix3 scaleMatrix( PRECISION x, PRECISION y ) { return Matrix3( m_scaleArray( x, y ) ); }
	ref Matrix3 scale( PRECISION x, PRECISION y ) { return opOpAssign!"*"(m_scaleArray( x, y )); }

	PRECISION determinant() const nothrow
	{
		return _11*_22*_33 + _21*_32*_13 + _31*_12*_23 - _31*_22*_13 - _21*_12*_33 - _11*_32*_23;
	}

	Matrix3 inverseMatrix() const
	{
		PRECISION det = determinant;
		if( 0 == det ) return Matrix3( PRECISION.nan );
		PRECISION det1 = 1 / det;

		return Matrix3( (_22*_33 - _32*_23 ) * det1
		              , (_32*_13 - _12*_33 ) * det1
		              , (_12*_23 - _22*_13 ) * det1

		              , (_31*_23 - _21*_33 ) * det1
		              , (_11*_33 - _31*_13 ) * det1
		              , (_21*_13 - _11*_23 ) * det1

		              , (_21*_32 - _31*_22 ) * det1
		              , (_31*_12 - _11*_32 ) * det1
		              , (_11*_22 - _21*_12 ) * det1 );
	}
}

unittest
{
	M3 m = M3.rotateMatrix( PI_2 );
	V2 a = V2( 1, 0 );
	auto b = m * a;
	assert( aEqual( b[], [ 0, 1 ] ) );
	auto mi = m.inverseMatrix;
	assert( aEqual( (mi * b)[], a[] ) );
}

/*SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS*\
|*|                                 Matrix4                                  |*|
\*SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS*/
/** 4x4 column-major matrix.
 * \htmlonly
 * <pre>
 *        | _11, _21, _31, _41 |   | 0,  4,  8,  12 |
 *    M = | _12, _22, _32, _42 | = | 1,  5,  9,  13 |
 *        | _13, _23, _33, _43 |   | 2,  6,  10, 14 |
 *        | _14, _24, _34, _44 |   | 3,  7,  11, 15 |
 * </pre>
 * \endhtmlonly
 *
 * M[1] == M[0,1] == M._12;
 */
struct Matrix4(PRECISION)
{
	union
	{
		PRECISION[16] v = m_IdentityArray;
		struct
		{
			PRECISION _11, _12, _13, _14
			        , _21, _22, _23, _24
			        , _31, _32, _33, _34
			        , _41, _42, _43, _44;
		}
	}
	alias v this;

	// constructor
	this(PRECISION s){ v[] = s; }
	this( in PRECISION[] s ... ) { v[] = s; }

	// operator overloading
	PRECISION opIndex( uint i ) const { return v[i]; }
	PRECISION opIndex(uint column, uint row) const {return v[ row + (column * 4) ];}
	PRECISION opIndexAssign(PRECISION s, uint column, uint row){v[row+(column*4)] = s; return s;}

	// matrix * matrix
	private PRECISION[] m_MulArray( in PRECISION[] s) const
	{
		return [ (_11*s[0]) + (_21*s[1]) + (_31*s[2]) + (_41*s[3]) // _11
		       , (_12*s[0]) + (_22*s[1]) + (_32*s[2]) + (_42*s[3]) // _12
		       , (_13*s[0]) + (_23*s[1]) + (_33*s[2]) + (_43*s[3]) // _13
		       , (_14*s[0]) + (_24*s[1]) + (_34*s[2]) + (_44*s[3]) // _14

		       , (_11*s[4]) + (_21*s[5]) + (_31*s[6]) + (_41*s[7]) // _21
		       , (_12*s[4]) + (_22*s[5]) + (_32*s[6]) + (_42*s[7]) // _22
		       , (_13*s[4]) + (_23*s[5]) + (_33*s[6]) + (_43*s[7]) // _23
		       , (_14*s[4]) + (_24*s[5]) + (_34*s[6]) + (_44*s[7]) // _24

		       , (_11*s[8]) + (_21*s[9]) + (_31*s[10]) + (_41*s[11]) // _31
		       , (_12*s[8]) + (_22*s[9]) + (_32*s[10]) + (_42*s[11]) // _32
		       , (_13*s[8]) + (_23*s[9]) + (_33*s[10]) + (_43*s[11]) // _33
		       , (_14*s[8]) + (_24*s[9]) + (_34*s[10]) + (_44*s[11]) // _34

		       , (_11*s[12]) + (_21*s[13]) + (_31*s[14]) + (_41*s[15]) // _41
		       , (_12*s[12]) + (_22*s[13]) + (_32*s[14]) + (_42*s[15]) // _42
		       , (_13*s[12]) + (_23*s[13]) + (_33*s[14]) + (_43*s[15]) // _43
		       , (_14*s[12]) + (_24*s[13]) + (_34*s[14]) + (_44*s[15]) // _44
		       ];
	}

	Vector3!PRECISION opBinary( string OP : "*" )( in PRECISION[3] s ... )
	{
		Vector3!PRECISION r;
		PRECISION w = 1 / ( v[3] * s[0] + v[7] * s[1] + v[11] * s[2] + v[15] );
		r[0] = ( v[0] * s[0] + v[4] * s[1] + v[8] * s[2] + v[12] ) * w;
		r[1] = ( v[1] * s[0] + v[5] * s[1] + v[9] * s[2] + v[13] ) * w;
		r[2] = ( v[2] * s[0] + v[6] * s[1] + v[10] * s[2] + v[14] ) * w;
		return r;
	}

	//
	Matrix4 opBinary( string OP : "*" )( PRECISION[] s ) { return Matrix4( m_MulArray(s) ); }

	//
	ref Matrix4 opOpAssign( string OP : "*" )( PRECISION[] s ){ v[] = m_MulArray(s); return this; }

	// identity
	static private PRECISION[] m_IdentityArray() pure nothrow
	{
		return [ 1.0, 0.0, 0.0, 0.0
		       , 0.0, 1.0, 0.0, 0.0
		       , 0.0, 0.0, 1.0, 0.0
		       , 0.0, 0.0, 0.0, 1.0 ];
	}
	static Matrix4 identityMatrix() { return Matrix4(m_IdentityArray); }
	ref Matrix4 loadIdentity() { v[] = m_IdentityArray; return this; }

	// translation
	static private PRECISION[] m_translateArray( ref const(PRECISION[3]) s ) pure nothrow
	{
		return [ 1.0,  0.0,  0.0,  0.0
		       , 0.0,  1.0,  0.0,  0.0
		       , 0.0,  0.0,  1.0,  0.0
		       , s[0], s[1], s[2], 1.0];
	}
	static Matrix4 translateMatrix( in PRECISION[3] s ... )
	{
		return Matrix4(m_translateArray(s));
	}
	ref Matrix4 translate( in PRECISION[3] s ... ){return opOpAssign!("*")(m_translateArray(s));}

	// rotation
	static private PRECISION[] m_rotateArray(PRECISION a, ref const(PRECISION[3]) r ) pure
	{
		creal cs= expi(a);
		PRECISION c = cs.re;
		PRECISION s = cs.im;
		PRECISION c1 = 1-c;
		return [ (r[0]*r[0]*c1)+c,        (r[1]*r[0]*c1)+(r[2]*s), (r[0]*r[2]*c1)-(r[1]*s), 0
		       , (r[0]*r[1]*c1)-(r[2]*s), (r[1]*r[1]*c1)+c,        (r[1]*r[2]*c1)+(r[0]*s), 0
		       , (r[0]*r[2]*c1)+(r[1]*s), (r[1]*r[2]*c1)-(r[0]*s), (r[2]*r[2]*c1)+c,        0
		       , 0,                       0,                        0,                      1 ];
	}
	static Matrix4 rotateMatrix(PRECISION a, in PRECISION[3] r...)
	{
		return Matrix4(m_rotateArray(a,r));
	}
	ref Matrix4 rotate(PRECISION a, in PRECISION[3] s... )
	{
		return opOpAssign!("*")(m_rotateArray(a,s));
	}

	static private PRECISION[] m_rotateYZArray(PRECISION a) pure
	{
		creal cs = expi(a); // cos(a)==cs.re; sin(a)==cs.im;
		return [ 1.0, 0.0,    0.0,   0.0
		       , 0.0, cs.re,  cs.im, 0.0
		       , 0.0, -cs.im, cs.re, 0.0
		       , 0.0, 0.0,    0.0,   1.0 ];
	}
	static Matrix4 rotateYZMatrix(PRECISION a) { return Matrix4(m_rotateYZArray(a)); }
	ref Matrix4 rotateYZ(PRECISION a){return opOpAssign!("*")(m_rotateYZArray(a));}

	//
	static private PRECISION[] m_rotateZXArray(PRECISION a) pure
	{
		creal cs = expi(a);// cos(a)==cs.re; sin(a)==cs.im;
		return [ cs.re, 0.0, -cs.im, 0.0
		       , 0.0,   1.0, 0.0,    0.0
		       , cs.im, 0.0, cs.re,  0.0
		       , 0.0,   0.0, 0.0,    1.0 ];
	}
	static Matrix4 rotateZXMatrix(PRECISION a) { return Matrix4(m_rotateZXArray(a)); }
	ref Matrix4 rotateZX(PRECISION a){ return opOpAssign!("*")(m_rotateZXArray(a)); }

	static private PRECISION[] m_rotateXYArray(PRECISION a) pure
	{
		creal cs = expi(a); // cos(a)==cs.re; sin(a)==cs.im;
		return [ cs.re,  cs.im, 0.0, 0.0
		       , -cs.im, cs.re, 0.0, 0.0
		       , 0.0,    0.0,   1.0, 0.0
		       , 0.0,    0.0,   0.0, 1.0 ];
	}
	static Matrix4 rotateXYMatrix(PRECISION a) { return Matrix4(m_rotateXYArray(a)); }
	ref Matrix4 rotateXY(PRECISION a){ return opOpAssign!("*")(m_rotateXYArray(a));}

	// scaling
	static private PRECISION[] m_scaleArray(PRECISION x, PRECISION y, PRECISION z) pure nothrow
	{
		return [ x,   0.0, 0.0, 0.0
		       , 0.0, y,   0.0, 0.0
		       , 0.0, 0.0, z,   0.0
		       , 0.0, 0.0, 0.0, 1.0 ];
	}
	static Matrix4 scaleMatrix(PRECISION x, PRECISION y, PRECISION z)
	{
		return Matrix4(m_scaleArray(x,y,z));
	}
	ref Matrix4 scale(PRECISION x, PRECISION y, PRECISION z){return opOpAssign!("*")(m_scaleArray(x,y,z));}

	// projection
	static Matrix4 orthoMatrix( PRECISION left, PRECISION right, PRECISION bottom, PRECISION top
	                          , PRECISION near, PRECISION far )
	{
		auto rl1 = 1 / ( right - left );
		auto tb1 = 1 / ( top - bottom );
		auto fn1 = 1 / ( far - near );
		return Matrix4( 2 * rl1,             0.0,                 0.0,               0.0
		              , 0.0,                 2 * tb1,             0.0,               0.0
		              , 0.0,                 0.0,                 -2 * fn1,          0.0
		              , -(right+left) * rl1, -(top+bottom) * tb1, -(far+near) * fn1, 1.0 );
	}


	static Matrix4 frustumMatrix(PRECISION width, PRECISION height
	                             , PRECISION near, PRECISION far)
	{
		PRECISION fn1 = 1/(far-near);
		return Matrix4( 2*near/width, 0.0,           0.0,              0.0
		              , 0.0,          2*near/height, 0.0,              0.0
		              , 0.0,          0.0,           -(far+near)*fn1, -1.0
		              , 0.0,          0.0,           -2*far*near*fn1,  0.0 );
	}
	static Matrix4 frustumMatrixLH(PRECISION width, PRECISION height
	                             , PRECISION near, PRECISION far)
	{
		PRECISION fn1 = 1/(far-near);
		return Matrix4( -2*near/width, 0.0,            0.0,             0.0
		              , 0.0,           -2*near/height, 0.0,             0.0
		              , 0.0,           0.0,            -(far+near)*fn1, 1.0
		              , 0.0,           0.0,            2*far*near*fn1,  1.0 );
	}

	static Matrix4 perspectiveMatrix(PRECISION fovy, PRECISION asp
	                                 , PRECISION near, PRECISION far)
	{
		PRECISION f = 1/(tan(fovy*0.5*TO_RADIAN));
		PRECISION fn1 = 1/(far-near);
		return Matrix4( f/asp, 0.0, 0.0,              0.0
		              , 0.0,   f,   0.0,              0.0
		              , 0.0,   0.0, -(far+near)*fn1, -1.0
		              , 0.0,   0.0, -2*far*near*fn1,  0.0 );
	}

	static Matrix4 perspectiveMatrixLH(PRECISION fovy, PRECISION asp
	                                 , PRECISION near, PRECISION far)
	{
		PRECISION f = 1/(tan(fovy*0.5*TO_RADIAN));
		PRECISION nf = 1/(far-near);
		return Matrix4( f/asp, 0.0, 0.0,              0.0
		              , 0.0,   f,   0.0,              0.0
		              , 0.0,   0.0, -1*(far+near)*nf, 1.0
		              , 0.0,   0.0, 2*far*near*nf,    1.0 );
	}

	// viewing
	static Matrix4 lookForMatrix( in PRECISION[3] lf, in PRECISION[3] up)
	{
		Vector3!PRECISION z = Vector3!PRECISION( -lf[0], -lf[1], -lf[2] );
		z.normalize;
		Vector3!(PRECISION) x = cross(up,z);
		x.normalize;
		Vector3!(PRECISION) y = cross(z,x);

		return Matrix4( x.x, y.x, z.x, 0
		              , x.y, y.y, z.y, 0
		              , x.z, y.z, z.z, 0
		              , 0,   0,   0,   1 );
	}

	static Matrix4 lookAtMatrix( in PRECISION[3] eye, in PRECISION[3] center, in PRECISION[3] up )
	{
		Vector3!(PRECISION) z = Vector3!(PRECISION)(eye) - center;
		z.normalize;
		Vector3!(PRECISION) x = cross(up,z);
		x.normalize;
		Vector3!(PRECISION) y = cross(z,x);

		auto e = Vector3!(PRECISION)( -x.x*eye[0]-x.y*eye[1]-x.z*eye[2]
		                            , -y.x*eye[0]-y.y*eye[1]-y.z*eye[2]
		                            , -z.x*eye[0]-z.y*eye[1]-z.z*eye[2] );

		return Matrix4( x.x, y.x, z.x, 0
		              , x.y, y.y, z.y, 0
		              , x.z, y.z, z.z, 0
		              , e.x, e.y, e.z, 1 );
	}

	// inverse system
	PRECISION determinant() const nothrow
	{
		return (_11*_22*_33*_44) + (_11*_32*_43*_24) + (_11*_42*_23*_34)
		     + (_21*_12*_43*_34) + (_21*_32*_13*_44) + (_21*_42*_33*_14)
		     + (_31*_12*_23*_44) + (_31*_22*_43*_14) + (_31*_42*_13*_24)
		     + (_41*_12*_33*_24) + (_41*_22*_13*_34) + (_41*_32*_23*_14)
		     - (_11*_22*_43*_34) - (_11*_32*_23*_44) - (_11*_42*_33*_24)
		     - (_21*_12*_33*_44) - (_21*_32*_43*_14) - (_21*_42*_13*_34)
		     - (_31*_12*_43*_24) - (_31*_22*_13*_44) - (_31*_42*_23*_14)
		     - (_41*_12*_23*_34) - (_41*_22*_33*_14) - (_41*_32*_13*_24);
	}

	Matrix4 inverseMatrix() const
	{
		PRECISION det = determinant;
		if(det==0)return Matrix4( PRECISION.nan );
		PRECISION det1 = 1 / det;

		return Matrix4(
		  ((_22*_33*_44)+(_32*_43*_24)+(_42*_23*_34)-(_22*_43*_34)-(_32*_23*_44)-(_42*_33*_24))*det1//_11
		 ,((_12*_43*_34)+(_32*_13*_44)+(_42*_33*_14)-(_12*_33*_44)-(_32*_43*_14)-(_42*_13*_34))*det1//_12
		 ,((_12*_23*_44)+(_22*_43*_14)+(_42*_13*_24)-(_12*_43*_24)-(_22*_13*_44)-(_42*_23*_14))*det1//_13
		 ,((_12*_33*_24)+(_22*_13*_34)+(_32*_23*_14)-(_12*_23*_34)-(_22*_33*_14)-(_32*_13*_24))*det1//_14

		 ,((_21*_43*_34)+(_31*_23*_44)+(_41*_33*_24)-(_21*_33*_44)-(_31*_43*_24)-(_41*_23*_34))*det1//_21
		 ,((_11*_33*_44)+(_31*_43*_14)+(_41*_13*_34)-(_11*_43*_34)-(_31*_13*_44)-(_41*_33*_14))*det1//_22
		 ,((_11*_43*_24)+(_21*_13*_44)+(_41*_23*_14)-(_11*_23*_44)-(_21*_43*_14)-(_41*_13*_24))*det1//_23
		 ,((_11*_23*_34)+(_21*_33*_14)+(_31*_13*_24)-(_11*_33*_24)-(_21*_13*_34)-(_31*_23*_14))*det1//_24

		 ,((_21*_32*_44)+(_31*_42*_24)+(_41*_22*_34)-(_21*_42*_34)-(_31*_22*_44)-(_41*_32*_24))*det1//_31
		 ,((_11*_42*_34)+(_31*_12*_44)+(_41*_32*_14)-(_11*_32*_44)-(_31*_42*_14)-(_41*_12*_34))*det1//_32
		 ,((_11*_22*_44)+(_21*_42*_14)+(_41*_12*_24)-(_11*_42*_24)-(_21*_12*_44)-(_41*_22*_14))*det1//_33
		 ,((_11*_32*_24)+(_21*_12*_34)+(_31*_22*_14)-(_11*_22*_34)-(_21*_32*_14)-(_31*_12*_24))*det1//_34

		 ,((_21*_42*_33)+(_31*_22*_43)+(_41*_32*_23)-(_21*_32*_43)-(_31*_42*_23)-(_41*_22*_33))*det1//_41
		 ,((_11*_32*_43)+(_31*_42*_13)+(_41*_12*_33)-(_11*_42*_33)-(_31*_12*_43)-(_41*_32*_13))*det1//_42
		 ,((_11*_42*_23)+(_21*_12*_43)+(_41*_22*_13)-(_11*_22*_43)-(_21*_42*_13)-(_41*_12*_23))*det1//_43
		 ,((_11*_22*_33)+(_21*_32*_13)+(_31*_12*_23)-(_11*_32*_23)-(_21*_12*_33)-(_31*_22*_13))*det1//_44
		 );
	}
}

alias Matrix4!double Matrix4d;
alias Matrix4!float Matrix4f;

unittest
{
	auto mat = M4.perspectiveMatrix( 45, 1, 1, 3 ) * M4.lookAtMatrix( V3( 0, 0, 1 ), V3( 0, 0, 0 ), V3( 0, 1, 0 ) );;
	auto v = V3( 0, 0, -2 );
	auto v2 = mat * v;
	writeln( v2 );
}

unittest
{
	auto v = V3( 1, 1, 1 );
	auto v2 = v;
	auto m1 = M4.translateMatrix( 1.0, 2.0, 3.0 ).rotate( 0.1, 1.2, 0.3, -1.0 ).scale( 0.3, 0.4, 1.3);
	v = m1 * v;
	auto inv_m1 = m1.inverseMatrix();
	v = inv_m1 * v;
	assert( aEqual( v[], v2[] ) );

	auto m2 = M4.frustumMatrix( 680, 480, 1.0, -1.0 );
	auto m3 = M4.perspectiveMatrix( cast(float)(PI_2 * 0.5), 4 / 3, -1.0, 1.0 );
	auto m4 = M4.lookAtMatrix( [ 100.0f, 200.0f, 300.0f ], [ 0.0f, 0.0f, 0.0f ], [ 0.0f, 1.0f, 0.0f ] );
}

//======================================================================================\\
struct Arrow(PRECISION)
{
	Vector3!(PRECISION) p;
	Vector3!(PRECISION) v;

	this( in PRECISION[3] p, in PRECISION[3] v ){ this.p = p; this.v = v; }
}
alias Arrow!float Arrowf;

debug(util_matrix):

void main()
{
	version(unittest) writeln( "unittest is well done." );
}


