package br.com.creche.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class ConexaoFactory {

 
    private static final String URL     = "jdbc:mysql://localhost:3306/crechepet"
                                        + "?useSSL=false"
                                        + "&serverTimezone=America/Sao_Paulo"
                                        + "&allowPublicKeyRetrieval=true"
                                        + "&characterEncoding=UTF-8";
    private static final String USUARIO = "root";
    private static final String SENHA   = "pixel2006123#"; 
    // ============================================================

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("Driver MySQL não encontrado! "
                + "Adicione o mysql-connector-j ao projeto.", e);
        }
    }

    /** Retorna uma nova conexão com o banco de dados. */
    public static Connection getConexao() throws SQLException {
        return DriverManager.getConnection(URL, USUARIO, SENHA);
    }

    /** Fecha a conexão de forma segura (null-safe). */
    public static void fechar(Connection con) {
        if (con != null) {
            try { con.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }
}
