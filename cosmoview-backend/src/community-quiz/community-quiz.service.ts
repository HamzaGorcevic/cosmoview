import { Injectable, Logger } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

@Injectable()
export class CommunityQuizService {
  private readonly logger = new Logger(CommunityQuizService.name);

  constructor(private readonly supabaseService: SupabaseService) { }

  async create(userId: string, createCommunityQuizDto: any) {
    const { question, options, correct_answer } = createCommunityQuizDto;

    const { data, error } = await this.supabaseService.getClient()
      .from('community_quizzes')
      .insert({
        question,
        options,
        correct_answer,
        creator_id: userId
      })
      .select()
      .single();

    if (error) {
      this.logger.error('Error creating community quiz', error);
      throw error;
    }

    return { status: true, data };
  }

  async findAll(userId?: string) {
    // Return all quizzes ordered by newest first
    const { data: quizzes, error } = await this.supabaseService.getClient()
      .from('community_quizzes')
      .select('*, users(username, id)')
      .order('created_at', { ascending: false });

    if (error) {
      this.logger.error('Error fetching community quizzes', error);
      return [];
    }

    if (!userId) {
      return quizzes;
    }

    // Fetch user attempts
    const { data: attempts } = await this.supabaseService.getClient()
      .from('community_quiz_attempts')
      .select('quiz_id, is_correct')
      .eq('user_id', userId);

    const attemptMap = new Map();
    attempts?.forEach(a => attemptMap.set(a.quiz_id, a.is_correct));

    return quizzes.map(q => ({
      ...q,
      attempted: attemptMap.has(q.id),
      is_correct: attemptMap.get(q.id)
    }));
  }

  async findOne(id: string) {
    const { data, error } = await this.supabaseService.getClient()
      .from('community_quizzes')
      .select('*, users(username)')
      .eq('id', id)
      .single();

    if (error) return null;
    return data;
  }

  async submitAnswer(userId: string, quizId: string, answer: string) {
    // 1. Check if already attempted
    const { data: existing } = await this.supabaseService.getClient()
      .from('community_quiz_attempts')
      .select('*')
      .eq('user_id', userId)
      .eq('quiz_id', quizId)
      .maybeSingle();

    if (existing) {
      return {
        status: false,
        message: 'Already attempted',
        correct: existing.is_correct,
        points: 0 // Previously earned points are not returned here, but standardizing strict struct decoding
      };
    }

    // 2. Fetch quiz to check answer
    const quiz = await this.findOne(quizId);
    if (!quiz) throw new Error('Quiz not found');

    const isCorrect = quiz.correct_answer === answer;

    // 3. Record attempt
    const { error } = await this.supabaseService.getClient()
      .from('community_quiz_attempts')
      .insert({
        user_id: userId,
        quiz_id: quizId,
        is_correct: isCorrect
      });

    if (error) throw error;

    // 4. Award points if correct (e.g. 5 points for community quiz)
    if (isCorrect) {
      const { data: user } = await this.supabaseService.getClient()
        .from('users')
        .select('total_points')
        .eq('id', userId)
        .single();

      const newPoints = (user?.total_points || 0) + 5;
      await this.supabaseService.getClient()
        .from('users')
        .update({ total_points: newPoints })
        .eq('id', userId);
    }

    return { status: true, correct: isCorrect, points: isCorrect ? 5 : 0 };
  }
}
