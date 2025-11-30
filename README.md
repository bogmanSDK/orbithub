# OrbitHub 🚀

**AI-powered DevOps automation tool for Jira workflows**

OrbitHub is a complete Jira automation framework written in Dart. It provides a powerful CLI and library for automating Jira workflows, with AI integration for intelligent ticket processing and GitHub Actions automation.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Dart Version](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev)

## 🌟 Features

- ✅ **Complete Jira REST API** - Full implementation of Jira Cloud API v3
- ✅ **Powerful CLI** - Command-line interface for all operations
- ✅ **JQL Search** - Advanced ticket searching with pagination
- ✅ **Ticket Management** - Create, read, update, delete tickets
- ✅ **Subtask Management** - Create and manage subtasks
- ✅ **Comments** - Add and retrieve comments
- ✅ **Workflow Transitions** - Move tickets through statuses
- ✅ **Labels & Assignments** - Manage labels and assignees
- ✅ **Native Executables** - Compile to standalone binaries (no runtime!)
- ✅ **AI Integration** - OpenAI/Claude for intelligent ticket analysis
- ✅ **Structured Questions** - Background, Question, Options, Decision format
- ✅ **GitHub Actions** - Automated workflows with Jira integration
- 🔄 **Code Generation** - (Coming soon) AI-powered implementation plans

## 🎯 Why OrbitHub?

### Why Dart?

1. **Native Binaries** - No JVM required, single executable
2. **Modern Async/Await** - Clean, readable asynchronous code
3. **Null Safety** - Built into the type system
4. **Fast Startup** - Instant execution, perfect for CLI
5. **Flutter Integration** - Share code with desktop/mobile UI
6. **Smaller Footprint** - Lightweight and fast

## 🚀 Quick Start

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/orbithub.git
cd orbithub

# Install dependencies
dart pub get

# Build native executable
dart compile exe bin/orbit.dart -o orbit

# Move to PATH (optional)
sudo mv orbit /usr/local/bin/
```

### Configuration

**Option 1: Using .env file (Recommended)**

Copy the template and edit with your credentials:

```bash
# Copy template
cp orbithub.env .env

# Edit .env with your actual credentials
nano .env
```

Or create `.env` file directly:

```bash
# .env
JIRA_BASE_PATH=https://your-company.atlassian.net
JIRA_EMAIL=your-email@company.com
JIRA_API_TOKEN=your_api_token_here
```

**Option 2: Using environment variables**

```bash
export JIRA_BASE_PATH="https://your-company.atlassian.net"
export JIRA_EMAIL="your-email@company.com"
export JIRA_API_TOKEN="your_api_token_here"
```

**Get your API token:** https://id.atlassian.com/manage-profile/security/api-tokens

> OrbitHub will check `.env` file first, then fall back to environment variables

### Basic Usage

```bash
# Get a ticket
orbit ticket --get PROJ-123

# Search tickets
orbit search --jql "project = PROJ AND status = 'In Progress'"

# Create a ticket
orbit ticket --create \
  --project PROJ \
  --type Task \
  --summary "New feature" \
  --description "Implement new functionality"

# Add comment
orbit comment --ticket PROJ-123 --post "Work completed"

# Create subtask
orbit subtask --parent PROJ-123 --create "Implement backend"

# Move to status
orbit transition --ticket PROJ-123 --status "In Progress"
```

## 📚 Documentation

- [Usage Guide](USAGE.md) - Complete CLI and API documentation
- [Examples](example/) - Code examples and workflows
  - [basic_usage.dart](example/basic_usage.dart) - Basic operations
  - [ai_teammate_workflow.dart](example/ai_teammate_workflow.dart) - AI-powered automation
  - [advanced_search.dart](example/advanced_search.dart) - JQL search examples

## 🔧 Programmatic Usage

```dart
import 'package:orbithub/orbithub.dart';

void main() async {
  // Initialize Jira client
  final config = JiraConfig.fromEnvironment();
  final jira = JiraClient(config);

  // Get a ticket
  final ticket = await jira.getTicket('PROJ-123');
  print('Title: ${ticket.title}');
  print('Status: ${ticket.statusName}');

  // Search tickets
  final results = await jira.searchTickets(
    'assignee = currentUser() AND status != Done',
  );
  print('Found ${results.total} tickets');

  // Create a ticket
  final newTicket = await jira.createTicket(
    projectKey: 'PROJ',
    issueType: 'Task',
    summary: 'Automated task',
    description: 'Created by OrbitHub',
  );
  print('Created: ${newTicket.key}');

  // Add comment
  await jira.postComment(newTicket.key, 'Ticket created successfully');

  // Create subtask
  await jira.createSubtask(
    parentKey: newTicket.key,
    summary: 'Subtask 1',
  );

  // Move to status
  await jira.moveToStatus(newTicket.key, 'In Progress');
}
```

## 🤖 AI Teammate Workflow

OrbitHub supports automated ticket analysis and question generation:

```dart
// 1. Get ticket
final ticket = await jira.getTicket('PROJ-123');

// 2. Generate questions with AI (coming soon)
final questions = await aiAnalyzer.generateQuestions(ticket);

// 3. Create subtasks for each question
for (final question in questions) {
  await jira.createSubtask(
    parentKey: ticket.key,
    summary: question,
  );
}

// 4. Assign for review
await jira.assignTicket(ticket.key, reviewerId);
await jira.moveToStatus(ticket.key, 'In Review');
```

See [example/ai_teammate_workflow.dart](example/ai_teammate_workflow.dart) for complete implementation.

## 🏗️ Architecture

```
orbithub/
├── lib/
│   ├── core/
│   │   └── jira/
│   │       ├── jira_client.dart      # Main Jira REST client
│   │       ├── jira_config.dart      # Configuration
│   │       ├── models/               # Data models
│   │       └── exceptions/           # Error handling
│   └── orbithub.dart                 # Library export
│
├── bin/
│   └── orbit.dart                    # CLI entry point
│
├── example/
│   ├── basic_usage.dart              # Basic examples
│   ├── ai_teammate_workflow.dart     # AI workflow
│   └── advanced_search.dart          # Search examples
│
└── test/                             # Unit tests
```

## 🎯 API Coverage

OrbitHub implements all major Jira REST API operations:

### Tickets
- ✅ Get ticket
- ✅ Search with JQL (paginated)
- ✅ Create ticket
- ✅ Update ticket
- ✅ Delete ticket
- ✅ Assign ticket
- ✅ Add labels

### Subtasks
- ✅ Get subtasks
- ✅ Create subtask

### Comments
- ✅ Get comments
- ✅ Post comment
- ✅ Post comment if not exists

### Workflow
- ✅ Get transitions
- ✅ Move to status
- ✅ Move with resolution

### Project Metadata
- ✅ Get components
- ✅ Get fix versions
- ✅ Get issue types
- ✅ Set/add/remove fix version
- ✅ Set priority

### Users
- ✅ Get my profile
- ✅ Get user profile
- ✅ Get account by email

## 🛠️ Development

### Run Examples

```bash
# Set environment variables
export JIRA_BASE_PATH="https://your-company.atlassian.net"
export JIRA_EMAIL="your@email.com"
export JIRA_API_TOKEN="your_token"

# Run basic usage example
dart run example/basic_usage.dart

# Run AI teammate workflow
dart run example/ai_teammate_workflow.dart

# Run advanced search
dart run example/advanced_search.dart
```

### Run Tests

```bash
dart test
```

### Build

```bash
# Compile to native executable
dart compile exe bin/orbit.dart -o orbit

# For specific platform
dart compile exe bin/orbit.dart -o orbit-macos  # macOS
dart compile exe bin/orbit.dart -o orbit.exe    # Windows
```

## 📋 Roadmap

- [x] Jira REST API implementation
- [x] CLI tool
- [x] JQL search with pagination
- [x] Complete ticket management
- [x] Subtasks and comments
- [x] Workflow transitions
- [ ] AI integration (OpenAI/Claude)
- [ ] GitHub integration
- [ ] Flutter desktop UI
- [ ] Flutter mobile app
- [ ] Confluence integration
- [ ] CI/CD integration (GitHub Actions)

## 🤝 Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 📞 Contact

- Issues: [GitHub Issues](https://github.com/yourusername/orbithub/issues)
- Discussions: [GitHub Discussions](https://github.com/yourusername/orbithub/discussions)

---

**Made with ❤️ and Dart**
