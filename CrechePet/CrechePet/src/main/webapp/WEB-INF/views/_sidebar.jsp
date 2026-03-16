<%@ page import="br.com.creche.model.Usuario" %>
<%
    Usuario _u = (Usuario) session.getAttribute("usuarioLogado");
    String _pag = (String) request.getAttribute("paginaAtiva");
    if (_pag == null) _pag = "";
%>
<style>
:root { --sidebar-w: 250px; --cor-sidebar: #1e3a8a; }
body  { background:#f1f5f9; font-family:'Segoe UI',sans-serif; margin:0; }

.sidebar {
    position:fixed; top:0; left:0;
    width:var(--sidebar-w); height:100vh;
    background:var(--cor-sidebar);
    display:flex; flex-direction:column;
    z-index:100; box-shadow:4px 0 15px rgba(0,0,0,.15);
}
.sidebar-logo {
    padding:1.25rem; border-bottom:1px solid rgba(255,255,255,.1);
    display:flex; align-items:center; gap:.75rem;
}
.sidebar-logo .icon {
    width:40px; height:40px; background:rgba(255,255,255,.15);
    border-radius:10px; display:flex; align-items:center; justify-content:center;
}
.sidebar-logo .icon i { color:#fff; font-size:1.2rem; }
.sidebar-logo span    { color:#fff; font-weight:700; font-size:1.15rem; }
.sidebar-nav  { flex:1; padding:.75rem 0; overflow-y:auto; }
.nav-section  {
    padding:.5rem 1.25rem .2rem;
    font-size:.68rem; font-weight:700;
    color:rgba(255,255,255,.4); letter-spacing:1px; text-transform:uppercase;
}
.nav-item a {
    display:flex; align-items:center; gap:.75rem;
    padding:.65rem 1.25rem; color:rgba(255,255,255,.75);
    text-decoration:none; font-size:.875rem;
    border-left:3px solid transparent; transition:all .2s;
}
.nav-item a:hover, .nav-item a.active {
    background:rgba(255,255,255,.1); color:#fff; border-left-color:#60a5fa;
}
.nav-item a i { font-size:1rem; width:20px; text-align:center; }
.sidebar-footer {
    padding:1rem 1.25rem; border-top:1px solid rgba(255,255,255,.1);
}
.user-info { display:flex; align-items:center; gap:.75rem; margin-bottom:.6rem; }
.user-avatar {
    width:36px; height:36px; background:rgba(255,255,255,.15);
    border-radius:50%; display:flex; align-items:center;
    justify-content:center; color:#fff; font-weight:700;
}
.user-name { color:#fff; font-size:.85rem; font-weight:600; }
.user-role { color:rgba(255,255,255,.5); font-size:.73rem; }
.btn-logout {
    width:100%; background:rgba(255,255,255,.08);
    border:1px solid rgba(255,255,255,.15); color:rgba(255,255,255,.75);
    border-radius:8px; padding:.45rem; font-size:.82rem;
    transition:all .2s; text-decoration:none;
    display:flex; align-items:center; justify-content:center; gap:.5rem;
}
.btn-logout:hover { background:rgba(239,68,68,.2); border-color:rgba(239,68,68,.4); color:#fca5a5; }
.main-content { margin-left:var(--sidebar-w); min-height:100vh; }
.topbar {
    background:#fff; padding:.9rem 2rem;
    border-bottom:1px solid #e2e8f0;
    display:flex; align-items:center; justify-content:space-between;
    box-shadow:0 1px 4px rgba(0,0,0,.05);
}
.topbar h1 { font-size:1.2rem; font-weight:700; color:#1e293b; margin:0; }
.page-body { padding:1.75rem 2rem; }
</style>

<aside class="sidebar">
    <div class="sidebar-logo">
        <div class="icon"><i class="bi bi-house-heart-fill"></i></div>
        <span>CrechePet</span>
    </div>
    <nav class="sidebar-nav">
        <div class="nav-section">Principal</div>
        <div class="nav-item">
            <a href="${pageContext.request.contextPath}/home" class="<%= _pag.equals("home") ? "active":"" %>">
                <i class="bi bi-grid-1x2-fill"></i> Dashboard
            </a>
        </div>
        <div class="nav-section">Cadastros</div>
        <div class="nav-item">
            <a href="${pageContext.request.contextPath}/clientes" class="<%= _pag.equals("clientes") ? "active":"" %>">
                <i class="bi bi-people-fill"></i> Clientes
            </a>
        </div>
        <div class="nav-item">
            <a href="${pageContext.request.contextPath}/pets" class="<%= _pag.equals("pets") ? "active":"" %>">
                <i class="bi bi-heart-fill"></i> Pets
            </a>
        </div>
        <div class="nav-item">
            <a href="${pageContext.request.contextPath}/servicos" class="<%= _pag.equals("servicos") ? "active":"" %>">
                <i class="bi bi-scissors"></i> Serviços
            </a>
        </div>
        <div class="nav-section">Operações</div>
        <div class="nav-item">
            <a href="${pageContext.request.contextPath}/agendamentos" class="<%= _pag.equals("agendamentos") ? "active":"" %>">
                <i class="bi bi-calendar-check-fill"></i> Agendamentos
            </a>
        </div>
        <div class="nav-item">
            <a href="${pageContext.request.contextPath}/financeiro" class="<%= _pag.equals("financeiro") ? "active":"" %>">
                <i class="bi bi-cash-stack"></i> Financeiro
            </a>
        </div>
        <div class="nav-section">Sistema</div>
        <div class="nav-item">
            <a href="${pageContext.request.contextPath}/usuarios" class="<%= _pag.equals("usuarios") ? "active":"" %>">
                <i class="bi bi-shield-person-fill"></i> Usuarios
            </a>
        </div>
    </nav>
    <div class="sidebar-footer">
        <div class="user-info">
            <div class="user-avatar">
                <%= _u != null ? String.valueOf(_u.getNomeCompleto().charAt(0)).toUpperCase() : "?" %>
            </div>
            <div>
                <div class="user-name"><%= _u != null ? _u.getPrimeiroNome() : "UsuÃ¡rio" %></div>
                <div class="user-role"><%= _u != null ? _u.getTipoPerfil() : "" %></div>
            </div>
        </div>
        <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
            <i class="bi bi-box-arrow-left"></i> Sair
        </a>
    </div>
</aside>
