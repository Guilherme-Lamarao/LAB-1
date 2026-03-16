package br.com.creche.servlet;

import br.com.creche.dao.*;
import br.com.creche.model.*;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@WebServlet("/agendamentos")
public class AgendamentoServlet extends HttpServlet {

    private static final DateTimeFormatter FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!autenticado(req, resp)) return;
        String acao = req.getParameter("acao");

        try (Connection con = ConexaoFactory.getConexao()) {
            AgendamentoDAO dao     = new AgendamentoDAO(con);
            ServicoDAO servicoDao  = new ServicoDAO(con);

            // ── Excluir ──
            if ("excluir".equals(acao)) {
                dao.excluir(parseInt(req.getParameter("id")));
                resp.sendRedirect(req.getContextPath() + "/agendamentos?msg=excluido");
                return;
            }

            // ── Concluir ──
            if ("concluir".equals(acao)) {
                int id = parseInt(req.getParameter("id"));
                Agendamento agend = dao.buscarPorId(id);

                if (agend != null && !"Concluído".equals(agend.getStatus())) {
                    Servico servico = servicoDao.buscarPorId(agend.getIdServico());
                    double valorFinal = servico != null ? servico.getValorBase() : 0.0;
                    String nomeServico = servico != null ? servico.getNome() : "Serviço #" + agend.getIdServico();

                    // Busca nome do cliente e pet para a descrição
                    Cliente cliente = new ClienteDAO(con).buscarPorId(agend.getIdCliente());
                    Pet pet = new PetDAO(con).buscarPorId(agend.getIdPet());
                    String nomeCliente = cliente != null ? cliente.getNome() : "Cliente #" + agend.getIdCliente();
                    String nomePet = pet != null ? pet.getNome() : "Pet #" + agend.getIdPet();

                    LocalDateTime agora = LocalDateTime.now();
                    DateTimeFormatter fmtDesc = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

                    // 1. Cria o ItemPrestacao
                    ItemPrestacao item = new ItemPrestacao(
                        0, id, agend.getIdServico(), agora, valorFinal,
                        "Concluído via agendamento #" + id
                    );
                    new ItemPrestacaoDAO(con).salvar(item);

                    // 2. Cria o MovimentoFinanceiro com descrição detalhada
                    String descricao = String.format(
                        "Receita — Agendamento #%d | Serviço: %s | Pet: %s | Cliente: %s | Data: %s | Valor: R$ %.2f",
                        id, nomeServico, nomePet, nomeCliente,
                        agend.getDataHoraInicio().format(fmtDesc), valorFinal
                    );
                    MovimentoFinanceiro mov = new MovimentoFinanceiro(
                        0, agora, valorFinal, "Receita", descricao, item.getIdItemPrestacao()
                    );
                    new MovimentoFinanceiroDAO(con).salvar(mov);

                    // 3. Atualiza status do agendamento
                    agend.setStatus("Concluído");
                    dao.atualizar(agend);

                    resp.sendRedirect(req.getContextPath() + "/agendamentos?msg=concluido");
                    return;
                }
                resp.sendRedirect(req.getContextPath() + "/agendamentos?msg=ja_concluido");
                return;
            }

            // ── Carregar página ──
            req.setAttribute("agendamentos", dao.listarTodos());
            // Apenas serviços ativos para o dropdown
            req.setAttribute("servicos",    servicoDao.listarAtivos());
            req.setAttribute("pets",        new PetDAO(con).listarTodos());
            req.setAttribute("clientes",    new ClienteDAO(con).listarTodos());
            req.setAttribute("atendentes",  new UsuarioDAO(con).listarTodos());
            // Mapa de TODOS os serviços (inclusive inativos) para exibir nomes na tabela
            req.setAttribute("todosServicos", servicoDao.listarTodos());

            if ("editar".equals(acao)) {
                req.setAttribute("agendamentoEditar",
                    dao.buscarPorId(parseInt(req.getParameter("id"))));
            }

        } catch (Exception e) { req.setAttribute("erro", e.getMessage()); }

        String msg = req.getParameter("msg");
        if (msg != null) req.setAttribute("msg", msg);
        req.setAttribute("paginaAtiva", "agendamentos");
        req.getRequestDispatcher("/WEB-INF/views/agendamentos.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!autenticado(req, resp)) return;
        req.setCharacterEncoding("UTF-8");

        String acao      = req.getParameter("acao");
        LocalDateTime ini = LocalDateTime.parse(req.getParameter("dataHoraInicio"), FMT);
        LocalDateTime fim = LocalDateTime.parse(req.getParameter("dataHoraFim"), FMT);
        String status    = req.getParameter("status");
        String obs       = req.getParameter("observacoes");
        int idPet        = parseInt(req.getParameter("idPet"));
        int idCliente    = parseInt(req.getParameter("idCliente"));
        int idAtendente  = parseInt(req.getParameter("idAtendente"));
        int idServico    = parseInt(req.getParameter("idServico"));
        int idAtual      = parseInt(req.getParameter("id")); // 0 = novo

        // Valida horário de início antes do fim
        if (!ini.isBefore(fim)) {
            resp.sendRedirect(req.getContextPath() + "/agendamentos?msg=horario_invalido");
            return;
        }

        try (Connection con = ConexaoFactory.getConexao()) {
            AgendamentoDAO dao = new AgendamentoDAO(con);

            // Verifica conflito de horário por serviço
            if (dao.verificarConflitoPorServico(idServico, ini, fim, idAtual)) {
                resp.sendRedirect(req.getContextPath() + "/agendamentos?msg=conflito");
                return;
            }

            if ("salvar".equals(acao)) {
                dao.salvar(new Agendamento(0, ini, fim, status, obs,
                           idPet, idCliente, idAtendente, idServico));
            } else if ("atualizar".equals(acao)) {
                dao.atualizar(new Agendamento(idAtual, ini, fim, status, obs,
                              idPet, idCliente, idAtendente, idServico));
            }
        } catch (Exception e) { e.printStackTrace(); }

        resp.sendRedirect(req.getContextPath() + "/agendamentos?msg=salvo");
    }

    private boolean autenticado(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession s = req.getSession(false);
        if (s == null || s.getAttribute("usuarioLogado") == null) {
            resp.sendRedirect(req.getContextPath() + "/login"); return false;
        }
        return true;
    }
    private int parseInt(String v) { try { return Integer.parseInt(v); } catch (Exception e) { return 0; } }
}
