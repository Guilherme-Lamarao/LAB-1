package br.com.creche.model;

import java.time.LocalDateTime;

public class Usuario {
    private int idUsuario;
    private String nomeCompleto;
    private String email;
    private String senhaHash;
    private String tipoPerfil;
    private String telefone;
    private LocalDateTime dataCadastro;

  
    public Usuario(int idUsuario, String nomeCompleto, String email,
                   String senhaHash, String tipoPerfil, String telefone,
                   LocalDateTime dataCadastro) {
        this.idUsuario    = idUsuario;
        this.nomeCompleto = nomeCompleto;
        this.email        = email;
        this.senhaHash    = senhaHash;
        this.tipoPerfil   = tipoPerfil;
        this.telefone     = telefone;
        this.dataCadastro = dataCadastro;
    }

   
    public Usuario(int idUsuario, String nomeCompleto, String email,
                   String senhaHash, String tipoPerfil, String telefone) {
        this(idUsuario, nomeCompleto, email, senhaHash, tipoPerfil,
             telefone, LocalDateTime.now());
    }

    // ── Getters e Setters ──────────────────────────────────────

    public int getIdUsuario()                        { return idUsuario; }
    public void setIdUsuario(int idUsuario)          { this.idUsuario = idUsuario; }

    public String getNomeCompleto()                  { return nomeCompleto; }
    public void setNomeCompleto(String v)            { this.nomeCompleto = v; }

    public String getEmail()                         { return email; }
    public void setEmail(String email)               { this.email = email; }

    public String getSenhaHash()                     { return senhaHash; }
    public void setSenhaHash(String senhaHash)       { this.senhaHash = senhaHash; }

    public String getTipoPerfil()                    { return tipoPerfil; }
    public void setTipoPerfil(String tipoPerfil)     { this.tipoPerfil = tipoPerfil; }

    public String getTelefone()                      { return telefone; }
    public void setTelefone(String telefone)         { this.telefone = telefone; }

    public LocalDateTime getDataCadastro()           { return dataCadastro; }
    public void setDataCadastro(LocalDateTime v)     { this.dataCadastro = v; }

   
    public String getPrimeiroNome() {
        if (nomeCompleto == null || nomeCompleto.isBlank()) return "Usuário";
        return nomeCompleto.split(" ")[0];
    }
}
