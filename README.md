# 手動実行部分

リソース自体は自動でデプロイされるが、認証・認可周りの設定は手動で行う必要がある。

## DNS

- route53 でドメインを取得した場合は同様の流れとはならない可能性がある。今回は外部の DNS プロバイダを利用した際の流れを記載。

1. `aws_acm_certificate_validation`によって SSL 証明書は自動更新されるが、route53 のリソースと同時の作成だと NS の値が外部プロバイダに登録されていないため検証が終了しない。
2. `ホストゾーン`→`レコード`からレコードタイプが NS のものを 4 つ確認し、外部プロバイダに登録する。
3. 登録後はすぐに検証が成功する見込みだが、失敗した場合は再度 apply する。

## Codepipeline

- ソースコードとして github を利用・codestarconnection を利用して連携の場合、認証が必要。

1. CodePipeline の「設定」→「接続」から github 認証を実施

# ECS コンテナへのログイン

- 踏み台サーバとして ec2 を用意する orEcs exec を利用してローカルから直接ログインが可能。どちらの場合も`Session Manager Plugin`が必要なのでインストールする。

```bash:
$ curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/mac/sessionmanager-bundle.zip" -o "sessionmanager-bundle.zip"
$ unzip sessionmanager-bundle.zip
$ sudo ./sessionmanager-bundle/install -i /usr/local/sessionmanagerplugin -b /usr/local/bin/session-manager-plugin
```

- インストールできない場合、公式ドキュメントから最新情報を参照・
