#!/bin/bash

################################################################################
# Pre-GoLive Script for #30DiasJava Monorepo
# 
# Purpose: Validate all projects before going live
# Usage: ./pre-golive.sh [project-name] [--no-cache]
#   - If no project specified, runs checks for all projects
#   - If project specified, runs checks only for that project
#   - --no-cache: Disable cache and run all checks
################################################################################

# Cache directory
CACHE_DIR="./.pre-golive-cache"
CACHE_TTL=3600  # 1 hour

# Don't exit on error for non-critical checks
set +e  # Allow continues execution
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

# Report generation
REPORT_DIR="./pre-golive-reports"
JSON_REPORT="$REPORT_DIR/report.json"
HTML_REPORT="$REPORT_DIR/report.html"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# Check cache
check_cache() {
    local project_dir=$1
    local cache_file="$CACHE_DIR/$(basename "$project_dir")_cache"
    
    if [ -f "$cache_file" ]; then
        local cache_age=$(($(date +%s) - $(stat -f %B "$cache_file" 2>/dev/null || stat -c %Y "$cache_file" 2>/dev/null)))
        if [ $cache_age -lt $CACHE_TTL ]; then
            return 0  # Cache valid
        fi
    fi
    return 1  # Cache invalid or missing
}

# Update cache
update_cache() {
    local project_dir=$1
    mkdir -p "$CACHE_DIR"
    touch "$CACHE_DIR/$(basename "$project_dir")_cache"
}

# Initialize JSON report
init_json_report() {
    mkdir -p "$REPORT_DIR"
    {
        echo "{"
        echo "  \"timestamp\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\","
        echo "  \"projects\": ["
    } > "$JSON_REPORT" 2>/dev/null || {
        echo "{" > "$JSON_REPORT"
        echo "  \"timestamp\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\"," >> "$JSON_REPORT"
        echo "  \"projects\": [" >> "$JSON_REPORT"
    }
}

# Add project to JSON report
add_project_to_json() {
    local project_name=$1
    local status=$2
    local checks_passed=$3
    local checks_failed=$4
    local warnings=$5
    
    # Ensure report directory exists
    mkdir -p "$REPORT_DIR"
    
    # Check if we need a comma (not first project)
    if [ "$JSON_FIRST_PROJECT" = false ]; then
        echo "," >> "$JSON_REPORT" 2>/dev/null || echo "," | tee -a "$JSON_REPORT" > /dev/null
    fi
    JSON_FIRST_PROJECT=false
    
    {
        echo "    {"
        echo "      \"name\": \"$project_name\","
        echo "      \"status\": \"$status\","
        echo "      \"checks_passed\": $checks_passed,"
        echo "      \"checks_failed\": $checks_failed,"
        echo "      \"warnings\": $warnings"
        echo -n "    }"
    } >> "$JSON_REPORT" 2>/dev/null || {
        echo "    {" >> "$JSON_REPORT"
        echo "      \"name\": \"$project_name\"," >> "$JSON_REPORT"
        echo "      \"status\": \"$status\"," >> "$JSON_REPORT"
        echo "      \"checks_passed\": $checks_passed," >> "$JSON_REPORT"
        echo "      \"checks_failed\": $checks_failed," >> "$JSON_REPORT"
        echo "      \"warnings\": $warnings" >> "$JSON_REPORT"
        echo -n "    }" >> "$JSON_REPORT"
    }
}

# Finalize JSON report
finalize_json_report() {
    {
        echo ""
        echo "  ],"
        echo "  \"summary\": {"
        echo "    \"total_projects\": $TOTAL_PROJECTS,"
        echo "    \"passed\": $PASSED_PROJECTS,"
        echo "    \"failed\": $FAILED_PROJECTS,"
        echo "    \"warnings\": $WARNINGS"
        echo "  }"
        echo "}"
    } >> "$JSON_REPORT" 2>/dev/null || {
        echo "" >> "$JSON_REPORT"
        echo "  ]," >> "$JSON_REPORT"
        echo "  \"summary\": {" >> "$JSON_REPORT"
        echo "    \"total_projects\": $TOTAL_PROJECTS," >> "$JSON_REPORT"
        echo "    \"passed\": $PASSED_PROJECTS," >> "$JSON_REPORT"
        echo "    \"failed\": $FAILED_PROJECTS," >> "$JSON_REPORT"
        echo "    \"warnings\": $WARNINGS" >> "$JSON_REPORT"
        echo "  }" >> "$JSON_REPORT"
        echo "}" >> "$JSON_REPORT"
    }
}

# Detect build tool (Maven or Gradle)
detect_build_tool() {
    local project_dir=$1
    
    if [ -f "$project_dir/pom.xml" ]; then
        echo "maven"
    elif [ -f "$project_dir/build.gradle" ] || [ -f "$project_dir/build.gradle.kts" ]; then
        echo "gradle"
    else
        echo "unknown"
    fi
}

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
    local build_tool=$(detect_build_tool "$project_dir")
    
    cd "$project_dir"
    
    if [ "$build_tool" = "maven" ]; then
        print_info "Checking Maven build..."
        
        if [ ! -f "pom.xml" ]; then
            print_error "pom.xml not found"
            cd - > /dev/null
            return 1
        fi
        
        # Check Java version
        local java_version=$(java -version 2>&1 | head -1 | cut -d'"' -f2 | sed '/^1\./s///' | cut -d'.' -f1)
        print_info "Java version: $java_version"
        
        # Check Spring Boot version
        if grep -q "spring-boot-starter-parent" pom.xml; then
            local spring_version=$(grep -A 1 "spring-boot-starter-parent" pom.xml | grep "<version>" | sed 's/.*<version>\(.*\)<\/version>.*/\1/' | head -1)
            print_info "Spring Boot version: $spring_version"
        fi
        
        # Dependency tree (quick check)
        print_info "Analyzing dependency tree..."
        if mvn dependency:tree -q > /tmp/dependency_tree.log 2>&1; then
            local dep_count=$(grep -c "org.springframework\|org.postgresql\|com." /tmp/dependency_tree.log 2>/dev/null || echo "0")
            print_info "Dependencies analyzed: $dep_count"
        fi
        
        # Clean and compile (skip tests for faster validation)
        if mvn clean compile -DskipTests -q > /tmp/mvn_build.log 2>&1; then
            print_success "Maven build successful"
            cd - > /dev/null
            rm -f /tmp/mvn_build.log /tmp/dependency_tree.log
            return 0
        else
            print_error "Maven build failed. Check /tmp/mvn_build.log"
            tail -20 /tmp/mvn_build.log
            cd - > /dev/null
            return 1
        fi
        
    elif [ "$build_tool" = "gradle" ]; then
        print_info "Checking Gradle build..."
        
        if [ -f "gradlew" ]; then
            ./gradlew clean compileJava -x test --quiet > /tmp/gradle_build.log 2>&1
        elif [ -f "gradle" ]; then
            gradle clean compileJava -x test --quiet > /tmp/gradle_build.log 2>&1
        else
            print_error "Gradle wrapper not found"
            cd - > /dev/null
            return 1
        fi
        
        if [ $? -eq 0 ]; then
            print_success "Gradle build successful"
            cd - > /dev/null
            rm -f /tmp/gradle_build.log
            return 0
        else
            print_error "Gradle build failed. Check /tmp/gradle_build.log"
            tail -20 /tmp/gradle_build.log
            cd - > /dev/null
            return 1
        fi
    else
        print_error "No build tool detected (pom.xml or build.gradle)"
        cd - > /dev/null
        return 1
    fi
}

check_tests() {
    local project_dir=$1
    local build_tool=$(detect_build_tool "$project_dir")
    
    print_info "Running tests..."
    
    cd "$project_dir"
    
    if [ "$build_tool" = "maven" ]; then
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
        
    elif [ "$build_tool" = "gradle" ]; then
        local gradle_cmd=""
        if [ -f "gradlew" ]; then
            gradle_cmd="./gradlew test --quiet"
        else
            gradle_cmd="gradle test --quiet"
        fi
        
        if ! $gradle_cmd > /tmp/gradle_test.log 2>&1; then
            print_error "Tests failed"
            tail -30 /tmp/gradle_test.log | grep -A 10 -E "(FAILED|FAILURE)" || tail -30 /tmp/gradle_test.log
            cd - > /dev/null
            return 1
        fi
        cd - > /dev/null
        rm -f /tmp/gradle_test.log
    fi
    
    print_success "All tests passed"
    return 0
}

check_coverage() {
    local project_dir=$1
    local build_tool=$(detect_build_tool "$project_dir")
    
    print_info "Checking test coverage..."
    
    cd "$project_dir"
    
    if [ "$build_tool" = "maven" ]; then
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
    elif [ "$build_tool" = "gradle" ]; then
        local gradle_cmd=""
        if [ -f "gradlew" ]; then
            gradle_cmd="./gradlew test jacocoTestReport --quiet"
        else
            gradle_cmd="gradle test jacocoTestReport --quiet"
        fi
        
        if $gradle_cmd > /tmp/gradle_coverage.log 2>&1; then
            if [ -f "build/reports/jacoco/test/html/index.html" ]; then
                print_success "Coverage report generated"
                print_info "View report: $project_dir/build/reports/jacoco/test/html/index.html"
            fi
            cd - > /dev/null
            rm -f /tmp/gradle_coverage.log
            return 0
        else
            print_warning "Coverage check failed (non-critical)"
            cd - > /dev/null
            return 0
        fi
    fi
}

################################################################################
# Code Quality Checks
################################################################################

check_code_quality() {
    local project_dir=$1
    local build_tool=$(detect_build_tool "$project_dir")
    
    print_info "Running code quality checks..."
    
    cd "$project_dir"
    local quality_issues=0
    
    if [ "$build_tool" = "maven" ]; then
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
        
        # SonarQube (if configured)
        if grep -q "sonar" pom.xml 2>/dev/null || [ -f "sonar-project.properties" ]; then
            print_info "SonarQube configuration found"
            if [ -n "$SONAR_TOKEN" ] && [ -n "$SONAR_HOST_URL" ]; then
                if mvn sonar:sonar -Dsonar.token="$SONAR_TOKEN" -Dsonar.host.url="$SONAR_HOST_URL" -q > /tmp/sonar.log 2>&1 2>/dev/null; then
                    print_success "SonarQube analysis completed"
                else
                    print_warning "SonarQube analysis failed (check /tmp/sonar.log)"
                fi
            else
                print_info "SonarQube configured but SONAR_TOKEN/SONAR_HOST_URL not set (skip)"
            fi
        else
            print_info "SonarQube not configured (optional)"
        fi
        
    elif [ "$build_tool" = "gradle" ]; then
        local gradle_cmd=""
        if [ -f "gradlew" ]; then
            gradle_cmd="./gradlew"
        else
            gradle_cmd="gradle"
        fi
        
        # Checkstyle for Gradle
        if $gradle_cmd checkstyleMain checkstyleTest --quiet > /tmp/checkstyle.log 2>&1 2>/dev/null; then
            print_success "Checkstyle: No issues found"
        else
            if grep -q "checkstyle" build.gradle* 2>/dev/null; then
                print_warning "Checkstyle found issues"
                quality_issues=1
            else
                print_info "Checkstyle not configured (optional)"
            fi
        fi
        
        # PMD for Gradle
        if $gradle_cmd pmdMain pmdTest --quiet > /tmp/pmd.log 2>&1 2>/dev/null; then
            print_success "PMD: No issues found"
        else
            if grep -q "pmd" build.gradle* 2>/dev/null; then
                print_warning "PMD found issues"
                quality_issues=1
            else
                print_info "PMD not configured (optional)"
            fi
        fi
        
        # SpotBugs for Gradle
        if $gradle_cmd spotbugsMain spotbugsTest --quiet > /tmp/spotbugs.log 2>&1 2>/dev/null; then
            print_success "SpotBugs: No issues found"
        else
            if grep -q "spotbugs" build.gradle* 2>/dev/null; then
                print_warning "SpotBugs found issues"
                quality_issues=1
            else
                print_info "SpotBugs not configured (optional)"
            fi
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
    
    local build_tool=$(detect_build_tool "$project_dir")
    
    if [ "$build_tool" = "maven" ]; then
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
    elif [ "$build_tool" = "gradle" ]; then
        local gradle_cmd=""
        if [ -f "gradlew" ]; then
            gradle_cmd="./gradlew dependencyCheckAnalyze --quiet"
        else
            gradle_cmd="gradle dependencyCheckAnalyze --quiet"
        fi
        
        if $gradle_cmd > /tmp/dependency-check.log 2>&1 2>/dev/null; then
            print_success "OWASP Dependency Check: No vulnerabilities found"
            cd - > /dev/null
            rm -f /tmp/dependency-check.log
            return 0
        else
            if grep -q "dependency-check" build.gradle* 2>/dev/null; then
                print_warning "OWASP Dependency Check found vulnerabilities"
            else
                print_info "OWASP Dependency Check not configured (recommended)"
            fi
            cd - > /dev/null
            return 0
        fi
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
    if grep -q "flyway" "$project_dir/pom.xml" 2>/dev/null || [ -d "$project_dir/src/main/resources/db/migration" ]; then
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
    if grep -q "liquibase" "$project_dir/pom.xml" 2>/dev/null || [ -f "$project_dir/src/main/resources/db/changelog/db.changelog-master.xml" ]; then
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
    if grep -q "spring-boot-starter-actuator" "$project_dir/pom.xml" 2>/dev/null || grep -q "spring-boot-starter-actuator" "$project_dir/build.gradle"* 2>/dev/null; then
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
    
    # Check cache (optional - can be disabled with --no-cache)
    if [ "$NO_CACHE" != "true" ] && check_cache "$project_dir"; then
        print_info "Using cached results (use --no-cache to force refresh)"
        # Load from cache would go here - simplified for now
    fi
    
    local checks_passed=0
    local checks_failed=0
    local project_warnings=0
    
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
    
    # Update cache
    if [ "$NO_CACHE" != "true" ]; then
        update_cache "$project_dir"
    fi
    
    # Summary
    echo ""
    if [ $checks_failed -eq 0 ]; then
        print_success "Project $project_name: All critical checks passed"
        ((PASSED_PROJECTS++))
        add_project_to_json "$project_name" "PASSED" $checks_passed $checks_failed $project_warnings
        return 0
    else
        print_error "Project $project_name: $checks_failed critical check(s) failed"
        ((FAILED_PROJECTS++))
        add_project_to_json "$project_name" "FAILED" $checks_passed $checks_failed $project_warnings
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
        if [ -d "$1" ] && ([ -f "$1/pom.xml" ] || [ -f "$1/build.gradle" ] || [ -f "$1/build.gradle.kts" ]); then
            projects=("$1")
        else
            print_error "Project '$1' not found or doesn't have pom.xml or build.gradle"
  exit 1
fi
    else
        # Find all projects with pom.xml or build.gradle
        while IFS= read -r -d '' project; do
            projects+=("$(dirname "$project")")
        done < <(find . -maxdepth 2 \( -name "pom.xml" -o -name "build.gradle" -o -name "build.gradle.kts" \) -type f -print0)
        
        # Remove duplicates
        local old_ifs="$IFS"
        IFS=$'\n' projects=($(printf '%s\n' "${projects[@]}" | sort -u))
        IFS="$old_ifs"
    fi
    
    echo "${projects[@]}"
}

################################################################################
# Report Generation
################################################################################

generate_html_report() {
    print_info "Generating HTML report..."
    
    cat > "$HTML_REPORT" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pre-GoLive Validation Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        h1 { color: #333; }
        .summary { display: flex; gap: 20px; margin: 20px 0; }
        .stat { padding: 15px; border-radius: 5px; text-align: center; flex: 1; }
        .stat.passed { background: #d4edda; color: #155724; }
        .stat.failed { background: #f8d7da; color: #721c24; }
        .stat.warnings { background: #fff3cd; color: #856404; }
        .project { margin: 20px 0; padding: 15px; border: 1px solid #ddd; border-radius: 5px; }
        .project.passed { border-left: 4px solid #28a745; }
        .project.failed { border-left: 4px solid #dc3545; }
        .status { font-weight: bold; font-size: 18px; margin-bottom: 10px; }
        .status.passed { color: #28a745; }
        .status.failed { color: #dc3545; }
        table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        th, td { padding: 8px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background: #f8f9fa; }
        .timestamp { color: #666; font-size: 12px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Pre-GoLive Validation Report</h1>
        <div class="timestamp">Generated: <span id="timestamp"></span></div>
        
        <div class="summary">
            <div class="stat">
                <h2 id="total-projects">0</h2>
                <p>Total Projects</p>
            </div>
            <div class="stat passed">
                <h2 id="passed-projects">0</h2>
                <p>Passed</p>
            </div>
            <div class="stat failed">
                <h2 id="failed-projects">0</h2>
                <p>Failed</p>
            </div>
            <div class="stat warnings">
                <h2 id="total-warnings">0</h2>
                <p>Warnings</p>
            </div>
        </div>
        
        <div id="projects-container"></div>
    </div>
    
    <script>
        // Load JSON report
        fetch('report.json')
            .then(response => response.json())
            .then(data => {
                document.getElementById('timestamp').textContent = new Date(data.timestamp).toLocaleString();
                document.getElementById('total-projects').textContent = data.summary.total_projects;
                document.getElementById('passed-projects').textContent = data.summary.passed;
                document.getElementById('failed-projects').textContent = data.summary.failed;
                document.getElementById('total-warnings').textContent = data.summary.warnings;
                
                const container = document.getElementById('projects-container');
                data.projects.forEach(project => {
                    const div = document.createElement('div');
                    div.className = `project ${project.status.toLowerCase()}`;
                    div.innerHTML = `
                        <div class="status ${project.status.toLowerCase()}">${project.status === 'PASSED' ? '✅' : '❌'} ${project.name}</div>
                        <table>
                            <tr><th>Metric</th><th>Value</th></tr>
                            <tr><td>Checks Passed</td><td>${project.checks_passed}</td></tr>
                            <tr><td>Checks Failed</td><td>${project.checks_failed}</td></tr>
                            <tr><td>Warnings</td><td>${project.warnings}</td></tr>
                        </table>
                    `;
                    container.appendChild(div);
                });
            })
            .catch(error => {
                console.error('Error loading report:', error);
                document.getElementById('projects-container').innerHTML = '<p>Error loading report data.</p>';
            });
    </script>
</body>
</html>
EOF
    
    print_success "HTML report generated: $HTML_REPORT"
    print_info "JSON report: $JSON_REPORT"
}

################################################################################
# Main
################################################################################

main() {
    # Parse arguments
    NO_CACHE=false
    for arg in "$@"; do
        case $arg in
            --no-cache)
                NO_CACHE=true
                shift
                ;;
            *)
                # Project name or other args
                ;;
        esac
    done
    
    print_header "🚀 Pre-GoLive Checks for #30DiasJava"
    echo ""
    echo "This script validates all projects before going live."
    if [ "$NO_CACHE" = "true" ]; then
        echo "Cache disabled - running all checks."
    fi
    echo ""
    
    # Initialize cache directory
    mkdir -p "$CACHE_DIR"
    
    # Initialize JSON report
    JSON_FIRST_PROJECT=true
    init_json_report
    
    # Find projects (get project name if provided, excluding --no-cache)
    local project_arg=""
    for arg in "$@"; do
        if [ "$arg" != "--no-cache" ]; then
            project_arg="$arg"
            break
        fi
    done
    
    read -a projects <<< "$(find_projects "$project_arg")"
    TOTAL_PROJECTS=${#projects[@]}
    
    if [ $TOTAL_PROJECTS -eq 0 ]; then
        print_error "No projects found with pom.xml or build.gradle"
        exit 1
    fi
    
    print_info "Found $TOTAL_PROJECTS project(s) to validate"
    echo ""
    
    # Validate each project
    for project in "${projects[@]}"; do
        validate_project "$project" || true
    done
    
    # Finalize JSON report
    finalize_json_report
    
    # Generate HTML report
    generate_html_report
    
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
        print_info ""
        print_info "📊 Reports generated:"
        print_info "   JSON: $JSON_REPORT"
        print_info "   HTML: $HTML_REPORT"
        exit 0
    else
        print_error "❌ Some projects failed critical checks"
        print_info "Fix the issues above before going live"
        print_info ""
        print_info "📊 Reports generated:"
        print_info "   JSON: $JSON_REPORT"
        print_info "   HTML: $HTML_REPORT"
        exit 1
    fi
}

# Run main function
main "$@"