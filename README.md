# RT Mobile Barber • SaaS Multi-Tenant

Sistema de gestão operacional, vitrine e agendamento para barbearias do ecossistema RT Mobile.

## 🚀 Tecnologias
- **Backend:** Node.js + Express
- **Banco de Dados:** Supabase (PostgreSQL) com isolamento por `tenant_id`
- **Deploy:** Render (Web Service contínuo integrado ao GitHub)
- **Frontend:** Mobile-first nativo (sem dependências quebradiças)

## 📌 Passo a Passo de Instalação e Deploy

### 1. Supabase
1. Crie um projeto no [Supabase](https://supabase.com).
2. Vá em **SQL Editor** e execute o conteúdo de `sql/schema.sql`.
3. Em **Project Settings > API**, copie a **Project URL** e a **service_role key**.

### 2. GitHub
1. Crie um repositório no seu GitHub chamado `rt-mobile-barber`.
2. No seu terminal, inicialize e envie o código:
   ```bash
   git init
   git add .
   git commit -m "feat: RT Mobile Barber SaaS final"
   git branch -M main
   git remote add origin https://github.com/SEU_USUARIO/rt-mobile-barber.git
   git push -u origin main
   ```

### 3. Render
1. Crie um novo **Web Service** no [Render](https://render.com) conectando o repositório do GitHub.
2. Defina:
   - **Build Command:** `npm install`
   - **Start Command:** `npm start`
3. Em **Environment Variables**, adicione:
   - `SUPABASE_URL` = sua URL do Supabase
   - `SUPABASE_SERVICE_ROLE_KEY` = sua chave service role do Supabase
   - `PORT` = `3000`
4. Clique em **Deploy**. Sua aplicação estará online em menos de 2 minutos!
