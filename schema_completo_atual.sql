-- ==============================================================================
-- SCHEMA COMPLETO E UNIFICADO — APRENDE+
-- Versão: 1.4.0 (Estrutura Real do Banco de Dados)
-- Data de Consolidação: 11 de Junho de 2026
--
-- INSTRUÇÕES DE USO:
-- Este script recria e configura a estrutura inteira do banco de dados no Supabase.
-- Pode ser executado diretamente no SQL Editor do painel online do Supabase.
-- ==============================================================================

-- Habilita as extensões necessárias para UUID e Criptografia
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ==============================================================================
-- PARTE 1: CRIAÇÃO DE TABELAS (DDL)
-- As tabelas estão ordenadas para evitar falhas de restrição de integridade referencial.
-- ==============================================================================

-- 1. INSTITUIÇÕES
CREATE TABLE IF NOT EXISTS public.institutions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    school_type TEXT NOT NULL CHECK (school_type IN ('faculdade', 'escola', 'cursinho')),
    city TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. TURMAS (CLASSES)
CREATE TABLE IF NOT EXISTS public.classes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id UUID REFERENCES public.institutions(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    shift TEXT DEFAULT 'Manhã' CHECK (shift IN ('Manhã', 'Tarde', 'Noite', 'Integral')),
    year TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. USUÁRIOS (USERS)
-- Esta tabela espelha a tabela de autenticação auth.users do Supabase
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY,                          -- Mesmo ID gerado pelo auth.users
    institution_id UUID REFERENCES public.institutions(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    role TEXT NOT NULL CHECK (role IN ('super_admin', 'admin', 'teacher', 'student')),
    must_change_password BOOLEAN DEFAULT true,
    class_id UUID REFERENCES public.classes(id) ON DELETE SET NULL, -- Turma vinculada (para alunos)
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. DISCIPLINAS (SUBJECTS)
CREATE TABLE IF NOT EXISTS public.subjects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id UUID REFERENCES public.institutions(id) ON DELETE CASCADE NOT NULL,
    class_id UUID REFERENCES public.classes(id) ON DELETE SET NULL,
    teacher_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    name TEXT NOT NULL,
    code TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. MATRÍCULAS (SUBJECT ENROLLMENTS)
-- Tabela pivot para relacionar Alunos e Disciplinas (N:M)
CREATE TABLE IF NOT EXISTS public.subject_enrollments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    subject_id UUID REFERENCES public.subjects(id) ON DELETE CASCADE NOT NULL,
    class_id UUID REFERENCES public.classes(id) ON DELETE SET NULL,
    enrolled_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(student_id, subject_id)                -- Impede que o mesmo aluno se matricule duas vezes na mesma disciplina
);

-- 6. AULAS (LESSONS)
-- Armazena os materiais complementares (vídeos e PDFs) publicados pelos professores
CREATE TABLE IF NOT EXISTS public.lessons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subject_id UUID REFERENCES public.subjects(id) ON DELETE CASCADE NOT NULL,
    teacher_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    type TEXT NOT NULL CHECK (type IN ('youtube', 'pdf', 'video')),
    url TEXT NOT NULL,
    duration TEXT,
    published_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. ATIVIDADES (ACTIVITIES)
-- Perguntas e alternativas são guardadas como JSONB flexível no campo 'questions'
CREATE TABLE IF NOT EXISTS public.activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subject_id UUID REFERENCES public.subjects(id) ON DELETE CASCADE NOT NULL,
    teacher_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    instructions TEXT,
    questions JSONB NOT NULL DEFAULT '[]',
    total_points NUMERIC DEFAULT 0,
    deadline_date TIMESTAMP WITH TIME ZONE,
    start_date TIMESTAMP WITH TIME ZONE,
    max_attempts INTEGER DEFAULT 1,
    shuffle_questions BOOLEAN DEFAULT false,
    allow_review BOOLEAN DEFAULT true,
    status TEXT DEFAULT 'draft' CHECK (status IN ('draft', 'published')),
    image TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8. PROVAS (EXAMS)
-- Similar às atividades, porém com peso de nota e tempo em minutos (temporizador)
CREATE TABLE IF NOT EXISTS public.exams (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subject_id UUID REFERENCES public.subjects(id) ON DELETE CASCADE NOT NULL,
    teacher_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    instructions TEXT,
    questions JSONB NOT NULL DEFAULT '[]',
    total_points NUMERIC DEFAULT 0,
    weight NUMERIC DEFAULT 1.0,
    duration_minutes INTEGER NOT NULL DEFAULT 60,
    deadline_date TIMESTAMP WITH TIME ZONE,
    start_date TIMESTAMP WITH TIME ZONE,
    max_attempts INTEGER DEFAULT 1,
    shuffle_questions BOOLEAN DEFAULT false,
    allow_review BOOLEAN DEFAULT false,
    status TEXT DEFAULT 'draft' CHECK (status IN ('draft', 'published')),
    image TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 9. SUBMISSÕES DE ATIVIDADES (ACTIVITY SUBMISSIONS)
CREATE TABLE IF NOT EXISTS public.activity_submissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    activity_id UUID REFERENCES public.activities(id) ON DELETE CASCADE NOT NULL,
    student_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    answers JSONB NOT NULL DEFAULT '{}',          -- Respostas dadas pelo aluno
    auto_score NUMERIC DEFAULT 0,                 -- Nota calculada nas questões de múltipla escolha
    manual_score NUMERIC,                         -- Nota dada pelo professor para dissertativas
    final_score NUMERIC,                          -- Soma de auto_score + manual_score
    teacher_feedback TEXT,                        -- Comentário geral do professor
    submitted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    graded_at TIMESTAMP WITH TIME ZONE,
    status TEXT DEFAULT 'submitted' CHECK (status IN ('submitted', 'late', 'graded')),
    question_feedback JSONB DEFAULT '{}'::jsonb,  -- Comentário por questão específica
    UNIQUE(activity_id, student_id)               -- Apenas um envio por atividade para cada aluno
);

-- 10. SUBMISSÕES DE PROVAS (EXAM SUBMISSIONS)
CREATE TABLE IF NOT EXISTS public.exam_submissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    exam_id UUID REFERENCES public.exams(id) ON DELETE CASCADE NOT NULL,
    student_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    answers JSONB NOT NULL DEFAULT '{}',
    auto_score NUMERIC DEFAULT 0,
    manual_score NUMERIC,
    final_score NUMERIC,
    teacher_feedback TEXT,
    submitted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    graded_at TIMESTAMP WITH TIME ZONE,
    status TEXT DEFAULT 'submitted' CHECK (status IN ('submitted', 'late', 'graded')),
    question_feedback JSONB DEFAULT '{}'::jsonb,
    UNIQUE(exam_id, student_id)
);

-- 11. NOTIFICAÇÕES (NOTIFICATIONS)
-- Usada para envio de avisos de novas tarefas ou notas liberadas
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('activity', 'exam', 'grade', 'system', 'lesson')),
    read BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==============================================================================
-- PARTE 2: FUNÇÕES AUXILIARES E DE SEGURANÇA
-- ==============================================================================

-- Função auxiliar que previne recursão infinita na validação de políticas do RLS
-- Retorna o ID da instituição do usuário autenticado no momento
CREATE OR REPLACE FUNCTION public.get_auth_user_institution()
RETURNS UUID AS $$
  SELECT institution_id FROM public.users WHERE id = auth.uid();
$$ LANGUAGE sql SECURITY DEFINER;

-- ==============================================================================
-- PARTE 3: SEGURANÇA (ROW LEVEL SECURITY - RLS)
-- Habilitação da política de RLS em todas as tabelas
-- ==============================================================================

ALTER TABLE public.institutions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subject_enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exams ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activity_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exam_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- ------------------------------------------------------------------------------
-- POLÍTICAS DE ACESSO PARA USUÁRIOS
-- ------------------------------------------------------------------------------

-- Usuários podem visualizar dados dos demais integrantes da mesma instituição
DROP POLICY IF EXISTS "Permitir leitura de usuários da mesma instituição" ON public.users;
CREATE POLICY "Permitir leitura de usuários da mesma instituição"
ON public.users FOR SELECT
USING (
  institution_id = public.get_auth_user_institution()
);

-- ------------------------------------------------------------------------------
-- POLÍTICAS DE ACESSO PARA DISCIPLINAS E MATRÍCULAS
-- ------------------------------------------------------------------------------

-- Qualquer pessoa da instituição pode ver as disciplinas cadastras
DROP POLICY IF EXISTS "Leitura de disciplinas para todos da instituição" ON public.subjects;
CREATE POLICY "Leitura de disciplinas para todos da instituição"
ON public.subjects FOR SELECT
USING (
  institution_id = public.get_auth_user_institution()
);

-- Controle de leitura de matrículas (alunos veem as suas, professores veem as da disciplina, admins veem todas da instituição)
DROP POLICY IF EXISTS "Leitura de matrículas" ON public.subject_enrollments;
CREATE POLICY "Leitura de matrículas"
ON public.subject_enrollments FOR SELECT
USING (
  student_id = auth.uid()
  OR
  EXISTS (
    SELECT 1 FROM public.subjects s
    WHERE s.id = subject_enrollments.subject_id
    AND s.teacher_id = auth.uid()
  )
  OR
  EXISTS (
    SELECT 1 FROM public.subjects s
    WHERE s.id = subject_enrollments.subject_id
    AND s.institution_id = public.get_auth_user_institution()
    AND EXISTS (
      SELECT 1 FROM public.users u
      WHERE u.id = auth.uid()
      AND u.role IN ('admin', 'super_admin')
    )
  )
);

-- ------------------------------------------------------------------------------
-- POLÍTICAS DE ACESSO PARA AULAS (LESSONS)
-- ------------------------------------------------------------------------------

-- Alunos/professores leem aulas das disciplinas associadas à sua instituição
DROP POLICY IF EXISTS "Leitura de aulas para todos da instituição" ON public.lessons;
CREATE POLICY "Leitura de aulas para todos da instituição"
ON public.lessons FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.users u
    WHERE u.id = auth.uid()
    AND u.institution_id = (SELECT institution_id FROM public.subjects s WHERE s.id = lessons.subject_id)
  )
);

-- Professores criadores da aula ou administradores gerenciam a tabela
DROP POLICY IF EXISTS "Professores e admins gerenciam suas aulas" ON public.lessons;
CREATE POLICY "Professores e admins gerenciam suas aulas"
ON public.lessons FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM public.users u
    WHERE u.id = auth.uid()
    AND u.role IN ('admin', 'super_admin')
  )
  OR teacher_id = auth.uid()
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.users u
    WHERE u.id = auth.uid()
    AND u.role IN ('admin', 'super_admin')
  )
  OR teacher_id = auth.uid()
);

-- ------------------------------------------------------------------------------
-- POLÍTICAS DE ACESSO PARA ATIVIDADES (ACTIVITIES)
-- ------------------------------------------------------------------------------

-- Usuários leem atividades de disciplinas da mesma instituição
DROP POLICY IF EXISTS "Leitura de atividades" ON public.activities;
CREATE POLICY "Leitura de atividades"
ON public.activities FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.users u
    WHERE u.id = auth.uid()
    AND u.institution_id = (SELECT institution_id FROM public.subjects s WHERE s.id = activities.subject_id)
  )
);

-- Inserção de atividades por professores/admins da mesma instituição da disciplina
DROP POLICY IF EXISTS "Professores e admins inserem atividades" ON public.activities;
CREATE POLICY "Professores e admins inserem atividades"
ON public.activities FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.users u
    WHERE u.id = auth.uid()
    AND u.institution_id = (SELECT institution_id FROM public.subjects s WHERE s.id = activities.subject_id)
    AND u.role IN ('teacher', 'admin', 'super_admin')
  )
);

-- Atualização e deleção limitadas ao professor criador ou administradores
DROP POLICY IF EXISTS "Professores e admins atualizam atividades" ON public.activities;
CREATE POLICY "Professores e admins atualizam atividades"
ON public.activities FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM public.users u
    WHERE u.id = auth.uid()
    AND u.role IN ('admin', 'super_admin')
  )
  OR teacher_id = auth.uid()
);

DROP POLICY IF EXISTS "Professores e admins deletam atividades" ON public.activities;
CREATE POLICY "Professores e admins deletam atividades"
ON public.activities FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM public.users u
    WHERE u.id = auth.uid()
    AND u.role IN ('admin', 'super_admin')
  )
  OR teacher_id = auth.uid()
);

-- ------------------------------------------------------------------------------
-- POLÍTICAS DE ACESSO PARA PROVAS (EXAMS)
-- ------------------------------------------------------------------------------

-- Usuários leem provas de disciplinas de sua instituição
DROP POLICY IF EXISTS "Leitura de provas para todos da instituição" ON public.exams;
CREATE POLICY "Leitura de provas para todos da instituição"
ON public.exams FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.users u
    WHERE u.id = auth.uid()
    AND u.institution_id = (SELECT institution_id FROM public.subjects s WHERE s.id = exams.subject_id)
  )
);

-- Inserção por professores/admins da mesma instituição da disciplina
DROP POLICY IF EXISTS "Professores e admins inserem provas" ON public.exams;
CREATE POLICY "Professores e admins inserem provas"
ON public.exams FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.users u
    WHERE u.id = auth.uid()
    AND u.institution_id = (SELECT institution_id FROM public.subjects s WHERE s.id = exams.subject_id)
    AND u.role IN ('teacher', 'admin', 'super_admin')
  )
);

-- Atualização e deleção limitadas ao criador ou administradores
DROP POLICY IF EXISTS "Professores e admins atualizam provas" ON public.exams;
CREATE POLICY "Professores e admins atualizam provas"
ON public.exams FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM public.users u
    WHERE u.id = auth.uid()
    AND u.role IN ('admin', 'super_admin')
  )
  OR teacher_id = auth.uid()
);

DROP POLICY IF EXISTS "Professores e admins deletam provas" ON public.exams;
CREATE POLICY "Professores e admins deletam provas"
ON public.exams FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM public.users u
    WHERE u.id = auth.uid()
    AND u.role IN ('admin', 'super_admin')
  )
  OR teacher_id = auth.uid()
);

-- ------------------------------------------------------------------------------
-- POLÍTICAS DE ACESSO PARA SUBMISSÕES DE ATIVIDADES
-- ------------------------------------------------------------------------------

-- Leitura: alunos leem as suas; professores e admins veem as submissões das atividades sob sua alçada
DROP POLICY IF EXISTS "Leitura de submissões de atividades" ON public.activity_submissions;
CREATE POLICY "Leitura de submissões de atividades"
ON public.activity_submissions FOR SELECT
USING (
  student_id = auth.uid()
  OR
  EXISTS (
    SELECT 1 FROM public.activities a
    WHERE a.id = activity_submissions.activity_id
    AND a.teacher_id = auth.uid()
  )
  OR
  EXISTS (
    SELECT 1 FROM public.activities a
    JOIN public.subjects s ON s.id = a.subject_id
    WHERE a.id = activity_submissions.activity_id
    AND s.institution_id = public.get_auth_user_institution()
    AND EXISTS (
      SELECT 1 FROM public.users u
      WHERE u.id = auth.uid()
      AND u.role IN ('admin', 'super_admin')
    )
  )
);

-- Alunos inserem seus próprios envios
DROP POLICY IF EXISTS "Alunos inserem submissão de atividade" ON public.activity_submissions;
CREATE POLICY "Alunos inserem submissão de atividade"
ON public.activity_submissions FOR INSERT
WITH CHECK (
  student_id = auth.uid()
);

-- Professores/Admins atualizam para atribuir notas ou feedbacks
DROP POLICY IF EXISTS "Professores e admins atualizam submissões de atividades" ON public.activity_submissions;
CREATE POLICY "Professores e admins atualizam submissões de atividades"
ON public.activity_submissions FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM public.activities a
    WHERE a.id = activity_submissions.activity_id
    AND a.teacher_id = auth.uid()
  )
  OR
  EXISTS (
    SELECT 1 FROM public.activities a
    JOIN public.subjects s ON s.id = a.subject_id
    WHERE a.id = activity_submissions.activity_id
    AND s.institution_id = public.get_auth_user_institution()
    AND EXISTS (
      SELECT 1 FROM public.users u
      WHERE u.id = auth.uid()
      AND u.role IN ('admin', 'super_admin')
    )
  )
);

-- ------------------------------------------------------------------------------
-- POLÍTICAS DE ACESSO PARA SUBMISSÕES DE PROVAS
-- ------------------------------------------------------------------------------

-- Leitura: alunos veem as suas próprias; professores/admins veem as da instituição
DROP POLICY IF EXISTS "Leitura de submissões de provas" ON public.exam_submissions;
CREATE POLICY "Leitura de submissões de provas"
ON public.exam_submissions FOR SELECT
USING (
  student_id = auth.uid()
  OR
  EXISTS (
    SELECT 1 FROM public.exams e
    WHERE e.id = exam_submissions.exam_id
    AND e.teacher_id = auth.uid()
  )
  OR
  EXISTS (
    SELECT 1 FROM public.exams e
    JOIN public.subjects s ON s.id = e.subject_id
    WHERE e.id = exam_submissions.exam_id
    AND s.institution_id = public.get_auth_user_institution()
    AND EXISTS (
      SELECT 1 FROM public.users u
      WHERE u.id = auth.uid()
      AND u.role IN ('admin', 'super_admin')
    )
  )
);

-- Alunos inserem suas submissões de provas
DROP POLICY IF EXISTS "Alunos inserem submissão de prova" ON public.exam_submissions;
CREATE POLICY "Alunos inserem submissão de prova"
ON public.exam_submissions FOR INSERT
WITH CHECK (
  student_id = auth.uid()
);

-- Professores/Admins atualizam para correção
DROP POLICY IF EXISTS "Professores e admins atualizam submissões de provas" ON public.exam_submissions;
CREATE POLICY "Professores e admins atualizam submissões de provas"
ON public.exam_submissions FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM public.exams e
    WHERE e.id = exam_submissions.exam_id
    AND e.teacher_id = auth.uid()
  )
  OR
  EXISTS (
    SELECT 1 FROM public.exams e
    JOIN public.subjects s ON s.id = e.subject_id
    WHERE e.id = exam_submissions.exam_id
    AND s.institution_id = public.get_auth_user_institution()
    AND EXISTS (
      SELECT 1 FROM public.users u
      WHERE u.id = auth.uid()
      AND u.role IN ('admin', 'super_admin')
    )
  )
);

-- ------------------------------------------------------------------------------
-- POLÍTICAS DE ACESSO PARA NOTIFICAÇÕES
-- ------------------------------------------------------------------------------

-- Usuários gerenciam apenas suas próprias notificações
DROP POLICY IF EXISTS "users_see_own_notifications" ON public.notifications;
CREATE POLICY "users_see_own_notifications"
ON public.notifications FOR ALL TO authenticated
USING (
  user_id = auth.uid()
);

-- ==============================================================================
-- PARTE 4: SISTEMA DE REALTIME (PUBLICAÇÕES DE EVENTOS)
-- Adiciona tabelas na publicação 'supabase_realtime' para alimentar o front reativo
-- ==============================================================================

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables 
    WHERE pubname = 'supabase_realtime' AND tablename = 'activities'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE activities;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables 
    WHERE pubname = 'supabase_realtime' AND tablename = 'exams'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE exams;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables 
    WHERE pubname = 'supabase_realtime' AND tablename = 'activity_submissions'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE activity_submissions;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables 
    WHERE pubname = 'supabase_realtime' AND tablename = 'exam_submissions'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE exam_submissions;
  END IF;
END
$$;

-- ==============================================================================
-- FIM DO SCHEMA COMPLETO E ATUALIZADO
-- ==============================================================================
