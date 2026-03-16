package br.com.creche.servlet;

import br.com.creche.dao.ConexaoFactory;
import br.com.creche.dao.DashboardDAO;
import br.com.creche.model.Usuario;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;

@WebServlet("/home")
public class HomeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Verificação de autenticação
        HttpSession sessao = req.getSession(false);
        if (sessao == null || sessao.getAttribute("usuarioLogado") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        Usuario usuario = (Usuario) sessao.getAttribute("usuarioLogado");
        req.setAttribute("usuario", usuario);

        // Busca os dados do dashboard
        try (Connection con = ConexaoFactory.getConexao()) {

            DashboardDAO dash = new DashboardDAO(con);

            req.setAttribute("totalClientes",         dash.contarClientes());
            req.setAttribute("totalPets",             dash.contarPets());
            req.setAttribute("agendamentosHoje",      dash.contarAgendamentosHoje());
            req.setAttribute("agendamentosPendentes", dash.contarAgendamentosPendentes());
            req.setAttribute("receitaMes",            dash.receitaMesAtual());

        } catch (Exception e) {
            e.printStackTrace();
            // Passa zeros se o banco falhar — não quebra a tela
            req.setAttribute("totalClientes", 0);
            req.setAttribute("totalPets", 0);
            req.setAttribute("agendamentosHoje", 0);
            req.setAttribute("agendamentosPendentes", 0);
            req.setAttribute("receitaMes", 0.0);
            req.setAttribute("erroDb", "Aviso: não foi possível carregar os dados do banco.");
        }

        req.getRequestDispatcher("/WEB-INF/views/home.jsp").forward(req, resp);
    }
}
