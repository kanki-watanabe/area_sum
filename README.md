
# Weightcount3.R の README

## 概要
このスクリプトは、パイプラインネットワークのデータを処理し、各ノードの上流に存在する特定の値（例: 面積の合計）の累積値を計算します。計算結果はCSVファイルとして保存され、元のデータに結合されます。

## スクリプトの目的
- 各ノードの上流に存在する特定の値（例: 面積の合計）の累積値を計算する。
- 計算結果を元のデータに結合し、新しいCSVファイルとして保存する。

## 入力ファイル
1. **result8_m.csv**: パイプラインネットワークの基本データ（`upMH`, `downID`, `pipeID`, `weight`, `Upstreamcount`, `WeightSum`）。
2. **100point_2.csv**: 開始ノードのリスト。
3. **Shape_length.csv**: パイプの長さデータ（`pipeID`, `Shape_length`）。
4. **area.csv**: 面積の合計データ（`upMH`, `area_sum`）。
5. **pipe_env.csv**: 環境データ（`pipeID`, `removal`, `type`, `diameter`, `length`, `material`, `slope`, `year`）。

## 出力ファイル
1. **cumulative_{value_column}.csv**: 各ノードの上流に存在する特定の値の累積値を記録したCSVファイル。
2. **cumulative_{value_column}_m.csv**: 累積値を元のデータに結合したCSVファイル。

## スクリプトの手順
1. **データの読み込み**: 各入力ファイルを読み込み、必要なデータをマージします。
2. **累積値の計算**: BFS（幅優先探索）を使用して、各ノードの上流に存在する特定の値の累積値を計算します。
3. **結果の保存**: 計算結果をCSVファイルとして保存します。
4. **データの結合**: 計算結果を元のデータに結合し、新しいCSVファイルとして保存します。

## 使用関数
- **get_upstream_cumulative_value(data, start_node, value_column)**: 指定されたノードの上流に存在する特定の値の累積値を計算します。

## 主要な処理
1. **データのマージ**:
   - `result8_m.csv`、`pipe_env.csv`、`Shape_length.csv`、`area.csv` を `pipeID` または `upMH` をキーとして結合します。
2. **累積値の計算**:
   - 各ノードに対して、上流に存在する特定の値（例: `area_sum`）の累積値を計算します。
3. **結果の保存**:
   - 計算結果を `cumulative_{value_column}.csv` として保存します。
4. **データの結合**:
   - 計算結果を元のデータに結合し、`cumulative_{value_column}_m.csv` として保存します。

## 出力例
- **cumulative_area_sum.csv**:
  ```
  NodeID,CumulativeValue
  JQD0879001,12345.67
  JQD0879002,67890.12
  ...
  ```
- **cumulative_area_sum_m.csv**:
  ```
  upMH,downID,pipeID,weight,Upstreamcount,WeightSum,removal,type,diameter,length,material,slope,year,Shape_length,area_sum,cumulative_area_sum
  JQD0643001,JQD0643002,KQD0643001,1.2,3,4.5,0.1,TypeA,300,100,MaterialX,0.01,2000,100,500,12345.67
  ...
  ```

## 注意点
- 入力ファイルの形式とエンコーディングに注意してください（UTF-8）。
- 計算対象の列名（`value_column`）を適切に指定してください。デフォルトでは `area_sum` が指定されています。
- エラーハンドリングが含まれており、エラーが発生したノードはスキップされます。

## 依存関係
- **Rライブラリ**:
  - `readr`: CSVファイルの読み込みに使用。

## 作者
- kanki-watanabe (kanki.watanabe.s2@dc.tohoku.ac.jp)
