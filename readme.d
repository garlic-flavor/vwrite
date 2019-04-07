/** generate readme.

   Date:       2019-Apr-01 23:08:47
   Authors:    KUMA
   License:    CC0
 */
module readme;
import sworks.base.readmegen;

enum _VERSION_ = "0.35(dmd2.085.0)";
enum _DATE_ = "2019-Apr-01 23:08:47";

void proc (string locale = "")
{
    if (0 < locale.length && !_.setlocale(locale))
        return;

    h1("Version WRITEr");
    putln;
    b("Version:")(" " ~ _VERSION_).ln;
    b("Date:")(" " ~ _DATE_).ln;
    b("Authors:")(" KUMA").ln;
    b("License:")(" CC0").ln;

    h2._("Description");
    exec("vwrite", "--help", "description", "--lang", locale).putln;

    h2._("Acknowledgements");
    _("vwrite is written by D Programming Language.").ln;
    _("Digital Mars D Programming Language").link("http://dlang.org/").ln;
    putln;
    _("vwrite depends on Mofile as a submodule.").ln;
    _("Mofile").link("https://github.com/FreeSlave/mofile.git").ln;

    h2._("Notice");
    b._("THIS PROGRAM WILL CHANGE YOUR PROJECT'S WHITE SPACING RULE ACCORDING TO THE RULE OF DMD!").ln;

    h2._("White spacing rule of DMD");
    list._("`'\t'`(tab character) is not allowed.");
    list._("trailing spaces are not allowed.");
    list._("Newline sequence other than `'\\n'`(unix style) is not allowed.");

    h2._("How to build");
    h3._("On Windows");
    _("Please use the make tool that is distributed with dmd.").ln;
    h3("32bit Windows");
    ">make -f win.mak release".pre;
    h3("64bit Windows");
    ">make -f win.mak release FLAG=-m64".pre;
    h3("On linux");
    ">make -f linux64.mak release".pre;

    h2._("How to use");
    exec("vwrite", "-h", "how_to_use", "-lang", locale).pre;

    h2._("Options");
    exec("vwrite", "-h", "options", "-lang", locale).putln;

    h2._("What will this program do");
    _("this program will do,").ln;
    putln;
    elist._("read informations about your project from command line arguments.");
    1.elist._("`'--setversion XXX.x'` gives the description of the version.");
    elist._("read file names from arguments. and select files that");
    1.elist._("have `'.d'` or `'.di'` extension.");
    elist._("read each files and do replacement accroding to the manners below.");
    1.elist._("replace `'\\r\\n'` with `'\\n'`.");
    1.elist._("replace `'\\r'` with `'\\n'`.");
    1.elist._("replace `'\\t'` with `'    '`(four sequential spaces).");
    1.elist._("remove tailing spaces.");
    1.elist._("replace `Version:` with `Version: XXX.x(dmdY.YYY.Y)`.");
    1.elist._("replace `enum _VERSION_ = \"\";` with `enum _VERSION_=\"XXX.x(dmdY.YYY.Y)\";`.");
    1.elist._("replace `Date:` with `Date: YYYY-MON-DD HH:MM:SS`.");
    1.elist._("replace `if(` with `if (`.");
    1.elist._("replace `for(` with `for (`.");
    1.elist._("replace `foreach(` with `foreach (`.");
    1.elist._("replace `version(` with `version (`.");
    1.elist._("replace `catch(` with `catch (`.");
    elist._("output to the file.");
    elist._("rewind the modified time of the file.");

    h2._("Development Environment");
    list(0)("Windows Vista(x64) x dmd 2.070.0 x make(of Digital Mars)");
    list(0)("Ubuntu 15.10(amd64) x dmd 2.070.0 x gcc 5.2.1");

    h2._("License description");
    _("Creative Commons Zero License").link("http://creativecommons.org/publicdomain/zero/1.0/").ln;

    h2._("History");
    history("2019-Apr-01 16:42:32 ver. 0.35(dmd2.085.0)")
        ._("implement i18n and japanese l10n.");

    history("2016-02-28 ver. 0.034(dmd2.070.0)")
        ._("--authors, --project and --license are removed.");

    history("2016-02-22 ver. 0.33(dmd2.070.0)")
        ._("README.md and the commandline help message are generated automatically by ddoc. add 'Dmd:', ddoc section.");

    history("2016-01-29 ver. 0.32(dmd2.070.0)")
        ._("The version information of dmd is added to the user specified string automatically.");

    history("2015-12-16 ver. 0.31(dmd2.069.2)")
        ._("add replacing rule for `'if ('`, `'for ('`, `'foreach ('`, `'version ('`, `'catch ('`.");

    history("2015 12/14 ver. 0.30(dmd2.069.2)")
        ._("add japanese messages.");

    history("2015 12/13 ver. 0.29(dmd2.069.2)")
        ._("fully brush up.")
        ._("delete v-style.xml.")
        ._("use command line argument for all settings.")
        ._("delete -target.")
        ._("add checking process of white spacing style.")
        ._("add English README.md.");

    history("2013 03/02 ver. 0.28(dmd2.062)")
        ._("fix a bug about searching for v-style.xml on linux.");

    history("2012 10/28 ver. 0.27(dmd2.060)")
        ._("add `'-target'` to set a needle file to filter that newer than the needle will pass.");

    history("2012 10/27 ver. 0.26(dmd2.060)")
        ._("debut on GitHub.");

    history("2012  2/21  ver. 0.24 for dmd2.058")
        ._("some bugs are fixed.");

    history("2010  3/14  ver. 0.22")
        ._("for dmd2.041. but no change occur.");

    history("2009 10/20  ver. 0.21")
        ._("for dmd2.035.");

    history("2009  9/ 1  ver. 0.1")
        ._("First released version.");
}

/+

* * *


## はじめにお読み下さい:
これは D言語で書かれたソースコードにヴァージョン情報を付加するプログラムです。
ソースコードに使える文字コードは UTF-8(non-BOM) のみです。




## 注意:
__このプログラムは対象ソースコードの改行コードとインデント文字を変更します!__


## DMDルール:
- `'\t'`(タブ文字)を使わない。
- 行末の空白文字はだめ。
- 改行コードは`'\n'`のみ。



## ビルド方法:
### Windowsでは
DMDに付属のmakeを使ってください。
### 32bit版では

    >make -f win.mak release FLAG=-version=InJapanese
### 64bit版では

    >make -f win.mak release FLAG="-version=InJapanese -m64"
### linuxでは

    >make -f linux64.mak release FLAG=-version=InJapanese



## 使い方:
コマンドラインから使います。

    >vwrite --setversion=x.x source.d [...]


### オプション
引数                |説明
--------------------|--------------------
-h --help -? /?     |ヘルプメッセージを出力します。
--version           |vwrite のヴァージョン情報を表示します。
--setversion XXX.x  |ヴァージョン文字列を指定します。




## このプログラムは何をしますか:
このプログラムは、


1. コマンドライン引数より、プロジェクトに関する以下の情報を得ます。
    1. `--setversion XXX.x` ヴァージョン情報を指定します。



1. コマンドライン引数より拡張子が`'.d'`又は`'.di'`のファイル名のものを選びます。


1. それぞれのファイルに対して以下の置換を行います。
    1. `'\r\n'` を `'\n'` に
    1. `'\r'` を `'\n'`に
    1. `'\t'` を `'    '`(スペース4個)に
    1. 行末の空白文字の消去
    1. `'Version:'` を `'Version: XXX.x'`に
    1. `'enum _VERSION_ = "";'` を `'enum _VERSION_="XXX.x(dmdY.YYY.Y)"`に
    1. `'Date:\'` を `'Date: YYYY-MON-DD HH:MM:SS'`に
    1. `'if ('` を `'if ('`に
    1. `'for ('` を `'for ('`に
    1. `'foreach ('` を `'foreach ('`に
    1. `'version ('` を `'version ('`に
    1. `'catch ('` を `'catch ('`に



1. 同じファイルに出力します。
1. ファイルの最終編集時刻を書き戻します。



## 謝辞:
- vwrite は D言語で書かれています。
  [Digital Mars D Programming Language(http://dlang.org/)](http://dlang.org/)



## 開発環境:
- Windows Vista(x64) x dmd2.070.0 x (Digital Marsの)make
- Ubuntu 15.10(amd64) x dmd2.070.0 x gcc 5.2.1



## ライセンス:
[Creative Commons Zero License(http://creativecommons.org/publicdomain/zero/1.0/)](http://creativecommons.org/publicdomain/zero/1.0/)


## 履歴:
- 2016-02-28 ver. 0.34(dmd2.070.0)
  --authors, --license, --project がなくなりました。


- 2016-02-22 ver. 0.33(dmd2.070.0)
  README.md と コマンドラインヘルプメッセージはddocで生成するようになりました。
  'Dmd:' の見出しに対してdmdのヴァージョン情報を出力します。


- 2016-01-29 ver. 0.32(dmd2.070.0)
  dmdのヴァージョン情報は自動的に付加されるようになりました。


- 2015-12-16 ver. 0.31(dmd2.069.2)
  `'if ('`, `'for ('`, `'foreach ('`, `'version ('`,
  `'catch ('` に関する変換を追加。


- 2015 12/14 ver. 0.30(dmd2.069.2)
  日本語メッセージの追加。


- 2015 12/13 ver. 0.29(dmd2.069.2)
  全面刷新。
    - v-style.xml の廃止
    - 情報はコマンドライン引数で指定するように。
    - -target の廃止
    - 空白文字に関する慣習をDMD準拠に。
    - 英語版 README.md の追加。



- 2013 03/02 ver. 0.28(dmd2.062)
  linuxで v-style.xml を探せないバグの修正。


- 2012 10/28 ver. 0.27(dmd2.060)
  -target で指定したファイルより新しいもののみ更新するように変更しました。


- 2012 10/27 ver. 0.26(dmd2.060)
  GitHub デビュー


- 2012  2/21  ver. 0.24 for dmd2.058
  some bugs are fixed.


- 2010  3/14  ver. 0.22
  for dmd2.041. but no change occur.


- 2009 10/20  ver. 0.21
  for dmd2.035.


- 2009  9/ 1  ver. 0.1
  First released version.



+/

void main ()
{
    _.openFile("README.md");
    _.projectName = "readme";

    proc;
    putln;
    hl;
    putln;
    proc("ja");
}
