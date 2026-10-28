
const {setGlobalOptions} = require("firebase-functions");
const {onCall, HttpsError} = require("firebase-functions/v2/https");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore, Timestamp} = require("firebase-admin/firestore");

setGlobalOptions({maxInstances: 10, region: "asia-south2",});

initializeApp();

const db = getFirestore();

exports.validateCoupon = onCall(async (request) => {
  // Require the user to be signed in.
  if (!request.auth) {
    throw new HttpsError(
        "unauthenticated",
        "Please sign in to apply a coupon.",
    );
  }

  const code = typeof request.data?.code === "string" ?
    request.data.code.trim().toUpperCase() : "";

  const subtotal = request.data?.subtotal;

  if (!/^[A-Z0-9_-]{3,50}$/.test(code)) {
    throw new HttpsError(
        "invalid-argument",
        "Please enter a valid coupon code.",
    );
  }

  if (typeof subtotal !== "number" ||
      !Number.isFinite(subtotal) ||
      subtotal < 0) {
    throw new HttpsError(
        "invalid-argument",
        "The cart subtotal is invalid.",
    );
  }

  const couponRef = db.collection("coupons").doc(code);
  const couponSnapshot = await couponRef.get();

  if (!couponSnapshot.exists) {
    throw new HttpsError(
        "not-found",
        "This coupon does not exist.",
    );
  }

  const coupon = couponSnapshot.data();

  if (coupon.isActive !== true) {
    throw new HttpsError(
        "failed-precondition",
        "This coupon is inactive.",
    );
  }

  if (!(coupon.expiresAt instanceof Timestamp)) {
    throw new HttpsError(
        "failed-precondition",
        "This coupon has an invalid expiry date.",
    );
  }

  if (coupon.expiresAt.toMillis() <= Date.now()) {
    throw new HttpsError(
        "failed-precondition",
        "This coupon has expired.",
    );
  }

  if (typeof coupon.maxUses !== "number" ||
      typeof coupon.usedCount !== "number" ||
      coupon.maxUses < 0 ||
      coupon.usedCount < 0 ||
      coupon.usedCount >= coupon.maxUses) {
    throw new HttpsError(
        "failed-precondition",
        "This coupon has reached its usage limit.",
    );
  }

  if (typeof coupon.minSubtotal !== "number" ||
      !Number.isFinite(coupon.minSubtotal) ||
      subtotal < coupon.minSubtotal) {
    throw new HttpsError(
        "failed-precondition",
        `Your cart subtotal must be at least ₹${coupon.minSubtotal}.`,
    );
  }

  if (typeof coupon.discountValue !== "number" ||
      !Number.isFinite(coupon.discountValue) ||
      coupon.discountValue <= 0) {
    throw new HttpsError(
        "failed-precondition",
        "This coupon has an invalid discount.",
    );
  }

  let discount = 0;

  if (coupon.discountType === "percentage") {
    if (coupon.discountValue > 100) {
      throw new HttpsError(
          "failed-precondition",
          "This coupon has an invalid percentage.",
      );
    }

    discount = subtotal * coupon.discountValue / 100;

    if (typeof coupon.maxDiscount === "number" &&
        Number.isFinite(coupon.maxDiscount) &&
        coupon.maxDiscount >= 0) {
      discount = Math.min(discount, coupon.maxDiscount);
    }
  } else if (coupon.discountType === "fixed") {
    discount = coupon.discountValue;
  } else {
    throw new HttpsError(
        "failed-precondition",
        "This coupon has an unsupported discount type.",
    );
  }

  // A discount must never exceed the subtotal.
  discount = Math.min(discount, subtotal);

  // Return currency amounts rounded to two decimal places.
  discount = Math.round((discount + Number.EPSILON) * 100) / 100;

  return {
    valid: true,
    code,
    discountType: coupon.discountType,
    discountValue: coupon.discountValue,
    discountAmount: discount,
    finalSubtotal: Math.round(
        (subtotal - discount + Number.EPSILON) * 100,
    ) / 100,
    message: "Coupon applied successfully.",
  };
});
