<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*,br.com.creche.model.*,java.time.format.DateTimeFormatter" %>
<%
    List<Agendamento> agendamentos = (List<Agendamento>) request.getAttribute("agendamentos");
    List<Servico>     servicos     = (List<Servico>)     request.getAttribute("servicos");    // ativos
    List<Servico>     todosServ    = (List<Servico>)     request.getAttribute("todosServicos");
    List<Pet>         pets         = (List<Pet>)         request.getAttribute("pets");
    List<Cliente>     clientes     = (List<Cliente>)     request.getAttribute("clientes");
    List<Usuario>     atendentes   = (List<Usuario>)     request.getAttribute("atendentes");
    Agendamento editar             = (Agendamento)       request.getAttribute("agendamentoEditar");
    if (agendamentos == null) agendamentos = new ArrayList<>();
    if (servicos     == null) servicos     = new ArrayList<>();
    if (todosServ    == null) todosServ    = new ArrayList<>();
    if (pets         == null) pets         = new ArrayList<>();
    if (clientes     == null) clientes     = new ArrayList<>();
    if (atendentes   == null) atendentes   = new ArrayList<>();

    // Mapas de lookup para exibição na tabela
    Map<Integer,String> mapaServico  = new HashMap<>();
    for (Servico s  : todosServ)  mapaServico.put(s.getIdServico(), s.getNome());
    Map<Integer,String> mapaPet      = new HashMap<>();
    for (Pet p      : pets)       mapaPet.put(p.getIdPet(), p.getNome());
    Map<Integer,String> mapaCliente  = new HashMap<>();
    for (Cliente c  : clientes)   mapaCliente.put(c.getIdCliente(), c.getNome());
    Map<Integer,String> mapaAtend    = new HashMap<>();
    for (Usuario u  : atendentes) mapaAtend.put(u.getIdUsuario(), u.getPrimeiroNome());

    DateTimeFormatter fmtExib = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    DateTimeFormatter fmtForm = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
    String msg = (String) request.getAttribute("msg");
%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8"/><meta name="viewport" content="width=device-width,initial-scale=1"/>
    <title>CrechePet — Agendamentos</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet"/>
    <style>
        .badge-Pendente   { background:#f97316 }
        .badge-Confirmado { background:#22c55e }
        .badge-Concluído  { background:#3b82f6 }
        .badge-Cancelado  { background:#ef4444 }
    </style>
</head>
<body>
<jsp:include page="_sidebar.jsp"/>
<jsp:include page="_sortable.jsp"/>

<div class="main-content">
    <div class="topbar">
        <h1><i class="bi bi-calendar-check-fill text-warning me-2"></i>Agendamentos</h1>
        <button class="btn btn-warning btn-sm text-dark" data-bs-toggle="modal"
                data-bs-target="#modalAgendamento" onclick="limparModal()">
            <i class="bi bi-plus-lg me-1"></i>Novo Agendamento
        </button>
    </div>
    <div class="page-body">

        <%-- Alertas --%>
        <% if ("salvo".equals(msg)) { %>
        <div class="alert alert-success alert-dismissible fade show rounded-3">
            <i class="bi bi-check-circle-fill me-2"></i>Agendamento salvo!
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } else if ("concluido".equals(msg)) { %>
        <div class="alert alert-success alert-dismissible fade show rounded-3">
            <i class="bi bi-check2-all me-2"></i><strong>Agendamento concluído!</strong> Receita registrada no financeiro automaticamente.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } else if ("excluido".equals(msg)) { %>
        <div class="alert alert-warning alert-dismissible fade show rounded-3">
            <i class="bi bi-trash-fill me-2"></i>Agendamento excluído.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } else if ("conflito".equals(msg)) { %>
        <div class="alert alert-danger alert-dismissible fade show rounded-3">
            <i class="bi bi-exclamation-triangle-fill me-2"></i>
            <strong>Conflito de horário!</strong> Já existe um agendamento com este serviço nesse intervalo.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } else if ("horario_invalido".equals(msg)) { %>
        <div class="alert alert-danger alert-dismissible fade show rounded-3">
            <i class="bi bi-clock-fill me-2"></i>
            <strong>Horário inválido!</strong> O horário de início deve ser antes do horário de fim.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } else if ("ja_concluido".equals(msg)) { %>
        <div class="alert alert-info alert-dismissible fade show rounded-3">
            <i class="bi bi-info-circle-fill me-2"></i>Este agendamento já foi concluído anteriormente.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>

        <div class="card border-0 shadow-sm rounded-3">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0" id="tblAgend">
                        <thead class="table-light">
                            <tr>
                                <th class="sortable-th" onclick="sortTable('tblAgend',0,'number')">#</th>
                                <th class="sortable-th" onclick="sortTable('tblAgend',1,'date')">Início</th>
                                <th class="sortable-th" onclick="sortTable('tblAgend',2,'date')">Fim</th>
                                <th class="sortable-th" onclick="sortTable('tblAgend',3,'string')">Serviço</th>
                                <th class="sortable-th" onclick="sortTable('tblAgend',4,'string')">Status</th>
                                <th class="sortable-th" onclick="sortTable('tblAgend',5,'string')">Pet</th>
                                <th class="sortable-th" onclick="sortTable('tblAgend',6,'string')">Cliente</th>
                                <th class="sortable-th" onclick="sortTable('tblAgend',7,'string')">Atendente</th>
                                <th class="text-center">Ações</th>
                            </tr>
                        </thead>
                        <tbody>
                        <% if (agendamentos.isEmpty()) { %>
                            <tr><td colspan="9" class="text-center text-muted py-4">Nenhum agendamento cadastrado.</td></tr>
                        <% } else { for (Agendamento a : agendamentos) {
                               String nomeServ  = mapaServico.getOrDefault(a.getIdServico(), "—");
                               String nomePet   = mapaPet.getOrDefault(a.getIdPet(), "#"+a.getIdPet());
                               String nomeCli   = mapaCliente.getOrDefault(a.getIdCliente(), "#"+a.getIdCliente());
                               String nomeAtend = mapaAtend.getOrDefault(a.getIdAtendente(), "—");
                               boolean concluido = "Concluído".equals(a.getStatus()) || "Cancelado".equals(a.getStatus());
                        %>
                            <tr>
                                <td><span class="badge bg-secondary"><%= a.getIdAgendamento() %></span></td>
                                <td><%= a.getDataHoraInicio().format(fmtExib) %></td>
                                <td><%= a.getDataHoraFim().format(fmtExib) %></td>
                                <td class="fw-semibold"><%= nomeServ %></td>
                                <td><span class="badge badge-<%= a.getStatus() %>"><%= a.getStatus() %></span></td>
                                <td><%= nomePet %></td>
                                <td><%= nomeCli %></td>
                                <td><%= nomeAtend %></td>
                                <td class="text-center" style="white-space:nowrap">
                                    <%-- Botão Concluir (só aparece se não estiver concluído/cancelado) --%>
                                    <% if (!concluido) { %>
                                    <a href="${pageContext.request.contextPath}/agendamentos?acao=concluir&id=<%= a.getIdAgendamento() %>"
                                       class="btn btn-sm btn-success me-1"
                                       title="Marcar como concluído e registrar receita"
                                       onclick="return confirm('Concluir agendamento #<%= a.getIdAgendamento() %> e registrar receita de R$ <%= String.format("%.2f", mapaServico.containsKey(a.getIdServico()) ? 0.0 : 0.0) %>?')">
                                        <i class="bi bi-check2-circle"></i>
                                    </a>
                                    <% } %>
                                    <button class="btn btn-sm btn-outline-primary me-1"
                                        data-bs-toggle="modal" data-bs-target="#modalAgendamento"
                                        onclick="editarAgendamento(<%= a.getIdAgendamento() %>,'<%= a.getDataHoraInicio().format(fmtForm) %>','<%= a.getDataHoraFim().format(fmtForm) %>','<%= a.getStatus() %>','<%= a.getObservacoes()!=null?a.getObservacoes().replace("'","\\'").replace("\"",""):"" %>',<%= a.getIdPet() %>,<%= a.getIdCliente() %>,<%= a.getIdAtendente() %>,<%= a.getIdServico() %>)">
                                        <i class="bi bi-pencil-fill"></i>
                                    </button>
                                    <a href="${pageContext.request.contextPath}/agendamentos?acao=excluir&id=<%= a.getIdAgendamento() %>"
                                       class="btn btn-sm btn-outline-danger"
                                       onclick="return confirm('Excluir agendamento #<%= a.getIdAgendamento() %>?')">
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

<div class="modal fade" id="modalAgendamento" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <form method="POST" action="${pageContext.request.contextPath}/agendamentos">
        <div class="modal-content">
            <div class="modal-header" style="background:#f97316">
                <h5 class="modal-title text-white"><i class="bi bi-calendar-plus-fill me-2"></i><span id="modalTitulo">Novo Agendamento</span></h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <input type="hidden" name="acao" id="inputAcao" value="salvar"/>
                <input type="hidden" name="id"   id="inputId"   value="0"/>
                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Serviço <span class="text-danger">*</span></label>
                        <select name="idServico" id="inputServico" class="form-select" required>
                            <option value="">Selecione um serviço...</option>
                            <% for (Servico s : servicos) { %>
                            <option value="<%= s.getIdServico() %>">
                                <%= s.getNome() %> — R$ <%= String.format("%.2f", s.getValorBase()) %>
                                (<%= s.getDuracaoEstimadaMinutos() %> min)
                            </option>
                            <% } %>
                        </select>
                        <div class="form-text text-muted">Apenas serviços ativos são exibidos.</div>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Status</label>
                        <select name="status" id="inputStatus" class="form-select">
                            <option value="Pendente">Pendente</option>
                            <option value="Confirmado">Confirmado</option>
                            <option value="Concluído">Concluído</option>
                            <option value="Cancelado">Cancelado</option>
                        </select>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Data/Hora Início <span class="text-danger">*</span></label>
                        <input type="datetime-local" name="dataHoraInicio" id="inputInicio" class="form-control" required/>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Data/Hora Fim <span class="text-danger">*</span></label>
                        <input type="datetime-local" name="dataHoraFim" id="inputFim" class="form-control" required/>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Pet <span class="text-danger">*</span></label>
                        <select name="idPet" id="inputPet" class="form-select" required>
                            <option value="">Selecione...</option>
                            <% for (Pet p : pets) { %>
                            <option value="<%= p.getIdPet() %>"><%= p.getNome() %> (<%= p.getRaca()!=null?p.getRaca():"sem raça" %>)</option>
                            <% } %>
                        </select>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Cliente <span class="text-danger">*</span></label>
                        <select name="idCliente" id="inputCliente" class="form-select" required>
                            <option value="">Selecione...</option>
                            <% for (Cliente c : clientes) { %>
                            <option value="<%= c.getIdCliente() %>"><%= c.getNome() %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="col-md-12">
                        <label class="form-label fw-semibold">Atendente</label>
                        <select name="idAtendente" id="inputAtendente" class="form-select">
                            <option value="0">Sem atendente</option>
                            <% for (Usuario u : atendentes) { %>
                            <option value="<%= u.getIdUsuario() %>"><%= u.getNomeCompleto() %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="col-12">
                        <label class="form-label fw-semibold">Observações</label>
                        <textarea name="observacoes" id="inputObs" class="form-control" rows="2"></textarea>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                <button type="submit" class="btn" style="background:#f97316;color:#fff">
                    <i class="bi bi-check-lg me-1"></i>Salvar
                </button>
            </div>
        </div>
        </form>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
function limparModal() {
    document.getElementById('modalTitulo').textContent = 'Novo Agendamento';
    document.getElementById('inputAcao').value    = 'salvar';
    document.getElementById('inputId').value      = '0';
    document.getElementById('inputServico').value = '';
    document.getElementById('inputStatus').value  = 'Pendente';
    document.getElementById('inputInicio').value  = '';
    document.getElementById('inputFim').value     = '';
    document.getElementById('inputPet').value     = '';
    document.getElementById('inputCliente').value = '';
    document.getElementById('inputAtendente').value = '0';
    document.getElementById('inputObs').value     = '';
}
function editarAgendamento(id, ini, fim, status, obs, idPet, idCli, idAtend, idServ) {
    document.getElementById('modalTitulo').textContent = 'Editar Agendamento';
    document.getElementById('inputAcao').value    = 'atualizar';
    document.getElementById('inputId').value      = id;
    document.getElementById('inputServico').value = idServ;
    document.getElementById('inputStatus').value  = status;
    document.getElementById('inputInicio').value  = ini;
    document.getElementById('inputFim').value     = fim;
    document.getElementById('inputPet').value     = idPet;
    document.getElementById('inputCliente').value = idCli;
    document.getElementById('inputAtendente').value = idAtend;
    document.getElementById('inputObs').value     = obs;
}
<% if (editar != null) { %>
window.addEventListener('load', () => {
    editarAgendamento(<%= editar.getIdAgendamento() %>,
        '<%= editar.getDataHoraInicio().format(fmtForm) %>',
        '<%= editar.getDataHoraFim().format(fmtForm) %>',
        '<%= editar.getStatus() %>',
        '<%= editar.getObservacoes()!=null?editar.getObservacoes().replace("'","\\'").replace("\"",""):"" %>',
        <%= editar.getIdPet() %>, <%= editar.getIdCliente() %>,
        <%= editar.getIdAtendente() %>, <%= editar.getIdServico() %>);
    new bootstrap.Modal(document.getElementById('modalAgendamento')).show();
});
<% } %>
</script>
</body>
</html>
