package br.com.creche.dao;

import br.com.creche.model.Usuario;
import br.com.creche.utils.SenhaUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UsuarioDAO {

    private final Connection conexao;

    public UsuarioDAO(Connection conexao) {
        this.conexao = conexao;
    }

    private static final String INSERT_SQL =
        "INSERT INTO usuario (nomeCompleto, email, senhaHash, tipoPerfil, telefone) VALUES (?, ?, ?, ?, ?)";
    private static final String UPDATE_SQL =
        "UPDATE usuario SET nomeCompleto=?, email=?, tipoPerfil=?, telefone=? WHERE idUsuario=?";
    private static final String DELETE_SQL      = "DELETE FROM usuario WHERE idUsuario=?";
    private static final String SELECT_ALL_SQL  = "SELECT * FROM usuario ORDER BY nomeCompleto";
    private static final String SELECT_BY_ID_SQL  = "SELECT * FROM usuario WHERE idUsuario=?";
    private static final String SELECT_BY_EMAIL_SQL = "SELECT * FROM usuario WHERE email=?";

    private Usuario mapear(ResultSet rs) throws SQLException {
        Timestamp ts = rs.getTimestamp("dataCadastro");
        return new Usuario(
            rs.getInt("idUsuario"),
            rs.getString("nomeCompleto"),
            rs.getString("email"),
            rs.getString("senhaHash"),
            rs.getString("tipoPerfil"),
            rs.getString("telefone"),
            ts != null ? ts.toLocalDateTime() : null
        );
    }


    public boolean emailJaExiste(String email, int idExcluir) throws SQLException {
        String sql = "SELECT COUNT(*) FROM usuario WHERE email = ? AND idUsuario != ?";
        try (PreparedStatement stmt = conexao.prepareStatement(sql)) {
            stmt.setString(1, email);
            stmt.setInt(2, idExcluir);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    //  CRUD 

    public void registraUsuario(Usuario usuario) throws SQLException {
        usuario.setSenhaHash(SenhaUtil.hashSenha(usuario.getSenhaHash()));
        try (PreparedStatement stmt = conexao.prepareStatement(INSERT_SQL, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, usuario.getNomeCompleto());
            stmt.setString(2, usuario.getEmail());
            stmt.setString(3, usuario.getSenhaHash());
            stmt.setString(4, usuario.getTipoPerfil());
            stmt.setString(5, usuario.getTelefone());
            stmt.executeUpdate();
            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) usuario.setIdUsuario(rs.getInt(1));
            }
        }
    }

    public Usuario buscarPorId(int id) throws SQLException {
        try (PreparedStatement stmt = conexao.prepareStatement(SELECT_BY_ID_SQL)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return mapear(rs);
            }
        }
        return null;
    }

    public Usuario buscarPorEmail(String email) throws SQLException {
        try (PreparedStatement stmt = conexao.prepareStatement(SELECT_BY_EMAIL_SQL)) {
            stmt.setString(1, email);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return mapear(rs);
            }
        }
        return null;
    }

    public List<Usuario> listarTodos() throws SQLException {
        List<Usuario> lista = new ArrayList<>();
        try (PreparedStatement stmt = conexao.prepareStatement(SELECT_ALL_SQL);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) lista.add(mapear(rs));
        }
        return lista;
    }

    public Usuario autenticar(String email, String senha) throws SQLException {
        Usuario u = buscarPorEmail(email);
        if (u != null && SenhaUtil.verificar(senha, u.getSenhaHash())) return u;
        return null;
    }

    public void atualizarUsuario(Usuario usuario) throws SQLException {
        try (PreparedStatement stmt = conexao.prepareStatement(UPDATE_SQL)) {
            stmt.setString(1, usuario.getNomeCompleto());
            stmt.setString(2, usuario.getEmail());
            stmt.setString(3, usuario.getTipoPerfil());
            stmt.setString(4, usuario.getTelefone());
            stmt.setInt(5, usuario.getIdUsuario());
            stmt.executeUpdate();
        }
    }

    public void excluirUsuario(int id) throws SQLException {
        try (PreparedStatement stmt = conexao.prepareStatement(DELETE_SQL)) {
            stmt.setInt(1, id);
            stmt.executeUpdate();
        }
    }

    public int contarUsuarios() throws SQLException {
        try (PreparedStatement stmt = conexao.prepareStatement("SELECT COUNT(*) FROM usuario");
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }
}
