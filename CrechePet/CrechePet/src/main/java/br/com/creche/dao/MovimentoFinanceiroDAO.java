package br.com.creche.dao;

import br.com.creche.model.MovimentoFinanceiro;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class MovimentoFinanceiroDAO {
    
    private final Connection conexao; // Conexão injetada

    public MovimentoFinanceiroDAO(Connection conexao) {
        this.conexao = conexao;
    }
    
    // SQLs CRUD
    private static final String INSERT_SQL = "INSERT INTO MovimentoFinanceiro (dataMovimentacao, valor, tipoMovimentacao, descricao, idItemPrestacao) VALUES (?, ?, ?, ?, ?)";
    private static final String SELECT_ALL_SQL = "SELECT * FROM MovimentoFinanceiro ORDER BY dataMovimentacao DESC";
    private static final String SELECT_BY_ID_SQL = "SELECT * FROM MovimentoFinanceiro WHERE idMovimentacao = ?";
    private static final String UPDATE_SQL = "UPDATE MovimentoFinanceiro SET dataMovimentacao = ?, valor = ?, tipoMovimentacao = ?, descricao = ?, idItemPrestacao = ? WHERE idMovimentacao = ?";
    private static final String DELETE_SQL = "DELETE FROM MovimentoFinanceiro WHERE idMovimentacao = ?";
    
    // Mapeador de ResultSet para Objeto
    private MovimentoFinanceiro mapearMovimento(ResultSet rs) throws SQLException {
        return new MovimentoFinanceiro(
            rs.getInt("idMovimentacao"),
            rs.getTimestamp("dataMovimentacao").toLocalDateTime(),
            rs.getDouble("valor"),
            rs.getString("tipoMovimentacao"),
            rs.getString("descricao"),
            rs.getInt("idItemPrestacao")
        );
    }
    
    // C - CREATE
    public void salvar(MovimentoFinanceiro movimento) throws SQLException {
        try (PreparedStatement stmt = conexao.prepareStatement(INSERT_SQL, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setTimestamp(1, Timestamp.valueOf(movimento.getDataMovimentacao()));
            stmt.setDouble(2, movimento.getValor());
            stmt.setString(3, movimento.getTipoMovimentacao());
            stmt.setString(4, movimento.getDescricao());
            
            // Trata a FK que pode ser nula (ex: para Despesas)
            if (movimento.getIdItemPrestacao() > 0) {
                stmt.setInt(5, movimento.getIdItemPrestacao());
            } else {
                stmt.setNull(5, Types.INTEGER);
            }
            
            stmt.executeUpdate();
            
            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) {
                    movimento.setIdMovimentacao(rs.getInt(1));
                }
            }
        }
    }
    
    // R - READ ALL
    public List<MovimentoFinanceiro> listarTodos() throws SQLException {
        List<MovimentoFinanceiro> movimentos = new ArrayList<>();
        try (PreparedStatement stmt = conexao.prepareStatement(SELECT_ALL_SQL);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                movimentos.add(mapearMovimento(rs));
            }
        }
        return movimentos;
    }
    
    // R - READ BY ID
    public MovimentoFinanceiro buscarPorId(int id) throws SQLException {
        try (PreparedStatement stmt = conexao.prepareStatement(SELECT_BY_ID_SQL)) {
            stmt.setInt(1, id);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapearMovimento(rs);
                }
            }
        }
        return null;
    }
    
    // U - UPDATE
    public void atualizar(MovimentoFinanceiro movimento) throws SQLException {
        try (PreparedStatement stmt = conexao.prepareStatement(UPDATE_SQL)) {
            
            stmt.setTimestamp(1, Timestamp.valueOf(movimento.getDataMovimentacao()));
            stmt.setDouble(2, movimento.getValor());
            stmt.setString(3, movimento.getTipoMovimentacao());
            stmt.setString(4, movimento.getDescricao());

            if (movimento.getIdItemPrestacao() > 0) {
                stmt.setInt(5, movimento.getIdItemPrestacao());
            } else {
                stmt.setNull(5, Types.INTEGER);
            }
            
            stmt.setInt(6, movimento.getIdMovimentacao());
            
            stmt.executeUpdate();
        }
    }
    
    // D - DELETE
    public void excluir(int id) throws SQLException {
        try (PreparedStatement stmt = conexao.prepareStatement(DELETE_SQL)) {
            
            stmt.setInt(1, id);
            stmt.executeUpdate();
        }
    }
}