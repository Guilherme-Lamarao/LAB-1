package br.com.creche.model;

import java.time.LocalDateTime;

public class MovimentoFinanceiro {
    private int idMovimentacao; 
    private LocalDateTime dataMovimentacao;
    private double valor;
    private String tipoMovimentacao;
    private String descricao;
    private int idItemPrestacao; 

    // Construtor Básico
    public MovimentoFinanceiro(int idMovimentacao, LocalDateTime dataMovimentacao, double valor, String tipoMovimentacao, String descricao, int idItemPrestacao) {
        this.idMovimentacao = idMovimentacao;
        this.dataMovimentacao = dataMovimentacao;
        this.valor = valor;
        this.tipoMovimentacao = tipoMovimentacao;
        this.descricao = descricao;
        this.idItemPrestacao = idItemPrestacao;
    }

    //Getters e Setters

    public int getIdMovimentacao() {
        return idMovimentacao;
    }

    public void setIdMovimentacao(int idMovimentacao) {
        this.idMovimentacao = idMovimentacao;
    }

    public LocalDateTime getDataMovimentacao() {
        return dataMovimentacao;
    }

    public void setDataMovimentacao(LocalDateTime dataMovimentacao) {
        this.dataMovimentacao = dataMovimentacao;
    }

    public double getValor() {
        return valor;
    }

    public void setValor(double valor) {
        this.valor = valor;
    }

    public String getTipoMovimentacao() {
        return tipoMovimentacao;
    }

    public void setTipoMovimentacao(String tipoMovimentacao) {
        this.tipoMovimentacao = tipoMovimentacao;
    }

    public String getDescricao() {
        return descricao;
    }

    public void setDescricao(String descricao) {
        this.descricao = descricao;
    }

    public int getIdItemPrestacao() {
        return idItemPrestacao;
    }

    public void setIdItemPrestacao(int idItemPrestacao) {
        this.idItemPrestacao = idItemPrestacao;
    }
}