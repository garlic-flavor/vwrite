["summary": `VWRITE - Version WRITEr -
`,
"Version": `0.33(dmd2.070.0)
`,
"Date": "2016-Feb-21 20:41:29
",
"Authors": `KUMA
`,
"License": `CC0

`,
"Description:":`
This program appends some informations to your D source codes.
and modify your coding style.
Expected character coding of the source code is UTF-8(non-BOM) only.

`,
"Notice:":`
THIS PROGRAM WILL CHANGE YOUR PROJECT'S WHITE SPACING RULE ACCORDING TO
THE RULE OF DMD!

`,
"White spacing rule of DMD:":`
o '\t'(tab character) is not allowed.
o trailing spaces are not allowed.
o Newline sequence other than '\n'(unix style) is not allowed.


`,
"How to build:":`
** On Windows
Please use the make tool that is distributed with dmd.
** 32bit Windows
>make -f win.mak release
** 64bit Windows
>make -f win.mak release FLAG=-m64
** On linux
>make -f linux64.mak release


`,
"How to use:":`
>vwrite [OPT...] source.d[...]


** Options
option              | description
                    |
-h --help -? /?     | show help messages and exit.
--version           | show the version of vwrite.
                    |
--authors YOU       | set the project's author as YOU.
--license LICENSE   |  put your project to under LICENSE.
--project MYPROJECT | set your project's name as MYPROJECT
--setversion XXX.x  | set your project's version string as XXX.x.

`,
"What will this program do:":`
this program will do,


* read informations about your project from command line arguments.
    * '--project MYPROJECT' gives the name of the project.
    * '--setversion XXX.x' gives the description of the version.
    * '--authors YOU' gives names of authors.
    * '--license LICENSE' gives an information about the license.



* read file names from arguments. and select files that
      have '.d' or '.di' extension.


* read each files and do replacement accroding to the manners below.
    * replace '\r\n' with '\n'.
    * replace '\r' with '\n'.
    * replace '\t' with '    '(four sequential spaces).
    * remove tailing spaces.
    * replace 'Project:' with 'Project: MYPROJECT'.
    * replace 'enum _PROJECT_ ="";' with 'enum _PROJECT_="MYPROJECT".
    * replace 'Version:' with 'Version: XXX.x(dmdY.YYY.Y)'.
    * replace 'enum _VERSION_ = "";' with
          'enum _VERSION_="XXX.x(dmdY.YYY.Y)".
    * replace 'Date:' with 'Date: YYYY-MON-DD HH:MM:SS'.
    * replace 'Authors:' with 'Authors: YOU'.
    * replace 'enum _AUTHORS_ = "";' with 'enum _AUTHORS_ = "YOU";'.
    * replace 'License:' with 'License: LICENSE'.
    * replace 'enum _LICENSE_ = "";' with
          'enum _LICENSE_ = "LICENSE";'.
    * replace 'if' with 'if '.
    * replace 'for' with 'for '.
    * replace 'foreach' with 'foreach '.
    * replace 'version' with 'version '.
    * replace 'catch' with 'catch '.



* output to the file.
* rewind the modified time of the file.


`,
"Acknowledgements:":`
o vwrite is written by D Programming Language.
  Digital Mars D Programming Language(http://dlang.org/)


`,
"Development Environment:":`
o Windows Vista(x64) x dmd 2.070.0 x make(of Digital Mars)
o Ubuntu 15.10(amd64) x dmd 2.069.2 x gcc 5.2.1


`,
"License description:":`
Creative Commons Zero License(http://creativecommons.org/publicdomain/zero/1.0/)

`,
"History": `
o 2016-01-29 ver. 0.32(dmd2.070.0)
  The version information of dmd is added to the user specified string
  automatically.


o 2015-12-16 ver. 0.31(dmd2.069.2)
  add replacing rule for 'if ', 'for ',
  'foreach ',
  'version ', 'catch '.


o 2015 12/14 ver. 0.30(dmd2.069.2)
  add japanese messages.


o 2015 12/13 ver. 0.29(dmd2.069.2)
  fully brush up.
    o delete v-style.xml.
    o use command line argument for all settings.
    o delete -target.
    o add checking process of white spacing style.
    o add English README.md.






`,
"はじめにお読み下さい:":`
これは D言語で書かれたソースコードにヴァージョン情報を付加するプログラムです。
ソースコードに使える文字コードは UTF-8(non-BOM) のみです。



`,
"注意:":`
このプログラムは対象ソースコードの改行コードとインデント文字を変更します!

`,
"DMDルール:":`
o '\t'(タブ文字)を使わない。
o 行末の空白文字はだめ。
o 改行コードは'\n'のみ。


`,
"ビルド方法:":`
** Windowsでは
DMDに付属のmakeを使ってください。
** 32bit版では
>make -f win.mak release FLAG=-version=InJapanese
** 64bit版では
>make -f win.mak release FLAG="-version=InJapanese -m64"
** linuxでは
>make -f linux64.mak release FLAG=-version=InJapanese


`,
"使い方:":`
コマンドラインから使います。
>vwrite --setversion=x.x source.d [...]


** オプション
引数                |説明
                    |
-h --help -? /?     |ヘルプメッセージを出力します。
                    |
--authors 名無し    |プロジェクトの著者を'名無し'とします。
--license NYSL      |プロジェクトのライセンスを'NYSL'とします。
--project MYPROJECT |プロジェクト名を'MYPROJECT'とします。
--setversion XXX.x  |ヴァージョン文字列を指定します。
--version           |vwrite のヴァージョン情報を表示します。

`,
"このプログラムは何をしますか:":`
このプログラムは、


* コマンドライン引数より、プロジェクトに関する以下の情報を得ます。
    * --project MYPROJECT プロジェクトの名前を指定します。
    * --setversion XXX.x ヴァージョン情報を指定します。
    * --authors YOU 著者名を指定します。
    * --license LICENSE ライセンス情報を指定します。



* コマンドライン引数より拡張子が'.d'又は'.di'のファイル名のものを選びます。


* それぞれのファイルに対して以下の置換を行います。
    * '\r\n' を '\n' に
    * '\r' を '\n'に
    * '\t' を '    '(スペース4個)に
    * 行末の空白文字の消去
    * 'Project:' を 'Project: MYPROJECT'に
    * 'enum _PROJECT_ ="";' を 'enum _PROJECT_="MYPROJECT"に
    * 'Version:' を 'Version: XXX.x'に
    * 'enum _VERSION_ = "";' を 'enum _VERSION_="XXX.x(dmdY.YYY.Y)"に
    * 'Date:\' を 'Date: YYYY-MON-DD HH:MM:SS'に
    * 'Authors:' を 'Authors: YOU'に
    * 'enum _AUTHORS_ = "";' を 'enum _AUTHORS_ = "YOU";'に
    * 'License:' を 'License: LICENSE'に
    * 'enum _LICENSE_ = "";' を 'enum _LICENSE_ = "LICENSE";'に
    * 'if' を 'if 'に
    * 'for' を 'for 'に
    * 'foreach' を 'foreach 'に
    * 'version' を 'version 'に
    * 'catch' を 'catch 'に



* 同じファイルに出力します。
* ファイルの最終編集時刻を書き戻します。


`,
"謝辞:":`
o vwrite は D言語で書かれています。
  Digital Mars D Programming Language(http://dlang.org/)


`,
"開発環境:":`
o Windows Vista(x64) x dmd 2.070.0 x (Digital Marsの)make
o Ubuntu 15.10(amd64) x dmd 2.069.2 x gcc 5.2.1


`,
"ライセンス:":`
Creative Commons Zero License(http://creativecommons.org/publicdomain/zero/1.0/)

`,
"履歴:":`
o 2016-01-29 ver. 0.32(dmd2.070.0)
  dmdのヴァージョン情報は自動的に付加されるようになりました。


o 2015-12-16 ver. 0.31(dmd2.069.2)
  'if ', 'for ', 'foreach ', 'version ',
  'catch ' に関する変換を追加。


o 2015 12/14 ver. 0.30(dmd2.069.2)
  日本語メッセージの追加。


o 2015 12/13 ver. 0.29(dmd2.069.2)
  全面刷新。
    o v-style.xml の廃止
    o 情報はコマンドライン引数で指定するように。
    o -target の廃止
    o 空白文字に関する慣習をDMD準拠に。
    o 英語版 README.md の追加。



o 2013 03/02 ver. 0.28(dmd2.062)
  linuxで v-style.xml を探せないバグの修正。


o 2012 10/28 ver. 0.27(dmd2.060)
  -target で指定したファイルより新しいもののみ更新するように変更しました。


o 2012 10/27 ver. 0.26(dmd2.060)
  GitHub デビュー


o 2012  2/21  ver. 0.24 for dmd2.058
  some bugs are fixed.


o 2010  3/14  ver. 0.22
  for dmd2.041. but no change occur.


o 2009 10/20  ver. 0.21
  for dmd2.035.


o 2009  9/ 1  ver. 0.1
  First released version.
`,

"": ""]
