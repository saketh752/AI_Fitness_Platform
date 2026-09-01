from app.safety.guardrails import check_action_claim, check_output


def test_code_output_is_rejected():
    result = check_output(
        "Here is the code:\n```python\nprint('hello')\n```"
    )

    assert result.allowed is False


def test_normal_fitness_output_is_allowed():
    result = check_output(
        "Progressive overload means gradually increasing training demands."
    )

    assert result.allowed is True


def test_pending_action_completion_claim_is_rejected():
    result = check_action_claim(
        "Done! Your workout has been updated.",
        has_pending_actions=True,
    )

    assert result.allowed is False


def test_pending_action_confirmation_text_is_allowed():
    result = check_action_claim(
        "I can shorten your workout to 20 minutes. Please confirm.",
        has_pending_actions=True,
    )

    assert result.allowed is True