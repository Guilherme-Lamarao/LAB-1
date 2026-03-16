package br.com.creche.dao;

import br.com.creche.model.Agendamento;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class AgendamentoDAO {

    private final Connection conexao;

    public AgendamentoDAO(Connection conexao) {
        this.conexao = conexao;
    }

    private static final String INSERT_SQL =
        "INSERT INTO Agendamento (dataHoraInicio, dataHoraFim, status, observacoes, idPet, idCliente, idAtendente, idServico) " +
        "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
    private static final String SELECT_ALL_SQL =
        "SELECT * FROM Agendamento ORDER BY dataHoraInicio DESC";
    private static final String SELECT_BY_ID_SQL =
        "SELECT * FROM Agendamento WHERE idAgendamento = ?";
    private static final String UPDATE_SQL =
        "UPDATE Agendamento SET dataHoraInicio=?, dataHoraFim=?, status=?, observacoes=?, " +
        "idPet=?, idCliente=?, idAtendente=?, idServico=? WHERE idAgendamento=?";
    private static final String DELETE_SQL =
        "DELETE FROM Agendamento WHERE idAgendamento = ?";

    private Agendamento mapear(ResultSet rs) throws SQLException {
        return new Agendamento(
            rs.getInt("idAgendamento"),
            rs.getTimestamp("dataHoraInicio").toLocalDateTime(),
            rs.getTimestamp("dataHoraFim").toLocalDateTime(),
            rs.getString("status"),
            rs.getString("observacoes"),
            rs.getInt("idPet"),
            rs.getInt("idCliente"),
            rs.getInt("idAtendente"),
            rs.getInt("idServico")
        );
    }

    public void salvar(Agendamento a) throws SQLException {
        try (PreparedStatement stmt = conexao.prepareStatement(INSERT_SQL, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setTimestamp(1, Timestamp.valueOf(a.getDataHoraInicio()));
            stmt.setTimestamp(2, Timestamp.valueOf(a.getDataHoraFim()));
            stmt.setString(3, a.getStatus());
            stmt.setString(4, a.getObservacoes());
            stmt.setInt(5, a.getIdPet());
            stmt.setInt(6, a.getIdCliente());
            if (a.getIdAtendente() > 0) stmt.setInt(7, a.getIdAtendente()); else stmt.setNull(7, Types.INTEGER);
            if (a.getIdServico()   > 0) stmt.setInt(8, a.getIdServico());   else stmt.setNull(8, Types.INTEGER);
            stmt.executeUpdate();
            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) a.setIdAgendamento(rs.getInt(1));
            }
        }
    }

    public List<Agendamento> listarTodos() throws SQLException {
        List<Agendamento> lista = new ArrayList<>();
        try (PreparedStatement stmt = conexao.prepareStatement(SELECT_ALL_SQL);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) lista.add(mapear(rs));
        }
        return lista;
    }

    public Agendamento buscarPorId(int id) throws SQLException {
        try (PreparedStatement stmt = conexao.prepareStatement(SELECT_BY_ID_SQL)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return mapear(rs);
            }
        }
        return null;
    }

    public void atualizar(Agendamento a) throws SQLException {
        try (PreparedStatement stmt = conexao.prepareStatement(UPDATE_SQL)) {
            stmt.setTimestamp(1, Timestamp.valueOf(a.getDataHoraInicio()));
            stmt.setTimestamp(2, Timestamp.valueOf(a.getDataHoraFim()));
            stmt.setString(3, a.getStatus());
            stmt.setString(4, a.getObservacoes());
            stmt.setInt(5, a.getIdPet());
            stmt.setInt(6, a.getIdCliente());
            if (a.getIdAtendente() > 0) stmt.setInt(7, a.getIdAtendente()); else stmt.setNull(7, Types.INTEGER);
            if (a.getIdServico()   > 0) stmt.setInt(8, a.getIdServico());   else stmt.setNull(8, Types.INTEGER);
            stmt.setInt(9, a.getIdAgendamento());
            stmt.executeUpdate();
        }
    }

    public void excluir(int id) throws SQLException {
        try (PreparedStatement stmt = conexao.prepareStatement(DELETE_SQL)) {
            stmt.setInt(1, id);
            stmt.executeUpdate();
        }
    }

    /**
     * Verifica conflito de horário pelo MESMO SERVIÇO.
     * Exclui o próprio agendamento ao editar (idExcluir > 0).
     */
    public boolean verificarConflitoPorServico(int idServico, LocalDateTime inicio,
                                               LocalDateTime fim, int idExcluir) throws SQLException {
        String sql = "SELECT COUNT(*) FROM Agendamento " +
                     "WHERE idServico = ? " +
                     "AND status IN ('Confirmado','Pendente') " +
                     "AND idAgendamento != ? " +
                     "AND dataHoraInicio < ? AND dataHoraFim > ?";
        try (PreparedStatement stmt = conexao.prepareStatement(sql)) {
            stmt.setInt(1, idServico);
            stmt.setInt(2, idExcluir);
            stmt.setTimestamp(3, Timestamp.valueOf(fim));
            stmt.setTimestamp(4, Timestamp.valueOf(inicio));
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        }
        return false;
    }
}
