# Refactoring Patterns Reference

> Detailed patterns for code-simplifier skill

## Extract Method
- **When**: Function too long, code block with comment
- **How**: Extract into focused functions with descriptive names

## Replace Conditional with Polymorphism
- **When**: Switch on type, repeated type checks
- **How**: Use interface/abstract class with type.execute()

## Introduce Parameter Object
- **When**: Function has > 3 related parameters
- **How**: Group into typed object

## Decompose Conditional
- **When**: Complex boolean condition
- **How**: Extract into named predicate function

See main SKILL.md for complete pattern catalog.
