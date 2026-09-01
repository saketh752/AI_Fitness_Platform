# Contributing to AI Fitness Platform

Thank you for your interest in contributing to the **AI Fitness Platform**! We welcome community contributions, bug reports, and feature proposals.

---

## Code of Conduct
Please be respectful, collaborative, and constructive when interacting in issues and pull requests.

---

## How Can I Contribute?

### 1. Reporting Bugs
- Check the [Issues tab](https://github.com/saketh752/AI_Fitness_Platform/issues) to ensure the bug hasn't already been reported.
- Open a new issue using our **Bug Report template**.
- Include clear reproduction steps, screenshots/logs, and your environment (OS, Flutter version, etc.).

### 2. Suggesting Features
- Open a new issue using our **Feature Request template**.
- Explain the user problem and propose an implementation approach.

### 3. Submitting Pull Requests
1. Fork the repository and create your branch from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```
2. Ensure your changes adhere to clean architecture patterns.
3. Run automated tests to verify nothing is broken:
   ```bash
   # Flutter Tests
   cd ai_fitness_app && flutter test

   # Python AI Agent Tests
   cd ai-agent && pytest tests

   # Spring Boot Tests
   cd ai-fitness-Backend && ./mvnw test
   ```
4. Commit with descriptive messages (e.g. `feat: add pose angle smoothing for lunge exercises`).
5. Open a Pull Request referencing the related issue.

---

## Coding Standards
- **Flutter**: Follow official Effective Dart style guides.
- **Java**: Follow Google Java Style guidelines and Spring Boot conventions.
- **Python**: Follow PEP 8 and use Pydantic type annotations.

---

Thank you for helping make the AI Fitness Platform better! 🏋️‍♂️

