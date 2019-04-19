/** i18n と l10n の実装

Description:
  https://github.com/FreeSlave/mofile.git を利用して$(LINK2 gettext, https://www.gnu.org/software/gettext/)を呼び出し、多言語化処理を実装する。
 */
module sworks.base.mo;

import mofile; // https://github.com/FreeSlave/mofile.git
debug import std.stdio: writeln;

/**

How_To_Use:

$(DDOC_SECTION_H gettextの使い方)
$(OL
  $(LI テンプレートを出力する。
---
xgettext --from-code=UTF-8 --language=C -k_ main.d subroutine.d -o l10n/project/messages.pot
---
  )

  $(LI 特定ロケール用のPOファイルを出力する。
---
msginit --locale=ja_JP.utf8 -i l10n/project/messages.pot -o l10n/project/ja_JP.utf8.po --no-translator
---
  )

  $(LI MOファイルへとコンパイルする。
---
msgfmt l10n/project/ja_JP.utf8.po -o l10n/project/ja_JP.utf8.mo
---
  )

  $(LI 更新されたテンプレートをPOファイルに適用する。
---
msgmerge --update l10n/project/ja_JP.utf8.po l10n/project/messages.pot
---
  )
)

$(DDOC_SECTION_H 想定されているフォルダ構成)
---
- root -+- l10n -+- project_name -+- messages.pot
        |                         +- ja_JP.utf8.po
        |                         +- ja_JP.utf8.mo
        |                         +- ...
        |
        +- src -+- package_name -+- src1.d
        |       |                +- src2.d
        |       |                +...
        |       |
        |       +- another_pkg -+- srcA.d
        |                       +- srcB.d
        |                       +...
        +- application.exe
        +- ...
---

 */
struct MoUtil
{
    /// moファイルが入っているルートディレクトリを指定する。初期値は "l10n"。
    @property @safe @nogc pure nothrow
    void basePath(string p)
    {
        _basePath = p;
    }

    @property @safe @nogc pure nothrow
    void projectName(string p)
    {
        _projectName = p;
    }

    /// moファイル用のルートディレクトリを "l10n" に設定する。
    @safe @nogc pure nothrow
    void restoreDefaultPath()
    {
        _basePath = null;
    }

    /** ロケールを設定する。

    Return:
        指定したロケールのmoファイルが見つかったら true を、
        見つからなかったら false を返す。
     */
    @safe
    bool setlocale(string loc)
    {
        string path;
        if (check(loc, path))
        {
            file = MoFile(path);
            return true;
        }
        else
            return false;
    }

    /// moファイルを参照しない。
    @safe @nogc pure nothrow
    void unsetlocale()
    {
        file = MoFile.init;
    }

    /// gettext を呼び出す。
    auto opCall(OPT...)(string s, OPT opt) const
    {
        import std.format: format;
        return file.gettext(s).format(opt);
    }

    /// gettext を呼び出す。(Lazy evaluation.)
    auto _(OPT...)(string s, OPT opt) const
    {
        return ()=>opCall(s, opt);
    }

private:

    version (Windows)
        enum _defaultPath = "l10n";
    else
        enum _defaultPath = "/usr/local/etc";

    enum _moFileExtension = "mo";


    @safe
    bool check(string loc, out string path)
    {
        import std.array: split;
        import std.path: buildPath, setExtension, dirName;
        import std.file: exists, isFile, thisExePath;
        import std.range: retro, drop;
        import std.algorithm: findAmong;

        if (0 == _basePath.length)
        {
            version (Windows)
                _basePath = thisExePath.dirName.buildPath(_defaultPath);
            else
                _basePath = _defaultPath;
        }

        version (Windows)
            path = _basePath.buildPath(_projectName, loc)
                .setExtension(_moFileExtension);
        else
            path = _basePath.buildPath(_projectName, "l10n", loc)
                .setExtension(_moFileExtension);

        if      (path.exists && path.isFile)
            return true;
        else if ((loc = loc.retro.findAmong(['_', '.', '@']).drop(1).retro)
                 .length)
            return check(loc, path);
        else
            return false;
    }

    string _basePath;
    string _projectName;
    MoFile file;
}

/**

このモジュールを読み込んだ先で、
---
throw new Exception(_("fugafuga: %s", fugafuga));
---
のようにして使う。
 */
MoUtil _;
