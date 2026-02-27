/**
 * Team Collaboration Templates
 *
 * 提供四种预定义的团队场景模板，用于 Agent Teams 协作开发。
 *
 * @module team-collaboration/templates
 * @version 1.0.0
 */

// ============================================================================
// Types
// ============================================================================

export interface Teammate {
  /** 角色标识符 */
  role: string
  /** Agent 类型 (subagent_type) */
  type: string
  /** 角色描述 */
  description: string
  /** 负责的文件范围 */
  fileScope?: string[]
  /** 关注焦点 */
  focus?: string
  /** 依赖的角色 */
  blockedBy?: string[]
  /** 预估任务数量 */
  estimatedTasks: number
}

export interface WorkflowPhase {
  /** 阶段名称 */
  name: string
  /** 参与的队友 */
  teammates: string[]
  /** 是否并行执行 */
  parallel: boolean
  /** 依赖的阶段 */
  blockedBy?: string[]
}

export interface TeamTemplate {
  /** 模板名称 */
  name: string
  /** 模板描述 */
  description: string
  /** 触发词 */
  trigger: string[]
  /** 队友配置 */
  teammates: Teammate[]
  /** 工作流配置 */
  workflow: {
    type: string
    phases: WorkflowPhase[]
  }
  /** 通信配置 */
  communication?: {
    syncPoints?: string[]
    broadcastOn?: string[]
    conflictResolution?: string
    reportFormat?: string
    hypothesisSharing?: boolean
    debateProtocol?: string
  }
}

// ============================================================================
// Templates
// ============================================================================

/**
 * 功能开发团队模板
 *
 * 前后端分离并行开发，适用于实现新功能。
 *
 * 触发词: "功能", "开发", "实现", "feature", "develop"
 *
 * @example
 * // 使用示例
 * /ai:team 实现用户认证功能，包括登录、注册、密码重置
 */
export const FEATURE_DEVELOPMENT: TeamTemplate = {
  name: "功能开发团队",
  description: "前后端分离并行开发",
  trigger: ["功能", "开发", "实现", "feature", "develop", "新增", "添加"],

  teammates: [
    {
      role: "frontend-dev",
      type: "ai-dev:frontend-developer",
      description: "前端开发",
      fileScope: ["src/components/**", "src/pages/**", "src/styles/**"],
      estimatedTasks: 3
    },
    {
      role: "backend-dev",
      type: "ai-dev:api-helper",
      description: "后端开发",
      fileScope: ["src/api/**", "src/routes/**", "src/db/**"],
      estimatedTasks: 3
    },
    {
      role: "test-engineer",
      type: "ai-dev:test-automator",
      description: "测试自动化",
      fileScope: ["tests/**", "__tests__/**"],
      blockedBy: ["frontend-dev", "backend-dev"],
      estimatedTasks: 2
    }
  ],

  workflow: {
    type: "parallel-then-merge",
    phases: [
      {
        name: "开发",
        teammates: ["frontend-dev", "backend-dev"],
        parallel: true
      },
      {
        name: "测试",
        teammates: ["test-engineer"],
        parallel: false,
        blockedBy: ["开发"]
      }
    ]
  },

  communication: {
    syncPoints: ["API 契约确认", "数据结构确认", "集成测试准备"],
    broadcastOn: ["API 变更", "数据结构变更", "环境变更"]
  }
}

/**
 * 代码审查团队模板
 *
 * 多角度并行审查，适用于代码质量检查。
 *
 * 触发词: "审查", "review", "检查代码", "代码质量"
 *
 * @example
 * // 使用示例
 * /ai:team review 检查 src/auth 目录下的所有代码
 */
export const CODE_REVIEW: TeamTemplate = {
  name: "代码审查团队",
  description: "多角度并行审查",
  trigger: ["审查", "review", "检查代码", "代码质量", "review code", "代码检查"],

  teammates: [
    {
      role: "security-reviewer",
      type: "ai-dev:code-reviewer",
      description: "安全审查",
      focus: "安全漏洞、XSS、SQL注入、权限问题",
      estimatedTasks: 2
    },
    {
      role: "performance-reviewer",
      type: "ai-dev:code-reviewer",
      description: "性能审查",
      focus: "性能瓶颈、内存泄漏、算法复杂度",
      estimatedTasks: 2
    },
    {
      role: "quality-reviewer",
      type: "ai-dev:quality-guardian",
      description: "质量审查",
      focus: "代码风格、可维护性、测试覆盖",
      estimatedTasks: 2
    }
  ],

  workflow: {
    type: "parallel-independent",
    phases: [
      {
        name: "审查",
        teammates: ["security-reviewer", "performance-reviewer", "quality-reviewer"],
        parallel: true
      }
    ]
  },

  communication: {
    conflictResolution: "team-lead-decides",
    reportFormat: "consolidated"
  }
}

/**
 * 问题调查团队模板
 *
 * 竞争假设并行调查，适用于问题排查和调试。
 *
 * 触发词: "调查", "debug", "问题", "investigate", "排查"
 *
 * @example
 * // 使用示例
 * /ai:team debug 调查登录失败的问题
 */
export const INVESTIGATION: TeamTemplate = {
  name: "问题调查团队",
  description: "竞争假设并行调查",
  trigger: ["调查", "debug", "问题", "investigate", "排查", "故障", "错误"],

  teammates: [
    {
      role: "log-analyst",
      type: "ai-dev:debugger",
      description: "日志分析",
      focus: "错误日志、堆栈跟踪、异常模式",
      estimatedTasks: 2
    },
    {
      role: "code-tracer",
      type: "ai-dev:error-detective",
      description: "代码追踪",
      focus: "代码路径、数据流、状态变化",
      estimatedTasks: 2
    },
    {
      role: "hypothesis-tester",
      type: "ai-dev:debugger",
      description: "假设验证",
      focus: "复现问题、验证修复",
      blockedBy: ["log-analyst", "code-tracer"],
      estimatedTasks: 2
    }
  ],

  workflow: {
    type: "competitive-hypothesis",
    phases: [
      {
        name: "调查",
        teammates: ["log-analyst", "code-tracer"],
        parallel: true
      },
      {
        name: "验证",
        teammates: ["hypothesis-tester"],
        parallel: false,
        blockedBy: ["调查"]
      }
    ]
  },

  communication: {
    hypothesisSharing: true,
    debateProtocol: "structured-argument"
  }
}

/**
 * 架构设计团队模板
 *
 * 多视角架构评审，适用于系统设计。
 *
 * 触发词: "架构", "设计", "architecture", "design"
 *
 * @example
 * // 使用示例
 * /ai:team 设计电商系统的架构，包括订单、支付、库存模块
 */
export const ARCHITECTURE: TeamTemplate = {
  name: "架构设计团队",
  description: "多视角架构评审",
  trigger: ["架构", "设计", "architecture", "design", "系统设计", "技术方案"],

  teammates: [
    {
      role: "backend-architect",
      type: "ai-dev:backend-architect",
      description: "后端架构",
      focus: "服务设计、数据模型、API设计",
      estimatedTasks: 3
    },
    {
      role: "frontend-architect",
      type: "ai-dev:frontend-developer",
      description: "前端架构",
      focus: "组件设计、状态管理、路由",
      estimatedTasks: 2
    },
    {
      role: "security-architect",
      type: "ai-dev:code-reviewer",
      description: "安全架构",
      focus: "认证授权、数据保护、安全边界",
      blockedBy: ["backend-architect", "frontend-architect"],
      estimatedTasks: 2
    }
  ],

  workflow: {
    type: "collaborative-design",
    phases: [
      {
        name: "设计",
        teammates: ["backend-architect", "frontend-architect"],
        parallel: true
      },
      {
        name: "评审",
        teammates: ["security-architect"],
        parallel: false,
        blockedBy: ["设计"]
      }
    ]
  }
}

// ============================================================================
// Template Registry
// ============================================================================

/**
 * 所有团队模板的注册表
 */
export const TEAM_TEMPLATES: Record<string, TeamTemplate> = {
  FEATURE_DEVELOPMENT,
  CODE_REVIEW,
  INVESTIGATION,
  ARCHITECTURE
}

// ============================================================================
// Helper Functions
// ============================================================================

/**
 * 从用户请求中选择最匹配的团队模板
 *
 * @param request - 用户请求字符串
 * @returns 匹配的团队模板，如果没有匹配则返回默认模板
 */
export function selectTeamTemplate(request: string): TeamTemplate {
  const keywords = extractKeywords(request)

  // 计算每个模板的匹配分数
  const scores = Object.entries(TEAM_TEMPLATES).map(([key, template]) => ({
    key,
    template,
    score: calculateMatchScore(keywords, template.trigger)
  }))

  // 选择最高分的模板
  const best = scores.sort((a, b) => b.score - a.score)[0]

  if (best.score > 0.5) {
    return best.template
  }

  // 默认使用功能开发团队
  return FEATURE_DEVELOPMENT
}

/**
 * 从请求中提取关键词
 */
function extractKeywords(request: string): string[] {
  // 简单的关键词提取：按空格分词，过滤停用词
  const stopWords = new Set(["的", "和", "与", "或", "以及", "一个", "这个", "那个", "是", "在", "有", "我", "你", "他", "a", "an", "the", "is", "are", "was", "were"])

  return request
    .toLowerCase()
    .split(/[\s,，。！？、；：""''（）【】\[\]]+/)
    .filter(word => word.length > 1 && !stopWords.has(word))
}

/**
 * 计算关键词与触发词的匹配分数
 */
function calculateMatchScore(keywords: string[], triggers: string[]): number {
  if (keywords.length === 0 || triggers.length === 0) {
    return 0
  }

  const matches = keywords.filter(k =>
    triggers.some(t => k.includes(t.toLowerCase()) || t.toLowerCase().includes(k))
  )

  return matches.length / Math.max(keywords.length, triggers.length)
}

/**
 * 生成团队名称
 *
 * @param description - 任务描述
 * @returns 团队名称
 */
export function generateTeamName(description: string): string {
  // 从描述中提取关键信息作为团队名称
  const keywords = extractKeywords(description)
  const prefix = keywords.slice(0, 3).join("-")
  const timestamp = Date.now().toString(36)

  return `${prefix}-${timestamp}`
}

/**
 * 评估任务复杂度
 *
 * @param request - 用户请求
 * @returns 复杂度级别
 */
export function assessComplexity(request: string): "simple" | "medium" | "complex" {
  const keywords = extractKeywords(request)

  // 基于关键词数量和特定词汇判断复杂度
  const complexIndicators = ["系统", "架构", "集成", "多", "完整", "复杂", "system", "architecture", "integration"]
  const simpleIndicators = ["修复", "添加", "修改", "简单", "fix", "add", "update", "simple"]

  const hasComplex = keywords.some(k => complexIndicators.some(i => k.includes(i)))
  const hasSimple = keywords.some(k => simpleIndicators.some(i => k.includes(i)))

  if (hasComplex || keywords.length > 10) {
    return "complex"
  }

  if (hasSimple || keywords.length < 5) {
    return "simple"
  }

  return "medium"
}

/**
 * 根据复杂度推荐团队规模
 *
 * @param complexity - 复杂度级别
 * @returns 推荐的队友数量
 */
export function recommendTeamSize(complexity: "simple" | "medium" | "complex"): number {
  switch (complexity) {
    case "simple":
      return 2
    case "medium":
      return 3
    case "complex":
      return 4
  }
}

// ============================================================================
// Exports
// ============================================================================

export default {
  TEAM_TEMPLATES,
  FEATURE_DEVELOPMENT,
  CODE_REVIEW,
  INVESTIGATION,
  ARCHITECTURE,
  selectTeamTemplate,
  generateTeamName,
  assessComplexity,
  recommendTeamSize
}