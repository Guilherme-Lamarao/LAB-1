package br.com.creche.servlet;

import br.com.creche.dao.ConexaoFactory;
import br.com.creche.dao.UsuarioDAO;
import br.com.creche.model.Usuario;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

   
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Se já estiver logado, redireciona para o home
        HttpSession sessao = req.getSession(false);
        if (sessao != null && sessao.getAttribute("usuarioLogado") != null) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }
        req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
    }

    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        String email = req.getParameter("email");
        String senha = req.getParameter("senha");

      
        if (email == null || email.trim().isEmpty() || senha == null || senha.trim().isEmpty()) {
            req.setAttribute("erro", "Preencha o e-mail e a senha.");
            req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
            return;
        }

        try (Connection con = ConexaoFactory.getConexao()) {

            UsuarioDAO dao = new UsuarioDAO(con);
            Usuario usuario = dao.autenticar(email, senha);

            if (usuario != null) {
                HttpSession sessao = req.getSession(true);
                sessao.setAttribute("usuarioLogado", usuario);
                sessao.setMaxInactiveInterval(60 * 60); 
                resp.sendRedirect(req.getContextPath() + "/home");
            } else {
                req.setAttribute("erro", "E-mail ou senha incorretos.");
                req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
            }

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("erro", "Erro ao conectar ao banco de dados: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
        }
    }
}
