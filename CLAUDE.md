<!-- code-review-graph MCP tools -->
## MCP Tools: code-review-graph

**IMPORTANT: This project has a knowledge graph. ALWAYS use the
code-review-graph MCP tools BEFORE using Grep/Glob/Read to explore
the codebase.** The graph is faster, cheaper (fewer tokens), and gives
you structural context (callers, dependents, test coverage) that file
scanning cannot.

### When to use graph tools FIRST

- **Exploring code**: `semantic_search_nodes` or `query_graph` instead of Grep
- **Understanding impact**: `get_impact_radius` instead of manually tracing imports
- **Code review**: `detect_changes` + `get_review_context` instead of reading entire files
- **Finding relationships**: `query_graph` with callers_of/callees_of/imports_of/tests_for
- **Architecture questions**: `get_architecture_overview` + `list_communities`

Fall back to Grep/Glob/Read **only** when the graph doesn't cover what you need.

### Key Tools

| Tool | Use when |
|------|----------|
| `detect_changes` | Reviewing code changes — gives risk-scored analysis |
| `get_review_context` | Need source snippets for review — token-efficient |
| `get_impact_radius` | Understanding blast radius of a change |
| `get_affected_flows` | Finding which execution paths are impacted |
| `query_graph` | Tracing callers, callees, imports, tests, dependencies |
| `semantic_search_nodes` | Finding functions/classes by name or keyword |
| `get_architecture_overview` | Understanding high-level codebase structure |
| `refactor_tool` | Planning renames, finding dead code |

### Workflow

1. The graph auto-updates on file changes (via hooks).
2. Use `detect_changes` for code review.
3. Use `get_affected_flows` to understand impact.
4. Use `query_graph` pattern="tests_for" to check coverage.

## Flyz Google Play Deployment Notes

### App identity
- Android package / namespace: `com.flyz`
- iOS bundle ID: `com.example.flyz`
- Firebase iOS bundle ID in `lib/firebase_options.dart`: `com.example.flyz`

### Android signing
- Release keystore file: `android/upload-keystore.jks`
- Release properties file: `android/key.properties`
- Build file wired to read `android/key.properties` for release signing
- Do not commit `android/key.properties` or the keystore

### Play Console questionnaire answers
- App access / login required: `Yes`
- Reviewer account access: provide test credentials and any OTP / 2FA steps if applicable
- Ads: `No`
- Uploaded content with violence / sexual / offensive / drug content: `No`
- User-generated content sharing: `No`
- Online content: `Yes`
- Age target: `18+`
- Data collection: `Yes`
- Encrypted in transit: `Yes`
- Account creation methods: `Username and password`
- Data deletion request without account deletion: `No`
- Location data: none selected
- Device or other IDs: `Collected`
- Data usage reasons for device ID / FCM token:
  - App functionality
  - Developer communications
- Financial features: `No`
- Advertising ID: `No`

### Store listing notes
- Short description used: `Flyz aide a chercher des vols, gerer vos reservations et acceder au support.`
- Full description draft is available in the chat history.

### Reviewer access reminder
- The Play Console login credentials belong in the `Informations de connexion` / `Acces a l'application` section, not in the data safety or store listing pages.
