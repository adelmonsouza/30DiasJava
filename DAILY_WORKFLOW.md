# 🔄 Daily Workflow - #30DiasJava

**Standard sequence for each day of the challenge**

---

## 📅 Day X Workflow

### Phase 1: Development (Morning)

**Time:** 2-4 hours

1. **Create Project Structure**
   ```bash
   # Create new Spring Boot project
   # Use Spring Initializr or copy from template
   ```

2. **Implement Core Features**
   - Models/Entities
   - DTOs
   - Repository
   - Service
   - Controller
   - Exception handling

3. **Add Tests**
   - Unit tests (Service layer)
   - Integration tests (Controller layer)
   - Testcontainers for database tests

4. **Configure Infrastructure**
   - Docker Compose (PostgreSQL, etc.)
   - Application properties
   - CI/CD workflow

---

### Phase 2: Documentation (Afternoon)

**Time:** 1-2 hours

1. **Write README.md**
   - Use `TEMPLATES/README_Template_EN.md`
   - Include: stack, architecture, how to run
   - Link to Business Plan

2. **Write Business_Plan.md**
   - Use `TEMPLATES/Business_Plan_Template_EN.md`
   - Include: problem, solution, architecture decisions
   - Explain the "why" behind technical choices

3. **Commit & Push to GitHub**
   ```bash
   git add .
   git commit -m "feat: Day X - [Project Name]"
   git push origin main
   ```

4. **Create GitHub Repository**
   - Repository name: `30DiasJava-DayXX-ProjectName`
   - Add topics (java, spring-boot, etc.)
   - Update main README.md with link

---

### Phase 3: Content Creation (Evening)

**Time:** 2-3 hours

1. **Write Blog Article**
   - Use `TEMPLATES/Blog_Post_Template.md`
   - Follow Day 2 model
   - Include "Under the Hood" section
   - Add code examples and performance comparisons
   - Link to GitHub project

2. **Publish on Blog**
   - File: `_posts/YYYY-MM-DD-[topic]-under-the-hood.md`
   - Commit and push to `adelmonsouza.github.io`
   - Verify on enouveau.io

3. **Create LinkedIn Post**
   - Use `TEMPLATES/LinkedIn_Post_Template_English.md`
   - Include GitHub link
   - Include blog link
   - Share key insight/learning
   - Add call-to-action question

4. **Schedule LinkedIn Post**
   - Best times: 9-11 AM or 3-5 PM
   - Use LinkedIn scheduler or post immediately

---

## ✅ Daily Checklist

### Before Posting on LinkedIn:

- [ ] Code complete and pushed to GitHub
- [ ] README.md complete and informative
- [ ] Business_Plan.md explains decisions
- [ ] Tests passing (≥80% coverage)
- [ ] CI/CD working
- [ ] Blog article published on enouveau.io
- [ ] LinkedIn post includes:
  - [ ] GitHub repository link
  - [ ] Blog article link
  - [ ] Key insight/learning
  - [ ] Call-to-action question
  - [ ] Proper hashtags (5-7)

---

## 📊 Content Linking Template

### LinkedIn Post Must Include:

```
🚀 Day X/30 of #30DiasJava: [Title]

[Opening paragraph - what I learned]

**What I built today:**
[Project description]

**Why this matters:**
[Real-world connection]

**Under the Hood:**
[Brief technical explanation]

**Key takeaway:**
[One powerful insight]

🔗 Full project: github.com/adelmonsouza/30DiasJava-DayXX-ProjectName
📖 Deep-dive article: enouveau.io/blog/YYYY/MM/DD/article.html

[Call-to-action question]

#Java #SpringBoot #30DiasJava #[Concept] #[Technology] #AdelmoDev
```

---

## 🎯 Content Hierarchy Reminder

| Platform | Purpose | Links To |
|----------|---------|----------|
| **LinkedIn** | Teaser + Engagement | GitHub + Blog |
| **Blog** | Deep-dive + Technical | GitHub (code examples) |
| **GitHub** | Complete Code | Blog (README mentions article) |

**All three platforms cross-reference each other!**

---

## ⏰ Time Allocation Example

**Total: 6-9 hours per day**

- **Development:** 3-4 hours (40-50%)
- **Documentation:** 1-2 hours (15-20%)
- **Content Creation:** 2-3 hours (30-35%)

**Note:** As you get faster, content creation becomes the bottleneck. Reuse templates and structures!

---

## 🔗 Quick Links Reference

- **Blog:** https://enouveau.io
- **GitHub Org:** https://github.com/adelmonsouza
- **Main Repo:** https://github.com/adelmonsouza/30DiasJava
- **Templates:** `TEMPLATES/` folder

---

**Follow this workflow consistently for all 30 days!**

**Last Updated:** November 2, 2025

