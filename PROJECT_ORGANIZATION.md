# 📋 Project Organization - #30DiasJava

**Status:** ✅ Standardized (Based on Day 2 Model)  
**Date:** November 2, 2025

**📖 See also:** [CONTENT_ECOSYSTEM.md](./CONTENT_ECOSYSTEM.md) - How GitHub, Blog, and LinkedIn connect

---

## 🎯 Standardization Guidelines

### ✅ Blog Post Format (Based on Day 2)

**Structure:**
1. Front matter with `layout: post`
2. English title (descriptive, technical)
3. Opening: "Hey there! So I've been diving into..."
4. Disclaimer section
5. "Why I'm Looking at This" section
6. Technical deep-dive with code examples
7. "Under the Hood" explanations
8. Performance comparisons (tables)
9. "What Can We Learn From This?" with trade-offs
10. "Final Thoughts" with key takeaways
11. Links to project and next article
12. Hashtags

**File naming:**
- Format: `YYYY-MM-DD-[topic]-under-the-hood.md`
- Example: `2025-11-02-pagination-under-the-hood.md`

**Categories:**
- Architecture
- Performance
- Security
- Spring Boot
- [Specific Technology]

---

### ✅ LinkedIn Post Format (Based on Day 2)

**Structure:**
1. Opening: "So I've been diving into..."
2. "What I built today:" (2-3 sentences)
3. "Why this matters:" (2-3 sentences)
4. "Under the Hood:" (3-4 sentences, technical)
5. Code example (optional, brief)
6. "Key takeaway:" (1 sentence)
7. Links (GitHub + Blog)
8. Call to action question
9. 5-7 hashtags

**File naming:**
- Format: `LinkedIn_DayXX_[Topic]_EN.md`
- Example: `LinkedIn_Day02_Pagination_EN.md`

---

### ✅ README Format (English)

**Required Sections:**
1. Project name and Day X/30
2. Business Plan & Purpose
3. Technology Stack
4. Architecture & Best Practices
5. How to Run
6. API Endpoints
7. Testing Strategy
8. Success Metrics
9. Links (Business Plan, Blog article)

**Use Template:** `TEMPLATES/README_Template_EN.md`

---

### ✅ Business Plan Format (English)

**Required Sections:**
1. Problem Statement
2. Solution Overview
3. Architecture Decisions (with trade-offs table)
4. Technology Stack
5. Success Metrics
6. Learning Objectives

**Use Template:** `TEMPLATES/Business_Plan_Template_EN.md`

---

## 📁 Project Structure

```
30DiasJava/
├── day-01-user-profile-service/
│   ├── README.md (English)
│   ├── Business_Plan.md (English)
│   └── [code]
├── day-02-content-catalog-api/
│   ├── README.md (English)
│   ├── Business_Plan.md (English)
│   └── [code]
├── TEMPLATES/
│   ├── Blog_Post_Template.md (English, based on Day 2)
│   ├── LinkedIn_Post_Template_English.md (Based on Day 2)
│   ├── README_Template_EN.md (English)
│   └── Business_Plan_Template_EN.md (English)
├── LINKEDIN_POSTS/
│   ├── LinkedIn_Day01_Launch_EN.md (English)
│   ├── LinkedIn_Day02_Pagination_EN.md (English, MODEL)
│   └── [Future days]
└── THE_JAVA_PLACE/
    └── _posts/
        ├── 2025-11-01-dtos-under-the-hood.md (English, standardized)
        └── 2025-11-02-pagination-under-the-hood.md (English, MODEL)
```

---

## ✅ Completed Standardization

### Blog Posts
- ✅ Day 1: Updated to English title, improved consistency
- ✅ Day 2: Model format (reference for future posts)
- ✅ Template created: `Blog_Post_Template.md`

### LinkedIn Posts
- ✅ Day 1: English version created
- ✅ Day 2: English version created (MODEL)
- ✅ Template created: `LinkedIn_Post_Template_English.md`

### Templates
- ✅ Blog Post Template (English)
- ✅ LinkedIn Post Template (English)
- ✅ README Template (English)
- ✅ Business Plan Template (English)

### Documentation
- ✅ README_EN.md (English version)
- ✅ Project organization guidelines

---

## 🎯 Next Steps for Future Days

### For Each New Day (Follow This Sequence):

1. **Build & Document (GitHub):**
   - Use `README_Template_EN.md` for README
   - Use `Business_Plan_Template_EN.md` for Business Plan
   - Push to `30DiasJava-DayXX-ProjectName`

2. **Write Deep-Dive (Blog):**
   - Use `Blog_Post_Template.md` for blog article
   - Include "Under the Hood" section
   - Link to GitHub project
   - Publish on enouveau.io

3. **Create LinkedIn Post:**
   - Use `LinkedIn_Post_Template_English.md`
   - Include GitHub link
   - Include blog link
   - Share key insight
   - Post at optimal time (9-11 AM or 3-5 PM)

### Content Ecosystem Rule:
- **LinkedIn** = Teaser + Engagement (links to GitHub + Blog)
- **Blog** = Complete Explanation + Technical Details
- **GitHub** = Code + Ready-to-Study Project

### Quality Checklist:
   - ✅ All text in English
   - ✅ Technical accuracy
   - ✅ Code examples
   - ✅ Performance comparisons
   - ✅ Trade-offs table
   - ✅ **Links to GitHub AND blog in LinkedIn post**
   - ✅ Proper hashtags

---

## 📝 File Naming Conventions

### Blog Posts
- `YYYY-MM-DD-[topic]-under-the-hood.md`
- All lowercase with hyphens
- English only

### LinkedIn Posts
- `LinkedIn_DayXX_[Topic]_EN.md`
- PascalCase for topic
- `_EN` suffix for English

### Project READMEs
- `README.md` (always English)

### Business Plans
- `Business_Plan.md` (always English)

---

**Last Updated:** November 2, 2025  
**Model Reference:** Day 2 (Content-Catalog-API & Pagination article)

