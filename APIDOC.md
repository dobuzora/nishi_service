## GET /login
ログインは LINE(notify?) の oauth を使用してログインする.  
[LINE notify API Document](https://notify-bot.line.me/static/pdf/line-notify-api_ja.pdf)  
  
### ログイン成功した時
LINE notify のアクセストークンをキーとして、ユーザーを識別する.  
クッキーで保存すればいい？（クッキー消された時の処理を考えなければいけないのがめんどい）  
html の input hidden で用意しておくのもアリかも

### ログイン失敗した時
よしなに

## POST /addfeed
パラメータを送信することで、LINE Notify で通知する RSS feed を新しく通知する.  
### parameter
- access-token
  - LINE Notify の Oauth で得たアクセストークンを value とする
- rss-feed
  - rss 用リンクを array で受け取る
     
# RSS のリアルタイムの取得をどうすればいいか
pubsubhubbub の [subscribe](https://pubsubhubbub.appspot.com/subscribe) を使用すればよさそう！  
参考:  
[tokuhirom さんブログ](http://blog.64p.org/entry/20100307/push)
