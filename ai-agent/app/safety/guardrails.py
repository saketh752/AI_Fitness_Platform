import re
from dataclasses import dataclass


@dataclass
class ScopeCheckResult:
    allowed: bool
    reason: str


# Clearly out-of-scope programming requests.
PROGRAMMING_PATTERNS = [
    r"\bwrite\b.*\bpython\b.*\b(code|program|script)\b",
    r"\bcreate\b.*\bpython\b.*\b(code|program|script)\b",
    r"\bgive me\b.*\bpython\b.*\b(code|program|script)\b",
    r"\bwrite\b.*\bjava\b.*\b(code|program|script)\b",
    r"\bwrite\b.*\bjavascript\b.*\b(code|program|script)\b",
    r"\bwrite\b.*\bc\+\+\b.*\b(code|program|script)\b",
    r"\bwrite\b.*\bc\b.*\b(code|program|script)\b",
    r"\bwrite\b.*\bsql\b.*\b(query|code|script)\b",
    r"\bwrite\b.*\bprogram\b",
    r"\bwrite\b.*\bscript\b",
]


# Clearly dangerous or unrelated technical requests.
DANGEROUS_PATTERNS = [
    r"\bhack\b",
    r"\bhacking\b",
    r"\bmalware\b",
    r"\bransomware\b",
    r"\bsql injection\b",
    r"\bexploit\b",
]


# Attempts to override the agent's role or instructions.
PROMPT_INJECTION_PATTERNS = [
    r"\bignore all previous instructions\b",
    r"\bignore previous instructions\b",
    r"\bignore your instructions\b",
    r"\bforget your instructions\b",
    r"\byou are no longer\b",
    r"\bact as\b.*\b(unrestricted|general|coding|programming)\b",
    r"\bpretend you are\b.*\b(unrestricted|general|coding|programming)\b",
]


def _matches_any(message: str, patterns: list[str]) -> bool:
    return any(re.search(pattern, message, re.IGNORECASE) for pattern in patterns)


def check_scope(message: str) -> ScopeCheckResult:
    """
    Perform deterministic checks before a message reaches the LLM.

    This is one security layer. It is intentionally conservative
    for clearly identifiable out-of-scope requests.
    """

    normalized_message = message.strip()

    if _matches_any(normalized_message, PROMPT_INJECTION_PATTERNS):
        return ScopeCheckResult(
            allowed=False,
            reason="Prompt injection or role override detected.",
        )

    if _matches_any(normalized_message, PROGRAMMING_PATTERNS):
        return ScopeCheckResult(
            allowed=False,
            reason="Programming request is outside the fitness agent's scope.",
        )

    if _matches_any(normalized_message, DANGEROUS_PATTERNS):
        return ScopeCheckResult(
            allowed=False,
            reason="Request is outside the fitness agent's scope.",
        )

    return ScopeCheckResult(
        allowed=True,
        reason="Request passed the initial scope check.",
    )
def check_output(response: str) -> ScopeCheckResult:
    """
    Validate the model's response before returning it to the client.
    """

    if not response or not response.strip():
        return ScopeCheckResult(
            allowed=False,
            reason="Model returned an empty response.",
        )

    programming_output_patterns = [
        r"```python\b",
        r"```java\b",
        r"```javascript\b",
        r"```c\+\+\b",
        r"```sql\b",
        r"\bdef\s+\w+\s*\(",
        r"\bpublic\s+static\s+void\s+main\b",
        r"\bimport\s+\w+",
        r"\bSELECT\s+.+\s+FROM\b",
    ]

    if _matches_any(response, programming_output_patterns):
        return ScopeCheckResult(
            allowed=False,
            reason="Model generated programming content.",
        )

    return ScopeCheckResult(
        allowed=True,
        reason="Model output passed the safety check.",
    )
def check_action_claim(
    response: str,
    has_pending_actions: bool,
) -> ScopeCheckResult:

    if not has_pending_actions:
        return ScopeCheckResult(
            allowed=True,
            reason="No pending actions.",
        )

    success_patterns = [
        r"\bcompleted\b",
        r"\bdone\b",
        r"\bupdated\b",
        r"\bchanged\b",
        r"\bremoved\b",
        r"\breplaced\b",
    ]

    if _matches_any(response, success_patterns):
        return ScopeCheckResult(
            allowed=False,
            reason="Response claims a write action was completed.",
        )

    return ScopeCheckResult(
        allowed=True,
        reason="No unsupported completion claim detected.",
    )