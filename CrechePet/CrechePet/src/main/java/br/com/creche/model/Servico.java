package br.com.creche.model;

public class Servico {
    private int idServico; 
    private String nome;
    private String descricao;
    private double valorBase;
    private int duracaoEstimadaMinutos;
    private boolean ativo;

    // Construtor Básico
    public Servico(int idServico, String nome, String descricao, double valorBase, int duracaoEstimadaMinutos, boolean ativo) {
        this.idServico = idServico;
        this.nome = nome;
        this.descricao = descricao;
        this.valorBase = valorBase;
        this.duracaoEstimadaMinutos = duracaoEstimadaMinutos;
        this.ativo = ativo;
    }

    //Getters e Setters

    public int getIdServico() {
        return idServico;
    }

    public void setIdServico(int idServico) {
        this.idServico = idServico;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public String getDescricao() {
        return descricao;
    }

    public void setDescricao(String descricao) {
        this.descricao = descricao;
    }

    public double getValorBase() {
        return valorBase;
    }

    public void setValorBase(double valorBase) {
        this.valorBase = valorBase;
    }

    public int getDuracaoEstimadaMinutos() {
        return duracaoEstimadaMinutos;
    }

    public void setDuracaoEstimadaMinutos(int duracaoEstimadaMinutos) {
        this.duracaoEstimadaMinutos = duracaoEstimadaMinutos;
    }

    public boolean isAtivo() {
        return ativo;
    }

    public void setAtivo(boolean ativo) {
        this.ativo = ativo;
    }
}