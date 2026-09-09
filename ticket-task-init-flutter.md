# Ticket: Initialize Flutter project with clean architecture

## Question

Set up the Flutter project foundation with a scalable architecture that supports V1 features and can grow with the product.

Requirements:
- Clean architecture or similar separation (domain, data, presentation)
- State management solution: **Bloc** (chosen for experimentation)
- Routing setup (GoRouter or AutoRoute)
- Dependency injection (get_it or Riverpod's container — pick one that fits Bloc)
- Localization support (English + Arabic at minimum)
- Theming system (light/dark mode)
- Linting and formatting rules
- CI-ready structure

This is a manual setup task, not a decision — but it must be done before feature development begins.

## Dependencies

- Research: Flutter local storage options (must be closed)
- Prototype: Core user flow and onboarding (must be closed)
- Decision: State management — Bloc chosen over Riverpod

## Assets

- [ ] Flutter project scaffolded and running on Android
- [ ] Architecture documentation (folder structure, state management choice)
- [ ] README with setup instructions
