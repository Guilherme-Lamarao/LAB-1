package br.com.creche.model;

import java.time.LocalDateTime;

public class Agendamento {
    private int idAgendamento;
    private LocalDateTime dataHoraInicio;
    private LocalDateTime dataHoraFim;
    private String status;
    private String observacoes;
    private int idPet;
    private int idCliente;
    private int idAtendente;
    private int idServico; 

    public Agendamento(int idAgendamento, LocalDateTime dataHoraInicio, LocalDateTime dataHoraFim,
                       String status, String observacoes,
                       int idPet, int idCliente, int idAtendente, int idServico) {
        this.idAgendamento  = idAgendamento;
        this.dataHoraInicio = dataHoraInicio;
        this.dataHoraFim    = dataHoraFim;
        this.status         = status;
        this.observacoes    = observacoes;
        this.idPet          = idPet;
        this.idCliente      = idCliente;
        this.idAtendente    = idAtendente;
        this.idServico      = idServico;
    }

    
    public Agendamento(int idAgendamento, LocalDateTime dataHoraInicio, LocalDateTime dataHoraFim,
                       String status, String observacoes,
                       int idPet, int idCliente, int idAtendente) {
        this(idAgendamento, dataHoraInicio, dataHoraFim, status, observacoes,
             idPet, idCliente, idAtendente, 0);
    }

    // Getters e Setters
    public int getIdAgendamento()                         { return idAgendamento; }
    public void setIdAgendamento(int v)                   { this.idAgendamento = v; }
    public LocalDateTime getDataHoraInicio()              { return dataHoraInicio; }
    public void setDataHoraInicio(LocalDateTime v)        { this.dataHoraInicio = v; }
    public LocalDateTime getDataHoraFim()                 { return dataHoraFim; }
    public void setDataHoraFim(LocalDateTime v)           { this.dataHoraFim = v; }
    public String getStatus()                             { return status; }
    public void setStatus(String v)                       { this.status = v; }
    public String getObservacoes()                        { return observacoes; }
    public void setObservacoes(String v)                  { this.observacoes = v; }
    public int getIdPet()                                 { return idPet; }
    public void setIdPet(int v)                           { this.idPet = v; }
    public int getIdCliente()                             { return idCliente; }
    public void setIdCliente(int v)                       { this.idCliente = v; }
    public int getIdAtendente()                           { return idAtendente; }
    public void setIdAtendente(int v)                     { this.idAtendente = v; }
    public int getIdServico()                             { return idServico; }
    public void setIdServico(int v)                       { this.idServico = v; }
}
