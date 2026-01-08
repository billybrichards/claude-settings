# Update Session

Update the current session with a brief summary of what you're working on.

## When to Use

- Run `/update-session` to manually update the session description
- This is called automatically every 10 minutes during active work

## Instructions

When this skill is invoked:

1. Summarize the current work in 1-2 sentences
2. Focus on what's being accomplished, not technical details
3. Run `session set "Your summary here"` to update the Agent Monitor
4. Optionally update progress with `session progress <0-100>`

## Examples

Good summaries:
- "Implementing user authentication with OAuth integration"
- "Fixing pagination bug in the product listing page"
- "Adding unit tests for the payment processing module"

Bad summaries (too vague):
- "Working on code"
- "Fixing bugs"
- "Development work"

## Auto-Update Behavior

This plugin automatically updates the session every 10 minutes by:
1. Analyzing recent conversation context
2. Generating a concise summary with Haiku
3. Updating the session with `session set`
