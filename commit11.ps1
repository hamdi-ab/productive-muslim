$env:GIT_AUTHOR_NAME = "hamdi-ab"
$env:GIT_AUTHOR_EMAIL = "hamdi-ab@users.noreply.github.com"
$env:GIT_COMMITTER_NAME = "hamdi-ab"
$env:GIT_COMMITTER_EMAIL = "hamdi-ab@users.noreply.github.com"
git add -A
if ($?) {
  git commit -m "fix: resolve compile blockers in Taskinator

- Fix bloc import path (flutter_bloc, not bloc)
- Add Task import to task_event.dart and task_state.dart
- Fix TextField decoration (InputDecoration, not BoxDecoration)
- Use local _successColor constant instead of missing theme extension
- Remove unused imports"
}