package br.com.creche.dao;

import br.com.creche.model.Servico;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ServicoDAO {

    private final Connection conexao;

    public ServicoDAO(Connection conexao) {
        this.conexao = conexao;
    }

    private static final String INSERT_SQL =
        "INSERT INTO Servico (nome, descricao, valorBase, duracaoEstimadaMinutos, ativo) VALUES (?, ?, ?, ?, ?)";
    private static final String SELECT_ALL_SQL    = "SELECT * FROM Servico ORDER BY nome";
    private static final String SELECT_ATIVOS_SQL = "SELECT * FROM Servico WHERE ativo = TRUE ORDER BY nome";
    private static final String SELECT_BY_ID_SQL  = "SELECT * FROM Servico WHERE idServico=?";
    private static final String UPDATE_SQL =
        "UPDATE Servico SET nome=?, descricao=?, valorBase=?, duracaoEstimadaMinutos=?, ativo=? WHERE idServico=?";
    private static final String DELETE_SQL = "DELETE FROM Servico WHERE idServico=?";

    private Servico mapear(ResultSet rs) throws SQLException {
        return new Servico(
            rs.getInt("idServico"),
            rs.getString("nome"),
            rs.getString("descricao"),
            rs.getDouble("valorBase"),
            rs.getInt("duracaoEstimadaMinutos"),
            rs.getBoolean("ativo")
        );
    }

    public void salvar(Servico s) throws SQLException {
        try (PreparedStatement stmt = conexao.prepareStatement(INSERT_SQL, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, s.getNome());
            stmt.setString(2, s.getDescricao());
            stmt.setDouble(3, s.getValorBase());
            stmt.setInt(4, s.getDuracaoEstimadaMinutos());
            stmt.setBoolean(5, s.isAtivo());
            stmt.executeUpdate();
            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) s.setIdServico(rs.getInt(1));
            }
        }
    }

    public List<Servico> listarTodos() throws SQLException {
        List<Servico> lista = new ArrayList<>();
        try (PreparedStatement stmt = conexao.prepareStatement(SELECT_ALL_SQL);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) lista.add(mapear(rs));
        }
        return lista;
    }

  
    public List<Servico> listarAtivos() throws SQLException {
        List<Servico> lista = new ArrayList<>();
        try (PreparedStatement stmt = conexao.prepareStatement(SELECT_ATIVOS_SQL);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) lista.add(mapear(rs));
        }
        return lista;
    }

    public Servico buscarPorId(int id) throws SQLException {
        try (PreparedStatement stmt = conexao.prepareStatement(SELECT_BY_ID_SQL)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return mapear(rs);
            }
        }
        return null;
    }

    public void atualizar(Servico s) throws SQLException {
        try (PreparedStatement stmt = conexao.prepareStatement(UPDATE_SQL)) {
            stmt.setString(1, s.getNome());
            stmt.setString(2, s.getDescricao());
            stmt.setDouble(3, s.getValorBase());
            stmt.setInt(4, s.getDuracaoEstimadaMinutos());
            stmt.setBoolean(5, s.isAtivo());
            stmt.setInt(6, s.getIdServico());
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
