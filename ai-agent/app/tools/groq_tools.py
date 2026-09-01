from app.tools.registry import ToolRegistry


def build_groq_tools(registry: ToolRegistry) -> list[dict]:
    """Convert our allowlisted tools into Groq function definitions."""

    tools = []

    for name in registry.names():
        tool = registry.get(name)

        if tool is None:
            continue

        schema = tool.input_model.model_json_schema()

        tools.append(
            {
                "type": "function",
                "function": {
                    "name": tool.name,
                    "description": tool.description,
                    "parameters": schema,
                },
            }
        )

    return tools