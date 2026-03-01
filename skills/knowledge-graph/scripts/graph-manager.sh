#!/bin/bash

# Knowledge Graph Manager
# 管理项目知识图谱的增删查改
# v2: 增加 active/superseded 生命周期管理

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
  "version": "2.0.0",
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

    local cutoff_date=$(date -v-${RETENTION_DAYS}d +%Y-%m-%d 2>/dev/null || date -d "$RETENTION_DAYS days ago" +%Y-%m-%d)

    echo -e "${BLUE}[Knowledge Graph] Cleaning up old records...${NC}"

    if command -v jq &> /dev/null; then
        local before_count=$(jq 'length' "$NODES_FILE")

        # Priority 1: Remove superseded records older than retention period
        jq --arg cutoff "$cutoff_date" '[.[] | select(
            (.status == "superseded" and .created_at >= $cutoff) or
            (.status != "superseded")
        )]' "$NODES_FILE" > "${NODES_FILE}.tmp"
        mv "${NODES_FILE}.tmp" "$NODES_FILE"

        # Priority 2: Remove any records older than retention period
        jq --arg cutoff "$cutoff_date" '[.[] | select(.created_at >= $cutoff)]' "$NODES_FILE" > "${NODES_FILE}.tmp"
        mv "${NODES_FILE}.tmp" "$NODES_FILE"

        # Priority 3: If still over limit, remove superseded first, then oldest
        local current_count=$(jq 'length' "$NODES_FILE")
        if [[ $current_count -gt $MAX_RECORDS ]]; then
            # Keep active records, drop superseded first
            jq --argjson max "$MAX_RECORDS" '
                ([ .[] | select(.status != "superseded") ] | sort_by(.created_at) | reverse) as $active |
                ([ .[] | select(.status == "superseded") ] | sort_by(.created_at) | reverse) as $superseded |
                ($active + $superseded) | .[:$max]
            ' "$NODES_FILE" > "${NODES_FILE}.tmp"
            mv "${NODES_FILE}.tmp" "$NODES_FILE"
        fi

        local after_count=$(jq 'length' "$NODES_FILE")
        local removed=$((before_count - after_count))

        if [[ $removed -gt 0 ]]; then
            echo -e "${GREEN}Removed $removed old records${NC}"
        else
            echo -e "${GREEN}No records to clean${NC}"
        fi

        update_index
    else
        echo -e "${YELLOW}jq not installed, skipping cleanup${NC}"
    fi
}

# 更新索引
update_index() {
    if command -v jq &> /dev/null; then
        local node_count=$(jq 'length' "$NODES_FILE")
        local active_count=$(jq '[.[] | select(.status == "active" or (.status == null))] | length' "$NODES_FILE")
        local relation_count=$(jq 'length' "$RELATIONS_FILE")
        local now=$(date +%Y-%m-%dT%H:%M:%S)

        jq --arg updated "$now" \
           --argjson nodes "$node_count" \
           --argjson active "$active_count" \
           --argjson relations "$relation_count" \
           '.last_updated = $updated | .total_nodes = $nodes | .active_nodes = $active | .total_relations = $relations' \
           "$INDEX_FILE" > "${INDEX_FILE}.tmp"
        mv "${INDEX_FILE}.tmp" "$INDEX_FILE"
    fi
}

# 标记同 project + 重叠 tags 的旧记录为 superseded
supersede_old_nodes() {
    local project="$1"
    local tags_csv="$2"

    if [[ -z "$tags_csv" ]]; then
        return
    fi

    # Mark old nodes with same project and any overlapping tag as superseded
    jq --arg project "$project" \
       --arg tags_csv "$tags_csv" '
        ($tags_csv | split(",") | map(gsub("^\\s+|\\s+$"; ""))) as $new_tags |
        [.[] | if (
            .project == $project and
            (.status == "active" or (.status == null)) and
            (.tags | map(ascii_downcase) | any(. as $t | $new_tags | map(ascii_downcase) | any(. == $t)))
        ) then
            .status = "superseded"
        else
            .
        end]
    ' "$NODES_FILE" > "${NODES_FILE}.tmp"
    mv "${NODES_FILE}.tmp" "$NODES_FILE"
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
        # Supersede old records with overlapping tags in same project
        supersede_old_nodes "$project_name" "$tags"

        local new_node=$(cat << EOF
{
  "id": "$id",
  "type": "$type",
  "title": "$title",
  "project": "$project_name",
  "description": "$description",
  "tags": $(echo "$tags" | jq -R 'split(",") | map(gsub("^\\s+|\\s+$"; ""))'),
  "created_at": "$created_at",
  "status": "active",
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
    local show_all="${2:-false}"

    init_knowledge

    if [[ ! -f "$NODES_FILE" ]] || [[ $(cat "$NODES_FILE") == "[]" ]]; then
        echo -e "${YELLOW}Knowledge graph is empty${NC}"
        return
    fi

    if command -v jq &> /dev/null; then
        echo -e "${BLUE}[Knowledge Graph] Searching: ${search:-all}${NC}"
        echo ""

        # Build status filter: active-only by default, all with --all
        local status_filter
        if [[ "$show_all" == "true" ]]; then
            status_filter='.'
        else
            status_filter='[.[] | select(.status == "active" or (.status == null))]'
        fi

        if [[ -z "$search" ]]; then
            jq -r "$status_filter"' | .[] | "[\(.type)] \(.title) [\(.status // "active")]\n  Project: \(.project)\n  Tags: \(.tags | join(", "))\n"' "$NODES_FILE"
        else
            jq -r --arg q "$search" "
                ${status_filter} |
                [.[] | select(
                    (.title | ascii_downcase | contains(\$q | ascii_downcase)) or
                    (.description | ascii_downcase | contains(\$q | ascii_downcase)) or
                    (.tags | map(ascii_downcase) | any(contains(\$q | ascii_downcase)))
                )] | .[] | \"[\(.type)] \(.title) [\(.status // \"active\")]\n  Project: \(.project)\n  Tags: \(.tags | join(\", \"))\n  Description: \(.description)\n\"
            " "$NODES_FILE"
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
        local total=$(jq 'length' "$NODES_FILE")
        local active=$(jq '[.[] | select(.status == "active" or (.status == null))] | length' "$NODES_FILE")
        local superseded=$(jq '[.[] | select(.status == "superseded")] | length' "$NODES_FILE")

        echo "Total Nodes: $total (active: $active, superseded: $superseded)"
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
        show_all="false"
        # Check for --all flag
        for arg in "$@"; do
            if [[ "$arg" == "--all" ]]; then
                show_all="true"
            fi
        done
        query "$QUERY" "$show_all"
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
        echo "  query [search]          Query active knowledge (use --all for all)"
        echo "  cleanup                 Clean old records (superseded first)"
        echo "  stats                   Show statistics"
        ;;
esac
