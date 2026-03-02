# Pre-Change Hook: Phase 0 Knowledge Check

> 在任何变更开始前自动执行此 hook，确保全局约束存在和知识预查完成

---

## 🎯 目的

Phase 0 是所有变更的第一阶段，在进入 Phase 1（需求澄清）之前执行：

1. **全局约束验证** - 确保项目有统一的规范和约束
2. **知识库预查** - 查询历史成功模式和错误，避免重复错误
3. **合规性预检** - 验证变更描述是否明确，是否符合技术栈约束
4. **风险评估** - 基于知识库识别潜在风险

## 📋 执行流程

### Step 1: 全局约束检查

```typescript
async function checkGlobalConstraints(): Promise<ConstraintCheckResult> {
  const projectRoot = '.agent';
  const requiredFiles = [
    'requirements.md',
    'design.md',
    'CLAUDE.md',
    'constraints.md'
  ];

  const results = {
    exists: true,
    missing: [] as string[],
    recommendation: ''
  };

  for (const file of requiredFiles) {
    const filePath = `${projectRoot}/${file}`;
    if (!fs.existsSync(filePath)) {
      results.exists = false;
      results.missing.push(file);
    }
  }

  if (!results.exists) {
    results.recommendation = `
⚠️ 全局约束文件缺失！

缺少文件:
${results.missing.map(f => `  - ${f}`).join('\n')}

建议操作:
1. 运行 project-initializer 初始化项目
2. 或手动创建缺失的全局约束文件

全局约束的作用:
- requirements.md: 项目级需求，所有变更必须引用
- design.md: 全局架构模式，确保一致性
- CLAUDE.md: AI 行为约束，统一代码风格
- constraints.md: 质量门禁，所有变更必须通过

没有全局约束，AI 可能在多个 feature 间产生不一致的设计和实现。
    `;
    return results;
  }

  results.recommendation = '✅ 全局约束文件完整';
  return results;
}
```

### Step 2: 知识库查询

**Schema参考**: [Knowledge Base Schema](../references/knowledge-base-schema.md)

```typescript
interface KnowledgeQuery {
  query: string;           // 用户的变更描述
  categories: string[];    // 查询类别: patterns, errors, learnings
  tags?: string[];         // 可选标签过滤
}

interface KnowledgeCheckResult {
  relatedPatterns: Pattern[];
  relatedErrors: HistoricalError[];
  riskLevel: 'low' | 'medium' | 'high' | 'critical';
  preventionMeasures: string[];
  recommendations: string[];
  suggestedFiles?: string[];  // 基于patterns建议参考的文件
}

async function queryKnowledgeBase(query: KnowledgeQuery): Promise<KnowledgeCheckResult> {
  const knowledgeDir = '.agent/knowledge';

  // 1. 读取知识库文件
  const patternsDB = JSON.parse(Bash(`cat ${knowledgeDir}/patterns.json`));
  const errorsDB = JSON.parse(Bash(`cat ${knowledgeDir}/errors.json`));
  const learnings = Bash(`cat ${knowledgeDir}/learnings.md`);

  // 2. 提取查询关键词和推断tags
  const keywords = extractKeywords(query.query);
  const inferredTags = inferTagsFromQuery(query.query);
  const allTags = [...(query.tags || []), ...inferredTags];

  console.log(`🔍 查询关键词: ${keywords.join(', ')}`);
  console.log(`🏷️  推断标签: ${allTags.join(', ')}`);

  // 3. 查询相关成功模式
  const relatedPatterns = findRelevantPatterns(
    patternsDB.patterns,
    keywords,
    allTags
  );

  console.log(`✅ 找到 ${relatedPatterns.length} 个相关模式`);
  relatedPatterns.forEach(p => {
    console.log(`   - ${p.id}: ${p.name} (使用${p.usageCount}次, 成功率${p.successRate}%)`);
  });

  // 4. 查询相关历史错误
  const relatedErrors = findRelevantErrors(
    errorsDB.errors,
    keywords,
    allTags
  );

  // 过滤未解决的高风险错误
  const unresolvedErrors = relatedErrors.filter(e => !e.resolved);

  console.log(`⚠️  识别 ${relatedErrors.length} 个相关历史错误`);
  unresolvedErrors.forEach(e => {
    console.log(`   - ${e.id}: ${e.symptom} (${e.riskLevel}, 发生${e.occurrenceCount}次)`);
  });

  // 5. 风险评估
  const riskLevel = assessRisk(unresolvedErrors);
  console.log(`🚨 风险等级: ${riskLevel}`);

  // 6. 提取预防措施
  const preventionMeasures = extractPreventionMeasures(unresolvedErrors);

  // 7. 生成推荐
  const recommendations = generateRecommendations(
    relatedPatterns,
    unresolvedErrors
  );

  // 8. 收集建议参考的文件
  const suggestedFiles = collectSuggestedFiles(relatedPatterns, relatedErrors);

  return {
    relatedPatterns,
    relatedErrors: unresolvedErrors,
    riskLevel,
    preventionMeasures,
    recommendations,
    suggestedFiles
  };
}

// === 辅助函数 ===

/**
 * 从查询中提取关键词
 */
function extractKeywords(query: string): string[] {
  const stopWords = ['的', '是', '在', '和', '了', '有', '个', '用', 'a', 'the', 'is', 'to'];
  return query
    .toLowerCase()
    .split(/[\s,，、。]+/)
    .filter(word => word.length > 1 && !stopWords.includes(word));
}

/**
 * 从查询中推断tags
 */
function inferTagsFromQuery(query: string): string[] {
  const tagMap: Record<string, string[]> = {
    'login|登录|auth|认证|授权': ['authentication', 'authorization'],
    'database|数据库|db|存储': ['database'],
    'api|接口|endpoint': ['api'],
    'test|测试|unit': ['testing'],
    'ui|界面|component|组件': ['ui'],
    'upload|上传|file|文件': ['validation', 'file-upload'],
    'performance|性能|优化|慢': ['performance'],
    'error|错误|异常|exception': ['error-handling'],
  };

  const inferredTags: string[] = [];
  const lowerQuery = query.toLowerCase();

  for (const [pattern, tags] of Object.entries(tagMap)) {
    const regex = new RegExp(pattern, 'i');
    if (regex.test(lowerQuery)) {
      inferredTags.push(...tags);
    }
  }

  return Array.from(new Set(inferredTags));
}

/**
 * 查找相关成功模式
 */
function findRelevantPatterns(
  patterns: Pattern[],
  keywords: string[],
  tags: string[]
): Pattern[] {
  return patterns
    .map(pattern => {
      let score = 0;

      // 关键词匹配（名称、描述）
      keywords.forEach(keyword => {
        if (pattern.name.toLowerCase().includes(keyword)) score += 10;
        if (pattern.description.toLowerCase().includes(keyword)) score += 5;
        if (pattern.context?.toLowerCase().includes(keyword)) score += 3;
      });

      // 标签匹配
      tags.forEach(tag => {
        if (pattern.tags.includes(tag)) score += 15;
        if (pattern.category === tag) score += 20;
      });

      // 成功率加分
      if (pattern.successRate >= 95) score += 5;

      // 使用频率加分
      if (pattern.usageCount > 10) score += 3;

      return { pattern, score };
    })
    .filter(item => item.score > 0)
    .sort((a, b) => b.score - a.score)
    .slice(0, 5)  // 返回top 5
    .map(item => item.pattern);
}

/**
 * 查找相关历史错误
 */
function findRelevantErrors(
  errors: HistoricalError[],
  keywords: string[],
  tags: string[]
): HistoricalError[] {
  return errors
    .map(error => {
      let score = 0;

      // 关键词匹配
      keywords.forEach(keyword => {
        if (error.symptom.toLowerCase().includes(keyword)) score += 10;
        if (error.rootCause.toLowerCase().includes(keyword)) score += 8;
      });

      // 标签匹配
      tags.forEach(tag => {
        if (error.tags.includes(tag)) score += 15;
        if (error.category === tag) score += 20;
      });

      // 风险等级加权
      const riskWeight = {
        'critical': 20,
        'high': 15,
        'medium': 5,
        'low': 0
      };
      score += riskWeight[error.riskLevel] || 0;

      // 未解决的错误优先
      if (!error.resolved) score += 10;

      // 最近发生的错误优先
      if (error.lastOccurred) {
        const daysSince = (Date.now() - new Date(error.lastOccurred).getTime()) / (1000 * 60 * 60 * 24);
        if (daysSince < 30) score += 10;  // 30天内发生
        else if (daysSince < 90) score += 5;  // 90天内发生
      }

      return { error, score };
    })
    .filter(item => item.score > 0)
    .sort((a, b) => b.score - a.score)
    .map(item => item.error);
}

/**
 * 风险评估
 */
function assessRisk(errors: HistoricalError[]): 'low' | 'medium' | 'high' | 'critical' {
  if (errors.length === 0) return 'low';

  const criticalCount = errors.filter(e => e.riskLevel === 'critical').length;
  const highCount = errors.filter(e => e.riskLevel === 'high').length;
  const unresolvedCount = errors.filter(e => !e.resolved).length;

  if (criticalCount > 0) return 'critical';
  if (highCount >= 2 || (highCount === 1 && unresolvedCount >= 2)) return 'high';
  if (highCount === 1 || unresolvedCount > 0) return 'medium';
  return 'low';
}

/**
 * 提取预防措施
 */
function extractPreventionMeasures(errors: HistoricalError[]): string[] {
  const allMeasures = errors.flatMap(e => e.preventionMeasures);
  // 去重
  return Array.from(new Set(allMeasures));
}

/**
 * 生成推荐
 */
function generateRecommendations(
  patterns: Pattern[],
  errors: HistoricalError[]
): string[] {
  const recommendations: string[] = [];

  // 基于成功模式的推荐
  patterns.forEach(p => {
    recommendations.push(
      `使用 ${p.id} (${p.name}) - ${p.description}`
    );
  });

  // 基于错误的推荐（关联的预防模式）
  errors.forEach(e => {
    if (e.relatedPatterns && e.relatedPatterns.length > 0) {
      e.relatedPatterns.forEach(patternId => {
        recommendations.push(
          `为避免 ${e.id}，建议使用 ${patternId}`
        );
      });
    }
  });

  return recommendations;
}

/**
 * 收集建议参考的文件
 */
function collectSuggestedFiles(
  patterns: Pattern[],
  errors: HistoricalError[]
): string[] {
  const files: string[] = [];

  // 从patterns收集
  patterns.forEach(p => {
    if (p.files) files.push(...p.files);
  });

  // 从errors收集
  errors.forEach(e => {
    if (e.relatedFiles) files.push(...e.relatedFiles);
  });

  // 去重并排序
  return Array.from(new Set(files)).sort();
}
```

### 实际执行示例

```bash
# 示例1: 查询"实现用户登录"
用户输入: "实现用户登录功能，支持JWT认证"

查询执行:
🔍 查询关键词: 实现, 用户, 登录, 功能, 支持, jwt, 认证
🏷️  推断标签: authentication, authorization, api
✅ 找到 3 个相关模式
   - PATTERN-001: Repository Pattern (使用25次, 成功率98%)
   - PATTERN-002: Service Layer Pattern (使用18次, 成功率95%)
   - PATTERN-003: Zod Schema Validation (使用42次, 成功率100%)
⚠️  识别 2 个相关历史错误
   - ERROR-001: 未处理的Promise rejection (high, 发生3次)
   - ERROR-002: API返回500而非400验证错误 (medium, 发生5次)
🚨 风险等级: medium

预防措施:
1. 所有async函数必须使用try-catch包裹
2. 添加ESLint规则 no-floating-promises
3. 所有API endpoints必须使用Zod schema验证输入
4. 添加集成测试覆盖invalid input场景

推荐:
1. 使用 PATTERN-001 (Repository Pattern) - 使用Repository模式隔离数据访问层
2. 使用 PATTERN-002 (Service Layer Pattern) - 业务逻辑封装在Service层
3. 使用 PATTERN-003 (Zod Schema Validation) - 使用Zod进行运行时类型验证
4. 为避免 ERROR-001，建议使用 PATTERN-004
5. 为避免 ERROR-002，建议使用 PATTERN-003

建议参考文件:
- src/lib/interfaces/IUserRepository.ts
- src/lib/repositories/UserRepository.ts
- src/lib/services/AuthService.ts
- src/lib/schemas/auth.ts
- src/app/api/auth/login/route.ts
```

```bash
# 示例2: 查询"文件上传"
用户输入: "实现用户头像上传功能"

查询执行:
🔍 查询关键词: 实现, 用户, 头像, 上传, 功能
🏷️  推断标签: validation, file-upload, ui
✅ 找到 1 个相关模式
   - PATTERN-003: Zod Schema Validation (使用42次, 成功率100%)
⚠️  识别 1 个相关历史错误
   - ERROR-005: 用户上传超大文件导致服务器崩溃 (high, 发生2次, 未解决)
🚨 风险等级: high

预防措施:
1. 使用multer或类似中间件限制文件大小（如10MB）
2. 在前端也添加文件大小验证提供即时反馈
3. 添加集成测试上传超大文件验证错误处理

推荐:
1. 使用 PATTERN-003 (Zod Schema Validation) - 使用Zod进行运行时类型验证
2. 为避免 ERROR-005，建议使用 PATTERN-003

建议参考文件:
- src/lib/schemas/auth.ts
- src/app/api/upload/route.ts
- src/middleware/upload.ts

⚠️ 注意: ERROR-005 尚未解决，风险等级high！
建议在Phase 1 proposal中明确文件大小限制策略。
```

### Step 3: 合规性预检查

```typescript
interface ComplianceCheck {
  isDescriptionClear: boolean;
  canMapToRequirements: boolean;
  isTechStackCompliant: boolean;
  issues: string[];
  suggestions: string[];
}

async function checkCompliance(
  userRequest: string,
  globalRequirements: string
): Promise<ComplianceCheck> {
  const result: ComplianceCheck = {
    isDescriptionClear: true,
    canMapToRequirements: true,
    isTechStackCompliant: true,
    issues: [],
    suggestions: []
  };

  // 1. 描述明确性检查
  if (userRequest.length < 10) {
    result.isDescriptionClear = false;
    result.issues.push('变更描述过于简短，缺少上下文');
    result.suggestions.push('提供更详细的描述：要实现什么功能？为什么需要？');
  }

  const ambiguousWords = ['这个', '那个', '它', '一些', '可能'];
  if (ambiguousWords.some(word => userRequest.includes(word))) {
    result.issues.push('描述包含模糊词汇');
    result.suggestions.push('使用明确的名词和动词描述需求');
  }

  // 2. 全局需求映射检查
  const requirements = parseRequirements(globalRequirements);
  const mappable = requirements.some(req =>
    isRelated(userRequest, req)
  );

  if (!mappable && requirements.length > 0) {
    result.canMapToRequirements = false;
    result.issues.push('无法映射到任何全局需求');
    result.suggestions.push('确认此变更是否符合项目范围，或更新 requirements.md 添加新需求');
  }

  // 3. 技术栈合规性检查
  const constrainedTechStack = extractTechStack(globalRequirements);
  const mentionedTech = extractMentionedTech(userRequest);

  const violations = mentionedTech.filter(tech =>
    !constrainedTechStack.includes(tech)
  );

  if (violations.length > 0) {
    result.isTechStackCompliant = false;
    result.issues.push(`使用了约束外的技术: ${violations.join(', ')}`);
    result.suggestions.push('使用项目约定的技术栈，或先更新 requirements.md 获得批准');
  }

  return result;
}
```

### Step 4: 生成 Knowledge Context

```typescript
interface KnowledgeContext {
  timestamp: string;
  relatedPatterns: string[];
  relatedErrors: string[];
  riskLevel: string;
  preventionMeasures: string[];
  recommendations: string[];
  complianceIssues: string[];
}

function generateKnowledgeContext(
  knowledgeResult: KnowledgeCheckResult,
  complianceResult: ComplianceCheck
): string {
  const context = `
## 📚 知识预查 (Phase 0)

**查询时间**: ${new Date().toISOString()}

### 🎯 相关成功模式

${knowledgeResult.relatedPatterns.length > 0
  ? knowledgeResult.relatedPatterns.map(p => `
- **${p.id}**: ${p.name}
  - **适用场景**: ${p.when_to_use}
  - **收益**: ${p.benefits.join(', ')}
  - **参考**: ${p.example_file}
`).join('\n')
  : '暂无相关成功模式（这是新领域）'
}

### ⚠️ 历史错误（需避免）

${knowledgeResult.relatedErrors.length > 0
  ? knowledgeResult.relatedErrors.map(e => `
- **${e.id}**: ${e.title} (严重程度: ${e.severity})
  - **根因**: ${e.root_cause}
  - **发生次数**: ${e.occurrences}
  - **参考**: 查看 knowledge/errors.json
`).join('\n')
  : '✅ 暂无相关历史错误'
}

### 🚨 风险等级

**${knowledgeResult.riskLevel.toUpperCase()}**

${knowledgeResult.riskLevel === 'high'
  ? '⚠️ 此变更涉及高风险领域，建议详细设计和充分测试'
  : knowledgeResult.riskLevel === 'medium'
  ? '⚡ 此变更有一定风险，建议参考历史经验'
  : '✅ 此变更风险较低'
}

### 🛡️ 预防措施

${knowledgeResult.preventionMeasures.length > 0
  ? knowledgeResult.preventionMeasures.map((m, i) => `${i + 1}. ${m}`).join('\n')
  : '✅ 暂无特殊预防措施'
}

### 💡 推荐做法

${knowledgeResult.recommendations.length > 0
  ? knowledgeResult.recommendations.map((r, i) => `${i + 1}. ${r}`).join('\n')
  : '参考全局 design.md 和 CLAUDE.md'
}

### 📋 合规性检查

${complianceResult.issues.length === 0
  ? '✅ 通过合规性预检查'
  : `
⚠️ 发现以下问题:
${complianceResult.issues.map((issue, i) => `${i + 1}. ${issue}`).join('\n')}

建议:
${complianceResult.suggestions.map((s, i) => `${i + 1}. ${s}`).join('\n')}
`
}

---

**下一步**: 进入 Phase 1 (需求澄清)，结合以上知识编写 proposal.md
`;

  return context;
}
```

## 📊 完整执行流程

```typescript
async function phase0KnowledgeCheck(userRequest: string): Promise<Phase0Result> {
  console.log('🔍 Phase 0: 知识预查开始...\n');

  // Step 1: 检查全局约束
  console.log('Step 1: 检查全局约束...');
  const constraintCheck = await checkGlobalConstraints();

  if (!constraintCheck.exists) {
    console.error(constraintCheck.recommendation);
    return {
      success: false,
      reason: 'missing_global_constraints',
      recommendation: '请先运行 project-initializer 初始化项目'
    };
  }
  console.log('✅ 全局约束文件完整\n');

  // Step 2: 读取全局约束
  console.log('Step 2: 读取全局约束...');
  const requirements = fs.readFileSync('.agent/requirements.md', 'utf-8');
  const design = fs.readFileSync('.agent/design.md', 'utf-8');
  const claudeMd = fs.readFileSync('.agent/CLAUDE.md', 'utf-8');
  const constraints = fs.readFileSync('.agent/constraints.md', 'utf-8');
  console.log('✅ 全局约束已加载\n');

  // Step 3: 知识库查询
  console.log('Step 3: 查询知识库...');
  const knowledgeResult = await queryKnowledgeBase({
    query: userRequest,
    categories: ['patterns', 'errors', 'learnings']
  });
  console.log(`✅ 找到 ${knowledgeResult.relatedPatterns.length} 个相关模式`);
  console.log(`⚠️ 识别 ${knowledgeResult.relatedErrors.length} 个历史错误`);
  console.log(`🚨 风险等级: ${knowledgeResult.riskLevel}\n`);

  // Step 4: 合规性检查
  console.log('Step 4: 合规性预检查...');
  const complianceResult = await checkCompliance(userRequest, requirements);

  if (complianceResult.issues.length > 0) {
    console.warn(`⚠️ 发现 ${complianceResult.issues.length} 个合规性问题`);
    complianceResult.issues.forEach(issue => console.warn(`  - ${issue}`));
  } else {
    console.log('✅ 通过合规性检查\n');
  }

  // Step 5: 生成知识上下文
  console.log('Step 5: 生成知识上下文...');
  const knowledgeContext = generateKnowledgeContext(knowledgeResult, complianceResult);

  // 保存到临时文件，供 Phase 1 使用
  const changeId = generateChangeId(userRequest);
  const contextPath = `.agent/changes/active/${changeId}/phase0-context.md`;
  fs.mkdirSync(path.dirname(contextPath), { recursive: true });
  fs.writeFileSync(contextPath, knowledgeContext);
  console.log(`✅ 知识上下文已保存: ${contextPath}\n`);

  // Step 6: 决策
  const shouldProceed = complianceResult.issues.length === 0 ||
                        complianceResult.issues.every(i => !i.includes('严重'));

  if (!shouldProceed) {
    return {
      success: false,
      reason: 'compliance_failed',
      knowledgeContext,
      issues: complianceResult.issues,
      suggestions: complianceResult.suggestions
    };
  }

  return {
    success: true,
    knowledgeContext,
    riskLevel: knowledgeResult.riskLevel,
    preventionMeasures: knowledgeResult.preventionMeasures,
    nextPhase: 'phase-1-clarification'
  };
}
```

## 🎯 使用示例

### 示例 1: 成功通过 Phase 0

```bash
用户输入: "实现用户登录功能，支持 JWT 认证"

Phase 0 执行:
✅ 全局约束文件完整
✅ 全局约束已加载
✅ 找到 2 个相关模式 (PATTERN-001: Repository Pattern, PATTERN-002: Service Layer)
⚠️ 识别 1 个历史错误 (ERROR-001: 未处理 Promise rejection)
🚨 风险等级: medium
✅ 通过合规性检查
✅ 知识上下文已保存

→ 进入 Phase 1 (需求澄清)
```

### 示例 2: 合规性问题

```bash
用户输入: "用 MongoDB 实现数据存储"

Phase 0 执行:
✅ 全局约束文件完整
✅ 全局约束已加载
✅ 找到 1 个相关模式 (PATTERN-001: Repository Pattern)
⚠️ 识别 0 个历史错误
🚨 风险等级: low
⚠️ 发现 1 个合规性问题:
  - 使用了约束外的技术: MongoDB

建议:
  - 项目约束要求使用 PostgreSQL + Drizzle ORM
  - 如需使用 MongoDB，请先更新 requirements.md 并获得批准

→ 阻塞，需用户确认是否继续或修改需求
```

### 示例 3: 缺少全局约束

```bash
用户输入: "实现评论功能"

Phase 0 执行:
⚠️ 全局约束文件缺失！

缺少文件:
  - requirements.md
  - design.md
  - CLAUDE.md
  - constraints.md

建议操作:
1. 运行 project-initializer 初始化项目
2. 或手动创建缺失的全局约束文件

→ 阻塞，必须先初始化项目
```

## 📝 Phase 0 输出格式

生成的 `phase0-context.md` 会被附加到后续的 `proposal.md` 中：

```markdown
# Change Proposal: 001-user-auth

## 📚 知识预查 (Phase 0)

**查询时间**: 2025-01-02T10:30:00Z

### 🎯 相关成功模式
- **PATTERN-001**: Repository Pattern
  - 适用场景: 需要抽象数据访问逻辑时
  - 收益: 易测试, 易切换数据源, 业务逻辑解耦

### ⚠️ 历史错误（需避免）
- **ERROR-001**: 未处理的 Promise rejection (严重程度: high)
  - 根因: 异步函数缺少 try-catch
  - 发生次数: 0

### 🚨 风险等级
**MEDIUM**

### 🛡️ 预防措施
1. 所有 async 函数必须用 try-catch 包装
2. 使用 Repository Pattern

### 💡 推荐做法
1. 考虑使用 PATTERN-001 (Repository Pattern)
2. 参考 PATTERN-002 (Service Layer Pattern)

### 📋 合规性检查
✅ 通过合规性预检查

---

## What: 功能描述
[Phase 1 填写]

## Why: 用户价值
[Phase 1 填写]

## Success Criteria
[Phase 1 填写]
```

## 🔧 集成到 ai-dev

在 `ai-dev/SKILL.md` 中添加 Phase 0 触发：

```typescript
async function orchestrate(userRequest: string) {
  // Phase 0: Knowledge Check (自动执行)
  const phase0Result = await phase0KnowledgeCheck(userRequest);

  if (!phase0Result.success) {
    if (phase0Result.reason === 'missing_global_constraints') {
      return {
        message: '⚠️ 项目缺少全局约束，请先运行 project-initializer',
        action: 'block'
      };
    }

    if (phase0Result.reason === 'compliance_failed') {
      // 询问用户是否继续
      const userChoice = await askUserQuestion({
        question: '发现合规性问题，是否继续？',
        options: [
          { label: '修改需求', value: 'refine' },
          { label: '继续（我知道风险）', value: 'proceed' },
          { label: '取消', value: 'cancel' }
        ]
      });

      if (userChoice !== 'proceed') {
        return { action: 'cancel' };
      }
    }
  }

  // Phase 1: Requirement Clarification
  // (使用 phase0Result.knowledgeContext)
  ...
}
```

## ✅ 成功标准

Phase 0 执行成功当：
1. ✅ 全局约束文件完整
2. ✅ 知识库查询完成
3. ✅ 生成知识上下文
4. ✅ 合规性检查通过（或用户确认继续）
5. ✅ phase0-context.md 已保存

失败时会阻塞流程，要求用户先修复问题或确认风险。

---

**核心价值**: Phase 0 确保每个变更都有历史知识支持，避免重复错误，保持项目一致性。
