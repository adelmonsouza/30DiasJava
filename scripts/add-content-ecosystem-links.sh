#!/bin/bash

################################################################################
# Script to Add Content Ecosystem Links to All READMEs
# 
# This script adds the Content Ecosystem section to all project READMEs
################################################################################

# Function to get blog URL
get_blog_url() {
    case "$1" in
        "user-profile-service")
            echo "https://enouveau.io/blog/2025/11/01/dtos-under-the-hood.html"
            ;;
        "content-catalog-api")
            echo "https://enouveau.io/blog/2025/11/02/pagination-under-the-hood.html"
            ;;
        "recommendation-engine")
            echo "https://enouveau.io/blog/2025/11/03/recommendation-under-the-hood.html"
            ;;
        *)
            echo ""
            ;;
    esac
}

# Function to get GitHub repo
get_github_repo() {
    case "$1" in
        "user-profile-service")
            echo "30DiasJava-Day01-UserProfileService"
            ;;
        "content-catalog-api")
            echo "30DiasJava-Day02-ContentCatalogAPI"
            ;;
        "recommendation-engine")
            echo "30DiasJava-Day03-RecommendationEngine"
            ;;
        *)
            echo ""
            ;;
    esac
}

add_content_ecosystem() {
    local project_dir=$1
    local readme_file="$project_dir/README.md"
    
    if [ ! -f "$readme_file" ]; then
        echo "⚠️  README.md not found in $project_dir"
        return 1
    fi
    
    # Check if already exists
    if grep -qi "content ecosystem" "$readme_file" 2>/dev/null; then
        echo "✅ Content Ecosystem section already exists in $readme_file"
        return 0
    fi
    
    local blog_url=$(get_blog_url "$project_dir")
    local github_repo=$(get_github_repo "$project_dir")
    
    if [ -z "$blog_url" ] || [ -z "$github_repo" ]; then
        echo "⚠️  No mapping found for $project_dir"
        return 1
    fi
    
    # Add section before License or at the end
    local content_ecosystem_section="

---

## 🔗 Content Ecosystem

**This project is part of a complete learning ecosystem:**
- **GitHub (this repo):** Complete code, README, Business Plan - ready to study and clone
  - Repository: [github.com/adelmonsouza/$github_repo](https://github.com/adelmonsouza/$github_repo)
- **Blog:** Technical deep-dive and \"Under the Hood\" analysis
  - Article: [$blog_url]($blog_url)
- **LinkedIn:** Day announcement, insights, and community engagement

Each platform complements the others. Study the code here, understand the concepts in the blog post, and engage with the community on LinkedIn!

"
    
    # Try to add before License section
    if grep -q "## 🛡️ License\|## License\|## 📄 License" "$readme_file"; then
        sed -i.bak "/## 🛡️ License\|## License\|## 📄 License/i\\$content_ecosystem_section" "$readme_file"
    else
        # Append at the end
        echo "$content_ecosystem_section" >> "$readme_file"
    fi
    
    rm -f "$readme_file.bak"
    echo "✅ Content Ecosystem section added to $readme_file"
}

PROJECTS=("user-profile-service" "content-catalog-api" "recommendation-engine")

echo "🔗 Adding Content Ecosystem Links to READMEs..."

for project_dir in "${PROJECTS[@]}"; do
    if [ -d "$project_dir" ]; then
        echo ""
        echo "📦 Processing: $project_dir"
        add_content_ecosystem "$project_dir"
    else
        echo "⚠️  Project directory not found: $project_dir"
    fi
done

echo ""
echo "✅ Done! All READMEs updated with Content Ecosystem links."

