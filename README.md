# プログラミングⅣ
## 課題
Oauth認証でログインできる、Webアプリケーションを作成する。　　
## 内容　　
1.サービスにアクセス  
2.WebページのRSSを登録  
3.登録ページが更新されたかどうか判定  
4.更新時通知を送る  

## 何が必要か

・ログイン機能(LINE notfify , Oauth)  
・データベース(User info , RSS info)  
・更新判定　　

## API Document
[これを見よ！](https://github.com/Nishisi/nishi_service/blob/master/APIDOC.md)

## Setup
スキーマの更新があるたびに次のスクリプトを実行.  

    ./migrate

`tools/Checker/`, `tools/Notifier` へ移動し `go build` を実行する.  
完了後, 次を実行.

    ./run

`tools/Checker/Checker` は基本 Cron で定期的に実行することを予想.