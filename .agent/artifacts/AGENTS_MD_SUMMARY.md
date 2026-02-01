# AGENTS.md Implementation Summary

## What Was Created

### 1. AGENTS.md (Root Level)
**Location**: `/AGENTS.md`

A concise, 50-line project guidance file following industry best practices:
- ✅ One-liner project description
- ✅ Package manager specification (Cargo)
- ✅ Key domain concepts
- ✅ Architecture hints (not detailed paths)
- ✅ Development patterns
- ✅ Progressive disclosure pointers
- ✅ "Prefer retrieval" instruction
- ✅ Testing commands

**Design Principles**:
- Small instruction budget (~50 lines)
- No file paths or implementation details
- Progressive disclosure to detailed docs
- Domain concepts only (stable over time)

### 2. CLAUDE.md Update
**Location**: `/CLAUDE.md`

Updated to reference AGENTS.md for project-level guidance:
- Added header explaining separation of concerns
- Links to AGENTS.md for architecture/patterns
- Keeps personal preferences (commit style, tone)

**Separation**:
- **AGENTS.md**: Project scope (what the project does, architecture)
- **CLAUDE.md**: Personal scope (your preferences, style)

### 3. AGENTS.md Implementation Guide
**Location**: `.agent/artifacts/AGENTS_MD_GUIDE.md`

Comprehensive documentation explaining:
- Why AGENTS.md (100% vs 79% vs 53% pass rates)
- Design principles from industry research
- Content strategy (what to include/exclude)
- Progressive disclosure pattern
- Meta-prompting for evolution
- Compression techniques
- Maintenance guidelines

## Research-Backed Approach

Based on three authoritative sources:

### 1. Vercel Research
**Finding**: AGENTS.md achieved **100% pass rate** on Next.js 16 API evals
- Skills (default): 53% (same as baseline)
- Skills (explicit): 79%
- **AGENTS.md**: 100% ✅

**Why it works**:
- No decision point (info always available)
- Consistent availability (every turn)
- No ordering issues (no sequencing decisions)

### 2. AI Hero Guide
**Key Principles**:
- Instruction budget: ~150-200 instructions max
- Progressive disclosure over comprehensiveness
- Avoid stale documentation (especially file paths)
- One-liner project description anchors decisions

### 3. Tessl Research
**Insights**:
- AGENTS.md as persistent memory across sessions
- Meta-prompting for rule evolution
- Hierarchical structure for monorepos
- Community pattern mining (40,000+ repos analyzed)

## File Structure

```
http-nu/
├── AGENTS.md                           # ✅ NEW: Project guidance
├── CLAUDE.md                           # ✅ UPDATED: References AGENTS.md
└── .agent/
    └── artifacts/
        └── AGENTS_MD_GUIDE.md          # ✅ NEW: Implementation guide
```

## Key Features

### Progressive Disclosure Pattern

Instead of cramming everything into AGENTS.md:

```markdown
For Nushell handler patterns: See examples/basic.nu
For Docker deployment: See .agent/artifacts/docker-render-technical-reference.md
For multi-example architecture: See .agent/artifacts/MULTI_EXAMPLE_ARCHITECTURE.md
```

Agents navigate these hierarchies efficiently.

### "Prefer Retrieval" Instruction

Critical instruction from Vercel research:

```markdown
**Prefer retrieval-led reasoning over pre-training-led reasoning** when working with:
- Nushell syntax and commands (consult examples)
- http-nu specific APIs and modules (check source files)
- Deployment configurations (reference artifact files)
```

This tells agents to consult actual docs rather than rely on potentially outdated training data.

### Compression Techniques

Our AGENTS.md stays under 100 lines by:
1. One-liner descriptions
2. Bullet points for scanning
3. Progressive disclosure pointers
4. Domain concepts only (no implementation)

## What We Avoided

❌ **Don't Include**:
- Detailed file paths (they change)
- Specific function locations (files move)
- Implementation details (code evolves)
- Language-specific rules (use progressive disclosure)
- Auto-generated content (bloat)
- Marketing language (noise)

✅ **Do Include**:
- Domain concepts (stable)
- Package manager (rarely changes)
- Architecture patterns (foundational)
- Progressive disclosure pointers
- Testing commands

## Maintenance

### Regular Reviews
- **Monthly**: Check for stale concepts
- **After major changes**: Update architecture hints
- **When patterns emerge**: Add to development patterns

### Evolution Pattern

From Tessl research:

**After problems**:
```
"Don't do this again, and adjust your rules to avoid this in the future."
```

**After success**:
```
"Reflect on this session and propose five improvements to the rules. Wait for approval."
```

This creates a feedback loop where agents learn and improve rules over time.

## Compatibility

### Claude Code
Uses CLAUDE.md, which now references AGENTS.md for project guidance.

### Other Tools
Most AI coding tools support AGENTS.md standard:
- Cursor
- GitHub Copilot
- Cody
- Continue
- And more

## Success Metrics

Based on Vercel's research:

| Approach | Pass Rate | vs Baseline |
|----------|-----------|-------------|
| Baseline (no docs) | 53% | — |
| Skills (default) | 53% | +0pp |
| Skills (explicit) | 79% | +26pp |
| **AGENTS.md** | **100%** | **+47pp** ✅ |

Our implementation follows the winning pattern.

## Resources

All research sources:
- [AI Hero: Complete Guide to AGENTS.md](https://www.aihero.dev/a-complete-guide-to-agents-md)
- [Vercel: AGENTS.md Outperforms Skills](https://vercel.com/blog/agents-md-outperforms-skills-in-our-agent-evals)
- [Tessl: From Prompts to AGENTS.md](https://tessl.io/blog/from-prompts-to-agents-md-what-survives-across-thousands-of-runs)

## Next Steps

1. ✅ **AGENTS.md created** and ready to use
2. ✅ **CLAUDE.md updated** to reference it
3. ✅ **Implementation guide** documented
4. 🔄 **Test with AI agents** to validate effectiveness
5. 🔄 **Iterate based on feedback** using meta-prompting
6. 🔄 **Monitor for staleness** and update as needed

## Conclusion

We've implemented AGENTS.md following industry best practices proven to achieve **100% pass rates** on framework-specific tasks. The approach is:

- **Concise**: ~50 lines, respecting instruction budget
- **Current**: Domain concepts, not implementation details
- **Progressive**: Points to detailed docs when needed
- **Proven**: Based on research from Vercel, AI Hero, and Tessl

The file will evolve over time through meta-prompting and feedback loops, continuously improving agent performance on this project.

---

**Created**: 2026-01-31  
**Based on**: Vercel, AI Hero, and Tessl research  
**Status**: ✅ Ready for use
