# LifeQuest Quick Start Guide

## 🚀 You're All Set Up!

### What We Configured

✅ **Claude Code Integration**
- Configuration file: `.clauderc`
- Project context: `.claude/context.md`
- Task definitions: `.claude/tasks.md`

✅ **Deployment System**
- Automated script: `scripts/deploy-to-manus.ps1`
- Multiple deployment methods supported
- Verification and error handling

✅ **Helper Script**
- Interactive menu: `lifequest-helper.ps1`
- Quick access to all commands

---

## 🎯 Quick Commands

### Using the Helper Script (Easiest)

```powershell
cd C:\Users\wsk\Documents\lqq\Life-Quest-Alpha-df
pwsh lifequest-helper.ps1
```

Then select from menu:
- 1 = Deploy to Manus
- 2 = Build web version
- 3 = Run locally
- 6 = Claude Code chat
- 7 = Ask Claude anything

### Using Claude Code Directly

```bash
# Navigate to project
cd C:\Users\wsk\Documents\lqq\Life-Quest-Alpha-df

# Deploy
claude task deploy

# Chat mode
claude chat

# Quick question
claude "How do I add a new feature?"
```

### Manual Deployment

```powershell
cd C:\Users\wsk\Documents\lqq\Life-Quest-Alpha-df
pwsh scripts\deploy-to-manus.ps1
```

---

## 📋 Next: Complete Manus Setup

**You need to:**

1. **Check Manus Dashboard** (should be open in browser)
   - Look for: API keys, CLI commands, or Git URLs
   
2. **Configure Deployment Method**

   **If you see API Keys:**
   ```powershell
   $env:MANUS_API_KEY = "paste-your-key-here"
   ```

   **If you see CLI instructions:**
   ```powershell
   npm install -g @manus/cli
   manus login
   ```

   **If you see Git URL:**
   ```powershell
   $env:MANUS_GIT_URL = "paste-git-url-here"
   ```

3. **Test Deployment**
   ```powershell
   pwsh scripts\deploy-to-manus.ps1
   ```

---

## 💡 Common Tasks

### Deploy Your App
```powershell
pwsh lifequest-helper.ps1
# Select option 1
```

### Ask Claude for Help
```bash
cd C:\Users\wsk\Documents\lqq\Life-Quest-Alpha-df
claude "Debug the 404 error on Manus"
```

### Develop New Feature
```bash
claude chat
> Implement AI quest generation using Anthropic API
```

### Check If Deployment Works
```powershell
pwsh lifequest-helper.ps1
# Select option 5
```

---

## 🆘 If Something Doesn't Work

**Deployment fails?**
1. Check Manus dashboard for logs
2. Verify environment variables are set
3. Try manual upload as fallback

**Claude Code not responding?**
1. Ensure you're in project directory
2. Check `.clauderc` file exists
3. Try: `claude --version`

**Build fails?**
1. Run: `flutter clean`
2. Run: `flutter pub get`
3. Try building again

---

## 📞 Get Help

**In this chat:**
- Just ask me! I can help debug, code, or deploy

**With Claude Code:**
```bash
claude "I need help with [your issue]"
```

**Check project context:**
```bash
cat .claude\context.md
```

---

## 🎉 You're Ready!

**Right now, you can:**
- ✅ Use Claude Code for development
- ✅ Deploy to Manus (once configured)
- ✅ Run helper scripts
- ✅ Ask AI for help anytime

**Next step:**
Tell me what you see in the Manus dashboard, and I'll help you complete the deployment setup!

---

**Project Location:**
`C:\Users\wsk\Documents\lqq\Life-Quest-Alpha-df`

**Deployment URL:**
`https://lifequest-dduv2x5v.manus.space`

**Status:**
🟡 Ready to deploy (awaiting Manus configuration)
