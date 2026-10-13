-- ====================================================================
-- ECOSSISTEMA RT MOBILE BARBER • SCRIPT SQL SUPABASE (POSTGRESQL)
-- ====================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. TABELA DE ESTABELECIMENTOS (TENANTS)
CREATE TABLE IF NOT EXISTS tenants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    slug VARCHAR(60) UNIQUE NOT NULL, -- link ex: rtmobilebarber
    name VARCHAR(120) NOT NULL DEFAULT 'RT Mobile Barber',
    logo_url TEXT DEFAULT '',
    address TEXT DEFAULT 'Centro, Santa Izabel do Pará – PA',
    hero_title VARCHAR(120) DEFAULT 'CORTE FINO. ESTILO PURO.',
    hero_subtitle TEXT DEFAULT 'Ambiente climatizado, navalha afiada e atendimento premium.',
    hero_image_url TEXT DEFAULT 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?q=80&w=900',
    phone_whatsapp VARCHAR(30) DEFAULT '5591984551100',
    pix_key VARCHAR(120) DEFAULT 'contato@rtmobilebarber.com.br',
    pix_receiver_name VARCHAR(120) DEFAULT 'RT Mobile Barbearia LTDA',
    
    -- Status da Assinatura SaaS
    plan_status VARCHAR(20) DEFAULT 'active', -- 'trial', 'active', 'past_due', 'canceled'
    monthly_fee NUMERIC(10,2) DEFAULT 50.00,
    trial_expires_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() + INTERVAL '48 HOURS'),
    
    -- Toggles de Configuração
    online_booking_enabled BOOLEAN DEFAULT true,
    require_deposit BOOLEAN DEFAULT false,
    deposit_percentage NUMERIC(5,2) DEFAULT 30.00,
    hide_zero_stock BOOLEAN DEFAULT true,
    auto_whatsapp_notification BOOLEAN DEFAULT true,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. TABELA DE USUÁRIOS & OPERADORES
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(30) NOT NULL,
    role VARCHAR(30) DEFAULT 'barber', -- 'super_admin', 'owner', 'barber', 'client'
    commission_pct NUMERIC(5,2) DEFAULT 50.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. SERVIÇOS DO ESTABELECIMENTO (CHAVES ON/OFF & LETRAS MAIÚSCULAS)
CREATE TABLE IF NOT EXISTS services (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL, -- Forçado sempre em MAIÚSCULAS
    price NUMERIC(10,2) NOT NULL,
    duration_min INT DEFAULT 30,
    is_active BOOLEAN DEFAULT true,
    is_combo BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. ESTOQUE & PRODUTOS DO BALCÃO
CREATE TABLE IF NOT EXISTS products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(60) DEFAULT 'Pomadas',
    price NUMERIC(10,2) NOT NULL,
    cost_price NUMERIC(10,2) DEFAULT 0.00,
    stock_qty INT DEFAULT 0,
    image_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. AGENDAMENTOS E ATENDIMENTOS
CREATE TABLE IF NOT EXISTS appointments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
    client_name VARCHAR(100) NOT NULL,
    client_phone VARCHAR(30) NOT NULL,
    barber_id UUID REFERENCES users(id),
    service_names TEXT[] NOT NULL,
    total_amount NUMERIC(10,2) NOT NULL,
    appointment_at TIMESTAMP WITH TIME ZONE NOT NULL,
    status VARCHAR(30) DEFAULT 'active', -- 'active', 'in_progress', 'finished', 'canceled'
    payment_method VARCHAR(30) DEFAULT 'PIX',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. FECHAMENTO CEGO DE CAIXA (FINANCEIRO DONO)
CREATE TABLE IF NOT EXISTS cash_registers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
    opened_by UUID REFERENCES users(id),
    cash_drawer NUMERIC(10,2) NOT NULL,
    card_receipts NUMERIC(10,2) NOT NULL,
    pix_receipts NUMERIC(10,2) NOT NULL,
    system_expected NUMERIC(10,2) NOT NULL,
    difference NUMERIC(10,2) NOT NULL,
    closed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- INSERIR ESTABELECIMENTO PADRÃO RT MOBILE BARBER
INSERT INTO tenants (slug, name, address, hero_title, hero_subtitle, phone_whatsapp, pix_key, pix_receiver_name)
VALUES (
    'rtmobilebarber',
    'RT Mobile Barber',
    'Centro, Santa Izabel do Pará – PA',
    'CORTE FINO. ESTILO PURO.',
    'Ambiente climatizado, navalha afiada e atendimento premium.',
    '5591984551100',
    'contato@rtmobilebarber.com.br',
    'RT Mobile Barbearia LTDA'
) ON CONFLICT (slug) DO NOTHING;
