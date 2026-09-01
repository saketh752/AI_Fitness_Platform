from app.schemas.conversation import (
    Conversation,
    ConversationMessage,
)


class ConversationOwnershipError(Exception):
    """Raised when a user attempts to access another user's conversation."""


class ConversationStore:
    """
    Temporary in-memory conversation store.

    This abstraction can later be replaced by a Spring Boot/MySQL-backed
    implementation without changing the agent's core conversation logic.
    """

    def __init__(self) -> None:
        self._conversations: dict[str, Conversation] = {}

    def get_or_create(
        self,
        conversation_id: str,
        user_id: str,
    ) -> Conversation:

        conversation = self._conversations.get(conversation_id)

        if conversation is None:
            conversation = Conversation(
                conversation_id=conversation_id,
                user_id=user_id,
            )

            self._conversations[conversation_id] = conversation

        elif conversation.user_id != user_id:
            raise ConversationOwnershipError(
                "Conversation does not belong to this user."
            )

        return conversation

    def add_message(
        self,
        conversation_id: str,
        user_id: str,
        message: ConversationMessage,
    ) -> Conversation:

        conversation = self.get_or_create(
            conversation_id,
            user_id,
        )

        conversation.messages.append(message)

        return conversation

    def get_messages(
        self,
        conversation_id: str,
        user_id: str,
        limit: int | None = None,
    ) -> list[ConversationMessage]:

        conversation = self.get_or_create(
            conversation_id,
            user_id,
        )

        messages = conversation.messages

        if limit is None:
            return messages

        if limit <= 0:
            return []

        return messages[-limit:]

    def get_summary(
        self,
        conversation_id: str,
        user_id: str,
    ) -> str | None:

        conversation = self.get_or_create(
            conversation_id,
            user_id,
        )

        return conversation.summary

    def set_summary(
        self,
        conversation_id: str,
        user_id: str,
        summary: str | None,
    ) -> Conversation:

        conversation = self.get_or_create(
            conversation_id,
            user_id,
        )

        conversation.summary = summary

        return conversation

    def clear(
        self,
        conversation_id: str,
        user_id: str,
    ) -> None:

        conversation = self.get_or_create(
            conversation_id,
            user_id,
        )

        del self._conversations[conversation.conversation_id]