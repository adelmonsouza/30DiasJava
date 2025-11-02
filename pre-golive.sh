#!/bin/bash

################################################################################
# Pre-GoLive Script for #30DiasJava Monorepo
# 
# Purpose: Validate all projects before going live
# Usage: ./pre-golive.sh [project-name]
#   - If no project specified, runs checks for all projects
#   - If project specified, runs checks only for that project
################################################################################

set -e  # Exit on error
set -o pipefail  # Exit on pipe failure

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
TOTAL_PROJECTS=0
PASSED_PROJECTS=0
FAILED_PROJECTS=0
WARNINGS=0

################################################################################
# Functions
################################################################################

print_header() {
    echo ""
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    ((WARNINGS++))
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

################################################################################
# Security Checks
################################################################################

check_secrets() {
    local project_dir=$1
    print_info "Checking for secrets and sensitive data..."
    
    local secrets_found=0
    
    # Check for common secret patterns, but exclude:
    # - Environment variables (${VAR:default})
    # - Spring property placeholders
    # - Example/template values
    # - Method names containing password/secret
    if grep -r -E "(ghp_[a-zA-Z0-9]{36}|gho_[a-zA-Z0-9]{36}|github_pat_[a-zA-Z0-9_]{82}|AKIA[0-9A-Z]{16})" \
        --include="*.java" --include="*.properties" --include="*.yml" --include="*.yaml" \
        --exclude-dir=target --exclude-dir=.git --exclude-dir=node_modules "$project_dir" 2>/dev/null | \
        grep -v -E "(\$\{[^}]+\}|\${|CHANGE_ME|example|TODO|FIXME|passwordEncoder|passwordEncoder\(\)|YourSecretKey|placeholder)" > /tmp/secrets_check.tmp; then
        
        if [ -s /tmp/secrets_check.tmp ]; then
            print_error "Potential secrets found:"
            cat /tmp/secrets_check.tmp
            secrets_found=1
        fi
    fi
    
    # Check for hardcoded passwords (but exclude environment variables)
    if grep -r -iE "(password\s*=\s*['\"][^'\"]{8,}['\"]|secret\s*=\s*['\"][^'\"]{8,}['\"]|apikey\s*=\s*['\"][^'\"]{8,}['\"]|apikey\s*=\s*[^[:space:]]{8,})" \
        --include="*.java" --include="*.properties" --include="*.yml" --include="*.yaml" \
        --exclude-dir=target --exclude-dir=.git --exclude-dir=node_modules "$project_dir" 2>/dev/null | \
        grep -v -E "(\$\{[^}]+\}|\${|CHANGE_ME|example|TODO|FIXME|passwordEncoder|passwordEncoder\(\)|YourSecretKey|placeholder|default)" > /tmp/secrets_check2.tmp; then
        
        if [ -s /tmp/secrets_check2.tmp ]; then
            if [ $secrets_found -eq 0 ]; then
                print_error "Potential hardcoded credentials found:"
            fi
            cat /tmp/secrets_check2.tmp
            secrets_found=1
        fi
    fi
    
    rm -f /tmp/secrets_check.tmp /tmp/secrets_check2.tmp
    
    if [ $secrets_found -eq 0 ]; then
        print_success "No secrets detected"
        return 0
    else
        print_warning "Secrets check failed. Review false positives and ensure no real secrets are committed."
        return 1
    fi
}

################################################################################
# Documentation Checks
################################################################################

check_documentation() {
    local project_dir=$1
    local project_name=$(basename "$project_dir")
    print_info "Checking documentation..."
    
    local missing_docs=0
    
    # Check for required files
    if [ ! -f "$project_dir/README.md" ]; then
        print_error "Missing README.md"
        missing_docs=1
    fi
    
    if [ ! -f "$project_dir/Business_Plan.md" ]; then
        print_warning "Missing Business_Plan.md (recommended)"
    fi
    
    # Check if README has required sections (non-critical, just warnings)
    if [ -f "$project_dir/README.md" ]; then
        local has_tech_stack=$(grep -i "technology\|stack\|tech" "$project_dir/README.md" | wc -l)
        local has_how_to_run=$(grep -i "how to run\|getting started\|prerequisites\|running\|execute" "$project_dir/README.md" | wc -l)
        
        if [ $has_tech_stack -eq 0 ]; then
            print_warning "README.md should include Technology Stack section"
        fi
        
        if [ $has_how_to_run -eq 0 ]; then
            print_warning "README.md should include 'How to Run' section"
        fi
        
        # Check if README has links to blog and GitHub (Content Ecosystem)
        local has_content_ecosystem=$(grep -i "content ecosystem\|blog\|deep-dive" "$project_dir/README.md" | wc -l)
        if [ $has_content_ecosystem -eq 0 ]; then
            print_warning "README.md should include links to blog article (Content Ecosystem)"
        fi
    fi
    
    if [ $missing_docs -eq 0 ]; then
        print_success "Documentation check passed"
        return 0
    else
        return 1
    fi
}

################################################################################
# Maven Build Checks
################################################################################

check_build() {
    local project_dir=$1
    print_info "Checking Maven build..."
    
    cd "$project_dir"
    
    if [ ! -f "pom.xml" ]; then
        print_error "pom.xml not found"
        cd - > /dev/null
        return 1
    fi
    
    # Clean and compile (skip tests for faster validation)
    if mvn clean compile -DskipTests -q > /tmp/mvn_build.log 2>&1; then
        print_success "Build successful"
        cd - > /dev/null
        rm -f /tmp/mvn_build.log
        return 0
    else
        print_error "Build failed. Check /tmp/mvn_build.log"
        tail -20 /tmp/mvn_build.log
        cd - > /dev/null
        return 1
    fi
}

check_tests() {
    local project_dir=$1
    print_info "Running tests..."
    
    cd "$project_dir"
    
    if ! mvn test -q > /tmp/mvn_test.log 2>&1; then
        print_error "Tests failed"
        tail -30 /tmp/mvn_test.log | grep -A 10 -E "(ERROR|FAILURE|FAILED)" || tail -30 /tmp/mvn_test.log
        cd - > /dev/null
        return 1
    fi
    
    # Check test results
    local test_results=$(grep -E "Tests run:|BUILD" /tmp/mvn_test.log | tail -1)
    print_info "Test results: $test_results"
    
    cd - > /dev/null
    rm -f /tmp/mvn_test.log
    print_success "All tests passed"
    return 0
}

check_coverage() {
    local project_dir=$1
    print_info "Checking test coverage..."
    
    cd "$project_dir"
    
    # Run tests with coverage
    if mvn test jacoco:report -q > /tmp/mvn_coverage.log 2>&1; then
        # Try to extract coverage percentage
        if [ -f "target/site/jacoco/index.html" ]; then
            print_success "Coverage report generated"
            print_info "View report: $project_dir/target/site/jacoco/index.html"
        else
            print_warning "Coverage report not found (JaCoCo might not be configured)"
        fi
        cd - > /dev/null
        rm -f /tmp/mvn_coverage.log
        return 0
    else
        print_warning "Coverage check failed (non-critical)"
        cd - > /dev/null
        return 0  # Non-critical, don't fail
    fi
}

################################################################################
# Code Quality Checks
################################################################################

check_code_quality() {
    local project_dir=$1
    print_info "Running code quality checks..."
    
    cd "$project_dir"
    local quality_issues=0
    
    # Checkstyle
    if mvn checkstyle:check -q > /tmp/checkstyle.log 2>&1 2>/dev/null; then
        print_success "Checkstyle: No issues found"
    else
        if grep -q "checkstyle" pom.xml 2>/dev/null; then
            print_warning "Checkstyle found issues (check /tmp/checkstyle.log)"
            quality_issues=1
        else
            print_info "Checkstyle not configured (optional)"
        fi
    fi
    
    # PMD
    if mvn pmd:check -q > /tmp/pmd.log 2>&1 2>/dev/null; then
        print_success "PMD: No issues found"
    else
        if grep -q "pmd" pom.xml 2>/dev/null; then
            print_warning "PMD found issues (check /tmp/pmd.log)"
            quality_issues=1
        else
            print_info "PMD not configured (optional)"
        fi
    fi
    
    # SpotBugs
    if mvn spotbugs:check -q > /tmp/spotbugs.log 2>&1 2>/dev/null; then
        print_success "SpotBugs: No issues found"
    else
        if grep -q "spotbugs" pom.xml 2>/dev/null; then
            print_warning "SpotBugs found issues (check /tmp/spotbugs.log)"
            quality_issues=1
        else
            print_info "SpotBugs not configured (optional)"
        fi
    fi
    
    cd - > /dev/null
    
    if [ $quality_issues -eq 0 ]; then
        return 0
    else
        print_warning "Code quality issues found (review logs)"
        return 0  # Non-critical, but recommended
    fi
}

################################################################################
# Dependency Security Checks
################################################################################

check_dependency_security() {
    local project_dir=$1
    print_info "Checking for dependency vulnerabilities..."
    
    cd "$project_dir"
    
    # OWASP Dependency Check
    if mvn org.owasp:dependency-check-maven:check -q > /tmp/dependency-check.log 2>&1 2>/dev/null; then
        print_success "OWASP Dependency Check: No vulnerabilities found"
        cd - > /dev/null
        rm -f /tmp/dependency-check.log
        return 0
    else
        # Check if plugin is configured
        if grep -q "dependency-check-maven" pom.xml 2>/dev/null; then
            print_warning "OWASP Dependency Check found vulnerabilities (check /tmp/dependency-check.log)"
            if [ -f "target/dependency-check-report.html" ]; then
                print_info "Report: $project_dir/target/dependency-check-report.html"
            fi
        else
            print_info "OWASP Dependency Check not configured (recommended to add)"
        fi
        cd - > /dev/null
        return 0  # Non-critical
    fi
}

################################################################################
# Database & Migrations Checks
################################################################################

check_database_migrations() {
    local project_dir=$1
    print_info "Checking database migrations..."
    
    local migration_checks_passed=0
    
    # Check for Flyway
    if grep -q "flyway" pom.xml 2>/dev/null || [ -d "$project_dir/src/main/resources/db/migration" ]; then
        print_success "Flyway configuration found"
        
        # Validate migrations
        cd "$project_dir"
        if mvn flyway:validate -q > /tmp/flyway.log 2>&1 2>/dev/null; then
            print_success "Flyway migrations valid"
        else
            if grep -q "flyway" pom.xml 2>/dev/null; then
                print_warning "Flyway validation failed (check /tmp/flyway.log)"
            fi
        fi
        cd - > /dev/null
        migration_checks_passed=1
    fi
    
    # Check for Liquibase
    if grep -q "liquibase" pom.xml 2>/dev/null || [ -f "$project_dir/src/main/resources/db/changelog/db.changelog-master.xml" ]; then
        print_success "Liquibase configuration found"
        
        # Validate changelogs
        cd "$project_dir"
        if mvn liquibase:validate -q > /tmp/liquibase.log 2>&1 2>/dev/null; then
            print_success "Liquibase changelogs valid"
        else
            if grep -q "liquibase" pom.xml 2>/dev/null; then
                print_warning "Liquibase validation failed (check /tmp/liquibase.log)"
            fi
        fi
        cd - > /dev/null
        migration_checks_passed=1
    fi
    
    if [ $migration_checks_passed -eq 0 ]; then
        print_info "No database migration tool configured (Flyway or Liquibase recommended)"
    fi
    
    return 0  # Non-critical
}

################################################################################
# Configuration & Properties Checks
################################################################################

check_configuration() {
    local project_dir=$1
    print_info "Checking configuration files..."
    
    local config_issues=0
    
    # Check for application.properties or application.yml
    local config_file=""
    if [ -f "$project_dir/src/main/resources/application.properties" ]; then
        config_file="$project_dir/src/main/resources/application.properties"
        print_success "application.properties found"
    elif [ -f "$project_dir/src/main/resources/application.yml" ]; then
        config_file="$project_dir/src/main/resources/application.yml"
        print_success "application.yml found"
    else
        print_warning "No application.properties or application.yml found"
        config_issues=1
    fi
    
    # Check for required properties (if config file exists)
    if [ -n "$config_file" ]; then
        # Check for database configuration
        if ! grep -qE "(spring\.datasource|datasource)" "$config_file" 2>/dev/null; then
            print_warning "Database configuration not found in $config_file"
        fi
        
        # Check for JPA configuration
        if ! grep -qE "spring\.jpa|spring\.data\.jpa" "$config_file" 2>/dev/null; then
            print_warning "JPA configuration not found in $config_file"
        fi
        
        # Check for server port
        if ! grep -qE "server\.port" "$config_file" 2>/dev/null; then
            print_info "server.port not configured (will use default 8080)"
        fi
    fi
    
    # Check for required environment variables (already checked in original script)
    print_info "Required env vars: DB_URL, DB_USER, DB_PASS (if applicable)"
    
    if [ $config_issues -eq 0 ]; then
        return 0
    else
        return 0  # Non-critical warnings
    fi
}

################################################################################
# Performance & Profiling Checks
################################################################################

check_performance() {
    local project_dir=$1
    print_info "Checking performance configuration..."
    
    local perf_checks_passed=0
    
    # Check for actuator endpoints
    if grep -q "spring-boot-starter-actuator" "$project_dir/pom.xml" 2>/dev/null; then
        print_success "Spring Actuator found (enables monitoring)"
        perf_checks_passed=1
    fi
    
    # Check for logging configuration
    if [ -f "$project_dir/src/main/resources/logback.xml" ] || \
       [ -f "$project_dir/src/main/resources/log4j2.xml" ] || \
       grep -q "logging" "$project_dir/src/main/resources/application.properties" 2>/dev/null || \
       grep -q "logging" "$project_dir/src/main/resources/application.yml" 2>/dev/null; then
        print_success "Logging configuration found"
        perf_checks_passed=1
    else
        print_info "Logging configuration not found (optional but recommended)"
    fi
    
    # Check for connection pool configuration
    local config_file=""
    [ -f "$project_dir/src/main/resources/application.properties" ] && config_file="$project_dir/src/main/resources/application.properties"
    [ -f "$project_dir/src/main/resources/application.yml" ] && config_file="$project_dir/src/main/resources/application.yml"
    
    if [ -n "$config_file" ] && grep -qE "(hikari|tomcat|druid)" "$config_file" 2>/dev/null; then
        print_success "Connection pool configuration found"
    else
        print_info "Connection pool not explicitly configured (will use defaults)"
    fi
    
    return 0  # Optional checks
}

################################################################################
# Docker Checks
################################################################################

check_docker() {
    local project_dir=$1
    print_info "Checking Docker configuration..."
    
    local docker_checks_passed=0
    
    # Check for Dockerfile
    if [ -f "$project_dir/Dockerfile" ]; then
        print_success "Dockerfile found"
        docker_checks_passed=1
    else
        print_warning "Dockerfile not found (optional but recommended)"
    fi
    
    # Check for docker-compose.yml
    if [ -f "$project_dir/compose.yaml" ] || [ -f "$project_dir/docker-compose.yml" ]; then
        local compose_file=$(ls "$project_dir"/compose.yaml "$project_dir"/docker-compose.yml 2>/dev/null | head -1)
        print_success "Docker Compose file found"
        
        # Validate compose file syntax
        if command -v docker-compose &> /dev/null || command -v docker &> /dev/null; then
            if docker compose -f "$compose_file" config > /dev/null 2>&1 || \
               docker-compose -f "$compose_file" config > /dev/null 2>&1; then
                print_success "Docker Compose syntax valid"
            else
                print_error "Docker Compose syntax invalid"
                return 1
            fi
        fi
        docker_checks_passed=1
    else
        print_warning "Docker Compose file not found (optional but recommended)"
    fi
    
    return 0  # Docker is optional
}

################################################################################
# CI/CD Checks
################################################################################

check_cicd() {
    local project_dir=$1
    print_info "Checking CI/CD configuration..."
    
    if [ -d "$project_dir/.github/workflows" ]; then
        local workflow_count=$(find "$project_dir/.github/workflows" -name "*.yml" -o -name "*.yaml" | wc -l | tr -d ' ')
        if [ $workflow_count -gt 0 ]; then
            print_success "GitHub Actions workflows found ($workflow_count)"
            return 0
        fi
    fi
    
    print_warning "CI/CD workflows not found (recommended)"
    return 0  # Non-critical
}

################################################################################
# Main Project Validation
################################################################################

validate_project() {
    local project_dir=$1
    local project_name=$(basename "$project_dir")
    
    print_header "Validating: $project_name"
    
    local checks_passed=0
    local checks_failed=0
    
    # 1. Security checks (critical)
    if check_secrets "$project_dir"; then
        ((checks_passed++))
    else
        ((checks_failed++))
    fi
    
    # 2. Documentation checks (critical)
    if check_documentation "$project_dir"; then
        ((checks_passed++))
    else
        ((checks_failed++))
    fi
    
    # 3. Build check (critical)
    if check_build "$project_dir"; then
        ((checks_passed++))
    else
        ((checks_failed++))
    fi
    
    # 4. Test check (critical)
    if check_tests "$project_dir"; then
        ((checks_passed++))
    else
        ((checks_failed++))
        print_warning "Project has test failures (fix before going live)"
    fi
    
    # 5. Coverage check (recommended)
    check_coverage "$project_dir"
    
    # 6. Code quality check (recommended)
    check_code_quality "$project_dir"
    
    # 7. Dependency security check (recommended)
    check_dependency_security "$project_dir"
    
    # 8. Database migrations check (recommended)
    check_database_migrations "$project_dir"
    
    # 9. Configuration check (recommended)
    check_configuration "$project_dir"
    
    # 10. Docker check (recommended)
    check_docker "$project_dir"
    
    # 11. CI/CD check (recommended)
    check_cicd "$project_dir"
    
    # 12. Performance check (optional)
    check_performance "$project_dir"
    
    # Summary
    echo ""
    if [ $checks_failed -eq 0 ]; then
        print_success "Project $project_name: All critical checks passed"
        ((PASSED_PROJECTS++))
        return 0
    else
        print_error "Project $project_name: $checks_failed critical check(s) failed"
        ((FAILED_PROJECTS++))
        return 1
    fi
}

################################################################################
# Find Projects
################################################################################

find_projects() {
    local projects=()
    
    if [ -n "$1" ]; then
        # Specific project requested
        if [ -d "$1" ] && [ -f "$1/pom.xml" ]; then
            projects=("$1")
        else
            print_error "Project '$1' not found or doesn't have pom.xml"
            exit 1
        fi
    else
        # Find all projects with pom.xml
        while IFS= read -r -d '' project; do
            projects+=("$(dirname "$project")")
        done < <(find . -maxdepth 2 -name "pom.xml" -type f -print0)
    fi
    
    echo "${projects[@]}"
}

################################################################################
# Main
################################################################################

main() {
    print_header "🚀 Pre-GoLive Checks for #30DiasJava"
    echo ""
    echo "This script validates all projects before going live."
    echo ""
    
    # Find projects
    read -a projects <<< "$(find_projects "$1")"
    TOTAL_PROJECTS=${#projects[@]}
    
    if [ $TOTAL_PROJECTS -eq 0 ]; then
        print_error "No projects found with pom.xml"
        exit 1
    fi
    
    print_info "Found $TOTAL_PROJECTS project(s) to validate"
    echo ""
    
    # Validate each project
    for project in "${projects[@]}"; do
        validate_project "$project" || true
    done
    
    # Final summary
    echo ""
    print_header "📊 Summary"
    echo ""
    echo "Total projects: $TOTAL_PROJECTS"
    print_success "Passed: $PASSED_PROJECTS"
    if [ $FAILED_PROJECTS -gt 0 ]; then
        print_error "Failed: $FAILED_PROJECTS"
    fi
    if [ $WARNINGS -gt 0 ]; then
        print_warning "Warnings: $WARNINGS"
    fi
    
    echo ""
    if [ $FAILED_PROJECTS -eq 0 ]; then
        print_success "✅ All projects passed critical checks!"
        print_info "Ready for production deployment"
        exit 0
    else
        print_error "❌ Some projects failed critical checks"
        print_info "Fix the issues above before going live"
        exit 1
    fi
}

# Run main function
main "$@"
