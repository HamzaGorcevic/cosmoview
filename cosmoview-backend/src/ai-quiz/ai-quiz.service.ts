import { Injectable, Logger } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { Cron, CronExpression } from '@nestjs/schedule';
import { ConfigService } from '@nestjs/config';
import axios from 'axios';

@Injectable()
export class AiQuizService {
    private readonly logger = new Logger(AiQuizService.name);

    constructor(
        private supabaseService: SupabaseService,
        private configService: ConfigService,
    ) { }

    async getAiQuiz() {
        // Get today's quiz
        const today = new Date().toISOString().split('T')[0];
        const { data, error } = await this.supabaseService.getClient()
            .from('ai_quiz')
            .select('*')
            .eq('quiz_date', today)
            .maybeSingle();

        if (error) throw error;

        // If found, return it
        if (data) return data;

        // If not found, trigger generation
        this.logger.log('No quiz found for today, triggering generation...');
        await this.handleDailyQuiz();

        // Fetch again
        const { data: newQuiz } = await this.supabaseService.getClient()
            .from('ai_quiz')
            .select('*')
            .eq('quiz_date', today)
            .maybeSingle();

        if (newQuiz) return newQuiz;

        // Fallback to latest
        const { data: latest } = await this.supabaseService.getClient()
            .from('ai_quiz')
            .select('*')
            .order('quiz_date', { ascending: false })
            .limit(1)
            .maybeSingle();

        return latest;
    }

    @Cron('0 0 * * *')
    async handleDailyQuiz() {
        this.logger.debug('Checking daily quiz generation...');
        const today = new Date().toISOString().split('T')[0];
        const { data: existing } = await this.supabaseService.getClient()
            .from('ai_quiz')
            .select('*')
            .eq('quiz_date', today)
            .maybeSingle();

        if (existing) {
            this.logger.debug('Quiz already exists for today.');
            return;
        }

        try {
            const quiz = await this.generateQuizFromAI();
            const { error } = await this.supabaseService.getClient()
                .from('ai_quiz')
                .insert({
                    question: quiz.question,
                    options: quiz.options,
                    correct_answer: quiz.correct_answer,
                    quiz_date: today,
                });

            if (error) {
                this.logger.error('Failed to save quiz', error);
            } else {
                this.logger.log('Daily quiz generated and saved.');
                await this.notifyUsers(quiz.question);
            }
        } catch (e) {
            this.logger.error('Error generating quiz', e);
        }
    }

    private async generateQuizFromAI(): Promise<{ question: string; options: string[]; correct_answer: string }> {
        const apiKey = this.configService.get('AZURE_OPENAI_API_KEY');
        if (!apiKey) {
            this.logger.warn('No AZURE_OPENAI_API_KEY found, using mock data.');
            return {
                question: 'Which planet is known as the Red Planet?',
                options: ['Venus', 'Mars', 'Jupiter', 'Saturn'],
                correct_answer: 'Mars',
            };
        }

        const prompt = `Generate 1 simple trivia question about the universe, cosmos, stars, or planets. 
        Provide exactly 4 distinct options. 
        The output MUST be a raw JSON object with no markdown formatting.
        The JSON object must strictly adhere to this schema:
        {
            "question": "The text of the question",
            "options": ["Option 1", "Option 2", "Option 3", "Option 4"],
            "correct_answer": "The text of the correct option (must be one of the options)"
        }`;

        try {
            const response = await axios.post(
                'https://models.inference.ai.azure.com/chat/completions',
                {
                    model: 'gpt-4o',
                    messages: [
                        { role: 'system', content: 'You are a backend API that generates trivia questions. You only return valid JSON.' },
                        { role: 'user', content: prompt },
                    ],
                    temperature: 0.7,
                    response_format: { type: "json_object" }
                },
                {
                    headers: {
                        'Authorization': `Bearer ${apiKey}`,
                        'Content-Type': 'application/json',
                    },
                },
            );

            const content = response.data.choices[0].message.content;
            // Parse JSON from content (handle potential markdown code blocks)
            const jsonStr = content.replace(/```json/g, '').replace(/```/g, '').trim();
            return JSON.parse(jsonStr);
        } catch (error) {
            this.logger.error('AI API Call failed', error);
            throw error;
        }
    }

    async submitAnswer(userId: string, quizId: string, answer: string) {
        // Check if already answered
        const { data: existing } = await this.supabaseService.getClient()
            .from('user_quiz_attempts')
            .select('*')
            .eq('user_id', userId) // Ensure userId matches usage in project (snake_case vs camelCase in DB vs DTO)
            .eq('quiz_id', quizId)
            .maybeSingle();

        if (existing) {
            return { message: 'Already attempted', correct: existing.is_correct, points: existing.awarded_points };
        }

        // Get Quiz
        const { data: quiz } = await this.supabaseService.getClient()
            .from('ai_quiz')
            .select('*')
            .eq('id', quizId)
            .single();

        if (!quiz) throw new Error('Quiz not found');

        const isCorrect = quiz.correct_answer === answer;
        const points = isCorrect ? 10 : 0;

        // Record attempt
        const { error } = await this.supabaseService.getClient()
            .from('user_quiz_attempts')
            .insert({
                user_id: userId,
                quiz_id: quizId,
                is_correct: isCorrect,
                awarded_points: points
            });

        if (error) throw error;

        // Update user points if correct
        if (isCorrect) {
            const { data: user } = await this.supabaseService.getClient()
                .from('users')
                .select('total_points')
                .eq('id', userId)
                .single();

            const newPoints = (user?.total_points || 0) + points;

            await this.supabaseService.getClient()
                .from('users')
                .update({ total_points: newPoints })
                .eq('id', userId);
        }

        return { correct: isCorrect, points };
    }

    private async notifyUsers(question: string) {
        // Placeholder for Swift Notification
        // In a real app, this would use APNs or a service like Firebase Cloud Messaging (FCM)
        // or Expo Push Notifications.
        this.logger.log(`[NOTIFICATION] New Daily Quiz: ${question}`);
        // TODO: Integration with Push Notification Service
    }
}
