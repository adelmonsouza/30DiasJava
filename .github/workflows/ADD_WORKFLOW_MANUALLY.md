# 🔧 Add Pre-GoLive Workflow Manually

Due to GitHub OAuth App permissions, the workflow file needs to be added manually.

## Steps

1. Go to: https://github.com/adelmonsouza/30DiasJava

2. Navigate to: `.github/workflows/pre-golive.yml`

3. Click "Create new file"

4. Copy the content from `scripts/pre-golive.yml.backup` or use this template:

```yaml
name: Pre-GoLive Validation

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]
  workflow_dispatch:
    inputs:
      project:
        description: 'Specific project to validate (leave empty for all)'
        required: false
        type: string

jobs:
  validate:
    name: Pre-GoLive Checks
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Set up Java
        uses: actions/setup-java@v4
        with:
          java-version: '21'
          distribution: 'temurin'
          cache: 'maven'
      
      - name: Run Pre-GoLive Script
        run: |
          chmod +x pre-golive.sh
          ./pre-golive.sh "${{ github.event.inputs.project }}"
```

5. Commit the file

Alternatively, you can use a Personal Access Token (PAT) with `workflow` scope to push directly.


