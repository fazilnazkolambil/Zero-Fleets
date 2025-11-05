/**
 * Scheduled Firestore field nullifier
 * Runs every Monday at 4:00 AM (Asia/Kolkata)
 */

const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

exports.weeklyReset = onSchedule(
  {
    schedule: "0 4 * * 1", // Monday 4:00 AM
    timeZone: "Asia/Kolkata",
  },
  async (event) => {
    console.log("Running scheduled nullifyFields...");

    const usersSnap = await db.collection("users").get();
    const userUpdates = usersSnap.docs.map((doc) =>
      doc.ref.update({
        'weekly_shift': null,
        'weekly_trip': null,
      })
    );

    const vehiclesSnap = await db.collection("vehicles").get();
    const vehicleUpdates = vehiclesSnap.docs.map((doc) =>
      doc.ref.update({
        'weekly_trips': null,
      })
    );

    await Promise.all([...userUpdates, ...vehicleUpdates]);
    console.log("✅ All fields set to null successfully!");
  }
);
