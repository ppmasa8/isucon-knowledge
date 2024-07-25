# isucon-knowledge

# 練習の順番
- private-isu
- isucon13
- isucon12

# 当日までにやること
- discordのisucon事前課題(7/31のやつのみ)
- otelやtailscaleを使わない簡便な構成(7/31のやつのみ, 参考：https://github.com/narusejun/isucon-app-scaffold)
- tailscale調査&整備
- otel+jaeger調査&整備
- [過去問 on AWS](https://github.com/matsuu/aws-isucon/tree/main)
- [private-isu](https://github.com/catatsuy/private-isu)
- メンバー集め(インターネットゼミで誘ってみる)

# 当日やること
- 動作確認及び初期値計測
- N+1の解消
- アプリケーションサーバーとmysqlサーバーの分離
- nginxとmysqlの秘伝のタレ追加
- インデックス確認
- **再起動試験**
- ログや計測ツール系の削除

# 秘伝のタレ
## Nginx
1. Nginxのワーカープロセス数
シナリオ：マルチコアCPUを使用している場合
調整：worker_processes をCPUコア数と同じに設定します。
例：8コアCPUの場合、 `worker_processes 8;`

2. Nginxのキープアライブ設定
シナリオ：多数の短時間の接続がある場合
調整：keepalive_timeout を低く、keepalive_requests を高く設定します。
例： `keepalive_timeout 15; keepalive_requests 10000;`

3. Nginxのgzip圧縮
シナリオ：帯域幅を節約したい場合
調整：gzipを有効にし、適切なMIMEタイプを指定します。
例：
```
gzip on;
gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
```

4. Nginxのopen_file_cache
シナリオ：静的ファイルへの頻繁なアクセスがある場合
調整：キャッシュサイズを増やし、有効期間を調整します。
例：
```
open_file_cache max=10000 inactive=60s;
open_file_cache_valid 120s;
```

5. Nginxのclient_max_body_size
シナリオ：大きなファイルのアップロードを許可する場合
調整：許可する最大サイズに設定します。
例：`client_max_body_size 20M;`

6. worker_rlimit_nofile
シナリオ：大量の同時接続を処理する必要がある場合
調整：システムの上限に近い値に設定。例えば、ulimit -n の出力が100000なら：

`worker_rlimit_nofile 90000;`

7. use epoll
シナリオ：Linuxシステムで高パフォーマンスが必要な場合
調整：常に有効にする

`use epoll;`

8. バッファサイズ
シナリオ：リクエストヘッダーやボディが大きい場合
調整：アプリケーションの要求に合わせて増加。例：
```
client_body_buffer_size 16k;
client_header_buffer_size 2k;
```

9. タイムアウト設定
シナリオ：接続が遅い、または不安定なクライアントがある場合
調整：適切な値に設定。短すぎると接続が切れる可能性がある。例：
```
client_body_timeout 30;
client_header_timeout 30;
send_timeout 60;
```

10. sendfile, tcp_nopush, tcp_nodelay
シナリオ：静的ファイル配信の最適化が必要な場合
調整：通常はすべてオンにする
```
sendfile on;
tcp_nopush on;
tcp_nodelay on;
```

## MySQL
1. MySQLのInnoDBバッファプールサイズ
シナリオ：データベースのサイズが大きい場合
調整：利用可能なRAMの50-80%を割り当てます。
例：16GB RAMのサーバーで、`innodb_buffer_pool_size = 8G`

2. MySQLのmax_connections
シナリオ：同時接続数が多い場合
調整：アプリケーションの要求に応じて増やします。ただし、サーバーのリソースを考慮する必要があります。
例：`max_connections = 2000`

3. MySQLのslow_query_log
シナリオ：パフォーマンス問題の調査時
調整：long_query_time を低く設定して、多くのクエリをキャプチャします。
例：`slow_query_log = 1 long_query_time = 0.1`

4. MySQLのinnodb_log_file_size
シナリオ：大量の書き込みがある場合
調整：大きな値に設定しますが、クラッシュ時の回復時間とのバランスを取ります。
例：`innodb_log_file_size = 512M`

5. MySQLのtable_open_cache
シナリオ：多数のテーブルを使用するアプリケーションの場合
調整：開いているテーブルの数に応じて増やします。
例： `table_open_cache = 8000`

6. key_buffer_size
シナリオ：MyISAMテーブルを多用する場合
調整：利用可能なメモリの25%程度。例えば16GB RAMの場合：

`key_buffer_size = 4G`

7. tmp_table_size と max_heap_table_size
シナリオ：大きな一時テーブルを使用するクエリが多い場合
調整：同じ値に設定し、利用可能なメモリに応じて増加。例：
```
tmp_table_size = 256M
max_heap_table_size = 256M
```
8. sort_buffer_size
シナリオ：大量のソート操作を行うクエリがある場合
調整：2-4MBから開始し、必要に応じて増加。例：

`sort_buffer_size = 4M`

9. read_buffer_size と read_rnd_buffer_size
シナリオ：大きなテーブルスキャンを行う場合
調整：1-8MBの範囲で設定。例：
```
read_buffer_size = 2M
read_rnd_buffer_size = 4M
```
10. join_buffer_size
シナリオ：大きなジョイン操作を行うクエリがある場合
調整：256KB-4MBの範囲で設定。例：

`join_buffer_size = 1M`

11. table_open_cache
シナリオ：多数のテーブルを頻繁に開く場合
調整：(max_connections * テーブル数)を目安に設定。例：

`table_open_cache = 4000`

12. thread_cache_size
シナリオ：頻繁に新しい接続が作成される場合
調整：max_connectionsの10-20%程度。例：

`thread_cache_size = 100`

13. innodb_flush_log_at_trx_commit
シナリオ：パフォーマンスを重視し、わずかなデータロスを許容できる場合
調整：2に設定（ただし、完全なACID準拠が必要な場合は1のまま）

`innodb_flush_log_at_trx_commit = 2`

14. innodb_flush_method
シナリオ：高速なI/Oが可能なハードウェアを使用している場合
調整：O_DIRECTに設定

`innodb_flush_method = O_DIRECT`

15. performance_schema
シナリオ：パフォーマンスモニタリングが不要で、オーバーヘッドを減らしたい場合
調整：OFFに設定

`performance_schema = OFF`

## 注意事項
これらの調整を行う際は、以下の点に注意してください：

変更の前後でベンチマークを実行し、効果を測定します。
システムのリソース（特にメモリ）を常に監視します。
一度に多くの変更を行わず、1つずつ調整して効果を確認します。
アプリケーションの特性や要件に基づいて調整します。

## FAQ
### Nginx の設定ファイルどこ？
メイン設定ファイル:`/etc/nginx/nginx.conf`

サイト固有の設定ファイル（通常は nginx.conf から include されます）:
```
/etc/nginx/sites-available/default
/etc/nginx/sites-enabled/default
```

モジュール設定ファイル:

`/etc/nginx/modules-enabled/`

### MySQL の設定ファイルどこ？

メイン設定ファイル:`/etc/mysql/my.cnf`
MySQL 5.7 以降では、以下のファイルも使用されることがあります:`/etc/mysql/mysql.conf.d/mysqld.cnf`

カスタム設定ファイル（通常は my.cnf から !includedir で指定されます）:`/etc/mysql/conf.d/*.cnf`

### 注意点:
ISUCON のような特殊な環境では、これらのパスが異なる場合があります。
設定ファイルの場所を確認するには、以下のコマンドが役立つことがあります:
Nginx: `nginx -t`（設定ファイルの構文チェックと場所の表示）
MySQL: `mysql --help | grep "Default options"` （設定ファイルの読み込み順序の表示）
設定を変更した後は、必ずサービスを再起動する必要があります:
Nginx: `sudo systemctl restart nginx`
MySQL: `sudo systemctl restart mysql`

# Ref
- https://blog.p1ass.com/posts/isucon13/
- https://isucon.net/archives/56842718.html
- https://zenn.dev/tohutohu/articles/923bdf5dcd73af
- https://blog.sakamo.dev/post/isucon13/
- https://gist.github.com/HirokiYoshida837/812b89e58da3ba2fe37c103d2b4dbd2d
- https://ai-techblog.hatenablog.com/entry/2023/05/28/105447
- https://zenn.dev/vaxila_labs/articles/218d01ffbbb0f3
- https://sfujiwara.hatenablog.com/search?q=isucon

