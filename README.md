# isucon-knowledge

# 秘伝のタレ
1. Nginxのワーカープロセス数
シナリオ：マルチコアCPUを使用している場合
調整：worker_processes をCPUコア数と同じに設定します。
例：8コアCPUの場合、 `worker_processes 8;`

2. Nginxのキープアライブ設定
シナリオ：多数の短時間の接続がある場合
調整：keepalive_timeout を低く、keepalive_requests を高く設定します。
例： `keepalive_timeout 15; keepalive_requests 10000;`

3. MySQLのInnoDBバッファプールサイズ
シナリオ：データベースのサイズが大きい場合
調整：利用可能なRAMの50-80%を割り当てます。
例：16GB RAMのサーバーで、`innodb_buffer_pool_size = 8G`

4. MySQLのmax_connections
シナリオ：同時接続数が多い場合
調整：アプリケーションの要求に応じて増やします。ただし、サーバーのリソースを考慮する必要があります。
例：`max_connections = 2000`

5. MySQLのslow_query_log
シナリオ：パフォーマンス問題の調査時
調整：long_query_time を低く設定して、多くのクエリをキャプチャします。
例：`slow_query_log = 1 long_query_time = 0.1`

6. Nginxのgzip圧縮
シナリオ：帯域幅を節約したい場合
調整：gzipを有効にし、適切なMIMEタイプを指定します。
例：
```
gzip on;
gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
```
7. MySQLのinnodb_log_file_size
シナリオ：大量の書き込みがある場合
調整：大きな値に設定しますが、クラッシュ時の回復時間とのバランスを取ります。
例：`innodb_log_file_size = 512M`

8. Nginxのopen_file_cache
シナリオ：静的ファイルへの頻繁なアクセスがある場合
調整：キャッシュサイズを増やし、有効期間を調整します。
例：
```
open_file_cache max=10000 inactive=60s;
open_file_cache_valid 120s;
```
9. MySQLのtable_open_cache
シナリオ：多数のテーブルを使用するアプリケーションの場合
調整：開いているテーブルの数に応じて増やします。
例： `table_open_cache = 8000`

10. Nginxのclient_max_body_size
シナリオ：大きなファイルのアップロードを許可する場合
調整：許可する最大サイズに設定します。
例：`client_max_body_size 20M;`

これらの調整を行う際は、以下の点に注意してください：

変更の前後でベンチマークを実行し、効果を測定します。
システムのリソース（特にメモリ）を常に監視します。
一度に多くの変更を行わず、1つずつ調整して効果を確認します。
アプリケーションの特性や要件に基づいて調整します。

# Ref
- https://blog.p1ass.com/posts/isucon13/
- https://gist.github.com/HirokiYoshida837/812b89e58da3ba2fe37c103d2b4dbd2d
- https://zenn.dev/vaxila_labs/articles/218d01ffbbb0f3
