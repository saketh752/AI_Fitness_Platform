from app.config.settings import settings


def test_groq_configuration_is_loaded():
    assert settings.groq_api_key
    assert settings.groq_model
def test_conversation_history_limit_is_configured():
    from app.config.settings import settings

    assert settings.conversation_history_limit == 10