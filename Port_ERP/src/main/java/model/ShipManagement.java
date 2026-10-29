package model;

import java.sql.Timestamp;
import java.util.List;
import java.util.Map;
import operation_implementor.ShipManagement_Implementor;

public class ShipManagement {

    private int shipId;
    private String shipName;
    private Timestamp arrivalDate;
    private Timestamp departureDate;
    private String status;
    private int operatorId;

    public ShipManagement() {}

    public int getShipId()                          { return shipId; }
    public void setShipId(int shipId)               { this.shipId = shipId; }
    public String getShipName()                     { return shipName; }
    public void setShipName(String shipName)        { this.shipName = shipName; }
    public Timestamp getArrivalDate()               { return arrivalDate; }
    public void setArrivalDate(Timestamp t)         { this.arrivalDate = t; }
    public Timestamp getDepartureDate()             { return departureDate; }
    public void setDepartureDate(Timestamp t)       { this.departureDate = t; }
    public String getStatus()                       { return status; }
    public void setStatus(String status)            { this.status = status; }
    public int getOperatorId()                      { return operatorId; }
    public void setOperatorId(int operatorId)       { this.operatorId = operatorId; }

    // Implementor instance
    ShipManagement_Implementor implementor = new ShipManagement_Implementor();

    // CRUD — plain String returns
    public String register_ship(ShipManagement ship)       { return implementor.register_ship(ship); }
    public String update_ship(ShipManagement ship)         { return implementor.update_ship(ship); }
    public String delete_ship(ShipManagement ship)         { return implementor.delete_ship(ship); }
    public String update_arrival_time(ShipManagement ship) { return implementor.update_arrival_time(ship); }
    public String update_departure_time(ShipManagement ship){ return implementor.update_departure_time(ship); }

    // Views — plain List returns, NO ResultSet
    public List<Map<String, Object>> search_ship(String input)         { return implementor.search_ship(input); }
    public List<Map<String, Object>> view_ship_list()                  { return implementor.view_ship_list(); }
    public List<Map<String, Object>> view_anchored_ships()             { return implementor.view_anchored_ships(); }
    public List<Map<String, Object>> view_operators()                  { return implementor.view_operators(); }
    public List<Map<String, Object>> view_ship_containers(int shipId)  { return implementor.view_ship_containers(shipId); }
    public List<Map<String, Object>> view_ship_dock(int shipId)        { return implementor.view_ship_dock(shipId); }
}