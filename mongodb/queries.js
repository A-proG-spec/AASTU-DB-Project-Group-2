use parking_management_system;

// Q1: Find all open parking lots
db.parking_lots.find({ status: "open" }).pretty();

// Q2: Find lots with high occupancy (>80%)
db.parking_lots.aggregate([
  {
    $addFields: {
      occupancy_rate: {
        $multiply: [
          {
            $divide: [
              { $subtract: ["$total_slots", "$available_slots"] },
              "$total_slots",
            ],
          },
          100,
        ],
      },
    },
  },
  {
    $match: {
      occupancy_rate: { $gt: 80 },
    },
  },
]);

// COLLECTION: parking_slots

// Q3: Find all available slots with lot info
db.parking_slots.find({ status: "available" }).pretty();

// Q4: Find VIP slots
db.parking_slots.find({ type: "vip", status: "available" }).pretty();

// Q5: Occupied slots with current booking
db.parking_slots.find({ is_occupied: true }).pretty();

// Q6: Group slots by type and calculate occupancy
db.parking_slots.aggregate([
  {
    $group: {
      _id: "$type",
      total_slots: { $sum: 1 },
      occupied_slots: {
        $sum: { $cond: ["$is_occupied", 1, 0] },
      },
    },
  },
  {
    $project: {
      type: "$_id",
      total_slots: 1,
      occupied_slots: 1,
      occupancy_rate: {
        $multiply: [
          { $divide: ["$occupied_slots", "$total_slots"] },
          100,
        ],
      },
    },
  },
]);

// COLLECTION: users

// Q7: Find all VIP customers
db.users.find({ is_vip: true }).pretty();

// Q8: Find user by phone number
db.users.find({ phone_number: "0923456789" }).pretty();

// Q9: Top customers by total spent
db.users.find().sort({ total_spent: -1 }).limit(3).pretty();

// COLLECTION: staff

// Q10: Find all active staff
db.staff.find({ status: "active" }).pretty();

// Q11: Staff by role
db.staff.aggregate([
  {
    $group: {
      _id: "$role",
      count: { $sum: 1 },
    },
  },
]);

// COLLECTION: bookings

// Q12: Find active bookings
db.bookings.find({ booking_status: "active" }).pretty();

// Q13: VIP customer bookings
db.bookings.find({ "user.is_vip": true }).pretty();

// Q14: Daily revenue report
db.bookings.aggregate([
  {
    $match: {
      payment_status: "paid",
      end_time: { $ne: null },
    },
  },
  {
    $group: {
      _id: {
        $dateToString: {
          format: "%Y-%m-%d",
          date: { $dateFromString: { dateString: "$end_time" } },
        },
      },
      total_revenue: { $sum: "$total_fee" },
      total_bookings: { $sum: 1 },
    },
  },
  { $sort: { _id: -1 } },
]);

// Q15: Bookings by slot type
db.bookings.aggregate([
  {
    $group: {
      _id: "$slot.type",
      total_bookings: { $sum: 1 },
      total_revenue: { $sum: "$total_fee" },
    },
  },
]);

// COLLECTION: vehicles

// Q16: Find all vehicles by user
db.vehicles.find({ user_name: "Jane Smith" }).pretty();

// Q17: Find vehicle by plate number
db.vehicles.find({ plate_number: "AA-1234" }).pretty();

// Q18: Group vehicles by type
db.vehicles.aggregate([
  {
    $group: {
      _id: "$vehicle_type",
      count: { $sum: 1 },
    },
  },
]);

// COLLECTION: payments

// Q19: Completed payments
db.payments.find({ payment_status: "completed" }).pretty();

// Q20: Payment method breakdown
db.payments.aggregate([
  {
    $match: { payment_status: "completed" },
  },
  {
    $group: {
      _id: "$payment_method",
      total_amount: { $sum: "$amount" },
      count: { $sum: 1 },
    },
  },
  { $sort: { total_amount: -1 } },
]);

// COLLECTION: reservations

// Q21: Active reservations
db.reservations.find({ status: "active" }).pretty();

// Q22: Reservations expiring soon
db.reservations.aggregate([
  {
    $match: { status: "active" },
  },
  {
    $addFields: {
      minutes_remaining: {
        $divide: [
          {
            $subtract: [
              { $dateFromString: { dateString: "$expiry_time" } },
              new Date(),
            ],
          },
          60000,
        ],
      },
    },
  },
  {
    $match: {
      minutes_remaining: { $lt: 60, $gt: 0 },
    },
  },
]);

// COLLECTION: penalties

// Q23: Pending penalties
db.penalties.find({ status: "pending" }).pretty();

// Q24: Penalties by reason
db.penalties.aggregate([
  {
    $group: {
      _id: "$reason",
      count: { $sum: 1 },
      total_amount: { $sum: "$amount" },
    },
  },
]);

// COLLECTION: salary_payments

// Q25: Monthly salary summary
db.salary_payments.aggregate([
  {
    $match: { payment_status: "completed" },
  },
  {
    $group: {
      _id: "$month_year",
      total_paid: { $sum: "$amount" },
      num_employees: { $sum: 1 },
      average_salary: { $avg: "$amount" },
    },
  },
  { $sort: { _id: -1 } },
]);

// COLLECTION: live_parking_status

// Q26: Current live parking status
db.live_parking_status.findOne();

// CROSS-COLLECTION COMPLEX QUERIES

// Q27: Join bookings with payments
db.bookings.aggregate([
  {
    $lookup: {
      from: "payments",
      localField: "booking_id",
      foreignField: "booking_id",
      as: "payment_details",
    },
  },
  {
    $match: {
      "payment_details": { $ne: [] },
    },
  },
  {
    $project: {
      booking_id: 1,
      user_name: "$user.full_name",
      slot_number: "$slot.slot_number",
      total_fee: 1,
      payment_method: { $arrayElemAt: ["$payment_details.payment_method", 0] },
    },
  },
]);

// Q28: User complete history (bookings + vehicles)
db.users.aggregate([
  {
    $lookup: {
      from: "vehicles",
      localField: "user_id",
      foreignField: "user_id",
      as: "user_vehicles",
    },
  },
  {
    $lookup: {
      from: "bookings",
      localField: "user_id",
      foreignField: "user.user_id",
      as: "user_bookings",
    },
  },
  {
    $project: {
      full_name: 1,
      phone_number: 1,
      is_vip: 1,
      vehicle_count: { $size: "$user_vehicles" },
      booking_count: { $size: "$user_bookings" },
      total_spent: 1,
    },
  },
]);

// Q29: Staff with their salary history
db.staff.aggregate([
  {
    $lookup: {
      from: "salary_payments",
      localField: "staff_id",
      foreignField: "staff_id",
      as: "salary_history",
    },
  },
  {
    $project: {
      staff_id: 1,
      user_name: 1,
      role: 1,
      total_earned: { $sum: "$salary_history.amount" },
      num_payments: { $size: "$salary_history" },
    },
  },
]);