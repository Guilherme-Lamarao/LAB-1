<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, br.com.creche.model.Pet, br.com.creche.model.Cliente" %>
<%
    List<Pet>     pets     = (List<Pet>)     request.getAttribute("pets");
    List<Cliente> clientes = (List<Cliente>) request.getAttribute("clientes");
    Pet editar             = (Pet)           request.getAttribute("petEditar");
    if (pets     == null) pets     = new java.util.ArrayList<>();
    if (clientes == null) clientes = new java.util.ArrayList<>();
    java.util.Map<Integer,String> mapaCliente = new java.util.HashMap<>();
    for (Cliente c : clientes) mapaCliente.put(c.getIdCliente(), c.getNome());
    String msg = (String) request.getAttribute("msg");
%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8"/><meta name="viewport" content="width=device-width,initial-scale=1"/>
    <title>CrechePet — Pets</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet"/>
</head>
<body>
<jsp:include page="_sidebar.jsp"/>
<jsp:include page="_sortable.jsp"/>

<div class="main-content">
    <div class="topbar">
        <h1><i class="bi bi-heart-fill text-danger me-2"></i>Pets</h1>
        <button class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#modalPet" onclick="limparModal()">
            <i class="bi bi-plus-lg me-1"></i>Novo Pet
        </button>
    </div>
    <div class="page-body">

        <% if ("salvo".equals(msg)) { %>
        <div class="alert alert-success alert-dismissible fade show rounded-3">
            <i class="bi bi-check-circle-fill me-2"></i>Pet salvo! <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } else if ("excluido".equals(msg)) { %>
        <div class="alert alert-warning alert-dismissible fade show rounded-3">
            <i class="bi bi-trash-fill me-2"></i>Pet excluído. <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>

        <div class="card border-0 shadow-sm rounded-3">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0" id="tblPets">
                        <thead class="table-light">
                            <tr>
                                <th class="sortable-th" onclick="sortTable('tblPets',0,'number')">#</th>
                                <th class="sortable-th" onclick="sortTable('tblPets',1,'string')">Nome</th>
                                <th class="sortable-th" onclick="sortTable('tblPets',2,'string')">Raça</th>
                                <th class="sortable-th" onclick="sortTable('tblPets',3,'number')">Peso</th>
                                <th class="sortable-th" onclick="sortTable('tblPets',4,'string')">Dono</th>
                                <th>Necessidades Especiais</th>
                                <th class="text-center">Ações</th>
                            </tr>
                        </thead>
                        <tbody>
                        <% if (pets.isEmpty()) { %>
                            <tr><td colspan="7" class="text-center text-muted py-4">Nenhum pet cadastrado.</td></tr>
                        <% } else { for (Pet p : pets) {
                               String nomeDono = mapaCliente.getOrDefault(p.getIdCliente(), "—");
                        %>
                            <tr>
                                <td><span class="badge bg-secondary"><%= p.getIdPet() %></span></td>
                                <td class="fw-semibold"><%= p.getNome() %></td>
                                <td><%= p.getRaca() != null ? p.getRaca() : "—" %></td>
                                <td><%= p.getPeso() > 0 ? String.format("%.1f kg", p.getPeso()) : "—" %></td>
                                <td><%= nomeDono %></td>
                                <td><small class="text-muted"><%= p.getNecessidadesEspeciais() != null ? p.getNecessidadesEspeciais() : "—" %></small></td>
                                <td class="text-center">
                                    <button class="btn btn-sm btn-outline-primary me-1"
                                        data-bs-toggle="modal" data-bs-target="#modalPet"
                                        onclick="editarPet(<%= p.getIdPet() %>,'<%= p.getNome().replace("'","\\'") %>','<%= p.getRaca()!=null?p.getRaca().replace("'","\\'"):"" %>',<%= p.getPeso() %>,'<%= p.getNecessidadesEspeciais()!=null?p.getNecessidadesEspeciais().replace("'","\\'").replace("\"",""):"" %>',<%= p.getIdCliente() %>)">
                                        <i class="bi bi-pencil-fill"></i>
                                    </button>
                                    <a href="${pageContext.request.contextPath}/pets?acao=excluir&id=<%= p.getIdPet() %>"
                                       class="btn btn-sm btn-outline-danger"
                                       onclick="return confirm('Excluir pet <%= p.getNome().replace("'","\\'") %>?')">
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

<div class="modal fade" id="modalPet" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <form method="POST" action="${pageContext.request.contextPath}/pets">
        <div class="modal-content">
            <div class="modal-header bg-danger text-white">
                <h5 class="modal-title"><i class="bi bi-heart-fill me-2"></i><span id="modalTitulo">Novo Pet</span></h5>
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
                        <label class="form-label fw-semibold">Raça</label>
                        <input type="text" name="raca" id="inputRaca" class="form-control"/>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fw-semibold">Peso (kg)</label>
                        <input type="number" step="0.1" name="peso" id="inputPeso" class="form-control" placeholder="0.0"/>
                    </div>
                    <div class="col-md-8">
                        <label class="form-label fw-semibold">Dono (Cliente) <span class="text-danger">*</span></label>
                        <select name="idCliente" id="inputCliente" class="form-select" required>
                            <option value="">Selecione o cliente...</option>
                            <% for (Cliente c : clientes) { %>
                            <option value="<%= c.getIdCliente() %>"><%= c.getNome() %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="col-12">
                        <label class="form-label fw-semibold">Necessidades Especiais</label>
                        <textarea name="necessidadesEspeciais" id="inputNec" class="form-control" rows="2"></textarea>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                <button type="submit" class="btn btn-danger"><i class="bi bi-check-lg me-1"></i>Salvar</button>
            </div>
        </div>
        </form>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
function limparModal() {
    document.getElementById('modalTitulo').textContent = 'Novo Pet';
    document.getElementById('inputAcao').value = 'salvar';
    document.getElementById('inputId').value   = '0';
    ['inputNome','inputRaca','inputPeso','inputNec'].forEach(id => document.getElementById(id).value = '');
    document.getElementById('inputCliente').value = '';
}
function editarPet(id, nome, raca, peso, nec, idCliente) {
    document.getElementById('modalTitulo').textContent = 'Editar Pet';
    document.getElementById('inputAcao').value    = 'atualizar';
    document.getElementById('inputId').value      = id;
    document.getElementById('inputNome').value    = nome;
    document.getElementById('inputRaca').value    = raca;
    document.getElementById('inputPeso').value    = peso;
    document.getElementById('inputNec').value     = nec;
    document.getElementById('inputCliente').value = idCliente;
}
<% if (editar != null) { %>
window.addEventListener('load', () => {
    editarPet(<%= editar.getIdPet() %>,'<%= editar.getNome().replace("'","\\'") %>',
        '<%= editar.getRaca()!=null?editar.getRaca().replace("'","\\'"):"" %>',
        <%= editar.getPeso() %>,
        '<%= editar.getNecessidadesEspeciais()!=null?editar.getNecessidadesEspeciais().replace("'","\\'").replace("\"",""):"" %>',
        <%= editar.getIdCliente() %>);
    new bootstrap.Modal(document.getElementById('modalPet')).show();
});
<% } %>
</script>
</body>
</html>
