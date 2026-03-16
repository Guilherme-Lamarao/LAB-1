package br.com.creche.dao;

import br.com.creche.model.Pet;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class PetDAO {
    
    private final Connection conexao; // Conexão injetada

    public PetDAO(Connection conexao) {
        this.conexao = conexao;
    }
    
    // SQLs CRUD
    private static final String INSERT_SQL = "INSERT INTO Pet (nome, raca, peso, necessidadesEspeciais, idCliente) VALUES (?, ?, ?, ?, ?)";
    private static final String SELECT_ALL_SQL = "SELECT * FROM Pet";
    private static final String SELECT_BY_ID_SQL = "SELECT * FROM Pet WHERE idPet = ?";
    private static final String UPDATE_SQL = "UPDATE Pet SET nome = ?, raca = ?, peso = ?, necessidadesEspeciais = ? WHERE idPet = ?";
    private static final String DELETE_SQL = "DELETE FROM Pet WHERE idPet = ?";
    
    // Mapeador de ResultSet para Objeto
    private Pet mapearPet(ResultSet rs) throws SQLException {
        return new Pet(
            rs.getInt("idPet"),
            rs.getString("nome"),
            rs.getString("raca"),
            rs.getDouble("peso"),
            rs.getString("necessidadesEspeciais"),
            rs.getInt("idCliente")
        );
    }
    
    // C - CREATE
    public void salvar(Pet pet) throws SQLException {
        try (PreparedStatement stmt = conexao.prepareStatement(INSERT_SQL, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setString(1, pet.getNome());
            stmt.setString(2, pet.getRaca());
            stmt.setDouble(3, pet.getPeso());
            stmt.setString(4, pet.getNecessidadesEspeciais());
            stmt.setInt(5, pet.getIdCliente());
            
            stmt.executeUpdate();
            
            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) {
                    pet.setIdPet(rs.getInt(1));
                }
            }
        }
    }
    
    // R - READ ALL
    public List<Pet> listarTodos() throws SQLException {
        List<Pet> pets = new ArrayList<>();
        try (PreparedStatement stmt = conexao.prepareStatement(SELECT_ALL_SQL);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                pets.add(mapearPet(rs));
            }
        }
        return pets;
    }
    
    // R - READ BY ID
    public Pet buscarPorId(int id) throws SQLException {
        try (PreparedStatement stmt = conexao.prepareStatement(SELECT_BY_ID_SQL)) {
            stmt.setInt(1, id);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapearPet(rs);
                }
            }
        }
        return null;
    }
    
    // U - UPDATE
    public void atualizar(Pet pet) throws SQLException {
        try (PreparedStatement stmt = conexao.prepareStatement(UPDATE_SQL)) {
            
            stmt.setString(1, pet.getNome());
            stmt.setString(2, pet.getRaca());
            stmt.setDouble(3, pet.getPeso());
            stmt.setString(4, pet.getNecessidadesEspeciais());
            stmt.setInt(5, pet.getIdPet());
            
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