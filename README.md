VWRITE - Version WRITEr -
=========================
This program appends some informations to your D source codes.
and modify your coding style.

Expected character coding of the source code is UTF-8(non-BOM) only.

_!!!NOTICE!!!_
--------
__THIS PROGRAM WILL CHANGE YOUR PROJECT'S WHITE SPACING RULE ACCORDING TO
THE RULE OF DMD!__

WHITE SPACING RULE OF DMD
-------------------------
* `'\t'`(tab character) is not allowed.
* trailing spaces are not allowed.
* Newline sequence other than `'\n'`(unix style) is not allowed.

HOW TO USE
----------

    >vwrite [OPT...] source.d[...]

### Options

    -h --help -? /?     : show help messages and exit.
    --version           : show the version of vwrite.

    --authors YOU       : set the project's author as YOU.
    --license LICENSE   : put your project to under LICENSE.
    --project MYPROJECT : set your project's name as MYPROJECT
    --setversion XXX.x  : set your project's version string as XXX.x.


WHAT WILL THIS PROGRAM DO?
--------------------------
this program will

1. read informations about your project from command line arguments.
   1. `'--project MYPROJECT'` gives the name of the project.
   2. `'--setversion XXX.x'` gives the description of the version.
   3. `'--authors YOU'` gives names of authors.
   4. `'--license LICENSE'` gives an information about the license.

2. read file names from arguments. and select files that
   have `'.d'` or `'.di'` extension.

3. read each files and do replacement accroding to the manners below.
   1. replace `'\r\n'` with `'\n'`.
   2. replace `'\r'` with `'\n'`.
   3. replace `'\t'` with `'    '`(four sequential spaces).
   4. remove tailing spaces.
   5. replace `'Project:'` with `'Project: MYPROJECT'`.
   6. replace `'enum _PROJECT_ ="";'` with `'enum _PROJECT_="MYPROJECT"`.
   7. replace `'Version:'` with `'Version: XXX.x'`.
   8. replace `'enum _VERSION_ = "";'` with `'enum _VERSION_="XXX.x"`.
   9. replace `'Date:\'` with `'Date: YYYY-MON-DD HH:MM:SS'`.
   10. replace `'Authors:'` with `'Authors: YOU'`.
   11. replace `'enum _AUTHORS_ = "";'` with `'enum _AUTHORS_ = "YOU";'`.
   12. replace `'License:'` with `'License: LICENSE'`.
   13. replace `'enum _LICENSE_ = "";'` with `'enum _LICENSE_ = "LICENSE";'`.
   14. replace `'if('` with `'if ('`.
   15. replace `'for('` with `'for ('`.
   16. replace `'foreach('` with `'foreach ('`.
   17. replace `'version('` with `'version ('`.
   18. replace `'catch('` with `'catch ('`.

4. output to the file.
5. rewind the modified time of the file.

ACKNOWLEDGEMENTS
----------------
* vwrite is written by D Programming Language.->
[Digital Mars D Programming Language](http://dlang.org/"D PROGRAMMING LANGUAGE")


DEVELOPMENT ENVIRONMENT
-----------------------
* Ubuntu 15.10(amd64) x dmd 2.069.2 x gcc 5.2.1


LICENSE
-------
[CC0](http://creativecommons.org/publicdomain/zero/1.0/ "Creative Commons Zero License")


HISTORY
-------
- 2015-12-16 ver. 0.31(dmd2.069.2)

  add replacing rule for `'if ('`, `'for ('`, `'foreach ('`, `'version ('`,
  `'catch ('`.


- 2015 12/14 ver. 0.30(dmd2.069.2)

  add japanese messages.


- 2015 12/13 ver. 0.29(dmd2.069.2)

  fully brush up.

  + delete v-style.xml.
  + use command line argument for all settings.
  + delete -target.
  + add checking process of white spacing style.
  + add English README.md.


* * *


はじめにお読み下さい。 - VWRITE -
=================================
これは D言語で書かれたソースコードにヴァージョン情報を付加するプログラムです。

ソースコードに使える文字コードは UTF-8(non-BOM) のみです。


_!!!注意!!!_
------------

__このプログラムは対象ソースコードの改行コードとインデント文字を変更します!__


DMDルール
---------
* `'\t'`(タブ文字)を使わない。
* 行末の空白文字はだめ。
* 改行コードは`'\n'`のみ。


使い方
------
コマンドラインから使います。

    >vwrite --setversion=x.x source.d [...]


### オプション

    -h --help -? /?     : ヘルプメッセージを出力します。

    --authors 名無し    : プロジェクトの著者を'名無し'とします。
    --license NYSL      : プロジェクトのライセンスを'NYSL'とします。
    --project MYPROJECT : プロジェクト名を'MYPROJECT'とします。
    --setversion XXX.x  : ヴァージョン文字列を指定します。
    --version           : vwrite のヴァージョン情報を表示します。


このプログラムは何をしますか？
------------------------------
このプログラムは、
1. コマンドライン引数より、プロジェクトに関する以下の情報を得ます。
   1. `--project MYPROJECT` プロジェクトの名前を指定します。
   2. `--setversion XXX.x` ヴァージョン情報を指定します。
   3. `--authors YOU` 著者名を指定します。
   4. `--license LICENSE` ライセンス情報を指定します。

2. コマンドライン引数より拡張子が`'.d'`又は`'.di'`のファイル名のものを選びます。

3. それぞれのファイルに対して以下の置換を行います。
   1. `'\r\n'` を `'\n'` に
   2. `'\r'` を `'\n'`に
   3. `'\t'` を `'    '`(スペース4個)に
   4. 行末の空白文字の消去
   5. `'Project:'` を `'Project: MYPROJECT'`に
   6. `'enum _PROJECT_ ="";'` を `'enum _PROJECT_="MYPROJECT"`に
   7. `'Version:'` を `'Version: XXX.x'`に
   8. `'enum _VERSION_ = "";'` を `'enum _VERSION_="XXX.x"`に
   9. `'Date:\'` を `'Date: YYYY-MON-DD HH:MM:SS'`に
   10. `'Authors:'` を `'Authors: YOU'`に
   11. `'enum _AUTHORS_ = "";'` を `'enum _AUTHORS_ = "YOU";'`に
   12. `'License:'` を `'License: LICENSE'`に
   13. `'enum _LICENSE_ = "";'` を `'enum _LICENSE_ = "LICENSE";'`に
   14. `'if('` を `'if ('`に
   15. `'for('` を `'for ('`に
   16. `'foreach('` を `'foreach ('`に
   17. `'version('` を `'version ('`に
   18. `'catch('` を `'catch ('`に

4. 同じファイルに出力します。
5. ファイルの最終編集時刻を書き戻します。


謝辞
----
* vwrite は D言語で書かれています。->[Digital Mars D Programming Language](http://dlang.org/ "D PROGRAMMING LANGUAGE")


開発環境
--------
* Ubuntu 15.10(amd64) x dmd 2.069.2 x gcc 5.2.1


ライセンス
----------
[CC0](http://creativecommons.org/publicdomain/zero/1.0/ "Creative Commons Zero License")


履歴
----
- 2015-12-16 ver. 0.31(dmd2.069.2)

  `'if ('`, `'for ('`, `'foreach ('`, `'version ('`, `'catch ('`
  に関する変換を追加。


- 2015 12/14 ver. 0.30(dmd2.069.2)

  日本語メッセージの追加。


- 2015 12/13 ver. 0.29(dmd2.069.2)

  全面刷新。

  + v-style.xml の廃止
  + 情報はコマンドライン引数で指定するように。
  + -target の廃止
  + 空白文字に関する慣習をDMD準拠に。
  + 英語版 README.md の追加。


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

