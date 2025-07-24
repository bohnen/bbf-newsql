# 「わかばちゃんとつくって、壊して、直して学ぶ NewSQL入門」 コマンドライン一覧

このドキュメントは、書籍「わかばちゃんとつくって、壊して、直して学ぶ NewSQL入門」の各章のコマンドラインとその説明をまとめたものです。

## Chapter 2

### 2.1 必要な環境を整備しよう

TiUPインストールスクリプトをダウンロードして実行します。

```bash
curl --proto '=https' --tlsv1.2 -sSf https://tiup-mirrors.pingcap.com/install.sh | sh
```

インストールされたTiUPのバージョン情報を表示して、インストールが成功したことを確認します。

```bash
tiup --version
```

利用可能なTiUPコマンドと使用方法の情報を表示します。

```bash
tiup --help
```

デフォルト設定でTiDBクラスターをプレイグラウンドモードで起動します。

```bash
tiup playground
```

### 2.2 TiDBクラスターをつくろう

macOSでHomebrewパッケージマネージャーを使用してMySQL client バージョン8.4をインストールします。

```bash
brew install mysql-client@8.4
```

パッケージカタログを更新し、Ubuntuで特定バージョンのMySQLクライアントをインストールします。

```bash
sudo apt-get update
sudo apt-get install mysql-client=8.0.40-0ubuntu0.24.04.1
```

TiDB PlaygroundにrootユーザーでMySQLクライアントを使用して接続します。

```bash
mysql --host 127.0.0.1 --port 4000 -u root
```

データベースの一覧を表示します。

```sql
SHOW DATABASES;
```

実行中のクラスターに1つのTiDBノードを追加します。

```bash
tiup playground scale-out --db 1
```

プレイグラウンドクラスター内のすべてのコンポーネントの状態を表示します（プロセスID、役割、稼働時間を含む）。

```bash
tiup playground display
```

最小構成でTiDB Playgroundを起動します（この例では1つのTiDB、1つのPD、1つのTiKVノードを起動します）。

```bash
tiup playground --db 1 --pd 1 --kv 1
```

プロセスIDを使用してクラスターから特定のノードを削除します。

```bash
tiup playground scale-in --pid 87375
```

## Chapter 3

### 3.1 MySQLクライアントを使ってデータベースへ接続する

TiDB PlaygroundにrootユーザーでMySQLクライアントを使用して接続します。

```bash
mysql --host 127.0.0.1 --port 4000 -u root
```

TiDBバージョンを返します。

```sql
SELECT VERSION();
```

### 3.2 データベースをつくってみよう

書籍情報を格納するBooksテーブルと図書貸出を追跡するBorrowingsテーブルを持つlibraryデータベースを作成します。

```sql
CREATE DATABASE library;
USE library;

-- 書籍テーブル
CREATE TABLE Books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255) NOT NULL,
    publisher VARCHAR(255),
    published_year YEAR
);

-- 貸出テーブル
CREATE TABLE Borrowings (
    borrowing_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    borrower_name VARCHAR(255) NOT NULL,
    borrow_date DATE NOT NULL,
    return_date DATE,
    FOREIGN KEY (book_id) REFERENCES Books(book_id)
    ON DELETE CASCADE
);
```

サンプルの書籍レコードと貸出レコードを各テーブルに挿入します。

```sql
-- 書籍データを挿入
INSERT INTO Books (title, author, publisher, published_year)
VALUES
('かんたんSQL入門', '田中 花子', 'りんご出版', 2021),
('Pythonマスターガイド', '鈴木 一郎', 'ばなな書房', 2019),
('データベースの基本', '佐藤 由美', 'さくらプレス', 2020),
('コードの美学', '山田 太郎', 'なつめ社', 2018),
('JavaScript初心者講座', '高橋 明美', 'ぶどうエディション', 2022);

-- 貸出データを挿入
INSERT INTO Borrowings (book_id, borrower_name, borrow_date, return_date)
VALUES
(1, '山本 太郎', '2024-12-01', NULL), -- 未返却
(2, '中村 花子', '2024-12-10', '2024-12-20'), -- 返却済み
(3, '田中 次郎', '2024-12-05', NULL); -- 未返却
```

Booksテーブルからすべての列と行を取得します。

```sql
SELECT * FROM Books;
```

### 3.3 SQLについて学ぼう

Booksテーブルから書籍IDとタイトルのみを取得します。

```sql
SELECT book_id, title FROM library.Books;
```

クエリパフォーマンスを向上させるため、borrow_date列にインデックスを作成します。

```sql
CREATE INDEX Borrowings_borrow_date_index ON Borrowings (borrow_date);
```

インデックス、テーブル、データベースをそれぞれ削除します。

```sql
DROP INDEX Borrowings_borrow_date_index ON Borrowings;
DROP TABLE Borrowings;
DROP DATABASE library;
```

出版年が2020年の書籍をBooksテーブルから取得します。

```sql
SELECT * FROM Books WHERE published_year = 2020;
```

未返却の書籍と、その貸出者名を取得します。

```sql
SELECT title, borrower_name
FROM books INNER JOIN borrowings ON books.book_id = borrowings.book_id
WHERE borrowings.return_date IS NULL;
```

書籍タイトルと貸出情報を結合して、すべての書籍とその貸出情報を取得します。

```sql
SELECT title, borrowings.* FROM books LEFT JOIN
borrowings ON books.book_id = borrowings.book_id;
```

WHEREの条件を元通りにして、未返却の書籍とその貸出者名を取得します。

```sql
SELECT title, borrower_name
FROM books LEFT JOIN borrowings ON books.book_id = borrowings.book_id
WHERE borrowings.return_date IS NULL;
```

borrowings_idが3の貸出レコードの返却日を現在の日付に更新します。

```sql
UPDATE borrowings SET return_date = NOW() 
WHERE borrowing_id = 3;
```

borrowings_idが3のレコードを削除します。

```sql
DELETE FROM borrowings WHERE borrowing_id = 3;
```

### 3.4 データをバックアップする方法と復元する方法を学ぼう

libraryデータベースを絶対パスで指定されたローカルディレクトリにバックアップします。

```sql
BACKUP DATABASE library to 'local://<保存ディレクトリの絶対パス>';
-- Example:
-- BACKUP DATABASE library to 'local:///tmp/backup/';
```

バックアップディレクトリからすべてのデータベースをリストアします。アスタリスク（*）はバックアップ内のすべてのデータベースをリストアすることを意味します。

```sql
RESTORE DATABASE * from 'local://<保存ディレクトリの絶対パス>';
```

## Chapter 5

### 5-1: 1台構成のクラスターを壊してみよう

デフォルト設定でTiDB Playgroundを起動します。

```bash
tiup playground
```

TiDB PlaygroundにMySQLクライアントを使用して接続します。

```bash
mysql --host 127.0.0.1 --port 4000 -u root
```

ローカルバックアップディレクトリからすべてのデータベースをリストアします。

```sql
RESTORE DATABASE * FROM 'local://[バックアップ保存先の絶対パス]';
```

TiDB Playgroundクラスター内で実行中のプロセス（Pid、Role、Uptime）を表示します。

```bash
tiup playground display
```

プロセスIDを使用して特定のプロセスを停止します。

```bash
kill [Pid]
```

クラスターに1つのTiDBサーバーインスタンスを追加します。

```bash
tiup playground scale-out --db 1
```

Booksテーブルからすべてのレコードを取得します。

```sql
SELECT * FROM library.Books;
```

### 5-2: 耐障害性のあるNewSQLクラスターをつくって、壊す

#### 5-2-1: コンピューティングノードを停止してみよう

1つのTiProxy、2つのTiDBサーバー、3つのTiKVサーバー、3つのPDサーバー、0個のTiFlashサーバーでTiDB Playgroundを起動します。

```bash
tiup playground --tiproxy 1 --db 2 --kv 3 --pd 3 --tiflash 0
```

TiDB Playgroundクラスター内で実行中のプロセス（Pid、Role、Uptime）を表示します。

```bash
tiup playground display
```

ポート6000でTiProxyを通じてTiDB Playgroundに接続します。

```bash
mysql -h 127.0.0.1 -P 6000 -u root
```

ローカルバックアップディレクトリからすべてのデータベースをリストアします。

```sql
RESTORE DATABASE * FROM 'local://[バックアップ保存先の絶対パス]';
```

現在接続しているTiDBサーバーのサーバーIDを表示します。

```sql
SHOW STATUS LIKE 'server_id';
```

ID、IPアドレス、ポートを含むすべてのTiDBサーバーを表示します。

```sql
SELECT ddl_id, ip, port FROM information_schema.tidb_servers_info;
```

ポート4000を使用しているプロセスをリストします。

```bash
lsof -i:4000
```

プロセスIDを使用してクラスターから特定のコンポーネントを削除します。

```bash
tiup playground scale-in --pid [PID]
```

稼働確認のため、簡単なクエリを実行します。

```sql
SELECT VERSION();
```

TiDBを2台に戻します。

```bash
tiup playground scale-out --db 1
```

新しいデータベーストランザクションを開始します。

```sql
BEGIN;
```

Booksテーブルに新しいレコードを挿入します。

```sql
INSERT INTO Books (title, author, publisher, published_year) values ('test_title', 'test_author', 'test_publisher', 2025);
```

port4001で起動しているTiDBサーバを特定します。

```bash
lsof -i:4001
```

TiDBサーバーのプロセスIDを使用して、TiDBサーバーを停止します。

```bash
kill -9 [PID]
```

現在のトランザクションをコミットします。

```sql
commit;
```

ロールバック確認のため、Booksテーブルからすべてのレコードを取得します。

```sql
SELECT * FROM library.Books;
```

#### 5-2-2: コンピューティングノードを直してみよう

TiDBサーバを2台に戻します。

```bash
tiup playground scale-out --db 2
```

#### 5-2-3: ストレージノードを停止してみよう

リージョンIDとキー範囲を含む、Booksテーブルのリージョン情報を表示します。

```sql
SELECT region_id,start_key, end_key, table_name, db_name FROM information_schema.tikv_region_status WHERE table_name = 'Books';
```

クラスター全体のすべてのリージョンリーダーをリストします。

```sql
SELECT * FROM information_schema.tikv_region_peers WHERE is_leader = 1 ORDER BY region_id;
```

IPアドレスとstore_idを含むすべてのTiKVストアの詳細なステータスを表示します。

```sql
SELECT * FROM tikv_store_status;
```

information_schemaデータベースに切り替えます。

```sql
USE information_schema;
```

複数のテーブルを結合して、BooksテーブルのリージョンのリーダーであるTiKVサーバーを特定します。

```sql
SELECT region_id, store_id, address
FROM tikv_region_status NATURAL JOIN tikv_region_peers NATURAL JOIN tikv_store_status
WHERE is_leader = 1 AND table_name = 'Books';
```

ポート20161でリッスンしているプロセスをリストします。

```bash
lsof -i:20161 | grep LISTEN
```

Booksテーブルに行を追加し、その後に全行を取得します。

```sql
USE library;
INSERT INTO Books (title, author, publisher, published_year) VALUES ('test_title', 'test_author', 'test_publisher', 2025);
SELECT * FROM library.Books;
```

#### 5-2-4: ストレージノードを直してみよう

TiDb Playgroundを再起動します。

```bash
tiup playground --tiproxy 1 --db 2 --kv 3 --pd 3 --tiflash 0
```

ポート6000でTiProxyを通じてTiDB Playgroundに接続します。

```bash
mysql -h 127.0.0.1 -P 6000 -u root
```

ローカルバックアップディレクトリからすべてのデータベースをリストアします。

```sql
RESTORE DATABASE * FROM 'local://[バックアップ保存先の絶対パス]';
```

#### コラム 1台のストレージノードからクラスターを復元する

PDサーバー管理のためのpd-ctlツールをインストールします。

```bash
tiup install ctl:v8.5.1
```

障害したTiKVストアをクラスターから強制的に削除します（ストアID 1と2）。

```bash
tiup ctl:v8.5.1 pd unsafe remove-failed-stores 1,2
```

unsafe recovery操作のステータスを表示します。

```bash
tiup ctl:v8.5.1 pd unsafe remove-failed-stores show
```

Booksテーブルのクエリが成功することを確認します。

```sql
USE library;
SELECT * FROM Books;
```

Books, Borrowingsテーブルの整合性を確認します。

```sql
ADMIN CHECK TABLE Books;
ADMIN CHECK TABLE Borrowings;
```

クラスターに2つのTiKVサーバーインスタンスを追加します。

```bash
tiup playground scale-out --kv 2
tiup playground display
```

TiKVストアのステータスを表示して、追加されたストアの稼働状況を確認します。

```sql
SELECT * FROM information_schema.tikv_store_status;
```

#### 5-2-5: クラスター管理ノードを停止してみよう

PDサーバーに接続してPDメンバー情報を表示します。

```bash
tiup ctl:v8.5.1 pd member show
```

PDサーバーを指定して接続し、PDメンバー情報を表示します。

```bash
tiup ctl:v8.5.1 pd member show --pd http://127.0.0.1:2379
```

#### 5.2.6 クラスター管理ノードを直してみよう

データを保持するためのタグ付きでTiDB Playgroundを起動します。

```bash
tiup --tag tidbbook playground --tiproxy 1 --db 2 --kv 3 --pd 3 --tiflash 0
```

ポート6000でTiProxyを通じてTiDB Playgroundに接続します。

```bash
mysql -h 127.0.0.1 -P 6000 -u root
```

ローカルバックアップディレクトリからすべてのデータベースをリストアします。

```sql
RESTORE DATABASE * FROM 'local://[バックアップ保存先の絶対パス]';
```

#### コラム 1台のクラスター管理ノードからクラスターを復元する

復旧に必要なcluster idを見つけるためにTiKVログを検索します。

```bash
grep "connect to PD cluster" ~/.tiup/data/tidbbook/tikv-*/tikv.log
```

復旧に必要なallocate idを見つけるためにPDログを検索します。

```bash
grep "idAllocator allocates a new id" ~/.tiup/data/tidbbook/pd-*/pd.log
```

PDサーバーからすべてのデータを削除します（-iは削除対象の確認のため）。

```bash
rm -ri ~/.tiup/data/tidbbook/pd-*/data/*
```

カスタム設定で単一のPDサーバーを起動します。

```bash
tiup --tag tidbbook playground --pd 1 --pd.config ~/.tiup/data/tidbbook/pd.conf.toml --db 0 --kv 0 --tiflash 0
```

cluster idとallocate idを使用してPDサーバーを復旧します。

```bash
tiup pd-recover -endpoints http://127.0.0.1:2379 -cluster-id 7479806413711524522 -alloc-id 4000
```

1つのPDサーバーインスタンスを追加します。

```bash
tiup playground scale-out --pd 1
```

クラスターを復元します。

```bash
tiup --tag tidbbook playground --tiproxy 1 --db 2 --kv 3--pd 3 --tiflash 0
```

## Chapter 6

### 6.1.5 インフォメーションスキーマから内部構造を把握しよう

TiDB Playgroundを起動します。

```bash
tiup playground --db 3 --pd 3 --kv 3 --tiflash 0
```

TiDB Playgroundに接続します。

```bash
mysql --host 127.0.0.1 --port 4000 -u root
```

データベースの一覧を表示します。

```sql
SHOW DATABASES;
```

INFORMATION_SCHEMAをデフォルトデータベースとして設定します。

```sql
USE INFORMATION_SCHEMA;
```

INFORMATION_SCHEMA内のすべてのテーブルをリストします。

```sql
SHOW TABLES;
```

すべてのノードのインスタンスタイプ、アドレス、開始時間、稼働時間を取得します。

```sql
SELECT TYPE, INSTANCE, START_TIME, UPTIME FROM cluster_info;
```

### 6.2.5 実行計画の確認とTiKVのリージョンの様子を確認してみよう

TiDB Playgroundを起動します。

```bash
tiup playground --db 3 --pd 3 --kv 3 --tiflash 0
```

TiDB Playgroundに接続します。

```bash
mysql --host 127.0.0.1 --port 4000 -u root
```

'chapter6_2_5_db'という名前の新しいデータベースを作成します。

```sql
CREATE DATABASE chapter6_2_5_db;
```

新しく作成したデータベースをデフォルトデータベースとして設定します。

```sql
USE chapter6_2_5_db;
```

'users'という名前のテーブルを作成します。

```sql
CREATE TABLE users (id INT PRIMARY KEY, name VARCHAR(100), age INT);
```

SELECTクエリの実行計画を表示します。

```sql
EXPLAIN SELECT * FROM users WHERE age > 20;
```

テーブルのテーブルIDとテーブル名を取得します。

```sql
SELECT TIDB_TABLE_ID, TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='chapter6_2_5_db';
```

usersテーブルにレコードを挿入します。

```sql
INSERT INTO users (id, name, age) VALUES (1, 'Alice', 25);
```

usersテーブルのデータを格納するTiKVリージョンを表示します。

```sql
SELECT TABLE_NAME, REGION_ID FROM INFORMATION_SCHEMA.TIKV_REGION_STATUS WHERE TABLE_NAME = 'users';
```

トランザクションがロールバックした場合、値が反映されないことを確認します。

```sql
BEGIN;
INSERT INTO users (id, name, age) VALUES (2, 'Alice', 25);
SELECT * FROM users;
ROLLBACK;
SELECT * FROM users;
```

### 6.3.4 MVCCの特徴を実際に確認してみよう

テスト用のデータベースを作成します。

```sql
CREATE DATABASE mvcc_test;
```

データベースをデフォルトに設定します。

```sql
USE mvcc_test;
```

テスト用のテーブルを作成します。

```sql
CREATE TABLE mvcc_users (id INT PRIMARY KEY, name VARCHAR(100), age INT);
```

複数のテストレコード（計10レコード）を挿入します。

```sql
INSERT INTO mvcc_users (id, name, age) VALUES (1, 'test1', 11), (2, 'test2', 12), (3, 'test3', 13), (4, 'test4', 14), (5, 'test5', 15), (6, 'test6', 16), (7, 'test7', 17), (8, 'test8', 18), (9, 'test9', 19), (10, 'test10', 20);
```

mvcc_usersテーブル内のすべてのレコードを表示します。

```sql
SELECT * FROM mvcc_users;
```

現在の日付と時刻を返します。

```sql
SELECT now();
```

id=10のレコードを削除します。

```sql
DELETE FROM mvcc_users WHERE id = 10;
```

指定されたタイムスタンプ時点でのクエリを実行します。

```sql
SELECT * FROM mvcc_users AS OF TIMESTAMP '2025-03-10 14:29:27';
```

### 6.4.3 さわって確かめてみよう

PD（Placement Driver）テスト用のデータベースを作成します。

```sql
CREATE DATABASE pd_test;
```

PDテストデータベースをデフォルトに設定します。

```sql
USE pd_test;
```

テスト用のproductsテーブルを作成します。

```sql
CREATE TABLE products (id INT PRIMARY KEY, name VARCHAR(100), price INT);
```

サンプルの製品データを挿入します。

```sql
INSERT INTO products (id, name, price) VALUES (1, 'Book', 1500), (2, 'Pen', 300);
```

テーブルのテーブルIDを取得します。

```sql
SELECT TABLE_NAME, TIDB_TABLE_ID FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='pd_test';
```

特定のテーブルの開始・終了キーを含むリージョン情報を表示します。

```sql
SELECT REGION_ID, START_KEY, END_KEY FROM INFORMATION_SCHEMA.TIKV_REGION_STATUS WHERE TABLE_ID = 120;
```

特定リージョンのピア情報を表示します。

```sql
SELECT REGION_ID, PEER_ID, STORE_ID FROM INFORMATION_SCHEMA.TIKV_REGION_PEERS WHERE REGION_ID = 44;
```

アドレスとリーダー数を含むTiKVストア情報を表示します。

```sql
SELECT STORE_ID, ADDRESS, LEADER_COUNT FROM INFORMATION_SCHEMA.TIKV_STORE_STATUS;
```

ターミナル1での操作。

```sql
BEGIN;
INSERT INTO products (id, name, price) VALUES (3, 'Notebook', 500);
SELECT * FROM products;
```

ターミナル2での操作。

```sql
BEGIN;
SELECT * FROM pd_test.products;
COMMIT;
```

ターミナル1での操作。

```sql
COMMIT;
```

ターミナル2での操作。

```sql
SELECT * FROM pd_test.products;
```

productsテーブルをキー範囲0-10000で4つのリージョンに手動で分割します。

```sql
SPLIT TABLE products BETWEEN (0) AND (10000) REGIONS 4;
```

テーブルのテーブルIDを取得します。

```sql
SELECT TABLE_NAME, TIDB_TABLE_ID FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='pd_test';
```

特定のテーブルの開始・終了キーを含むリージョン情報を表示します。

```sql
SELECT REGION_ID, START_KEY, END_KEY FROM INFORMATION_SCHEMA.TIKV_REGION_STATUS WHERE TABLE_ID = 120;
```

## Chapter 8

### 8.2 Terraformを使ったサーバのセットアップ

サーバーのSSHキーペアを生成します。

```bash
ssh-keygen -f ~/.ssh/sakura_cloud -t ed25519
```

Homebrewパッケージマネージャーを使用してmacOSにTerraformをインストールします。

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

LinuxにTerraformをダウンロードしてインストールします。

```bash
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

インストールされたバージョンを表示してTerraformのインストールを確認します。

```bash
terraform --version
```

書籍のサポートリポジトリからファイルをダウンロードし、terraformディレクトリに移動します。

```bash
git clone https://github.com/bohnen/bbf-newsql.git
cd terraform
```

Terraformの作業ディレクトリを初期化し、必要なプロバイダープラグイン（この場合はSakura Cloudプロバイダー）をダウンロードします。

```bash
terraform init
```

Terraform設定ファイルの構文エラーと一貫性を検証します。

```bash
terraform validate
```

Terraformが行う変更を表示します。（実行はしません）

```bash
terraform plan
```

Terraformを適用して実際のリソース（サーバー、ネットワークなど）を作成します。

```bash
terraform apply
```

秘密鍵を使用してSSHで踏み台サーバーに接続します。

```bash
ssh -i ~/.ssh/sakura_cloud ubuntu@133.125.81.30
```

### 8.3 Ansibleを使ってサーバをセットアップしよう

SSH秘密キーを踏み台サーバーに転送して、クラスター内のほかのサーバーへの接続を可能にします。

```bash
scp -i ~/.ssh/sakura_cloud ~/.ssh/sakura_cloud ubuntu@<踏み台サーバのIPアドレス>:~/.ssh/
```

SSHで踏み台サーバーに接続します。

```bash
ssh -i ~/.ssh/sakura_cloud -p 22 ubuntu@<踏み台サーバのIPアドレス>
```

パッケージリストを更新し、Ansibleインストールに必要なPython pipと仮想環境ツールをインストールします。

```bash
sudo apt update
sudo apt install -y python3-pip python3-venv
```

Ansible用の作業ディレクトリを作成し、Python仮想環境をセットアップ、アクティベートし、venv環境内でAnsibleをインストールします。

```bash
mkdir ~/ansible
cd ~/ansible
python3 -m venv venv
source venv/bin/activate
pip install ansible
```

バージョン情報と設定詳細を表示してAnsibleのインストールを確認します。

```bash
ansible --version
```

Ansibleのpingモジュールでクラスターグループのサーバーへの接続性をテストし、SSHアクセスとPythonの利用可能性を確認します。

```bash
ansible cluster -i inventory.ini -m ping
```

踏み台サーバーセットアッププレイブックを実行して、TiUPとMySQLクライアントをインストールします。

```bash
ansible-playbook -i inventory.ini bastion_playbook.yml --ask-become-pass
```

bash設定を再読み込みしてPATHを更新し、バージョン確認でTiUPのインストールを確認します。

```bash
source ~/.bashrc
tiup --version
```

クラスターセットアッププレイブックを実行します。

```bash
ansible-playbook -i inventory.ini cluster_playbook.yml --ask-become-pass
```

### 8.4 TiUPを使ってTiDBクラスターをセットアップしよう

サーバーがTiDBクラスター実行の要件を満たしているかチェックします。

```bash
tiup cluster check ./topology.yml --user ubuntu -i ~/.ssh/sakura_cloud
```

上記と同じチェックを実行しますが、可能な場合は検出された問題に対して修正を適用します。

```bash
tiup cluster check --apply ./topology.yml --user ubuntu -i ~/.ssh/sakura_cloud
```

指定されたトポロジーファイルを使用して、TiDBクラスターをデプロイします。

```bash
tiup cluster deploy tidb-test v8.1.1 ./topology.yml --user ubuntu -i ~/.ssh/sakura_cloud
```

デプロイされたTiDBクラスターを開始します。

```bash
tiup cluster start tidb-test --init
```

TiDBクラスター内のコンポーネントの現在のステータスと設定を表示します。

```bash
tiup cluster display tidb-test
```

MySQLクライアントを使用してTiDBサーバーに接続します。

```bash
mysql -h 192.168.100.11 -P 4000 -u root -p
```

TiDBバージョン情報を表示します。

```sql
SELECT VERSION();
```

### 8.5 TiDBクラスターを運用しよう

新しいノードをチェックします。

```bash
tiup cluster check tidb-test --apply scale-out.yml --cluster --user ubuntu -i ~/.ssh/sakura_cloud
```

スケールアウトトポロジーファイルを使用して既存のTiDBクラスターに新しいノードを追加します。

```bash
tiup cluster scale-out tidb-test scale-out.yml --user ubuntu -i ~/.ssh/sakura_cloud
```

新しく追加されたTiDBノードに接続します。

```bash
mysql -h 192.168.100.12 -P 4000 -u root -p
```

TiDBバージョン情報を表示します。

```sql
SELECT VERSION();
```

TiDBクラスターからノードを削除します。

```bash
tiup cluster scale-in tidb-test --node 192.168.100.12:4000
```

TiDBクラスターをバージョン8.1.2にローリングアップグレードします。

```bash
tiup cluster upgrade tidb-test v8.1.2
```

TiDBクラスターを停止します。

```bash
tiup cluster stop tidb-cluster
```

Terraformによって作成されたリソースをクリーンアップします。

```bash
terraform destroy
```
