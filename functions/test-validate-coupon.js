
const {validateCoupon} = require("./index.js");

async function main() {
  const result = await validateCoupon.run({
    data: {
      code: "EXPIRED10",
subtotal: 1500,
    },
    auth: {
      uid: "local-test-user",
      token: {
        firebase: {
          sign_in_provider: "custom",
        },
      },
    },
  });

  console.log("Coupon result:", result);
}

main().catch((error) => {
  console.error("Coupon test failed:", error);
  process.exitCode = 1;
});
