# 🤖 Как работает AI Teammate

Полное объяснение работы AI Teammate в OrbitHub.

---

## 🎯 Обзор системы

```
┌─────────────┐
│    JIRA     │  ← Ты создаешь тикет, назначаешь на AI Agent
└──────┬──────┘
       │
       ↓
┌─────────────────────┐
│  JIRA AUTOMATION    │  ← Видит: Assignee=AI + Status=To Do
└──────┬──────────────┘
       │ Webhook
       ↓
┌─────────────────────┐
│  GITHUB ACTIONS     │  ← Запускает workflow
└──────┬──────────────┘
       │ Runs
       ↓
┌─────────────────────┐
│   AI TEAMMATE       │  ← Обрабатывает тикет
│   (OrbitHub)        │
└──────┬──────────────┘
       │ Updates
       ↓
┌─────────────┐
│    JIRA     │  ← Добавляет комментарии, меняет статус
└─────────────┘
```

---

## 📝 Пошаговый процесс

### **ПЕРВЫЙ ЦИКЛ: AI создает вопросы**

#### **Шаг 1: Ты создаешь тикет**

В Jira:
```
Ticket: AIH-1
Title: "Добавить темную тему"
Type: Story
Assignee: Igor AI Agent
Status: To Do
Description: "Приложению нужна темная тема для лучшего UX"
```

#### **Шаг 2: Jira Automation срабатывает**

Правило видит:
- ✅ Assignee = "Igor AI Agent"
- ✅ Status = "To Do"

Отправляет webhook:
```bash
curl -X POST \
  https://api.github.com/repos/serhii-bohush/orbithub/dispatches \
  -H "Authorization: Bearer YOUR_GITHUB_PAT" \
  -H "Content-Type: application/json" \
  -d '{
    "event_type": "ai-teammate-trigger",
    "client_payload": {
      "ticket_key": "AIH-1"
    }
  }'
```

#### **Шаг 3: GitHub Actions запускается**

GitHub получает webhook и запускает `.github/workflows/ai-teammate.yml`:

```yaml
1. Создает Ubuntu VM
2. Устанавливает Dart SDK
3. Клонирует orbithub репозиторий
4. Запускает: dart pub get
5. Создает .env с JIRA credentials
6. Запускает: dart run bin/ai_teammate.dart AIH-1
```

#### **Шаг 4: AI Teammate обрабатывает тикет**

**bin/ai_teammate.dart** выполняет:

```dart
📥 Step 1: Fetching ticket AIH-1
   Title: Добавить темную тему
   Status: To Do
   Assignee: Igor AI Agent

📋 Step 2: Checking for existing questions...
   ℹ️  No existing questions found

🔍 Step 3: Analyzing ticket to generate questions...
   ⚠️  AI integration not yet implemented
   📝 TODO: Call OpenAI/Claude to analyze ticket

💡 For now, create questions manually
```

**Сейчас (пока нет AI)**: Нужно вручную создать subtasks с вопросами.

**В будущем (когда добавим AI)**: AI автоматически проанализирует тикет и создаст вопросы:

```dart
🤖 AI analyzing ticket...
   Reading description...
   Checking codebase...
   
📝 Generated 3 questions:
   1. What color values for dark theme?
   2. Should it be default or opt-in?
   3. Any accessibility requirements?

✅ Creating subtasks...
   Created: AIH-2 (Question 1)
   Created: AIH-3 (Question 2)
   Created: AIH-4 (Question 3)

💬 Posting comment to AIH-1
🔄 Moving to "In Progress"
```

---

### **ВТОРОЙ ЦИКЛ: AI проверяет ответы**

#### **Шаг 5: Ты отвечаешь на вопросы**

Открываешь каждый subtask и добавляешь комментарии:

**AIH-2**: "❓ What color values for dark theme?"
```
Комментарий:
Primary: #1a1a1a
Text: #ffffff
Accent: #0066cc
```

**AIH-3**: "❓ Should it be default or opt-in?"
```
Комментарий:
Make it opt-in with a toggle in settings
```

**AIH-4**: "❓ Any accessibility requirements?"
```
Комментарий:
Follow WCAG 2.1 AA standards, minimum contrast ratio 4.5:1
```

#### **Шаг 6: Ты запускаешь AI снова**

В Jira для тикета AIH-1:
```
1. Assignee → Igor AI Agent
2. Status → To Do
```

#### **Шаг 7: Jira Automation → GitHub Actions → AI Teammate**

Тот же процесс, но теперь AI Teammate видит ответы:

```dart
📥 Step 1: Fetching ticket AIH-1
   Title: Добавить темную тему
   Status: To Do
   Assignee: Igor AI Agent

📋 Step 2: Checking for existing questions...
   ✅ Found 3 existing question(s)
      - AIH-2: What color values?
      - AIH-3: Default or opt-in?
      - AIH-4: Accessibility requirements?

🔍 Step 3: Checking if questions have been answered...
   Progress: 3/3 answered
   Completion: 100%

📊 Step 4: Answer status:
   ✅ AIH-2: Answered by Serhii Bohush
   ✅ AIH-3: Answered by Serhii Bohush
   ✅ AIH-4: Answered by Serhii Bohush

🎯 Step 5: All questions answered! ✅

📝 Step 6: Collecting answers...
   Question 1: Primary: #1a1a1a, Text: #ffffff...
   Question 2: Make it opt-in with toggle...
   Question 3: WCAG 2.1 AA, contrast 4.5:1...

🤖 Step 7: Processing answers...
   ⚠️  AI implementation not yet available
   📝 TODO: Send to OpenAI/Claude:
      - Original ticket
      - All Q&A
      - Generate implementation plan
      - Create PR

💬 Step 8: Posting completion comment
   "🎉 All questions answered! Ready for implementation..."

🔄 Step 9: Moving to "In Progress"
   ✅ Status updated
```

---

## 🧪 Что работает СЕЙЧАС

### ✅ **Можно использовать:**

1. **Answer Checker** - проверка ответов на subtasks
   ```bash
   dart run test_ai_teammate.dart
   ```

2. **AI Teammate Script** - полный workflow
   ```bash
   dart run bin/ai_teammate.dart AIH-1
   ```

3. **GitHub Actions** - автоматический запуск
   ```
   Jira → webhook → GitHub → OrbitHub
   ```

4. **Status Comments** - AI постит статус в Jira
   ```
   "⏳ Waiting for 2 more answers..."
   "✅ All questions answered!"
   ```

5. **Status Transitions** - меняет статус тикетов
   ```
   To Do → In Progress
   ```

---

## ❌ Что НЕ работает (TODO)

1. **AI Question Generation** - нужно добавить OpenAI/Claude
   - Автоматический анализ тикета
   - Генерация умных вопросов
   - Создание subtasks

2. **AI Implementation** - нужно добавить Cursor/AI
   - Анализ ответов
   - Генерация кода
   - Создание PR
   - Запуск тестов

---

## 🔍 Как проверить, что работает?

### **Test 1: Answer Checker (локально)**

```bash
cd /Users/Serhii_Bohush/orbithub

# Создай subtasks для AIH-1 (если еще нет)
# Ответь на один из них в Jira
# Запусти:

dart run test_ai_teammate.dart
```

Должен увидеть:
```
📊 Results:
   Total questions: 3
   Answered: 1
   Progress: 33%

📋 Subtasks:
   ✅ AIH-2: Answered by Serhii Bohush
   ⏳ AIH-3: Waiting for answer
   ⏳ AIH-4: Waiting for answer
```

### **Test 2: AI Teammate (локально)**

```bash
dart run bin/ai_teammate.dart AIH-1
```

Должен увидеть:
```
🤖 OrbitHub AI Teammate
📋 Processing ticket: AIH-1
📥 Fetching ticket details...
📋 Checking for existing questions...
🔍 Checking if questions have been answered...
💬 Posting status comment...
✅ Done!
```

Проверь в Jira - должен появиться новый комментарий от API token user.

### **Test 3: GitHub Actions (manual trigger)**

1. Go to: https://github.com/YOUR_USERNAME/orbithub/actions
2. Select "AI Teammate" workflow
3. Click "Run workflow"
4. Enter: AIH-1
5. Click "Run workflow"

Должен увидеть:
```
✅ Workflow completed successfully
📋 Logs show: AI Teammate processed AIH-1
💬 Comment appeared in Jira
```

### **Test 4: Full Automation (с Jira Automation)**

После настройки Jira Automation rule:

1. В Jira, открой любой тикет (e.g., AIH-1)
2. Assignee → Igor AI Agent
3. Status → To Do
4. Смотри:
   - Project settings → Automation → Audit log ✅
   - GitHub → Actions → AI Teammate запустился ✅
   - Jira → Тикет → Новый комментарий появился ✅

---

## 📊 Архитектура

### **Файлы:**

```
orbithub/
├── lib/
│   ├── core/
│   │   └── jira/
│   │       ├── jira_client.dart       # API client
│   │       └── models/                # Data models
│   └── workflows/
│       └── answer_checker.dart        # ✨ NEW: Answer checker
│
├── bin/
│   └── ai_teammate.dart               # ✨ NEW: Main workflow
│
├── .github/
│   └── workflows/
│       └── ai-teammate.yml            # ✨ NEW: GitHub Actions
│
└── docs/
    ├── AI_TEAMMATE_SETUP.md           # Full setup guide
    ├── QUICK_START_AI_TEAMMATE.md     # Quick start
    └── HOW_IT_WORKS.md                # This file
```

### **Классы:**

```dart
// Answer Checker
class AnswerChecker {
  checkTicketAnswers(ticketKey)      // Проверяет все subtasks
  generateAnswerReport(status)        // Создает отчет
  collectAnswersForAI(status)         // Собирает текст для AI
}

class TicketAnswerStatus {
  totalQuestions                      // Всего вопросов
  answeredQuestions                   // Отвечено
  allAnswered                         // Все ли отвечены?
  completionRate                      // Процент завершения
}

class SubtaskAnswer {
  subtaskKey                          // Ключ subtask
  isAnswered                          // Есть ли ответ?
  answers                             // Список ответов
  answeredBy                          // Кто ответил
}
```

---

## 🎯 Следующие шаги

### **Фаза 1: Тестирование (сейчас)**

- [x] Создать answer checker
- [x] Создать AI Teammate script
- [x] Создать GitHub Actions workflow
- [ ] Протестировать локально
- [ ] Протестировать GitHub Actions manual trigger
- [ ] Настроить Jira Automation
- [ ] Протестировать full workflow

### **Фаза 2: AI Integration (скоро)**

- [ ] Добавить OpenAI/Claude API
- [ ] Генерация вопросов на основе тикета
- [ ] Анализ кодовой базы для контекста
- [ ] Автоматическое создание subtasks

### **Фаза 3: Implementation (позже)**

- [ ] Cursor API integration
- [ ] Автоматическая генерация кода
- [ ] Создание PR
- [ ] Запуск тестов
- [ ] Code review

---

## 💡 Советы

### **Для отладки:**

1. **Проверь Jira Automation logs:**
   ```
   Project settings → Automation → Audit log
   ```

2. **Проверь GitHub Actions logs:**
   ```
   GitHub → Actions → Workflow run → View logs
   ```

3. **Запусти локально с debug:**
   ```bash
   dart run bin/ai_teammate.dart AIH-1
   ```

### **Для продакшна:**

1. **Rate limits**: Jira API ~150 req/min, GitHub Actions ~1000 runs/month (free)
2. **Secrets rotation**: Меняй токены каждые 90 дней
3. **Error handling**: Workflow повторяется автоматически при ошибках
4. **Monitoring**: Смотри GitHub Actions summary для статистики

---

## ❓ FAQ

**Q: Можно ли запускать без GitHub Actions?**  
A: Да! Просто запускай `dart run bin/ai_teammate.dart TICKET-KEY` вручную.

**Q: Можно ли использовать другие CI/CD?**  
A: Да! Можно настроить GitLab CI, Jenkins, etc. Главное - запустить Dart script.

**Q: Нужен ли отдельный Jira user для AI?**  
A: Нет, но рекомендуется для ясности. API token может быть от любого user.

**Q: Сколько стоит запуск?**  
A: GitHub Actions free tier - 2000 минут/месяц. Один workflow ~2-5 минут.

**Q: Что если GitHub Actions упадет?**  
A: Можно перезапустить вручную из GitHub UI или локально.

---

## 🎉 Готово!

Теперь у тебя есть:

✅ **Answer Checker** - проверяет ответы на вопросы  
✅ **AI Teammate** - полный workflow script  
✅ **GitHub Actions** - автоматический запуск  
✅ **Jira Integration** - автоматический триггер  
✅ **Status Updates** - комментарии и переходы статусов  

**Следующий шаг**: Протестируй локально! 🚀

```bash
dart run test_ai_teammate.dart
```

