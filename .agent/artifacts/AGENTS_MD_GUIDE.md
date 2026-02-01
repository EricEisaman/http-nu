# AGENTS.md Implementation Guide

## Overview

This project uses **AGENTS.md** to provide AI coding agents with project-specific context and guidance. This approach follows industry best practices from Vercel, Tessl, and the broader AI coding community.

## Why AGENTS.md?

Based on [Vercel's research](https://vercel.com/blog/agents-md-outperforms-skills-in-our-agent-evals), a well-crafted AGENTS.md file achieves **100% pass rate** on framework-specific tasks, outperforming skill-based approaches (79% max) and baseline (53%).

### Key Benefits

1. **No Decision Point**: Information is always available; agents don't need to decide "should I look this up?"
2. **Consistent Availability**: Context is present on every turn, not loaded asynchronously
3. **No Ordering Issues**: Avoids sequencing problems (explore first vs. read docs first)
4. **Persistent Memory**: Stores learnings across sessions about what to do and avoid

## Design Principles

Our AGENTS.md follows these principles from [AI Hero's guide](https://www.aihero.dev/a-complete-guide-to-agents-md):

### 1. Keep It Small (Instruction Budget)

- **Frontier models** can follow ~150-200 instructions consistently
- Every token loads on every request, regardless of relevance
- **Our approach**: ~50 lines, focused on essentials

### 2. Progressive Disclosure

Instead of cramming everything into AGENTS.md, we point to other resources:
- Examples for Nushell patterns
- Artifact files for deployment details
- Source code for implementation specifics

**Why**: Agents are fast at navigating documentation hierarchies. They understand context well enough to find what they need.

### 3. Avoid Stale Documentation

We **don't** document:
- File system structure (paths change constantly)
- Specific function locations (files get renamed/moved)
- Implementation details (code evolves)

We **do** document:
- Domain concepts (stable over time)
- Package manager choice (rarely changes)
- Architecture patterns (foundational)
- Where to find more information (progressive disclosure)

### 4. One-Liner Project Description

```
A Rust-based HTTP server that uses Nushell for scriptable request handling.
```

This single sentence anchors every decision the agent makes.

## File Structure

```
http-nu/
├── AGENTS.md           # Project-level guidance (architecture, patterns)
├── CLAUDE.md           # Personal preferences (commit style, tone)
└── .agent/
    └── artifacts/      # Detailed documentation (progressive disclosure)
```

### AGENTS.md vs CLAUDE.md

- **AGENTS.md**: Project scope - what the project does, architecture, patterns
- **CLAUDE.md**: Personal scope - your commit style, coding preferences, tone

CLAUDE.md references AGENTS.md for project-level guidance, following the progressive disclosure pattern.

## Content Strategy

### What Goes in AGENTS.md

✅ **Include**:
- One-liner project description
- Package manager specification
- Key domain concepts
- Architecture hints (not detailed structure)
- Development patterns (high-level)
- Progressive disclosure pointers
- Testing commands

❌ **Exclude**:
- Detailed file paths
- Specific function locations
- Implementation details
- Language-specific rules (point to separate files)
- Auto-generated content
- Marketing language

### Progressive Disclosure Examples

Instead of:
```markdown
## TypeScript Rules
Always use const instead of let. Never use var.
Use interface instead of type when possible.
Use strict null checks.
[... 50 more lines ...]
```

We do:
```markdown
For Nushell handler patterns, see examples/basic.nu
For Docker deployment, see .agent/artifacts/docker-render-technical-reference.md
```

## The "Prefer Retrieval" Pattern

From Vercel's research, this instruction is critical:

```markdown
**Prefer retrieval-led reasoning over pre-training-led reasoning** when working with:
- Nushell syntax and commands (consult examples)
- http-nu specific APIs and modules (check source files)
- Deployment configurations (reference artifact files)
```

This tells the agent to consult actual documentation rather than rely on potentially outdated training data.

## Meta-Prompting for Evolution

From [Tessl's research](https://tessl.io/blog/from-prompts-to-agents-md-what-survives-across-thousands-of-runs), AGENTS.md should evolve:

### After Encountering Problems
```
"Don't do this again, and adjust your rules to avoid this in the future."
```

### After Successful Sessions
```
"Reflect on this session and propose five improvements to the rules. Wait for approval."
```

This creates a feedback loop where the agent learns and improves the rules over time.

## Compression Techniques

Our AGENTS.md uses compression to stay within the instruction budget:

1. **Concise descriptions**: One-liners instead of paragraphs
2. **Bullet points**: Quick scanning
3. **Progressive disclosure**: Point to detailed docs instead of including them
4. **Domain concepts only**: Avoid implementation details

**Result**: ~50 lines covering all essential guidance, with pointers to detailed documentation.

## Hierarchical AGENTS.md (Future)

For larger projects, you can use hierarchical AGENTS.md files:

```
project/
├── AGENTS.md              # Root-level rules
├── component-a/
│   └── AGENTS.md          # Component-specific rules
└── component-b/
    └── AGENTS.md          # Component-specific rules
```

Agents gather rules from parent directories as they traverse the structure. General rules flow down, component-specific patterns stay local.

## Measuring Success

### Metrics to Track

1. **Agent Performance**: Does the agent make correct decisions?
2. **File Size**: Is AGENTS.md under 100 lines?
3. **Staleness**: Are documented concepts still accurate?
4. **Coverage**: Are key patterns documented?

### Red Flags

- 🚩 AGENTS.md over 200 lines
- 🚩 Documenting specific file paths
- 🚩 Conflicting rules from different developers
- 🚩 Auto-generated content
- 🚩 No progressive disclosure pointers

## Community Patterns

Based on analysis of 40,000+ GitHub repositories:

1. **CLAUDE.md spiked first** (Claude Code specific)
2. **AGENTS.md followed** (open standard)
3. **Skills.md exploding now** (skill-based approaches)

Our approach: Use AGENTS.md as the standard, with CLAUDE.md referencing it for Claude Code compatibility.

## Maintenance

### Regular Reviews

- **Monthly**: Check for stale concepts
- **After major changes**: Update architecture hints
- **When patterns emerge**: Add to development patterns section

### Cleanup Prompts

Use this prompt to clean up an overgrown AGENTS.md:

```
Review this AGENTS.md file. Remove:
1. Stale documentation
2. Specific file paths
3. Implementation details
4. Conflicting rules
5. Auto-generated content

Keep:
1. One-liner project description
2. Package manager spec
3. Domain concepts
4. Progressive disclosure pointers
5. High-level patterns

Aim for under 100 lines.
```

## Resources

- [AI Hero's Complete Guide to AGENTS.md](https://www.aihero.dev/a-complete-guide-to-agents-md)
- [Vercel: AGENTS.md Outperforms Skills](https://vercel.com/blog/agents-md-outperforms-skills-in-our-agent-evals)
- [Tessl: From Prompts to AGENTS.md](https://tessl.io/blog/from-prompts-to-agents-md-what-survives-across-thousands-of-runs)
- [AGENTS.md Standard](https://agents.md/)
- [Agent Skills Standard](https://agentskills.io/)

## Example: Our AGENTS.md

See [AGENTS.md](../AGENTS.md) for our implementation following these principles.

**Key features**:
- ✅ 50 lines total
- ✅ One-liner project description
- ✅ Package manager specified
- ✅ Progressive disclosure to detailed docs
- ✅ No file paths or implementation details
- ✅ "Prefer retrieval" instruction
- ✅ Testing commands included

## Conclusion

AGENTS.md is **persistent memory** for AI coding agents. Keep it:
- **Small** (instruction budget)
- **Current** (avoid staleness)
- **Conceptual** (not implementation details)
- **Progressive** (point to detailed docs)

This approach has been proven to achieve 100% pass rates on framework-specific tasks, significantly outperforming other methods.
