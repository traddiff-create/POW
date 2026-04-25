export type UserRole = "participant" | "facilitator" | "admin";
export type ApplicationStatus = "pending" | "approved" | "rejected" | "waitlisted";
export type PaymentStatus = "pending" | "succeeded" | "failed";

export interface Database {
  public: {
    Tables: {
      user_profiles: {
        Row: {
          id: string;
          display_name: string | null;
          role: UserRole;
          onboarding_completed_at: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: { id: string; display_name?: string | null; role?: UserRole; onboarding_completed_at?: string | null };
        Update: { display_name?: string | null; role?: UserRole; onboarding_completed_at?: string | null; updated_at?: string };
        Relationships: never[];
      };
      cohorts: {
        Row: {
          id: string;
          name: string;
          slug: string | null;
          description: string | null;
          start_date: string | null;
          max_participants: number | null;
          price_cents: number;
          is_open: boolean;
          created_at: string;
        };
        Insert: { name: string; slug?: string | null; description?: string | null; start_date?: string | null; max_participants?: number | null; price_cents?: number; is_open?: boolean };
        Update: Partial<Database["public"]["Tables"]["cohorts"]["Insert"]>;
        Relationships: never[];
      };
      cohort_curriculum: {
        Row: {
          id: string;
          cohort_id: string | null;
          week_number: number;
          title: string;
          theme: string | null;
          circle_prompt: string | null;
        };
        Insert: { cohort_id?: string | null; week_number: number; title: string; theme?: string | null; circle_prompt?: string | null };
        Update: Partial<Database["public"]["Tables"]["cohort_curriculum"]["Insert"]>;
        Relationships: never[];
      };
      applications: {
        Row: {
          id: string;
          cohort_id: string | null;
          applicant_name: string;
          applicant_email: string;
          motivation: string | null;
          how_heard: string | null;
          status: ApplicationStatus;
          stripe_checkout_session_id: string | null;
          created_at: string;
          reviewed_at: string | null;
          reviewed_by: string | null;
        };
        Insert: {
          cohort_id?: string | null;
          applicant_name: string;
          applicant_email: string;
          motivation?: string | null;
          how_heard?: string | null;
          status?: ApplicationStatus;
        };
        Update: {
          status?: ApplicationStatus;
          stripe_checkout_session_id?: string | null;
          reviewed_at?: string | null;
          reviewed_by?: string | null;
        };
        Relationships: never[];
      };
      payments: {
        Row: {
          id: string;
          user_id: string | null;
          cohort_id: string | null;
          stripe_session_id: string | null;
          stripe_payment_intent_id: string | null;
          amount_cents: number | null;
          currency: string | null;
          status: PaymentStatus;
          created_at: string;
          completed_at: string | null;
        };
        Insert: {
          user_id?: string | null;
          cohort_id?: string | null;
          stripe_session_id?: string | null;
          stripe_payment_intent_id?: string | null;
          amount_cents?: number | null;
          currency?: string | null;
          status?: PaymentStatus;
        };
        Update: {
          status?: PaymentStatus;
          stripe_payment_intent_id?: string | null;
          completed_at?: string | null;
        };
        Relationships: never[];
      };
      enrollments: {
        Row: {
          id: string;
          user_id: string;
          cohort_id: string;
          payment_id: string | null;
          enrolled_at: string;
        };
        Insert: { user_id: string; cohort_id: string; payment_id?: string | null };
        Update: Partial<Database["public"]["Tables"]["enrollments"]["Insert"]>;
        Relationships: never[];
      };
      practices: {
        Row: {
          id: string;
          title: string;
          category: string | null;
          week_number: number | null;
          duration_minutes: number | null;
          has_audio: boolean;
          audio_path: string | null;
          body_text: string | null;
          created_at: string;
        };
        Insert: { title: string; category?: string | null; week_number?: number | null; duration_minutes?: number | null; has_audio?: boolean; audio_path?: string | null; body_text?: string | null };
        Update: Partial<Database["public"]["Tables"]["practices"]["Insert"]>;
        Relationships: never[];
      };
      civic_lessons: {
        Row: {
          id: string;
          title: string;
          category: string | null;
          estimated_minutes: number | null;
          body_text: string | null;
          reflection_prompt: string | null;
          order_index: number | null;
          created_at: string;
        };
        Insert: { title: string; category?: string | null; estimated_minutes?: number | null; body_text?: string | null; reflection_prompt?: string | null; order_index?: number | null };
        Update: Partial<Database["public"]["Tables"]["civic_lessons"]["Insert"]>;
        Relationships: never[];
      };
      check_ins: {
        Row: {
          id: string;
          user_id: string;
          week_number: number;
          mood_score: number | null;
          body_sensation: string | null;
          one_word: string | null;
          free_note: string | null;
          created_at: string;
        };
        Insert: { user_id: string; week_number: number; mood_score?: number | null; body_sensation?: string | null; one_word?: string | null; free_note?: string | null };
        Update: never;
        Relationships: never[];
      };
      journal_entries: {
        Row: {
          id: string;
          user_id: string;
          week_number: number | null;
          title: string | null;
          body: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: { user_id: string; week_number?: number | null; title?: string | null; body?: string | null };
        Update: { title?: string | null; body?: string | null; updated_at?: string };
        Relationships: never[];
      };
      circle_shares: {
        Row: {
          id: string;
          user_id: string;
          cohort_id: string;
          week_number: number | null;
          content: string;
          is_anonymous: boolean;
          created_at: string;
        };
        Insert: { user_id: string; cohort_id: string; week_number?: number | null; content: string; is_anonymous?: boolean };
        Update: never;
        Relationships: never[];
      };
      circle_comments: {
        Row: {
          id: string;
          share_id: string;
          user_id: string;
          content: string;
          created_at: string;
        };
        Insert: { share_id: string; user_id: string; content: string };
        Update: never;
        Relationships: never[];
      };
      reports: {
        Row: {
          id: string;
          reporter_id: string | null;
          reported_content_id: string | null;
          reported_content_type: string | null;
          reason: string | null;
          status: string;
          resolved_by: string | null;
          created_at: string;
          resolved_at: string | null;
        };
        Insert: { reporter_id?: string | null; reported_content_id?: string | null; reported_content_type?: string | null; reason?: string | null };
        Update: { status?: string; resolved_by?: string | null; resolved_at?: string | null };
        Relationships: never[];
      };
    };
    Views: Record<string, never>;
    Functions: Record<string, never>;
    Enums: Record<string, never>;
  };
}
