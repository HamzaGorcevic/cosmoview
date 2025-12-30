import { Injectable } from '@nestjs/common';
import { SupabaseService } from 'src/supabase/supabase.service';
import * as bcrypt from 'bcrypt';

@Injectable()
export class AuthService {
  constructor(private readonly supabaseService: SupabaseService) { }

  async createUser(username: string, email: string, password: string) {
    const { data: existingUser, error: fetchError } = await this.supabaseService.getClient()
      .from('users')
      .select('id')
      .eq('email', email)
      .single();

    if (fetchError && fetchError.code !== 'PGRST116') {
      console.error('Error checking user existence:', fetchError);
      return { status: false, message: 'Failed to check user', data: null };
    }

    if (existingUser) {
      return { status: false, message: 'User with this email already exists', data: null };
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const { data, error } = await this.supabaseService.getClient()
      .from('users')
      .insert([{ username, email, password_hash: hashedPassword }])
      .select('id, username, email, created_at, updated_at')
      .single();

    if (error) {
      console.error('Error creating user:', error);
      return { status: false, message: 'Failed to create user', data: null };
    }

    return {
      status: true,
      message: 'User created successfully',
      data: {
        id: data.id,
        username: data.username,
        email: data.email,
        totalPoints: data.total_points || 0,
        createdAt: data.created_at,
        updatedAt: data.updated_at
      }
    };
  }

  async loginUser(email: string, password: string) {
    const { data: user, error } = await this.supabaseService.getClient()
      .from('users')
      .select('*')
      .eq('email', email)
      .single();

    if (error || !user) {
      return { status: false, message: 'User not found', data: null };
    }

    const isPasswordValid = await bcrypt.compare(password, user.password_hash);

    if (!isPasswordValid) {
      return { status: false, message: 'Invalid password', data: null };
    }

    return {
      status: true,
      message: 'Login successful',
      data: {
        id: user.id,
        username: user.username,
        email: user.email,
        totalPoints: user.total_points || 0,
        createdAt: user.created_at,
        updatedAt: user.updated_at
      }
    };
  }

  async changePassword(userId: string, oldPassword: string, newPassword: string) {
    const { data: user, error } = await this.supabaseService.getClient()
      .from('users')
      .select('*')
      .eq('id', userId)
      .single();

    if (error || !user) {
      return { status: false, message: 'User not found', data: null };
    }

    const isPasswordValid = await bcrypt.compare(oldPassword, user.password_hash);

    if (!isPasswordValid) {
      return { status: false, message: 'Invalid old password', data: null };
    }

    const hashedPassword = await bcrypt.hash(newPassword, 10);

    const { data: updatedUser, error: updateError } = await this.supabaseService.getClient()
      .from('users')
      .update({ password_hash: hashedPassword, updated_at: new Date().toISOString() })
      .eq('id', userId)
      .select('id, username, email, created_at, updated_at')
      .single();

    if (updateError) {
      console.error('Error updating password:', updateError);
      return { status: false, message: 'Failed to update password', data: null };
    }

    return {
      status: true,
      message: 'Password changed successfully',
      data: {
        id: updatedUser.id,
        username: updatedUser.username,
        email: updatedUser.email,
        createdAt: updatedUser.created_at,
        updatedAt: updatedUser.updated_at
      }
    };
  }
}