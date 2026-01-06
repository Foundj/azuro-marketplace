#!/bin/bash

# Generate Implementation Constraints
# Extracts technical standards from project config and code samples
# Outputs: codebox/implementation-constraints.json

set -euo pipefail

CODEBOX_DIR="${CODEBOX_DIR:-codebox}"
OUTPUT_FILE="${CODEBOX_DIR}/implementation-constraints.json"

log_info() {
    echo "🔧 Constraints: $1"
}

# Extract tech stack from package.json
extract_tech_stack() {
    if [[ ! -f "package.json" ]]; then
        echo '[]'
        return
    fi
    
    local stack=()
    local deps=$(jq -r '(.dependencies // {}) + (.devDependencies // {}) | keys[]' package.json 2>/dev/null || echo "")
    
    # Detect frameworks
    [[ "$deps" == *"next"* ]] && stack+=("next.js")
    [[ "$deps" == *"react"* ]] && stack+=("react")
    [[ "$deps" == *"vue"* ]] && stack+=("vue")
    [[ "$deps" == *"express"* ]] && stack+=("express")
    [[ "$deps" == *"hono"* ]] && stack+=("hono")
    
    # TypeScript
    [[ -f "tsconfig.json" ]] && stack+=("typescript")
    
    # ORMs
    [[ "$deps" == *"drizzle"* ]] && stack+=("drizzle")
    [[ "$deps" == *"prisma"* ]] && stack+=("prisma")
    
    # Styling
    [[ "$deps" == *"tailwindcss"* ]] && stack+=("tailwind")
    
    # Testing
    [[ "$deps" == *"vitest"* ]] && stack+=("vitest")
    [[ "$deps" == *"jest"* ]] && stack+=("jest")
    
    # Validation
    [[ "$deps" == *"zod"* ]] && stack+=("zod")
    
    printf '%s\n' "${stack[@]}" | jq -R . | jq -s .
}

# Detect forbidden dependencies based on what's NOT in package.json
detect_forbidden_deps() {
    local forbidden=()
    local deps=$(jq -r '(.dependencies // {}) + (.devDependencies // {}) | keys[]' package.json 2>/dev/null || echo "")
    
    # If using drizzle, forbid prisma
    [[ "$deps" == *"drizzle"* ]] && [[ "$deps" != *"prisma"* ]] && forbidden+=("prisma")
    
    # If using prisma, forbid drizzle
    [[ "$deps" == *"prisma"* ]] && [[ "$deps" != *"drizzle"* ]] && forbidden+=("drizzle")
    
    # Common forbidden (heavy dependencies)
    [[ "$deps" != *"lodash"* ]] && forbidden+=("lodash")
    [[ "$deps" != *"moment"* ]] && forbidden+=("moment")
    [[ "$deps" != *"mongoose"* ]] && forbidden+=("mongoose")
    
    printf '%s\n' "${forbidden[@]}" | jq -R . | jq -s .
}

# Detect directory structure
detect_directories() {
    local dirs="{}"
    
    # Services
    if [[ -d "src/lib/services" ]]; then
        dirs=$(echo "$dirs" | jq '.services = "src/lib/services/"')
    elif [[ -d "src/services" ]]; then
        dirs=$(echo "$dirs" | jq '.services = "src/services/"')
    fi
    
    # Repositories
    if [[ -d "src/lib/repositories" ]]; then
        dirs=$(echo "$dirs" | jq '.repositories = "src/lib/repositories/"')
    elif [[ -d "src/repositories" ]]; then
        dirs=$(echo "$dirs" | jq '.repositories = "src/repositories/"')
    fi
    
    # Components
    if [[ -d "src/components" ]]; then
        dirs=$(echo "$dirs" | jq '.components = "src/components/"')
    fi
    
    # Types
    if [[ -d "src/types" ]]; then
        dirs=$(echo "$dirs" | jq '.types = "src/types/"')
    fi
    
    # Hooks
    if [[ -d "src/hooks" ]]; then
        dirs=$(echo "$dirs" | jq '.hooks = "src/hooks/"')
    fi
    
    # Utils/Lib
    if [[ -d "src/lib/utils" ]]; then
        dirs=$(echo "$dirs" | jq '.utils = "src/lib/utils/"')
    elif [[ -d "src/lib" ]]; then
        dirs=$(echo "$dirs" | jq '.lib = "src/lib/"')
    elif [[ -d "src/utils" ]]; then
        dirs=$(echo "$dirs" | jq '.utils = "src/utils/"')
    fi
    
    echo "$dirs"
}

# Detect naming patterns from existing files
detect_naming() {
    local naming="{}"
    
    # Services naming
    if ls src/lib/services/*.ts 2>/dev/null | head -1 | grep -q "[A-Z]"; then
        naming=$(echo "$naming" | jq '.service_file = "PascalCase.ts"')
    fi
    
    # Component naming
    if ls src/components/*.tsx 2>/dev/null | head -1 | grep -q "[A-Z]"; then
        naming=$(echo "$naming" | jq '.component_file = "PascalCase.tsx"')
    fi
    
    # Hook naming
    if ls src/hooks/*.ts 2>/dev/null | head -1 | grep -q "use-"; then
        naming=$(echo "$naming" | jq '.hook_file = "use-kebab-case.ts"')
    elif ls src/hooks/*.ts 2>/dev/null | head -1 | grep -q "use"; then
        naming=$(echo "$naming" | jq '.hook_file = "useCamelCase.ts"')
    fi
    
    # Default naming conventions
    naming=$(echo "$naming" | jq '.function = "camelCase"')
    naming=$(echo "$naming" | jq '.type = "PascalCase"')
    naming=$(echo "$naming" | jq '.constant = "UPPER_SNAKE_CASE"')
    
    echo "$naming"
}

# Detect import patterns
detect_patterns() {
    local patterns="{}"
    
    # Check for @ alias in tsconfig
    if [[ -f "tsconfig.json" ]]; then
        if jq -e '.compilerOptions.paths["@/*"]' tsconfig.json >/dev/null 2>&1; then
            patterns=$(echo "$patterns" | jq '.import = "@/ alias"')
        else
            patterns=$(echo "$patterns" | jq '.import = "relative"')
        fi
    fi
    
    # Check export style from sample files
    if grep -rq "^export default" src/ 2>/dev/null; then
        patterns=$(echo "$patterns" | jq '.export = "default"')
    else
        patterns=$(echo "$patterns" | jq '.export = "named"')
    fi
    
    # Async pattern
    patterns=$(echo "$patterns" | jq '.async = "async/await"')
    patterns=$(echo "$patterns" | jq '.error = "try-catch"')
    
    echo "$patterns"
}

# Extract forbidden patterns from CLAUDE.md
extract_forbidden() {
    local forbidden='["no any type", "no var", "no console.log in production"]'
    
    if [[ -f "${CODEBOX_DIR}/CLAUDE.md" ]]; then
        # Try to extract forbidden patterns from CLAUDE.md
        local claude_forbidden=$(grep -i "don't\|never\|avoid\|forbidden\|禁止" "${CODEBOX_DIR}/CLAUDE.md" 2>/dev/null | head -5 || echo "")
        # For now, use defaults
    fi
    
    if [[ -f "${CODEBOX_DIR}/constraints.md" ]]; then
        # Try to extract from constraints.md
        :
    fi
    
    echo "$forbidden"
}

# Find template files
find_templates() {
    local templates="{}"
    
    # Find a service template
    local service_file=$(ls src/lib/services/*.ts 2>/dev/null | head -1 || ls src/services/*.ts 2>/dev/null | head -1 || echo "")
    if [[ -n "$service_file" ]]; then
        templates=$(echo "$templates" | jq --arg f "$service_file" '.service = $f')
    fi
    
    # Find a repository template
    local repo_file=$(ls src/lib/repositories/*.ts 2>/dev/null | head -1 || ls src/repositories/*.ts 2>/dev/null | head -1 || echo "")
    if [[ -n "$repo_file" ]]; then
        templates=$(echo "$templates" | jq --arg f "$repo_file" '.repository = $f')
    fi
    
    # Find a component template
    local comp_file=$(ls src/components/*.tsx 2>/dev/null | head -1 || echo "")
    if [[ -n "$comp_file" ]]; then
        templates=$(echo "$templates" | jq --arg f "$comp_file" '.component = $f')
    fi
    
    echo "$templates"
}

# Main function
generate_constraints() {
    log_info "Generating implementation constraints..."
    
    local tech_stack=$(extract_tech_stack)
    local forbidden_deps=$(detect_forbidden_deps)
    local directories=$(detect_directories)
    local naming=$(detect_naming)
    local patterns=$(detect_patterns)
    local forbidden=$(extract_forbidden)
    local templates=$(find_templates)
    
    # Build final JSON
    jq -n \
        --argjson tech_stack "$tech_stack" \
        --argjson forbidden_deps "$forbidden_deps" \
        --argjson directories "$directories" \
        --argjson naming "$naming" \
        --argjson patterns "$patterns" \
        --argjson forbidden "$forbidden" \
        --argjson templates "$templates" \
        --arg generated "$(date -Iseconds)" \
        '{
            version: "1.0",
            generated: $generated,
            tech_stack: $tech_stack,
            forbidden_deps: $forbidden_deps,
            directories: $directories,
            naming: $naming,
            patterns: $patterns,
            forbidden: $forbidden,
            templates: $templates
        }'
}

# CLI
main() {
    local output_to_file=true
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -o|--stdout)
                output_to_file=false
                shift
                ;;
            -h|--help)
                echo "Usage: $(basename "$0") [-o|--stdout]"
                echo "Generates implementation constraints from project config and code."
                exit 0
                ;;
            *)
                shift
                ;;
        esac
    done
    
    local result=$(generate_constraints)
    
    if [[ "$output_to_file" == true ]]; then
        mkdir -p "$(dirname "$OUTPUT_FILE")"
        echo "$result" > "$OUTPUT_FILE"
        log_info "Saved to $OUTPUT_FILE"
    else
        echo "$result"
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
