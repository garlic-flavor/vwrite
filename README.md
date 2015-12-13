VWRITE - Version WRITEr -
=========================
This program appends some informations to your D source code.

Expected character code of the source code is UTF-8(non-BOM) only.

_!!!NOTICE!!!_
--------
__THIS PROGRAM WILL CHANGE YOUR PROJECT'S WHITE SPACING RULE ACCRODING TO
THE RULE OF DMD!__

WHITE SPACING RULE OF DMD
-------------------------
* `'\t'`(tab character) is not allowed.
* trailing spaces are not allowed.
* Newline sequence other than `'\n'`(unix style) is not allowed.

HOW TO USE
----------

    >vwrite --setversion x.x source.d

### Options

    -h --help -? /?     : show help messages and exit.

    --authors YOU       : set the project's author as YOU.
    --license LICENSE   : put your project to under LICENSE.
    --project MYPROJECT : set your project's name as MYPROJECT
    --setversion XXX.x  : set your project's version string as XXX.x.
    --version           : show the version of vwrite.


ACKNOWLEDGEMENTS
----------------
* vwrite is written by D Programming Language.->
[Digital Mars D Programming Language](http://dlang.org/"D PROGRAMMING LANGUAGE")

LICENSE
-------
[CC0](http://creativecommons.org/publicdomain/zero/1.0/ "Creative Commons Zero License")


HISTORY
-------
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


謝辞
----
* vwrite は D言語で書かれています。->[Digital Mars D Programming Language](http://dlang.org/ "D PROGRAMMING LANGUAGE")


ライセンス
----------
[CC0](http://creativecommons.org/publicdomain/zero/1.0/ "Creative Commons Zero License")


履歴
----
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

