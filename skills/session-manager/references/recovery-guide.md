# Session Recovery Guide

> Step-by-step recovery process for session-manager

## 7-Step Recovery Sequence

### Step 1: Confirm Location
```bash
pwd
# Verify current directory is project root
```

### Step 2: Read Progress
```bash
# Load last 50 lines of progress.txt
tail -50 .agent/progress.txt
```

### Step 3: Load Features
```bash
# Parse feature_list.json
jq '.features[] | select(.status != "completed")' .agent/feature_list.json
```

### Step 4: Check Git Status
```bash
git log -3 --oneline
git status
```

### Step 5: Start Environment
```bash
# init.sh 从未创建。若需初始化项目，请运行 project-initializer 技能或 /ai:dev "初始化项目"
```

### Step 6: Run Smoke Tests
```bash
npm test -- --grep "smoke" 2>/dev/null || true
```

### Step 7: Analyze & Recommend
- Calculate completion rate
- Identify next feature
- Check dependencies satisfied

## Troubleshooting

### Recovery Fails
- Ensure in correct project directory
- Check .agent/ directory exists
- Validate JSON file formats

### Environment Issues
- **init.sh**: 项目默认不包含此文件；若需初始化，请运行 project-initializer 或 `/ai:dev "初始化项目"`
- Verify dependencies installed
- Check port availability
