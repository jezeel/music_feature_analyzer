# Contributing to Music Feature Analyzer

Thank you for your interest in contributing to the Music Feature Analyzer package! This document provides guidelines and information for contributors.

## 🚀 Getting Started

### Prerequisites
- Flutter 3.0.0 or higher
- Dart 3.8.1 or higher
- Git
- A code editor (VS Code, Android Studio, etc.)

### Setting Up the Development Environment

1. **Fork the repository**
   ```bash
   # Fork the repository on GitHub, then clone your fork
   git clone https://github.com/yourusername/music_feature_analyzer.git
   cd music_feature_analyzer
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run tests**
   ```bash
   flutter test
   ```

4. **Generate code**
   ```bash
   flutter packages pub run build_runner build
   ```

## 📝 How to Contribute

### Reporting Issues
- Use the [GitHub Issues](https://github.com/jezeel/music_feature_analyzer/issues) page
- Provide a clear description of the issue
- Include steps to reproduce the problem
- Specify your Flutter/Dart version
- Include relevant code snippets

### Suggesting Features
- Use the [GitHub Issues](https://github.com/jezeel/music_feature_analyzer/issues) page
- Clearly describe the feature you'd like to see
- Explain why this feature would be useful
- Provide examples of how it might work

### Submitting Code Changes

1. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Follow the existing code style
   - Add tests for new functionality
   - Update documentation as needed

3. **Run tests and checks**
   ```bash
   flutter test
   flutter analyze
   flutter packages pub run build_runner build
   ```

4. **Commit your changes**
   ```bash
   git add .
   git commit -m "Add: Brief description of your changes"
   ```

5. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Create a Pull Request**
   - Go to the [GitHub repository](https://github.com/jezeel/music_feature_analyzer)
   - Click "New Pull Request"
   - Select your feature branch
   - Provide a clear description of your changes

## 🎯 Development Guidelines

### Code Style
- Follow Dart/Flutter conventions
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused
- Use proper error handling

### Testing
- Write tests for new functionality
- Ensure all existing tests pass
- Aim for high test coverage
- Test edge cases and error conditions

### Documentation
- Update README.md for significant changes
- Add code comments for complex logic
- Update CHANGELOG.md for new features
- Include examples in documentation

### Commit Messages
Use clear, descriptive commit messages:
- `Add: New feature description`
- `Fix: Bug description`
- `Update: Change description`
- `Remove: Removal description`
- `Docs: Documentation update`

## 🏗️ Project Structure

```
lib/
├── music_feature_analyzer.dart          # Main package export
├── src/
│   ├── music_feature_analyzer_base.dart # Core analyzer class
│   ├── models/                          # Data models
│   ├── services/                        # Core services
│   └── utils/                           # Utility functions
test/                                    # Test files
assets/models/                           # AI model assets
```

## 🧪 Testing

### Running Tests
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/music_feature_analyzer_test.dart
```

### Writing Tests
- Test all public methods
- Test error conditions
- Test edge cases
- Use descriptive test names
- Group related tests

## 📦 Building and Publishing

### Local Testing
```bash
# Build the package
flutter packages pub run build_runner build

# Test the package locally
flutter test
```

### Publishing
- Update version in `pubspec.yaml`
- Update `CHANGELOG.md`
- Create a release tag
- Follow semantic versioning

## 🤝 Community Guidelines

### Be Respectful
- Be kind and respectful to other contributors
- Welcome newcomers and help them learn
- Provide constructive feedback
- Respect different opinions and approaches

### Be Collaborative
- Work together to improve the project
- Share knowledge and best practices
- Help others when you can
- Ask questions when you need help

### Be Professional
- Keep discussions focused on the project
- Avoid personal attacks or off-topic discussions
- Follow the code of conduct
- Maintain a positive attitude

## 📞 Getting Help

- **Documentation**: Check the README.md and code comments
- **Issues**: Use GitHub Issues for bugs and feature requests
- **Discussions**: Use GitHub Discussions for questions and ideas
- **Email**: Contact the maintainers if needed

## 🎉 Recognition

Contributors will be recognized in:
- CONTRIBUTORS.md file
- Release notes
- Project documentation
- GitHub contributors list

Thank you for contributing to Music Feature Analyzer! 🎵
