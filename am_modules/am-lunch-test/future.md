## 実装フロー
```coffee
ワードアルゴリズム


自動実行 = (終了フラグ) =>

jsファイル更新時に実行 = (params) =>
  前回の実行結果があれば消す
  iframeを実行する #必ず
  クリック対象をパラメーターで指定しておく
  止める


サーバー起動
bookmarklet連携サーバーを持つ
ブックマークにbookmarkletを入れる
開発したい画面上でポチと押す
画面が消える
パターンファイル更新時にリスト更新 #監視1
jsファイル更新時に実行() #監視2

```


#実装したいもの

## 優先度高
paramを見てam-autoeventを実行する

## 中
実行前ダイアログを作る
  デフォルト動作
  coffeeベースな実行環境作成（＋js変換ベースの実行環境作成）

websocketと連携したアサーションを作る

## 小