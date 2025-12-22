---
description: DEPRECATED - Use /reportToGitHub instead to create GitHub issues
---

## ⚠️ DEPRECATED - USE `/reportToGitHub` INSTEAD

**This prompt is deprecated.** Do not use it.

**Instead:** Use the `/reportToGitHub` workflow to create GitHub issues directly.

### Why?

- GitHub is the single source of truth for all template work
- Markdown task files create duplication and maintenance burden
- GitHub issues are easier to track, assign, and close
- GitHub provides better project board and milestone views

### Correct Workflow

1. Run `/healthCheck` → generates `.template/HEALTH_CHECK_REPORT.md`
2. Run `/reportToGitHub` → creates GitHub issues with proper labels
3. Work from GitHub issues
4. **Do NOT create** `.template/FIXES.md` or `.template/IMPROVEMENTS.md`

---

## Historical Context (For Reference)

The Quality Assurance Architect has completed a comprehensive health check and created `.template/HEALTH_CHECK_REPORT.md`. This prompt was previously used to transform those findings into markdown task files.

**This approach is no longer recommended.** Use GitHub issues instead.
