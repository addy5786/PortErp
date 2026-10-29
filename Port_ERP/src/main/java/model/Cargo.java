package model;

import java.io.Serializable;
import java.util.List;
import operation_implementor.Cargo_Implementor;
import operations.Cargo_operation;

public class Cargo implements Serializable {
    private static final long serialVersionUID = 1L;
    
    private int cargoId;
    private String description;
    private double weight;
    private String status;
    private int containerId;
    private String containerType;
    private int shipId;
    private String shipName;

    private static final Cargo_operation cargoDao = new Cargo_Implementor();

    public Cargo() {}

    // Operational Methods Calling DAO Implementation layer
    public static List<String[]> getEmptyContainers() {
        return cargoDao.getEmptyContainers();
    }

    public static List<Cargo> viewAllCargo() {
        return cargoDao.viewAllCargo();
    }

    public static List<Cargo> searchCargo(String keyword, String containerId, String status) {
        return cargoDao.searchCargo(keyword, containerId, status);
    }

    public static Cargo getCargoById(int cargoId) {
        return cargoDao.getCargoById(cargoId);
    }

    public boolean addCargo(int currentUserId) {
        return cargoDao.addCargo(this, currentUserId);
    }

    public boolean updateCargo(int currentUserId) {
        return cargoDao.updateCargo(this, currentUserId);
    }

    public static boolean deleteCargo(int cargoId) {
        return cargoDao.deleteCargo(cargoId);
    }

    public static List<CargoMovement> viewCargoMovementHistory(int cargoId) {
        return cargoDao.viewCargoMovementHistory(cargoId);
    }

    public static List<CargoMovement> viewAllCargoMovements() {
        return cargoDao.viewAllCargoMovements();
    }

    public static List<CargoMovement> searchCargoMovements(String keyword, String typeFilter) {
        return cargoDao.searchCargoMovements(keyword, typeFilter);
    }

    // Getters and Setters
    public int getCargoId() { return cargoId; }
    public void setCargoId(int cargoId) { this.cargoId = cargoId; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public double getWeight() { return weight; }
    public void setWeight(double weight) { this.weight = weight; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public int getContainerId() { return containerId; }
    public void setContainerId(int containerId) { this.containerId = containerId; }

    public String getContainerType() { return containerType; }
    public void setContainerType(String containerType) { this.containerType = containerType; }

    public int getShipId() { return shipId; }
    public void setShipId(int shipId) { this.shipId = shipId; }

    public String getShipName() { return shipName; }
    public void setShipName(String shipName) { this.shipName = shipName; }
}