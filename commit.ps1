$env:GIT_AUTHOR_NAME = "hamdi-ab"
$env:GIT_AUTHOR_EMAIL = "hamdi-ab@users.noreply.github.com"
$env:GIT_COMMITTER_NAME = "hamdi-ab"
$env:GIT_COMMITTER_EMAIL = "hamdi-ab@users.noreply.github.com"
git add -A
if ($?) {
  git commit -m "feat: intentions feature + analysis cleanup

Add PR #8: intentions journal feature with Bloc state management,
hand-rolled database layer, and theme extensions.

Also fixes:
- Resolve duplicate class names across event/state libraries
- Add missing ARB keys (todayIntentions, noIntentionsToday, reflection,
  saveReflection, newIntention, completed)
- Fix AppColors/AppTypography extension constructors
- Fix GoRouter config (router: -> routerConfig:)
- Fix onboarding screen type annotations and TextField decoration
- Fix app_database.dart NativeDatabase import
- Fix tasks.dart TableIndex annotation placement

flutter analyze: 4 info-level only"
}