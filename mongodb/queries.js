use parking_management_system;





// COLLECTION: parking_lots





// Q1: Find all open parking lots

print("=== Q1: Open Parking Lots ===");

db.parking_lots.find({

    status: "open"

}).pretty();



// Q2: Find lots with high occupancy (>80%)

print("\n=== Q2: High Occupancy Lots (>80%) ===");

db.parking_lots.aggregate([

    {

        $addFields: {

            occupancy_rate: {

                $multiply: [

                    { $divide: [

                        { $subtract: ["$total_slots", "$available_slots"] },

                        "$total_slots"

                    ] },

                    100

                ]

            }

        }

    },

    {

        $match: {

            occupancy_rate: { $gt: 80 }

        }

    }

]);





// COLLECTION: parking_slots





// Q3: Find all available slots with lot info

print("\n=== Q3: Available Parking Slots ===");

db.parking_slots.find({

    status: "available"

}).pretty();



// Q4: Find VIP slots

print("\n=== Q4: VIP Parking Slots ===");

db.parking_slots.find({

    type: "vip",

    status: "available"

}).pretty();



// Q5: Occupied slots with current booking

print("\n=== Q5: Occupied Slots ===");

db.parking_slots.find({

    is_occupied: true

}).pretty();



// Q6: Group slots by type and calculate occupancy

print("\n=== Q6: Occupancy by Slot Type ===");

db.parking_slots.aggregate([

    {

        $group: {

            _id: "$type",

            total_slots: { $sum: 1 },

            occupied_slots: {

                $sum: { $cond: ["$is_occupied", 1, 0] }

            }

        }

    },

    {

        $project: {

            type: "$_id",

            total_slots: 1,

            occupied_slots: 1,

            occupancy_rate: {

                $multiply: [

                    { $divide: ["$occupied_slots", "$total_slots"] },

                    100

                ]

            }

        }

    }

]);





// COLLECTION: users





// Q7: Find all VIP customers

print("\n=== Q7: VIP Customers ===");

db.users.find({

    is_vip: true

}).pretty();



// Q8: Find user by phone number

print("\n=== Q8: Find User by Phone ===");

db.users.find({

    phone_number: "0923456789"

}).pretty();



// Q9: Top customers by total spent

print("\n=== Q9: Top Customers by Spending ===");

db.users.find()

    .sort({ total_spent: -1 })

    .limit(3)

    .pretty();





// COLLECTION: staff





// Q10: Find all active staff

print("\n=== Q10: Active Staff ===");

db.staff.find({

    status: "active"

}).pretty();



// Q11: Staff by role

print("\n=== Q11: Staff Grouped by Role ===");

db.staff.aggregate([

    {

        $group: {

            _id: "$role",

            count: { $sum: 1 }

        }

    }

]);





// COLLECTION: bookings





// Q12: Find active bookings

print("\n=== Q12: Active Bookings ===");

db.bookings.find({

    booking_status: "active"

}).pretty();



// Q13: VIP customer bookings

print("\n=== Q13: VIP Customer Bookings ===");

db.bookings.find({

    "user.is_vip": true

}).pretty();



// Q14: Daily revenue report

print("\n=== Q14: Daily Revenue Report ===");

db.bookings.aggregate([

    {

        $match: {

            payment_status: "paid",

            end_time: { $ne: null }

        }

    },

    {

        $group: {

            _id: { $dateToString: { format: "%Y-%m-%d", date: { $dateFromString: { dateString: "$end_time" } } } },

            total_revenue: { $sum: "$total_fee" },

            total_bookings: { $sum: 1 }

        }

    },

    { $sort: { _id: -1 } }

]);



// Q15: Bookings by slot type

print("\n=== Q15: Bookings Grouped by Slot Type ===");

db.bookings.aggregate([

    {

        $group: {

            _id: "$slot.type",

            total_bookings: { $sum: 1 },

            total_revenue: { $sum: "$total_fee" }

        }

    }

]);





// COLLECTION: vehicles





// Q16: Find all vehicles by user

print("\n=== Q16: Vehicles of Jane Smith ===");

db.vehicles.find({

    user_name: "Jane Smith"

}).pretty();



// Q17: Find vehicle by plate number

print("\n=== Q17: Find Vehicle by Plate ===");

db.vehicles.find({

    plate_number: "AA-1234"

}).pretty();



// Q18: Group vehicles by type

print("\n=== Q18: Vehicle Count by Type ===");

db.vehicles.aggregate([

    {

        $group: {

            _id: "$vehicle_type",

            count: { $sum: 1 }

        }

    }

]);





// COLLECTION: payments





// Q19: Completed payments

print("\n=== Q19: Completed Payments ===");

db.payments.find({

    payment_status: "completed"

}).pretty();



// Q20: Payment method breakdown

print("\n=== Q20: Payment Method Analysis ===");

db.payments.aggregate([

    {

        $match: { payment_status: "completed" }

    },

    {

        $group: {

            _id: "$payment_method",

            total_amount: { $sum: "$amount" },

            count: { $sum: 1 }

        }

    },

    { $sort: { total_amount: -1 } }

]);





// COLLECTION: reservations





// Q21: Active reservations

print("\n=== Q21: Active Reservations ===");

db.reservations.find({

    status: "active"

}).pretty();



// Q22: Reservations expiring soon

print("\n=== Q22: Reservations Expiring Soon ===");

db.reservations.aggregate([

    {

        $match: { status: "active" }

    },

    {

        $addFields: {

            minutes_remaining: {

                $divide: [

                    { $subtract: [

                        { $dateFromString: { dateString: "$expiry_time" } },

                        new Date()

                    ] },

                    60000

                ]

            }

        }

    },

    {

        $match: {

            minutes_remaining: { $lt: 60, $gt: 0 }

        }

    }

]);





// COLLECTION: penalties





// Q23: Pending penalties

print("\n=== Q23: Pending Penalties ===");

db.penalties.find({

    status: "pending"

}).pretty();



// Q24: Penalties by reason

print("\n=== Q24: Penalties Grouped by Reason ===");

db.penalties.aggregate([

    {

        $group: {

            _id: "$reason",

            count: { $sum: 1 },

            total_amount: { $sum: "$amount" }

        }

    }

]);





// COLLECTION: salary_payments





// Q25: Monthly salary summary

print("\n=== Q25: Monthly Salary Summary ===");

db.salary_payments.aggregate([

    {

        $match: { payment_status: "completed" }

    },

    {

        $group: {

            _id: "$month_year",

            total_paid: { $sum: "$amount" },

            num_employees: { $sum: 1 },

            average_salary: { $avg: "$amount" }

        }

    },

    { $sort: { _id: -1 } }

]);





// COLLECTION: live_parking_status





// Q26: Current live parking status

print("\n=== Q26: Live Parking Status ===");

db.live_parking_status.findOne();





// CROSS-COLLECTION COMPLEX QUERIES





// Q27: Join bookings with payments

print("\n=== Q27: Bookings with Payment Details ===");

db.bookings.aggregate([

    {

        $lookup: {

            from: "payments",

            localField: "booking_id",

            foreignField: "booking_id",

            as: "payment_details"

        }

    },

    {

        $match: {

            "payment_details": { $ne: [] }

        }

    },

    {

        $project: {

            booking_id: 1,

            user_name: "$user.full_name",

            slot_number: "$slot.slot_number",

            total_fee: 1,

            payment_method: { $arrayElemAt: ["$payment_details.payment_method", 0] }

        }

    }

]);



// Q28: User complete history (bookings + vehicles)

print("\n=== Q28: User Complete History ===");

db.users.aggregate([

    {

        $lookup: {

            from: "vehicles",

            localField: "user_id",

            foreignField: "user_id",

            as: "user_vehicles"

        }

    },

    {

        $lookup: {

            from: "bookings",

            localField: "user_id",

            foreignField: "user.user_id",

            as: "user_bookings"

        }

    },

    {

        $project: {

            full_name: 1,

            phone_number: 1,

            is_vip: 1,

            vehicle_count: { $size: "$user_vehicles" },

            booking_count: { $size: "$user_bookings" },

            total_spent: 1

        }

    }

]);



// Q29: Staff with their salary history

print("\n=== Q29: Staff with Salary History ===");

db.staff.aggregate([

    {

        $lookup: {

            from: "salary_payments",

            localField: "staff_id",

            foreignField: "staff_id",

            as: "salary_history"

        }

    },

    {

        $project: {

            staff_id: 1,

            user_name: 1,

            role: 1,

            total_earned: { $sum: "$salary_history.amount" },

            num_payments: { $size: "$salary_history" }

        }

    }

]);


