module sworks.compo.win32.dll_main;

import core.runtime;
import sworks.compo.win32.port;

HINSTANCE g_hInst;

/*
 * DLLにしたい場合は、このファイルと一緒にコンパイルする。
 */
extern( Windows ) bool DllMain( HINSTANCE hInstance, uint ulReason, void* pvReserved )
{
	switch( ulReason )
	{
		case DLL_PROCESS_ATTACH:
			Runtime.initialize();
		break; case DLL_PROCESS_DETACH:
			Runtime.terminate();
		break; case DLL_THREAD_ATTACH:
		       case DLL_THREAD_DETACH:
		       default:
			return false;
	}
	g_hInst = hInstance;
	return true;
}
