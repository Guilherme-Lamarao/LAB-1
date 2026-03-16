<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, br.com.creche.model.Servico" %>
<%
    List<Servico> servicos = (List<Servico>) request.getAttribute("servicos");
    Servico editar         = (Servico)       request.getAttribute("servicoEditar");
    if (servicos == null) servicos = new java.util.ArrayList<>();
    String msg = (String) request.getAttribute("msg");
%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8"/><meta name="viewport" content="width=device-width,initial-scale=1"/>
    <title>CrechePet — Serviços</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet"/>
</head>
<body>
<jsp:include page="_sidebar.jsp"/>
<jsp:include page="_sortable.jsp"/>

<div class="main-content">
    <div class="topbar">
        <h1><i class="bi bi-scissors text-success me-2"></i>Serviços</h1>
        <button class="btn btn-success btn-sm" data-bs-toggle="modal" data-bs-target="#modalServico" onclick="limparModal()">
            <i class="bi bi-plus-lg me-1"></i>Novo Serviço
        </button>
    </div>
    <div class="page-body">

        <% if ("salvo".equals(msg)) { %>
        <div class="alert alert-success alert-dismissible fade show rounded-3">
            <i class="bi bi-check-circle-fill me-2"></i>Serviço salvo!
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } else if ("excluido".equals(msg)) { %>
        <div class="alert alert-warning alert-dismissible fade show rounded-3">
            <i class="bi bi-trash-fill me-2"></i>Serviço excluído.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>

        <div class="card border-0 shadow-sm rounded-3">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0" id="tblServicos">
                        <thead class="table-light">
                            <tr>
                                <th class="sortable-th" onclick="sortTable('tblServicos',0,'number')">#</th>
                                <th class="sortable-th" onclick="sortTable('tblServicos',1,'string')">Nome</th>
                                <th>Descrição</th>
                                <th class="sortable-th" onclick="sortTable('tblServicos',3,'number')">Valor Base</th>
                                <th class="sortable-th" onclick="sortTable('tblServicos',4,'number')">Duração</th>
                                <th class="sortable-th" onclick="sortTable('tblServicos',5,'string')">Status</th>
                                <th class="text-center">Ações</th>
                            </tr>
                        </thead>
                        <tbody>
                        <% if (servicos.isEmpty()) { %>
                            <tr><td colspan="7" class="text-center text-muted py-4">Nenhum serviço cadastrado.</td></tr>
                        <% } else { for (Servico s : servicos) { %>
                            <tr>
                                <td><span class="badge bg-secondary"><%= s.getIdServico() %></span></td>
                                <td class="fw-semibold"><%= s.getNome() %></td>
                                <td><small class="text-muted"><%= s.getDescricao()!=null?s.getDescricao():"—" %></small></td>
                                <td>R$ <%= String.format("%.2f", s.getValorBase()) %></td>
                                <td><%= s.getDuracaoEstimadaMinutos() %> min</td>
                                <td><span class="badge <%= s.isAtivo()?"bg-success":"bg-secondary" %>">
                                    <%= s.isAtivo()?"Ativo":"Inativo" %></span></td>
                                <td class="text-center">
                                    <button class="btn btn-sm btn-outline-primary me-1"
                                        data-bs-toggle="modal" data-bs-target="#modalServico"
                                        onclick="editarServico(<%= s.getIdServico() %>,'<%= s.getNome().replace("'","\\'") %>','<%= s.getDescricao()!=null?s.getDescricao().replace("'","\\'").replace("\"",""):"" %>',<%= s.getValorBase() %>,<%= s.getDuracaoEstimadaMinutos() %>,<%= s.isAtivo() %>)">
                                        <i class="bi bi-pencil-fill"></i>
                                    </button>
                                    <a href="${pageContext.request.contextPath}/servicos?acao=excluir&id=<%= s.getIdServico() %>"
                                       class="btn btn-sm btn-outline-danger"
                                       onclick="return confirm('Excluir serviço <%= s.getNome().replace("'","\\'") %>?')">
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

<div class="modal fade" id="modalServico" tabindex="-1">
    <div class="modal-dialog">
        <form method="POST" action="${pageContext.request.contextPath}/servicos">
        <div class="modal-content">
            <div class="modal-header bg-success text-white">
                <h5 class="modal-title"><i class="bi bi-scissors me-2"></i><span id="modalTitulo">Novo Serviço</span></h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <input type="hidden" name="acao" id="inputAcao" value="salvar"/>
                <input type="hidden" name="id"   id="inputId"   value="0"/>
                <div class="row g-3">
                    <div class="col-12">
                        <label class="form-label fw-semibold">Nome <span class="text-danger">*</span></label>
                        <input type="text" name="nome" id="inputNome" class="form-control" required/>
                    </div>
                    <div class="col-12">
                        <label class="form-label fw-semibold">Descrição</label>
                        <textarea name="descricao" id="inputDesc" class="form-control" rows="2"></textarea>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Valor Base (R$) <span class="text-danger">*</span></label>
                        <input type="number" step="0.01" min="0" name="valorBase" id="inputValor" class="form-control" required/>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Duração (minutos)</label>
                        <input type="number" min="0" name="duracaoEstimadaMinutos" id="inputDuracao" class="form-control" placeholder="60"/>
                    </div>
                    <div class="col-12">
                        <div class="form-check form-switch">
                            <input class="form-check-input" type="checkbox" name="ativo" id="inputAtivo" value="true" checked/>
                            <label class="form-check-label fw-semibold" for="inputAtivo">Serviço Ativo</label>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                <button type="submit" class="btn btn-success"><i class="bi bi-check-lg me-1"></i>Salvar</button>
            </div>
        </div>
        </form>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
function limparModal() {
    document.getElementById('modalTitulo').textContent = 'Novo Serviço';
    document.getElementById('inputAcao').value = 'salvar';
    document.getElementById('inputId').value   = '0';
    ['inputNome','inputDesc','inputValor','inputDuracao'].forEach(id => document.getElementById(id).value = '');
    document.getElementById('inputAtivo').checked = true;
}
function editarServico(id, nome, desc, valor, duracao, ativo) {
    document.getElementById('modalTitulo').textContent = 'Editar Serviço';
    document.getElementById('inputAcao').value    = 'atualizar';
    document.getElementById('inputId').value      = id;
    document.getElementById('inputNome').value    = nome;
    document.getElementById('inputDesc').value    = desc;
    document.getElementById('inputValor').value   = valor;
    document.getElementById('inputDuracao').value = duracao;
    document.getElementById('inputAtivo').checked = ativo;
}
</script>
</body>
</html>
