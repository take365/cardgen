# トレーディングカードクラフター（cardgen）

静的 Web アプリとして動作する「トレーディングカード」作成ツールです。背景・枠・アイテム・アイコンを選び、タイトル/本文テキストを編集して、透過 PNG でエクスポートできます。補助ツールとして AI 画像生成ページ（OpenAI 画像モデル）も同梱しています。

## 主な機能
- 背景/枠/アイテム/アイコンの選択（モーダル UI + サムネ）
- 画像のドラッグ移動・スケール・簡易回転（Konva.js）
- タイトル/本文の編集（色/サイズ/太さ/フォント）と Google Fonts の URL 追加
- 自動レイアウト（枠ファイル名 `frame-[Main]-[Title]-[Description].png` に基づくゾーン調整）
- PNG エクスポート（透過、`pixelRatio=2`）
- アセットマニフェスト自動生成（PowerShell/Bash）
- サムネイル自動生成（任意、PowerShell/Bash、最長辺256px → `assets/_thumbs/`）
- AI 画像生成ページ（`docs/gen.html` または サイト直下の `gen.html`）で gpt-image-1 / dall-e-3 を利用可能

## ディレクトリ構成（抜粋）
```
cardgen/
├─ docs/               # 公開用（GitHub Pages 配信用）
│  ├─ index.html      # カード作成 UI 本体
│  ├─ gen.html        # AI 画像生成ページ
│  ├─ styles.css
│  └─ assets/
│     ├─ backgrounds/ # 背景画像
│     ├─ frames/      # 枠画像（frame-<Main>-<Title>-<Desc>.png 推奨）
│     ├─ icons/       # アイコン画像
│     ├─ items/       # アイテム画像
│     └─ manifest.json
├─ doc/               # 設計/ガイド類
│  ├─ 設計.md
│  ├─ カードレイアウト寸法ガイド.md
│  └─ フォント選択.md
├─ gen_manifest.ps1   # マニフェスト生成（PowerShell）
├─ gen_thumbs.ps1     # サムネイル生成（PowerShell, ImageMagick 必要）
├─ scripts_gen_manifest.sh # マニフェスト生成（Bash）
├─ scripts_gen_thumbs.sh   # サムネイル生成（Bash, ImageMagick 必要）
├─ start.ps1 / start.bat   # ローカル起動補助（Windows）※ docs を優先
├─ Dockerfile / nginx.conf # コンテナ配信（nginx:alpine）
```

## クイックスタート
### 1) Windows（推奨）
- `start.bat` を実行（内部で `start.ps1` を呼び出し、マニフェストを自動生成してローカルサーバを起動）
- 既定ポート: `http://localhost:8080`
- ポート変更: PowerShell で `./start.ps1 -Port 3000`

### 2) Docker（全 OS）
```
docker build -t cardgen-mvp .
docker run --rm -p 8080:8080 cardgen-mvp
# → http://localhost:8080
```

### 3) Python HTTP サーバ（手動）
```
cd docs
python3 -m http.server 8080 --bind 127.0.0.1
# → http://localhost:8080
```

## 使い方（カード作成）
1. ブラウザで `http://localhost:8080` を開く
2. 左ペインから「背景/枠/アイテム/アイコンを選択」で素材モーダルを開く
   - サムネをクリックで反映。画像はドラッグ移動、ツールバーで拡大/縮小可
3. タイトル/本文を入力（詳細から色/サイズ/太さ/フォントを調整）
   - Google Fonts を追加する場合は「＋追加…」→ CSS URL（`https://fonts.googleapis.com/css2?...`）を貼り付け
4. 右上ツールバーの表示倍率でプレビューを調整
5. 「PNG保存」で透過 PNG をダウンロード（`pixelRatio=2`）

初期状態（デフォルト）
- 背景: `SSR.png`
- 枠: `frame3.png`
- アイテム: `soad.png`
- アイコン: `sun.png`
- タイトル: 「勇者のつるぎ」
- 本文: 「魔王を倒した伝説のつるぎ。\n勇者の押し入れの奥底に眠る。」

## アセットの追加とマニフェスト/サムネイル
- 画像を `docs/assets/` 配下の各ディレクトリに配置（`backgrounds/`, `frames/`, `icons/`, `items/`）
- （任意）サムネイルを生成（高速化推奨。生成後にマニフェスト再生成）
  - PowerShell: `./gen_thumbs.ps1 -AssetsRoot docs/assets -MaxSize 256`
  - Bash: `bash ./scripts_gen_thumbs.sh docs`
- マニフェストを更新（どちらか）
  - Windows: `./start.ps1` 実行時に自動生成
  - PowerShell: `./gen_manifest.ps1`
  - Bash: `./scripts_gen_manifest.sh`

枠ファイル名ルール（任意・推奨）
```
frame-[Main]-[Title]-[Description].png
# 例: frame-550-100-250.png
```
この数値から、メイン/タイトル/説明の各ゾーン高さを自動推定し、初期レイアウトに反映します。

メモ（マニフェスト形式）
- サムネイルが存在する場合は `{"src":"assets/...","thumb":"assets/_thumbs/..."}` 形式で出力されます。
- サムネイルがない場合は従来どおり文字列（`"assets/..."`）。アプリ側はどちらも解釈可能です。

## AI 画像生成（オプション）
- `http://localhost:8080/gen.html`
- OpenAI API キーを入力（保存しません）
- プロンプト、モデル（gpt-image-1 / dall-e-3）、サイズ/品質/背景（透過）などを設定
- 「生成する」で作成、ギャラリー表示からダウンロード可能
- 注意: ブラウザから直接 API を叩くため、公開環境ではサーバレス関数等の経由を推奨

## トラブルシュート
- 素材が表示されない: `docs/assets/manifest.json` が最新か確認。必要ならマニフェストを再生成
- フォントが反映されない: Google Fonts の URL が正しいか、CSS が読み込める環境か確認
- `file://` で開くと動かない: `fetch` 制約のため、必ずローカルサーバ（上記の http.server / Docker）で起動

## 開発メモ
- 主要ライブラリ: Konva.js（CDN）
- 配信: nginx（alpine）、HTML は no-cache、静的アセットは long cache（immutable）
- 既知: レイヤ数が多め（最適化余地あり）。ブラウザ内保存（IndexedDB）は端末/ブラウザ毎で独立

---
不明点や改善要望があれば Issue/連絡でお知らせください。
