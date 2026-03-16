package br.com.creche.servlet;

import br.com.creche.dao.ClienteDAO;
import br.com.creche.dao.ConexaoFactory;
import br.com.creche.model.Cliente;
import br.com.creche.model.Usuario;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.util.List;

@WebServlet("/clientes")
public class ClienteServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!autenticado(req, resp)) return;
        String acao = req.getParameter("acao");

        try (Connection con = ConexaoFactory.getConexao()) {
            ClienteDAO dao = new ClienteDAO(con);

            if ("excluir".equals(acao)) {
                int id = Integer.parseInt(req.getParameter("id"));
                if (dao.possuiVinculos(id)) {
                    resp.sendRedirect(req.getContextPath() + "/clientes?msg=vinculo");
                } else {
                    dao.excluir(id);
                    resp.sendRedirect(req.getContextPath() + "/clientes?msg=excluido");
                }
                return;
            }

            List<Cliente> lista = dao.listarTodos();
            req.setAttribute("clientes", lista);

            if ("editar".equals(acao)) {
                req.setAttribute("clienteEditar",
                    dao.buscarPorId(Integer.parseInt(req.getParameter("id"))));
            }

        } catch (Exception e) {
            req.setAttribute("erro", "Erro: " + e.getMessage());
        }

        String msg = req.getParameter("msg");
        if (msg != null) req.setAttribute("msg", msg);
        req.setAttribute("paginaAtiva", "clientes");
        req.getRequestDispatcher("/WEB-INF/views/clientes.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!autenticado(req, resp)) return;
        req.setCharacterEncoding("UTF-8");

        String acao  = req.getParameter("acao");
        String nome  = req.getParameter("nome");
        String tel   = req.getParameter("telefone");
        String email = req.getParameter("email");
        String end   = req.getParameter("endereco");
        int    idAtual = parseInt(req.getParameter("id")); // 0 = novo

        HttpSession sessao = req.getSession(false);
        Usuario logado = (Usuario) sessao.getAttribute("usuarioLogado");
        int idUsuario = logado != null ? logado.getIdUsuario() : 0;

        try (Connection con = ConexaoFactory.getConexao()) {
            ClienteDAO dao = new ClienteDAO(con);

            // ── Validações de duplicidade ──
            if (dao.emailJaExiste(email, idAtual)) {
                resp.sendRedirect(req.getContextPath() + "/clientes?msg=email_dup");
                return;
            }
            if (dao.telefoneJaExiste(tel, idAtual)) {
                resp.sendRedirect(req.getContextPath() + "/clientes?msg=tel_dup");
                return;
            }

            if ("salvar".equals(acao)) {
                dao.salvar(new Cliente(0, nome, tel, email, end, idUsuario));
            } else if ("atualizar".equals(acao)) {
                Cliente original = dao.buscarPorId(idAtual);
                int idUsuOrig = original != null ? original.getIdUsuario() : idUsuario;
                dao.atualizar(new Cliente(idAtual, nome, tel, email, end, idUsuOrig));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        resp.sendRedirect(req.getContextPath() + "/clientes?msg=salvo");
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
