package operations;

import java.util.List;
import java.util.Map;
import model.ShipManagement;

public interface ShipManagement_Operation {

    // CRUD
    String register_ship(ShipManagement ship);
    String update_ship(ShipManagement ship);
    String delete_ship(ShipManagement ship);

    // Targeted updates
    String update_arrival_time(ShipManagement ship);
    String update_departure_time(ShipManagement ship);

    // Search / Filter — returns plain Java type, NO ResultSet
    List<Map<String, Object>> search_ship(String input);

    // Views — returns plain Java type, NO ResultSet
    List<Map<String, Object>> view_ship_list();
    List<Map<String, Object>> view_anchored_ships();
    List<Map<String, Object>> view_operators();
    List<Map<String, Object>> view_ship_containers(int shipId);
    List<Map<String, Object>> view_ship_dock(int shipId);
}