# Ridgepole 使用方法

## 概要
Ridgepoleは、RailsのスキーマをDSL形式で管理するツールです。マイグレーションファイルの代わりに`Schemafile`を使用してデータベーススキーマを宣言的に定義します。

## セットアップ

### 1. Gemfileに追加
```ruby
gem 'ridgepole'
```

### 2. bundle install
```bash
docker compose exec web bundle install
```

### 3. Schemafileの作成
`db/Schemafile`を作成し、スキーマを定義します。

## 基本的な使い方

### スキーマの適用
```bash
docker compose exec web bundle exec ridgepole -c config/database.yml -E development --apply -f db/Schemafile
```

### Dry-run（変更内容の確認）
```bash
docker compose exec web bundle exec ridgepole -c config/database.yml -E development --apply -f db/Schemafile --dry-run
```

### 既存のスキーマからSchemafileを生成
```bash
docker compose exec web bundle exec ridgepole -c config/database.yml -E development --export -o db/Schemafile
```

## Schemafileの記述例

```ruby
create_table "users", force: :cascade do |t|
  t.string "name", null: false
  t.string "email", null: false, index: { unique: true }
  t.timestamps
end

create_table "posts", force: :cascade do |t|
  t.bigint "user_id", null: false, index: true
  t.string "title", null: false
  t.text "content"
  t.timestamps
end

add_foreign_key "posts", "users"
```

## オプション

- `-c, --config`: database.ymlのパス
- `-E, --env`: 環境（development, test, production）
- `-f, --file`: Schemafileのパス
- `--apply`: スキーマを適用
- `--dry-run`: 実行せずに変更内容を表示
- `--export`: 現在のスキーマをSchemafileとして出力

## 注意点

1. **破壊的な変更**: カラムやテーブルの削除は自動で実行されます
2. **データの保持**: データは保持されますが、スキーマ変更時は事前にバックアップを推奨
3. **マイグレーション履歴**: Ridgepoleはマイグレーション履歴を使用しないため、schema_migrationsテーブルは使用されません

## トラブルシューティング

### エラー: "no configuration file provided: not found"
- Schemafileが存在するか確認
- `-f` オプションでSchemafileのパスを正しく指定

### エラー: "bundler: command not found: ridgepole"
- `bundle install` を実行してridgepoleをインストール

## 参考リンク
- [Ridgepole GitHub](https://github.com/ridgepole/ridgepole)
