const admin = require("firebase-admin");
const fs = require("fs");
const csv = require("csv-parser");

// Initialize Firebase Admin SDK
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();
const collectionRef = db.collection("flocks");

// Read the new flock names from CSV
const newFlocks = new Set();
const flockData = [];

fs.createReadStream("hobby_categories_formatted.csv")
  .pipe(csv())
  .on("data", (row) => {
    newFlocks.add(row.uniqueFlockName); // Store new flock names
    flockData.push(row); // Store formatted flock data
  })
  .on("end", async () => {
    console.log("✅ Flocks from CSV loaded.");

    try {
      // Step 1: Fetch all existing flocks
      const snapshot = await collectionRef.get();
      const existingFlocks = new Map();

      snapshot.forEach((doc) => {
        existingFlocks.set(doc.id, doc.ref); // Store doc IDs and references
      });

      // Step 2: Delete any flocks not in the new CSV
      for (const [flockName, docRef] of existingFlocks) {
        if (!newFlocks.has(flockName)) {
          console.log(`🗑 Deleting old flock: ${flockName}`);
          await docRef.delete();
        }
      }

      console.log("✅ Outdated flocks removed.");

      // Step 3: Upload the new flocks
      for (const row of flockData) {
        try {
          await collectionRef.doc(row.uniqueFlockName).set({
            banned: JSON.parse(row.banned),
            createdAt: new Date(row.createdAt),
            createdBy: row.createdBy,
            description: row.description,
            flockName: row.flockName,
            isPrivate: row.isPrivate === "TRUE",
            memberIds: JSON.parse(row.memberIds),
            members: JSON.parse(row.members),
            squawks: JSON.parse(row.squawks),
            uniqueFlockName: row.uniqueFlockName,
          });
          console.log(`✅ Uploaded: ${row.flockName}`);
        } catch (error) {
          console.error(`❌ Error uploading ${row.flockName}:`, error);
        }
      }

      console.log("🎉 All flocks updated successfully!");
    } catch (error) {
      console.error("❌ Error updating Firestore:", error);
    }
  });
