package com.aifitness.user;

import java.io.Serializable;
import java.util.Objects;

public class UserEquipmentId implements Serializable {
    private Long user;
    private Long equipment;

    public UserEquipmentId() {}

    public UserEquipmentId(Long user, Long equipment) {
        this.user = user;
        this.equipment = equipment;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        UserEquipmentId that = (UserEquipmentId) o;
        return Objects.equals(user, that.user) && Objects.equals(equipment, that.equipment);
    }

    @Override
    public int hashCode() {
        return Objects.hash(user, equipment);
    }
}

