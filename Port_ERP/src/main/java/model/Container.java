package model;

import java.util.List;
import operation_implementor.Container_implementor;

public class Container {

    private int container_id;
    private String container_type;
    private String status;
    private int ship_id;
    private String ship_name;

    private int cargo_id;
    private String description;
    private double weight;
    private String cargoStatus;

    private static final Container_implementor implementor = new Container_implementor();

    public int getContainer_id()                        { return container_id; }
    public void setContainer_id(int container_id)       { this.container_id = container_id; }
    public String getContainer_type()                   { return container_type; }
    public void setContainer_type(String container_type){ this.container_type = container_type; }
    public String getStatus()                           { return status; }
    public void setStatus(String status)                { this.status = status; }
    public int getShip_id()                             { return ship_id; }
    public void setShip_id(int ship_id)                 { this.ship_id = ship_id; }
    public String getShip_name()                        { return ship_name; }
    public void setShip_name(String ship_name)          { this.ship_name = ship_name; }
    public int getCargo_id()                            { return cargo_id; }
    public void setCargo_id(int cargo_id)               { this.cargo_id = cargo_id; }
    public String getDescription()                      { return description; }
    public void setDescription(String description)      { this.description = description; }
    public double getWeight()                           { return weight; }
    public void setWeight(double weight)                { this.weight = weight; }
    public String getCargoStatus()                      { return cargoStatus; }
    public void setCargoStatus(String cargoStatus)      { this.cargoStatus = cargoStatus; }

    public static List<String[]> getDockedShips()       { return implementor.getDockedShips(); }
    public String addContainer(Container c)             { return implementor.addContainer(c); }
    public static List<Container> viewContainers()      { return implementor.viewContainers(); }
    public String updateContainer(Container c)          { return implementor.updateContainer(c); }
    public static String deleteContainer(int id)        { return implementor.deleteContainer(id); }
    public static List<Container> filterContainer(String input)         { return implementor.filterContainer(input); }
    public static List<Container> viewContainerDetails(int container_id){ return implementor.viewContainerDetails(container_id); }
}