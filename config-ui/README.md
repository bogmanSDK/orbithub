# OrbitHub Configuration UI

Desktop application for configuring OrbitHub settings on Windows and macOS.

## Features

- **Jira Configuration**: Configure Jira instance URL, email, API token, and settings
- **AI Configuration**: Set up AI provider (OpenAI/Claude), API keys, and model settings
- **Advanced Settings**: Configure Cursor API, MCP tools, and other advanced options
- **Auto-save**: Automatically reads and writes to `.env` file
- **Validation**: Validates required fields before saving

## Usage

### Running the App

```bash
cd config-ui
flutter run -d macos    # For macOS
flutter run -d windows  # For Windows
```

### Configuration File Location

The app looks for `.env` file in the following order:
1. Current working directory (where you run the app)
2. Parent directory (orbithub root)
3. Application support directory (`~/.orbithub/.env`)

### Configuration Structure

The app reads and writes to `.env` file with the following structure:

```env
# Jira Configuration
JIRA_BASE_PATH=https://company.atlassian.net
JIRA_EMAIL=your-email@domain.com
JIRA_API_TOKEN=your-api-token
JIRA_SEARCH_MAX_RESULTS=100
JIRA_LOGGING_ENABLED=false

# AI Configuration
AI_PROVIDER=openai
AI_API_KEY=your-ai-api-key
AI_MODEL=gpt-4
AI_TEMPERATURE=0.7
AI_MAX_TOKENS=2000

# Cursor Configuration
CURSOR_API_KEY=your-cursor-api-key

# Advanced Settings
USE_MCP_TOOLS=false
DISABLE_JIRA_COMMENTS=false
```

## Development

### Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── config_model.dart     # Configuration data model
├── services/
│   └── config_service.dart   # Config file operations
├── screens/
│   ├── home_screen.dart      # Main screen with tabs
│   ├── jira_config_screen.dart
│   ├── ai_config_screen.dart
│   └── advanced_config_screen.dart
├── widgets/
│   ├── config_text_field.dart
│   ├── config_section.dart
│   └── save_button.dart
└── utils/
    └── env_parser.dart       # .env file parser
```

### Building for Release

```bash
# macOS
flutter build macos

# Windows
flutter build windows
```

## Notes

- This app is created locally and not pushed to remote repository
- The app reads/writes to the same `.env` file used by OrbitHub CLI
- All configuration is stored locally in the `.env` file
- UI state (like selected tab) is stored in shared_preferences
