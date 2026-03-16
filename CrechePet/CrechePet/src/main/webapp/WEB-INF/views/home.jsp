<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="br.com.creche.model.Usuario" %>
<%@ page import="java.text.NumberFormat, java.util.Locale" %>
<%
    Usuario usuario = (Usuario) session.getAttribute("usuarioLogado");
    NumberFormat moeda = NumberFormat.getCurrencyInstance(new Locale("pt", "BR"));
    double receitaMes = request.getAttribute("receitaMes") != null
        ? (double) request.getAttribute("receitaMes") : 0.0;
%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>CrechePet — Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet"/>
    <style>
        :root {
            --sidebar-w: 250px;
            --cor-sidebar: #1e3a8a;
            --cor-sidebar-hover: rgba(255,255,255,0.1);
            --cor-primaria: #3b82f6;
            --cor-fundo: #f1f5f9;
        }

        body { background: var(--cor-fundo); font-family: 'Segoe UI', sans-serif; margin: 0; }

        /* ── Sidebar ── */
        .sidebar {
            position: fixed; top: 0; left: 0;
            width: var(--sidebar-w); height: 100vh;
            background: var(--cor-sidebar);
            display: flex; flex-direction: column;
            z-index: 100;
            box-shadow: 4px 0 15px rgba(0,0,0,0.15);
        }

        .sidebar-logo {
            padding: 1.5rem 1.25rem;
            border-bottom: 1px solid rgba(255,255,255,0.1);
            display: flex; align-items: center; gap: 0.75rem;
        }

        .sidebar-logo .icon {
            width: 42px; height: 42px;
            background: rgba(255,255,255,0.15);
            border-radius: 10px;
            display: flex; align-items: center; justify-content: center;
        }

        .sidebar-logo .icon i { color: white; font-size: 1.3rem; }
        .sidebar-logo span { color: white; font-weight: 700; font-size: 1.2rem; }

        .sidebar-nav { flex: 1; padding: 1rem 0; overflow-y: auto; }

        .nav-section {
            padding: 0.5rem 1.25rem 0.25rem;
            font-size: 0.7rem;
            font-weight: 700;
            color: rgba(255,255,255,0.4);
            letter-spacing: 1px;
            text-transform: uppercase;
        }

        .nav-item a {
            display: flex; align-items: center; gap: 0.75rem;
            padding: 0.7rem 1.25rem;
            color: rgba(255,255,255,0.75);
            text-decoration: none;
            font-size: 0.9rem;
            border-left: 3px solid transparent;
            transition: all 0.2s;
        }

        .nav-item a:hover, .nav-item a.active {
            background: var(--cor-sidebar-hover);
            color: white;
            border-left-color: #60a5fa;
        }

        .nav-item a i { font-size: 1.1rem; width: 20px; text-align: center; }

        .sidebar-footer {
            padding: 1rem 1.25rem;
            border-top: 1px solid rgba(255,255,255,0.1);
        }

        .user-info {
            display: flex; align-items: center; gap: 0.75rem; margin-bottom: 0.75rem;
        }

        .user-avatar {
            width: 38px; height: 38px;
            background: rgba(255,255,255,0.15);
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            color: white; font-weight: 700;
        }

        .user-name { color: white; font-size: 0.875rem; font-weight: 600; }
        .user-role { color: rgba(255,255,255,0.5); font-size: 0.75rem; }

        .btn-logout {
            width: 100%;
            background: rgba(255,255,255,0.08);
            border: 1px solid rgba(255,255,255,0.15);
            color: rgba(255,255,255,0.75);
            border-radius: 8px;
            padding: 0.5rem;
            font-size: 0.85rem;
            transition: all 0.2s;
            text-decoration: none;
            display: flex; align-items: center; justify-content: center; gap: 0.5rem;
        }

        .btn-logout:hover {
            background: rgba(239,68,68,0.2);
            border-color: rgba(239,68,68,0.4);
            color: #fca5a5;
        }

        /* ── Main Content ── */
        .main-content {
            margin-left: var(--sidebar-w);
            min-height: 100vh;
            padding: 0;
        }

        /* ── Topbar ── */
        .topbar {
            background: white;
            padding: 1rem 2rem;
            border-bottom: 1px solid #e2e8f0;
            display: flex; align-items: center; justify-content: space-between;
            box-shadow: 0 1px 4px rgba(0,0,0,0.05);
        }

        .topbar h1 { font-size: 1.3rem; font-weight: 700; color: #1e293b; margin: 0; }
        .topbar small { color: #64748b; font-size: 0.85rem; }

        /* ── Page body ── */
        .page-body { padding: 2rem; }

        /* ── Stat Cards ── */
        .stat-card {
            background: white;
            border-radius: 16px;
            padding: 1.5rem;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
            transition: transform 0.2s, box-shadow 0.2s;
            height: 100%;
        }

        .stat-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 20px rgba(0,0,0,0.1);
        }

        .stat-icon {
            width: 52px; height: 52px; border-radius: 14px;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.4rem; margin-bottom: 1rem;
        }

        .stat-card .stat-value { font-size: 2rem; font-weight: 800; color: #1e293b; }
        .stat-card .stat-label { color: #64748b; font-size: 0.875rem; margin-top: 0.25rem; }

        .icon-blue   { background: #eff6ff; color: #3b82f6; }
        .icon-green  { background: #f0fdf4; color: #22c55e; }
        .icon-orange { background: #fff7ed; color: #f97316; }
        .icon-purple { background: #faf5ff; color: #a855f7; }
        .icon-teal   { background: #f0fdfa; color: #14b8a6; }

        /* ── Quick Access Cards ── */
        .quick-card {
            background: white;
            border-radius: 14px;
            padding: 1.25rem;
            text-decoration: none;
            color: inherit;
            display: flex; align-items: center; gap: 1rem;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
            transition: all 0.2s;
            border: 1.5px solid transparent;
        }

        .quick-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(0,0,0,0.1);
            border-color: var(--cor-primaria);
            color: var(--cor-primaria);
        }

        .quick-card .q-icon {
            width: 46px; height: 46px; border-radius: 12px;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.3rem; flex-shrink: 0;
        }

        .quick-card .q-label { font-weight: 600; font-size: 0.9rem; }
        .quick-card .q-sub   { font-size: 0.78rem; color: #94a3b8; }

        /* ── Section Header ── */
        .section-title {
            font-size: 1rem; font-weight: 700; color: #1e293b;
            margin-bottom: 1rem; display: flex; align-items: center; gap: 0.5rem;
        }

        /* ── Alert error ── */
        .alert-db {
            background: #fef9c3; border: 1px solid #fde047;
            border-radius: 10px; padding: 0.75rem 1rem;
            font-size: 0.85rem; color: #92400e; margin-bottom: 1.5rem;
        }
    </style>
</head>
<body>

<!-- ═══════════════════ SIDEBAR ═══════════════════ -->
<aside class="sidebar">
    <div class="sidebar-logo">
        <div class="icon"><i class="bi bi-house-heart-fill"></i></div>
        <span>CrechePet</span>
    </div>

    <nav class="sidebar-nav">
        <div class="nav-section">Principal</div>
        <div class="nav-item">
            <a href="${pageContext.request.contextPath}/home" class="active">
                <i class="bi bi-grid-1x2-fill"></i> Dashboard
            </a>
        </div>

        <div class="nav-section">Cadastros</div>
        <div class="nav-item">
            <a href="${pageContext.request.contextPath}/clientes">
                <i class="bi bi-people-fill"></i> Clientes
            </a>
        </div>
        <div class="nav-item">
            <a href="${pageContext.request.contextPath}/pets">
                <i class="bi bi-heart-fill"></i> Pets
            </a>
        </div>
        <div class="nav-item">
            <a href="${pageContext.request.contextPath}/servicos">
                <i class="bi bi-scissors"></i> Serviços
            </a>
        </div>

        <div class="nav-section">Operações</div>
        <div class="nav-item">
            <a href="${pageContext.request.contextPath}/agendamentos">
                <i class="bi bi-calendar-check-fill"></i> Agendamentos
            </a>
        </div>
        <div class="nav-item">
            <a href="${pageContext.request.contextPath}/financeiro">
                <i class="bi bi-cash-stack"></i> Financeiro
            </a>
        </div>

        <div class="nav-section">Sistema</div>
        <div class="nav-item">
            <a href="${pageContext.request.contextPath}/usuarios">
                <i class="bi bi-shield-person-fill"></i> Usuários
            </a>
        </div>
    </nav>

    <div class="sidebar-footer">
        <div class="user-info">
            <div class="user-avatar">
                <%= usuario != null ? String.valueOf(usuario.getNomeCompleto().charAt(0)).toUpperCase() : "?" %>
            </div>
            <div>
                <div class="user-name"><%= usuario != null ? usuario.getPrimeiroNome() : "Usuário" %></div>
                <div class="user-role"><%= usuario != null ? usuario.getTipoPerfil() : "" %></div>
            </div>
        </div>
        <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
            <i class="bi bi-box-arrow-left"></i> Sair
        </a>
    </div>
</aside>

<!-- ═══════════════════ MAIN ═══════════════════ -->
<div class="main-content">

    <!-- Topbar -->
    <div class="topbar">
        <div>
            <h1><i class="bi bi-grid-1x2 me-2 text-primary"></i>Dashboard</h1>
            <small>Bem-vindo de volta, <strong><%= usuario != null ? usuario.getPrimeiroNome() : "Usuário" %></strong>!</small>
        </div>
        <small class="text-muted">
            <i class="bi bi-clock me-1"></i>
            <span id="relogio"></span>
        </small>
    </div>

    <div class="page-body">

        <%-- Alerta de erro de banco --%>
        <% if (request.getAttribute("erroDb") != null) { %>
        <div class="alert-db">
            <i class="bi bi-exclamation-triangle me-2"></i><%= request.getAttribute("erroDb") %>
        </div>
        <% } %>

        <!-- ── Cards de Estatísticas ── -->
        <div class="row g-3 mb-4">
            <div class="col-xl-3 col-md-6">
                <div class="stat-card">
                    <div class="stat-icon icon-blue"><i class="bi bi-people-fill"></i></div>
                    <div class="stat-value"><%= request.getAttribute("totalClientes") %></div>
                    <div class="stat-label">Clientes Cadastrados</div>
                </div>
            </div>
            <div class="col-xl-3 col-md-6">
                <div class="stat-card">
                    <div class="stat-icon icon-green"><i class="bi bi-heart-fill"></i></div>
                    <div class="stat-value"><%= request.getAttribute("totalPets") %></div>
                    <div class="stat-label">Pets Cadastrados</div>
                </div>
            </div>
            <div class="col-xl-3 col-md-6">
                <div class="stat-card">
                    <div class="stat-icon icon-orange"><i class="bi bi-calendar-check-fill"></i></div>
                    <div class="stat-value"><%= request.getAttribute("agendamentosHoje") %></div>
                    <div class="stat-label">Agendamentos Hoje</div>
                </div>
            </div>
            <div class="col-xl-3 col-md-6">
                <div class="stat-card">
                    <div class="stat-icon icon-teal"><i class="bi bi-cash-coin"></i></div>
                    <div class="stat-value" style="font-size:1.4rem">
                        <%= moeda.format(receitaMes) %>
                    </div>
                    <div class="stat-label">Receita do Mês</div>
                </div>
            </div>
        </div>

        <!-- ── Acesso Rápido ── -->
        <div class="section-title">
            <i class="bi bi-lightning-charge-fill text-warning"></i> Acesso Rápido
        </div>
        <div class="row g-3 mb-4">
            <div class="col-lg-4 col-md-6">
                <a href="${pageContext.request.contextPath}/clientes" class="quick-card">
                    <div class="q-icon icon-blue"><i class="bi bi-person-plus-fill"></i></div>
                    <div>
                        <div class="q-label">Clientes</div>
                        <div class="q-sub">Cadastrar e gerenciar clientes</div>
                    </div>
                </a>
            </div>
            <div class="col-lg-4 col-md-6">
                <a href="${pageContext.request.contextPath}/pets" class="quick-card">
                    <div class="q-icon icon-green"><i class="bi bi-heart-fill"></i></div>
                    <div>
                        <div class="q-label">Pets</div>
                        <div class="q-sub">Cadastrar e gerenciar pets</div>
                    </div>
                </a>
            </div>
            <div class="col-lg-4 col-md-6">
                <a href="${pageContext.request.contextPath}/agendamentos" class="quick-card">
                    <div class="q-icon icon-orange"><i class="bi bi-calendar-plus-fill"></i></div>
                    <div>
                        <div class="q-label">Agendamentos</div>
                        <div class="q-sub">Novo agendamento de serviço</div>
                    </div>
                </a>
            </div>
            <div class="col-lg-4 col-md-6">
                <a href="${pageContext.request.contextPath}/servicos" class="quick-card">
                    <div class="q-icon icon-purple"><i class="bi bi-scissors"></i></div>
                    <div>
                        <div class="q-label">Serviços</div>
                        <div class="q-sub">Banho, tosa e outros serviços</div>
                    </div>
                </a>
            </div>
            <div class="col-lg-4 col-md-6">
                <a href="${pageContext.request.contextPath}/financeiro" class="quick-card">
                    <div class="q-icon icon-teal"><i class="bi bi-cash-stack"></i></div>
                    <div>
                        <div class="q-label">Financeiro</div>
                        <div class="q-sub">Receitas e despesas</div>
                    </div>
                </a>
            </div>
            <div class="col-lg-4 col-md-6">
                <a href="${pageContext.request.contextPath}/usuarios" class="quick-card">
                    <div class="q-icon" style="background:#fef3c7;color:#d97706">
                        <i class="bi bi-shield-person-fill"></i>
                    </div>
                    <div>
                        <div class="q-label">Usuários</div>
                        <div class="q-sub">Gerenciar acessos ao sistema</div>
                    </div>
                </a>
            </div>
        </div>

        <!-- ── Pendentes ── -->
        <% int pendentes = request.getAttribute("agendamentosPendentes") != null
               ? (int) request.getAttribute("agendamentosPendentes") : 0;
           if (pendentes > 0) { %>
        <div class="alert alert-warning d-flex align-items-center gap-2 rounded-3" role="alert">
            <i class="bi bi-exclamation-triangle-fill fs-5"></i>
            <div>
                Você tem <strong><%= pendentes %> agendamento(s) pendente(s)</strong> aguardando confirmação.
                <a href="${pageContext.request.contextPath}/agendamentos" class="alert-link ms-1">Ver agendamentos →</a>
            </div>
        </div>
        <% } %>

    </div><!-- /page-body -->
</div><!-- /main-content -->

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Relógio em tempo real no topbar
    function atualizarRelogio() {
        const agora = new Date();
        document.getElementById('relogio').textContent =
            agora.toLocaleDateString('pt-BR', {weekday:'long', day:'2-digit', month:'long'})
            + ' • ' + agora.toLocaleTimeString('pt-BR', {hour:'2-digit', minute:'2-digit'});
    }
    atualizarRelogio();
    setInterval(atualizarRelogio, 1000);
</script>
</body>
</html>
