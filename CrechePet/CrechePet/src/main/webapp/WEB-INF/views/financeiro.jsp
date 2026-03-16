<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, br.com.creche.model.MovimentoFinanceiro, java.time.format.DateTimeFormatter" %>
<%
    List<MovimentoFinanceiro> movimentos = (List<MovimentoFinanceiro>) request.getAttribute("movimentos");
    MovimentoFinanceiro editar           = (MovimentoFinanceiro) request.getAttribute("movimentoEditar");
    if (movimentos == null) movimentos   = new java.util.ArrayList<>();
    double totalReceitas = 0, totalDespesas = 0;
    for (MovimentoFinanceiro m : movimentos) {
        if ("Receita".equals(m.getTipoMovimentacao())) totalReceitas += m.getValor();
        else totalDespesas += m.getValor();
    }
    double saldo = totalReceitas - totalDespesas;
    DateTimeFormatter fmtExib = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    DateTimeFormatter fmtForm = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
    String msg = (String) request.getAttribute("msg");
%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8"/><meta name="viewport" content="width=device-width,initial-scale=1"/>
    <title>CrechePet — Financeiro</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet"/>
    <style>
        .card-receita { border-left:4px solid #22c55e; }
        .card-despesa { border-left:4px solid #ef4444; }
        .card-saldo   { border-left:4px solid #3b82f6; }
    </style>
</head>
<body>
<jsp:include page="_sidebar.jsp"/>
<jsp:include page="_sortable.jsp"/>

<div class="main-content">
    <div class="topbar">
        <h1><i class="bi bi-cash-stack text-success me-2"></i>Financeiro</h1>
        <button class="btn btn-success btn-sm" data-bs-toggle="modal" data-bs-target="#modalMovimento" onclick="limparModal()">
            <i class="bi bi-plus-lg me-1"></i>Novo Lançamento
        </button>
    </div>
    <div class="page-body">

        <% if ("salvo".equals(msg)) { %>
        <div class="alert alert-success alert-dismissible fade show rounded-3">
            <i class="bi bi-check-circle-fill me-2"></i>Lançamento salvo!
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } else if ("excluido".equals(msg)) { %>
        <div class="alert alert-warning alert-dismissible fade show rounded-3">
            <i class="bi bi-trash-fill me-2"></i>Lançamento excluído.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>

        <div class="row g-3 mb-4">
            <div class="col-md-4">
                <div class="card border-0 shadow-sm rounded-3 card-receita p-3">
                    <div class="text-muted small">Total de Receitas</div>
                    <div class="fs-4 fw-bold text-success">R$ <%= String.format("%.2f", totalReceitas) %></div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card border-0 shadow-sm rounded-3 card-despesa p-3">
                    <div class="text-muted small">Total de Despesas</div>
                    <div class="fs-4 fw-bold text-danger">R$ <%= String.format("%.2f", totalDespesas) %></div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card border-0 shadow-sm rounded-3 card-saldo p-3">
                    <div class="text-muted small">Saldo</div>
                    <div class="fs-4 fw-bold <%= saldo>=0?"text-primary":"text-danger" %>">R$ <%= String.format("%.2f", saldo) %></div>
                </div>
            </div>
        </div>

        <div class="card border-0 shadow-sm rounded-3">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0" id="tblFin">
                        <thead class="table-light">
                            <tr>
                                <th class="sortable-th" onclick="sortTable('tblFin',0,'number')">#</th>
                                <th class="sortable-th" onclick="sortTable('tblFin',1,'date')">Data</th>
                                <th class="sortable-th" onclick="sortTable('tblFin',2,'string')">Tipo</th>
                                <th class="sortable-th" onclick="sortTable('tblFin',3,'number')">Valor</th>
                                <th>Descrição</th>
                                <th class="text-center">Ações</th>
                            </tr>
                        </thead>
                        <tbody>
                        <% if (movimentos.isEmpty()) { %>
                            <tr><td colspan="6" class="text-center text-muted py-4">Nenhum lançamento registrado.</td></tr>
                        <% } else { for (MovimentoFinanceiro m : movimentos) { %>
                            <tr>
                                <td><span class="badge bg-secondary"><%= m.getIdMovimentacao() %></span></td>
                                <td><%= m.getDataMovimentacao().format(fmtExib) %></td>
                                <td>
                                    <% if ("Receita".equals(m.getTipoMovimentacao())) { %>
                                    <span class="badge bg-success"><i class="bi bi-arrow-up-circle me-1"></i>Receita</span>
                                    <% } else { %>
                                    <span class="badge bg-danger"><i class="bi bi-arrow-down-circle me-1"></i>Despesa</span>
                                    <% } %>
                                </td>
                                <td class="fw-semibold">R$ <%= String.format("%.2f", m.getValor()) %></td>
                                <td><small class="text-muted"><%= m.getDescricao()!=null?m.getDescricao():"—" %></small></td>
                                <td class="text-center">
                                    <button class="btn btn-sm btn-outline-primary me-1"
                                        data-bs-toggle="modal" data-bs-target="#modalMovimento"
                                        onclick="editarMov(<%= m.getIdMovimentacao() %>,'<%= m.getDataMovimentacao().format(fmtForm) %>',<%= m.getValor() %>,'<%= m.getTipoMovimentacao() %>','<%= m.getDescricao()!=null?m.getDescricao().replace("'","\\'").replace("\"",""):"" %>',<%= m.getIdItemPrestacao() %>)">
                                        <i class="bi bi-pencil-fill"></i>
                                    </button>
                                    <a href="${pageContext.request.contextPath}/financeiro?acao=excluir&id=<%= m.getIdMovimentacao() %>"
                                       class="btn btn-sm btn-outline-danger"
                                       onclick="return confirm('Excluir lançamento #<%= m.getIdMovimentacao() %>?')">
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

<div class="modal fade" id="modalMovimento" tabindex="-1">
    <div class="modal-dialog">
        <form method="POST" action="${pageContext.request.contextPath}/financeiro">
        <div class="modal-content">
            <div class="modal-header bg-success text-white">
                <h5 class="modal-title"><i class="bi bi-cash-coin me-2"></i><span id="modalTitulo">Novo Lançamento</span></h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <input type="hidden" name="acao" id="inputAcao" value="salvar"/>
                <input type="hidden" name="id"   id="inputId"   value="0"/>
                <div class="row g-3">
                    <div class="col-md-7">
                        <label class="form-label fw-semibold">Data/Hora <span class="text-danger">*</span></label>
                        <input type="datetime-local" name="dataMovimentacao" id="inputData" class="form-control" required/>
                    </div>
                    <div class="col-md-5">
                        <label class="form-label fw-semibold">Tipo <span class="text-danger">*</span></label>
                        <select name="tipoMovimentacao" id="inputTipo" class="form-select" required>
                            <option value="Receita">Receita</option>
                            <option value="Despesa">Despesa</option>
                        </select>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Valor (R$) <span class="text-danger">*</span></label>
                        <input type="number" step="0.01" min="0" name="valor" id="inputValor" class="form-control" required/>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Item Prestação (ID)</label>
                        <input type="number" min="0" name="idItemPrestacao" id="inputItem" class="form-control" placeholder="0 = nenhum"/>
                    </div>
                    <div class="col-12">
                        <label class="form-label fw-semibold">Descrição</label>
                        <textarea name="descricao" id="inputDesc" class="form-control" rows="3"></textarea>
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
    document.getElementById('modalTitulo').textContent = 'Novo Lançamento';
    document.getElementById('inputAcao').value = 'salvar';
    document.getElementById('inputId').value   = '0';
    ['inputData','inputValor','inputDesc'].forEach(id => document.getElementById(id).value = '');
    document.getElementById('inputTipo').value = 'Receita';
    document.getElementById('inputItem').value = '0';
}
function editarMov(id, data, valor, tipo, desc, idItem) {
    document.getElementById('modalTitulo').textContent = 'Editar Lançamento';
    document.getElementById('inputAcao').value  = 'atualizar';
    document.getElementById('inputId').value    = id;
    document.getElementById('inputData').value  = data;
    document.getElementById('inputValor').value = valor;
    document.getElementById('inputTipo').value  = tipo;
    document.getElementById('inputDesc').value  = desc;
    document.getElementById('inputItem').value  = idItem;
}
</script>
</body>
</html>
