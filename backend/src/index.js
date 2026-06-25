const express = require("express");
const { db, auth } = require("./firebase");

const app = express();
app.use(express.json());

// Test route
app.get("/", (req, res) => {
  res.send("Civil App Backend is running! 🚀");
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});