import { Module } from '@nestjs/common';
import { createServerClient } from '@supabase/ssr';

@Module({
  providers: [
    {
      provide: 'SUPABASE_CLIENT',
      useFactory: () => {
        const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
        const supabaseKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;
        
        // Implement your cookieStore logic or pass empty if not using SSR cookies
        const cookieStore = {
          getAll: () => [], // replace with real cookie getter
          set: (name: string, value: string, options?: any) => {}, // replace with real setter
        };

        return createServerClient(
          supabaseUrl,
          supabaseKey,
          {
            cookies: {
              getAll: cookieStore.getAll,
              setAll: (cookiesToSet) => {
                cookiesToSet.forEach(({ name, value, options }) =>
                  cookieStore.set(name, value, options),
                );
              },
            },
          },
        ) 
      },
    },
  ],
  exports: ['SUPABASE_CLIENT'],
})
export class SupabaseModule {}
