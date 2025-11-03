# AE Infinity Context

A centralized repository for managing context metadata and configuration for the AE Infinity project ecosystem.

## 🎯 Purpose

This repository serves as the source of truth for:
- Context definitions and schemas
- Metadata templates
- Configuration files
- Documentation for context management
- Shared resources across AE Infinity services

## 📁 Repository Structure

```
ae-infinity-context/
├── schemas/                 # JSON schemas for context definitions
├── metadata/               # Metadata templates and examples
├── config/                 # Configuration files
├── docs/                   # Documentation
└── README.md              # This file
```

## 🚀 Getting Started

### Clone the Repository

```bash
git clone https://github.com/rkSlalom/ae-infinity-context.git
cd ae-infinity-context
```

## 📋 Context Types

This repository manages various types of context metadata including:
- **User Context** - User preferences, permissions, and profile data
- **Session Context** - Temporary session-specific information
- **Application Context** - Application state and configuration
- **Business Context** - Domain-specific business rules and data

## 🔧 Usage

### Adding New Context Schemas

1. Create a new JSON schema file in the `schemas/` directory
2. Document the schema in the appropriate docs file
3. Add example metadata in the `metadata/` directory
4. Submit a pull request for review

### Configuration Management

Configuration files should be stored in the `config/` directory and follow these conventions:
- Use JSON or YAML format
- Include environment-specific configurations
- Document all configuration options

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-context`)
3. Commit your changes (`git commit -m 'Add new context definition'`)
4. Push to the branch (`git push origin feature/new-context`)
5. Open a Pull Request

## 📝 Related Projects

- [ae-infinity-api](https://github.com/rkSlalom/ae-infinity-api) - Backend API service

## 👥 Authors

- **Reecha Kansal** - [rkSlalom](https://github.com/rkSlalom)

## 📄 License

This project is part of the AE Immersion Workshop.

## 🔗 Links

- [Repository](https://github.com/rkSlalom/ae-infinity-context)

