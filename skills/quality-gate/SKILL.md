---
name: quality-gate
description: |
  Automated quality gate system for comprehensive code assessment.
  Scores security, code quality, documentation, and architecture.
version: 4.1.3
---

# Quality Gate

> 代码质量门禁系统 - 确保代码达到发布标准

## 使用方式

### 手动触发

在 ai-dev 工作流中，Phase 5 完成后：

```
请执行质量门禁检查
```

### 与 ai-dev 集成

Quality Gate 在以下时机自动建议：
- Phase 5 (Review) 完成后
- 准备提交代码前
- CI/CD 流程中

---

## 评分维度详解

### 1. 安全性检查 (40%)

**检查项**:
- [ ] 无硬编码密钥/密码
- [ ] 无敏感信息日志输出
- [ ] SQL 参数化查询
- [ ] XSS 防护
- [ ] CSRF 防护
- [ ] 认证/授权正确实现

**扫描命令**:
```bash
# 检查敏感信息
grep -rn "password\|secret\|api_key\|token" --include="*.{js,ts,py,go}" . | grep -v node_modules
```

### 2. 代码质量 (30%)

**检查项**:
- [ ] 函数长度 < 50 行
- [ ] 圈复杂度 < 10
- [ ] 无重复代码块 (> 10 行)
- [ ] 命名遵循项目规范
- [ ] 无 TODO/FIXME 遗留

**工具建议**:
- JavaScript/TypeScript: ESLint, SonarJS
- Python: pylint, flake8
- Go: golint, staticcheck

### 3. 文档完整性 (20%)

**检查项**:
- [ ] 公开函数有注释
- [ ] README 更新
- [ ] API 文档 (如适用)
- [ ] CHANGELOG 更新 (如适用)

### 4. 架构合理性 (10%)

**检查项**:
- [ ] 模块职责单一
- [ ] 依赖方向正确 (高层不依赖低层实现)
- [ ] 无循环依赖
- [ ] 接口抽象合理

---

## 评分输出格式

```
╔════════════════════════════════════════════════════════════╗
║                    QUALITY GATE REPORT                     ║
╠════════════════════════════════════════════════════════════╣
║  Dimension        │ Score  │ Weight │ Weighted │ Status   ║
╠═══════════════════╪════════╪════════╪══════════╪══════════╣
║  🔒 Security      │  90/100│   40%  │   36.0   │ ✅ PASS  ║
║  📝 Code Quality  │  75/100│   30%  │   22.5   │ ✅ PASS  ║
║  📖 Documentation │  65/100│   20%  │   13.0   │ ✅ PASS  ║
║  🏗️ Architecture  │  80/100│   10%  │    8.0   │ ✅ PASS  ║
╠═══════════════════╧════════╧════════╧══════════╧══════════╣
║  TOTAL SCORE: 79.5/100                                     ║
║  STATUS: ✅ PASSED                                         ║
╚════════════════════════════════════════════════════════════╝
```

---

## 阈值配置

可在项目 `.claude-project/config.json` 中自定义：

```json
{
  "quality_gate": {
    "thresholds": {
      "total": 70,
      "security": 85,
      "code_quality": 60,
      "documentation": 50,
      "architecture": 50
    },
    "weights": {
      "security": 40,
      "code_quality": 30,
      "documentation": 20,
      "architecture": 10
    }
  }
}
```

---

## 失败处理

### 安全检查失败 (CRITICAL)

```
🚨 SECURITY CHECK FAILED

Issues found:
1. [HIGH] Hardcoded API key in src/config.js:15
2. [MEDIUM] SQL concatenation in src/db/user.js:42

Action Required:
- Fix all HIGH severity issues before merge
- Review MEDIUM issues with security team
```

### 总分不达标

```
⚠️ QUALITY GATE FAILED (Score: 65/100, Required: 70)

Recommendations:
1. Add documentation to 3 public functions
2. Reduce complexity in handleUserAuth() 
3. Remove 2 duplicate code blocks
```

---

## 最佳实践

1. **开发中检查**: 不要等到最后才运行质量门禁
2. **增量改进**: 每次提升 5-10 分比一次性达标更现实
3. **团队共识**: 确保团队理解并认同评分标准
4. **自动化**: 集成到 CI/CD 流程中
