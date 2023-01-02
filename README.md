# 手動実行部分

リソース自体は自動でデプロイされるが、認証・認可周りの設定は手動で行う必要がある。

## DNS

1. ドメイン登録を行っても、「保留中のリクエスト」となっているため、rotue53 からリクエストの認証を行う。
2. route53 の該当ホストゾーン内のレコードに NS が追加されているため、DNS サービス側で登録を実施。

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
