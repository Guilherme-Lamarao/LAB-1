package br.com.creche.dao;

import java.sql.*;

/**
 * Métodos extras para o Dashboard — conta registros de cada entidade.
 * Basta chamar esses métodos no HomeServlet para popular os cards.
 */
public class DashboardDAO {

    private final Connection conexao;

    public DashboardDAO(Connection conexao) {
        this.conexao = conexao;
    }

    public int contarClientes() throws SQLException {
        return contar("SELECT COUNT(*) FROM Cliente");
    }

    public int contarPets() throws SQLException {
        return contar("SELECT COUNT(*) FROM Pet");
    }

    public int contarAgendamentosHoje() throws SQLException {
        String sql = "SELECT COUNT(*) FROM Agendamento "
                   + "WHERE DATE(dataHoraInicio) = CURDATE()";
        return contar(sql);
    }

    public int contarAgendamentosPendentes() throws SQLException {
        String sql = "SELECT COUNT(*) FROM Agendamento WHERE status = 'Pendente'";
        return contar(sql);
    }

    public double receitaMesAtual() throws SQLException {
        String sql = "SELECT COALESCE(SUM(valor), 0) FROM MovimentoFinanceiro "
                   + "WHERE tipoMovimentacao = 'Receita' "
                   + "AND MONTH(dataMovimentacao) = MONTH(CURDATE()) "
                   + "AND YEAR(dataMovimentacao)  = YEAR(CURDATE())";
        try (PreparedStatement stmt = conexao.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) return rs.getDouble(1);
        }
        return 0.0;
    }

    private int contar(String sql) throws SQLException {
        try (PreparedStatement stmt = conexao.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }
}
