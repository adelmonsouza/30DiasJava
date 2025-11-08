# 🚀 Pre-GoLive Script - User Guide

## Purpose

The `pre-golive.sh` script validates all projects in the #30DiasJava monorepo before going live. It performs critical security, documentation, build, and test checks.

## Usage

### Validate All Projects

```bash
./pre-golive.sh
```

This will:
1. Find all projects with `pom.xml`
2. Validate each project
3. Show summary report

### Validate Specific Project

```bash
./pre-golive.sh user-profile-service
./pre-golive.sh content-catalog-api
./pre-golive.sh recommendation-engine
```

## What It Checks

### ✅ Critical Checks (Must Pass)

1. **Security Checks**
   - No secrets/tokens in code
   - No hardcoded passwords
   - Environment variables properly used

2. **Documentation**
   - README.md exists
   - Required sections present

3. **Build**
   - Project compiles successfully
   - No compilation errors

4. **Tests**
   - All tests pass
   - Test execution successful

### ⚠️ Recommended Checks (Warnings Only)

1. **Test Coverage**
   - Coverage report generated
   - Target: ≥80% coverage

2. **Docker Configuration**
   - Dockerfile exists
   - Docker Compose file valid

3. **CI/CD**
   - GitHub Actions workflows configured

## Integration with Git Hooks

### Pre-Commit Hook (Optional)

Add to `.git/hooks/pre-commit`:

```bash
#!/bin/bash
# Run pre-golive for staged projects
git diff --cached --name-only | grep -E "pom.xml|src/" | while read file; do
    project_dir=$(dirname "$file" | cut -d'/' -f1-2)
    if [ -f "$project_dir/pom.xml" ]; then
        echo "Running pre-golive for $project_dir..."
        ./pre-golive.sh "$project_dir" || exit 1
    fi
done
```

Make it executable:
```bash
chmod +x .git/hooks/pre-commit
```

### Pre-Push Hook (Recommended)

Add to `.git/hooks/pre-push`:

```bash
#!/bin/bash
# Run pre-golive before pushing
echo "Running pre-golive checks..."
./pre-golive.sh || {
    echo "❌ Pre-golive checks failed. Fix issues before pushing."
    exit 1
}
```

Make it executable:
```bash
chmod +x .git/hooks/pre-push
```

## CI/CD Integration

The script is integrated with GitHub Actions. See `.github/workflows/pre-golive.yml`.

It runs automatically on:
- Push to `main` or `develop`
- Pull requests to `main`
- Manual trigger via `workflow_dispatch`

## Exit Codes

- `0` - All critical checks passed
- `1` - One or more critical checks failed

## Output Files

Temporary files created during execution (automatically cleaned up):
- `/tmp/mvn_build.log` - Maven build output
- `/tmp/mvn_test.log` - Test execution output
- `/tmp/mvn_coverage.log` - Coverage report generation
- `/tmp/secrets_check.tmp` - Secret detection results

## Best Practices

1. **Run Before Every Push**
   ```bash
   ./pre-golive.sh
   ```

2. **Fix Issues Immediately**
   - Don't push if critical checks fail
   - Address warnings before production

3. **Keep Script Updated**
   - Add new checks as needed
   - Update patterns for secret detection

4. **Document Project-Specific Rules**
   - If a project needs exceptions, document them
   - Update script to handle exceptions

## Troubleshooting

### "No projects found"
- Ensure `pom.xml` exists in project directories
- Check script execution directory

### "Build failed"
- Check Maven configuration
- Ensure Java 21 is installed
- Review `/tmp/mvn_build.log`

### "Tests failed"
- Run tests manually: `mvn test`
- Review `/tmp/mvn_test.log`
- Fix failing tests

### "Secrets detected" (False Positive)
- Update regex patterns in `check_secrets()`
- Add exceptions for known safe patterns

## Adding New Checks

To add a new validation check:

1. Create a new function:
```bash
check_new_feature() {
    local project_dir=$1
    print_info "Checking new feature..."
    # Your validation logic
    if [ condition ]; then
        print_success "Check passed"
        return 0
    else
        print_error "Check failed"
        return 1
    fi
}
```

2. Call it in `validate_project()`:
```bash
if check_new_feature "$project_dir"; then
    ((checks_passed++))
else
    ((checks_failed++))
fi
```

---

**Last Updated:** November 2, 2025


