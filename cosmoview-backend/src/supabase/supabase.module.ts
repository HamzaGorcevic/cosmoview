import { Module } from '@nestjs/common';
import { createServerClient } from '@supabase/ssr';
import { SupabaseService } from './supabase.service';

@Module({
  providers: [
    {
      provide: 'SUPABASE_CLIENT',
      useFactory: () => {
        const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
        const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY!;

        // Implement your cookieStore logic or pass empty if not using SSR cookies
        const cookieStore = {
          getAll: () => [], // replace with real cookie getter
          set: (name: string, value: string, options?: any) => { }, // replace with real setter
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
    SupabaseService,
  ],
  exports: ['SUPABASE_CLIENT', SupabaseService],
})
export class SupabaseModule { }
