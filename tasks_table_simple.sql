-- SQL SIMPLIFICADO - Ejecuta esto en Supabase SQL Editor

-- Eliminar todo si existe
DROP TABLE IF EXISTS public.tasks CASCADE;

-- Crear tabla simple
CREATE TABLE public.tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  completed BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Activar RLS
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;

-- Crear políticas (simple)
CREATE POLICY "task_select_policy" ON public.tasks FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "task_insert_policy" ON public.tasks FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "task_update_policy" ON public.tasks FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "task_delete_policy" ON public.tasks FOR DELETE USING (auth.uid() = user_id);

-- Crear índice
CREATE INDEX tasks_user_id_idx ON public.tasks(user_id);

