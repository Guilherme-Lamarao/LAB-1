package br.com.creche.dao;

import br.com.creche.model.Cliente;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@SuppressWarnings("unused")
public class ClienteDAO {

    private final Connection conexao;

    public ClienteDAO(Connection conexao) {
        this.conexao = conexao;
    }

    private static final String INSERT_SQL =
        "INSERT INTO Cliente (nome, telefone, email, endereco, idUsuario) VALUES (?, ?, ?, ?, ?)";
    private static final String SELECT_ALL_SQL  = "SELECT * FROM Cliente ORDER BY nome";
    private static final String SELECT_BY_ID_SQL = "SELECT * FROM Cliente WHERE idCliente = ?";
    private static final String UPDATE_SQL =
        "UPDATE Cliente SET nome=?, telefone=?, email=?, endereco=? WHERE idCliente=?";
    private static final String DELETE_SQL = "DELETE FROM Cliente WHERE idCliente=?";

    private Cliente mapear(ResultSet rs) throws SQLException {
        return new Cliente(
            rs.getInt("idCliente"),
            rs.getString("nome"),
            rs.getString("telefone"),
            rs.getString("email"),
            rs.getString("endereco"),
            rs.getInt("idUsuario")
        );
    }

    // ── Verificações de unicidade ──────────────────────────────

    /** Retorna true se outro cliente (diferente de idExcluir) já usa esse e-mail. */
    public boolean emailJaExiste(String email, int idExcluir) throws SQLException {
        if (email == null || email.isBlank()) return false;
        String sql = "SELECT COUNT(*) FROM Cliente WHERE email = ? AND idCliente != ?";
        try (PreparedStatement stmt = conexao.prepareStatement(sql)) {
            stmt.setString(1, email);
            stmt.setInt(2, idExcluir);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    /** Retorna true se outro cliente (diferente de idExcluir) já usa esse telefone. */
    public boolean telefoneJaExiste(String telefone, int idExcluir) throws SQLException {
        if (telefone == null || telefone.isBlank()) return false;
        String sql = "SELECT COUNT(*) FROM Cliente WHERE telefone = ? AND idCliente != ?";
        try (PreparedStatement stmt = conexao.prepareStatement(sql)) {
            stmt.setString(1, telefone);
            stmt.setInt(2, idExcluir);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    /** Retorna true se o cliente possui pets ou agendamentos vinculados (impede exclusão). */
    public boolean possuiVinculos(int idCliente) throws SQLException {
        String sqlPet  = "SELECT COUNT(*) FROM Pet WHERE idCliente = ?";
        String sqlAgend = "SELECT COUNT(*) FROM Agendamento WHERE idCliente = ?";
        try (PreparedStatement s = conexao.prepareStatement(sqlPet)) {
            s.setInt(1, idCliente);
            try (ResultSet rs = s.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) return true;
            }
        }
        try (PreparedStatement s = conexao.prepareStatement(sqlAgend)) {
            s.setInt(1, idCliente);
            try (ResultSet rs = s.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) return true;
            }
        }
        return false;
    }

    // ── CRUD ──────────────────────────────────────────────────

    public void salvar(Cliente cliente) throws SQLException {
        try (PreparedStatement stmt = conexao.prepareStatement(INSERT_SQL, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, cliente.getNome());
            stmt.setString(2, cliente.getTelefone());
            stmt.setString(3, cliente.getEmail());
            stmt.setString(4, cliente.getEndereco());
            if (cliente.getIdUsuario() > 0) stmt.setInt(5, cliente.getIdUsuario());
            else stmt.setNull(5, Types.INTEGER);
            stmt.executeUpdate();
            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) cliente.setIdCliente(rs.getInt(1));
            }
        }
    }

    public List<Cliente> listarTodos() throws SQLException {
        List<Cliente> lista = new ArrayList<>();
        try (PreparedStatement stmt = conexao.prepareStatement(SELECT_ALL_SQL);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) lista.add(mapear(rs));
        }
        return lista;
    }

    public Cliente buscarPorId(int id) throws SQLException {
        try (PreparedStatement stmt = conexao.prepareStatement(SELECT_BY_ID_SQL)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return mapear(rs);
            }
        }
        return null;
    }

    public void atualizar(Cliente cliente) throws SQLException {
        try (PreparedStatement stmt = conexao.prepareStatement(UPDATE_SQL)) {
            stmt.setString(1, cliente.getNome());
            stmt.setString(2, cliente.getTelefone());
            stmt.setString(3, cliente.getEmail());
            stmt.setString(4, cliente.getEndereco());
            stmt.setInt(5, cliente.getIdCliente());
            stmt.executeUpdate();
        }
    }

    public void excluir(int id) throws SQLException {
        try (PreparedStatement stmt = conexao.prepareStatement(DELETE_SQL)) {
            stmt.setInt(1, id);
            stmt.executeUpdate();
        }
    }
}
