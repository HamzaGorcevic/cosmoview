import { Injectable } from '@nestjs/common';
import { SupabaseService } from 'src/supabase/supabase.service';
import * as bcrypt from 'bcrypt';
@Injectable()
export class AuthService {
    constructor(private readonly supabaseService:SupabaseService){}
    async createUser(username:string,email:string,password:string){
        const { data: existingUser, error: fetchError } = await this.supabaseService.getClient()
        .from('users')
        .select('id')
        .eq('email', email)
        .single();
      if (fetchError && fetchError.code !== 'PGRST116') { // PGRST116 = no rows found
        console.error('Error checking user existence:', fetchError);
        return ('Failed to check user');
      }
      if (existingUser) {
        return ('User with this email already exists');
      }
        const saltRounds = 10;
        const hashedPassword = await bcrypt.hash(password, saltRounds);

        const {data,error} = await this.supabaseService.getClient().from("users").insert([{username,email,password_hash:hashedPassword}]);
        if(error){
            console.error("Error creating user:",error);
            return "Failed to create user";
        }
        return "User created successfully";
    }
    async loginUser(email:string,password:string){
        const { data: user, error } = await this.supabaseService.getClient()
        .from('users')
        .select('*')
        .eq('email', email)
        .maybeSingle();
      if (error) {
        console.error('Error fetching user:', error);
        return 'User not found';
      }
      const isPasswordValid = await this.verifyPassword(password, user.password_hash);
      if (!isPasswordValid) {
        return 'Invalid password';
      }
      return "Login successful";
    }
    async verifyPassword(password:string,hashedPassword:string):Promise<boolean>{
        return bcrypt.compare(password,hashedPassword);
    }
    async changePassword(userId:string,oldPassword:string,newPassword:string){
        const { data: user, error } = await this.supabaseService.getClient()
        .from('users')
        .select('*')
        .eq('id', userId)
        .single();
      if (error) {
        console.error('Error fetching user:', error);
        return 'User not found';
      }
      const isPasswordValid = await this.verifyPassword(oldPassword, user.password_hash);
      if (!isPasswordValid) {
        return 'Invalid old password';
      }
      const saltRounds = 10;
      const hashedPassword = await bcrypt.hash(newPassword, saltRounds);
      const {error: updateError} = await this.supabaseService.getClient()
        .from('users')
        .update({password_hash:hashedPassword,updated_at:new Date().toISOString()})
        .eq('id', userId);
      if(updateError){
        console.error("Error updating password:",updateError);
        return "Failed to update password";
      }
      return "Password changed successfully";
    }
}
