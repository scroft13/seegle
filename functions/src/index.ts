import { onDocumentCreated } from "firebase-functions/firestore";
import * as admin from "firebase-admin";

admin.initializeApp();

/**
 * Determines if a user should receive a notification for a flock.
 */

async function shouldNotify(userId: string, flockId: string): Promise<boolean> {
  const db = admin.firestore();

  const profileSnap = await db
    .collection("users")
    .doc(userId)
    .collection("notification_settings")
    .doc("profile")
    .get();

  const overrideSnap = await db
    .collection("users")
    .doc(userId)
    .collection("notification_settings")
    .doc("flocks")
    .collection(flockId)
    .doc("override")
    .get();

  const global = profileSnap.data()?.notificationsEnabled ?? true;
  const defaultFlock = profileSnap.data()?.defaultFlockNotifications ?? true;
  const override = overrideSnap.data()?.notificationsEnabled;

  return global && (override ?? defaultFlock);
}

export const notifyOnNewSquawk = onDocumentCreated(
  "squawks/{squawkId}",
  async (event) => {
    const squawk = event.data?.data();
    if (!squawk) return;

    const flockId = squawk.flockId;
    if (!flockId || typeof flockId !== "string") {
      console.error("🚫 Invalid flockId:", flockId);
      return;
    }
    const createdBy = squawk.userId;

    const db = admin.firestore();
    const flockDoc = await db.collection("flocks").doc(flockId).get();
    const memberIds: string[] = flockDoc.data()?.memberIds || [];
    const flockName: string = flockDoc.data()?.flockName || "a flock you're in";

    for (const userId of memberIds) {
      if (!userId || typeof userId !== "string") {
        console.error("🚫 Invalid userId:", userId);
        continue;
      }

      if (userId === createdBy) continue;

      const notify = await shouldNotify(userId, flockId);
      if (!notify) continue;

      const userDoc = await db.collection("users").doc(userId).get();
      const token = userDoc.data()?.pushToken;

      if (token) {
        try {
          await admin.messaging().send({
            token,
            notification: {
              title: `New squawk in ${flockName}`,
              body: squawk.title || "Someone squawked something.",
            },
          });
        } catch (error) {
          console.error("🔥 Push failed:", error);
        }
      }
    }
  }
);
