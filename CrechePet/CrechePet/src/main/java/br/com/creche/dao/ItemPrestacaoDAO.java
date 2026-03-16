package br.com.creche.dao;

import br.com.creche.model.ItemPrestacao;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class ItemPrestacaoDAO {
    
    private final Connection conexao; // Conexão injetada

    public ItemPrestacaoDAO(Connection conexao) {
        this.conexao = conexao;
    }
    
    // SQLs CRUD
    private static final String INSERT_SQL = "INSERT INTO Item_Prestacao (idAgendamento, idServico, dataExecucao, valorFinal, observacoesExecucao) VALUES (?, ?, ?, ?, ?)";
    private static final String SELECT_ALL_SQL = "SELECT * FROM Item_Prestacao";
    private static final String SELECT_BY_ID_SQL = "SELECT * FROM Item_Prestacao WHERE idItemPrestacao = ?";
    private static final String UPDATE_SQL = "UPDATE Item_Prestacao SET idAgendamento = ?, idServico = ?, dataExecucao = ?, valorFinal = ?, observacoesExecucao = ? WHERE idItemPrestacao = ?";
    private static final String DELETE_SQL = "DELETE FROM Item_Prestacao WHERE idItemPrestacao = ?";
    
    // Mapeador de ResultSet para Objeto
    private ItemPrestacao mapearItemPrestacao(ResultSet rs) throws SQLException {
        return new ItemPrestacao(
            rs.getInt("idItemPrestacao"),
            rs.getInt("idAgendamento"),
            rs.getInt("idServico"),
            rs.getTimestamp("dataExecucao").toLocalDateTime(),
            rs.getDouble("valorFinal"),
            rs.getString("observacoesExecucao")
        );
    }
    
    // C - CREATE
    public void salvar(ItemPrestacao item) throws SQLException {
        try (PreparedStatement stmt = conexao.prepareStatement(INSERT_SQL, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setInt(1, item.getIdAgendamento());
            stmt.setInt(2, item.getIdServico());
            stmt.setTimestamp(3, Timestamp.valueOf(item.getDataExecucao()));
            stmt.setDouble(4, item.getValorFinal());
            stmt.setString(5, item.getObservacoesExecucao());
            
            stmt.executeUpdate();
            
            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) {
                    item.setIdItemPrestacao(rs.getInt(1));
                }
            }
        }
    }
    
    // R - READ ALL
    public List<ItemPrestacao> listarTodos() throws SQLException {
        List<ItemPrestacao> itens = new ArrayList<>();
        try (PreparedStatement stmt = conexao.prepareStatement(SELECT_ALL_SQL);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                itens.add(mapearItemPrestacao(rs));
            }
        }
        return itens;
    }
    
    // R - READ BY ID
    public ItemPrestacao buscarPorId(int id) throws SQLException {
        try (PreparedStatement stmt = conexao.prepareStatement(SELECT_BY_ID_SQL)) {
            stmt.setInt(1, id);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapearItemPrestacao(rs);
                }
            }
        }
        return null;
    }
    
    // U - UPDATE
    public void atualizar(ItemPrestacao item) throws SQLException {
        try (PreparedStatement stmt = conexao.prepareStatement(UPDATE_SQL)) {
            
            stmt.setInt(1, item.getIdAgendamento());
            stmt.setInt(2, item.getIdServico());
            stmt.setTimestamp(3, Timestamp.valueOf(item.getDataExecucao()));
            stmt.setDouble(4, item.getValorFinal());
            stmt.setString(5, item.getObservacoesExecucao());
            stmt.setInt(6, item.getIdItemPrestacao());
            
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