package com.aifitness.coach;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.List;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.aifitness.coach.dto.ChatRequest;
import com.aifitness.coach.dto.ChatResponse;
import com.aifitness.coach.dto.CoachMessageDto;
import com.aifitness.groq.GroqClient;
import com.aifitness.groq.GroqPromptBuilder;
import com.aifitness.health.assessment.UserConditionRepository;
import com.aifitness.nutrition.NutritionService;
import com.aifitness.nutrition.dto.NutritionSummaryDto;
import com.aifitness.recommendation.Recommendation;
import com.aifitness.recommendation.RecommendationRepository;
import com.aifitness.user.User;
import com.aifitness.user.UserGoal;
import com.aifitness.user.UserGoalRepository;
import com.aifitness.user.UserProfile;
import com.aifitness.user.UserProfileRepository;
import com.aifitness.user.UserRepository;

@ExtendWith(MockitoExtension.class)
class CoachServiceTest {

    @Mock
    private CoachConversationRepository conversationRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private UserProfileRepository userProfileRepository;

    @Mock
    private UserGoalRepository userGoalRepository;

    @Mock
    private UserConditionRepository userConditionRepository;

    @Mock
    private RecommendationRepository recommendationRepository;

    @Mock
    private NutritionService nutritionService;

    @Mock
    private GroqClient groqClient;

    @Mock
    private GroqPromptBuilder promptBuilder;

    @InjectMocks
    private CoachService coachService;

    private User testUser;
    private UserProfile testProfile;

    @BeforeEach
    void setUp() {
        testUser = new User();
        testUser.setId(1L);
        testUser.setEmail("alex@example.com");

        testProfile = new UserProfile();
        testProfile.setFullName("Alex Johnson");
        testProfile.setGender("Male");
    }

    @Test
    void chat_InterceptsMedicalRiskKeyword() {
        when(userRepository.findById(1L)).thenReturn(Optional.of(testUser));

        ChatRequest request = new ChatRequest();
        request.setMessage("I have severe sharp chest pain while benching");

        ChatResponse response = coachService.chat(1L, request);

        assertNotNull(response);
        assertEquals("MEDICAL_REVIEW", response.getStatus());
        verify(groqClient, never()).getChatCompletion(anyList());
        verify(conversationRepository).save(any(CoachConversation.class));
    }

    @Test
    void chat_BuildsContextAndCallsGroq() {
        when(userRepository.findById(1L)).thenReturn(Optional.of(testUser));
        when(userProfileRepository.findByUserId(1L)).thenReturn(Optional.of(testProfile));
        when(userGoalRepository.findByUserIdAndStatus(1L, "ACTIVE")).thenReturn(List.of(new UserGoal()));
        when(userConditionRepository.findAllByUserId(1L)).thenReturn(List.of());
        when(recommendationRepository.findTopByUserIdOrderByCreatedAtDesc(1L)).thenReturn(Optional.of(new Recommendation()));
        when(nutritionService.getTodaySummary(1L)).thenReturn(NutritionSummaryDto.builder().targetCalories(2200).consumedCalories(800).remainingCalories(1400).build());
        when(promptBuilder.buildCoachPrompt(any(), any())).thenReturn(List.of());
        when(groqClient.getChatCompletion(anyList())).thenReturn("Make sure to keep your core tight!");

        ChatRequest request = new ChatRequest();
        request.setMessage("How can I improve my deadlift?");

        ChatResponse response = coachService.chat(1L, request);

        assertNotNull(response);
        assertEquals("SAFE", response.getStatus());
        assertEquals("Make sure to keep your core tight!", response.getResponse());
        verify(conversationRepository).save(any(CoachConversation.class));
    }

    @Test
    void getHistory_ReturnsPastConversations() {
        CoachConversation conv = new CoachConversation();
        conv.setId(10L);
        conv.setMessage("What to eat today?");
        conv.setResponse("Eat high protein foods.");
        conv.setStatus("SAFE");

        when(conversationRepository.findAllByUserIdOrderByCreatedAtDesc(1L)).thenReturn(List.of(conv));

        List<CoachMessageDto> history = coachService.getHistory(1L);

        assertNotNull(history);
        assertEquals(1, history.size());
        assertEquals("What to eat today?", history.get(0).getMessage());
        assertEquals("Eat high protein foods.", history.get(0).getResponse());
    }
}
