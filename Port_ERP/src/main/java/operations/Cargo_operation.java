package operations;

import java.util.List;
import model.Cargo;
import model.CargoMovement;

public interface Cargo_operation {
    List<Cargo> viewAllCargo();
    Cargo getCargoById(int cargoId);
    List<Cargo> searchCargo(String keyword, String containerId, String status);
    
    // Fetches container IDs and types for containers marked as 'Empty'
    List<String[]> getEmptyContainers(); 
    
    boolean addCargo(Cargo cargo, int currentUserId);
    boolean updateCargo(Cargo cargo, int currentUserId);
    boolean deleteCargo(int cargoId);
    List<CargoMovement> viewCargoMovementHistory(int cargoId);
    List<CargoMovement> viewAllCargoMovements();
    List<CargoMovement> searchCargoMovements(String keyword, String typeFilter);
}