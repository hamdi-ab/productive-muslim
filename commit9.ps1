$env:GIT_AUTHOR_NAME = "hamdi-ab"
$env:GIT_AUTHOR_EMAIL = "hamdi-ab@users.noreply.github.com"
$env:GIT_COMMITTER_NAME = "hamdi-ab"
$env:GIT_COMMITTER_EMAIL = "hamdi-ab@users.noreply.github.com"
git add -A
if ($?) {
  git commit -m "fix: resolve CRITICAL compile blockers in home shell

- Fix flutter_gen import path to lib/l10n/app_localizations.dart
- Fix BottomNavigationItem typo to BottomNavigationBarItem
- Fix nullable AppLocalizations.of(context) dereference with ! null check
- Fix switch statement arrow case syntax to colon + break (Dart 3.13)
- Move /settings route inside ShellRoute so shell persists on navigation"
}