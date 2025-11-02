#!/bin/bash

################################################################################
# Script to Add Code Quality Tools to All Projects
# 
# This script adds Checkstyle, PMD, and SpotBugs plugins to all Maven projects
################################################################################

PROJECTS=("user-profile-service" "content-catalog-api" "recommendation-engine")

add_checkstyle() {
    local pom_file=$1
    local plugin_section=""
    
    # Check if checkstyle already exists
    if grep -q "maven-checkstyle-plugin" "$pom_file" 2>/dev/null; then
        echo "Checkstyle already configured in $pom_file"
        return 0
    fi
    
    # Find the </plugins> closing tag
    if grep -q "</plugins>" "$pom_file"; then
        # Add before </plugins>
        sed -i.bak '/<\/plugins>/i\
            <!-- Checkstyle Plugin -->\
            <plugin>\
                <groupId>org.apache.maven.plugins</groupId>\
                <artifactId>maven-checkstyle-plugin</artifactId>\
                <version>3.3.1</version>\
                <executions>\
                    <execution>\
                        <id>validate</id>\
                        <phase>validate</phase>\
                        <goals>\
                            <goal>check</goal>\
                        </goals>\
                    </execution>\
                </executions>\
                <configuration>\
                    <configLocation>google_checks.xml</configLocation>\
                    <consoleOutput>true</consoleOutput>\
                    <failOnViolation>false</failOnViolation>\
                </configuration>\
            </plugin>
' "$pom_file"
        echo "✅ Checkstyle added to $pom_file"
    else
        echo "⚠️  Could not find </plugins> tag in $pom_file"
    fi
}

add_spotbugs() {
    local pom_file=$1
    
    if grep -q "spotbugs-maven-plugin" "$pom_file" 2>/dev/null; then
        echo "SpotBugs already configured in $pom_file"
        return 0
    fi
    
    if grep -q "</plugins>" "$pom_file"; then
        sed -i.bak '/<\/plugins>/i\
            <!-- SpotBugs Plugin -->\
            <plugin>\
                <groupId>com.github.spotbugs</groupId>\
                <artifactId>spotbugs-maven-plugin</artifactId>\
                <version>4.8.0.0</version>\
                <executions>\
                    <execution>\
                        <goals>\
                            <goal>check</goal>\
                        </goals>\
                    </execution>\
                </executions>\
            </plugin>
' "$pom_file"
        echo "✅ SpotBugs added to $pom_file"
    else
        echo "⚠️  Could not find </plugins> tag in $pom_file"
    fi
}

echo "🔧 Adding Code Quality Tools to Projects..."

for project in "${PROJECTS[@]}"; do
    if [ -f "$project/pom.xml" ]; then
        echo ""
        echo "📦 Processing: $project"
        add_checkstyle "$project/pom.xml"
        add_spotbugs "$project/pom.xml"
        rm -f "$project/pom.xml.bak"
    else
        echo "⚠️  $project/pom.xml not found"
    fi
done

echo ""
echo "✅ Done! Run 'mvn clean verify' to test the new plugins."

