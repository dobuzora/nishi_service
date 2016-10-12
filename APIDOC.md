## GET /login
ログインは LINE(notify?) の oauth を使用してログインする.  
[LINE notify API Document](https://notify-bot.line.me/static/pdf/line-notify-api_ja.pdf)  
  
### ログイン成功した時
LINE notify のアクセストークンをキーとして、ユーザーを識別する.  
クッキーで保存すればいい？（クッキー消された時の処理を考えなければいけないのがめんどい）  
html の input hidden で用意しておくのもアリかも

### ログイン失敗した時
よしなに

## POST http://127.0.0.1:5000/addurl
パラメータを送信することで、LINE Notify で通知する RSS feed を新しく通知する.   
LINE Notify の Oauth で得たアクセストークンをセッション経由で受け取る.

### parameter
- urls
  - 更新を確認したいリンクを array で受け取る
     
## POST http://127.0.0.1:5001/notification
- urls
  - 更新されていることが確認された url が送信される.
  - 更新されていることが確認された url で検索して, 登録している user_id へ LINE Notify を通じて通知する.
