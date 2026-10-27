
const {initializeApp} = require("firebase-admin/app");
const {getFirestore, Timestamp} = require("firebase-admin/firestore");

if (!process.env.FIRESTORE_EMULATOR_HOST) {
  throw new Error(
      "Safety check failed: FIRESTORE_EMULATOR_HOST is not set.",
  );
}

initializeApp({projectId: "cynx-kage"});

const db = getFirestore();

async function main() {
    await db.collection("coupons").doc("EXPIRED10").set({
    code: "EXPIRED10",
    discountType: "percentage",
    discountValue: 10,
    minSubtotal: 999,
    maxDiscount: 300,
    isActive: true,
    expiresAt: Timestamp.fromDate(new Date("2020-01-01T00:00:00Z")),
    maxUses: 100,
    usedCount: 0,
  });

  console.log("EXPIRED10 created in the local Firestore emulator.");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

