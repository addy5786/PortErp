package model;

import java.io.Serializable;
import java.sql.Timestamp;

public class CargoMovement implements Serializable {
    private static final long serialVersionUID = 1L;

    private int movementId;
    private int cargoId;
    private String movementType;
    private Timestamp movementDate;
    private String handlerName;

    public CargoMovement() {}

    // Getters and Setters
    public int getMovementId() { return movementId; }
    public void setMovementId(int movementId) { this.movementId = movementId; }

    public int getCargoId() { return cargoId; }
    public void setCargoId(int cargoId) { this.cargoId = cargoId; }

    public String getMovementType() { return movementType; }
    public void setMovementType(String movementType) { this.movementType = movementType; }

    public Timestamp getMovementDate() { return movementDate; }
    public void setMovementDate(Timestamp movementDate) { this.movementDate = movementDate; }

    public String getHandlerName() { return handlerName; }
    public void setHandlerName(String handlerName) { this.handlerName = handlerName; }
}