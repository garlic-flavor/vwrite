# VWRITE - Version WRITEr -


__Version:__ 0.33(dmd2.070.0)

__Date:__ 2016-Feb-21 20:41:29

__Authors:__ KUMA

__License:__ CC0


## Description:
This program appends some informations to your D source codes.
and modify your coding style.
Expected character coding of the source code is UTF-8(non-BOM) only.


## Notice:
__THIS PROGRAM WILL CHANGE YOUR PROJECT'S WHITE SPACING RULE ACCORDING TO
THE RULE OF DMD!__


## White spacing rule of DMD:
- `'\t'`(tab character) is not allowed.
- trailing spaces are not allowed.
- Newline sequence other than `'\n'`(unix style) is not allowed.



## How to build:
### On Windows
Please use the make tool that is distributed with dmd.
### 32bit Windows

    >make -f win.mak release
### 64bit Windows

    >make -f win.mak release FLAG=-m64
### On linux

    >make -f linux64.mak release



## How to use:

    >vwrite [OPT...] source.d[...]


### Options
option              | description
-                    |-
-h --help -? /?     | show help messages and exit.
--version           | show the version of vwrite.
                    |
--authors YOU       | set the project's author as YOU.
--license LICENSE   |  put your project to under LICENSE.
--project MYPROJECT | set your project's name as MYPROJECT
--setversion XXX.x  | set your project's version string as XXX.x.


## What will this program do:
this program will do,


1. read informations about your project from command line arguments.
    1. `'--project MYPROJECT'` gives the name of the project.
    1. `'--setversion XXX.x'` gives the description of the version.
    1. `'--authors YOU'` gives names of authors.
    1. `'--license LICENSE'` gives an information about the license.



1. read file names from arguments. and select files that
      have `'.d'` or `'.di'` extension.


1. read each files and do replacement accroding to the manners below.
    1. replace `'\r\n'` with `'\n'`.
    1. replace `'\r'` with `'\n'`.
    1. replace `'\t'` with `'    '`(four sequential spaces).
    1. remove tailing spaces.
    1. replace `'Project:'` with `'Project: MYPROJECT'`.
    1. replace `'enum _PROJECT_ ="";'` with `'enum _PROJECT_="MYPROJECT"`.
    1. replace `'Version:'` with `'Version: XXX.x(dmdY.YYY.Y)'`.
    1. replace `'enum _VERSION_ = "";'` with
          `'enum _VERSION_="XXX.x(dmdY.YYY.Y)"`.
    1. replace `'Date:'` with `'Date: YYYY-MON-DD HH:MM:SS'`.
    1. replace `'Authors:'` with `'Authors: YOU'`.
    1. replace `'enum _AUTHORS_ = "";'` with `'enum _AUTHORS_ = "YOU";'`.
    1. replace `'License:'` with `'License: LICENSE'`.
    1. replace `'enum _LICENSE_ = "";'` with
          `'enum _LICENSE_ = "LICENSE";'`.
    1. replace `'if('` with `'if ('`.
    1. replace `'for('` with `'for ('`.
    1. replace `'foreach('` with `'foreach ('`.
    1. replace `'version('` with `'version ('`.
    1. replace `'catch('` with `'catch ('`.



1. output to the file.
1. rewind the modified time of the file.



## Acknowledgements:
- vwrite is written by D Programming Language.
  [Digital Mars D Programming Language(http://dlang.org/)](http://dlang.org/)



## Development Environment:
- Windows Vista(x64) x dmd 2.070.0 x make(of Digital Mars)
- Ubuntu 15.10(amd64) x dmd 2.069.2 x gcc 5.2.1



## License description:
[Creative Commons Zero License(http://creativecommons.org/publicdomain/zero/1.0/)](http://creativecommons.org/publicdomain/zero/1.0/)


## History:
- 2016-02-22 ver. 0.33(dmd2.070.0)
  README.md and the commandline help message are generated automatically
  by ddoc.
  add 'Dmd:', ddoc section.


- 2016-01-29 ver. 0.32(dmd2.070.0)
  The version information of dmd is added to the user specified string
  automatically.


- 2015-12-16 ver. 0.31(dmd2.069.2)
  add replacing rule for `'if ('`, `'for ('`,
  `'foreach ('`,
  `'version ('`, `'catch ('`.


- 2015 12/14 ver. 0.30(dmd2.069.2)
  add japanese messages.


- 2015 12/13 ver. 0.29(dmd2.069.2)
  fully brush up.
    - delete v-style.xml.
    - use command line argument for all settings.
    - delete -target.
    - add checking process of white spacing style.
    - add English README.md.



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
-                    |-
-h --help -? /?     |ヘルプメッセージを出力します。
                    |
--authors 名無し    |プロジェクトの著者を'名無し'とします。
--license NYSL      |プロジェクトのライセンスを'NYSL'とします。
--project MYPROJECT |プロジェクト名を'MYPROJECT'とします。
--setversion XXX.x  |ヴァージョン文字列を指定します。
--version           |vwrite のヴァージョン情報を表示します。


## このプログラムは何をしますか:
このプログラムは、


1. コマンドライン引数より、プロジェクトに関する以下の情報を得ます。
    1. `--project MYPROJECT` プロジェクトの名前を指定します。
    1. `--setversion XXX.x` ヴァージョン情報を指定します。
    1. `--authors YOU` 著者名を指定します。
    1. `--license LICENSE` ライセンス情報を指定します。



1. コマンドライン引数より拡張子が`'.d'`又は`'.di'`のファイル名のものを選びます。


1. それぞれのファイルに対して以下の置換を行います。
    1. `'\r\n'` を `'\n'` に
    1. `'\r'` を `'\n'`に
    1. `'\t'` を `'    '`(スペース4個)に
    1. 行末の空白文字の消去
    1. `'Project:'` を `'Project: MYPROJECT'`に
    1. `'enum _PROJECT_ ="";'` を `'enum _PROJECT_="MYPROJECT"`に
    1. `'Version:'` を `'Version: XXX.x'`に
    1. `'enum _VERSION_ = "";'` を `'enum _VERSION_="XXX.x(dmdY.YYY.Y)"`に
    1. `'Date:\'` を `'Date: YYYY-MON-DD HH:MM:SS'`に
    1. `'Authors:'` を `'Authors: YOU'`に
    1. `'enum _AUTHORS_ = "";'` を `'enum _AUTHORS_ = "YOU";'`に
    1. `'License:'` を `'License: LICENSE'`に
    1. `'enum _LICENSE_ = "";'` を `'enum _LICENSE_ = "LICENSE";'`に
    1. `'if('` を `'if ('`に
    1. `'for('` を `'for ('`に
    1. `'foreach('` を `'foreach ('`に
    1. `'version('` を `'version ('`に
    1. `'catch('` を `'catch ('`に



1. 同じファイルに出力します。
1. ファイルの最終編集時刻を書き戻します。



## 謝辞:
- vwrite は D言語で書かれています。
  [Digital Mars D Programming Language(http://dlang.org/)](http://dlang.org/)



## 開発環境:
- Windows Vista(x64) x dmd 2.070.0 x (Digital Marsの)make
- Ubuntu 15.10(amd64) x dmd 2.069.2 x gcc 5.2.1



## ライセンス:
[Creative Commons Zero License(http://creativecommons.org/publicdomain/zero/1.0/)](http://creativecommons.org/publicdomain/zero/1.0/)


## 履歴:
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



