-- Tabla de tareas para Supabase
-- Ejecuta este SQL en el SQL Editor de tu proyecto Supabase

-- Eliminar tabla si existe (por si acaso)
DROP TABLE IF EXISTS public.tasks CASCADE;

-- Crear tabla de tareas
CREATE TABLE public.tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT NOT NULL DEFAULT '',
  completed BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Activar Row Level Security
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;

-- Eliminar políticas si existen
DROP POLICY IF EXISTS "Users can view own tasks" ON public.tasks;
DROP POLICY IF EXISTS "Users can create own tasks" ON public.tasks;
DROP POLICY IF EXISTS "Users can update own tasks" ON public.tasks;
DROP POLICY IF EXISTS "Users can delete own tasks" ON public.tasks;

-- Política: Usuarios solo ven SUS propias tareas
CREATE POLICY "Users can view own tasks"
  ON public.tasks FOR SELECT
  USING (auth.uid() = user_id);

-- Política: Usuarios solo crean SUS propias tareas
CREATE POLICY "Users can create own tasks"
  ON public.tasks FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Política: Usuarios solo actualizan SUS propias tareas
CREATE POLICY "Users can update own tasks"
  ON public.tasks FOR UPDATE
  USING (auth.uid() = user_id);

-- Política: Usuarios solo eliminan SUS propias tareas
CREATE POLICY "Users can delete own tasks"
  ON public.tasks FOR DELETE
  USING (auth.uid() = user_id);

-- Índice para mejorar rendimiento de consultas por usuario
CREATE INDEX IF NOT EXISTS tasks_user_id_idx ON public.tasks(user_id);

-- Verificar que la tabla existe
SELECT 'Tabla tasks creada exitosamente' as resultado;

-- IMPORTANTE: Espera 30 segundos después de ejecutar este SQL
-- antes de probar la app para que el cache se actualice

