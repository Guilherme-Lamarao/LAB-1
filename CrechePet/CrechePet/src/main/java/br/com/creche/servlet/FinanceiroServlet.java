package br.com.creche.servlet;

import br.com.creche.dao.ConexaoFactory;
import br.com.creche.dao.MovimentoFinanceiroDAO;
import br.com.creche.model.MovimentoFinanceiro;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@WebServlet("/financeiro")
public class FinanceiroServlet extends HttpServlet {

    private static final DateTimeFormatter FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!autenticado(req, resp)) return;
        String acao = req.getParameter("acao");

        try (Connection con = ConexaoFactory.getConexao()) {
            MovimentoFinanceiroDAO dao = new MovimentoFinanceiroDAO(con);

            if ("excluir".equals(acao)) {
                dao.excluir(Integer.parseInt(req.getParameter("id")));
                resp.sendRedirect(req.getContextPath() + "/financeiro?msg=excluido");
                return;
            }

            req.setAttribute("movimentos", dao.listarTodos());

            if ("editar".equals(acao)) {
                req.setAttribute("movimentoEditar",
                    dao.buscarPorId(Integer.parseInt(req.getParameter("id"))));
            }

        } catch (Exception e) { req.setAttribute("erro", e.getMessage()); }

        String msg = req.getParameter("msg");
        if (msg != null) req.setAttribute("msg", msg);
        req.setAttribute("paginaAtiva", "financeiro");
        req.getRequestDispatcher("/WEB-INF/views/financeiro.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!autenticado(req, resp)) return;
        req.setCharacterEncoding("UTF-8");

        String acao      = req.getParameter("acao");
        LocalDateTime dt = LocalDateTime.parse(req.getParameter("dataMovimentacao"), FMT);
        double valor     = parseDouble(req.getParameter("valor"));
        String tipo      = req.getParameter("tipoMovimentacao");
        String desc      = req.getParameter("descricao");
        int idItem       = parseInt(req.getParameter("idItemPrestacao"));

        try (Connection con = ConexaoFactory.getConexao()) {
            MovimentoFinanceiroDAO dao = new MovimentoFinanceiroDAO(con);

            if ("salvar".equals(acao)) {
                dao.salvar(new MovimentoFinanceiro(0, dt, valor, tipo, desc, idItem));
            } else if ("atualizar".equals(acao)) {
                int id = parseInt(req.getParameter("id"));
                dao.atualizar(new MovimentoFinanceiro(id, dt, valor, tipo, desc, idItem));
            }
        } catch (Exception e) { e.printStackTrace(); }

        resp.sendRedirect(req.getContextPath() + "/financeiro?msg=salvo");
    }

    private boolean autenticado(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession s = req.getSession(false);
        if (s == null || s.getAttribute("usuarioLogado") == null) {
            resp.sendRedirect(req.getContextPath() + "/login"); return false;
        }
        return true;
    }
    private int    parseInt(String v)   { try { return Integer.parseInt(v); } catch (Exception e) { return 0; } }
    private double parseDouble(String v){ try { return Double.parseDouble(v.replace(",",".")); } catch (Exception e) { return 0; } }
}
