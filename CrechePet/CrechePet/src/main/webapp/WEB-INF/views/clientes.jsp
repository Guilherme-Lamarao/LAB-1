<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, br.com.creche.model.Cliente" %>
<%
    List<Cliente> clientes = (List<Cliente>) request.getAttribute("clientes");
    Cliente editar = (Cliente) request.getAttribute("clienteEditar");
    if (clientes == null) clientes = new java.util.ArrayList<>();
    String msg = (String) request.getAttribute("msg");
%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8"/><meta name="viewport" content="width=device-width,initial-scale=1"/>
    <title>CrechePet — Clientes</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet"/>
</head>
<body>
<jsp:include page="_sidebar.jsp"/>
<jsp:include page="_sortable.jsp"/>

<div class="main-content">
    <div class="topbar">
        <h1><i class="bi bi-people-fill text-primary me-2"></i>Clientes</h1>
        <button class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#modalCliente" onclick="limparModal()">
            <i class="bi bi-plus-lg me-1"></i>Novo Cliente
        </button>
    </div>
    <div class="page-body">

        <% if ("salvo".equals(msg)) { %>
        <div class="alert alert-success alert-dismissible fade show rounded-3">
            <i class="bi bi-check-circle-fill me-2"></i>Cliente salvo com sucesso!
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } else if ("excluido".equals(msg)) { %>
        <div class="alert alert-warning alert-dismissible fade show rounded-3">
            <i class="bi bi-trash-fill me-2"></i>Cliente excluído.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } else if ("vinculo".equals(msg)) { %>
        <div class="alert alert-danger alert-dismissible fade show rounded-3">
            <i class="bi bi-exclamation-triangle-fill me-2"></i>
            <strong>Não é possível excluir!</strong> Este cliente possui pets ou agendamentos vinculados.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } else if ("email_dup".equals(msg)) { %>
        <div class="alert alert-danger alert-dismissible fade show rounded-3">
            <i class="bi bi-exclamation-circle-fill me-2"></i>
            <strong>E-mail já cadastrado!</strong> Outro cliente já usa este e-mail.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } else if ("tel_dup".equals(msg)) { %>
        <div class="alert alert-danger alert-dismissible fade show rounded-3">
            <i class="bi bi-exclamation-circle-fill me-2"></i>
            <strong>Telefone já cadastrado!</strong> Outro cliente já usa este telefone.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>

        <div class="card border-0 shadow-sm rounded-3">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0" id="tblClientes">
                        <thead class="table-light">
                            <tr>
                                <th class="sortable-th" onclick="sortTable('tblClientes',0,'number')">#</th>
                                <th class="sortable-th" onclick="sortTable('tblClientes',1,'string')">Nome</th>
                                <th class="sortable-th" onclick="sortTable('tblClientes',2,'string')">Telefone</th>
                                <th class="sortable-th" onclick="sortTable('tblClientes',3,'string')">E-mail</th>
                                <th class="sortable-th" onclick="sortTable('tblClientes',4,'string')">Endereço</th>
                                <th class="text-center">Ações</th>
                            </tr>
                        </thead>
                        <tbody>
                        <% if (clientes.isEmpty()) { %>
                            <tr><td colspan="6" class="text-center text-muted py-4">Nenhum cliente cadastrado.</td></tr>
                        <% } else { for (Cliente c : clientes) { %>
                            <tr>
                                <td><span class="badge bg-secondary"><%= c.getIdCliente() %></span></td>
                                <td class="fw-semibold"><%= c.getNome() %></td>
                                <td><%= c.getTelefone() != null ? c.getTelefone() : "—" %></td>
                                <td><%= c.getEmail() != null ? c.getEmail() : "—" %></td>
                                <td><%= c.getEndereco() != null ? c.getEndereco() : "—" %></td>
                                <td class="text-center">
                                    <button class="btn btn-sm btn-outline-primary me-1"
                                        data-bs-toggle="modal" data-bs-target="#modalCliente"
                                        onclick="editarCliente(<%= c.getIdCliente() %>,'<%= esc(c.getNome()) %>','<%= c.getTelefone()!=null?c.getTelefone():"" %>','<%= c.getEmail()!=null?c.getEmail():"" %>','<%= c.getEndereco()!=null?esc(c.getEndereco()):"" %>')">
                                        <i class="bi bi-pencil-fill"></i>
                                    </button>
                                    <a href="${pageContext.request.contextPath}/clientes?acao=excluir&id=<%= c.getIdCliente() %>"
                                       class="btn btn-sm btn-outline-danger"
                                       onclick="return confirm('Excluir cliente <%= esc(c.getNome()) %>?')">
                                        <i class="bi bi-trash-fill"></i>
                                    </a>
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

<%!
    private String esc(String s) {
        if (s == null) return "";
        return s.replace("\\","\\\\").replace("'","\\'").replace("\"","&quot;");
    }
%>

<div class="modal fade" id="modalCliente" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <form method="POST" action="${pageContext.request.contextPath}/clientes">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title"><i class="bi bi-person-fill me-2"></i><span id="modalTitulo">Novo Cliente</span></h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <input type="hidden" name="acao" id="inputAcao" value="salvar"/>
                <input type="hidden" name="id"   id="inputId"   value="0"/>
                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Nome <span class="text-danger">*</span></label>
                        <input type="text" name="nome" id="inputNome" class="form-control" required/>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Telefone</label>
                        <input type="text" name="telefone" id="inputTelefone" class="form-control" placeholder="(00) 00000-0000"/>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">E-mail</label>
                        <input type="email" name="email" id="inputEmail" class="form-control"/>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Endereço</label>
                        <input type="text" name="endereco" id="inputEndereco" class="form-control"/>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                <button type="submit" class="btn btn-primary"><i class="bi bi-check-lg me-1"></i>Salvar</button>
            </div>
        </div>
        </form>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
function limparModal() {
    document.getElementById('modalTitulo').textContent = 'Novo Cliente';
    document.getElementById('inputAcao').value = 'salvar';
    document.getElementById('inputId').value   = '0';
    ['inputNome','inputTelefone','inputEmail','inputEndereco'].forEach(id => document.getElementById(id).value = '');
}
function editarCliente(id, nome, tel, email, end) {
    document.getElementById('modalTitulo').textContent = 'Editar Cliente';
    document.getElementById('inputAcao').value = 'atualizar';
    document.getElementById('inputId').value   = id;
    document.getElementById('inputNome').value      = nome;
    document.getElementById('inputTelefone').value  = tel;
    document.getElementById('inputEmail').value     = email;
    document.getElementById('inputEndereco').value  = end;
}
<% if (editar != null) { %>
window.addEventListener('load', () => {
    editarCliente(<%= editar.getIdCliente() %>,'<%= esc(editar.getNome()) %>',
        '<%= editar.getTelefone()!=null?editar.getTelefone():"" %>',
        '<%= editar.getEmail()!=null?editar.getEmail():"" %>',
        '<%= editar.getEndereco()!=null?esc(editar.getEndereco()):"" %>');
    new bootstrap.Modal(document.getElementById('modalCliente')).show();
});
<% } %>
</script>
</body>
</html>
