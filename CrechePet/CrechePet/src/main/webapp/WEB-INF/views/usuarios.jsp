<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, br.com.creche.model.Usuario" %>
<%
    List<Usuario> usuarios = (List<Usuario>) request.getAttribute("usuarios");
    Usuario editar         = (Usuario)       request.getAttribute("usuarioEditar");
    Usuario logado         = (Usuario)       session.getAttribute("usuarioLogado");
    boolean isAdmin        = request.getAttribute("isAdmin") != null && (Boolean) request.getAttribute("isAdmin");
    if (usuarios == null) usuarios = new java.util.ArrayList<>();
    String msg = (String) request.getAttribute("msg");
%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8"/><meta name="viewport" content="width=device-width,initial-scale=1"/>
    <title>CrechePet — Usuários</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet"/>
</head>
<body>
<jsp:include page="_sidebar.jsp"/>
<jsp:include page="_sortable.jsp"/>

<div class="main-content">
    <div class="topbar">
        <h1><i class="bi bi-shield-person-fill me-2" style="color:#d97706"></i>Usuários do Sistema</h1>
        <button class="btn btn-sm btn-warning text-dark" data-bs-toggle="modal" data-bs-target="#modalUsuario" onclick="limparModal()">
            <i class="bi bi-plus-lg me-1"></i>Novo Usuário
        </button>
    </div>
    <div class="page-body">

        <% if ("salvo".equals(msg)) { %>
        <div class="alert alert-success alert-dismissible fade show rounded-3">
            <i class="bi bi-check-circle-fill me-2"></i>Usuário salvo!
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } else if ("excluido".equals(msg)) { %>
        <div class="alert alert-warning alert-dismissible fade show rounded-3">
            <i class="bi bi-trash-fill me-2"></i>Usuário excluído.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } else if ("auto".equals(msg)) { %>
        <div class="alert alert-danger alert-dismissible fade show rounded-3">
            <i class="bi bi-exclamation-triangle-fill me-2"></i>Você não pode excluir seu próprio usuário!
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } else if ("sem_permissao".equals(msg)) { %>
        <div class="alert alert-danger alert-dismissible fade show rounded-3">
            <i class="bi bi-lock-fill me-2"></i><strong>Acesso negado!</strong> Apenas administradores podem excluir usuários.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } else if ("email_dup".equals(msg)) { %>
        <div class="alert alert-danger alert-dismissible fade show rounded-3">
            <i class="bi bi-exclamation-circle-fill me-2"></i><strong>E-mail já cadastrado!</strong> Outro usuário já usa este e-mail.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>

        <% if (!isAdmin) { %>
        <div class="alert alert-info rounded-3 py-2">
            <i class="bi bi-info-circle-fill me-2"></i>
            Apenas <strong>Administradores</strong> podem excluir usuários.
        </div>
        <% } %>

        <div class="card border-0 shadow-sm rounded-3">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0" id="tblUsuarios">
                        <thead class="table-light">
                            <tr>
                                <th class="sortable-th" onclick="sortTable('tblUsuarios',0,'number')">#</th>
                                <th class="sortable-th" onclick="sortTable('tblUsuarios',1,'string')">Nome</th>
                                <th class="sortable-th" onclick="sortTable('tblUsuarios',2,'string')">E-mail</th>
                                <th class="sortable-th" onclick="sortTable('tblUsuarios',3,'string')">Perfil</th>
                                <th class="sortable-th" onclick="sortTable('tblUsuarios',4,'string')">Telefone</th>
                                <th class="sortable-th" onclick="sortTable('tblUsuarios',5,'date')">Cadastro</th>
                                <th class="text-center">Ações</th>
                            </tr>
                        </thead>
                        <tbody>
                        <% if (usuarios.isEmpty()) { %>
                            <tr><td colspan="7" class="text-center text-muted py-4">Nenhum usuário cadastrado.</td></tr>
                        <% } else { for (Usuario u : usuarios) {
                               boolean ehLogado = logado != null && logado.getIdUsuario() == u.getIdUsuario();
                               String corPerfil = "bg-primary";
                               if ("Administrador".equals(u.getTipoPerfil())) corPerfil = "bg-danger";
                               else if ("Gerente".equals(u.getTipoPerfil())) corPerfil = "bg-info";
                        %>
                            <tr class="<%= ehLogado?"table-warning":"" %>">
                                <td><span class="badge bg-secondary"><%= u.getIdUsuario() %></span></td>
                                <td class="fw-semibold">
                                    <%= u.getNomeCompleto() %>
                                    <% if (ehLogado) { %><span class="badge bg-warning text-dark ms-1">Você</span><% } %>
                                </td>
                                <td><%= u.getEmail() %></td>
                                <td><span class="badge <%= corPerfil %>"><%= u.getTipoPerfil() %></span></td>
                                <td><%= u.getTelefone()!=null?u.getTelefone():"—" %></td>
                                <td>
                                    <%= u.getDataCadastro()!=null
                                        ? u.getDataCadastro().format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy"))
                                        : "—" %>
                                </td>
                                <td class="text-center">
                                    <button class="btn btn-sm btn-outline-primary me-1"
                                        data-bs-toggle="modal" data-bs-target="#modalUsuario"
                                        onclick="editarUsuario(<%= u.getIdUsuario() %>,'<%= u.getNomeCompleto().replace("'","\\'") %>','<%= u.getEmail() %>','<%= u.getTipoPerfil() %>','<%= u.getTelefone()!=null?u.getTelefone():"" %>')">
                                        <i class="bi bi-pencil-fill"></i>
                                    </button>
                                    <% if (isAdmin && !ehLogado) { %>
                                    <a href="${pageContext.request.contextPath}/usuarios?acao=excluir&id=<%= u.getIdUsuario() %>"
                                       class="btn btn-sm btn-outline-danger"
                                       onclick="return confirm('Excluir usuário <%= u.getNomeCompleto().replace("'","\\'") %>?')">
                                        <i class="bi bi-trash-fill"></i>
                                    </a>
                                    <% } else if (!isAdmin) { %>
                                    <button class="btn btn-sm btn-outline-secondary" disabled title="Apenas admins podem excluir">
                                        <i class="bi bi-lock-fill"></i>
                                    </button>
                                    <% } %>
                                </td>
                            </tr>
                        <% } } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="modalUsuario" tabindex="-1">
    <div class="modal-dialog">
        <form method="POST" action="${pageContext.request.contextPath}/usuarios">
        <div class="modal-content">
            <div class="modal-header" style="background:#d97706">
                <h5 class="modal-title text-white"><i class="bi bi-person-badge-fill me-2"></i><span id="modalTitulo">Novo Usuário</span></h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <input type="hidden" name="acao" id="inputAcao" value="salvar"/>
                <input type="hidden" name="id"   id="inputId"   value="0"/>
                <div class="row g-3">
                    <div class="col-12">
                        <label class="form-label fw-semibold">Nome Completo <span class="text-danger">*</span></label>
                        <input type="text" name="nomeCompleto" id="inputNome" class="form-control" required/>
                    </div>
                    <div class="col-md-8">
                        <label class="form-label fw-semibold">E-mail <span class="text-danger">*</span></label>
                        <input type="email" name="email" id="inputEmail" class="form-control" required/>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fw-semibold">Telefone</label>
                        <input type="text" name="telefone" id="inputTel" class="form-control"/>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Perfil <span class="text-danger">*</span></label>
                        <select name="tipoPerfil" id="inputPerfil" class="form-select" required>
                            <option value="Atendente">Atendente</option>
                            <option value="Administrador">Administrador</option>
                            <option value="Gerente">Gerente</option>
                        </select>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">
                            Senha <span id="senhaObs" class="text-muted small">(obrigatório)</span>
                        </label>
                        <input type="password" name="senha" id="inputSenha" class="form-control" placeholder="••••••••"/>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                <button type="submit" class="btn btn-warning text-dark"><i class="bi bi-check-lg me-1"></i>Salvar</button>
            </div>
        </div>
        </form>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
function limparModal() {
    document.getElementById('modalTitulo').textContent = 'Novo Usuário';
    document.getElementById('inputAcao').value  = 'salvar';
    document.getElementById('inputId').value    = '0';
    ['inputNome','inputEmail','inputTel','inputSenha'].forEach(id => document.getElementById(id).value = '');
    document.getElementById('inputPerfil').value = 'Atendente';
    document.getElementById('senhaObs').textContent = '(obrigatório)';
    document.getElementById('inputSenha').required = true;
}
function editarUsuario(id, nome, email, perfil, tel) {
    document.getElementById('modalTitulo').textContent = 'Editar Usuário';
    document.getElementById('inputAcao').value   = 'atualizar';
    document.getElementById('inputId').value     = id;
    document.getElementById('inputNome').value   = nome;
    document.getElementById('inputEmail').value  = email;
    document.getElementById('inputPerfil').value = perfil;
    document.getElementById('inputTel').value    = tel;
    document.getElementById('inputSenha').value  = '';
    document.getElementById('inputSenha').required = false;
    document.getElementById('senhaObs').textContent = '(deixe em branco para manter)';
}
<% if (editar != null) { %>
window.addEventListener('load', () => {
    editarUsuario(<%= editar.getIdUsuario() %>,
        '<%= editar.getNomeCompleto().replace("'","\\'") %>',
        '<%= editar.getEmail() %>',
        '<%= editar.getTipoPerfil() %>',
        '<%= editar.getTelefone()!=null?editar.getTelefone():"" %>');
    new bootstrap.Modal(document.getElementById('modalUsuario')).show();
});
<% } %>
</script>
</body>
</html>
