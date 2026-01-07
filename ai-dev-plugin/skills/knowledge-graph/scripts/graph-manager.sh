#!/bin/bash

# Knowledge Graph Manager
# 管理项目知识图谱的增删查改

set -e

COMMAND="${1:-query}"
PROJECT_DIR="${2:-.}"
QUERY="${3:-}"

# 知识库路径
KNOWLEDGE_DIR="$PROJECT_DIR/.claude-project/knowledge"
NODES_FILE="$KNOWLEDGE_DIR/nodes.json"
RELATIONS_FILE="$KNOWLEDGE_DIR/relations.json"
INDEX_FILE="$KNOWLEDGE_DIR/index.json"

# 配置
MAX_RECORDS=50
RETENTION_DAYS=30

# 颜色
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 初始化知识库
init_knowledge() {
    mkdir -p "$KNOWLEDGE_DIR"
    
    if [[ ! -f "$NODES_FILE" ]]; then
        echo '[]' > "$NODES_FILE"
    fi
    
    if [[ ! -f "$RELATIONS_FILE" ]]; then
        echo '[]' > "$RELATIONS_FILE"
    fi
    
    if [[ ! -f "$INDEX_FILE" ]]; then
        cat > "$INDEX_FILE" << 'EOF'
{
  "version": "1.0.0",
  "last_updated": null,
  "total_nodes": 0,
  "total_relations": 0
}
EOF
    fi
}

# 清理过期和超量记录
cleanup() {
    init_knowledge
    
    local now=$(date +%s)
    local retention_seconds=$((RETENTION_DAYS * 86400))
    local cutoff_date=$(date -v-${RETENTION_DAYS}d +%Y-%m-%d 2>/dev/null || date -d "$RETENTION_DAYS days ago" +%Y-%m-%d)
    
    echo -e "${BLUE}[Knowledge Graph] Cleaning up old records...${NC}"
    
    # 删除超过保留期的记录
    if command -v jq &> /dev/null; then
        local before_count=$(jq 'length' "$NODES_FILE")
        
        # 按日期过滤
        jq --arg cutoff "$cutoff_date" '[.[] | select(.created_at >= $cutoff)]' "$NODES_FILE" > "${NODES_FILE}.tmp"
        mv "${NODES_FILE}.tmp" "$NODES_FILE"
        
        # 限制最大数量
        local current_count=$(jq 'length' "$NODES_FILE")
        if [[ $current_count -gt $MAX_RECORDS ]]; then
            jq "sort_by(.created_at) | reverse | .[:$MAX_RECORDS]" "$NODES_FILE" > "${NODES_FILE}.tmp"
            mv "${NODES_FILE}.tmp" "$NODES_FILE"
        fi
        
        local after_count=$(jq 'length' "$NODES_FILE")
        local removed=$((before_count - after_count))
        
        if [[ $removed -gt 0 ]]; then
            echo -e "${GREEN}Removed $removed old records${NC}"
        else
            echo -e "${GREEN}No records to clean${NC}"
        fi
        
        # 更新索引
        update_index
    else
        echo -e "${YELLOW}jq not installed, skipping cleanup${NC}"
    fi
}

# 更新索引
update_index() {
    if command -v jq &> /dev/null; then
        local node_count=$(jq 'length' "$NODES_FILE")
        local relation_count=$(jq 'length' "$RELATIONS_FILE")
        local now=$(date +%Y-%m-%dT%H:%M:%S)
        
        jq --arg updated "$now" \
           --argjson nodes "$node_count" \
           --argjson relations "$relation_count" \
           '.last_updated = $updated | .total_nodes = $nodes | .total_relations = $relations' \
           "$INDEX_FILE" > "${INDEX_FILE}.tmp"
        mv "${INDEX_FILE}.tmp" "$INDEX_FILE"
    fi
}

# 添加知识节点
add_node() {
    local type="$1"
    local title="$2"
    local description="$3"
    local tags="$4"
    
    init_knowledge
    
    local id="know-$(date +%Y%m%d%H%M%S)-$(printf '%04d' $RANDOM)"
    local project_name=$(basename "$PROJECT_DIR")
    local created_at=$(date +%Y-%m-%d)
    
    if command -v jq &> /dev/null; then
        local new_node=$(cat << EOF
{
  "id": "$id",
  "type": "$type",
  "title": "$title",
  "project": "$project_name",
  "description": "$description",
  "tags": $(echo "$tags" | jq -R 'split(",") | map(gsub("^\\s+|\\s+$"; ""))'),
  "created_at": "$created_at",
  "success_count": 0,
  "failure_count": 0
}
EOF
)
        jq --argjson node "$new_node" '. += [$node]' "$NODES_FILE" > "${NODES_FILE}.tmp"
        mv "${NODES_FILE}.tmp" "$NODES_FILE"
        
        update_index
        cleanup
        
        echo -e "${GREEN}Added knowledge node: $title${NC}"
        echo "ID: $id"
    else
        echo "Error: jq is required for this operation"
        exit 1
    fi
}

# 查询知识
query() {
    local search="$1"
    
    init_knowledge
    
    if [[ ! -f "$NODES_FILE" ]] || [[ $(cat "$NODES_FILE") == "[]" ]]; then
        echo -e "${YELLOW}Knowledge graph is empty${NC}"
        return
    fi
    
    if command -v jq &> /dev/null; then
        echo -e "${BLUE}[Knowledge Graph] Searching: $search${NC}"
        echo ""
        
        if [[ -z "$search" ]]; then
            # 显示所有
            jq -r '.[] | "[\(.type)] \(.title)\n  Project: \(.project)\n  Tags: \(.tags | join(", "))\n"' "$NODES_FILE"
        else
            # 搜索匹配
            jq -r --arg q "$search" \
                '[.[] | select(
                    (.title | ascii_downcase | contains($q | ascii_downcase)) or
                    (.description | ascii_downcase | contains($q | ascii_downcase)) or
                    (.tags | map(ascii_downcase) | any(contains($q | ascii_downcase)))
                )] | .[] | "[\(.type)] \(.title)\n  Project: \(.project)\n  Tags: \(.tags | join(", "))\n  Description: \(.description)\n"' "$NODES_FILE"
        fi
    else
        echo "Error: jq is required for this operation"
        exit 1
    fi
}

# 显示统计
stats() {
    init_knowledge
    
    echo -e "${BLUE}[Knowledge Graph] Statistics${NC}"
    echo ""
    
    if command -v jq &> /dev/null; then
        echo "Total Nodes: $(jq 'length' "$NODES_FILE")"
        echo "Total Relations: $(jq 'length' "$RELATIONS_FILE")"
        echo ""
        echo "By Type:"
        jq -r 'group_by(.type) | .[] | "  \(.[0].type): \(length)"' "$NODES_FILE"
        echo ""
        echo "Config:"
        echo "  Max Records: $MAX_RECORDS"
        echo "  Retention Days: $RETENTION_DAYS"
    else
        echo "Error: jq is required"
    fi
}

# 主入口
case "$COMMAND" in
    init)
        init_knowledge
        echo -e "${GREEN}Knowledge graph initialized${NC}"
        ;;
    add)
        add_node "${3:-solution}" "${4:-Untitled}" "${5:-}" "${6:-}"
        ;;
    query)
        query "$QUERY"
        ;;
    cleanup)
        cleanup
        ;;
    stats)
        stats
        ;;
    *)
        echo "Usage: graph-manager.sh <command> [project_dir] [args...]"
        echo ""
        echo "Commands:"
        echo "  init                    Initialize knowledge graph"
        echo "  add <type> <title>      Add knowledge node"
        echo "  query [search]          Query knowledge"
        echo "  cleanup                 Clean old records"
        echo "  stats                   Show statistics"
        ;;
esac
