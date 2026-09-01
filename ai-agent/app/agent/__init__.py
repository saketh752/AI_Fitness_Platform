def __init__(self) -> None:
    # LLM client
    self.groq = GroqClient()

    # Fitness context builder
    self.context_manager = ContextManager()

    # Controlled tool system
    self.tool_registry = create_default_registry()
    self.tool_executor = ToolExecutor(self.tool_registry)
    self.groq_tools = build_groq_tools(self.tool_registry)

    # Temporary in-memory conversation storage
    self.conversation_store = ConversationStore()

    # Conversation summary manager
    self.summary_manager = SummaryManager()