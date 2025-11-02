#!/bin/bash

################################################################################
# Script to Add Flyway to All Projects
# 
# This script adds Flyway plugin and creates initial migration
################################################################################

PROJECTS=("user-profile-service" "content-catalog-api" "recommendation-engine")

add_flyway_plugin() {
    local pom_file=$1
    
    if grep -q "flyway-maven-plugin" "$pom_file" 2>/dev/null; then
        echo "Flyway already configured in $pom_file"
        return 0
    fi
    
    if grep -q "</plugins>" "$pom_file"; then
        sed -i.bak '/<\/plugins>/i\
            <!-- Flyway Plugin -->\
            <plugin>\
                <groupId>org.flywaydb</groupId>\
                <artifactId>flyway-maven-plugin</artifactId>\
                <version>10.7.1</version>\
                <configuration>\
                    <url>${spring.datasource.url}</url>\
                    <user>${spring.datasource.username}</user>\
                    <password>${spring.datasource.password}</password>\
                </configuration>\
            </plugin>
' "$pom_file"
        echo "✅ Flyway plugin added to $pom_file"
        
        # Also add dependency
        if grep -q "</dependencies>" "$pom_file"; then
            sed -i.bak2 '/<\/dependencies>/i\
            <!-- Flyway -->\
            <dependency>\
                <groupId>org.flywaydb</groupId>\
                <artifactId>flyway-core</artifactId>\
            </dependency>\
            <dependency>\
                <groupId>org.flywaydb</groupId>\
                <artifactId>flyway-database-postgresql</artifactId>\
            </dependency>
' "$pom_file"
            echo "✅ Flyway dependencies added"
        fi
        rm -f "$pom_file.bak" "$pom_file.bak2"
    fi
}

create_migration() {
    local project_dir=$1
    local migration_dir="$project_dir/src/main/resources/db/migration"
    
    mkdir -p "$migration_dir"
    
    # Create initial migration
    local migration_file="$migration_dir/V1__Initial_schema.sql"
    
    if [ ! -f "$migration_file" ]; then
        cat > "$migration_file" << 'EOF'
-- Initial database schema
-- This migration is created automatically
-- Add your table creation statements here

-- Example:
-- CREATE TABLE IF NOT EXISTS example (
--     id BIGSERIAL PRIMARY KEY,
--     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
-- );
EOF
        echo "✅ Initial migration created: $migration_file"
    else
        echo "⚠️  Migration file already exists: $migration_file"
    fi
}

echo "🔧 Adding Flyway to Projects..."

for project in "${PROJECTS[@]}"; do
    if [ -f "$project/pom.xml" ]; then
        echo ""
        echo "📦 Processing: $project"
        add_flyway_plugin "$project/pom.xml"
        create_migration "$project"
    else
        echo "⚠️  $project/pom.xml not found"
    fi
done

echo ""
echo "✅ Done! Configure database connection in application.properties"
echo "   Then run 'mvn flyway:migrate' to apply migrations"

