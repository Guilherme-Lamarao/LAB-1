package br.com.creche.model;

import java.time.LocalDateTime;

public class ItemPrestacao {
    private int idItemPrestacao; 
    private int idAgendamento; 
    private int idServico;
    private LocalDateTime dataExecucao;
    private double valorFinal;
    private String observacoesExecucao;

    // Construtor Básico
    public ItemPrestacao(int idItemPrestacao, int idAgendamento, int idServico, LocalDateTime dataExecucao, double valorFinal, String observacoesExecucao) {
        this.idItemPrestacao = idItemPrestacao;
        this.idAgendamento = idAgendamento;
        this.idServico = idServico;
        this.dataExecucao = dataExecucao;
        this.valorFinal = valorFinal;
        this.observacoesExecucao = observacoesExecucao;
    }

    //Getters e Setters

    public int getIdItemPrestacao() {
        return idItemPrestacao;
    }

    public void setIdItemPrestacao(int idItemPrestacao) {
        this.idItemPrestacao = idItemPrestacao;
    }

    public int getIdAgendamento() {
        return idAgendamento;
    }

    public void setIdAgendamento(int idAgendamento) {
        this.idAgendamento = idAgendamento;
    }

    public int getIdServico() {
        return idServico;
    }

    public void setIdServico(int idServico) {
        this.idServico = idServico;
    }

    public LocalDateTime getDataExecucao() {
        return dataExecucao;
    }

    public void setDataExecucao(LocalDateTime dataExecucao) {
        this.dataExecucao = dataExecucao;
    }

    public double getValorFinal() {
        return valorFinal;
    }

    public void setValorFinal(double valorFinal) {
        this.valorFinal = valorFinal;
    }

    public String getObservacoesExecucao() {
        return observacoesExecucao;
    }

    public void setObservacoesExecucao(String observacoesExecucao) {
        this.observacoesExecucao = observacoesExecucao;
    }
}