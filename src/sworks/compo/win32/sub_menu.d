/** sub_menu.d for padm.exe
 * \version      0.0005 dmd2.055
 * \date         2011-Sep-21 02:47:54
 * \author       KUMA
 * \par license:
 * CC0
 */
module sworks.compo.win32.sub_menu;
import std.utf;
import sworks.compo.win32.port;
import sworks.compo.win32.util;

/*
 * 右クリックで出すメニューのラッパ
 */
class SubMenu
{
  HWND hMenu;
  alias hMenu this;

  this()
  {
    hMenu = CreatePopupMenu();
  }

  ~this()
  {
    DestroyMenu( hMenu );
  }

  void append( wstring name, uint id, uint upperOf = 0, uint state = 0 )
  {
    MENUITEMINFO mii;
    with( mii )
    {
      cbSize =  MENUITEMINFO.sizeof;
      fMask =  MIIM_TYPE | MIIM_ID | (state?MIIM_STATE:0) ;
      fType =  MFT_STRING;
      fState = state;
      wID =  id;
      dwTypeData =  cast(wchar*)toUTF16z(name);
      cch =  name.length;
    }
    InsertMenuItem( hMenu, upperOf, false, &mii );
  }

  void append( wstring name, HMENU sub, uint upperOf = 0, uint state = 0)
  {
    MENUITEMINFO mii;
    with( mii )
    {
      cbSize =  MENUITEMINFO.sizeof;
      fMask =  MIIM_TYPE | MIIM_SUBMENU | (state?MIIM_STATE:0);
      fType =  MFT_STRING;
      fState = state;
      hSubMenu = sub;
      dwTypeData =  cast(wchar*)toUTF16z(name);
      cch =  name.length;
    }
    InsertMenuItem( hMenu, upperOf, false, &mii );
  }

  void append_separator( uint upperOf = 0 )
  {
    MENUITEMINFO mii;
    with( mii )
    {
      cbSize = MENUITEMINFO.sizeof;
      fMask = MIIM_FTYPE;
      fType = MFT_SEPARATOR;
    }
    InsertMenuItem( hMenu, upperOf, false, &mii );
  }

  void start( HWND parent, int x, int y )
  {
    SetForegroundWindow( parent );
    TrackPopupMenu( hMenu, TPM_BOTTOMALIGN, x, y, 0, parent, null );
  }
}