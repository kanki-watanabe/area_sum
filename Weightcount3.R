################# import data ###################################################

data <- read.csv("rawcsv/result8_m.csv", header = TRUE, col.names = c("upMH", "downID", "pipeID","weight", "Upstreamcount", "WeightSum"), fileEncoding = 'UTF-8', sep = ",", stringsAsFactors = FALSE)
start_nodes_data <- read.csv("rawcsv/100point_2.csv", header = TRUE, col.names = c("NodeID") ,fileEncoding = 'UTF-8', sep = ",", stringsAsFactors = FALSE)
length_data <- read.csv("rawcsv/Shape_length.csv", header = TRUE, col.names = c("pipeID","Shape_length") ,fileEncoding = 'UTF-8', sep = ",", stringsAsFactors = FALSE)
area_data <- read.csv("rawcsv/area.csv", header = TRUE, col.names = c("upMH","area_sum") ,fileEncoding = 'UTF-8', sep = ",", stringsAsFactors = FALSE)


library(readr)
# カラム名を英語に変換する
column_names <- c("pipeID", "removal", "type", "diameter", "length", "material", "slope", "year")
# readr パッケージを使用してファイルを読み込む
env_data <- read_csv("rawcsv/pipe_env.csv", col_names = column_names, skip = 1)

start_nodes_data[1,1] <- "JQD0879001"
start_nodes_data[1809,1] <- "JQD0879002"
length_data[1,1] <- "KQD0643001"
area_data[1,1] <- "JQD0643001"

# データのマージ
data <- merge(data, env_data, by = "pipeID", all.x = TRUE)
data <- merge(data, length_data, by = "pipeID", all.x = TRUE)
data <- merge(data, area_data, by = "upMH", all.x = TRUE)

# NA を 0 に置き換える
data$area_sum[is.na(data$area_sum)] <- 0
# 結果の表示
print(data)

##################################################################################

# BFSを使用して上流に存在する重みの累積を求める関数
get_upstream_cumulative_value <- function(data, start_node, value_column) {
  visited <- character(0)
  cumulative_value <- 0
  
  # 再帰的に上流ノードを探索する関数
  explore_upstream <- function(current_node) {
    # ノードが既に訪問されているかチェック
    if (current_node %in% visited) {
      return()
    }
    visited <<- c(visited, current_node)
    
    # ノードの累積する値を取得
    node_value <- data[data$downID == current_node, value_column]
    cumulative_value <<- cumulative_value + sum(node_value, na.rm = TRUE)
    
    # 上流ノードを取得
    upstream_nodes <- data[data$downID == current_node, "upMH"]
    
    # 再帰的に上流ノードを探索
    for (upstream_node in upstream_nodes) {
      explore_upstream(upstream_node)
    }
  }
  
  # 上流ノードの探索を開始
  explore_upstream(start_node)
  
  return(cumulative_value)
}

# 全体の処理
start_time <- Sys.time()

########################## 累積値を計算する対象の列名を指定#################

value_column <- "area_sum"  # ここに累積する値の列名を指定
file_name1 <- paste0("cumulative_",value_column,".csv")
file_name2 <- paste0("cumulative_",value_column,"_m.csv")
resultcol <- paste0("cumulative_",value_column)

############### 各ノードの上流に存在する値の累積を計算######################
total_nodes <- length(unique(data$downID))
upstream_data <- vector("list", total_nodes)
node_ids <- unique(data$downID)

for (i in seq_along(node_ids)) {
  node_id <- node_ids[i]
  cat("\rProcessing node:", i, "/", total_nodes, "(", round(i / total_nodes * 100, 2), "%)", sep = "")
  
  cumulative_value <- tryCatch({
    get_upstream_cumulative_value(data, node_id, value_column)
  }, error = function(e) {
    cat("\nError at node:", node_id, "- Skipping\n")
    return(c(NodeID = node_id, CumulativeValue = NA))
  })
  
  upstream_data[[i]] <- c(NodeID = node_id, CumulativeValue = cumulative_value)
}

# 上流データをデータフレームに変換
result <- do.call(rbind, upstream_data)
result <- as.data.frame(result, stringsAsFactors = FALSE)

# 時間計測終了
end_time <- Sys.time()

# 経過時間を表示
cat("\nElapsed time:", end_time - start_time, "\n")

# 結果を表示
print(result)

# 結果をCSVファイルに保存
write.csv(result, file_name1, row.names = FALSE)

############################################################

# 元のデータに result データフレームを "upMH" をキーとして結合
resultm <- result
colnames(resultm) <- c("upMH",resultcol)
merged_data <- merge(data, resultm, by.x = "upMH", by.y = "upMH", all.x = TRUE)

# NA を 0 に置き換える (必要に応じて)
merged_data$cumulative_area_sum[is.na(merged_data$cumulative_area_sum)] <- 0

# 結合後のデータを表示
print(merged_data)

write.csv(merged_data, file_name2, row.names = FALSE)
