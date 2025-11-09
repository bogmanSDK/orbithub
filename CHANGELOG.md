# Changelog

All notable changes to OrbitHub will be documented in this file.

## [1.1.0] - 2025-11-07

### Added - .env File Support 🎉

#### New Features
- ✅ **`.env` file support** - No more need to export environment variables!
- ✅ **Automatic configuration loading** - Checks `.env` file first, then falls back to environment variables
- ✅ **Setup script** (`setup.sh`) - One-command setup for OrbitHub
- ✅ **Comprehensive documentation** (`ENV_SETUP.md`) - Complete guide for configuration

#### What Changed

**Before (Required exports):**
```bash
export JIRA_BASE_PATH="https://your-company.atlassian.net"
export JIRA_EMAIL="your@email.com"
export JIRA_API_TOKEN="your_token"

dart run bin/orbit.dart ticket --get PROJ-123
```

**After (Just use .env file):**
```bash
# Create .env file once
cat > .env << 'EOF'
JIRA_BASE_PATH=https://your-company.atlassian.net
JIRA_EMAIL=your@email.com
JIRA_API_TOKEN=your_token
EOF

# Run without exports!
dart run bin/orbit.dart ticket --get PROJ-123
```

#### Files Modified

1. **`lib/core/jira/jira_config.dart`**
   - Added `import 'package:dotenv/dotenv.dart'`
   - Updated `fromEnvironment()` to check `.env` file first
   - Added fallback to environment variables
   - Improved error messages

2. **`README.md`**
   - Added `.env` file documentation
   - Updated configuration section
   - Added priority information

3. **`QUICKSTART.md`**
   - Updated Step 3 with `.env` file instructions
   - Added detailed API token instructions
   - Added configuration priority explanation

#### New Files

1. **`setup.sh`** - Interactive setup script
   - Installs dependencies
   - Creates `.env` file
   - Optionally builds native executable
   - Optionally installs to system PATH

2. **`ENV_SETUP.md`** - Complete configuration guide
   - Step-by-step instructions
   - Troubleshooting section
   - Security best practices
   - Example configurations

#### Configuration Priority

OrbitHub now checks configuration in this order:
1. **`.env` file** (if exists) ✅ **NEW**
2. **Environment variables** (fallback)

#### Benefits

- ✅ **Easier setup** - No need to remember export commands
- ✅ **Project-specific** - Each project can have its own `.env`
- ✅ **Secure** - `.env` is in `.gitignore` (never committed)
- ✅ **Flexible** - Still supports environment variables
- ✅ **Developer-friendly** - Standard practice for modern tools

#### Security

- `.env` file is already in `.gitignore`
- Never committed to version control
- Project-local configuration
- Works with team sharing (use `.env.template`)

---

## [1.0.0] - 2025-11-07

### Initial Release - Complete Jira Implementation 🚀

#### Features
- ✅ Complete Jira REST API client
- ✅ 40+ methods for ticket management
- ✅ JQL search with automatic pagination
- ✅ Subtask management
- ✅ Comment management
- ✅ Workflow transitions
- ✅ Labels, priorities, fix versions
- ✅ User management
- ✅ Project metadata

#### Components
- **CLI Tool** - Command-line interface
- **Dart Library** - Importable package
- **13 Data Models** - Type-safe JSON serialization
- **Error Handling** - Custom exception hierarchy

#### Documentation
- README.md - Project overview
- QUICKSTART.md - 5-minute setup
- USAGE.md - Complete reference
- IMPLEMENTATION_SUMMARY.md - Technical details
- 3 working examples

#### Architecture
- Native executable support
- ~2,500 lines of code
- Zero compile errors
- Modern async/await patterns
- Null-safe type system

---

## Upgrade Guide

### From 1.0.0 to 1.1.0

No breaking changes! Your existing code will continue to work.

**Optional: Switch to .env file**

1. Create `.env` file:
```bash
./setup.sh
```

2. Remove exports from shell profile (optional):
```bash
# Can remove these from ~/.bashrc or ~/.zshrc
# export JIRA_BASE_PATH=...
# export JIRA_EMAIL=...
# export JIRA_API_TOKEN=...
```

3. That's it! Continue using OrbitHub as before.

---

## Future Roadmap

### Version 1.2.0 (Planned)
- [ ] AI integration (OpenAI/Claude)
- [ ] Automated ticket analysis
- [ ] Question generation
- [ ] Smart suggestions

### Version 1.3.0 (Planned)
- [ ] GitHub integration
- [ ] Repository operations
- [ ] Pull request management

### Version 2.0.0 (Planned)
- [ ] Flutter desktop UI
- [ ] Flutter mobile app
- [ ] Visual ticket management
- [ ] Drag-and-drop workflows

---

**Version 1.1.0 Status:** ✅ Complete and tested


