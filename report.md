#  EXECUTIVE SUMMARY
This project delivers a comprehensive relational database solution for an
Integrated Parking Management System (PMS). The system manages ten core entities:
 • User • Booking • Payment • Penalty
 • Vehicle • Reservation • Parking Lot • Salary Payment
 • Parking Slot • Staff
By digitizing the tracking of vehicles, slot occupancy, staff shifts, and financial transactions, 
the system eliminates manual entry errors, reduces revenue leakage, and optimizes the 
utilization of physical parking assets.
The database supports real-time occupancy monitoring, VIP customer management,
automated penalty calculation, and comprehensive financial reporting. Both MySQL 
(relational) and MongoDB (NoSQL) implementations ensure flexibility for different 
operational needs.

#  INTRODUCTION & PROBLEM STATEMENT
Urban parking facilities frequently face challenges such as:
 1. Revenue leakage due to untracked overstays
 2. Slow vehicle processing at entry/exit points
 3. Inefficient space allocation across different vehicle types
 4. Lack of data for pricing optimization
 5. No systematic VIP or loyalty program
 6. Difficulty in staff shift and payroll management
 7. Manual penalty issuance and tracking
 8. No advance reservation system
This project addresses these bottlenecks by implementing a structured database that provides 
real-time visibility into facility operations, automates fee Calculation, and enables data-driven 
decision making.
# PROJECT OBJECTIVES
The primary goal is to establish a centralized repository that manages the complete lifecycle
of a parking event—from user registration and vehicle entry to automated fee calculation, 
payment processing, and penalty enforcement.
Specific Objectives:
 
 1. Design a normalized database schema (BCNF) for all parking operations
 2. Implement both MySQL (relational) and MongoDB (NoSQL) solutions
 3. Track real-time slot occupancy across multiple parking lots
 4. Automate fee calculation based on duration and slot type
 5. Support advance reservations with expiry handling
 6. Manage staff information, shifts, and salary payments
 7. Track penalties for overstay and violations
 8. Generate operational and financial reports
 9. Implement VIP customer benefits and loyalty tracking
 10. Ensure data security with role-based access control
# SYSTEM REQUIREMENTS ANALYSIS
The system is designed to handle high-concurrency environments. Key requirements
were gathered through stakeholder surveys (see Annex: survey_questions.pdf).
## Functional Requirements
 • User registration and authentication
 • Vehicle registration (multiple vehicles per user)
 • Real-time slot availability checking
 • Booking creation, modification, and cancellation
 • Advance reservation with time-limited expiry
 • Automated fee calculation based on duration
 • Payment processing (cash, card, Telebirr, mobile money)
 • Penalty issuance for overstay or violations
 • Staff shift scheduling and salary management
 • VIP customer benefits and discount logic
 • Report generation (revenue, utilization, penalties)
## Non-Functional Requirements
 • ACID compliance for financial transactions
 • Response time < 2 seconds for availability checks
 • 99.9% uptime for critical operations
 • Data retention for 7 years (financial records)
 • Role-based access control with audit logging
# DATA COLLECTION METHODOLOGY
Requirement gathering was conducted through a comprehensive 10-page stakeholder
survey distributed to:
 • Customers (Section A & D) - 50 respondents
 • Staff/Attendants (Section B) - 15 respondents
 • Management (Section C & E) - 5 respondents
Key findings from the survey:
 • 68% of customers prefer mobile money (Telebirr) payment
 • 45% of users would pay for VIP subscription (500-1000 birr/month)
 • Staff identified North Zone as highest congestion area
 • Management targets 5,000 birr daily revenue
 • Overstay penalties are most common violation (72% of penalties)
Survey responses directly informed:
 • price_per_hour values for different slot types
 • is_vip logic and discount rates
 • location_zone and floor_number assignments
 • shift_start and shift_end for staff schedules
 • penalty amount calculation rules
# ENTITY-RELATIONSHIP (ER) DIAGRAM LOGIC
The architecture follows a star-like schema where the Booking entity acts as the Central hub, 
connecting User, Vehicle, and Parking Slot. This ensures that every transaction is traceable to 
a specific individual and physical asset.
## Core Entities and Relationships
 User (1) ──────< (M) Vehicle - One user can own multiple vehicles
 User (1) ──────< (M) Booking - One user can make multiple bookings
 User (1) ──────< (M) Reservation - One user can make multiple reservations
 User (1) ──────|| (1) Staff - One user can be a staff member
 Parking Lot (1) ──< (M) Parking Slot - One lot contains multiple slots
 Parking Slot (1) ──< (M) Booking - One slot can have multiple bookings
 Parking Slot (1) ──< (M) Reservation - One slot can have multiple reservations
 Booking (1) ───── (1) Payment - Each booking has one payment
 Booking (1) ─────< (M) Penalty - One booking can have multiple penalties
 Staff (1) ──────< (M) Salary Payment - One staff receives multiple salaries

## Relational Cardinalities
 • User to Vehicle: One-to-Many (cascade delete)
 • User to Booking: One-to-Many (restrict delete)
 • Parking Lot to Parking Slot: One-to-Many (cascade delete)
 • Booking to Payment: One-to-One (unique constraint)
 • Booking to Penalty: One-to-Many (optional)
# RELATIONAL DATABASE SCHEMA DESIGN
The schema utilizes MySQL data types effectively, employing ENUM types for
status tracking and DECIMAL for financial accuracy. Foreign key constraints
maintain referential integrity.
## Complete List of Tables
 
Valid role and status values
 • DEFAULT values: created_at, status defaults
 • ON DELETE CASCADE: Automatic cleanup of dependent records
 ## Data Type Selection Rationale
 • INT/AUTO_INCREMENT: Surrogate keys for efficient joins
 • VARCHAR(20) for phone_number: E.164 format support
 • ENUM for status fields: Constrained values, storage efficiency
 • DECIMAL(10,2) for financial fields: Exact decimal precision
 • DATETIME for timestamps: Timezone-aware tracking
 • TIME for shift times: Duration-agnostic time storage
