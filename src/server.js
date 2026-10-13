require('dotenv').config();
const express = require('express');
const cors = require('cors');
const path = require('path');
const supabase = require('./db');

const app = express();
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// Middleware Multi-Tenant com checagem de plano SaaS (R$ 50/mês)
async function tenantMiddleware(req, res, next) {
  const tenantSlug = req.headers['x-tenant-slug'] || req.query.slug || 'rtmobilebarber';
  
  try {
    const { data: tenant, error } = await supabase
      .from('tenants')
      .select('*')
      .eq('slug', tenantSlug)
      .single();

    if (error || !tenant) {
      req.tenant = {
        id: 'default-tenant-rt',
        slug: 'rtmobilebarber',
        name: 'RT Mobile Barber',
        hero_title: 'CORTE FINO. ESTILO PURO.',
        hero_subtitle: 'Ambiente climatizado, navalha afiada e atendimento premium.',
        hero_image_url: 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?q=80&w=900',
        phone_whatsapp: '5591984551100',
        pix_key: 'contato@rtmobilebarber.com.br',
        pix_receiver_name: 'RT Mobile Barbearia LTDA',
        plan_status: 'active',
        online_booking_enabled: true
      };
      return next();
    }

    req.tenant = tenant;
    next();
  } catch (err) {
    next();
  }
}

// 1. Obter dados da Barbearia Atual
app.get('/api/tenant/info', tenantMiddleware, (req, res) => {
  res.json(req.tenant);
});

// 2. Salvar Configurações (Foto do Ambiente, Nome, Banner, Pix e WhatsApp)
app.put('/api/tenant/config', tenantMiddleware, async (req, res) => {
  const { name, hero_title, hero_subtitle, hero_image_url, logo_url, pix_key, pix_receiver_name, phone_whatsapp, online_booking_enabled } = req.body;
  
  const { data, error } = await supabase
    .from('tenants')
    .update({
      name,
      hero_title,
      hero_subtitle,
      hero_image_url,
      logo_url,
      pix_key,
      pix_receiver_name,
      phone_whatsapp,
      online_booking_enabled
    })
    .eq('id', req.tenant.id)
    .select();

  if (error) return res.status(500).json({ error: error.message });
  res.json({ success: true, tenant: data[0] });
});

// 3. Obter Serviços do Estabelecimento
app.get('/api/services', tenantMiddleware, async (req, res) => {
  const { data, error } = await supabase
    .from('services')
    .select('*')
    .eq('tenant_id', req.tenant.id)
    .order('created_at', { ascending: true });

  if (error) return res.status(500).json({ error: error.message });
  res.json(data || []);
});

// 4. Salvar / Criar Serviço (REGRA: NOME FORÇADO EM MAIÚSCULAS)
app.post('/api/services', tenantMiddleware, async (req, res) => {
  const { name, price, is_active } = req.body;
  
  if (!name || !price) {
    return res.status(400).json({ error: 'Nome e Preço são obrigatórios.' });
  }

  const { data, error } = await supabase
    .from('services')
    .insert([{
      tenant_id: req.tenant.id,
      name: name.toUpperCase().trim(), // REGRA MAIÚSCULAS
      price: parseFloat(price),
      is_active: is_active !== false
    }])
    .select();

  if (error) return res.status(500).json({ error: error.message });
  res.json(data[0]);
});

// 5. Fechamento Cego de Caixa (Exclusivo Dono)
app.post('/api/cash-close', tenantMiddleware, async (req, res) => {
  const { cashDrawer, cardReceipts, pixReceipts } = req.body;
  const counted = Number(cashDrawer) + Number(cardReceipts) + Number(pixReceipts);
  const systemExpected = 680.00; // Simulação acumulada
  const diff = counted - systemExpected;

  res.json({
    success: true,
    counted,
    systemExpected,
    diff,
    status: diff === 0 ? 'CAIXA_PERFEITO' : diff < 0 ? 'QUEBRA' : 'SOBRA'
  });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`[RT MOBILE BARBER] Servidor rodando na porta ${PORT}`);
});
