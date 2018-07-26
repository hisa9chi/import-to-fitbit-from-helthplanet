[![CircleCI](https://circleci.com/gh/hisa9chi/import-to-fitbit-from-helthplanet/tree/master.svg?style=svg)](https://circleci.com/gh/hisa9chi/import-to-fitbit-from-helthplanet/tree/master)

## import-to-fitbit-from-helthplanet
- Helthplanet に登録されている体重、体脂肪を Fitbit へインポートする。
- 1日単位で Helthplanet よりデータを取得してその取得データを Fitbit 側へ登録する。 
- ※本ツールは個人的利用を目的としています。

## 事前準備
- Helthplanet, Fitbit 共に oputh2.0 認証を用いて API を利用するためそれぞれで登録が必要
- 登録後に得られる Client ID, Client Secret を利用
### Helthplanet
- https://www.healthplanet.jp/apis_account.do へログインしてアプリの登録
  - アプリケーションタイプは 'クライアントアプリケーション'
### Fitbit
- https://dev.fitbit.com/apps/new へログインしてアプリの登録
  - 'OAuth 2.0 Application Type' は 'Personal'
  - 'Default Access Type' は 'Read & Write'
