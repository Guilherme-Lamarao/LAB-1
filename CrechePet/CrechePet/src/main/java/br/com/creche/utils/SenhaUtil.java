package br.com.creche.utils;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;


public class SenhaUtil {

    private SenhaUtil() {  }

   
    public static String hashSenha(String senha) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] bytes = digest.digest(senha.getBytes(java.nio.charset.StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : bytes) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Algoritmo SHA-256 não disponível.", e);
        }
    }

  
    public static boolean verificar(String senhaDigitada, String hashArmazenado) {
        return hashSenha(senhaDigitada).equals(hashArmazenado);
    }
}
