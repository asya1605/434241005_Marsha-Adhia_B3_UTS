-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.tickets (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  title text NOT NULL,
  description text,
  status text DEFAULT '"Open"'::text,
  user_id uuid,
  assigned_to uuid,
  image_url text,
  category text,
  priority text,
  CONSTRAINT tickets_pkey PRIMARY KEY (id),
  CONSTRAINT fk_assigned_to_user FOREIGN KEY (assigned_to) REFERENCES public.user_profiles(id)
);
CREATE TABLE public.comments (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  ticket_id uuid,
  user_id uuid,
  message text NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  role text,
  CONSTRAINT comments_pkey PRIMARY KEY (id),
  CONSTRAINT comments_ticket_id_fkey FOREIGN KEY (ticket_id) REFERENCES public.tickets(id)
);
CREATE TABLE public.user_profiles (
  id uuid NOT NULL,
  email text,
  role text DEFAULT 'user'::text CHECK (role = ANY (ARRAY['user'::text, 'helpdesk'::text, 'admin'::text])),
  created_at timestamp without time zone DEFAULT now(),
  is_active boolean DEFAULT true,
  display_name text NOT NULL,
  phone text,
  avatar_url text,
  department text,
  last_login timestamp without time zone,
  CONSTRAINT user_profiles_pkey PRIMARY KEY (id),
  CONSTRAINT user_profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);
CREATE TABLE public.notifications (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid,
  title text,
  message text,
  ticket_id uuid,
  is_read boolean DEFAULT false,
  created_at timestamp without time zone DEFAULT now(),
  CONSTRAINT notifications_pkey PRIMARY KEY (id)
);
CREATE TABLE public.ticket_history (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  ticket_id uuid NOT NULL,
  action text NOT NULL,
  old_value text,
  new_value text,
  changed_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT ticket_history_pkey PRIMARY KEY (id),
  CONSTRAINT ticket_history_ticket_id_fkey FOREIGN KEY (ticket_id) REFERENCES public.tickets(id),
  CONSTRAINT ticket_history_changed_by_fkey FOREIGN KEY (changed_by) REFERENCES public.user_profiles(id)
);
CREATE TABLE public.user_profiles_backup (
  id uuid,
  name text,
  role text,
  created_at timestamp without time zone,
  is_active boolean
);
