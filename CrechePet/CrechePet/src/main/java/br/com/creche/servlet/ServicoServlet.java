package br.com.creche.servlet;

import br.com.creche.dao.ConexaoFactory;
import br.com.creche.dao.ServicoDAO;
import br.com.creche.model.Servico;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;

@WebServlet("/servicos")
public class ServicoServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!autenticado(req, resp)) return;
        String acao = req.getParameter("acao");

        try (Connection con = ConexaoFactory.getConexao()) {
            ServicoDAO dao = new ServicoDAO(con);

            if ("excluir".equals(acao)) {
                dao.excluir(Integer.parseInt(req.getParameter("id")));
                resp.sendRedirect(req.getContextPath() + "/servicos?msg=excluido");
                return;
            }

            req.setAttribute("servicos", dao.listarTodos());

            if ("editar".equals(acao)) {
                req.setAttribute("servicoEditar", dao.buscarPorId(Integer.parseInt(req.getParameter("id"))));
            }

        } catch (Exception e) { req.setAttribute("erro", e.getMessage()); }

        String msg = req.getParameter("msg");
        if (msg != null) req.setAttribute("msg", msg);
        req.setAttribute("paginaAtiva", "servicos");
        req.getRequestDispatcher("/WEB-INF/views/servicos.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!autenticado(req, resp)) return;
        req.setCharacterEncoding("UTF-8");

        String acao   = req.getParameter("acao");
        String nome   = req.getParameter("nome");
        String desc   = req.getParameter("descricao");
        double valor  = parseDouble(req.getParameter("valorBase"));
        int    durMin = parseInt(req.getParameter("duracaoEstimadaMinutos"));
        boolean ativo = "true".equals(req.getParameter("ativo"));

        try (Connection con = ConexaoFactory.getConexao()) {
            ServicoDAO dao = new ServicoDAO(con);
            if ("salvar".equals(acao)) {
                dao.salvar(new Servico(0, nome, desc, valor, durMin, ativo));
            } else if ("atualizar".equals(acao)) {
                int id = parseInt(req.getParameter("id"));
                dao.atualizar(new Servico(id, nome, desc, valor, durMin, ativo));
            }
        } catch (Exception e) { e.printStackTrace(); }

        resp.sendRedirect(req.getContextPath() + "/servicos?msg=salvo");
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
