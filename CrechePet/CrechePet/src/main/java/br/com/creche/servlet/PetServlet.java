package br.com.creche.servlet;

import br.com.creche.dao.ClienteDAO;
import br.com.creche.dao.ConexaoFactory;
import br.com.creche.dao.PetDAO;
import br.com.creche.model.Cliente;
import br.com.creche.model.Pet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.util.List;

@WebServlet("/pets")
public class PetServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!autenticado(req, resp)) return;
        String acao = req.getParameter("acao");

        try (Connection con = ConexaoFactory.getConexao()) {
            PetDAO dao       = new PetDAO(con);
            ClienteDAO cDao  = new ClienteDAO(con);

            if ("excluir".equals(acao)) {
                dao.excluir(Integer.parseInt(req.getParameter("id")));
                resp.sendRedirect(req.getContextPath() + "/pets?msg=excluido");
                return;
            }

            req.setAttribute("pets", dao.listarTodos());
            req.setAttribute("clientes", cDao.listarTodos());

            if ("editar".equals(acao)) {
                req.setAttribute("petEditar", dao.buscarPorId(Integer.parseInt(req.getParameter("id"))));
            }

        } catch (Exception e) {
            req.setAttribute("erro", e.getMessage());
        }

        String msg = req.getParameter("msg");
        if (msg != null) req.setAttribute("msg", msg);
        req.setAttribute("paginaAtiva", "pets");
        req.getRequestDispatcher("/WEB-INF/views/pets.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!autenticado(req, resp)) return;
        req.setCharacterEncoding("UTF-8");

        String acao       = req.getParameter("acao");
        String nome       = req.getParameter("nome");
        String raca       = req.getParameter("raca");
        double peso       = parseDouble(req.getParameter("peso"));
        String nec        = req.getParameter("necessidadesEspeciais");
        int    idCliente  = parseInt(req.getParameter("idCliente"));

        try (Connection con = ConexaoFactory.getConexao()) {
            PetDAO dao = new PetDAO(con);

            if ("salvar".equals(acao)) {
                dao.salvar(new Pet(0, nome, raca, peso, nec, idCliente));
            } else if ("atualizar".equals(acao)) {
                int id = parseInt(req.getParameter("id"));
                dao.atualizar(new Pet(id, nome, raca, peso, nec, idCliente));
            }
        } catch (Exception e) { e.printStackTrace(); }

        resp.sendRedirect(req.getContextPath() + "/pets?msg=salvo");
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
