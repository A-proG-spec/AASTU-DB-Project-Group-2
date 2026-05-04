# Smart Parking System - Database Normalization

**Group 2**  
**Course:** Database systems(SWEG2108)
**Instructor:** Yaynshet Medhin


## 1. Unnormalized Form (UNF) - Initial Data

Before normalization, all data is gonna be stored in a single table with repeating groups:

| Field | Contains |
|-------|----------|
| username, password, role, isVIP | User details |
| plate_number, vehicle_type | Vehicle details |
| slot_id, slot_type, price_per_hour | Parking slot details |
| booking_id, start_time, end_time, total_fee, status | Booking details |
| payment_id, amount, payment_status | Payment details |

**Problems:**
- Repeating groups (a user can have multiple vehicles and bookings)
- Data redundancy
- Update anomalies
- Insertion anomalies
- Deletion anomalies


## 2. First Normal Form (1NF)

**Rule:** Eliminate repeating groups. Ensure each column contains atomic (indivisible) values. Each table must have a primary key.

### Transformation Applied:

✅ Separated repeating groups into distinct entities  
✅ Identified primary keys for each entity  
✅ Ensured all attributes are atomic values

### Resulting Entities (1NF):

| Entity | Primary Key | Attributes |
|--------|-------------|------------|
| User | user_id | username, password_hash, role, is_vip |
| Vehicle | plate_number | user_id (FK), vehicle_type |
| ParkingSlot | slot_id | slot_type, price_per_hour, is_occupied |
| Booking | booking_id | user_id (FK), plate_number (FK), slot_id (FK), start_time, end_time, total_fee, status |
| Payment | payment_id | booking_id (FK), amount, payment_status |

**1NF Status:** ✅ Complete — No repeating groups, all values atomic, primary keys defined.

---
