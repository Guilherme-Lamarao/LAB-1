package br.com.creche.model;

public class Pet {
    private int idPet; 
    private String nome;
    private String raca;
    private double peso;
    private String necessidadesEspeciais;
    private int idCliente; 

    // Construtor Básico
    public Pet(int idPet, String nome, String raca, double peso, String necessidadesEspeciais, int idCliente) {
        this.idPet = idPet;
        this.nome = nome;
        this.raca = raca;
        this.peso = peso;
        this.necessidadesEspeciais = necessidadesEspeciais;
        this.idCliente = idCliente;
    }

    //Getters e Setters

    public int getIdPet() {
        return idPet;
    }

    public void setIdPet(int idPet) {
        this.idPet = idPet;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public String getRaca() {
        return raca;
    }

    public void setRaca(String raca) {
        this.raca = raca;
    }

    public double getPeso() {
        return peso;
    }

    public void setPeso(double peso) {
        this.peso = peso;
    }

    public String getNecessidadesEspeciais() {
        return necessidadesEspeciais;
    }

    public void setNecessidadesEspeciais(String necessidadesEspeciais) {
        this.necessidadesEspeciais = necessidadesEspeciais;
    }

    public int getIdCliente() {
        return idCliente;
    }

    public void setIdCliente(int idCliente) {
        this.idCliente = idCliente;
    }
}