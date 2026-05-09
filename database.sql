-- SorteioFácil - Database Schema

-- Perfis dos coordenadores (vinculado ao auth.users do Supabase)
CREATE TABLE IF NOT EXISTS coordenadores (
  id uuid PRIMARY KEY REFERENCES auth.users(id),
  nome text NOT NULL,
  email text NOT NULL,
  criado_em timestamp DEFAULT now()
);

-- Eventos criados pelos coordenadores
CREATE TABLE IF NOT EXISTS eventos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  coordenador_id uuid REFERENCES coordenadores(id) NOT NULL,
  nome text NOT NULL,
  descricao text,
  imagem_capa text,
  slug text UNIQUE NOT NULL, -- usado na URL pública: /evento.html?slug=dia-das-maes-2025
  max_numeros int NOT NULL DEFAULT 100, -- limite de inscrições
  status text DEFAULT 'aberto', -- aberto | encerrado | sorteado
  criado_em timestamp DEFAULT now()
);

-- Participantes inscritos em um evento (Criada antes de premios para garantir referencia de chave estrangeira)
CREATE TABLE IF NOT EXISTS participantes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  evento_id uuid REFERENCES eventos(id) ON DELETE CASCADE,
  nome text NOT NULL,
  whatsapp text NOT NULL,
  numero_inscricao serial,
  criado_em timestamp DEFAULT now(),
  UNIQUE(evento_id, whatsapp) -- mesmo WhatsApp não pode se inscrever duas vezes no mesmo evento
);

-- Prêmios de cada evento
CREATE TABLE IF NOT EXISTS premios (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  evento_id uuid REFERENCES eventos(id) ON DELETE CASCADE,
  nome_parceiro text NOT NULL,
  descricao text NOT NULL,
  imagem text,
  ordem int NOT NULL,
  ganhador_id uuid REFERENCES participantes(id) ON DELETE SET NULL,
  sorteado_em timestamp
);

-- RLS Policies
ALTER TABLE coordenadores ENABLE ROW LEVEL SECURITY;
ALTER TABLE eventos ENABLE ROW LEVEL SECURITY;
ALTER TABLE premios ENABLE ROW LEVEL SECURITY;
ALTER TABLE participantes ENABLE ROW LEVEL SECURITY;

-- Coordenadores: cada um vê e edita só os próprios dados
CREATE POLICY "coord_own" ON coordenadores USING (id = auth.uid());

-- Eventos: coordenador gerencia os seus; público pode ler pelo slug
CREATE POLICY "evento_owner" ON eventos USING (coordenador_id = auth.uid());
CREATE POLICY "evento_public_read" ON eventos FOR SELECT USING (true);

-- Prêmios: coordenador do evento gerencia; público pode ler
CREATE POLICY "premio_owner" ON premios USING (
  evento_id IN (SELECT id FROM eventos WHERE coordenador_id = auth.uid())
);
CREATE POLICY "premio_public_read" ON premios FOR SELECT USING (true);

-- Participantes: qualquer um pode se inscrever; coordenador do evento lê todos
CREATE POLICY "part_insert_public" ON participantes FOR INSERT WITH CHECK (true);
CREATE POLICY "part_owner_read" ON participantes FOR SELECT USING (
  evento_id IN (SELECT id FROM eventos WHERE coordenador_id = auth.uid())
);


-- Safe migrations for existing databases
ALTER TABLE eventos ADD COLUMN IF NOT EXISTS imagem_capa text;
ALTER TABLE premios ADD COLUMN IF NOT EXISTS imagem text;

