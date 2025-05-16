import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/session_sequence.dart';
import '../models/session.dart';

class GeminiService {
  static const String _apiKey = 'AIzaSyB9YueFBVulW8akICrGjh1ERxeEhczWh2Q';
  static const String _model = 'gemini-2.5-flash-preview-04-17';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';
  
  // Generate a personalized session sequence based on user history
  Future<SessionSequence> generatePersonalizedSequence(
    List<Session> pastSessions,
    int userLevel,
  ) async {
    try {
      // Create a prompt for Gemini API
      final prompt = _createSequencePrompt(pastSessions, userLevel);
      
      // Call Gemini API
      final response = await _callGeminiApi(prompt);
      
      // Parse the response to create a SessionSequence
      final sessionSequence = _parseSequenceResponse(response);
      
      return sessionSequence;
    } catch (e) {
      debugPrint('Error generating personalized sequence: $e');
      // Fallback to a predefined sequence if API call fails
      final predefinedSequences = SessionSequence.getPredefinedSequences();
      final index = (userLevel ~/ 2).clamp(0, predefinedSequences.length - 1);
      return predefinedSequences[index];
    }
  }
  
  // Get AI feedback on a completed session
  Future<String> getSessionFeedback(Session session) async {
    try {
      // Create a prompt for Gemini API
      final prompt = _createFeedbackPrompt(session);
      
      // Call Gemini API
      final response = await _callGeminiApi(prompt);
      
      // Extract the feedback text
      return response;
    } catch (e) {
      debugPrint('Error generating session feedback: $e');
      return 'Great job completing your session! Keep up the good work.';
    }
  }
  
  // Get AI response for user question
  Future<String> getAIResponse(String userQuestion, List<Session> pastSessions) async {
    try {
      // Create a prompt for Gemini API
      final prompt = _createAssistantPrompt(userQuestion, pastSessions);
      
      // Call Gemini API
      final response = await _callGeminiApi(prompt);
      
      return response;
    } catch (e) {
      debugPrint('Error getting AI response: $e');
      return 'I\'m sorry, I couldn\'t process your question at the moment. Please try again later.';
    }
  }
  
  // Create a prompt for generating a session sequence
  String _createSequencePrompt(List<Session> pastSessions, int userLevel) {
    final sessionStats = _getSessionStats(pastSessions);
    
    return '''
You are an AI designed to create personalized intervention sequences for a CBT-based mobile app that helps users overcome PMO addiction.

User Profile:
- Experience Level: ${_getLevelDescription(userLevel)}
- Completed Sessions: ${pastSessions.length}
- Average Completion Rate: ${sessionStats['avgCompletionRate']}%
- Average Session Duration: ${sessionStats['avgDuration']} seconds

Create a personalized session sequence with the following components:
1. A sequence ID (string)
2. A name for the sequence (string)
3. A brief description (string)
4. A list of 5 intervention steps with these properties for each:
   - title: A short title for the step
   - description: A user-friendly instruction
   - type: One of [handPosition, vibration, flashlight, audio, breathe, visualize]
   - parameters: A JSON object with appropriate parameters for the step type

The sequence should follow this general structure:
- Start with a handPosition step (left, right, or both hands)
- Include a vibration step with a pattern (gentle, pulsing, escalating, rhythmic, or wave)
- Include a preparation step for light therapy
- Include a flashlight step with a pattern (steady, pulsing, strobe, fadeInOut, morse, or heartbeat)
- End with an audio step (whitenoise, nature, meditation, breathing, or heartbeat)

Make the sequence appropriately challenging based on the user's level, but ensure it's effective for PMO addiction recovery using CBT principles.

Format your response as a valid JSON object that can be parsed directly.
''';
  }
  
  // Create a prompt for generating session feedback
  String _createFeedbackPrompt(Session session) {
    return '''
You are an AI designed to provide supportive feedback for users of a CBT-based mobile app that helps overcome PMO addiction.

Session Details:
- Completion Percentage: ${session.completionPercentage}%
- Duration: ${session.durationInSeconds} seconds
- Was Completed: ${session.wasCompleted}
- Timestamp: ${session.timestamp}

Provide encouraging, supportive feedback about this session. If the session was completed, congratulate the user and highlight the benefits of consistency. If it was not completed, provide encouragement and tips for next time.

Keep your response concise (2-3 sentences), positive, and focused on CBT principles for addiction recovery. Avoid being judgmental or using shame-based language.
''';
  }
  
  // Create a prompt for the AI assistant
  String _createAssistantPrompt(String userQuestion, List<Session> pastSessions) {
    final sessionStats = _getSessionStats(pastSessions);
    
    return '''
You are an AI assistant in a CBT-based mobile app that helps users overcome PMO addiction. You provide supportive, evidence-based guidance.

User Stats:
- Completed Sessions: ${pastSessions.length}
- Average Completion Rate: ${sessionStats['avgCompletionRate']}%
- Recent Activity: ${_getRecentActivityDescription(pastSessions)}

User Question: "$userQuestion"

Provide a helpful, supportive response based on CBT principles for addiction recovery. Be empathetic but professional. Provide practical advice when appropriate. Keep your response concise (3-5 sentences) and focused on helping the user overcome PMO addiction.

Avoid:
- Shame-based language
- Overly clinical terminology
- Vague platitudes
- Judgmental tone

Focus on:
- Evidence-based CBT techniques
- Practical, actionable advice
- Positive reinforcement
- Building healthy habits
''';
  }
  
  // Call the Gemini API
  Future<String> _callGeminiApi(String prompt) async {
    final url = '$_baseUrl/$_model:generateContent?key=$_apiKey';
    
    final requestBody = jsonEncode({
      'contents': [
        {
          'parts': [
            {
              'text': prompt,
            }
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.4,
        'topK': 32,
        'topP': 0.95,
        'maxOutputTokens': 1024,
      },
    });
    
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: requestBody,
    );
    
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final text = jsonResponse['candidates'][0]['content']['parts'][0]['text'];
      return text;
    } else {
      throw Exception('Failed to call Gemini API: ${response.statusCode} ${response.body}');
    }
  }
  
  // Parse the Gemini API response to create a SessionSequence
  SessionSequence _parseSequenceResponse(String response) {
    try {
      // Extract JSON from the response (in case there's markdown or other text)
      final jsonRegExp = RegExp(r'{[\s\S]*}');
      final match = jsonRegExp.firstMatch(response);
      
      if (match == null) {
        throw Exception('No JSON found in response');
      }
      
      final jsonStr = match.group(0);
      final json = jsonDecode(jsonStr!);
      
      return SessionSequence.fromJson(json);
    } catch (e) {
      debugPrint('Error parsing sequence response: $e');
      debugPrint('Response: $response');
      
      // Fallback to a random sequence
      return SessionSequence.generateRandom();
    }
  }
  
  // Helper methods
  Map<String, dynamic> _getSessionStats(List<Session> sessions) {
    if (sessions.isEmpty) {
      return {
        'avgCompletionRate': 0,
        'avgDuration': 0,
      };
    }
    
    final totalCompletionRate = sessions.fold<double>(
      0,
      (sum, session) => sum + session.completionPercentage,
    );
    
    final totalDuration = sessions.fold<int>(
      0,
      (sum, session) => sum + session.durationInSeconds,
    );
    
    return {
      'avgCompletionRate': (totalCompletionRate / sessions.length).toStringAsFixed(1),
      'avgDuration': (totalDuration / sessions.length).toStringAsFixed(0),
    };
  }
  
  String _getLevelDescription(int level) {
    switch (level) {
      case 1:
        return 'Beginner';
      case 2:
        return 'Novice';
      case 3:
        return 'Intermediate';
      case 4:
        return 'Advanced';
      case 5:
        return 'Expert';
      default:
        return 'Beginner';
    }
  }
  
  String _getRecentActivityDescription(List<Session> sessions) {
    if (sessions.isEmpty) {
      return 'No sessions completed yet';
    }
    
    // Sort sessions by timestamp (most recent first)
    final sortedSessions = List<Session>.from(sessions)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    final recentSession = sortedSessions.first;
    final daysSinceRecent = DateTime.now().difference(recentSession.timestamp).inDays;
    
    if (daysSinceRecent == 0) {
      return 'Completed a session today';
    } else if (daysSinceRecent == 1) {
      return 'Completed a session yesterday';
    } else {
      return 'Last session was $daysSinceRecent days ago';
    }
  }
}
