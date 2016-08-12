
# 備份 PTT 的文章 #

這是一個用來備份 PTT 文章的 git 。


## `ptt_backup.sh` ##

此腳本會用 curl 把 ptt 上的文章抓下來，
然後把其中樣式表的網址改成相對路徑。

	$ ./ptt_backup.sh http://path.to.ptt/board/article.html
	## 輸出備份後的網址，但要先 git push 後才會上線。


## `index.sh` ##

此腳本會呼叫 `genmeta.pl` ，對每個網頁產生摘錄。
並用摘錄生成網頁，輸出到標準輸出。
網頁的 metadata 和頭部是從 `index_old.html` 抓出來的。
我的習慣是先把 index.html 重新命名成 index_old.html ，
再產生新的 index.html 。

	$ ./index.sh >index.html


## 自動推送到 github ##

若加上 `-p` 選項，會再自動推送到 github 。
在 ptt_backup.sh 和 index.sh 後皆可以加上 `-p` 選項。
*注意 `-p` 必須是第一個參數。*
若要更改自動提交的訊息，可以到 index.sh 裡改。

	$ ./index.sh -p >index.html
	## 這樣會重新產生首頁 index.html 並推送。
	
	$ ./ptt_backup -p http://path.to.ptt/board/article
	## 這樣會備份並重新產生首頁 index.html 並推送。



## 相對路徑 ##

PTT 網頁版的樣式表和 javascript 
都是另外放的，而且是相對路徑。
我只好改她的相對路徑，並把 ptt 
的樣式表考貝一份放到本 git 裡。
也就是本目錄下的 `bbs-main.css` 、 `bbs-common.css` 、
`bbs-custom.css` 、 `pushstream.css` 。

至於 js ，反正我也用不到，
太部份 js 是用來更新推文的 js 。
就不放了。反正我也不能更新推大。


