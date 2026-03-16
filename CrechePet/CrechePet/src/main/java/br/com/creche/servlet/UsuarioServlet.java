package br.com.creche.servlet;

import br.com.creche.dao.ConexaoFactory;
import br.com.creche.dao.UsuarioDAO;
import br.com.creche.model.Usuario;
import br.com.creche.utils.SenhaUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;

@WebServlet("/usuarios")
public class UsuarioServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!autenticado(req, resp)) return;
        String acao = req.getParameter("acao");

        HttpSession sessao  = req.getSession(false);
        Usuario logado = (Usuario) sessao.getAttribute("usuarioLogado");
        boolean isAdmin = logado != null && "Administrador".equals(logado.getTipoPerfil());

        try (Connection con = ConexaoFactory.getConexao()) {
            UsuarioDAO dao = new UsuarioDAO(con);

            if ("excluir".equals(acao)) {
                // Somente admin pode excluir
                if (!isAdmin) {
                    resp.sendRedirect(req.getContextPath() + "/usuarios?msg=sem_permissao");
                    return;
                }
                int idExcluir = Integer.parseInt(req.getParameter("id"));
                // Não pode excluir o próprio usuário
                if (logado.getIdUsuario() == idExcluir) {
                    resp.sendRedirect(req.getContextPath() + "/usuarios?msg=auto");
                    return;
                }
                dao.excluirUsuario(idExcluir);
                resp.sendRedirect(req.getContextPath() + "/usuarios?msg=excluido");
                return;
            }

            req.setAttribute("usuarios", dao.listarTodos());
            req.setAttribute("isAdmin", isAdmin);

            if ("editar".equals(acao)) {
                req.setAttribute("usuarioEditar",
                    dao.buscarPorId(Integer.parseInt(req.getParameter("id"))));
            }

        } catch (Exception e) { req.setAttribute("erro", e.getMessage()); }

        String msg = req.getParameter("msg");
        if (msg != null) req.setAttribute("msg", msg);
        req.setAttribute("paginaAtiva", "usuarios");
        req.getRequestDispatcher("/WEB-INF/views/usuarios.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!autenticado(req, resp)) return;
        req.setCharacterEncoding("UTF-8");

        String acao   = req.getParameter("acao");
        String nome   = req.getParameter("nomeCompleto");
        String email  = req.getParameter("email");
        String perfil = req.getParameter("tipoPerfil");
        String tel    = req.getParameter("telefone");
        int    idAtual = parseInt(req.getParameter("id"));

        try (Connection con = ConexaoFactory.getConexao()) {
            UsuarioDAO dao = new UsuarioDAO(con);

            // Validação de e-mail duplicado
            if (dao.emailJaExiste(email, idAtual)) {
                resp.sendRedirect(req.getContextPath() + "/usuarios?msg=email_dup");
                return;
            }

            if ("salvar".equals(acao)) {
                String senha = req.getParameter("senha");
                dao.registraUsuario(new Usuario(0, nome, email, senha, perfil, tel));
            } else if ("atualizar".equals(acao)) {
                Usuario u = dao.buscarPorId(idAtual);
                if (u != null) {
                    u.setNomeCompleto(nome);
                    u.setEmail(email);
                    u.setTipoPerfil(perfil);
                    u.setTelefone(tel);
                    String novaSenha = req.getParameter("senha");
                    if (novaSenha != null && !novaSenha.isBlank()) {
                        u.setSenhaHash(SenhaUtil.hashSenha(novaSenha));
                    }
                    dao.atualizarUsuario(u);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }

        resp.sendRedirect(req.getContextPath() + "/usuarios?msg=salvo");
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
